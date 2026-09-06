package api_faucet

import (
	"context"
	"testing"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/hub/v1"
	btcpb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
)

// stubBitcoind accepts every send, and counts them.
type stubBitcoind struct {
	bitcoindv1alphaconnect.BitcoinServiceClient
	sends int
}

func (s *stubBitcoind) SendToAddress(ctx context.Context, req *connect.Request[btcpb.SendToAddressRequest]) (*connect.Response[btcpb.SendToAddressResponse], error) {
	s.sends++
	return connect.NewResponse(&btcpb.SendToAddressResponse{Txid: "txid"}), nil
}

func dispense(s *Server, destination string, amount float64) error {
	_, err := s.DispenseCoins(context.Background(), connect.NewRequest(&pb.DispenseCoinsRequest{
		Destination: destination,
		Amount:      amount,
	}))
	return err
}

func TestDispenseCoinsPerAddressLimit(t *testing.T) {
	bitcoind := new(stubBitcoind)
	faucet := New(bitcoind)

	const addr = "bcrt1qexhausted"

	// The per-address cap allows this many max-size requests.
	for i := 0; i < MaxCoinsPerAddressPer5Min/MaxCoinsPerRequest; i++ {
		if err := dispense(faucet, addr, MaxCoinsPerRequest); err != nil {
			t.Fatalf("request %d: %v", i, err)
		}
	}

	err := dispense(faucet, addr, MaxCoinsPerRequest)
	if got := connect.CodeOf(err); got != connect.CodeResourceExhausted {
		t.Fatalf("expected resource exhausted, got %v (%v)", got, err)
	}

	// The address is capped long before the faucet-wide limit.
	if faucet.totalDispensed != MaxCoinsPerAddressPer5Min {
		t.Fatalf("dispensed %f, want %d", faucet.totalDispensed, MaxCoinsPerAddressPer5Min)
	}

	// Another address is unaffected within the same window.
	if err := dispense(faucet, "bcrt1qfresh", MaxCoinsPerRequest); err != nil {
		t.Fatalf("unrelated address: %v", err)
	}

	if bitcoind.sends != 3 {
		t.Fatalf("sent %d times, want 3", bitcoind.sends)
	}
}

func TestDispenseCoinsGlobalLimit(t *testing.T) {
	faucet := New(new(stubBitcoind))

	// Open a window, then place the faucet just under the global cap.
	faucet.resetIfWindowElapsed(time.Now())
	faucet.totalDispensed = MaxCoinsPer5Min - MaxCoinsPerRequest + 1

	// The pending amount must not be allowed to exceed the cap.
	err := dispense(faucet, "bcrt1qglobal", MaxCoinsPerRequest)
	if got := connect.CodeOf(err); got != connect.CodeResourceExhausted {
		t.Fatalf("expected resource exhausted, got %v (%v)", got, err)
	}
}
