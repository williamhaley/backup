package rsync_test

import (
	"backup/config"
	"backup/rsync"
	"testing"
)

var _ = func() bool {
	testing.Init()
	return true
}()

func TestGeneratingAnEmptyRsyncCommand(t *testing.T) {
	config := &config.Config{
		Destination:    "/some/destination/my-backup",
		DestinationKey: "/some/ssh/key/file",
	}
	command := rsync.Command(config, "/my/filters/file")

	want := `/usr/bin/rsync --archive --recursive --delete --delete-excluded -e ssh -p 2222 -i /some/ssh/key/file -o "StrictHostKeychecking=no" -o "IdentityAgent=none" -o "UserKnownHostsFile=/dev/null" --filter merge /my/filters/file / /some/destination/my-backup`
	got := command.String()
	if want != got {
		t.Errorf(`Command() = %q, want == for %q`, got, want)
	}
}
