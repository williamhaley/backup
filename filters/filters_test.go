package filters

import (
	"testing"
)

func TestAnEmptyFilter(t *testing.T) {
	filters := NewFilters()

	want := "- /**"
	got := filters.String()
	if want != got {
		t.Errorf(`filters.String() = %q, want == for %q`, got, want)
	}
}

func TestOneEntry(t *testing.T) {
	filters := NewFilters()
	filters.AddPath("/my/cool/path")

	want := `+ /my
+ /my/cool
+ /my/cool/path**
- /**`
	got := filters.String()
	if want != got {
		t.Errorf(`filters.String() = %q, want == for %q`, got, want)
	}
}

func TestTwoNonOverlappingEntries(t *testing.T) {
	filters := NewFilters()
	filters.AddPath("/totally/different/path")
	filters.AddPath("/my/cool/path")

	want := `+ /my
+ /my/cool
+ /my/cool/path**
+ /totally
+ /totally/different
+ /totally/different/path**
- /**`
	got := filters.String()
	if want != got {
		t.Errorf(`filters.String() = %q, want == for %q`, got, want)
	}
}

func TestTwoOverlappingEntries(t *testing.T) {
	filters := NewFilters()
	filters.AddPath("/my/first/path")
	filters.AddPath("/my/second/path")

	want := `+ /my
+ /my/first
+ /my/first/path**
+ /my/second
+ /my/second/path**
- /**`
	got := filters.String()
	if want != got {
		t.Errorf(`filters.String() = %q, want == for %q`, got, want)
	}
}
