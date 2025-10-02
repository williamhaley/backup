package config

import (
	"flag"
	"os"
	"strconv"

	"github.com/goccy/go-yaml"
)

type Config struct {
	Name    string   `yaml:"name"`
	Address string   `yaml:"address"`
	Key     string   `yaml:"key"`
	Sources []string `yaml:"sources"`

	isValidation bool
	isVerbose    bool
	isDryRun     bool
}

var configFilePath string
var isValidation bool
var isVerbose bool
var isDryRun bool

func init() {
	flag.StringVar(&configFilePath, "config", "/etc/backup/backup.yaml", "path to config file")
	flag.BoolVar(&isValidation, "validate", false, "validate config")
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

	if c.Name == "" {
		panic("name not defined")
	}

	if c.Address == "" {
		panic("address not defined")
	}

	if c.Key == "" {
		panic("key not defined")
	}

	if len(c.Sources) < 1 {
		panic("no sources defined")
	}

	c.isValidation = isValidation
	c.isDryRun = isDryRun
	c.isVerbose = isVerbose

	return &c
}

func (c *Config) IsValidation() bool {
	return isValidation
}

func (c *Config) IsDryRun() bool {
	return isDryRun
}

func (c *Config) IsVerbose() bool {
	return isVerbose
}

func (c *Config) Port() string {
	return strconv.Itoa(49152)
}
