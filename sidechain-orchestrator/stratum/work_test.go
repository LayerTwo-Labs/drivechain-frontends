package stratum

import (
	"encoding/hex"
	"fmt"
	"testing"

	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Block 100000 of Bitcoin mainnet.
const (
	block100000Hash       = "000000000003ba27aa200b1cecaad478d2b00432346c3f1f3986da1afd33e506"
	block100000PrevHash   = "000000000002d01c1fccc21636b607dfd930d31d01c3a62104612a1719011250"
	block100000MerkleRoot = "f3e94742aca4b5ef85488dc37c06c3282295ffec960994b2c0d5ac2a25a95766"
	block100000Coinbase   = "01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff08044c86041b020602ffffffff0100f2052a010000004341041b0e8c2567c12536aa13357b79a073dc4444acb83c4ec7a0e2f99dd7457516c5817242da796924ca4e99947d087fedf9ce467cb9f7c6287078f801df276fdf84ac00000000"
)

var block100000Txids = []string{
	"8c14f0db3df150123e6f3dbbf30f8b955a8249b62ac1d1ff16284aefa3d06d87",
	"fff2525b8931402dd09222c50775608f75787bd2b87e56995a7bdd30f79702c4",
	"6359f0868171b1d194cbee1af2f16ea598ae8fad666d9b012c8ed2b79a236ec4",
	"e9a66845e05d5abc0ad04ec80f774a7e585c6e8db975962d069a522137b80c1d",
}

func hashes(t *testing.T, texts []string) []chainhash.Hash {
	t.Helper()
	out := make([]chainhash.Hash, len(texts))
	for i, text := range texts {
		h, err := chainhash.NewHashFromStr(text)
		require.NoError(t, err)
		out[i] = *h
	}
	return out
}

// fullMerkleRoot builds the whole tree, the way a node does.
func fullMerkleRoot(leaves []chainhash.Hash) chainhash.Hash {
	level := append([]chainhash.Hash(nil), leaves...)
	for len(level) > 1 {
		if len(level)%2 == 1 {
			level = append(level, level[len(level)-1])
		}
		var next []chainhash.Hash
		for i := 0; i < len(level); i += 2 {
			next = append(next, doubleSHA256(append(level[i][:], level[i+1][:]...)))
		}
		level = next
	}
	return level[0]
}

func TestMerkleBranch(t *testing.T) {
	t.Run("a known block", func(t *testing.T) {
		txids := hashes(t, block100000Txids)
		root := merkleRoot(txids[0], merkleBranch(txids[1:]))
		assert.Equal(t, block100000MerkleRoot, root.String())
	})

	t.Run("every transaction count up to twelve", func(t *testing.T) {
		for n := 0; n <= 12; n++ {
			t.Run(fmt.Sprint(n), func(t *testing.T) {
				leaves := make([]chainhash.Hash, n+1)
				for i := range leaves {
					leaves[i] = doubleSHA256([]byte(fmt.Sprintf("tx %d", i)))
				}
				assert.Equal(t, fullMerkleRoot(leaves), merkleRoot(leaves[0], merkleBranch(leaves[1:])))
			})
		}
	})
}

func TestStratumPrevHash(t *testing.T) {
	prev, err := chainhash.NewHashFromStr(block100000PrevHash)
	require.NoError(t, err)

	encoded := stratumPrevHash(*prev)
	assert.Equal(t, "1901125004612a1701c3a621d930d31d36b607df1fccc2160002d01c00000000", hex.EncodeToString(encoded))

	back, err := parseStratumPrevHash(encoded)
	require.NoError(t, err)
	assert.Equal(t, *prev, back)
}

func TestSolve(t *testing.T) {
	coinbase, err := hex.DecodeString(block100000Coinbase)
	require.NoError(t, err)
	txids := hashes(t, block100000Txids)
	prev, err := chainhash.NewHashFromStr(block100000PrevHash)
	require.NoError(t, err)

	w := &Work{
		PrevHash: *prev,
		Coinb1:   coinbase[:40],
		Coinb2:   coinbase[52:],
		Branch:   merkleBranch(txids[1:]),
		Version:  1,
		Bits:     0x1b04864c,
		Time:     1293623863,
	}
	gotCoinbase, header := solve(w, coinbase[40:44], coinbase[44:52], 1293623863, 274148111, 1)
	assert.Equal(t, coinbase, gotCoinbase)

	hash := header.BlockHash()
	assert.Equal(t, block100000Hash, hash.String())
	assert.InDelta(t, 14484.162361225399, NetworkDifficulty(w.Bits), 1e-6)
	assert.GreaterOrEqual(t, hashDifficulty(hash), NetworkDifficulty(w.Bits))

	t.Run("a wrong nonce misses the target", func(t *testing.T) {
		_, header := solve(w, coinbase[40:44], coinbase[44:52], 1293623863, 274148112, 1)
		assert.Less(t, hashDifficulty(header.BlockHash()), NetworkDifficulty(w.Bits))
	})
}

func TestDifficultyTarget(t *testing.T) {
	assert.InDelta(t, 1.0, difficultyOf(diff1Target), 1e-12)
	assert.InDelta(t, 8192.0, difficultyOf(targetOf(8192)), 1e-6)
	assert.Equal(t, 1, targetOf(1).Cmp(targetOf(2)))
}

func TestRollVersion(t *testing.T) {
	tests := []struct {
		name    string
		version int32
		bits    uint32
		mask    uint32
		want    int32
		wantErr bool
	}{
		{name: "no bits", version: 0x20000000, bits: 0, mask: VersionMask, want: 0x20000000},
		{name: "bits inside the mask", version: 0x20000000, bits: 0x1fffe000, mask: VersionMask, want: 0x3fffe000},
		{name: "bits replace the job bits", version: 0x20002000, bits: 0x00004000, mask: VersionMask, want: 0x20004000},
		{name: "a bit outside the mask", version: 0x20000000, bits: 0x00001000, mask: VersionMask, wantErr: true},
		{name: "no mask agreed", version: 0x20000000, bits: 0x00002000, mask: 0, wantErr: true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := rollVersion(tt.version, tt.bits, tt.mask)
			if tt.wantErr {
				require.Error(t, err)
				return
			}
			require.NoError(t, err)
			assert.Equal(t, tt.want, got)
		})
	}
}

func TestSplitExtranonce(t *testing.T) {
	tests := []struct {
		size, prefix, miner int
		wantErr             bool
	}{
		{size: 12, prefix: 4, miner: 8},
		{size: 8, prefix: 4, miner: 4},
		{size: 6, prefix: 3, miner: 3},
		{size: 4, prefix: 2, miner: 2},
		{size: 2, prefix: 1, miner: 1},
		{size: 1, wantErr: true},
	}
	for _, tt := range tests {
		t.Run(fmt.Sprint(tt.size), func(t *testing.T) {
			prefix, miner, err := splitExtranonce(tt.size)
			if tt.wantErr {
				require.Error(t, err)
				return
			}
			require.NoError(t, err)
			assert.Equal(t, tt.prefix, prefix)
			assert.Equal(t, tt.miner, miner)
		})
	}
}
