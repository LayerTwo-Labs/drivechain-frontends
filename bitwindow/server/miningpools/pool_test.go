package miningpools

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func betanetPools(t *testing.T) []Pool {
	t.Helper()
	pools, err := ParseRegistry([]byte(betanetSeed))
	require.NoError(t, err)
	return pools
}

func byName(t *testing.T, pools []Pool, name string) Pool {
	t.Helper()
	for _, pool := range pools {
		if pool.Name == name {
			return pool
		}
	}
	t.Fatalf("no pool named %q", name)
	return Pool{}
}

func TestParseRegistry(t *testing.T) {
	t.Parallel()

	pools := betanetPools(t)

	t.Run("the payout fields come through", func(t *testing.T) {
		t.Parallel()
		pool := byName(t, pools, "eCPool.tech")
		assert.Equal(t, "ecpooltech", pool.Slug)
		assert.Equal(t, "Wired4ncer", pool.Operator)
		assert.Equal(t, "proportional", pool.Mode)
		assert.Equal(t, 50, pool.FeeBps)
		assert.Equal(t, "stratum+tcp://mining.ecpool.tech:3334", pool.StratumURL)
		assert.Equal(t, "https://ecpool.tech", pool.Link)
		assert.Equal(t, []string{"/ecpool.tech/"}, pool.Tags)
	})

	t.Run("coinbase addresses win over the other addresses", func(t *testing.T) {
		t.Parallel()
		assert.Equal(t, []string{"3HxectQ44ECnadiofJjPGRMukEEAkjWjFk"}, byName(t, pools, "Pow.re").Addresses)
	})

	t.Run("the pool address comes before the operator address", func(t *testing.T) {
		t.Parallel()
		assert.Equal(t, []string{"bc1qr7x0rlf56rphwrzcqgl37rmh2zed6xxrmnpwuq"}, byName(t, pools, "ePool").Addresses)
	})

	t.Run("a fee puts the operator address in the coinbase", func(t *testing.T) {
		t.Parallel()
		assert.Equal(t, []string{"bc1qljvzxk0tp6qtrunt590z5rtdhs8jhkkn4ny4rm"}, byName(t, pools, "bip300.xyz").Addresses)
	})

	t.Run("a null stratum URL reads as empty", func(t *testing.T) {
		t.Parallel()
		pool := byName(t, pools, "Pow.re")
		assert.Empty(t, pool.StratumURL)
		assert.Empty(t, pool.Link)
	})

	t.Run("a document with no network is refused", func(t *testing.T) {
		t.Parallel()
		_, err := ParseRegistry([]byte(`{"pools": []}`))
		require.Error(t, err)
	})

	t.Run("a document that is not JSON is refused", func(t *testing.T) {
		t.Parallel()
		_, err := ParseRegistry([]byte(`<html>`))
		require.Error(t, err)
	})
}

func TestParseMempool(t *testing.T) {
	t.Parallel()

	pools, err := ParseMempool([]byte(`[
		{"name": "Foundry USA", "link": "https://foundrydigital.com", "addresses": ["bc1qfoundry"], "tags": ["Foundry USA Pool"]},
		{"name": "AntPool", "link": "https://www.antpool.com", "addresses": [], "tags": ["/AntPool/"]}
	]`))
	require.NoError(t, err)
	require.Len(t, pools, 2)
	assert.Equal(t, "foundryusa", pools[0].Slug)
	assert.Equal(t, []string{"bc1qfoundry"}, pools[0].Addresses)
	assert.Empty(t, pools[0].StratumURL)

	_, err = ParseMempool([]byte(`[]`))
	require.Error(t, err)
}

func TestMatch(t *testing.T) {
	t.Parallel()

	pools := betanetPools(t)
	const operator = "bc1qljvzxk0tp6qtrunt590z5rtdhs8jhkkn4ny4rm"

	for _, test := range []struct {
		name      string
		script    string
		addresses []string
		want      string
	}{
		{
			name:      "an address one pool owns names that pool",
			script:    "\x03\x01\x02\x03",
			addresses: []string{"bc1qminer", "3HxectQ44ECnadiofJjPGRMukEEAkjWjFk"},
			want:      "Pow.re",
		},
		{
			name:      "an owned address wins over the tag of an earlier pool",
			script:    "\x03\x01\x02\x03/bip300xyz/",
			addresses: []string{"bc1qr7x0rlf56rphwrzcqgl37rmh2zed6xxrmnpwuq"},
			want:      "ePool",
		},
		{
			name:      "an address two pools share leaves the tag to decide",
			script:    "\x03\x01\x02\x03/avonpool/",
			addresses: []string{operator, "bc1qfinder"},
			want:      "avonpool",
		},
		{
			name:      "a shared address and no tag names no pool",
			script:    "\x03\x01\x02\x03",
			addresses: []string{operator},
			want:      Unknown.Name,
		},
		{
			name:   "a tag matches in any case",
			script: "\x03\x01\x02\x03/ECPOOL.TECH/",
			want:   "eCPool.tech",
		},
		{
			name:   "nothing known names no pool",
			script: "\x03\x01\x02\x03/somebody/",
			want:   Unknown.Name,
		},
	} {
		t.Run(test.name, func(t *testing.T) {
			t.Parallel()
			assert.Equal(t, test.want, Match([]byte(test.script), test.addresses, pools).Name)
		})
	}
}

func TestTagMatchers(t *testing.T) {
	t.Parallel()

	t.Run("a tag is a regular expression", func(t *testing.T) {
		t.Parallel()
		matches := tagMatchers([]string{"/pool[0-9]+/"})[0]
		assert.True(t, matches("xx/POOL42/xx"))
		assert.False(t, matches("xx/pool/xx"))
	})

	t.Run("a tag that does not compile is a plain substring", func(t *testing.T) {
		t.Parallel()
		matches := tagMatchers([]string{"/pool(/"})[0]
		assert.True(t, matches("xx/Pool(/xx"))
		assert.False(t, matches("xx/pool/xx"))
	})
}

func TestScriptText(t *testing.T) {
	t.Parallel()
	assert.Equal(t, "ÿ/ab/", ScriptText([]byte{0xff, '/', 'a', 'b', '/'}))
}

func TestSlug(t *testing.T) {
	t.Parallel()
	assert.Equal(t, "powre", Slug("Pow.re"))
	assert.Equal(t, "f2pool", Slug("F2 Pool"))
}
