package rsync_test

import (
	"testing"

	"github.com/williamhaley/backup/config"
	"github.com/williamhaley/backup/rsync"
)

var _ = func() bool {
	testing.Init()
	return true
}()

func TestGeneratingAnEmptyRsyncCommand(t *testing.T) {
	config := &config.Config{
		Name:    "my-backup",
		Address: "server-address",
		Key:     "/some/ssh/key/file",
	}
	command := rsync.Command(config, "/my/filters/file")

	want := `/usr/bin/rsync --archive --recursive --delete --delete-excluded -e ssh -p 49152 -i /some/ssh/key/file -o "StrictHostKeychecking=no" -o "IdentityAgent=none" -o "UserKnownHostsFile=/dev/null" --filter merge /my/filters/file / my-backup@server-address:/`
	got := command.String()
	if want != got {
		t.Errorf(`Command() = %q, want == for %q`, got, want)
	}
}
