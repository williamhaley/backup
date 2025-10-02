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

	args = append(args, "-e", fmt.Sprintf("ssh -p %s -i %s -o \"StrictHostKeychecking=no\" -o \"IdentityAgent=none\" -o \"UserKnownHostsFile=/dev/null\"", config.Port(), config.Key))

	if config.IsDryRun() {
		args = append(args, "--dry-run")
	}

	if config.IsVerbose() {
		args = append(args, "--verbose", "--progress")
	}

	args = append(args, "--filter", fmt.Sprintf("merge %s", filtersFilePath))

	args = append(args, "/", fmt.Sprintf("%s@%s:/", config.Name, config.Address))

	return exec.Command(rsync, args...)
}
