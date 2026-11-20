package api

import (
	"context"
	"sync"
	"time"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

// binariesFeed reads the binary list one time for all WatchBinaries streams
// of one ForceBackend value, and wakes them on each change.
type binariesFeed struct {
	read    func() []*pb.BinaryStatusMsg
	changed func(ctx context.Context) <-chan struct{}
	recheck time.Duration

	mu     sync.Mutex
	last   []*pb.BinaryStatusMsg
	subs   map[chan struct{}]struct{}
	cancel context.CancelFunc
}

func newBinariesFeed(orch *orchestrator.Orchestrator, opts orchestrator.DownloadOptions) *binariesFeed {
	return &binariesFeed{
		read: func() []*pb.BinaryStatusMsg {
			statuses := orch.ListAllState(opts)
			out := make([]*pb.BinaryStatusMsg, len(statuses))
			for i, s := range statuses {
				out[i] = statusToProto(s)
			}
			return out
		},
		changed: orch.SubscribeBinaries,
		recheck: binariesRecheckInterval,
	}
}

// subscribe returns a channel that wakes on each change of the list. The
// first subscriber starts the reads, and the last one to leave stops them.
func (f *binariesFeed) subscribe(ctx context.Context) <-chan struct{} {
	ch := make(chan struct{}, 1)
	f.mu.Lock()
	if f.subs == nil {
		f.subs = make(map[chan struct{}]struct{})
	}
	if len(f.subs) == 0 {
		runCtx, cancel := context.WithCancel(context.Background())
		f.cancel = cancel
		changed := f.changed(runCtx)
		f.last = f.read()
		go f.run(runCtx, changed)
	}
	f.subs[ch] = struct{}{}
	f.mu.Unlock()

	go func() {
		<-ctx.Done()
		f.mu.Lock()
		defer f.mu.Unlock()
		delete(f.subs, ch)
		if len(f.subs) == 0 {
			f.cancel()
		}
	}()
	return ch
}

// latest returns the newest list. The caller must not change it.
func (f *binariesFeed) latest() ([]*pb.BinaryStatusMsg, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.last, nil
}

func (f *binariesFeed) run(ctx context.Context, changed <-chan struct{}) {
	ticker := time.NewTicker(f.recheck)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-changed:
		case <-ticker.C:
		}
		next := f.read()
		f.mu.Lock()
		if ctx.Err() != nil || sameBinaries(f.last, next) {
			f.mu.Unlock()
			continue
		}
		f.last = next
		for ch := range f.subs {
			select {
			case ch <- struct{}{}:
			default:
			}
		}
		f.mu.Unlock()
	}
}
