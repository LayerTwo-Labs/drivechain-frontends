package bitnames

import (
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const wireDigest = "34cc446b27c0fd42d572bb1d30e00beb3e74c19edea2c6f2c0241da40637196e"

// The node holds the commitment as a 32-byte array. Its OpenAPI schema calls
// the field a string, so only the wire form proves the shape.
func TestCommitmentReachesTheNodeAsBytes(t *testing.T) {
	digest := wireDigest
	node, err := BitNameData{Commitment: &digest}.toNode()
	require.NoError(t, err)

	raw, err := json.Marshal(node)
	require.NoError(t, err)
	assert.Contains(t, string(raw), `"commitment":[52,204,68,107`)
	assert.NotContains(t, string(raw), wireDigest)
}

func TestCommitmentReadsBackAsHex(t *testing.T) {
	var details nodeBitnameDetails
	require.NoError(t, json.Unmarshal([]byte(`{
		"seq_id": "1739-0029",
		"commitment": [52,204,68,107,39,192,253,66,213,114,187,29,48,224,11,235,62,116,193,158,222,162,198,242,192,36,29,164,6,55,25,110],
		"socket_addr_v4": "203.0.113.7:6002"
	}`), &details))

	client := details.toClient()
	require.NotNil(t, client.Commitment)
	assert.Equal(t, wireDigest, *client.Commitment)
	assert.Equal(t, "1739-0029", client.SeqID)
}

func TestNodeDataKeepsAnEmptyCommitment(t *testing.T) {
	empty := ""
	node, err := BitNameData{Commitment: &empty}.toNode()
	require.NoError(t, err)
	assert.Nil(t, node.Commitment)

	raw, err := json.Marshal(node)
	require.NoError(t, err)
	assert.NotContains(t, string(raw), "commitment")
}

func TestParseCommitmentRefusesTheWrongSize(t *testing.T) {
	_, err := ParseCommitment("deadbeef")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "32")

	_, err = ParseCommitment("zz")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "hexadecimal")
}
