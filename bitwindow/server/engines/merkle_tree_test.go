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

func TestCalculateMerkleTreeBlock100000(t *testing.T) {
	t.Parallel()

	result, err := CalculateMerkleTree([]string{
		"8c14f0db3df150123e6f3dbbf30f8b955a8249b62ac1d1ff16284aefa3d06d87",
		"fff2525b8931402dd09222c50775608f75787bd2b87e56995a7bdd30f79702c4",
		"6359f0868171b1d194cbee1af2f16ea598ae8fad666d9b012c8ed2b79a236ec4",
		"e9a66845e05d5abc0ad04ec80f774a7e585c6e8db975962d069a522137b80c1d",
	})
	require.NoError(t, err)

	assert.Equal(t, "f3e94742aca4b5ef85488dc37c06c3282295ffec960994b2c0d5ac2a25a95766", result.MerkleRoot)
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
	require.ErrorContains(t, err, "no transactions provided")
}
