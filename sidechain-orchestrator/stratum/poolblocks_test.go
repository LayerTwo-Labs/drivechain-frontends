package stratum

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// A blocks document from pool.beta.bip300.xyz.
const poolBlocksSample = `{
  "rows": [
    {
      "ts": 1789813418,
      "height": 968557,
      "hash": "0000000000000001f690742605a9dab3df4878e288220ea10abab015400beaa3",
      "finder_address": "bc1qnmdcyzhyv7f5fdtc5c8uy44uv92x5c3u8tdwrz",
      "reward_sats": 309375000,
      "fee_sats": 3125000,
      "status": "confirmed",
      "confirmations": 1220,
      "checked_via": "tips",
      "finder": "bc1qnmdcyzhyv7f5fdtc5c8uy44uv92x5c3u8tdwrz.test2"
    },
    {
      "height": 968556,
      "hash": "0000000000000001c8794cd30ae7c055a82d40d7f2d89b78e51f77149b0eef34",
      "reward_sats": 309375000,
      "fee_sats": 0,
      "status": "pending",
      "confirmations": 0,
      "finder": "someone.else"
    }
  ],
  "next_before": 1789813414
}`

func TestParsePoolBlocks(t *testing.T) {
	blocks, err := ParsePoolBlocks([]byte(poolBlocksSample))
	require.NoError(t, err)
	require.Len(t, blocks, 2)

	assert.Equal(t, uint32(968557), blocks[0].Height)
	assert.Equal(t, int64(309375000), blocks[0].RewardSats)
	assert.Equal(t, int64(3125000), blocks[0].FeeSats)
	assert.Equal(t, "bc1qnmdcyzhyv7f5fdtc5c8uy44uv92x5c3u8tdwrz.test2", blocks[0].Finder)
	assert.Equal(t, "confirmed", blocks[0].Status)
	assert.Equal(t, int32(1220), blocks[0].Confirmations)
	assert.Equal(t, time.Unix(1789813418, 0), blocks[0].FoundAt)
	assert.True(t, blocks[1].FoundAt.IsZero())

	t.Run("a body that is no JSON", func(t *testing.T) {
		_, err := ParsePoolBlocks([]byte("<html>"))
		require.ErrorContains(t, err, "decode the pool blocks")
	})
}

func TestPoolBlocksURL(t *testing.T) {
	url, err := PoolBlocksURL("https://pool.beta.bip300.xyz/api/overview", 20)
	require.NoError(t, err)
	assert.Equal(t, "https://pool.beta.bip300.xyz/api/blocks?limit=20", url)

	url, err = PoolBlocksURL("https://pool.beta.bip300.xyz/api/overview/", 5)
	require.NoError(t, err)
	assert.Equal(t, "https://pool.beta.bip300.xyz/api/blocks?limit=5", url)

	_, err = PoolBlocksURL("pool.beta.bip300.xyz", 20)
	require.ErrorContains(t, err, "no host")
}
