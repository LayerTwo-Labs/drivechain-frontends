package api_faucet

import (
	"context"
	"testing"

	connectv1 "connectrpc.com/connect"
	"connectrpc.com/connect/v2"
	pb "github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/hub/v1"
	btcpb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
)

type fakeBitcoind struct {
	bitcoindv1alphaconnect.BitcoinServiceClient
	sent []float64
}

func (f *fakeBitcoind) SendToAddress(_ context.Context, req *connectv1.Request[btcpb.SendToAddressRequest]) (*connectv1.Response[btcpb.SendToAddressResponse], error) {
	f.sent = append(f.sent, req.Msg.Amount)
	return connectv1.NewResponse(&btcpb.SendToAddressResponse{Txid: "txid"}), nil
}

func dispense(s *Server, amount float64) error {
	_, err := s.DispenseCoins(context.Background(), &pb.DispenseCoinsRequest{
		Destination: "bc1qdestination",
		Amount:      amount,
	})
	return err
}

func TestDispenseCoins_WindowLimit(t *testing.T) {
	bitcoind := &fakeBitcoind{}
	s := New(bitcoind)

	for range 19 {
		if err := dispense(s, MaxCoinsPerRequest); err != nil {
			t.Fatalf("dispense below the limit: %v", err)
		}
	}
	if err := dispense(s, 3); err != nil {
		t.Fatalf("dispense up to 98: %v", err)
	}

	err := dispense(s, 3)
	if connect.CodeOf(err) != connect.CodeResourceExhausted {
		t.Fatalf("dispense past the limit: got %v, want ResourceExhausted", err)
	}

	if err := dispense(s, 2); err != nil {
		t.Fatalf("dispense up to the limit: %v", err)
	}
	if s.totalDispensed != MaxCoinsPer5Min {
		t.Fatalf("total dispensed: got %v, want %d", s.totalDispensed, MaxCoinsPer5Min)
	}
	if len(bitcoind.sent) != 21 {
		t.Fatalf("sent transactions: got %d, want 21", len(bitcoind.sent))
	}
}
