package main

import (
	"backup/config"
	"backup/filters"
	"backup/rsync"
	"fmt"
	"log"
	"os"
)

func main() {
	euid := os.Geteuid()
	if euid != 0 {
		// TODO I don't like this, but it's how my system backups work today :shrug:
		panic("not sudo")
	}

	config := config.New()

	filters := filters.NewFilters()
	for _, source := range config.Sources {
		filters.AddPath(source)
	}

	// Create a temporary file with all the filters.
	filtersFile, err := os.CreateTemp("", "")
	if err != nil {
		panic(err)
	}
	// Defer the close and delete of the temporary filters file.
	defer func() {
		filtersFile.Close()
		os.Remove(filtersFile.Name())
	}()

	filtersFile.WriteString(filters.String())

	command := rsync.Command(config, filtersFile.Name())
	command.Stdout = os.Stdout
	command.Stderr = os.Stderr

	if config.IsVerbose() {
		fmt.Println(command)
	}

	if err := command.Run(); err != nil {
		log.Fatalf("error: %v", err)
	}
}
