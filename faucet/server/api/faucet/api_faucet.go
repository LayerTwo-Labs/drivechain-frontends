package api_faucet

import (
	"context"
	"fmt"
	"log"
	"math"
	"sync"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/faucet/server/gen/faucet/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/faucet/server/gen/faucet/v1/faucetv1connect"
	btcpb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/samber/lo"
)

var _ rpc.FaucetServiceHandler = new(Server)

// New creates a new Client
func New(
	bitcoind bitcoindv1alphaconnect.BitcoinServiceClient,
) *Server {
	s := &Server{
		bitcoind:       bitcoind,
		dispensed:      make(map[string]float64),
		totalDispensed: 0,
	}
	return s
}

type Server struct {
	bitcoind       bitcoindv1alphaconnect.BitcoinServiceClient
	mu             sync.Mutex
	dispensed      map[string]float64
	totalDispensed float64
}

const (
	MaxCoinsPer5Min    = 100_000
	MaxCoinsPerRequest = 5
)

func NewClient(ctx context.Context, bitcoind bitcoindv1alphaconnect.BitcoinServiceClient) *Server {
	faucet := &Server{
		bitcoind:       bitcoind,
		dispensed:      make(map[string]float64),
		totalDispensed: 0,
	}

	go faucet.resetHandler(ctx)

	return faucet
}

func (s *Server) resetHandler(ctx context.Context) {
	ticker := time.NewTicker(5 * time.Minute)
	defer ticker.Stop()

	connectionTicker := time.NewTicker(time.Minute)
	defer connectionTicker.Stop()

	for {
		select {
		case <-ticker.C:
			s.mu.Lock()
			s.totalDispensed = 0
			s.dispensed = make(map[string]float64)
			s.mu.Unlock()
			log.Println("faucet reset: cleared total dispensed coins, address list, and IP list.")
		case <-connectionTicker.C:
			info, err := s.bitcoind.GetBlockchainInfo(ctx, &connect.Request[btcpb.GetBlockchainInfoRequest]{})
			if err != nil {
				log.Println("could not ping sender: %w", err)
			} else {
				log.Println("client ping: still connected at height", info.Msg.Blocks)
			}
		}
	}
}

// DispenseCoins implements faucetv1connect.FaucetServiceHandler.
func (s *Server) DispenseCoins(ctx context.Context, c *connect.Request[pb.DispenseCoinsRequest]) (*connect.Response[pb.DispenseCoinsResponse], error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	amount, err := s.validateDispenseArgs(c.Msg)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	s.recordDispensation(c.Msg.Destination, amount.ToBTC())

	txid, err := s.bitcoind.SendToAddress(ctx, &connect.Request[btcpb.SendToAddressRequest]{
		Msg: &btcpb.SendToAddressRequest{
			Address: c.Msg.Destination,
			Amount:  amount.ToBTC(),
			Comment: "faucet-dispensation",
		},
	})
	if err != nil {
		s.undoDispensation(c.Msg.Destination, amount.ToBTC())
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("could not dispense coins: %w", err))
	}

	fmt.Printf("sent %.8f to %s in %s\n", amount.ToBTC(), c.Msg.Destination, txid.Msg.Txid)

	return connect.NewResponse(&pb.DispenseCoinsResponse{
		Txid: txid.Msg.Txid,
	}), nil
}

func (s *Server) recordDispensation(destination string, amount float64) {
	s.dispensed[destination] += amount
	s.totalDispensed += amount
}

func (s *Server) undoDispensation(destination string, amount float64) {
	s.dispensed[destination] -= amount
	s.totalDispensed -= amount
}

func (s *Server) validateDispenseArgs(req *pb.DispenseCoinsRequest) (btcutil.Amount, error) {

	if req.Amount > MaxCoinsPerRequest || req.Amount <= 0 {
		return 0, fmt.Errorf("amount must be less than or equal to %d, and greater than zero", MaxCoinsPerRequest)
	}

	amount, err := btcutil.NewAmount(req.Amount)
	if err != nil {
		return 0, fmt.Errorf("%.8f is not a valid bitcoin amount, expected format like 0.12345678", req.Amount)
	}

	if s.totalDispensed >= MaxCoinsPer5Min {
		return 0, fmt.Errorf("faucet limit reached, try again later")
	}

	return amount, nil
}

// ListClaims implements faucetv1connect.FaucetServiceHandler.
func (s *Server) ListClaims(ctx context.Context, req *connect.Request[pb.ListClaimsRequest]) (*connect.Response[pb.ListClaimsResponse], error) {
	txs, err := s.bitcoind.ListTransactions(ctx, &connect.Request[btcpb.ListTransactionsRequest]{
		Msg: &btcpb.ListTransactionsRequest{
			Count: 1000,
		},
	})
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("could not list transactions: %w", err))
	}

	transactions := lo.Filter(txs.Msg.Transactions, func(tx *btcpb.GetTransactionResponse, index int) bool {
		// we only want to show withdrawals going from our wallet
		return tx.Amount < 0 &&
			// and avoid txs with negative confirmations
			tx.Confirmations >= 0
	})

	transactions = lo.Map(transactions, func(tx *btcpb.GetTransactionResponse, index int) *btcpb.GetTransactionResponse {
		// for the user, the amounts makes most sense when positive
		tx.Amount = math.Abs(tx.Amount)
		tx.Fee = math.Abs(tx.Fee)
		return tx
	})

	return connect.NewResponse(&pb.ListClaimsResponse{
		Transactions: transactions,
	}), nil
}
