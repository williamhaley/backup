package config

import (
	"flag"
	"os"

	"github.com/goccy/go-yaml"
)

type Config struct {
	Destination    string   `yaml:"destination"`
	DestinationKey string   `yaml:"destination_key"`
	Sources        []string `yaml:"sources"`

	isVerbose bool
	isDryRun  bool
}

var configFilePath string
var isVerbose bool
var isDryRun bool

func init() {
	flag.StringVar(&configFilePath, "config", "/etc/backup/backup.yaml", "path to config file")
	flag.BoolVar(&isVerbose, "verbose", false, "verbose logging")
	flag.BoolVar(&isDryRun, "dry-run", false, "dry run without any actual backing up")
}

func New() *Config {
	flag.Parse()

	file, err := os.Open(configFilePath)
	if err != nil {
		panic(err)
	}

	var c Config

	decoder := yaml.NewDecoder(file)
	if err := decoder.Decode(&c); err != nil {
		panic(err)
	}

	if c.Destination == "" {
		panic("destination not defined")
	}

	if c.DestinationKey == "" {
		panic("destination_key not defined")
	}

	if len(c.Sources) < 1 {
		panic("no sources defined")
	}

	c.isDryRun = isDryRun
	c.isVerbose = isVerbose

	return &c
}

func (c *Config) IsDryRun() bool {
	return isDryRun
}

func (c *Config) IsVerbose() bool {
	return isVerbose
}
