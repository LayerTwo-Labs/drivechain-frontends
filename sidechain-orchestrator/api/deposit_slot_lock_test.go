package api

import (
	"testing"
	"time"
)

// Two overlapping deposits to one slot would spend the same treasury output,
// so the lock lets exactly one call at a time through.
func TestLockDepositSlotSerializesOneSlot(t *testing.T) {
	h := &WalletHandler{}

	unlock := h.lockDepositSlot(3)
	second := make(chan struct{})
	go func() {
		defer close(second)
		h.lockDepositSlot(3)()
	}()

	select {
	case <-second:
		t.Fatal("a second deposit to the slot ran while the first held the lock")
	case <-time.After(50 * time.Millisecond):
	}

	unlock()
	select {
	case <-second:
	case <-time.After(2 * time.Second):
		t.Fatal("the unlock never let the second deposit through")
	}
}

// A different slot spends a different treasury output, so it must not wait.
func TestLockDepositSlotLetsAnotherSlotThrough(t *testing.T) {
	h := &WalletHandler{}

	unlock := h.lockDepositSlot(3)
	defer unlock()

	done := make(chan struct{})
	go func() {
		defer close(done)
		h.lockDepositSlot(4)()
	}()

	select {
	case <-done:
	case <-time.After(2 * time.Second):
		t.Fatal("slot 4 waited for the lock of slot 3")
	}
}
