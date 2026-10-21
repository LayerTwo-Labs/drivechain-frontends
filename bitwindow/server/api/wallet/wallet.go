package wallet

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"math"
	"sort"
	"strconv"
	"strings"
	"time"

	"buf.build/go/protovalidate"
	connectv1 "connectrpc.com/connect"
	"connectrpc.com/connect/v2"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"

	drivechain "github.com/LayerTwo-Labs/sidesail/bitwindow/server/drivechain"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	bitwindowdv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/addressbook"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/preferences"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/transactions"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/utxometadata"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/signmessage"
	validatorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchwallet "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

var _ rpc.WalletServiceHandler = new(Server)

func New(
	database *sql.DB,
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
	enforcer *service.Service[validatorrpc.ValidatorServiceClient],
	chequeEngine *engines.ChequeEngine,
	chequeChain engines.ChequeChain,
	walletEngine *engines.WalletEngine,
	walletDir string,
	restartL1 func(context.Context) error,
) *Server {
	return &Server{
		database:     database,
		chequeChain:  chequeChain,
		bitcoind:     bitcoind,
		enforcer:     enforcer,
		chequeEngine: chequeEngine,
		walletEngine: walletEngine,
		backupEngine: engines.NewBackupEngine(database, walletDir),
		restartL1:    restartL1,
	}
}

type Server struct {
	database     *sql.DB
	bitcoind     *service.Service[corerpc.BitcoinServiceClient]
	enforcer     *service.Service[validatorrpc.ValidatorServiceClient]
	chequeEngine *engines.ChequeEngine
	chequeChain  engines.ChequeChain
	walletEngine *engines.WalletEngine
	backupEngine *engines.BackupEngine
	// restartL1 reboots the L1 stack (bitcoind + enforcer) via drivechaind.
	// Called after a backup restore.
	restartL1 func(context.Context) error
}

// SendTransaction implements walletv1connect.WalletServiceHandler.
func (s *Server) SendTransaction(ctx context.Context, c *pb.SendTransactionRequest) (*pb.SendTransactionResponse, error) {
	walletID := c.WalletId

	if err := protovalidate.Validate(c); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	const dustLimit = 546
	for destination, amount := range c.Destinations {
		if amount < dustLimit {
			err := fmt.Errorf(
				"amount to %s is below dust limit (%s): %s",
				destination, btcutil.Amount(dustLimit), btcutil.Amount(amount),
			)
			return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
		}
	}

	requiredInputs := make([]*orchpb.UnspentOutput, 0, len(c.RequiredInputs))
	for _, input := range c.RequiredInputs {
		txid, voutText, found := strings.Cut(input.Output, ":")
		if !found {
			return nil, connect.Errorf(connect.CodeInvalidArgument, "invalid UTXO format: %s", input.Output)
		}
		vout, err := strconv.ParseUint(voutText, 10, 31)
		if err != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Sprintf("invalid vout in UTXO %s: %s", input.Output, err)).WithCause(err)
		}
		requiredInputs = append(requiredInputs, &orchpb.UnspentOutput{
			Txid:       txid,
			Vout:       int32(vout),
			AmountSats: int64(input.ValueSats),
		})
	}

	// Coin selection belongs to drivechaind, which locks the frozen coins for
	// the length of a send. A second selector here would spend them.
	txid, err := s.walletEngine.SendTransaction(ctx, &orchpb.SendTransactionRequest{
		WalletId: walletID,
		Destinations: lo.MapValues(c.Destinations, func(sats uint64, _ string) int64 {
			return int64(sats)
		}),
		FeeRateSatPerVbyte: int64(c.FeeSatPerVbyte),
		FixedFeeSats:       int64(c.FixedFeeSats),
		RequiredInputs:     requiredInputs,
	})
	if errors.Is(err, engines.ErrFrozenInput) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	if err != nil {
		return nil, err
	}

	zerolog.Ctx(ctx).Info().Msgf("send tx: broadcast transaction: %s", txid)

	return &pb.SendTransactionResponse{
		Txid: txid,
	}, nil
}

// keepConnectCode returns err as it is when it holds a connect error, so the
// client gets that code. Any other error gets CodeInternal.
func keepConnectCode(err error) error {
	if connectErr := new(connect.Error); errors.As(err, &connectErr) {
		return err
	}
	return connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
}

func btcToSats(btc float64) (uint64, error) {
	amount, err := btcutil.NewAmount(btc)
	if err != nil {
		return 0, fmt.Errorf("convert %v BTC to sats: %w", btc, err)
	}
	if amount < 0 {
		return 0, fmt.Errorf("negative amount: %v BTC", btc)
	}
	return uint64(amount), nil
}

func sumBTCToSats(a, b float64) (uint64, error) {
	aSats, err := btcToSats(a)
	if err != nil {
		return 0, err
	}
	bSats, err := btcToSats(b)
	if err != nil {
		return 0, err
	}
	return aSats + bSats, nil
}

// GetNewAddress implements walletv1connect.WalletServiceHandler.
func (s *Server) GetNewAddress(ctx context.Context, c *pb.GetNewAddressRequest) (*pb.GetNewAddressResponse, error) {
	walletID := c.WalletId
	var addressType orchpb.AddressType
	switch c.AddressType {
	case pb.AddressType_ADDRESS_TYPE_UNSPECIFIED:
		addressType = orchpb.AddressType_ADDRESS_TYPE_UNSPECIFIED
	case pb.AddressType_ADDRESS_TYPE_SEGWIT:
		addressType = orchpb.AddressType_ADDRESS_TYPE_SEGWIT
	case pb.AddressType_ADDRESS_TYPE_TAPROOT:
		addressType = orchpb.AddressType_ADDRESS_TYPE_TAPROOT
	}
	address, err := s.walletEngine.GetNewAddress(ctx, walletID, addressType)
	if err != nil {
		return nil, err
	}

	err = addressbook.Create(ctx, s.database, &walletID, "", address, addressbook.DirectionReceive)
	if err != nil && !errors.Is(err, addressbook.ErrDuplicateAddress) {
		return nil, fmt.Errorf("save address %s to addressbook: %w", address, err)
	}

	return &pb.GetNewAddressResponse{
		Address: address,
		Index:   0,
	}, nil
}

// syncCoreAddresses adds the receive addresses of each Bitcoin Core wallet to
// the addressbook.
func (s *Server) syncCoreAddresses(ctx context.Context) error {
	wallets, err := s.walletEngine.GetAllWallets(ctx)
	if err != nil {
		return fmt.Errorf("get wallets: %w", err)
	}

	for _, wallet := range wallets {
		if wallet.WalletType != engines.WalletTypeBitcoinCore {
			continue
		}

		addresses, err := s.walletEngine.DeriveReceiveAddresses(ctx, wallet.ID, addressScanDepth)
		if err != nil {
			zerolog.Ctx(ctx).Warn().Err(err).
				Str("wallet_id", wallet.ID).
				Str("wallet_name", wallet.Name).
				Msg("derive addresses for sync")
			continue
		}

		for _, address := range addresses {
			err := addressbook.Create(ctx, s.database, &wallet.ID, "", address, addressbook.DirectionReceive)
			if err != nil && !errors.Is(err, addressbook.ErrDuplicateAddress) {
				return fmt.Errorf("save address %s of wallet %s: %w", address, wallet.ID, err)
			}
		}
	}

	return nil
}

// Run saves the receive addresses of each Core wallet to the address book every 5 minutes, until ctx ends.
func (s *Server) Run(ctx context.Context) error {
	ticker := time.NewTicker(5 * time.Minute)
	defer ticker.Stop()

	if err := s.syncCoreAddresses(ctx); err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("initial address sync")
	}

	for {
		select {
		case <-ctx.Done():
			return nil
		case <-ticker.C:
			if err := s.syncCoreAddresses(ctx); err != nil {
				zerolog.Ctx(ctx).Warn().Err(err).Msg("periodic address sync")
			}
		}
	}
}

// GetBalance implements walletv1connect.WalletServiceHandler.
func (s *Server) GetBalance(ctx context.Context, c *pb.GetBalanceRequest) (*pb.GetBalanceResponse, error) {
	walletID := c.WalletId
	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletID)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	switch walletType {
	case engines.WalletTypeBitcoinCore:
		coreWalletName, err := s.walletEngine.CoreWalletName(ctx, walletID)
		if err != nil {
			return nil, fmt.Errorf("ensure core wallet: %w", err)
		}

		bitcoindClient, err := s.bitcoind.Get(ctx)
		if err != nil {
			return nil, fmt.Errorf("get bitcoind client: %w", err)
		}

		balancesResp, err := bitcoindClient.GetBalances(ctx, connectv1.NewRequest(&corepb.GetBalancesRequest{
			Wallet: coreWalletName,
		}))
		if err != nil {
			return nil, fmt.Errorf("get balances from bitcoin core: %w", err)
		}

		// A descriptor wallet reports watch-only coins under mine, a legacy wallet under watchonly.
		mine, watchOnly := balancesResp.Msg.GetMine(), balancesResp.Msg.GetWatchonly()
		confirmedSats, err := sumBTCToSats(mine.GetTrusted(), watchOnly.GetTrusted())
		if err != nil {
			return nil, fmt.Errorf("confirmed balance: %w", err)
		}
		pendingSats, err := sumBTCToSats(mine.GetUntrustedPending(), watchOnly.GetUntrustedPending())
		if err != nil {
			return nil, fmt.Errorf("pending balance: %w", err)
		}
		immatureSats, err := sumBTCToSats(mine.GetImmature(), watchOnly.GetImmature())
		if err != nil {
			return nil, fmt.Errorf("immature balance: %w", err)
		}

		return &pb.GetBalanceResponse{
			ConfirmedSatoshi: confirmedSats,
			PendingSatoshi:   pendingSats,
			ImmatureSatoshi:  immatureSats,
		}, nil

	case engines.WalletTypeElectrum:
		confirmedSats, pendingSats, immatureSats, err := s.walletEngine.GetElectrumBalance(ctx, walletID)
		if err != nil {
			return nil, err
		}
		return &pb.GetBalanceResponse{
			ConfirmedSatoshi: confirmedSats,
			PendingSatoshi:   pendingSats,
			ImmatureSatoshi:  immatureSats,
		}, nil

	default:
		return nil, fmt.Errorf("unknown wallet type: %s", walletType)
	}
}

// ListTransactions implements walletv1connect.WalletServiceHandler.
func (s *Server) ListTransactions(ctx context.Context, c *pb.ListTransactionsRequest) (*pb.ListTransactionsResponse, error) {
	walletID := c.WalletId
	txs, err := s.listTransactions(ctx, walletID)
	if err != nil {
		return nil, err
	}

	labels, err := addressbook.LabelsByAddress(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("list addressbook: %w", err)
	}
	notes, err := transactions.ListByWallet(ctx, s.database, walletID)
	if err != nil {
		return nil, fmt.Errorf("list notes: %w", err)
	}
	noteMap := make(map[string]string, len(notes))
	for _, n := range notes {
		noteMap[n.TxID] = n.Note
	}

	for _, tx := range txs {
		if tx.AddressLabel == "" {
			tx.AddressLabel = labels[tx.Address]
		}
		tx.Note = noteMap[tx.Txid]
	}
	return &pb.ListTransactionsResponse{Transactions: txs}, nil
}

func (s *Server) listTransactions(ctx context.Context, walletID string) ([]*pb.WalletTransaction, error) {
	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletID)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	if walletType == engines.WalletTypeElectrum {
		entries, err := s.walletEngine.GetElectrumTransactions(ctx, walletID)
		if err != nil {
			return nil, err
		}

		tip := s.enforcerTipHeight(ctx, lo.SomeBy(entries, func(t *orchpb.TransactionEntry) bool { return t.Confirmations > 0 }))

		rows := make([]txRow, 0, len(entries))
		for _, t := range entries {
			feeSats, err := btcToSats(math.Abs(t.Fee))
			if err != nil {
				return nil, fmt.Errorf("electrum: fee of %s: %w", t.Txid, err)
			}
			row := txRow{
				txid:       t.Txid,
				amountSats: t.AmountSats,
				feeSats:    feeSats,
				address:    t.Address,
				label:      t.Label,
				immature:   t.Category == "immature",
			}
			if t.Confirmations > 0 {
				row.confirmation = &pb.Confirmation{
					Height:    engines.ConfirmedHeight(tip, t.Confirmations),
					Timestamp: &timestamppb.Timestamp{Seconds: t.BlockTime},
				}
			}
			rows = append(rows, row)
		}
		return mergeTxRows(rows), nil
	}

	coreWalletName, err := s.walletEngine.CoreWalletName(ctx, walletID)
	if err != nil {
		return nil, fmt.Errorf("get Bitcoin Core wallet: %w", err)
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("bitcoind: %w", err)
	}

	var coreTxs []*corepb.GetTransactionResponse
	for skip := uint32(0); ; skip += coreTxPageSize {
		page, err := bitcoind.ListTransactions(ctx, connectv1.NewRequest(&corepb.ListTransactionsRequest{
			Wallet: coreWalletName,
			Count:  coreTxPageSize,
			Skip:   skip,
		}))
		if err != nil {
			return nil, fmt.Errorf("bitcoin core list transactions: %w", err)
		}
		coreTxs = append(coreTxs, page.Msg.Transactions...)
		if len(page.Msg.Transactions) < coreTxPageSize {
			break
		}
	}

	tip := coreTipHeight(ctx, bitcoind, lo.SomeBy(coreTxs, func(tx *corepb.GetTransactionResponse) bool { return tx.Confirmations > 0 }))

	rows := make([]txRow, 0, len(coreTxs))
	for _, tx := range coreTxs {
		amount, err := btcutil.NewAmount(tx.Amount)
		if err != nil {
			return nil, fmt.Errorf("amount of %s: %w", tx.Txid, err)
		}
		var feeSats uint64
		if tx.Fee < 0 {
			feeSats, err = btcToSats(-tx.Fee)
			if err != nil {
				return nil, fmt.Errorf("fee of %s: %w", tx.Txid, err)
			}
		}
		row := txRow{
			txid:       tx.Txid,
			amountSats: int64(amount),
			feeSats:    feeSats,
			immature: lo.ContainsBy(tx.Details, func(d *corepb.GetTransactionResponse_Details) bool {
				return d.Category == corepb.GetTransactionResponse_CATEGORY_IMMATURE
			}),
		}
		if len(tx.Details) > 0 {
			row.address = tx.Details[0].Address
		}
		if tx.Confirmations > 0 {
			// BlockTime is always nil for ListTransactions in btc-buf, use Time or TimeReceived instead
			timestamp := tx.Time
			if timestamp == nil {
				timestamp = tx.TimeReceived
			}
			if timestamp != nil {
				row.confirmation = &pb.Confirmation{
					Height:    engines.ConfirmedHeight(tip, tx.Confirmations),
					Timestamp: timestamp,
				}
			}
		}
		rows = append(rows, row)
	}
	return mergeTxRows(rows), nil
}

const coreTxPageSize = 1000

// txRow is one listtransactions entry. A transaction with more than one
// output or input gives more than one row.
type txRow struct {
	txid         string
	amountSats   int64
	feeSats      uint64
	address      string
	label        string
	confirmation *pb.Confirmation
	immature     bool
}

// mergeTxRows gives one transaction per txid, in the order of the first row.
// The first row sets the address, label and confirmation.
func mergeTxRows(rows []txRow) []*pb.WalletTransaction {
	byTxid := make(map[string]*pb.WalletTransaction, len(rows))
	out := make([]*pb.WalletTransaction, 0, len(rows))
	for _, r := range rows {
		tx, ok := byTxid[r.txid]
		if !ok {
			tx = &pb.WalletTransaction{
				Txid:             r.txid,
				Address:          r.address,
				AddressLabel:     r.label,
				ConfirmationTime: r.confirmation,
			}
			byTxid[r.txid] = tx
			out = append(out, tx)
		}
		if r.amountSats >= 0 {
			tx.ReceivedSatoshi += uint64(r.amountSats)
		} else {
			tx.SentSatoshi += uint64(-r.amountSats)
		}
		// Core repeats the fee on each send row; Electrum puts it on one row.
		tx.FeeSats = max(tx.FeeSats, r.feeSats)
		tx.Immature = tx.Immature || r.immature
	}
	return out
}

// A failed tip read gives no block heights; the transaction list must not depend on it.
func coreTipHeight(ctx context.Context, bitcoind corerpc.BitcoinServiceClient, anyConfirmed bool) int32 {
	if !anyConfirmed {
		return 0
	}
	info, err := bitcoind.GetBlockchainInfo(ctx, connectv1.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("list transactions: no block heights, get blockchain info")
		return 0
	}
	return int32(info.Msg.Blocks)
}

// A down enforcer gives no block heights; the transaction list must not depend on it.
func (s *Server) enforcerTipHeight(ctx context.Context, anyConfirmed bool) int32 {
	if !anyConfirmed {
		return 0
	}
	enforcer, err := s.enforcer.Get(ctx)
	if err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("list transactions: no block heights, enforcer is down")
		return 0
	}
	resp, err := enforcer.GetChainTip(ctx, &validatorpb.GetChainTipRequest{})
	if err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("list transactions: no block heights, get chain tip")
		return 0
	}
	return int32(resp.BlockHeaderInfo.GetHeight())
}

// ListSidechainDeposits implements walletv1connect.WalletServiceHandler.
//
// Only this install's own deposits are knowable. An M5 is an ordinary
// transaction on the wire, so nothing on chain marks one after the fact.
func (s *Server) ListSidechainDeposits(ctx context.Context, c *pb.ListSidechainDepositsRequest) (*pb.ListSidechainDepositsResponse, error) {
	if c.Slot < 0 || c.Slot > 255 {
		return nil, connect.NewError(connect.CodeInvalidArgument, "slot must be 0-255")
	}
	deposits, err := s.walletEngine.ListSidechainDeposits(ctx, uint32(c.Slot), c.WalletId)
	if err != nil {
		return nil, fmt.Errorf("list sidechain deposits: %w", err)
	}
	return &pb.ListSidechainDepositsResponse{
		Deposits: lo.Map(deposits, func(d *orchpb.SidechainDeposit, _ int) *pb.ListSidechainDepositsResponse_SidechainDeposit {
			return &pb.ListSidechainDepositsResponse_SidechainDeposit{
				Txid:          d.Txid,
				Amount:        d.AmountSats,
				Fee:           d.FeeSats,
				Confirmations: d.Confirmations,
				Dropped:       d.DroppedAt != "",
			}
		}),
	}, nil
}

// CreateSidechainDeposit implements walletv1connect.WalletServiceHandler.
func (s *Server) CreateSidechainDeposit(ctx context.Context, c *pb.CreateSidechainDepositRequest) (*pb.CreateSidechainDepositResponse, error) {
	walletID := c.WalletId
	if _, err := s.walletEngine.GetWalletBackendType(ctx, walletID); err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	slot, depositAddress, _, err := drivechain.DecodeDepositAddress(c.Destination)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Sprintf("invalid deposit address: %s", err)).WithCause(err)
	}
	if slot != nil && c.Slot != 0 && *slot != c.Slot {
		return nil, connect.Errorf(connect.CodeInvalidArgument,
			"the deposit address is for slot %d, this deposit is for slot %d", *slot, c.Slot)
	}
	if slot == nil && c.Slot == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			"address is not a sidechain deposit address, expected slot or format: s<slot>_<address> or s9_<address>_<checksum>")
	} else if slot == nil {
		slot = &c.Slot
	}
	if *slot < 0 || *slot > 255 {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "invalid sidechain slot %d: must be 0-255", *slot)
	}

	amount, err := btcutil.NewAmount(c.Amount)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Sprintf("parse amount: %s", err)).WithCause(err)
	}
	if amount <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, "invalid amount, must be a BTC-amount greater than zero")
	}

	fee, err := btcutil.NewAmount(c.Fee)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Sprintf("parse fee: %s", err)).WithCause(err)
	}
	if fee <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, "invalid fee, must be a BTC-amount greater than zero")
	}

	txid, err := s.walletEngine.CreateDeposit(ctx, &orchpb.CreateDepositRequest{
		Slot:        int32(*slot),
		WalletId:    walletID,
		Destination: depositAddress,
		AmountSats:  int64(amount),
		FeeSats:     int64(fee),
	})
	if err != nil {
		return nil, fmt.Errorf("broadcast sidechain deposit: %w", err)
	}

	zerolog.Ctx(ctx).Info().Str("txid", txid).Int64("slot", *slot).Msg("create sidechain deposit")

	return &pb.CreateSidechainDepositResponse{Txid: txid}, nil
}

// addressScanDepth bounds how far along a receive chain a signable address can
// sit, and how many receive addresses the addressbook sync adds.
const addressScanDepth = 100

// deriveMessageSigningPrivateKey returns the key behind address, so the
// signature proves ownership of that address rather than some other one.
func deriveMessageSigningPrivateKey(seedHex string, wallet *engines.WalletInfo, chainParams *chaincfg.Params, address string) (*btcec.PrivateKey, error) {
	return orchwallet.SigningKey(&orchwallet.WalletData{
		Master:         orchwallet.MasterWallet{SeedHex: seedHex},
		ScriptType:     wallet.ScriptType,
		AccountIndex:   wallet.AccountIndex,
		DerivationPath: wallet.DerivationPath,
	}, chainParams, address, addressScanDepth)
}

// SignMessage implements walletv1connect.WalletServiceHandler.
func (s *Server) SignMessage(ctx context.Context, c *pb.SignMessageRequest) (*pb.SignMessageResponse, error) {
	if err := s.requireUnlocked(ctx); err != nil {
		return nil, err
	}

	if _, err := s.walletEngine.GetWalletBackendType(ctx, c.WalletId); err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	if c.Address == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "address is required")
	}

	chainParams := s.walletEngine.GetChainParams()
	address, err := btcutil.DecodeAddress(c.Address, chainParams)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Sprintf("decode address: %s", err)).WithCause(err)
	}

	walletInfo, err := s.walletEngine.GetWalletInfo(ctx, c.WalletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet info: %w", err)
	}

	seedHex, err := s.walletEngine.GetWalletSeed(ctx, walletInfo.ID)
	if err != nil {
		return nil, err
	}

	privKey, err := deriveMessageSigningPrivateKey(seedHex, walletInfo, chainParams, c.Address)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Sprintf("derive signing key: %s", err)).WithCause(err)
	}

	signature, err := signmessage.Sign(privKey, address, c.Message, chainParams)
	if err != nil {
		return nil, fmt.Errorf("sign message: %w", err)
	}

	return &pb.SignMessageResponse{Signature: signature}, nil
}

// VerifyMessage implements walletv1connect.WalletServiceHandler.
func (s *Server) VerifyMessage(ctx context.Context, c *pb.VerifyMessageRequest) (*pb.VerifyMessageResponse, error) {
	valid, err := signmessage.Verify(c.PublicKey, c.Message, c.Signature, s.walletEngine.GetChainParams())
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	return &pb.VerifyMessageResponse{Valid: valid}, nil
}

// ListUnspent implements walletv1connect.WalletServiceHandler.
func (s *Server) ListUnspent(ctx context.Context, c *pb.ListUnspentRequest) (*pb.ListUnspentResponse, error) {
	labels, err := addressbook.LabelsByAddress(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("list addressbook: %w", err)
	}

	utxos, err := s.listUnspent(ctx, c.WalletId, labels)
	if err != nil {
		return nil, err
	}

	return &pb.ListUnspentResponse{Utxos: utxos}, nil
}

func (s *Server) listUnspent(ctx context.Context, walletID string, labels map[string]string) ([]*pb.UnspentOutput, error) {
	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletID)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	switch walletType {
	case engines.WalletTypeElectrum:
		return s.listUnspentElectrum(ctx, walletID, labels)
	case engines.WalletTypeBitcoinCore:
		return s.listUnspentBitcoinCore(ctx, walletID, labels)
	default:
		return nil, fmt.Errorf("unknown wallet type: %s", walletType)
	}
}

func (s *Server) listUnspentElectrum(ctx context.Context, walletID string, labels map[string]string) ([]*pb.UnspentOutput, error) {
	raw, err := s.walletEngine.GetElectrumUnspent(ctx, walletID)
	if err != nil {
		return nil, err
	}
	utxos := make([]*pb.UnspentOutput, 0, len(raw))
	for _, u := range raw {
		utxos = append(utxos, &pb.UnspentOutput{
			Output:    fmt.Sprintf("%s:%d", u.Txid, u.Vout),
			Address:   u.Address,
			Label:     labels[u.Address],
			ValueSats: uint64(u.AmountSats),
		})
	}
	return utxos, nil
}

func (s *Server) listUnspentBitcoinCore(ctx context.Context, walletID string, labels map[string]string) ([]*pb.UnspentOutput, error) {
	coreWalletName, err := s.walletEngine.CoreWalletName(ctx, walletID)
	if err != nil {
		return nil, fmt.Errorf("get Bitcoin Core wallet: %w", err)
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	resp, err := bitcoind.ListUnspent(ctx, connectv1.NewRequest(&corepb.ListUnspentRequest{
		Wallet: coreWalletName,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoin Core list unspent: %w", err)
	}

	denials, err := deniability.List(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("bitcoin core: list denials: %w", err)
	}

	var utxosWithInfo []*pb.UnspentOutput
	for _, utxo := range resp.Msg.Unspent {
		valueSats, err := btcToSats(utxo.Amount)
		if err != nil {
			return nil, fmt.Errorf("value of %s:%d: %w", utxo.Txid, utxo.Vout, err)
		}

		utxosWithInfo = append(utxosWithInfo, &pb.UnspentOutput{
			Output:     fmt.Sprintf("%s:%d", utxo.Txid, utxo.Vout),
			Address:    utxo.Address,
			Label:      labels[utxo.Address],
			ValueSats:  valueSats,
			IsChange:   false,
			DenialInfo: s.addDenialInfoForCore(utxo.Txid, int32(utxo.Vout), denials),
		})
	}

	return utxosWithInfo, nil
}

func (s *Server) addDenialInfoForCore(txid string, vout int32, denials []deniability.Denial) *bitwindowdv1.DenialInfo {
	sort.Slice(denials, func(i, j int) bool {
		return denials[i].UpdatedAt.Before(denials[j].UpdatedAt)
	})

	denialInfo, found := lo.Find(denials, func(d deniability.Denial) bool {
		return d.TipTXID == txid && d.TipVout == vout
	})
	if !found {
		denialInfo, found = lo.Find(denials, func(d deniability.Denial) bool {
			return lo.ContainsBy(d.ExecutedDenials, func(e deniability.ExecutedDenial) bool {
				return e.ToTxID == txid
			})
		})
	}

	if !found {
		return nil
	}

	return s.denialToProtoCore(txid, vout, denialInfo)
}

func (s *Server) denialToProtoCore(txid string, vout int32, d deniability.Denial) *bitwindowdv1.DenialInfo {
	var cancelTime *timestamppb.Timestamp
	if d.CancelledAt != nil {
		cancelTime = timestamppb.New(*d.CancelledAt)
	}

	var pausedAt *timestamppb.Timestamp
	if d.PausedAt != nil {
		pausedAt = timestamppb.New(*d.PausedAt)
	}

	var nextExecutionTime *timestamppb.Timestamp
	isTip := d.TipTXID == txid && d.TipVout == vout
	if d.NextExecution != nil && isTip {
		nextExecutionTime = timestamppb.New(*d.NextExecution)
	}

	sort.Slice(d.ExecutedDenials, func(i, j int) bool {
		return d.ExecutedDenials[i].CreatedAt.Before(d.ExecutedDenials[j].CreatedAt)
	})
	uniqueBeforeThisUTXO := lo.UniqBy(d.ExecutedDenials, func(e deniability.ExecutedDenial) string {
		return e.ToTxID
	})

	executionIndex := -1
	for i, e := range uniqueBeforeThisUTXO {
		if e.ToTxID == txid {
			executionIndex = i
			break
		}
	}

	isChange := executionIndex != -1 && !isTip
	hopsCompleted := uint32(executionIndex) + 1

	return &bitwindowdv1.DenialInfo{
		Id:                d.ID,
		NumHops:           lo.If(isTip, d.NumHops).Else(int32(hopsCompleted)),
		DelaySeconds:      int32(d.DelayDuration.Seconds()),
		CreateTime:        timestamppb.New(d.CreatedAt),
		CancelTime:        cancelTime,
		CancelReason:      d.CancelReason,
		PausedAt:          pausedAt,
		NextExecutionTime: nextExecutionTime,
		Executions: lo.Map(d.ExecutedDenials, func(e deniability.ExecutedDenial, _ int) *bitwindowdv1.ExecutedDenial {
			return &bitwindowdv1.ExecutedDenial{
				Id:         e.ID,
				DenialId:   e.DenialID,
				FromTxid:   e.FromTxID,
				FromVout:   uint32(e.FromVout),
				ToTxid:     e.ToTxID,
				CreateTime: timestamppb.New(e.CreatedAt),
			}
		}),
		HopsCompleted: uint32(executionIndex) + 1,
		IsChange:      isChange,
	}
}

// ListReceiveAddresses implements walletv1connect.WalletServiceHandler.
func (s *Server) ListReceiveAddresses(ctx context.Context, c *pb.ListReceiveAddressesRequest) (*pb.ListReceiveAddressesResponse, error) {
	labels, err := addressbook.LabelsByAddress(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("list addressbook: %w", err)
	}

	utxos, err := s.listUnspent(ctx, c.WalletId, labels)
	if err != nil {
		return nil, err
	}

	addressMap := make(map[string]*pb.ReceiveAddress)
	for _, utxo := range utxos {
		if utxo.Address == "" {
			continue
		}
		if existing, found := addressMap[utxo.Address]; found {
			existing.CurrentBalanceSat += utxo.ValueSats
		} else {
			addressMap[utxo.Address] = &pb.ReceiveAddress{
				Address:           utxo.Address,
				Label:             utxo.Label,
				CurrentBalanceSat: utxo.ValueSats,
			}
		}
	}

	var addresses []*pb.ReceiveAddress
	for _, addr := range addressMap {
		addresses = append(addresses, addr)
	}

	return &pb.ListReceiveAddressesResponse{
		Addresses: addresses,
	}, nil
}

// GetStats implements walletv1connect.WalletServiceHandler.
func (s *Server) GetStats(ctx context.Context, c *pb.GetStatsRequest) (*pb.GetStatsResponse, error) {
	walletID := c.WalletId

	utxos, err := s.listUnspent(ctx, walletID, nil)
	if err != nil {
		return nil, err
	}
	utxoCount := uint64(len(utxos))

	addressSet := make(map[string]struct{})
	for _, utxo := range utxos {
		addressSet[utxo.Address] = struct{}{}
	}
	uniqueAddressCount := uint64(len(addressSet))

	txs, err := s.listTransactions(ctx, walletID)
	if err != nil {
		return nil, err
	}
	transactionCount := int64(len(txs))

	// Count transactions since the start of the current month, sum
	// lifetime fees paid, and find the most recent confirmed tx.
	now := time.Now()
	currentYear, currentMonth, _ := now.Date()
	currentMonthStart := time.Date(currentYear, currentMonth, 1, 0, 0, 0, 0, now.Location())
	transactionCountSinceMonth := int64(0)
	var totalFees int64
	var lastTxAt *timestamppb.Timestamp
	var lastTxBlockHeight uint32
	for _, tx := range txs {
		totalFees += int64(tx.FeeSats)
		if tx.ConfirmationTime != nil && tx.ConfirmationTime.Timestamp != nil {
			t := tx.ConfirmationTime.Timestamp.AsTime()
			if t.After(currentMonthStart) || t.Equal(currentMonthStart) {
				transactionCountSinceMonth++
			}
			if lastTxAt == nil || t.After(lastTxAt.AsTime()) {
				lastTxAt = tx.ConfirmationTime.Timestamp
				lastTxBlockHeight = tx.ConfirmationTime.Height
			}
		}
	}

	// Only our own record knows this: an M5 looks like any other send on chain.
	depositVolume, depositVolume30d, err := s.walletEngine.SidechainDepositTotals(ctx, now.AddDate(0, 0, -30), walletID)
	if err != nil {
		return nil, fmt.Errorf("sum sidechain deposits: %w", err)
	}

	return &pb.GetStatsResponse{
		UtxosCurrent:                      utxoCount,
		UtxosUniqueAddresses:              uniqueAddressCount,
		SidechainDepositVolume:            depositVolume,
		SidechainDepositVolumeLast_30Days: depositVolume30d,
		TransactionCountTotal:             transactionCount,
		TransactionCountSinceMonth:        transactionCountSinceMonth,
		TotalFeesSats:                     totalFees,
		LastTxAt:                          lastTxAt,
		LastTxBlockHeight:                 lastTxBlockHeight,
	}, nil
}

// UnlockWallet implements walletv1connect.WalletServiceHandler.
func (s *Server) UnlockWallet(ctx context.Context, c *pb.UnlockWalletRequest) (*emptypb.Empty, error) {
	if err := s.walletEngine.Unlock(ctx, c.Password); err != nil {
		return nil, err
	}

	go func() {
		syncCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), 30*time.Second)
		defer cancel()

		if err := s.walletEngine.SyncWallets(syncCtx); err != nil {
			zerolog.Ctx(syncCtx).Warn().Err(err).Msg("wallet sync failed after unlock")
		}
	}()

	zerolog.Ctx(ctx).Info().Msg("unlock wallet")
	return &emptypb.Empty{}, nil
}

// LockWallet implements walletv1connect.WalletServiceHandler.
func (s *Server) LockWallet(ctx context.Context, c *emptypb.Empty) (*emptypb.Empty, error) {
	// Only a password unlocks a wallet again, so a wallet with no password cannot lock.
	encrypted, err := s.walletEngine.IsEncrypted(ctx)
	if err != nil {
		return nil, err
	}
	if !encrypted {
		return nil, connect.NewError(connect.CodeFailedPrecondition, "wallet is not encrypted")
	}
	if err := s.walletEngine.Lock(ctx); err != nil {
		return nil, err
	}
	zerolog.Ctx(ctx).Info().Msg("wallet locked")
	return &emptypb.Empty{}, nil
}

// IsWalletUnlocked implements walletv1connect.WalletServiceHandler.
func (s *Server) IsWalletUnlocked(ctx context.Context, c *emptypb.Empty) (*emptypb.Empty, error) {
	if err := s.requireUnlocked(ctx); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}

func (s *Server) requireUnlocked(ctx context.Context) error {
	unlocked, err := s.walletEngine.IsUnlocked(ctx)
	if err != nil {
		return err
	}
	if !unlocked {
		return connect.NewError(connect.CodeFailedPrecondition, "wallet is locked")
	}
	return nil
}

// CreateCheque implements walletv1connect.WalletServiceHandler.
func (s *Server) CreateCheque(ctx context.Context, c *pb.CreateChequeRequest) (*pb.CreateChequeResponse, error) {
	log := zerolog.Ctx(ctx)

	walletID := c.WalletId
	if walletID == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "wallet_id is required")
	}

	if err := s.requireUnlocked(ctx); err != nil {
		return nil, err
	}

	_, err := s.walletEngine.GetWalletBackendType(ctx, walletID)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	nextIndex, err := cheques.GetNextIndex(ctx, s.database, walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("get next index: %s", err)).WithCause(err)
	}

	address, err := s.chequeEngine.DeriveChequeAddress(ctx, walletID, nextIndex)
	if err != nil {
		return nil, keepConnectCode(fmt.Errorf("derive address %d: %w", nextIndex, err))
	}

	id, err := cheques.Create(ctx, s.database, walletID, nextIndex, c.ExpectedAmountSats, address)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("create cheque: %s", err)).WithCause(err)
	}

	log.Info().
		Int64("id", id).
		Uint32("index", nextIndex).
		Str("address", address).
		Uint64("expected_sats", c.ExpectedAmountSats).
		Msg("cheque created")

	return &pb.CreateChequeResponse{
		Id:              id,
		Address:         address,
		DerivationIndex: nextIndex,
	}, nil
}

// GetCheque implements walletv1connect.WalletServiceHandler.
func (s *Server) GetCheque(ctx context.Context, c *pb.GetChequeRequest) (*pb.GetChequeResponse, error) {
	walletID := c.WalletId

	cheque, err := s.getCheque(ctx, walletID, c.Id)
	if err != nil {
		return nil, err
	}

	unlocked, err := s.walletEngine.IsUnlocked(ctx)
	if err != nil {
		return nil, err
	}
	pbCheque, err := s.chequeToPb(ctx, cheque, unlocked)
	if err != nil {
		return nil, keepConnectCode(err)
	}

	return &pb.GetChequeResponse{
		Cheque: pbCheque,
	}, nil
}

// GetChequePrivateKey implements walletv1connect.WalletServiceHandler.
func (s *Server) GetChequePrivateKey(ctx context.Context, c *pb.GetChequePrivateKeyRequest) (*pb.GetChequePrivateKeyResponse, error) {
	walletID := c.WalletId

	if err := s.requireUnlocked(ctx); err != nil {
		return nil, err
	}

	cheque, err := s.getCheque(ctx, walletID, c.Id)
	if err != nil {
		return nil, err
	}

	privateKeyWIF, err := s.chequeEngine.DeriveChequePrivateKey(ctx, walletID, cheque.DerivationIndex)
	if err != nil {
		return nil, keepConnectCode(fmt.Errorf("derive private key %d: %w", cheque.DerivationIndex, err))
	}

	return &pb.GetChequePrivateKeyResponse{
		PrivateKeyWif: privateKeyWIF,
	}, nil
}

// ListCheques implements walletv1connect.WalletServiceHandler.
func (s *Server) ListCheques(ctx context.Context, c *pb.ListChequesRequest) (*pb.ListChequesResponse, error) {
	walletID := c.WalletId

	_, err := s.walletEngine.GetWalletBackendType(ctx, walletID)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	chequeList, err := cheques.List(ctx, s.database, walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("list cheques: %s", err)).WithCause(err)
	}

	unlocked, err := s.walletEngine.IsUnlocked(ctx)
	if err != nil {
		return nil, err
	}
	pbCheques := make([]*pb.Cheque, len(chequeList))
	for i, ch := range chequeList {
		pbCheques[i], err = s.chequeToPb(ctx, &ch, unlocked)
		if err != nil {
			return nil, keepConnectCode(err)
		}
	}

	return &pb.ListChequesResponse{
		Cheques: pbCheques,
	}, nil
}

// CheckChequeFunding implements walletv1connect.WalletServiceHandler.
func (s *Server) CheckChequeFunding(ctx context.Context, c *pb.CheckChequeFundingRequest) (*pb.CheckChequeFundingResponse, error) {
	cheque, err := s.getCheque(ctx, c.WalletId, c.Id)
	if err != nil {
		return nil, err
	}

	funding, err := s.chequeEngine.CheckFunding(ctx, cheque)
	if err != nil {
		return nil, err
	}

	resp := &pb.CheckChequeFundingResponse{
		Funded:           funding.Funded,
		ActualAmountSats: funding.AmountSats,
		FundedTxids:      funding.Txids,
		MinConfirmations: funding.MinConfirmations,
	}
	if funding.FundedAt != nil {
		resp.FundedAt = timestamppb.New(*funding.FundedAt)
	}
	return resp, nil
}

// PreviewSweep implements walletv1connect.WalletServiceHandler.
// Reports what a private key holds and what sweeping it would cost.
func (s *Server) PreviewSweep(ctx context.Context, c *pb.PreviewSweepRequest) (*pb.PreviewSweepResponse, error) {
	wifKey, err := decodeSweepWIF(c.PrivateKeyWif, s.chequeEngine.GetChainParams())
	if err != nil {
		return nil, err
	}

	source, err := engines.ResolveSweepSource(ctx, s.chequeChain, wifKey, s.chequeEngine.GetChainParams())
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Sprintf("query UTXOs: %s", err)).WithCause(err)
	}

	feeSatPerVbyte, err := s.chequeEngine.SweepFeeRate(ctx, c.FeeSatPerVbyte)
	if err != nil {
		return nil, err
	}

	amountSats := source.TotalSats()
	feeSats := engines.SweepFeeSats(source, feeSatPerVbyte, engines.OutputVbytes)

	var receiveSats uint64
	if amountSats > feeSats {
		receiveSats = amountSats - feeSats
	}

	return &pb.PreviewSweepResponse{
		Address:        source.Address,
		AddressKind:    sweepAddressKindToPb(source.Kind),
		AmountSats:     amountSats,
		OutputCount:    uint32(len(source.UTXOs)),
		FeeSatPerVbyte: feeSatPerVbyte,
		FeeSats:        feeSats,
		ReceiveSats:    receiveSats,
	}, nil
}

func decodeSweepWIF(text string, params *chaincfg.Params) (*btcutil.WIF, error) {
	wifKey, err := btcutil.DecodeWIF(text)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Sprintf("invalid WIF: %s", err)).WithCause(err)
	}
	if !wifKey.IsForNet(params) {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "WIF is not for network %s", params.Name)
	}
	return wifKey, nil
}

func sweepAddressKindToPb(kind engines.SweepAddressKind) pb.SweepAddressKind {
	switch kind {
	case engines.SweepAddressP2WPKH:
		return pb.SweepAddressKind_SWEEP_ADDRESS_KIND_P2WPKH
	case engines.SweepAddressP2PKH:
		return pb.SweepAddressKind_SWEEP_ADDRESS_KIND_P2PKH
	case engines.SweepAddressUnknown:
		return pb.SweepAddressKind_SWEEP_ADDRESS_KIND_UNSPECIFIED
	default:
		return pb.SweepAddressKind_SWEEP_ADDRESS_KIND_UNSPECIFIED
	}
}

// SweepCheque implements walletv1connect.WalletServiceHandler.
// Sweeps a cheque using its WIF private key to the destination address.
func (s *Server) SweepCheque(ctx context.Context, c *pb.SweepChequeRequest) (*pb.SweepChequeResponse, error) {
	wifKey, err := decodeSweepWIF(c.PrivateKeyWif, s.chequeEngine.GetChainParams())
	if err != nil {
		return nil, err
	}

	sweep, err := s.chequeEngine.Sweep(ctx, c.WalletId, wifKey, c.DestinationAddress, c.FeeSatPerVbyte)
	if err != nil {
		return nil, err
	}

	return &pb.SweepChequeResponse{
		Txid:           sweep.Txid,
		AmountSats:     sweep.AmountSats,
		FeeSatPerVbyte: sweep.FeeSatPerVbyte,
	}, nil
}

// DeleteCheque implements walletv1connect.WalletServiceHandler.
func (s *Server) DeleteCheque(ctx context.Context, c *pb.DeleteChequeRequest) (*emptypb.Empty, error) {
	log := zerolog.Ctx(ctx)

	walletID := c.WalletId

	cheque, err := s.getCheque(ctx, walletID, c.Id)
	if err != nil {
		return nil, err
	}

	// Any recorded incoming funds (full or partial) but not swept = still has money, can't delete
	if (cheque.IsFunded() || cheque.IsPartiallyFunded()) && cheque.SweptTxid == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, "cannot delete funded cheque")
	}

	err = cheques.Delete(ctx, s.database, walletID, c.Id)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("delete cheque: %s", err)).WithCause(err)
	}

	log.Info().
		Int64("id", c.Id).
		Str("address", cheque.Address).
		Msg("cheque deleted")

	return &emptypb.Empty{}, nil
}

func (s *Server) getCheque(ctx context.Context, walletID string, id int64) (*cheques.Cheque, error) {
	if _, err := s.walletEngine.GetWalletBackendType(ctx, walletID); err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	cheque, err := cheques.Get(ctx, s.database, walletID, id)
	switch {
	case errors.Is(err, sql.ErrNoRows):
		return nil, connect.NewError(connect.CodeNotFound, "cheque not found")
	case err != nil:
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("get cheque: %s", err)).WithCause(err)
	}
	return cheque, nil
}

func (s *Server) chequeToPb(ctx context.Context, c *cheques.Cheque, unlocked bool) (*pb.Cheque, error) {
	pbCheque := &pb.Cheque{
		Id:                 c.ID,
		DerivationIndex:    c.DerivationIndex,
		Address:            c.Address,
		ExpectedAmountSats: c.ExpectedAmountSats,
		Funded:             c.IsFunded(),
		FundedTxids:        c.FundedTxids,
		CreatedAt:          timestamppb.New(c.CreatedAt),
	}

	if c.ActualAmountSats != nil {
		pbCheque.ActualAmountSats = c.ActualAmountSats
	}
	if c.FundedAt != nil {
		pbCheque.FundedAt = timestamppb.New(*c.FundedAt)
	}
	if c.SweptTxid != nil {
		pbCheque.SweptTxid = c.SweptTxid
	}
	if c.SweptAt != nil {
		pbCheque.SweptAt = timestamppb.New(*c.SweptAt)
	}

	if c.IsFunded() && unlocked {
		privateKeyWIF, err := s.chequeEngine.DeriveChequePrivateKey(ctx, c.WalletID, c.DerivationIndex)
		if err != nil {
			return nil, fmt.Errorf("derive cheque %d private key: %w", c.ID, err)
		}
		pbCheque.PrivateKeyWif = &privateKeyWIF
	}

	return pbCheque, nil
}

// SetUTXOMetadata implements walletv1connect.WalletServiceHandler.
func (s *Server) SetUTXOMetadata(ctx context.Context, c *pb.SetUTXOMetadataRequest) (*emptypb.Empty, error) {
	if c.Outpoint == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "outpoint is required")
	}

	if err := utxometadata.Set(ctx, s.database, c.Outpoint, c.IsFrozen, c.Label); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("set UTXO metadata: %s", err)).WithCause(err)
	}

	// Coin selection runs in drivechaind, so a freeze reaches it only when we
	// hand the new set over. A caller that reads success must be able to
	// believe the coin is safe.
	if c.IsFrozen != nil {
		if err := s.walletEngine.PushFrozenCoins(ctx); err != nil {
			return nil, keepConnectCode(err)
		}
	}

	return &emptypb.Empty{}, nil
}

// GetUTXOMetadata implements walletv1connect.WalletServiceHandler.
func (s *Server) GetUTXOMetadata(ctx context.Context, c *pb.GetUTXOMetadataRequest) (*pb.GetUTXOMetadataResponse, error) {
	metadata, err := utxometadata.Get(ctx, s.database, c.Outpoints)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("get UTXO metadata: %s", err)).WithCause(err)
	}

	result := make(map[string]*pb.UTXOMetadata)
	for outpoint, entry := range metadata {
		result[outpoint] = &pb.UTXOMetadata{
			Outpoint: entry.Outpoint,
			IsFrozen: entry.IsFrozen,
			Label:    entry.Label,
		}
	}

	return &pb.GetUTXOMetadataResponse{
		Metadata: result,
	}, nil
}

// SetCoinSelectionStrategy implements walletv1connect.WalletServiceHandler.
func (s *Server) SetCoinSelectionStrategy(ctx context.Context, c *pb.SetCoinSelectionStrategyRequest) (*emptypb.Empty, error) {
	strategyStr := strconv.Itoa(int(c.Strategy))
	if err := preferences.Set(ctx, s.database, preferences.KeyCoinSelectionStrategy, strategyStr); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("set coin selection strategy: %s", err)).WithCause(err)
	}
	return &emptypb.Empty{}, nil
}

// GetCoinSelectionStrategy implements walletv1connect.WalletServiceHandler.
func (s *Server) GetCoinSelectionStrategy(ctx context.Context, c *emptypb.Empty) (*pb.GetCoinSelectionStrategyResponse, error) {
	value, err := preferences.Get(ctx, s.database, preferences.KeyCoinSelectionStrategy)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("get coin selection strategy: %s", err)).WithCause(err)
	}

	strategy := pb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_LARGEST_FIRST // default
	if value != "" {
		parsed, err := strconv.Atoi(value)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("parse coin selection strategy %q: %s", value, err)).WithCause(err)
		}
		strategy = pb.CoinSelectionStrategy(parsed)
	}

	return &pb.GetCoinSelectionStrategyResponse{
		Strategy: strategy,
	}, nil
}

// readPrevOut reads an input's previous output when Core leaves out prevout,
// as it does for a block with no undo data.
func readPrevOut(ctx context.Context, bitcoind corerpc.BitcoinServiceClient, txid string, vout uint32) (*corepb.PreviousOutput, error) {
	parent, err := bitcoind.GetRawTransaction(ctx, connectv1.NewRequest(&corepb.GetRawTransactionRequest{
		Txid:      txid,
		Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_INFO,
	}))
	if err != nil {
		return nil, fmt.Errorf("get previous transaction %s: %w", txid, err)
	}
	if int(vout) >= len(parent.Msg.Outputs) {
		return nil, fmt.Errorf("previous transaction %s has no output %d", txid, vout)
	}
	out := parent.Msg.Outputs[vout]
	return &corepb.PreviousOutput{Amount: out.Amount, ScriptPubKey: out.ScriptPubKey}, nil
}

// GetTransactionDetails implements walletv1connect.WalletServiceHandler.
// Returns enriched transaction details with resolved input values/addresses.
func (s *Server) GetTransactionDetails(ctx context.Context, c *pb.GetTransactionDetailsRequest) (*pb.GetTransactionDetailsResponse, error) {
	txid := c.Txid
	if txid == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "txid required")
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	rawTx, err := bitcoind.GetRawTransaction(ctx, connectv1.NewRequest(&corepb.GetRawTransactionRequest{
		Txid:      txid,
		Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_PREVOUT_INFO,
	}))
	switch {
	// Core error -5.
	case err != nil && strings.Contains(err.Error(), "No such mempool or blockchain transaction"):
		return nil, connect.NewError(connect.CodeNotFound, fmt.Sprintf("transaction not found: %s", err)).WithCause(err)
	case err != nil:
		return nil, fmt.Errorf("get transaction %s: %w", txid, err)
	}

	var inputs []*pb.TransactionInput
	var totalInputSats int64
	var isCoinbaseTx bool

	for i, vin := range rawTx.Msg.Inputs {
		isCoinbase := vin.Coinbase != ""
		isCoinbaseTx = isCoinbaseTx || isCoinbase

		var scriptSigAsm, scriptSigHex string
		if vin.ScriptSig != nil {
			scriptSigAsm = vin.ScriptSig.Asm
			scriptSigHex = vin.ScriptSig.Hex
		}

		input := &pb.TransactionInput{
			Index:        int32(i),
			PrevTxid:     vin.Txid,
			PrevVout:     int32(vin.Vout),
			ScriptSigAsm: scriptSigAsm,
			ScriptSigHex: scriptSigHex,
			Witness:      vin.Witness,
			Sequence:     int64(vin.Sequence),
			IsCoinbase:   isCoinbase,
		}

		if !isCoinbase {
			prevOut := vin.PreviousOutput
			if prevOut == nil {
				if prevOut, err = readPrevOut(ctx, bitcoind, vin.Txid, vin.Vout); err != nil {
					return nil, err
				}
			}
			valueSats, err := btcToSats(prevOut.Amount)
			if err != nil {
				return nil, fmt.Errorf("value of %s:%d: %w", vin.Txid, vin.Vout, err)
			}
			input.ValueSats = int64(valueSats)
			if prevOut.ScriptPubKey != nil {
				input.Address = prevOut.ScriptPubKey.Address
			}
			totalInputSats += input.ValueSats
		}

		inputs = append(inputs, input)
	}

	var outputs []*pb.TransactionOutput
	var totalOutputSats int64

	for i, vout := range rawTx.Msg.Outputs {
		sats, err := btcToSats(vout.Amount)
		if err != nil {
			return nil, fmt.Errorf("value of output %d: %w", i, err)
		}
		valueSats := int64(sats)
		totalOutputSats += valueSats

		var address, scriptType, scriptAsm, scriptHex string
		if vout.ScriptPubKey != nil {
			address = vout.ScriptPubKey.Address
			scriptType = vout.ScriptPubKey.Type
			scriptAsm = vout.ScriptPubKey.Asm
			scriptHex = vout.ScriptPubKey.Hex
		}

		outputs = append(outputs, &pb.TransactionOutput{
			Index:           int32(i),
			ValueSats:       valueSats,
			Address:         address,
			ScriptType:      scriptType,
			ScriptPubkeyAsm: scriptAsm,
			ScriptPubkeyHex: scriptHex,
		})
	}

	var feeSats int64
	if !isCoinbaseTx {
		feeSats = totalInputSats - totalOutputSats
	}

	var feeRate float64
	if rawTx.Msg.Vsize > 0 {
		feeRate = float64(feeSats) / float64(rawTx.Msg.Vsize)
	}

	var blockTime int64
	if rawTx.Msg.BlockTime != nil {
		blockTime = rawTx.Msg.BlockTime.AsTime().Unix()
	}

	var hexStr string
	if rawTx.Msg.Tx != nil {
		hexStr = rawTx.Msg.Tx.Hex
	}

	return &pb.GetTransactionDetailsResponse{
		Txid:            rawTx.Msg.Txid,
		Blockhash:       rawTx.Msg.Blockhash,
		Confirmations:   int32(rawTx.Msg.Confirmations),
		BlockTime:       blockTime,
		Version:         int32(rawTx.Msg.Version),
		Locktime:        int32(rawTx.Msg.Locktime),
		SizeBytes:       rawTx.Msg.Size,
		VsizeVbytes:     rawTx.Msg.Vsize,
		WeightWu:        rawTx.Msg.Weight,
		FeeSats:         feeSats,
		FeeRateSatVb:    feeRate,
		Inputs:          inputs,
		TotalInputSats:  totalInputSats,
		Outputs:         outputs,
		TotalOutputSats: totalOutputSats,
		Hex:             hexStr,
	}, nil
}

// GetUTXODistribution implements walletv1connect.WalletServiceHandler.
// Returns UTXO distribution data for chart visualization.
func (s *Server) GetUTXODistribution(ctx context.Context, c *pb.GetUTXODistributionRequest) (*pb.GetUTXODistributionResponse, error) {
	walletID := c.WalletId

	maxBuckets := int(c.MaxBuckets)
	if maxBuckets <= 0 {
		maxBuckets = 6
	}

	utxos, err := s.listUnspent(ctx, walletID, nil)
	if err != nil {
		return nil, keepConnectCode(fmt.Errorf("list unspent: %w", err))
	}

	if len(utxos) == 0 {
		return &pb.GetUTXODistributionResponse{
			Buckets: []*pb.UTXOBucket{},
		}, nil
	}

	minVal := utxos[0].ValueSats
	maxVal := utxos[0].ValueSats
	for _, utxo := range utxos {
		if utxo.ValueSats < minVal {
			minVal = utxo.ValueSats
		}
		if utxo.ValueSats > maxVal {
			maxVal = utxo.ValueSats
		}
	}

	ranges := generateDynamicBuckets(minVal, maxVal, maxBuckets)

	bucketData := make([]struct {
		valueSats int64
		count     int32
		outpoints []string
	}, len(ranges))

	for _, utxo := range utxos {
		for i, r := range ranges {
			if utxo.ValueSats >= r.minSats && utxo.ValueSats <= r.maxSats {
				bucketData[i].valueSats += int64(utxo.ValueSats)
				bucketData[i].count++
				bucketData[i].outpoints = append(bucketData[i].outpoints, utxo.Output)
				break
			}
		}
	}

	var buckets []*pb.UTXOBucket
	for i, r := range ranges {
		if bucketData[i].count > 0 {
			buckets = append(buckets, &pb.UTXOBucket{
				Label:     r.label,
				ValueSats: bucketData[i].valueSats,
				Count:     bucketData[i].count,
				Outpoints: bucketData[i].outpoints,
			})
		}
	}

	return &pb.GetUTXODistributionResponse{
		Buckets: buckets,
	}, nil
}

type bucketRange struct {
	minSats uint64
	maxSats uint64
	label   string
}

func generateDynamicBuckets(minVal, maxVal uint64, numBuckets int) []bucketRange {
	boundaries := []uint64{
		546,            // dust limit
		1_000,          // 0.00001 BTC
		5_000,          // 0.00005 BTC
		10_000,         // 0.0001 BTC
		50_000,         // 0.0005 BTC
		100_000,        // 0.001 BTC
		500_000,        // 0.005 BTC
		1_000_000,      // 0.01 BTC
		5_000_000,      // 0.05 BTC
		10_000_000,     // 0.1 BTC
		50_000_000,     // 0.5 BTC
		100_000_000,    // 1 BTC
		500_000_000,    // 5 BTC
		1_000_000_000,  // 10 BTC
		5_000_000_000,  // 50 BTC
		10_000_000_000, // 100 BTC
	}

	var relevantBoundaries []uint64
	for _, b := range boundaries {
		if b > minVal && b < maxVal {
			relevantBoundaries = append(relevantBoundaries, b)
		}
	}

	// If we have too many boundaries, select evenly spaced ones
	if len(relevantBoundaries) > numBuckets-1 {
		step := float64(len(relevantBoundaries)) / float64(numBuckets-1)
		var selected []uint64
		for i := 0; i < numBuckets-1; i++ {
			idx := int(float64(i) * step)
			if idx < len(relevantBoundaries) {
				selected = append(selected, relevantBoundaries[idx])
			}
		}
		relevantBoundaries = selected
	}

	var ranges []bucketRange
	prevBoundary := minVal

	for _, boundary := range relevantBoundaries {
		ranges = append(ranges, bucketRange{
			minSats: prevBoundary,
			maxSats: boundary - 1,
			label:   formatBucketRange(prevBoundary, boundary-1),
		})
		prevBoundary = boundary
	}

	ranges = append(ranges, bucketRange{
		minSats: prevBoundary,
		maxSats: maxVal,
		label:   formatBucketRange(prevBoundary, maxVal),
	})

	return ranges
}

func formatBucketRange(minSats, maxSats uint64) string {
	minBTC := float64(minSats) / 100_000_000
	maxBTC := float64(maxSats) / 100_000_000

	formatVal := func(btc float64) string {
		switch {
		case btc >= 1:
			return fmt.Sprintf("%.1f", btc)
		case btc >= 0.01:
			return fmt.Sprintf("%.2f", btc)
		case btc >= 0.001:
			return fmt.Sprintf("%.3f", btc)
		case btc >= 0.0001:
			return fmt.Sprintf("%.4f", btc)
		default:
			return strconv.FormatFloat(btc, 'f', -1, 64)
		}
	}

	// No unit: the ticker depends on the active network, which the client knows.
	return fmt.Sprintf("%s - %s", formatVal(minBTC), formatVal(maxBTC))
}

// BumpFee implements RBF (Replace-By-Fee) for unconfirmed transactions.
// Uses Bitcoin Core's bumpfee command with automatic fee estimation.
func (s *Server) BumpFee(ctx context.Context, c *pb.BumpFeeRequest) (*pb.BumpFeeResponse, error) {
	log := zerolog.Ctx(ctx)
	if c.Txid == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "txid required")
	}

	// The caller names a txid alone, so try every wallet until one owns it.
	// Each try runs where the frozen coins sit locked.
	wallets, err := s.walletEngine.ListWalletIDs(ctx)
	if err != nil {
		return nil, err
	}
	var resp *orchpb.BumpFeeResponse
	var errs []error
	for _, walletID := range append([]string{""}, wallets...) {
		resp, err = s.walletEngine.BumpFee(ctx, &orchpb.BumpFeeRequest{
			WalletId: walletID,
			Txid:     c.Txid,
		})
		if err == nil {
			break
		}
		errs = append(errs, fmt.Errorf("wallet %q: %w", walletID, err))
	}
	if resp == nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("bump fee of %s: %s", c.Txid, errors.Join(errs...))).WithCause(errors.Join(errs...))
	}

	log.Info().
		Str("old_txid", c.Txid).
		Str("new_txid", resp.NewTxid).
		Msg("RBF transaction broadcast")

	return &pb.BumpFeeResponse{
		Txid:        resp.NewTxid,
		OriginalFee: float64(resp.GetPlan().GetOldFeeSats()) / 1e8,
		NewFee:      float64(resp.GetPlan().GetNewFeeSats()) / 1e8,
	}, nil
}

// SelectCoins implements walletv1connect.WalletServiceHandler.
func (s *Server) SelectCoins(ctx context.Context, c *pb.SelectCoinsRequest) (*pb.SelectCoinsResponse, error) {
	labels, err := addressbook.LabelsByAddress(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("list addressbook: %w", err)
	}
	utxos, err := s.listUnspent(ctx, c.WalletId, labels)
	if err != nil {
		return nil, fmt.Errorf("list unspent: %w", err)
	}

	frozenOutpoints := make(map[string]bool)
	for _, outpoint := range c.FrozenOutpoints {
		frozenOutpoints[outpoint] = true
	}

	requiredOutpoints := make(map[string]bool)
	for _, outpoint := range c.RequiredOutpoints {
		requiredOutpoints[outpoint] = true
	}

	numOutputs := int(c.NumOutputs)
	if numOutputs <= 0 {
		numOutputs = 2
	}

	strategy := c.Strategy
	if strategy == pb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_UNSPECIFIED {
		strategy = pb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_LARGEST_FIRST
	}

	result, err := engines.SelectCoins(
		utxos,
		frozenOutpoints,
		c.TargetSats,
		c.FeeSatsPerVbyte,
		numOutputs,
		strategy,
		requiredOutpoints,
	)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	return &pb.SelectCoinsResponse{
		SelectedUtxos:  result.SelectedUTXOs,
		TotalInputSats: result.TotalInputSats,
		FeeSats:        result.FeeSats,
		ChangeSats:     result.ChangeSats,
	}, nil
}

// CreateBackup implements walletv1connect.WalletServiceHandler.
func (s *Server) CreateBackup(ctx context.Context, _ *emptypb.Empty) (*pb.CreateBackupResponse, error) {
	data, filename, err := s.backupEngine.CreateBackup(ctx)
	if err != nil {
		return nil, fmt.Errorf("create backup: %w", err)
	}

	return &pb.CreateBackupResponse{
		BackupData:        data,
		SuggestedFilename: filename,
	}, nil
}

// RestoreBackup implements walletv1connect.WalletServiceHandler.
func (s *Server) RestoreBackup(ctx context.Context, c *pb.RestoreBackupRequest) (*emptypb.Empty, error) {
	if len(c.BackupData) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, "backup_data is required")
	}
	if c.Filename == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "filename is required")
	}

	if err := s.backupEngine.RestoreBackup(ctx, c.BackupData, c.Filename); err != nil {
		return nil, fmt.Errorf("restore backup: %w", err)
	}

	// The enforcer reads the restored wallet only after a restart.
	if err := s.restartL1(ctx); err != nil {
		return nil, fmt.Errorf("restore backup: restart L1 stack: %w", err)
	}

	return &emptypb.Empty{}, nil
}

// ValidateBackup implements walletv1connect.WalletServiceHandler.
func (s *Server) ValidateBackup(ctx context.Context, c *pb.ValidateBackupRequest) (*pb.ValidateBackupResponse, error) {
	if len(c.BackupData) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, "backup_data is required")
	}
	if c.Filename == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "filename is required")
	}

	contents, err := s.backupEngine.ValidateBackup(ctx, c.BackupData, c.Filename)
	if err != nil {
		return &pb.ValidateBackupResponse{
			Valid:        false,
			ErrorMessage: err.Error(),
		}, nil
	}

	return &pb.ValidateBackupResponse{
		Valid:           true,
		HasWallet:       contents.HasWallet,
		HasMultisig:     contents.HasMultisig,
		HasTransactions: contents.HasTransactions,
	}, nil
}
