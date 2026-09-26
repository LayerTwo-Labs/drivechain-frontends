package engines

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

type watchStore struct {
	deposits []wallet.SidechainDeposit
	dropped  []string
	cleared  []string
}

func (s *watchStore) SidechainDeposits(context.Context, uint32, string) ([]wallet.SidechainDeposit, error) {
	return s.deposits, nil
}

func (s *watchStore) MarkSidechainDepositDropped(_ context.Context, txid string) error {
	s.dropped = append(s.dropped, txid)
	return nil
}

func (s *watchStore) ClearSidechainDepositDrop(_ context.Context, txid string) error {
	s.cleared = append(s.cleared, txid)
	return nil
}

type watchChain struct {
	txErr  error
	tipErr error
}

func (c watchChain) GetRawTransaction(context.Context, string) (*wallet.RawTransaction, error) {
	if c.txErr != nil {
		return nil, c.txErr
	}
	return &wallet.RawTransaction{}, nil
}
func (c watchChain) Broadcast(context.Context, string) (string, error) { return "", nil }
func (c watchChain) TipHeight(context.Context) (int, error)            { return 0, c.tipErr }
func (c watchChain) SpenderOf(context.Context, string, int) (string, bool, error) {
	return "", false, wallet.ErrSpenderUnknown
}

type watchChains struct{ chain wallet.ChainSource }

func (c watchChains) ChainForWallet(string) wallet.ChainSource { return c.chain }

func watchEngine(store *watchStore, chain wallet.ChainSource) *DepositWatchEngine {
	return NewDepositWatchEngine(zerolog.Nop(), store, watchChains{chain: chain}, func() []uint32 { return []uint32{2} })
}

func openDeposit() wallet.SidechainDeposit {
	return wallet.SidechainDeposit{Txid: "dep1", WalletID: "w1", Slot: 2, AmountSats: 1000}
}

// The chain source is up and holds no copy, so the deposit can never confirm.
func TestDepositWatchStampsADepositTheNetworkLost(t *testing.T) {
	store := &watchStore{deposits: []wallet.SidechainDeposit{openDeposit()}}
	engine := watchEngine(store, watchChain{txErr: wallet.ErrTxNotFound})

	engine.tick(context.Background())
	require.Empty(t, store.dropped, "one answer is not proof")

	engine.tick(context.Background())
	require.Equal(t, []string{"dep1"}, store.dropped)
}

// Only "no such transaction" proves a deposit is gone. A rate limit or a
// timeout must not stamp a live deposit and ask for the money again.
func TestDepositWatchLeavesADepositAloneWhenTheSourceIsDown(t *testing.T) {
	store := &watchStore{deposits: []wallet.SidechainDeposit{openDeposit()}}
	chain := watchChain{txErr: errors.New("connection refused")}
	watchEngine(store, chain).tick(context.Background())

	require.Empty(t, store.dropped)
}

// An Esplora rate limit is the exact shape that used to stamp a live deposit.
func TestDepositWatchLeavesADepositAloneOnARateLimit(t *testing.T) {
	store := &watchStore{deposits: []wallet.SidechainDeposit{openDeposit()}}
	watchEngine(store, watchChain{txErr: errors.New("esplora GET /tx: 429 Too Many Requests")}).tick(context.Background())

	require.Empty(t, store.dropped)
}

// The sidechain already took the coin, so the deposit is finished.
func TestDepositWatchSkipsACreditedDeposit(t *testing.T) {
	credited := openDeposit()
	credited.CreditedAt = time.Now()
	store := &watchStore{deposits: []wallet.SidechainDeposit{credited}}
	engine := watchEngine(store, watchChain{txErr: wallet.ErrTxNotFound})
	engine.tick(context.Background())
	engine.tick(context.Background())

	require.Empty(t, store.dropped)
}

// A deposit that turns up again must lose the stamp, or a brief wrong answer
// buries it for good.
func TestDepositWatchLiftsTheStampWhenTheDepositReturns(t *testing.T) {
	back := openDeposit()
	back.DroppedAt = time.Now()
	store := &watchStore{deposits: []wallet.SidechainDeposit{back}}
	watchEngine(store, watchChain{}).tick(context.Background())

	require.Equal(t, []string{"dep1"}, store.cleared)
	require.Empty(t, store.dropped)
}

// One stamp per deposit: the engine runs every minute and must not report the
// same loss again.
func TestDepositWatchStampsADroppedDepositOnlyOnce(t *testing.T) {
	already := openDeposit()
	already.DroppedAt = time.Now()
	store := &watchStore{deposits: []wallet.SidechainDeposit{already}}
	engine := watchEngine(store, watchChain{txErr: wallet.ErrTxNotFound})
	engine.tick(context.Background())
	engine.tick(context.Background())

	require.Empty(t, store.dropped)
	require.Empty(t, store.cleared)
}

// A live deposit stays untouched.
func TestDepositWatchLeavesALiveDepositAlone(t *testing.T) {
	store := &watchStore{deposits: []wallet.SidechainDeposit{openDeposit()}}
	watchEngine(store, watchChain{}).tick(context.Background())

	require.Empty(t, store.dropped)
	require.Empty(t, store.cleared)
}

// One Esplora host in a list can answer 404 while another still holds the
// transaction. A deposit that turns up on the next pass must clear the count,
// so a later single wrong answer cannot stamp it either.
func TestDepositWatchNeedsAgreeingPasses(t *testing.T) {
	store := &watchStore{deposits: []wallet.SidechainDeposit{openDeposit()}}
	chain := &flakyChain{}
	engine := watchEngine(store, chain)

	chain.missing = true
	engine.tick(context.Background())
	chain.missing = false
	engine.tick(context.Background())
	chain.missing = true
	engine.tick(context.Background())

	require.Empty(t, store.dropped, "the count must restart when the deposit turns up")
}

// flakyChain reports the deposit gone or present on demand.
type flakyChain struct{ missing bool }

func (c *flakyChain) GetRawTransaction(context.Context, string) (*wallet.RawTransaction, error) {
	if c.missing {
		return nil, wallet.ErrTxNotFound
	}
	return &wallet.RawTransaction{}, nil
}
func (c *flakyChain) Broadcast(context.Context, string) (string, error) { return "", nil }
func (c *flakyChain) TipHeight(context.Context) (int, error)            { return 0, nil }
func (c *flakyChain) SpenderOf(context.Context, string, int) (string, bool, error) {
	return "", false, wallet.ErrSpenderUnknown
}
