package api

import (
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Thunder nests the header, and truthcoin flattens it into the block. A bid
// on an empty parent hash never passes the tip check.
func TestTemplatePrevMainHashReadsBothShapes(t *testing.T) {
	for name, block := range map[string]string{
		"nested": `{"header":{"merkle_root":"m","prev_side_hash":null,"prev_main_hash":"aa"},"body":{"transactions":[]}}`,
		"flat":   `{"merkle_root":"m","prev_side_hash":null,"prev_main_hash":"aa","transactions":[],"height":0}`,
	} {
		t.Run(name, func(t *testing.T) {
			got, err := templatePrevMainHash(json.RawMessage(block))
			require.NoError(t, err)
			assert.Equal(t, "aa", got)
		})
	}
}
