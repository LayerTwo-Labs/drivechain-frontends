package api

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestConnectTarget(t *testing.T) {
	tests := []struct {
		name       string
		want       string
		inclusions []string
		target     string
	}{
		{
			name:       "the caller names the block the sidechain holds",
			want:       "main-2",
			inclusions: []string{"main-2"},
			target:     "main-2",
		},
		{
			name:       "the sidechain has not seen the named block yet",
			want:       "main-2",
			inclusions: nil,
			target:     "",
		},
		{
			name:       "the sidechain holds another block for the bid",
			want:       "main-2",
			inclusions: []string{"main-9"},
			target:     "",
		},
		{
			name:       "the caller names no block",
			inclusions: []string{"main-2", "main-3"},
			target:     "main-2",
		},
		{
			name:       "the caller names no block and the sidechain lists none",
			inclusions: nil,
			target:     "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			assert.Equal(t, tt.target, connectTarget(tt.want, tt.inclusions))
		})
	}
}
