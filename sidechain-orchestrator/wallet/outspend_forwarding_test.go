package wallet

import (
	"context"
	"errors"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// The production wiring hands the electrum backend a *NetworkChainSource, not
// a bare *EsploraClient. Without forwarding, every light wallet silently loses
// the spender lookup and a deposit rebuilds on a stale treasury output.
func TestNetworkChainSourceForwardsOutspend(t *testing.T) {
	var _ outspendSource = (*NetworkChainSource)(nil)
	var _ outspendSource = (*fallbackChainSource)(nil)
	var _ outspendSource = (*EsploraClient)(nil)
}

// An Electrum endpoint cannot name a spender, so the wrapper says so rather
// than report the outpoint as unspent.
func TestNetworkChainSourceReportsAnUnknownSpender(t *testing.T) {
	source := NewNetworkChainSource(func() ChainTarget {
		return ChainTarget{Network: "regtest", URLs: []string{"ssl://electrum.example:50002"}, Params: &chaincfg.RegressionNetParams}
	}, zerolog.Nop())

	_, _, err := source.Outspend(context.Background(), "abc", 0)

	require.ErrorIs(t, err, ErrSpenderUnknown)
}

// Mainnet runs an Electrum-only source, so without this mapping the deposit
// watch never learns that a deposit is gone and it stays pending for ever.
func TestElectrumReportsAMissingTransaction(t *testing.T) {
	err := electrumRPCError("No such mempool or blockchain transaction. Use gettransaction for wallet transactions.")

	require.True(t, allNotFound(err))
	require.Contains(t, err.Error(), "electrum error")
}

// Any other server failure proves nothing about the transaction.
func TestElectrumKeepsAnOtherFailureGeneric(t *testing.T) {
	require.False(t, allNotFound(electrumRPCError("server busy")))
}

// A per-source error must never carry the sentinel. errors.Is walks every
// branch of a joined error, so a wrapped sentinel would read as proof beside a
// live server that failed for its own reason.
func TestPerSourceErrorsNeverCarryTheSentinel(t *testing.T) {
	missing := electrumRPCError("No such mempool or blockchain transaction.")
	transient := errors.New("dial tcp: i/o timeout")

	require.NotErrorIs(t, missing, ErrTxNotFound)
	require.NotErrorIs(t, errors.Join(missing, transient), ErrTxNotFound)
	require.False(t, allNotFound(errors.Join(missing, transient)))
	require.True(t, allNotFound(errors.Join(missing, missing)))
}

// A fallback joins the errors of every source. One 404 beside a transient
// failure must not read as proof, or the watch stamps a live deposit.
func TestAllNotFoundNeedsEveryAnswer(t *testing.T) {
	missing := &esploraStatusError{code: 404, msg: "not found"}
	transient := errors.New("dial tcp: i/o timeout")

	require.True(t, allNotFound(missing))
	require.True(t, allNotFound(errors.Join(missing, missing)))
	require.False(t, allNotFound(errors.Join(missing, transient)))
	require.False(t, allNotFound(transient))
}
