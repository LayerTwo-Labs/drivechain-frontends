package engines

import (
	"context"
	"errors"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/stretchr/testify/require"
)

type depositList struct {
	deposits []*orchpb.SidechainDeposit
	err      error
}

func (d depositList) ListSidechainDeposits(context.Context, uint32, string) ([]*orchpb.SidechainDeposit, error) {
	return d.deposits, d.err
}

type recorder struct {
	events    []*notificationv1.WatchResponse
	listeners int
}

// Deliver takes the event only when a frontend listens, which is what the real
// engine does with a non-blocking send to its subscriber channels.
func (r *recorder) Deliver(_ context.Context, event *notificationv1.WatchResponse) int {
	if r.listeners <= 0 {
		return 0
	}
	r.events = append(r.events, event)
	return r.listeners
}

func droppedEngine(t *testing.T, list DepositLister, sink *recorder) *DepositDroppedEngine {
	t.Helper()
	if sink.listeners == 0 {
		sink.listeners = 1
	}
	return NewDepositDroppedEngine(database.Test(t), list, sink, func() []uint32 { return []uint32{2} })
}

func deposit(txid string, droppedAt string) *orchpb.SidechainDeposit {
	return &orchpb.SidechainDeposit{Txid: txid, AmountSats: 50_000, DroppedAt: droppedAt}
}

// The coin never reaches the sidechain, and nothing else in the app says so.
func TestDepositDroppedEngineTellsTheUser(t *testing.T) {
	sink := &recorder{}
	list := depositList{deposits: []*orchpb.SidechainDeposit{deposit("lost", "2026-09-26T10:00:00Z")}}
	droppedEngine(t, list, sink).tick(context.Background())

	require.Len(t, sink.events, 1)
	system := sink.events[0].GetSystem()
	require.NotNil(t, system)
	require.Equal(t, notificationv1.SystemEvent_TYPE_DEPOSIT_DROPPED, system.Type)
	require.Contains(t, system.Message, "Deposit again")
}

// The engine re-reads the same row every minute, so one loss is one message.
func TestDepositDroppedEngineReportsOneDepositOnce(t *testing.T) {
	sink := &recorder{}
	list := depositList{deposits: []*orchpb.SidechainDeposit{deposit("lost", "2026-09-26T10:00:00Z")}}
	engine := droppedEngine(t, list, sink)

	engine.tick(context.Background())
	engine.tick(context.Background())
	engine.tick(context.Background())

	require.Len(t, sink.events, 1)
}

// A deposit that can still confirm is not news.
func TestDepositDroppedEngineStaysQuietForALiveDeposit(t *testing.T) {
	sink := &recorder{}
	list := depositList{deposits: []*orchpb.SidechainDeposit{deposit("live", "")}}
	droppedEngine(t, list, sink).tick(context.Background())

	require.Empty(t, sink.events)
}

// The orchestrator is down, so the engine knows nothing and says nothing.
func TestDepositDroppedEngineStaysQuietWhenItCannotRead(t *testing.T) {
	sink := &recorder{}
	droppedEngine(t, depositList{err: errors.New("orchestrator unavailable")}, sink).tick(context.Background())

	require.Empty(t, sink.events)
}

// BitWindow is closed, so a broadcast reaches nobody. The news must survive
// until a frontend attaches rather than get consumed in silence.
func TestDepositDroppedEngineHoldsTheNewsWithNoListener(t *testing.T) {
	sink := &recorder{listeners: 0}
	list := depositList{deposits: []*orchpb.SidechainDeposit{deposit("lost", "2026-09-26T10:00:00Z")}}
	engine := NewDepositDroppedEngine(database.Test(t), list, sink, func() []uint32 { return []uint32{2} })

	engine.tick(context.Background())
	require.Empty(t, sink.events)

	// A frontend attaches, and the same deposit reports on the next pass.
	sink.listeners = 1
	engine.tick(context.Background())
	require.Len(t, sink.events, 1)
}

// A deposit that comes back and drops again is a new episode. The old report
// must not silence it, or the user hears about the loss only once.
func TestDepositDroppedEngineReportsASecondEpisode(t *testing.T) {
	sink := &recorder{listeners: 1}
	list := &mutableList{deposits: []*orchpb.SidechainDeposit{deposit("flaky", "2026-09-26T10:00:00Z")}}
	engine := NewDepositDroppedEngine(database.Test(t), list, sink, func() []uint32 { return []uint32{2} })

	engine.tick(context.Background())
	require.Len(t, sink.events, 1)

	// The orchestrator lifts the stamp: the deposit turned up again.
	list.deposits = []*orchpb.SidechainDeposit{deposit("flaky", "")}
	engine.tick(context.Background())
	require.Len(t, sink.events, 1)

	// It drops a second time.
	list.deposits = []*orchpb.SidechainDeposit{deposit("flaky", "2026-09-26T12:00:00Z")}
	engine.tick(context.Background())
	require.Len(t, sink.events, 2, "a second loss must reach the user")
}

type mutableList struct{ deposits []*orchpb.SidechainDeposit }

func (m *mutableList) ListSidechainDeposits(context.Context, uint32, string) ([]*orchpb.SidechainDeposit, error) {
	return m.deposits, nil
}
