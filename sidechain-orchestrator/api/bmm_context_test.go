package api

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// getblockchaininfo returns warnings as a string before Bitcoin Core 25 and as
// an array after it. Both shapes reach the BMM panel as one line.
func TestCoreWarnings(t *testing.T) {
	tests := []struct {
		name string
		in   any
		want string
	}{
		{"absent", nil, ""},
		{"empty string", "", ""},
		{"pre-25 string", "Unknown new rules activated", "Unknown new rules activated"},
		{"post-25 empty array", []any{}, ""},
		{"post-25 one entry", []any{"Unknown new rules activated"}, "Unknown new rules activated"},
		{"post-25 two entries", []any{"first", "second"}, "first; second"},
		{"post-25 drops blanks", []any{"", "kept", ""}, "kept"},
		{"unexpected shape", 42, ""},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			assert.Equal(t, tt.want, coreWarnings(tt.in))
		})
	}
}
