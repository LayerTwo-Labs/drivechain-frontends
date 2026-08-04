package engines

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	txidA = "0000000000000000000000000000000000000000000000000000000000000001"
	txidB = "0000000000000000000000000000000000000000000000000000000000000002"
)

// A one-transaction block is its own merkle root. The UI renders only the
// formatted text, so this branch must fill it too.
func TestCalculateMerkleTreeSingleTransactionHasText(t *testing.T) {
	t.Parallel()

	result, err := CalculateMerkleTree([]string{txidA})
	require.NoError(t, err)

	assert.Equal(t, txidA, result.MerkleRoot)
	assert.NotEmpty(t, result.FormattedText)
	assert.Contains(t, result.FormattedText, txidA)
}

func TestCalculateMerkleTreeTwoTransactions(t *testing.T) {
	t.Parallel()

	result, err := CalculateMerkleTree([]string{txidA, txidB})
	require.NoError(t, err)

	assert.Len(t, result.Levels, 2)
	assert.NotEmpty(t, result.FormattedText)
	assert.NotEqual(t, txidA, result.MerkleRoot)
}

func TestFormatMerkleTreeOmitsRCBWhenNil(t *testing.T) {
	t.Parallel()

	result, err := CalculateMerkleTree([]string{txidA, txidB})
	require.NoError(t, err)

	withRCB := FormatMerkleTree(result.Levels, result.RCBLevels)
	withoutRCB := FormatMerkleTree(result.Levels, nil)

	assert.Contains(t, withRCB, "RCB:")
	assert.False(t, strings.Contains(withoutRCB, "RCB:"), "nil rcbLevels must drop the RCB rows")
}

func TestCalculateMerkleTreeRejectsEmpty(t *testing.T) {
	t.Parallel()

	_, err := CalculateMerkleTree(nil)
	require.Error(t, err)
}
