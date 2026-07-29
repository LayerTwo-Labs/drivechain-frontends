package engines

import (
	"testing"
)

func TestChequeDescriptorRangeEnd(t *testing.T) {
	cases := []struct {
		name  string
		index uint32
		want  uint32
	}{
		{"first cheque", 0, chequeDescriptorRangeStep},
		{"inside first step", 1999, chequeDescriptorRangeStep},
		// The index that used to fall outside the fixed range.
		{"step boundary", 2000, 2 * chequeDescriptorRangeStep},
		{"past first step", 2001, 2 * chequeDescriptorRangeStep},
		{"many steps in", 123456, 124000},
		{"clamped to core maximum", 999999, chequeDescriptorRangeMax},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got := chequeDescriptorRangeEnd(tc.index)
			if got != tc.want {
				t.Fatalf("chequeDescriptorRangeEnd(%d) = %d, want %d", tc.index, got, tc.want)
			}
			if got < tc.index {
				t.Fatalf("chequeDescriptorRangeEnd(%d) = %d does not cover the index", tc.index, got)
			}
		})
	}
}
