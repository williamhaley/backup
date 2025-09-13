package rsync

import (
	"fmt"
	"os/exec"

	"github.com/williamhaley/backup/config"
)

func Command(config *config.Config, filtersFilePath string) *exec.Cmd {
	rsync := "rsync"

	args := []string{
		"--archive",
		"--recursive",

		"--delete",
		"--delete-excluded",
	}

	args = append(args, "-e", fmt.Sprintf("ssh -p 2222 -i %s -o \"StrictHostKeychecking=no\" -o \"IdentityAgent=none\" -o \"UserKnownHostsFile=/dev/null\"", config.DestinationKey))

	if config.IsDryRun() {
		args = append(args, "--dry-run")
	}

	if config.IsVerbose() {
		args = append(args, "--verbose", "--progress")
	}

	args = append(args, "--filter", fmt.Sprintf("merge %s", filtersFilePath))

	args = append(args, "/", config.Destination)

	return exec.Command(rsync, args...)
}
