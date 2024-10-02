package api_wallet

import (
	"context"
	"errors"
	"fmt"
	"sort"
	"sync/atomic"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/drivechain-server/bdk"
	"github.com/LayerTwo-Labs/sidesail/drivechain-server/drivechain"
	drivechainrpc "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/drivechain/v1/drivechainv1connect"
	validatorpb "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/validator/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/validator/v1/validatorv1connect"
	pb "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/wallet/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/wallet/v1/walletv1connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

var _ rpc.WalletServiceHandler = new(Server)

// New creates a new Server and starts the balance update loop
func New(
	ctx context.Context, wallet *bdk.Wallet, bitcoind *coreproxy.Bitcoind,
	enforcer validatorrpc.ValidatorServiceClient, drivechain drivechainrpc.DrivechainServiceClient,

) *Server {
	s := &Server{
		wallet: wallet, bitcoind: bitcoind, enforcer: enforcer,
		drivechain: drivechain,
	}
	go s.startBalanceUpdateLoop(ctx)
	return s
}

type Server struct {
	wallet     *bdk.Wallet
	bitcoind   *coreproxy.Bitcoind
	enforcer   validatorrpc.ValidatorServiceClient
	drivechain drivechainrpc.DrivechainServiceClient

	balance atomic.Value
}

func (s *Server) startBalanceUpdateLoop(ctx context.Context) {
	ticker := time.NewTicker(time.Second * 5)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if err := s.updateBalance(ctx); err != nil {
				zerolog.Ctx(ctx).Err(err).Msg("failed to update balance")
			}
		}
	}
}

func (s *Server) updateBalance(ctx context.Context) error {
	if err := s.wallet.Sync(ctx); err != nil {
		return fmt.Errorf("unable to sync: %w", err)
	}

	balance, err := s.wallet.GetBalance(ctx)
	if err != nil {
		return fmt.Errorf("unable to get balance: %w", err)
	}

	prevBalance, ok := s.balance.Load().(bdk.Balance)
	if ok && (balance.Confirmed == prevBalance.Confirmed &&
		balance.Immature == prevBalance.Immature &&
		balance.TrustedPending == prevBalance.TrustedPending &&
		balance.UntrustedPending == prevBalance.UntrustedPending) {
		return nil
	}

	zerolog.Ctx(ctx).Info().
		Msgf("balance changed: %+v -> %+v", prevBalance, balance)

	s.balance.Store(*balance)
	return nil
}

// SendTransaction implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) SendTransaction(ctx context.Context, c *connect.Request[pb.SendTransactionRequest]) (*connect.Response[pb.SendTransactionResponse], error) {
	if len(c.Msg.Destinations) == 0 {
		err := errors.New("must provide at least one destination")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if c.Msg.FeeRate < 0 {
		err := errors.New("fee rate cannot be negative")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	log := zerolog.Ctx(ctx)

	if c.Msg.FeeRate == 0 {
		log.Debug().Msgf("send tx: received no fee rate, querying bitcoin core")

		estimate, err := s.bitcoind.EstimateSmartFee(ctx, connect.NewRequest(&corepb.EstimateSmartFeeRequest{
			ConfTarget:   2,
			EstimateMode: corepb.EstimateSmartFeeRequest_ESTIMATE_MODE_ECONOMICAL,
		}))
		if err != nil {
			return nil, err
		}

		c.Msg.FeeRate = estimate.Msg.FeeRate
		log.Info().Msgf("send tx: determined fee rate: %f", c.Msg.FeeRate)
	}

	destinations := make(map[string]btcutil.Amount)
	for address, amount := range c.Msg.Destinations {
		const dustLimit = 546
		if amount < dustLimit {
			err := fmt.Errorf(
				"amount to %s is below dust limit (%s): %s",
				address, btcutil.Amount(dustLimit), btcutil.Amount(amount),
			)
			return nil, connect.NewError(connect.CodeInvalidArgument, err)
		}
		destinations[address] = btcutil.Amount(amount)
	}

	btcPerByte, err := btcutil.NewAmount(c.Msg.FeeRate / 1000)
	if err != nil {
		return nil, err
	}
	satoshiPerVByte := btcPerByte.ToUnit(btcutil.AmountSatoshi)

	created, err := s.wallet.CreateTransaction(ctx, destinations, satoshiPerVByte, c.Msg.Rbf)
	if err != nil {
		return nil, err
	}

	log.Info().Msg("send tx: created transaction")

	signed, err := s.wallet.SignTransaction(ctx, created)
	if err != nil {
		return nil, err
	}

	log.Info().Msg("send tx: signed transaction")

	txid, err := s.wallet.BroadcastTransaction(ctx, signed)
	if err != nil {
		return nil, fmt.Errorf("broadcast transaction: %w", err)
	}

	log.Info().Msgf("send tx: broadcast transaction: %s", txid)

	return connect.NewResponse(&pb.SendTransactionResponse{
		Txid: txid,
	}), nil

}

// GetNewAddress implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) GetNewAddress(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.GetNewAddressResponse], error) {
	address, index, err := s.wallet.GetNewAddress(ctx)
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&pb.GetNewAddressResponse{
		Address: address.EncodeAddress(),
		Index:   uint32(index),
	}), nil
}

// GetBalance implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) GetBalance(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.GetBalanceResponse], error) {
	balanceValue := s.balance.Load()
	if balanceValue == nil {
		// If balance hasn't been fetched yet, do it now
		if err := s.updateBalance(ctx); err != nil {
			return nil, err
		}
		balanceValue = s.balance.Load()
	}

	balance, ok := balanceValue.(bdk.Balance)
	if !ok && balance != (bdk.Balance{}) {
		// If the balance is still nil or not of the expected type, return an error
		return nil, connect.NewError(connect.CodeInternal, errors.New("balance not available"))
	}

	return connect.NewResponse(&pb.GetBalanceResponse{
		ConfirmedSatoshi: uint64(balance.Confirmed),
		PendingSatoshi:   uint64(balance.Immature) + uint64(balance.TrustedPending) + uint64(balance.UntrustedPending),
	}), nil
}

// ListTransactions implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListTransactions(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.ListTransactionsResponse], error) {
	txs, err := s.wallet.ListTransactions(ctx)
	if err != nil {
		return nil, err
	}

	res := &pb.ListTransactionsResponse{
		Transactions: lo.Map(txs, func(tx bdk.Transaction, idx int) *pb.Transaction {
			var confirmation *pb.Confirmation
			if tx.ConfirmationTime != nil {
				confirmation = &pb.Confirmation{
					Height:    uint32(tx.ConfirmationTime.Height),
					Timestamp: &timestamppb.Timestamp{Seconds: int64(tx.ConfirmationTime.Timestamp)},
				}
			}
			return &pb.Transaction{
				Txid:             tx.TXID,
				FeeSatoshi:       uint64(tx.Fee),
				ReceivedSatoshi:  uint64(tx.Received),
				SentSatoshi:      uint64(tx.Sent),
				ConfirmationTime: confirmation,
			}
		}),
	}

	return connect.NewResponse(res), nil
}

// ListSidechainDeposits implements walletv1connect.WalletServiceHandler.
func (s *Server) ListSidechainDeposits(ctx context.Context, c *connect.Request[pb.ListSidechainDepositsRequest]) (*connect.Response[pb.ListSidechainDepositsResponse], error) {

	// TODO: Call ListSidechainDeposits with the CUSF-wallet here
	type Deposit struct {
		Txhex   string
		Strdest string
	}
	deposits := []Deposit{}

	transactions, err := s.bitcoind.ListTransactions(ctx, &connect.Request[corepb.ListTransactionsRequest]{
		Msg: &corepb.ListTransactionsRequest{},
	})
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to list transactions: %w", err))
	}

	var response pb.ListSidechainDepositsResponse
	for _, tx := range transactions.Msg.Transactions {
		if tx.Amount != 0 {
			continue
		}

		rawTxResponse, err := s.bitcoind.GetRawTransaction(ctx, &connect.Request[corepb.GetRawTransactionRequest]{
			Msg: &corepb.GetRawTransactionRequest{
				Txid: tx.Txid,
			},
		})
		if err != nil {
			return nil, fmt.Errorf("failed to get raw transaction: %w", err)
		}

		for _, deposit := range deposits {
			if deposit.Txhex == rawTxResponse.Msg.Tx.Hex {
				response.Deposits = append(response.Deposits, &pb.ListSidechainDepositsResponse_SidechainDeposit{
					Txid:          tx.Txid,
					Address:       deposit.Strdest,
					Amount:        tx.Amount,
					Fee:           tx.Fee,
					Confirmations: tx.Confirmations,
				})
				break
			}
		}
	}

	return connect.NewResponse(&response), nil
}

// CreateSidechainDeposit implements walletv1connect.WalletServiceHandler.
func (s *Server) CreateSidechainDeposit(ctx context.Context, c *connect.Request[pb.CreateSidechainDepositRequest]) (*connect.Response[pb.CreateSidechainDepositResponse], error) {
	// TODO: this is an external address. Would be nice to be possible to
	// fetch an internal address
	changeAddress, _, err := s.wallet.GetNewAddress(ctx)
	if err != nil {
		return nil, err
	}

	slot, depositAddress, _, err := drivechain.DecodeDepositAddress(c.Msg.Destination)
	if err != nil {
		err := fmt.Errorf("invalid deposit address: %w", err)
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	amount, err := btcutil.NewAmount(c.Msg.Amount)
	if err != nil || amount <= 0 {
		err := errors.New("invalid amount, must be a BTC-amount greater than zero")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	fee, err := btcutil.NewAmount(c.Msg.Fee)
	if err != nil || fee < 0 {
		err := fmt.Errorf("invalid fee, must be a BTC-amount greater than zero")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	tx := wire.NewMsgTx(wire.TxVersion)

	sidechainScript, err := drivechain.ScriptSidechainDeposit(uint8(slot))
	if err != nil {
		return nil, fmt.Errorf("create sidechain deposit script: %w", err)
	}

	zerolog.Ctx(ctx).Debug().
		Msgf("create sidechain deposit: created sidechain script: %s", string(sidechainScript))

	// First fund the tx using UTXO's from our own wallet
	if err := s.fundTx(ctx, tx, amount, fee, changeAddress); err != nil {
		return nil, err
	}

	zerolog.Ctx(ctx).Debug().
		Msgf("create sidechain deposit: funded TX")

	chainTip, err := s.getSidechainTip(ctx, slot)
	if err != nil {
		return nil, err
	}

	// Add extra drivechain-inputs (previous sidechain ctip)
	if err := s.addDepositInputs(tx, chainTip); err != nil {
		return nil, err
	}

	// Add extra drivechain-outputs (new sidechain UTXO, address data script)
	if err := s.addDepositOutputs(
		ctx, tx, sidechainScript, amount, depositAddress,
		chainTip,
	); err != nil {
		return nil, err
	}

	zerolog.Ctx(ctx).Debug().
		Msg("create sidechain deposit: added deposit outputs")

	unsignedPSBT, err := psbt.NewFromUnsignedTx(tx)
	if err != nil {
		return nil, fmt.Errorf("create psbt: %w", err)
	}

	base64PSBT, err := unsignedPSBT.B64Encode()
	if err != nil {
		return nil, fmt.Errorf("encode psbt: %w", err)
	}

	zerolog.Ctx(ctx).Debug().
		Any("psbt.ins", unsignedPSBT.Inputs).
		Any("psbt.outs", unsignedPSBT.Outputs).
		Str("psbt.raw", base64PSBT).
		Msg("create sidechain deposit: signing PSBT")

	signedPSBT, err := s.wallet.SignTransaction(ctx, base64PSBT)
	if err != nil {
		return nil, fmt.Errorf("sign psbt: %w", err)
	}

	txid, err := s.wallet.BroadcastTransaction(ctx, signedPSBT)
	if err != nil {
		return nil, fmt.Errorf("broadcast tx: %w", err)
	}

	return connect.NewResponse(&pb.CreateSidechainDepositResponse{
		Txid: txid,
	}), nil
}

// https://github.com/LayerTwo-Labs/bip300301_wallet/blob/f2177c32f7854980e43df242f0634a01be3618bf/src/wallet.rs#L749-L768
func (s *Server) addDepositInputs(
	tx *wire.MsgTx, sidechain *validatorpb.Ctip,
) error {
	if string(sidechain.Txid) == "" {
		// There are currently no active sidechains, so we can't add this
		// input yet.
		return nil
	}

	hash, err := chainhash.NewHash(sidechain.Txid)
	if err != nil {
		return fmt.Errorf("invalid chaintip txid: %w", err)
	}

	// All of a sidechains bitcoin is stored in a single UTXO. Always.
	// We therefore have to add the previous sidechains CTIP as an input.
	tx.AddTxIn(wire.NewTxIn(&wire.OutPoint{
		Hash:  *hash,
		Index: sidechain.Vout,
	}, nil, nil))

	return nil
}

func (s *Server) addDepositOutputs(
	ctx context.Context, tx *wire.MsgTx, sidechainScript []byte, amount btcutil.Amount,
	sidechainDepositAddress string, sidechainTip *validatorpb.Ctip,
) error {

	// Indicate what address we're depositing to (on the sidechain)
	depositAddrScript, err := drivechain.ScriptDepositAddress(sidechainDepositAddress)
	if err != nil {
		return fmt.Errorf("create deposit address script: %w", err)
	}

	// This UTXO does not need an amount. It only exists to indicate which address
	// should receive money on the sidechain.
	// https://github.com/LayerTwo-Labs/bip300301_wallet/blob/f2177c32f7854980e43df242f0634a01be3618bf/src/wallet.rs#L747C28-L747C45
	tx.AddTxOut(&wire.TxOut{
		Value:    int64(0),
		PkScript: depositAddrScript,
	})

	zerolog.Ctx(ctx).Debug().
		Hex("script", depositAddrScript).
		Msgf("add deposit outputs: added deposit address script")

	// Each sidechain stores all its BTC in one UTXO, and will be valid as long as
	// the new CTIP has more coins in it, than before. We ensure that is the case
	// by adding the current chaintip amount to the amount we're depositing.
	//
	// https://github.com/LayerTwo-Labs/bip300301_wallet/blob/f2177c32f7854980e43df242f0634a01be3618bf/src/wallet.rs#L746
	newSidechainBalance := btcutil.Amount(sidechainTip.Value) + amount
	tx.AddTxOut(&wire.TxOut{
		PkScript: sidechainScript,
		Value:    int64(newSidechainBalance),
	})

	zerolog.Ctx(ctx).Debug().
		Hex("script", sidechainScript).
		Msgf("add deposit outputs: added sidechain UTXO")

	return nil
}

// fundTx attempts to fund a transaction sending amt bitcoin. The coins are
// selected such that the final amount spent pays enough fees as dictated by the
// passed fee. If there's any change left over, it's added as a change output.
// Cribbed from btcd, with minor modifictaions:
// https://github.com/btcsuite/btcd/blob/67b8efd3ba53b60ff0eba5d79babe2c3d82f6c54/integration/rpctest/memwallet.go#L384
func (s *Server) fundTx(
	ctx context.Context, tx *wire.MsgTx, amt btcutil.Amount, fee btcutil.Amount,
	changeAddress btcutil.Address,
) error {

	unspents, err := s.wallet.ListUnspent(ctx)
	if err != nil {
		return fmt.Errorf("list unspent transactions: %w", err)
	}

	// Sort in ascending order to select small UTXOs
	sort.Slice(unspents, func(i, j int) bool {
		return unspents[i].Amount < unspents[j].Amount
	})

	var (
		amtSelected btcutil.Amount
	)

	for _, utxo := range unspents {
		amtSelected += btcutil.Amount(utxo.Amount)

		zerolog.Ctx(ctx).Debug().
			Msgf("fund tx: adding input: %s", utxo.Outpoint)

		// Add the selected output to the transaction
		tx.AddTxIn(wire.NewTxIn(&wire.OutPoint{
			Hash:  utxo.Outpoint.Hash,
			Index: utxo.Outpoint.Index,
		}, nil, nil))

		// Calculate the fee required for the txn at this point
		// observing the specified fee. If we don't have enough coins
		// coins from he current amount selected to pay the fee, then
		// continue to grab more coins.
		if amtSelected-fee < amt {
			continue
		}

		// If we have any change left over and we should create a change
		// output, then add an additional output to the transaction
		// reserved for it.
		changeVal := amtSelected - amt - fee
		if changeVal > 0 {

			pkScript, err := txscript.PayToAddrScript(changeAddress)
			if err != nil {
				return err
			}

			zerolog.Ctx(ctx).Debug().
				Hex("script", pkScript).
				Msgf("fund tx: adding change output to %s", changeAddress)

			tx.AddTxOut(&wire.TxOut{
				Value:    int64(changeVal),
				PkScript: pkScript,
			})
		}

		return nil
	}

	// If we've reached this point, then coin selection failed due to an
	// insufficient amount of coins.
	return fmt.Errorf("not enough funds for coin selection")
}

func (s *Server) getSidechainTip(ctx context.Context, slot uint32) (*validatorpb.Ctip, error) {
	// No sidechains are activated currently, so there's no ctips either.
	return &validatorpb.Ctip{
		Txid:  nil,
		Vout:  0,
		Value: 0,
	}, nil

	/*
		chainTip, err := s.enforcer.GetCtip(ctx, connect.NewRequest(&validatorpb.GetCtipRequest{
			SidechainNumber: wrapperspb.UInt32(slot),
		}))
		if err != nil {
			return nil, err
		}

		return chainTip.Msg.Ctip, nil
	*/
}
