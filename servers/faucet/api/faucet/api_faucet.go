package api_faucet

import (
	"context"
	"fmt"
	"log"
	"math"
	"sync"
	"time"

	"connectrpc.com/connect"
	faucetv1 "github.com/LayerTwo-Labs/sidesail/servers/faucet/gen/faucet/v1"
	"github.com/LayerTwo-Labs/sidesail/servers/faucet/gen/faucet/v1/faucetv1connect"
	bitcoindv1alpha "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/samber/lo"
)

var _ faucetv1connect.FaucetServiceHandler = new(Server)

// New creates a new Client
func New(
	bitcoind *coreproxy.Bitcoind,
) *Server {
	s := &Server{
		bitcoind:       bitcoind,
		dispensed:      make(map[string]float64),
		totalDispensed: 0,
	}
	return s
}

type Server struct {
	bitcoind       *coreproxy.Bitcoind
	mu             sync.Mutex
	dispensed      map[string]float64
	totalDispensed float64
}

const (
	MaxCoinsPer5Min    = 100_000
	MaxCoinsPerRequest = 5
)

func NewClient(ctx context.Context, bitcoind *coreproxy.Bitcoind) *Server {
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
			info, err := s.bitcoind.GetBlockchainInfo(ctx, &connect.Request[bitcoindv1alpha.GetBlockchainInfoRequest]{})
			if err != nil {
				log.Println("could not ping sender: %w", err)
			} else {
				log.Println("client ping: still connected at height", info.Msg.Blocks)
			}
		}
	}
}

// DispenseCoins implements faucetv1connect.FaucetServiceHandler.
func (s *Server) DispenseCoins(ctx context.Context, c *connect.Request[faucetv1.DispenseCoinsRequest]) (*connect.Response[faucetv1.DispenseCoinsResponse], error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	amount, err := s.validateDispenseArgs(c.Msg)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	s.recordDispensation(c.Msg.Destination, amount.ToBTC())

	txid, err := s.bitcoind.SendToAddress(ctx, &connect.Request[bitcoindv1alpha.SendToAddressRequest]{
		Msg: &bitcoindv1alpha.SendToAddressRequest{
			Address: c.Msg.Destination,
			Amount:  amount.ToBTC(),
		},
	})
	if err != nil {
		s.undoDispensation(c.Msg.Destination, amount.ToBTC())
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("could not dispense coins: %w", err))
	}

	fmt.Printf("sent %.8f to %s in %s\n", amount.ToBTC(), c.Msg.Destination, txid.Msg.Txid)

	return connect.NewResponse(&faucetv1.DispenseCoinsResponse{
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

func (s *Server) validateDispenseArgs(req *faucetv1.DispenseCoinsRequest) (btcutil.Amount, error) {

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
func (s *Server) ListClaims(ctx context.Context, req *connect.Request[faucetv1.ListClaimsRequest]) (*connect.Response[faucetv1.ListClaimsResponse], error) {
	txs, err := s.bitcoind.ListTransactions(ctx, &connect.Request[bitcoindv1alpha.ListTransactionsRequest]{
		Msg: &bitcoindv1alpha.ListTransactionsRequest{
			Count: 1000,
		},
	})
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("could not list transactions: %w", err))
	}

	transactions := lo.Filter(txs.Msg.Transactions, func(tx *bitcoindv1alpha.GetTransactionResponse, index int) bool {
		// we only want to show withdrawals going from our wallet
		return tx.Amount < 0 &&
			// and avoid txs with negative confirmations
			tx.Confirmations >= 0
	})

	transactions = lo.Map(transactions, func(tx *bitcoindv1alpha.GetTransactionResponse, index int) *bitcoindv1alpha.GetTransactionResponse {
		// for the user, the amounts makes most sense when positive
		tx.Amount = math.Abs(tx.Amount)
		tx.Fee = math.Abs(tx.Fee)
		return tx
	})

	return connect.NewResponse(&faucetv1.ListClaimsResponse{
		Transactions: transactions,
	}), nil
}
