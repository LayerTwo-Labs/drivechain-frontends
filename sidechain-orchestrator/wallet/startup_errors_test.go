package wallet

import (
	"errors"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestIsTransientWalletErr(t *testing.T) {
	cases := []struct {
		err  error
		want bool
		name string
	}{
		{nil, false, "nil"},
		{errors.New("loadwallet RPC error -4: Wallet already loading."), true, "wallet-already-loading"},
		{errors.New("loadwallet RPC error -28: Verifying blocks…"), true, "verifying-blocks"},
		{errors.New("rescan in progress: Still rescanning. At block 470818"), true, "still-rescanning"},
		{errors.New("loadwallet RPC error -1: not allowed"), false, "non-transient-error"},
		{errors.New("connection refused"), false, "connection-refused-not-classified"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			assert.Equal(t, tc.want, IsTransientWalletErr(tc.err))
		})
	}
}

// Core lists a wallet before it finishes loading it, so a wallet RPC in that
// window answers -18 for a wallet that is on its way up. Reading that as
// permanent leaves the caller on a wallet it never retries.
func TestWalletNotLoadedIsTransient(t *testing.T) {
	for _, msg := range []string{
		"importdescriptors RPC error -18: Requested wallet does not exist or is not loaded",
		"getbalance RPC error -18: Requested wallet does not exist or is not loaded",
		"listtransactions RPC error -1: Requested wallet does not exist or is not loaded",
	} {
		if !IsTransientWalletErr(errors.New(msg)) {
			t.Errorf("this reads as permanent, and the wallet is still on its way up: %s", msg)
		}
	}
}

// A wallet error that names a real fault stays permanent, so a caller fails
// rather than waits for a wallet that never arrives.
func TestARealWalletFaultStaysPermanent(t *testing.T) {
	for _, msg := range []string{
		"createwallet RPC error -4: Wallet file verification failed",
		"importdescriptors RPC error -5: Invalid descriptor",
	} {
		if IsTransientWalletErr(errors.New(msg)) {
			t.Errorf("this reads as transient, and it never clears: %s", msg)
		}
	}
}

// "Not loaded" and "busy" are different. A rescan is transient, and the wallet
// is still loaded, so the caller keeps using it.
func TestOnlyAnAbsentWalletReadsAsNotLoaded(t *testing.T) {
	notLoaded := "importdescriptors RPC error -18: Requested wallet does not exist or is not loaded"
	if !isWalletNotLoadedErr(errors.New(notLoaded)) {
		t.Error("Core says it does not hold the wallet, and this reads otherwise")
	}
	for _, msg := range []string{
		"importdescriptors RPC error -4: Wallet is currently rescanning. Abort existing rescan or wait.",
		"createwallet RPC error -4: Wallet already loading",
		"getbalance RPC error -28: Loading block index",
	} {
		if isWalletNotLoadedErr(errors.New(msg)) {
			t.Errorf("the wallet is loaded and busy, and this reads as absent: %s", msg)
		}
		if !isTransientWalletErr(errors.New(msg)) {
			t.Errorf("this clears on its own, and it reads as permanent: %s", msg)
		}
	}
}
