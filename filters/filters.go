package filters

import (
	"os"
	"path"
	"slices"
	"strings"
)

// TODO always true for now, but could be false for excludes
type Filters map[string]bool

func NewFilters() Filters {
	return make(map[string]bool)
}

func (f Filters) AddPath(sourcePath string) {
	prefix := ""

	for _, piece := range strings.Split(strings.TrimSpace(sourcePath), string(os.PathSeparator)) {
		if piece == "" {
			continue
		}

		prefix = path.Join(prefix, piece)

		if "/"+prefix == sourcePath {
			f["+ "+sourcePath+"**"] = true
		} else {
			f["+ "+"/"+prefix] = true
		}
	}
}

func (f Filters) String() string {
	list := make([]string, len(f))

	index := 0
	for filter := range f {
		list[index] = filter
		index += 1
	}

	slices.Sort(list)

	list = append(list, "- /**")

	return strings.Join(list, "\n")
}
