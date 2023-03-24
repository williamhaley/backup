#!/usr/bin/env bash

set -e

[ $EUID -ne 0 ] && echo "run as root" >&2 && exit 1

temp_dir=$(mktemp -d)

interrupt()
{
  echo "cleaning up..."
  umount "${temp_dir}/gocryptfs" 2> /dev/null
}

trap interrupt INT EXIT

verify_binary()
{
	if ! command -v "${1}" > /dev/null
	then
		echo "${1} not found"
		exit 1
	fi
}

# Check for required binaries
verify_binary rsync
verify_binary gocryptfs
verify_binary yq
verify_binary backblaze-cli

function backup()
{
	local config="${1}"

	is_enabled=$(yq -r '(select(has("enabled")) // { "enabled": true } | .enabled)' "${config}")
	filters=$(yq -r '.filters' "${config}")
	# If there are no destinations default to an empty array
	b2_enabled_status=$(yq -r '.b2.enabled // false' "${config}")
	b2_bucket_path=$(yq -r '.b2.bucket' "${config}")
	local_backup_destination=$(yq -r '.destination' "${config}")
	additional_local_destinations=$(yq -r '.destinations // []' "${config}")

	if [ ! -d "${local_backup_destination}" ]
	then
		echo "backup destination '${local_backup_destination}' does not exist"
		exit 1
	fi

	backup_name="$(basename "${config}" ".yaml")"
	echo "[backup: '${backup_name}']"

	if [ "${is_enabled}" != "true" ]
	then
		echo "not enabled"
		return
	fi

	if [ -z "${filters}" ]
	then
		return
	fi

	echo "${filters}" > "${temp_dir}/filters.txt"

	timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

	if [ ! -d "${local_backup_destination}/latest" ]
	then
		echo "create initial backup"

		rsync \
			--verbose \
			--partial \
			--progress \
			--human-readable \
			--recursive \
			--archive \
			--delete \
			--delete-excluded \
			--filter="merge ${temp_dir}/filters.txt" \
			/ \
			"${local_backup_destination}/initial"

		ln -s "${local_backup_destination}/initial" "${local_backup_destination}/latest"
	fi

	rsync \
		--verbose \
		--partial \
		--progress \
		--human-readable \
		--recursive \
		--archive \
		--delete \
		--delete-excluded \
		--filter "merge ${temp_dir}/filters.txt" \
		--link-dest="${local_backup_destination}/latest" \
		/ \
		"${local_backup_destination}/${timestamp}"

	# Delete the symlink
	rm -f "${local_backup_destination}/latest"

	# Create a new snapshot
	ln -s "${local_backup_destination}/${timestamp}" "${local_backup_destination}/latest"

	# Sync the latest snapshot to any specified destinations
	while read -r additional_local_destination
	do
		additional_destination_path=$(yq -r '.path' <<< "${additional_local_destination}")

		if ! mountpoint -q "${additional_destination_path}"
		then
			continue
		fi

		echo "[destination sync: '${backup_name}' => '${additional_destination_path}']"

		destination_filters_file=$(mktemp)
		# If there are no filters default to an empty string
		yq -r '.filters // ""' <<< "${additional_local_destination}" > "${destination_filters_file}"

		rsync \
			--archive \
			--recursive \
			--delete \
			--delete-excluded \
			--delete-before `# always --delete-before on a destination in case it gets full and we need to delete before adding new data` \
			--filter="merge ${destination_filters_file}" \
			--progress \
			--verbose \
			"${local_backup_destination}/latest/" "${additional_destination_path}/${backup_name}/"

		rm -f "${destination_filters_file}"
	done < <(yq -c '.[]' <<< "${additional_local_destinations}")

	if [ "${b2_enabled_status}" = "true" ]
	then
		echo "[b2 sync: '${backup_name}' => 'b2://${b2_bucket_path}']"

		mkdir -p "${temp_dir}/gocryptfs"

		# Mount a reverse encrypted filesystem of the latest backup for transmission
		# to B2 or any other services aside from Backblaze that do not support file
		# level encryption. Note, this snippet is how the reverse mount config is
		# created. It is re-used across all reverse mounts, which means one single
		# key is shared. Save the config file generated from this command as it is
		# used later for the reverse mounts. Note that the file names will be plain
		# text, which is less secure, but easier to debug.
		# sudo gocryptfs -aessiv -init -plaintextnames -passfile ./gocryptfs.key /tmp/cipherdir
		gocryptfs \
			-config "$(yq -r '.b2.gocryptfs_config_file // null' "${config}")" \
			-passfile "$(yq -r '.b2.gocryptfs_key_file // null' "${config}")" \
			-ro \
			-reverse \
			"${local_backup_destination}/latest/" "${temp_dir}/gocryptfs"

		application_key_id=$(yq -r '.b2.application_key_id // null' "${config}")
		application_key=$(yq -r '.b2.application_key // null' "${config}")

		excludes=$(yq -r '.b2.excludes // [] | .[]' "${config}")
		additional_arguments=()
		if [ -n "${excludes}" ]
		then
			for exclude in ${excludes}
			do
				if [ -n "${exclude}" ]
				then
					additional_arguments+=(--excludeRegex "${exclude}")
				fi
			done
		fi

		set -x
		B2_APPLICATION_KEY_ID="${application_key_id}" B2_APPLICATION_KEY="${application_key}" backblaze-cli sync "${additional_arguments[@]}" --delete "${temp_dir}/gocryptfs" "b2://${b2_bucket_path}"
		set +x

		umount "${temp_dir}/gocryptfs"
	fi
}

for config in /etc/backup/*.yaml
do
	backup "${config}"
done
