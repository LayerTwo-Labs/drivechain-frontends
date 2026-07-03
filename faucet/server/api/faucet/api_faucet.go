package api_faucet

import (
	"context"
	"errors"
	"fmt"
	"math"
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/faucet/server/gen/faucet/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/faucet/server/gen/faucet/v1/faucetv1connect"
	btcpb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/rs/zerolog"
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
	windowEnds     time.Time // when the current dispensation window resets
}

const (
	MaxCoinsPer5Min    = 100
	MaxCoinsPerRequest = 5
	ResetInterval      = 5 * time.Minute
)

// resetIfWindowElapsed clears the dispensation counters and starts a new
// window if the current one has passed. Callers must hold s.mu.
func (s *Server) resetIfWindowElapsed(now time.Time) {
	if now.Before(s.windowEnds) {
		return
	}
	s.dispensed = make(map[string]float64)
	s.totalDispensed = 0
	s.windowEnds = now.Add(ResetInterval)
}

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

	log := zerolog.Ctx(ctx)

	for {
		select {
		case now := <-ticker.C:
			s.mu.Lock()
			s.resetIfWindowElapsed(now)
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

	s.resetIfWindowElapsed(time.Now())

	amount, err := s.validateDispenseArgs(c.Msg)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if s.totalDispensed > MaxCoinsPer5Min {
		return nil, connect.NewError(connect.CodeResourceExhausted, fmt.Errorf(
			"the faucet has hit its dispensation limit, try again in %s",
			formatDuration(time.Until(s.windowEnds)),
		))
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
	}

	switch {
	case err != nil && strings.Contains(err.Error(), "Insufficient funds"):
		msg := "The faucet is out of funds. Please try again later."
		return nil, connect.NewError(connect.CodeResourceExhausted, errors.New(msg))

	case err != nil && isInvalidAddressError(err):
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("the destination is not a valid bitcoin address"))

	case err != nil:
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("dispense coins: %w", err))
	}

	fmt.Printf("sent %.8f to %s in %s\n", amount.ToBTC(), c.Msg.Destination, txid.Msg.Txid)

	return connect.NewResponse(&pb.DispenseCoinsResponse{
		Txid: txid.Msg.Txid,
	}), nil
}

// formatDuration renders d as a user-friendly string like
// "4 minutes and 30 seconds".
func formatDuration(d time.Duration) string {
	d = max(d.Round(time.Second), time.Second)

	minutes := int(d.Minutes())
	seconds := int(d.Seconds()) % 60

	plural := func(n int, unit string) string {
		if n == 1 {
			return fmt.Sprintf("%d %s", n, unit)
		}
		return fmt.Sprintf("%d %ss", n, unit)
	}

	switch {
	case minutes == 0:
		return plural(seconds, "second")
	case seconds == 0:
		return plural(minutes, "minute")
	default:
		return plural(minutes, "minute") + " and " + plural(seconds, "second")
	}
}

func (s *Server) recordDispensation(destination string, amount float64) {
	s.dispensed[destination] += amount
	s.totalDispensed += amount
}

func (s *Server) undoDispensation(destination string, amount float64) {
	s.dispensed[destination] -= amount
	s.totalDispensed -= amount
}

// isInvalidAddressError reports whether a SendToAddress error is Bitcoin Core
// (or btcutil) rejecting the destination address, as opposed to a genuine
// internal fault. Lets us return a clean InvalidArgument instead of a 500.
func isInvalidAddressError(err error) bool {
	msg := err.Error()
	return strings.Contains(msg, "Invalid Bitcoin address") ||
		strings.Contains(msg, "Invalid address") ||
		strings.Contains(msg, "invalid format")
}

func (s *Server) validateDispenseArgs(req *pb.DispenseCoinsRequest) (btcutil.Amount, error) {

	if req.Amount > MaxCoinsPerRequest || req.Amount <= 0 {
		return 0, fmt.Errorf("amount must be less than or equal to %d, and greater than zero", MaxCoinsPerRequest)
	}

	amount, err := btcutil.NewAmount(req.Amount)
	if err != nil {
		return 0, fmt.Errorf("%.8f is not a valid bitcoin amount, expected format like 0.12345678", req.Amount)
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
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("list transactions: %w", err))
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

// GetStatus implements faucetv1connect.FaucetServiceHandler. It reports the
// faucet's balance and whether it currently has enough funds to serve requests.
func (s *Server) GetStatus(ctx context.Context, req *connect.Request[pb.GetStatusRequest]) (*connect.Response[pb.GetStatusResponse], error) {

	const minHealthyBalance = 10

	balances, err := s.bitcoind.GetBalances(ctx, &connect.Request[btcpb.GetBalancesRequest]{})
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("get balances: %w", err))
	}

	mine := balances.Msg.GetMine()
	available := mine.GetTrusted()

	return connect.NewResponse(&pb.GetStatusResponse{
		Available: available,
		Pending:   mine.GetUntrustedPending() + mine.GetImmature(),
		Healthy:   available > minHealthyBalance,
	}), nil
}
