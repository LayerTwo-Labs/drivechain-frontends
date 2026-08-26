package orchestrator

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"time"
)

// ownerLockName is the file every install holds open while it runs.
const ownerLockName = "owner.lock"

// OwnerLock answers one question: may this install stop the binaries it finds
// running? It holds an exclusive lock for the process lifetime, so the kernel
// releases it the moment the holder dies — a crash included.
//
// A held lock means no other install is live, so every leftover binary is an
// orphan of a dead run and this install cleans it up. Asking a recorded PID
// instead cannot answer this: the OS reuses PIDs, so a stale number names a
// stranger as often as it names the process that wrote it.
type OwnerLock struct {
	file *os.File
}

// TakeOwnerLock claims the install. held is false when another live install
// already holds it, which is not an error.
func TakeOwnerLock(dataDir string) (lock *OwnerLock, held bool, err error) {
	dir := PidDir(dataDir)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return nil, false, fmt.Errorf("create pid dir %s: %w", dir, err)
	}
	path := filepath.Join(dir, ownerLockName)

	f, err := os.OpenFile(path, os.O_CREATE|os.O_RDWR, 0o644)
	if err != nil {
		return nil, false, fmt.Errorf("open owner lock %s: %w", path, err)
	}

	held, err = takeOwnerLock(f)
	if err != nil || !held {
		_ = f.Close()
		if err != nil {
			return nil, false, fmt.Errorf("lock %s: %w", path, err)
		}
		return nil, false, nil
	}
	return &OwnerLock{file: f}, true, nil
}

// ClaimOwnerLock takes the lock, and keeps retrying in the background until it
// does, because a start that races the previous session's exit finds it held
// for a moment. Nothing waits on this: an unowned install serves normally.
func (o *Orchestrator) ClaimOwnerLock(ctx context.Context, dataDir string) {
	lock, held, err := TakeOwnerLock(dataDir)
	if err != nil {
		o.log.Warn().Err(err).Msg("owner lock failed")
		return
	}
	if held {
		o.SetOwnerLock(lock)
		return
	}

	o.log.Info().Str("datadir", dataDir).
		Msg("the previous session still owns this data directory, waiting for it to let go")

	go func() {
		ticker := time.NewTicker(time.Second)
		defer ticker.Stop()
		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
			}
			lock, held, err := TakeOwnerLock(dataDir)
			if err != nil {
				o.log.Warn().Err(err).Msg("owner lock retry failed")
				return
			}
			if held {
				o.SetOwnerLock(lock)
				o.log.Info().Str("datadir", dataDir).Msg("the previous install let go, this one owns its binaries now")
				return
			}
		}
	}()
}

// Release drops the lock. The kernel does this on exit too, so a caller only
// needs it to hand the install over while it keeps running.
func (l *OwnerLock) Release() error {
	if l == nil || l.file == nil {
		return nil
	}
	f := l.file
	l.file = nil
	return f.Close()
}
