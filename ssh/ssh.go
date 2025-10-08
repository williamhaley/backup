package ssh

import (
	"fmt"
	"os"
	"os/exec"

	"github.com/williamhaley/backup/config"
)

func Test(config *config.Config) error {
	args := []string{
		"-p", config.Port(),
		"-i", config.Key,
		"-o", "StrictHostKeychecking=no",
		"-o", "IdentityAgent=none",
		"-o", "UserKnownHostsFile=/dev/null",
		"-T",
		fmt.Sprintf("%s@%s", config.Name, config.Address),
	}

	cmd := exec.Command("ssh", args...)
	if config.IsVerbose() {
		println(cmd.String())
	}
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}
