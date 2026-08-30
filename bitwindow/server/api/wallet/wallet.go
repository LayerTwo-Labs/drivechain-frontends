package api_wallet

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"math"
	"sort"
	"strconv"
	"strings"
	"time"

	"connectrpc.com/connect"
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
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/wallet"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/datasource"
	commonv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	cryptov1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1/cryptov1connect"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchwallet "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

var _ rpc.WalletServiceHandler = new(Server)

// New creates a new Server and starts the balance update loop
func New(
	ctx context.Context,
	database *sql.DB,
	data datasource.DataSource,
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
	crypto *service.Service[cryptorpc.CryptoServiceClient],
	chequeEngine *engines.ChequeEngine,
	chequeChain engines.ChequeChain,
	walletEngine *engines.WalletEngine,
	walletDir string,
	restartL1 func(context.Context) error,
) *Server {
	s := &Server{
		database:     database,
		chequeChain:  chequeChain,
		data:         data,
		bitcoind:     bitcoind,
		crypto:       crypto,
		chequeEngine: chequeEngine,
		walletEngine: walletEngine,
		backupEngine: engines.NewBackupEngine(database, walletDir),
		walletDir:    walletDir,
		restartL1:    restartL1,
	}

	// Start background sync of Bitcoin Core addresses to addressbook
	go s.startAddressSyncLoop(ctx)

	return s
}

type Server struct {
	database     *sql.DB
	data         datasource.DataSource
	bitcoind     *service.Service[corerpc.BitcoinServiceClient]
	crypto       *service.Service[cryptorpc.CryptoServiceClient]
	chequeEngine *engines.ChequeEngine
	chequeChain  engines.ChequeChain
	walletEngine *engines.WalletEngine
	backupEngine *engines.BackupEngine
	walletDir    string
	// restartL1 reboots the L1 stack (bitcoind + enforcer) via drivechaind;
	// nil when no orchestrator is configured. Called after a backup restore.
	restartL1 func(context.Context) error
}

// CreateBitcoinCoreWallet implements walletv1connect.WalletServiceHandler.
// Test endpoint to verify descriptor import to Bitcoin Core.
func (s *Server) CreateBitcoinCoreWallet(ctx context.Context, c *connect.Request[pb.CreateBitcoinCoreWalletRequest]) (*connect.Response[pb.CreateBitcoinCoreWalletResponse], error) {
	seedHex := strings.TrimSpace(c.Msg.SeedHex)
	if seedHex == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("seed_hex required"))
	}

	coreWalletName := c.Msg.Name
	if coreWalletName == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("name required"))
	}

	// Directly import to Bitcoin Core - no wallet.json needed
	if err := s.walletEngine.CreateBitcoinCoreWalletFromSeed(ctx, coreWalletName, seedHex, 0, ""); err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("create Bitcoin Core wallet failed")
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("create wallet: %w", err))
	}

	// Get first address for verification
	bitcoindClient, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	addrResp, err := bitcoindClient.GetNewAddress(ctx, connect.NewRequest(&corepb.GetNewAddressRequest{
		Wallet: coreWalletName,
	}))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("get new address: %w", err))
	}

	zerolog.Ctx(ctx).Info().
		Str("core_wallet_name", coreWalletName).
		Str("first_address", addrResp.Msg.Address).
		Msg("Created Bitcoin Core wallet from seed")

	return connect.NewResponse(&pb.CreateBitcoinCoreWalletResponse{
		WalletId:       "", // Not used in test
		CoreWalletName: coreWalletName,
		FirstAddress:   addrResp.Msg.Address,
	}), nil
}

// SendTransaction implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) SendTransaction(ctx context.Context, c *connect.Request[pb.SendTransactionRequest]) (*connect.Response[pb.SendTransactionResponse], error) {
	walletId := c.Msg.WalletId

	if len(c.Msg.Destinations) == 0 {
		err := errors.New("must provide a destination")
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not send transaction: no destination provided")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if c.Msg.FeeSatPerVbyte > 0 && c.Msg.FixedFeeSats > 0 {
		err := errors.New("cannot provide both fee rate and fee amount")
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not send transaction: both fee rate and fee amount provided")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	const dustLimit = 546
	for destination, amount := range c.Msg.Destinations {
		if amount < dustLimit {
			err := fmt.Errorf(
				"amount to %s is below dust limit (%s): %s",
				destination, btcutil.Amount(dustLimit), btcutil.Amount(amount),
			)
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not send transaction: amount below dust limit")
			return nil, connect.NewError(connect.CodeInvalidArgument, err)
		}
	}

	log := zerolog.Ctx(ctx)

	// Get wallet type to determine routing

	// Route to Bitcoin Core
	coreWalletName, err := s.walletEngine.GetBitcoinCoreWalletName(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get Bitcoin Core wallet: %w", err)
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("get bitcoind client: %w", err)
	}

	// Convert satoshi amounts to BTC (Bitcoin Core uses BTC, not satoshis)
	destinations := make(map[string]float64)
	for addr, sats := range c.Msg.Destinations {
		destinations[addr] = float64(sats) / 1e8
	}

	// If requiredInputs is specified, use raw transaction flow
	if len(c.Msg.RequiredInputs) > 0 {
		txid, err := s.sendWithRequiredInputs(ctx, bitcoind, coreWalletName, c.Msg.RequiredInputs, c.Msg.Destinations, c.Msg.FeeSatPerVbyte, c.Msg.FixedFeeSats)
		if err != nil {
			return nil, err
		}
		log.Info().Msgf("send tx: broadcast transaction with required inputs (Bitcoin Core): %s", txid)
		return connect.NewResponse(&pb.SendTransactionResponse{
			Txid: txid,
		}), nil
	}

	sendReq := &corepb.SendRequest{
		Destinations: destinations,
		Wallet:       coreWalletName,
	}

	// Set fee rate if provided (Bitcoin Core expects sat/vB directly)
	if c.Msg.FeeSatPerVbyte > 0 {
		sendReq.FeeRate = float64(c.Msg.FeeSatPerVbyte)
	}

	resp, err := bitcoind.Send(ctx, connect.NewRequest(sendReq))
	if err != nil {
		err = fmt.Errorf("bitcoin Core: send transaction: %w", err)
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not send transaction")
		return nil, err
	}

	log.Info().Msgf("send tx: broadcast transaction (Bitcoin Core): %s", resp.Msg.Txid)

	return connect.NewResponse(&pb.SendTransactionResponse{
		Txid: resp.Msg.Txid,
	}), nil
}

// sendWithRequiredInputs parses the "txid:vout" required inputs and broadcasts
// a transaction spending exactly those UTXOs.
func (s *Server) sendWithRequiredInputs(
	ctx context.Context,
	bitcoind corerpc.BitcoinServiceClient,
	walletName string,
	requiredInputs []*pb.UnspentOutput,
	destinationsSats map[string]uint64,
	feeSatPerVbyte uint64,
	fixedFeeSats uint64,
) (string, error) {
	wanted := make([]engines.CoreOutpoint, 0, len(requiredInputs))
	for _, utxo := range requiredInputs {
		parts := strings.Split(utxo.Output, ":")
		if len(parts) != 2 {
			return "", fmt.Errorf("invalid UTXO format: %s", utxo.Output)
		}
		vout, err := strconv.ParseUint(parts[1], 10, 32)
		if err != nil {
			return "", fmt.Errorf("invalid vout in UTXO %s: %w", utxo.Output, err)
		}
		wanted = append(wanted, engines.CoreOutpoint{Txid: parts[0], Vout: uint32(vout)})
	}

	return engines.SendCoreWithRequiredInputs(ctx, bitcoind, walletName, wanted, destinationsSats, feeSatPerVbyte, fixedFeeSats)
}

// GetNewAddress implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) GetNewAddress(ctx context.Context, c *connect.Request[pb.GetNewAddressRequest]) (*connect.Response[pb.GetNewAddressResponse], error) {
	walletId := c.Msg.WalletId
	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	addressType := c.Msg.AddressType
	if addressType == pb.AddressType_ADDRESS_TYPE_UNSPECIFIED {
		addressType = pb.AddressType_ADDRESS_TYPE_SEGWIT
	}

	coreAddressType := "bech32"
	if addressType == pb.AddressType_ADDRESS_TYPE_TAPROOT {
		coreAddressType = "bech32m"
	}

	// For segwit Bitcoin Core wallets, derive addresses and find the first
	// unused one to prevent address reuse and gaps in the derivation path.
	// Taproot addresses are served straight from Bitcoin Core (bech32m).
	if walletType == engines.WalletTypeBitcoinCore && addressType == pb.AddressType_ADDRESS_TYPE_SEGWIT {
		unusedAddress, derivedAddresses, err := s.deriveAndCheckAddresses(ctx, walletId)
		if err != nil {
			zerolog.Ctx(ctx).Warn().Err(err).Msg("derive addresses failed, will generate new")
		}
		if unusedAddress != "" {
			zerolog.Ctx(ctx).Debug().Str("address", unusedAddress).Msg("using derived unused address")

			// Save the unused address to addressbook
			err = addressbook.Create(ctx, s.database, &walletId, "", unusedAddress, addressbook.DirectionReceive)
			if err != nil && !strings.Contains(err.Error(), addressbook.ErrUniqueAddress) {
				zerolog.Ctx(ctx).Warn().Err(err).Msg("save address to addressbook")
			}

			return connect.NewResponse(&pb.GetNewAddressResponse{
				Address: unusedAddress,
				Index:   0,
			}), nil
		}

		// Also save any other derived addresses we found (for addressbook sync)
		for _, addr := range derivedAddresses {
			err = addressbook.Create(ctx, s.database, &walletId, "", addr.Address, addressbook.DirectionReceive)
			if err != nil && !strings.Contains(err.Error(), addressbook.ErrUniqueAddress) {
				zerolog.Ctx(ctx).Debug().Err(err).Str("address", addr.Address).Msg("save derived address")
			}
		}
	}

	var address string
	switch walletType {
	case engines.WalletTypeBitcoinCore:
		// Watch-only Core wallets import a descriptor; full wallets use the
		// seed-derived wallet. Both serve addresses from Bitcoin Core.
		ensure := s.walletEngine.GetBitcoinCoreWalletName
		watchOnly, err := s.walletEngine.IsWatchOnly(ctx, walletId)
		if err != nil {
			return nil, err
		}
		if watchOnly {
			ensure = s.walletEngine.EnsureWatchOnlyWallet
		}
		address, err = s.getBitcoinCoreAddress(ctx, walletId, ensure, coreAddressType)
		if err != nil {
			return nil, err
		}

	case engines.WalletTypeElectrum:
		// Electrum path — orchestrator derives the address and serves chain
		// data over Esplora.
		if addressType == pb.AddressType_ADDRESS_TYPE_TAPROOT {
			return nil, connect.NewError(connect.CodeUnimplemented, fmt.Errorf("taproot addresses are not supported for electrum wallets"))
		}
		address, err = s.walletEngine.GetElectrumReceiveAddress(ctx, walletId)
		if err != nil {
			return nil, err
		}

	default:
		return nil, fmt.Errorf("unknown wallet type: %s", walletType)
	}

	// Store all receiving addresses in the address book
	err = addressbook.Create(ctx, s.database, &walletId, "", address, addressbook.DirectionReceive)
	if err != nil {
		if err.Error() == addressbook.ErrUniqueAddress {
			// Address already in addressbook, that's fine
		} else {
			zerolog.Ctx(ctx).Warn().Err(err).Msg("failed to save address to addressbook")
		}
	}

	return connect.NewResponse(&pb.GetNewAddressResponse{
		Address: address,
		Index:   0, // Bitcoin Core doesn't expose index, Enforcer doesn't expose it either
	}), nil
}

// DerivedAddress represents an address derived from a wallet seed
type DerivedAddress struct {
	Address string
	Index   uint32
	Used    bool
}

// deriveAndCheckAddresses is the single source of truth for Bitcoin Core address derivation
// It derives addresses from the seed and checks which have been used
// Returns: (firstUnusedAddress, allDerivedAddresses, error)
func (s *Server) deriveAndCheckAddresses(ctx context.Context, walletId string) (string, []DerivedAddress, error) {
	// Get wallet info to access seed
	walletInfo, err := s.walletEngine.GetWalletInfo(ctx, walletId)
	if err != nil {
		return "", nil, fmt.Errorf("get wallet info: %w", err)
	}

	if walletInfo.Master.SeedHex == "" {
		return "", nil, fmt.Errorf("wallet has no seed")
	}

	chainParams := s.walletEngine.GetChainParams()

	external, err := deriveExternalChainKey(walletInfo, chainParams, orchwallet.ScriptNativeSegwit)
	if err != nil {
		return "", nil, err
	}

	walletName, err := s.walletEngine.GetBitcoinCoreWalletName(ctx, walletId)
	if err != nil {
		return "", nil, fmt.Errorf("get wallet name: %w", err)
	}

	// Get all transactions once to avoid repeated RPC calls
	txResp, err := s.data.ListWalletTransactions(ctx, &corepb.ListTransactionsRequest{
		Wallet: walletName,
		Count:  1000, // Check recent transactions
	})
	if err != nil {
		return "", nil, fmt.Errorf("list transactions: %w", err)
	}

	// Build a map of used addresses for fast lookup
	usedAddresses := make(map[string]bool)
	for _, tx := range txResp.Transactions {
		for _, detail := range tx.Details {
			usedAddresses[detail.Address] = true
		}
	}

	var derivedAddresses []DerivedAddress
	firstUnusedAddress := ""

	// Derive addresses and check usage
	for i := uint32(0); i < addressScanDepth; i++ {
		// Derive address at index i
		addrKey, err := external.Derive(i)
		if err != nil {
			return "", nil, fmt.Errorf("derive address %d: %w", i, err)
		}

		pubKey, err := addrKey.ECPubKey()
		if err != nil {
			return "", nil, fmt.Errorf("get public key %d: %w", i, err)
		}

		// Create P2WPKH address
		pubKeyHash := btcutil.Hash160(pubKey.SerializeCompressed())
		witnessAddr, err := btcutil.NewAddressWitnessPubKeyHash(pubKeyHash, chainParams)
		if err != nil {
			return "", nil, fmt.Errorf("create address %d: %w", i, err)
		}

		address := witnessAddr.EncodeAddress()
		used := usedAddresses[address]

		derivedAddresses = append(derivedAddresses, DerivedAddress{
			Address: address,
			Index:   i,
			Used:    used,
		})

		// Track first unused address
		if firstUnusedAddress == "" && !used {
			firstUnusedAddress = address
		}
	}

	return firstUnusedAddress, derivedAddresses, nil
}

// syncCoreAddresses syncs derived addresses to the addressbook
// This ensures the addressbook stays in sync with wallet state
func (s *Server) syncCoreAddresses(ctx context.Context) error {
	wallets, err := s.walletEngine.GetAllWallets(ctx)
	if err != nil {
		return fmt.Errorf("get wallets: %w", err)
	}

	// Sync addresses for each Bitcoin Core wallet
	for _, wallet := range wallets {
		if wallet.WalletType != engines.WalletTypeBitcoinCore {
			continue
		}

		// Use the unified function to derive and check addresses
		_, derivedAddresses, err := s.deriveAndCheckAddresses(ctx, wallet.ID)
		if err != nil {
			zerolog.Ctx(ctx).Warn().Err(err).
				Str("wallet_id", wallet.ID).
				Str("wallet_name", wallet.Name).
				Msg("derive addresses for sync")
			continue
		}

		// Add all derived addresses to addressbook
		for _, addr := range derivedAddresses {
			err := addressbook.Create(ctx, s.database, &wallet.ID, "", addr.Address, addressbook.DirectionReceive)
			if err != nil && !strings.Contains(err.Error(), addressbook.ErrUniqueAddress) {
				zerolog.Ctx(ctx).Debug().Err(err).
					Str("address", addr.Address).
					Str("wallet_id", wallet.ID).
					Msg("save address to addressbook")
			}
		}
	}

	return nil
}

// startAddressSyncLoop runs syncCoreAddresses periodically
func (s *Server) startAddressSyncLoop(ctx context.Context) {
	ticker := time.NewTicker(5 * time.Minute)
	defer ticker.Stop()

	// Initial sync
	if err := s.syncCoreAddresses(ctx); err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("initial address sync")
	}

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if err := s.syncCoreAddresses(ctx); err != nil {
				zerolog.Ctx(ctx).Warn().Err(err).Msg("periodic address sync")
			}
		}
	}
}

// getBitcoinCoreAddress is a helper to get a new address from Bitcoin Core wallets
func (s *Server) getBitcoinCoreAddress(
	ctx context.Context,
	walletId string,
	getWalletName func(context.Context, string) (string, error),
	addressType string,
) (string, error) {
	walletName, err := getWalletName(ctx, walletId)
	if err != nil {
		return "", fmt.Errorf("get wallet name: %w", err)
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return "", err
	}

	resp, err := bitcoind.GetNewAddress(ctx, connect.NewRequest(&corepb.GetNewAddressRequest{
		Wallet:      walletName,
		AddressType: addressType,
	}))
	if err != nil {
		return "", fmt.Errorf("bitcoin core get new address: %w", err)
	}

	return resp.Msg.Address, nil
}

// GetBalance implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) GetBalance(ctx context.Context, c *connect.Request[pb.GetBalanceRequest]) (*connect.Response[pb.GetBalanceResponse], error) {
	walletId := c.Msg.WalletId
	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	switch walletType {
	case engines.WalletTypeBitcoinCore:
		watchOnly, err := s.walletEngine.IsWatchOnly(ctx, walletId)
		if err != nil {
			return nil, err
		}
		ensure := s.walletEngine.GetBitcoinCoreWalletName
		if watchOnly {
			ensure = s.walletEngine.EnsureWatchOnlyWallet
		}
		coreWalletName, err := ensure(ctx, walletId)
		if err != nil {
			return nil, fmt.Errorf("ensure core wallet: %w", err)
		}

		bitcoindClient, err := s.bitcoind.Get(ctx)
		if err != nil {
			return nil, fmt.Errorf("get bitcoind client: %w", err)
		}

		balancesResp, err := bitcoindClient.GetBalances(ctx, connect.NewRequest(&corepb.GetBalancesRequest{
			Wallet: coreWalletName,
		}))
		if err != nil {
			return nil, fmt.Errorf("get balances from bitcoin core: %w", err)
		}

		// An imported descriptor's funds report under `watchonly`; a
		// seed-derived wallet's under `mine`.
		var confirmedSats, pendingSats uint64
		if watchOnly {
			confirmedSats = uint64(balancesResp.Msg.Watchonly.Trusted * 100_000_000)
			pendingSats = uint64(balancesResp.Msg.Watchonly.UntrustedPending * 100_000_000)
		} else {
			confirmedSats = uint64(balancesResp.Msg.Mine.Trusted * 100_000_000)
			pendingSats = uint64(balancesResp.Msg.Mine.UntrustedPending * 100_000_000)
		}

		return connect.NewResponse(&pb.GetBalanceResponse{
			ConfirmedSatoshi: confirmedSats,
			PendingSatoshi:   pendingSats,
		}), nil

	case engines.WalletTypeElectrum:
		confirmedSats, pendingSats, err := s.walletEngine.GetElectrumBalance(ctx, walletId)
		if err != nil {
			return nil, err
		}
		return connect.NewResponse(&pb.GetBalanceResponse{
			ConfirmedSatoshi: confirmedSats,
			PendingSatoshi:   pendingSats,
		}), nil

	default:
		return nil, fmt.Errorf("unknown wallet type: %s", walletType)
	}
}

// ListTransactions implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListTransactions(ctx context.Context, c *connect.Request[pb.ListTransactionsRequest]) (*connect.Response[pb.ListTransactionsResponse], error) {
	walletId := c.Msg.WalletId
	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	if walletType == engines.WalletTypeElectrum {
		entries, err := s.walletEngine.GetElectrumTransactions(ctx, walletId)
		if err != nil {
			return nil, err
		}

		addressBookEntries, err := addressbook.List(ctx, s.database)
		if err != nil {
			return nil, fmt.Errorf("electrum: could not list addressbook: %w", err)
		}
		label := func(addr string) string {
			for _, e := range addressBookEntries {
				if e.Address == addr {
					return e.Label
				}
			}
			return ""
		}
		notes, err := transactions.ListByWallet(ctx, s.database, walletId)
		if err != nil {
			return nil, fmt.Errorf("electrum: could not list notes: %w", err)
		}
		noteMap := make(map[string]string, len(notes))
		for _, n := range notes {
			noteMap[n.TxID] = n.Note
		}

		out := make([]*pb.WalletTransaction, 0, len(entries))
		for _, t := range entries {
			var received, sent uint64
			if t.AmountSats >= 0 {
				received = uint64(t.AmountSats)
			} else {
				sent = uint64(-t.AmountSats)
			}
			var confirmation *pb.Confirmation
			if t.Confirmations > 0 {
				confirmation = &pb.Confirmation{Timestamp: &timestamppb.Timestamp{Seconds: t.BlockTime}}
			}
			lbl := t.Label
			if lbl == "" {
				lbl = label(t.Address)
			}
			out = append(out, &pb.WalletTransaction{
				Txid:             t.Txid,
				FeeSats:          uint64(math.Round(math.Abs(t.Fee) * 1e8)),
				ReceivedSatoshi:  received,
				SentSatoshi:      sent,
				Address:          t.Address,
				AddressLabel:     lbl,
				Note:             noteMap[t.Txid],
				ConfirmationTime: confirmation,
			})
		}
		return connect.NewResponse(&pb.ListTransactionsResponse{Transactions: out}), nil
	}

	// Bitcoin Core path
	ensure := s.walletEngine.GetBitcoinCoreWalletName
	watchOnly, err := s.walletEngine.IsWatchOnly(ctx, walletId)
	if err != nil {
		return nil, err
	}
	if watchOnly {
		ensure = s.walletEngine.EnsureWatchOnlyWallet
	}
	coreWalletName, err := ensure(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get Bitcoin Core wallet: %w", err)
	}

	txsResp, err := s.data.ListWalletTransactions(ctx, &corepb.ListTransactionsRequest{
		Wallet: coreWalletName,
		Count:  1000, // Get last 1000 transactions
	})
	if err != nil {
		return nil, fmt.Errorf("bitcoin core list transactions: %w", err)
	}

	// Fetch address book and notes
	addressBookEntries, err := addressbook.List(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("list addressbook: %w", err)
	}

	notes, err := transactions.ListByWallet(ctx, s.database, walletId)
	if err != nil {
		return nil, fmt.Errorf("list transactions: %w", err)
	}
	noteMap := make(map[string]string)
	for _, note := range notes {
		noteMap[note.TxID] = note.Note
	}

	matchAddressLabel := func(addr string) string {
		for _, entry := range addressBookEntries {
			if entry.Address == addr {
				return entry.Label
			}
		}
		return ""
	}

	// Group transactions by txid to combine amounts
	txMap := make(map[string]*pb.WalletTransaction)
	for _, tx := range txsResp.Transactions {
		existing, found := txMap[tx.Txid]
		if !found {
			var confirmation *pb.Confirmation
			if tx.Confirmations > 0 {
				// BlockTime is always nil for ListTransactions in btc-buf, use Time or TimeReceived instead
				timestamp := tx.Time
				if timestamp == nil {
					timestamp = tx.TimeReceived
				}
				if timestamp != nil {
					confirmation = &pb.Confirmation{
						Timestamp: timestamp,
					}
				}
			}

			// Extract address from Details
			address := ""
			if len(tx.Details) > 0 {
				// Use the first detail's address
				address = tx.Details[0].Address
			}

			feeSats := uint64(0)
			if tx.Fee < 0 {
				feeSats = uint64(-tx.Fee * 100_000_000)
			}

			var receivedSats, sentSats uint64
			if tx.Amount > 0 {
				receivedSats = uint64(tx.Amount * 100_000_000)
			} else {
				sentSats = uint64(-tx.Amount * 100_000_000)
			}

			txMap[tx.Txid] = &pb.WalletTransaction{
				Txid:             tx.Txid,
				FeeSats:          feeSats,
				ReceivedSatoshi:  receivedSats,
				SentSatoshi:      sentSats,
				Address:          address,
				AddressLabel:     matchAddressLabel(address),
				Note:             noteMap[tx.Txid],
				ConfirmationTime: confirmation,
			}
		} else {
			// Update existing entry with additional info
			if tx.Amount > 0 {
				existing.ReceivedSatoshi += uint64(tx.Amount * 100_000_000)
			} else {
				existing.SentSatoshi += uint64(-tx.Amount * 100_000_000)
			}
		}
	}

	var walletTxs []*pb.WalletTransaction
	for _, tx := range txMap {
		walletTxs = append(walletTxs, tx)
	}

	return connect.NewResponse(&pb.ListTransactionsResponse{
		Transactions: walletTxs,
	}), nil
}

// ListSidechainDeposits implements walletv1connect.WalletServiceHandler.
//
// Only this install's own deposits are knowable. An M5 is an ordinary
// transaction on the wire, so nothing on chain marks one after the fact.
func (s *Server) ListSidechainDeposits(ctx context.Context, c *connect.Request[pb.ListSidechainDepositsRequest]) (*connect.Response[pb.ListSidechainDepositsResponse], error) {
	if c.Msg.Slot < 0 || c.Msg.Slot > 255 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("slot must be 0-255"))
	}

	// Wallet ID validation only - deposit history reads the same for all wallet
	// types. An empty ID would list every wallet's deposits.
	_, err := s.walletEngine.GetWalletBackendType(ctx, c.Msg.WalletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	// Deposit history is wallet data, so the wallet has to be unlocked
	if !s.walletEngine.IsUnlocked() {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("wallet is locked"))
	}

	deposits, err := s.walletEngine.ListSidechainDeposits(ctx, uint32(c.Msg.Slot), c.Msg.WalletId)
	if err != nil {
		return nil, fmt.Errorf("list sidechain deposits: %w", err)
	}
	return connect.NewResponse(&pb.ListSidechainDepositsResponse{
		Deposits: lo.Map(deposits, func(d *orchpb.SidechainDeposit, _ int) *pb.ListSidechainDepositsResponse_SidechainDeposit {
			return &pb.ListSidechainDepositsResponse_SidechainDeposit{
				Txid:          d.Txid,
				Amount:        d.AmountSats,
				Fee:           d.FeeSats,
				Confirmations: d.Confirmations,
			}
		}),
	}), nil
}

// CreateSidechainDeposit implements walletv1connect.WalletServiceHandler.
func (s *Server) CreateSidechainDeposit(ctx context.Context, c *connect.Request[pb.CreateSidechainDepositRequest]) (*connect.Response[pb.CreateSidechainDepositResponse], error) {
	walletId := c.Msg.WalletId
	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	slot, depositAddress, _, err := drivechain.DecodeDepositAddress(c.Msg.Destination)
	if err != nil {
		return nil, fmt.Errorf("invalid deposit address: %w", err)
	}
	if slot == nil && c.Msg.Slot == 0 {
		return nil, fmt.Errorf("address is not a sidechain deposit address, expected slot or format: s<slot>_<address> or s9_<address>_<checksum>")
	} else if slot == nil {
		slot = &c.Msg.Slot
	}
	if *slot > 255 {
		return nil, fmt.Errorf("invalid sidechain slot %d: must be 0-255", *slot)
	}

	amount, err := btcutil.NewAmount(c.Msg.Amount)
	if err != nil || amount < 0 {
		return nil, fmt.Errorf("invalid amount, must be a BTC-amount greater than zero")
	}

	fee, err := btcutil.NewAmount(c.Msg.Fee)
	if err != nil || fee < 0 {
		return nil, fmt.Errorf("invalid fee, must be a BTC-amount greater than zero")
	}

	// Electrum and Core wallets build the M5 deposit themselves (no local
	// enforcer) and broadcast it through the orchestrator wallet manager.
	if walletType == engines.WalletTypeElectrum || walletType == engines.WalletTypeBitcoinCore {
		return s.createWalletSidechainDeposit(ctx, walletId, uint32(*slot), depositAddress, amount, fee)
	}

	return nil, connect.NewError(connect.CodeFailedPrecondition,
		errors.New("this wallet backend cannot build a sidechain deposit"))
}

// createWalletSidechainDeposit delegates the M5 to the orchestrator, which
// assembles it and funds it from the wallet, whatever backend serves it.
func (s *Server) createWalletSidechainDeposit(
	ctx context.Context,
	walletId string,
	slot uint32,
	depositAddress string,
	amount, fee btcutil.Amount,
) (*connect.Response[pb.CreateSidechainDepositResponse], error) {
	txid, err := s.walletEngine.CreateDeposit(ctx, &orchpb.CreateDepositRequest{
		Slot:        int32(slot),
		WalletId:    walletId,
		Destination: depositAddress,
		AmountSats:  int64(amount),
		FeeSats:     int64(fee),
	})
	if err != nil {
		return nil, fmt.Errorf("broadcast sidechain deposit: %w", err)
	}

	zerolog.Ctx(ctx).Info().Str("txid", txid).Uint32("slot", slot).Msg("create electrum deposit tx: broadcast")

	return connect.NewResponse(&pb.CreateSidechainDepositResponse{Txid: txid}), nil
}

// addressScanDepth bounds how far along the external chain the wallet derives
// receiving addresses, and so how far a signable address can sit.
const addressScanDepth = 100

// walletScriptKinds returns the script kinds a wallet's receive descriptors were
// imported with, mirroring engines.coreDescriptors.
func walletScriptKinds(wallet *engines.WalletInfo) ([]orchwallet.ScriptKind, error) {
	// Core wallets import BIP84+BIP86, Electrum ones can be at m/44' or m/49',
	// and the stored wallet does not say which — so try every standard purpose.
	if strings.TrimSpace(wallet.DerivationPath) == "" {
		return []orchwallet.ScriptKind{
			orchwallet.ScriptNativeSegwit,
			orchwallet.ScriptTaproot,
			orchwallet.ScriptNestedSegwit,
			orchwallet.ScriptLegacy,
		}, nil
	}

	accountPath, err := orchwallet.ParseAccountPath(wallet.DerivationPath)
	if err != nil {
		return nil, fmt.Errorf("invalid derivation path: %w", err)
	}

	kind, ok := orchwallet.PurposeToCoreKind(accountPath.Purpose)
	if !ok {
		return nil, fmt.Errorf("unsupported derivation purpose %d'", accountPath.Purpose)
	}

	return []orchwallet.ScriptKind{kind}, nil
}

// deriveExternalChainKey derives the external chain a wallet's addresses of this
// script kind come from, at the account path its descriptors were imported with.
func deriveExternalChainKey(wallet *engines.WalletInfo, chainParams *chaincfg.Params, kind orchwallet.ScriptKind) (*hdkeychain.ExtendedKey, error) {
	seed, err := hex.DecodeString(wallet.Master.SeedHex)
	if err != nil {
		return nil, fmt.Errorf("decode seed: %w", err)
	}

	masterKey, err := hdkeychain.NewMaster(seed, chainParams)
	if err != nil {
		return nil, fmt.Errorf("derive master key: %w", err)
	}

	accountPath, err := orchwallet.ResolveAccountPath(
		wallet.AccountIndex, wallet.DerivationPath, kind, chainParams,
	)
	if err != nil {
		return nil, fmt.Errorf("resolve account path: %w", err)
	}

	account, err := engines.DeriveHardenedPath(masterKey, accountPath)
	if err != nil {
		return nil, fmt.Errorf("derive account: %w", err)
	}

	external, err := account.Derive(0)
	if err != nil {
		return nil, fmt.Errorf("derive external chain: %w", err)
	}

	return external, nil
}

// receiveAddressForKind builds the receiving address a pubkey produces under kind.
func receiveAddressForKind(kind orchwallet.ScriptKind, pubKey *btcec.PublicKey, chainParams *chaincfg.Params) (btcutil.Address, error) {
	pkHash := btcutil.Hash160(pubKey.SerializeCompressed())

	if kind == orchwallet.ScriptNativeSegwit {
		return btcutil.NewAddressWitnessPubKeyHash(pkHash, chainParams)
	}

	if kind == orchwallet.ScriptTaproot {
		return btcutil.NewAddressTaproot(schnorr.SerializePubKey(txscript.ComputeTaprootKeyNoScript(pubKey)), chainParams)
	}

	if kind == orchwallet.ScriptLegacy {
		return btcutil.NewAddressPubKeyHash(pkHash, chainParams)
	}

	if kind == orchwallet.ScriptNestedSegwit {
		witness, err := btcutil.NewAddressWitnessPubKeyHash(pkHash, chainParams)
		if err != nil {
			return nil, err
		}

		redeem, err := txscript.PayToAddrScript(witness)
		if err != nil {
			return nil, err
		}

		return btcutil.NewAddressScriptHash(redeem, chainParams)
	}

	return nil, fmt.Errorf("unsupported script kind %s", kind)
}

// deriveMessageSigningPrivateKey returns the hex encoded key behind address, so
// the signature proves ownership of that address rather than some other one.
func deriveMessageSigningPrivateKey(wallet *engines.WalletInfo, chainParams *chaincfg.Params, address string) (string, error) {
	kinds, err := walletScriptKinds(wallet)
	if err != nil {
		return "", err
	}

	for _, kind := range kinds {
		external, err := deriveExternalChainKey(wallet, chainParams, kind)
		if err != nil {
			return "", err
		}

		for i := uint32(0); i < addressScanDepth; i++ {
			addrKey, err := external.Derive(i)
			if err != nil {
				return "", fmt.Errorf("derive address %d: %w", i, err)
			}

			pubKey, err := addrKey.ECPubKey()
			if err != nil {
				return "", fmt.Errorf("get public key %d: %w", i, err)
			}

			derived, err := receiveAddressForKind(kind, pubKey, chainParams)
			if err != nil {
				return "", fmt.Errorf("create address %d: %w", i, err)
			}

			if derived.EncodeAddress() != address {
				continue
			}

			privKey, err := addrKey.ECPrivKey()
			if err != nil {
				return "", fmt.Errorf("get private key %d: %w", i, err)
			}

			// A taproot address commits to the tweaked output key, so the
			// untweaked internal key would sign for a key nobody can check.
			if kind == orchwallet.ScriptTaproot {
				privKey = txscript.TweakTaprootPrivKey(*privKey, []byte{})
			}

			return hex.EncodeToString(privKey.Serialize()), nil
		}
	}

	return "", fmt.Errorf("address %s is not one of the wallet's first %d receiving addresses", address, addressScanDepth)
}

// SignMessage implements walletv1connect.WalletServiceHandler.
func (s *Server) SignMessage(ctx context.Context, c *connect.Request[pb.SignMessageRequest]) (*connect.Response[pb.SignMessageResponse], error) {
	walletId := c.Msg.WalletId

	// Wallet ID validation only - signing works the same for both wallet types
	_, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	// Signing needs the seed, so the wallet has to be unlocked
	if !s.walletEngine.IsUnlocked() {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("wallet is locked"))
	}

	if c.Msg.Address == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("address is required"))
	}

	walletInfo, err := s.walletEngine.GetWalletInfo(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet info: %w", err)
	}

	privKeyHex, err := deriveMessageSigningPrivateKey(walletInfo, s.walletEngine.GetChainParams(), c.Msg.Address)
	if err != nil {
		return nil, fmt.Errorf("derive signing key: %w", err)
	}

	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, err
	}

	res, err := crypto.Secp256K1Sign(ctx, connect.NewRequest(&cryptov1.Secp256K1SignRequest{
		Message: &commonv1.Hex{
			Hex: &wrapperspb.StringValue{Value: hex.EncodeToString([]byte(c.Msg.Message))},
		},
		SecretKey: &commonv1.ConsensusHex{
			Hex: &wrapperspb.StringValue{Value: privKeyHex},
		},
	}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/crypto: could not sign message: %w", err)
	}

	return connect.NewResponse(&pb.SignMessageResponse{
		Signature: res.Msg.Signature.Hex.Value,
	}), nil
}

// VerifyMessage implements walletv1connect.WalletServiceHandler.
func (s *Server) VerifyMessage(ctx context.Context, c *connect.Request[pb.VerifyMessageRequest]) (*connect.Response[pb.VerifyMessageResponse], error) {
	// Verification needs only the message, signature and public key, so a third
	// party proof verifies without any wallet of our own.
	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, err
	}

	res, err := crypto.Secp256K1Verify(ctx, connect.NewRequest(&cryptov1.Secp256K1VerifyRequest{
		Message: &commonv1.Hex{
			Hex: &wrapperspb.StringValue{Value: hex.EncodeToString([]byte(c.Msg.Message))},
		},
		Signature: &commonv1.Hex{
			Hex: &wrapperspb.StringValue{Value: c.Msg.Signature},
		},
		PublicKey: &commonv1.ConsensusHex{
			Hex: &wrapperspb.StringValue{Value: c.Msg.PublicKey},
		},
	}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/crypto: could not verify message: %w", err)
	}

	return connect.NewResponse(&pb.VerifyMessageResponse{
		Valid: res.Msg.Valid,
	}), nil
}

// ListUnspent implements walletv1connect.WalletServiceHandler.
func (s *Server) ListUnspent(ctx context.Context, c *connect.Request[pb.ListUnspentRequest]) (*connect.Response[pb.ListUnspentResponse], error) {
	walletId := c.Msg.WalletId
	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	// Fetch the addressbook entries once for label lookup
	addressBookEntries, err := addressbook.List(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("list addressbook: %w", err)
	}
	getLabel := func(addr string) string {
		for _, entry := range addressBookEntries {
			if entry.Address == addr {
				return entry.Label
			}
		}
		return ""
	}

	var utxos []*pb.UnspentOutput
	switch walletType {
	case engines.WalletTypeElectrum:
		utxos, err = s.listUnspentElectrum(ctx, walletId, getLabel)
	case engines.WalletTypeBitcoinCore:
		utxos, err = s.listUnspentBitcoinCore(ctx, walletId, getLabel)
	default:
		err = fmt.Errorf("unknown wallet type: %s", walletType)
	}
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&pb.ListUnspentResponse{Utxos: utxos}), nil
}

func (s *Server) listUnspentElectrum(ctx context.Context, walletId string, getLabel func(string) string) ([]*pb.UnspentOutput, error) {
	raw, err := s.walletEngine.GetElectrumUnspent(ctx, walletId)
	if err != nil {
		return nil, err
	}
	utxos := make([]*pb.UnspentOutput, 0, len(raw))
	for _, u := range raw {
		utxos = append(utxos, &pb.UnspentOutput{
			Output:    fmt.Sprintf("%s:%d", u.Txid, u.Vout),
			Address:   u.Address,
			Label:     getLabel(u.Address),
			ValueSats: uint64(u.AmountSats),
		})
	}
	return utxos, nil
}

func (s *Server) listUnspentBitcoinCore(ctx context.Context, walletId string, getLabel func(string) string) ([]*pb.UnspentOutput, error) {
	coreWalletName, err := s.walletEngine.GetBitcoinCoreWalletName(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get Bitcoin Core wallet: %w", err)
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	resp, err := bitcoind.ListUnspent(ctx, connect.NewRequest(&corepb.ListUnspentRequest{
		Wallet: coreWalletName,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoin Core list unspent: %w", err)
	}

	denials, err := deniability.List(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("bitcoin core: could not list denials: %w", err)
	}

	var utxosWithInfo []*pb.UnspentOutput
	for _, utxo := range resp.Msg.Unspent {
		valueSats := uint64(utxo.Amount * 100000000)

		utxosWithInfo = append(utxosWithInfo, &pb.UnspentOutput{
			Output:     fmt.Sprintf("%s:%d", utxo.Txid, utxo.Vout),
			Address:    utxo.Address,
			Label:      getLabel(utxo.Address),
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
		if d.TipTXID == txid && d.TipVout == vout {
			return true
		}

		return lo.ContainsBy(d.ExecutedDenials, func(e deniability.ExecutedDenial) bool {
			return e.ToTxID == txid
		})
	})

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
func (s *Server) ListReceiveAddresses(ctx context.Context, c *connect.Request[pb.ListReceiveAddressesRequest]) (*connect.Response[pb.ListReceiveAddressesResponse], error) {
	walletId := c.Msg.WalletId

	// Bitcoin Core version
	coreWalletName, err := s.walletEngine.GetBitcoinCoreWalletName(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get bitcoin core wallet: %w", err)
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("get bitcoind client: %w", err)
	}

	// Get all UTXOs to build the address list
	utxosResp, err := bitcoind.ListUnspent(ctx, connect.NewRequest(&corepb.ListUnspentRequest{
		Wallet: coreWalletName,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoin core list unspent: %w", err)
	}

	// Fetch address book for labels
	addressBookEntries, err := addressbook.List(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("list addressbook: %w", err)
	}

	getLabel := func(addr string) string {
		for _, entry := range addressBookEntries {
			if entry.Address == addr {
				return entry.Label
			}
		}
		return ""
	}

	// Build map of addresses with their balances
	addressMap := make(map[string]*pb.ReceiveAddress)
	for _, utxo := range utxosResp.Msg.Unspent {
		if utxo.Address == "" {
			continue
		}

		if existing, found := addressMap[utxo.Address]; found {
			existing.CurrentBalanceSat += uint64(utxo.Amount * 100_000_000)
		} else {
			addressMap[utxo.Address] = &pb.ReceiveAddress{
				Address:           utxo.Address,
				Label:             getLabel(utxo.Address),
				CurrentBalanceSat: uint64(utxo.Amount * 100_000_000),
				IsChange:          false, // Bitcoin Core doesn't expose this easily
			}
		}
	}

	var addresses []*pb.ReceiveAddress
	for _, addr := range addressMap {
		addresses = append(addresses, addr)
	}

	return connect.NewResponse(&pb.ListReceiveAddressesResponse{
		Addresses: addresses,
	}), nil
}

// GetStats implements walletv1connect.WalletServiceHandler.
func (s *Server) GetStats(ctx context.Context, c *connect.Request[pb.GetStatsRequest]) (*connect.Response[pb.GetStatsResponse], error) {
	walletId := c.Msg.WalletId

	// Bitcoin Core version
	// Get UTXOs
	utxos, err := s.ListUnspent(ctx, connect.NewRequest(&pb.ListUnspentRequest{WalletId: walletId}))
	if err != nil {
		return nil, err
	}
	utxoCount := uint64(len(utxos.Msg.Utxos))

	// Count unique addresses among UTXOs
	addressSet := make(map[string]struct{})
	for _, utxo := range utxos.Msg.Utxos {
		addressSet[utxo.Address] = struct{}{}
	}
	uniqueAddressCount := uint64(len(addressSet))

	// Get transactions
	txs, err := s.ListTransactions(ctx, connect.NewRequest(&pb.ListTransactionsRequest{WalletId: walletId}))
	if err != nil {
		return nil, err
	}
	transactionCount := int64(len(txs.Msg.Transactions))

	// Count transactions since the start of the current month, sum
	// lifetime fees paid, and find the most recent confirmed tx.
	now := time.Now()
	currentYear, currentMonth, _ := now.Date()
	currentMonthStart := time.Date(currentYear, currentMonth, 1, 0, 0, 0, 0, now.Location())
	transactionCountSinceMonth := int64(0)
	var totalFees int64
	var lastTxAt *timestamppb.Timestamp
	var lastTxBlockHeight uint32
	for _, tx := range txs.Msg.Transactions {
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
	depositVolume, depositVolume30d, err := s.walletEngine.SidechainDepositTotals(ctx, now.AddDate(0, 0, -30), walletId)
	if err != nil {
		return nil, fmt.Errorf("sum sidechain deposits: %w", err)
	}

	return connect.NewResponse(&pb.GetStatsResponse{
		UtxosCurrent:                      utxoCount,
		UtxosUniqueAddresses:              uniqueAddressCount,
		SidechainDepositVolume:            depositVolume,
		SidechainDepositVolumeLast_30Days: depositVolume30d,
		TransactionCountTotal:             transactionCount,
		TransactionCountSinceMonth:        transactionCountSinceMonth,
		TotalFeesSats:                     totalFees,
		LastTxAt:                          lastTxAt,
		LastTxBlockHeight:                 lastTxBlockHeight,
	}), nil
}

// UnlockWallet implements walletv1connect.WalletServiceHandler.
func (s *Server) UnlockWallet(ctx context.Context, c *connect.Request[pb.UnlockWalletRequest]) (*connect.Response[emptypb.Empty], error) {
	log := zerolog.Ctx(ctx)

	log.Info().Msg("attempting to unlock wallet")

	// Unencrypted wallets cannot be unlocked (they have no password)
	if !wallet.IsWalletEncrypted(s.walletDir) {
		log.Info().Msg("wallet is not encrypted, no unlock needed")
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("wallet is not encrypted"))
	}

	walletData, err := wallet.DecryptWallet(s.walletDir, c.Msg.Password)
	if err != nil {
		log.Warn().Err(err).Msg("failed to decrypt wallet")
		return nil, connect.NewError(connect.CodeUnauthenticated, fmt.Errorf("incorrect password"))
	}

	if err := s.walletEngine.Unlock(walletData); err != nil {
		log.Error().Err(err).Msg("failed to unlock cheque engine")
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to unlock cheque engine: %w", err))
	}

	// Sync wallets after unlock to ensure all wallets exist in their backends
	go func() {
		syncCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()

		if err := s.walletEngine.SyncWallets(syncCtx); err != nil {
			zerolog.Ctx(syncCtx).Warn().Err(err).Msg("wallet sync failed after unlock")
		}
	}()

	log.Info().Msg("wallet unlocked successfully for cheque operations")
	return connect.NewResponse(&emptypb.Empty{}), nil
}

// LockWallet implements walletv1connect.WalletServiceHandler.
func (s *Server) LockWallet(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[emptypb.Empty], error) {
	s.walletEngine.Lock()
	zerolog.Ctx(ctx).Info().Msg("wallet locked")
	return connect.NewResponse(&emptypb.Empty{}), nil
}

// IsWalletUnlocked implements walletv1connect.WalletServiceHandler.
func (s *Server) IsWalletUnlocked(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[emptypb.Empty], error) {
	if !s.walletEngine.IsUnlocked() {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("wallet is locked"))
	}
	return connect.NewResponse(&emptypb.Empty{}), nil
}

// CreateCheque implements walletv1connect.WalletServiceHandler.
func (s *Server) CreateCheque(ctx context.Context, c *connect.Request[pb.CreateChequeRequest]) (*connect.Response[pb.CreateChequeResponse], error) {
	log := zerolog.Ctx(ctx)

	walletId := c.Msg.WalletId

	// Wallet ID validation only - cheques work the same for all wallet types
	_, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	if !s.walletEngine.IsUnlocked() {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("wallet is locked"))
	}

	// Get next index for this wallet
	nextIndex, err := cheques.GetNextIndex(ctx, s.database, walletId)
	if err != nil {
		log.Error().Err(err).Msg("failed to get next cheque index")
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to get next index: %w", err))
	}

	// Derive address for this wallet
	address, err := s.chequeEngine.DeriveChequeAddress(walletId, nextIndex)
	if err != nil {
		log.Error().Err(err).Uint32("index", nextIndex).Msg("failed to derive cheque address")
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to derive address: %w", err))
	}

	// Save to DB with wallet ID
	id, err := cheques.Create(ctx, s.database, walletId, nextIndex, c.Msg.ExpectedAmountSats, address)
	if err != nil {
		log.Error().Err(err).Msg("failed to create cheque in database")
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to create cheque: %w", err))
	}

	log.Info().
		Int64("id", id).
		Uint32("index", nextIndex).
		Str("address", address).
		Uint64("expected_sats", c.Msg.ExpectedAmountSats).
		Msg("cheque created")

	return connect.NewResponse(&pb.CreateChequeResponse{
		Id:              id,
		Address:         address,
		DerivationIndex: nextIndex,
	}), nil
}

// GetCheque implements walletv1connect.WalletServiceHandler.
func (s *Server) GetCheque(ctx context.Context, c *connect.Request[pb.GetChequeRequest]) (*connect.Response[pb.GetChequeResponse], error) {
	walletId := c.Msg.WalletId

	// Wallet ID validation only - cheques work the same for all wallet types
	_, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	cheque, err := cheques.Get(ctx, s.database, walletId, c.Msg.Id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, connect.NewError(connect.CodeNotFound, errors.New("cheque not found"))
		}
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to get cheque: %w", err))
	}

	return connect.NewResponse(&pb.GetChequeResponse{
		Cheque: s.chequeToPb(cheque),
	}), nil
}

// GetChequePrivateKey implements walletv1connect.WalletServiceHandler.
func (s *Server) GetChequePrivateKey(ctx context.Context, c *connect.Request[pb.GetChequePrivateKeyRequest]) (*connect.Response[pb.GetChequePrivateKeyResponse], error) {
	log := zerolog.Ctx(ctx)

	walletId := c.Msg.WalletId

	// Wallet ID validation only - cheques work the same for all wallet types
	_, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	if !s.walletEngine.IsUnlocked() {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("wallet is locked"))
	}

	cheque, err := cheques.Get(ctx, s.database, walletId, c.Msg.Id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, connect.NewError(connect.CodeNotFound, errors.New("cheque not found"))
		}
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to get cheque: %w", err))
	}

	privateKeyWIF, err := s.chequeEngine.DeriveChequePrivateKey(walletId, cheque.DerivationIndex)
	if err != nil {
		log.Error().Err(err).Uint32("index", cheque.DerivationIndex).Msg("failed to derive private key")
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to derive private key: %w", err))
	}

	return connect.NewResponse(&pb.GetChequePrivateKeyResponse{
		PrivateKeyWif: privateKeyWIF,
	}), nil
}

// ListCheques implements walletv1connect.WalletServiceHandler.
func (s *Server) ListCheques(ctx context.Context, c *connect.Request[pb.ListChequesRequest]) (*connect.Response[pb.ListChequesResponse], error) {
	walletId := c.Msg.WalletId

	// Wallet ID validation only - cheques work the same for all wallet types
	_, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	chequeList, err := cheques.List(ctx, s.database, walletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to list cheques: %w", err))
	}

	pbCheques := make([]*pb.Cheque, len(chequeList))
	for i, ch := range chequeList {
		pbCheques[i] = s.chequeToPb(&ch)
	}

	return connect.NewResponse(&pb.ListChequesResponse{
		Cheques: pbCheques,
	}), nil
}

// CheckChequeFunding implements walletv1connect.WalletServiceHandler.
func (s *Server) CheckChequeFunding(ctx context.Context, c *connect.Request[pb.CheckChequeFundingRequest]) (*connect.Response[pb.CheckChequeFundingResponse], error) {
	log := zerolog.Ctx(ctx)

	walletId := c.Msg.WalletId

	// Wallet ID validation only - cheques work the same for all wallet types
	_, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	cheque, err := cheques.Get(ctx, s.database, walletId, c.Msg.Id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, connect.NewError(connect.CodeNotFound, errors.New("cheque not found"))
		}
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to get cheque: %w", err))
	}

	utxos, err := s.chequeChain.AddressUnspent(ctx, cheque.Address)
	if err != nil {
		log.Error().Err(err).Str("address", cheque.Address).Msg("failed to query UTXOs")
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("failed to query UTXOs: %w", err))
	}

	log.Debug().
		Str("address", cheque.Address).
		Int("utxo_count", len(utxos)).
		Msg("CheckChequeFunding: UTXOs found")

	if len(utxos) > 0 {
		var amountSats uint64
		var txids []string
		var minConfirmations uint32 = math.MaxUint32
		for _, utxo := range utxos {
			amountSats += uint64(utxo.ValueSats)
			txids = append(txids, utxo.TxID)
			if confs := uint32(utxo.Confirmations); confs < minConfirmations {
				minConfirmations = confs
			}
		}

		// Always update — handles new fundings arriving after first one
		if err := cheques.UpdateFunding(ctx, s.database, walletId, c.Msg.Id, txids, amountSats); err != nil {
			log.Error().Err(err).Msg("failed to update cheque funding")
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to update funding: %w", err))
		}

		log.Info().
			Int64("id", c.Msg.Id).
			Str("address", cheque.Address).
			Uint64("amount_sats", amountSats).
			Int("utxo_count", len(txids)).
			Msg("cheque funded")

		// Re-fetch to get updated funded_at timestamp
		cheque, err = cheques.Get(ctx, s.database, walletId, c.Msg.Id)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to refetch cheque: %w", err))
		}

		resp := &pb.CheckChequeFundingResponse{
			Funded:           cheque.IsFunded(),
			ActualAmountSats: amountSats,
			FundedTxids:      txids,
			MinConfirmations: minConfirmations,
		}
		if cheque.FundedAt != nil {
			resp.FundedAt = timestamppb.New(*cheque.FundedAt)
		}
		return connect.NewResponse(resp), nil
	}

	// No UTXOs found - if cheque was funded, it means it was swept
	if cheque.IsFunded() && cheque.SweptTxid == nil {
		log.Warn().
			Str("address", cheque.Address).
			Int64("id", c.Msg.Id).
			Msg("funded cheque has no UTXOs - was swept externally")

		// Mark as swept - we know it was swept but don't know the exact txid
		// Finding the spending tx from a watch-only wallet requires full blockchain scan
		if err := cheques.UpdateSwept(ctx, s.database, walletId, c.Msg.Id, "swept_externally"); err != nil {
			log.Error().Err(err).Msg("failed to mark cheque as externally swept")
		}
	}

	return connect.NewResponse(&pb.CheckChequeFundingResponse{
		Funded: false,
	}), nil
}

// PreviewSweep implements walletv1connect.WalletServiceHandler.
// Reports what a private key holds and what sweeping it would cost.
func (s *Server) PreviewSweep(ctx context.Context, c *connect.Request[pb.PreviewSweepRequest]) (*connect.Response[pb.PreviewSweepResponse], error) {
	wifKey, err := btcutil.DecodeWIF(c.Msg.PrivateKeyWif)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("invalid WIF: %w", err))
	}

	source, err := engines.ResolveSweepSource(ctx, s.chequeChain, wifKey, s.chequeEngine.GetChainParams())
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("failed to query UTXOs: %w", err))
	}

	feeSatPerVbyte, err := s.chequeSweepFeeRate(ctx, c.Msg.FeeSatPerVbyte)
	if err != nil {
		return nil, err
	}

	amountSats := source.TotalSats()
	feeSats := engines.SweepFeeSats(source, feeSatPerVbyte, engines.SweepOutputVbytes)

	var receiveSats uint64
	if amountSats > feeSats {
		receiveSats = amountSats - feeSats
	}

	return connect.NewResponse(&pb.PreviewSweepResponse{
		Address:        source.Address,
		AddressKind:    sweepAddressKindToPb(source.Kind),
		AmountSats:     amountSats,
		OutputCount:    uint32(len(source.UTXOs)),
		FeeSatPerVbyte: feeSatPerVbyte,
		FeeSats:        feeSats,
		ReceiveSats:    receiveSats,
	}), nil
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
func (s *Server) SweepCheque(ctx context.Context, c *connect.Request[pb.SweepChequeRequest]) (*connect.Response[pb.SweepChequeResponse], error) {
	log := zerolog.Ctx(ctx)

	walletId := c.Msg.WalletId

	// Wallet ID validation only - cheques work the same for all wallet types
	_, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	wifKey, err := btcutil.DecodeWIF(c.Msg.PrivateKeyWif)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("invalid WIF: %w", err))
	}

	params := s.chequeEngine.GetChainParams()

	source, err := engines.ResolveSweepSource(ctx, s.chequeChain, wifKey, params)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("failed to query UTXOs: %w", err))
	}
	if len(source.UTXOs) == 0 {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("no funds found at this address"))
	}

	addressStr := source.Address
	totalAmount := source.TotalSats()

	log.Debug().Str("address", addressStr).Str("kind", source.Kind.String()).Msg("SweepCheque: sweeping")

	feeSatPerVbyte, err := s.chequeSweepFeeRate(ctx, c.Msg.FeeSatPerVbyte)
	if err != nil {
		return nil, err
	}

	unsignedTx, err := engines.BuildSweepTx(source, c.Msg.DestinationAddress, feeSatPerVbyte, params)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("build transaction: %w", err))
	}

	signedTx, err := engines.SignSweepTx(unsignedTx, source, wifKey, params)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("sign transaction: %w", err))
	}

	txHex, err := s.serializeTx(signedTx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("serialize transaction: %w", err))
	}

	txid, err := s.chequeChain.Broadcast(ctx, txHex)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("broadcast transaction: %w", err))
	}

	// Try to find and mark the cheque as swept in database if it exists
	cheque, err := cheques.GetByAddress(ctx, s.database, walletId, addressStr)
	if err == nil && cheque.SweptTxid == nil {
		if err := cheques.UpdateSwept(ctx, s.database, walletId, cheque.ID, txid); err != nil {
			log.Warn().Err(err).Msg("failed to mark cheque as swept in database")
		}
	}

	log.Info().
		Str("from", addressStr).
		Str("to", c.Msg.DestinationAddress).
		Str("txid", txid).
		Uint64("amount_sats", totalAmount).
		Msg("cheque swept successfully")

	return connect.NewResponse(&pb.SweepChequeResponse{
		Txid:           txid,
		AmountSats:     totalAmount,
		FeeSatPerVbyte: feeSatPerVbyte,
	}), nil
}

// chequeSweepFeeRate resolves the sweep's fee rate: the caller's, or the
// 6-block estimate when they pass zero.
func (s *Server) chequeSweepFeeRate(ctx context.Context, requested uint64) (uint64, error) {
	if requested > 0 {
		return requested, nil
	}
	rate, err := s.chequeChain.FeeRateSatPerVByte(ctx, 6)
	if err != nil {
		return 0, connect.NewError(connect.CodeUnavailable, fmt.Errorf("estimate fee: %w", err))
	}
	return uint64(math.Ceil(rate)), nil
}

// DeleteCheque implements walletv1connect.WalletServiceHandler.
func (s *Server) DeleteCheque(ctx context.Context, c *connect.Request[pb.DeleteChequeRequest]) (*connect.Response[emptypb.Empty], error) {
	log := zerolog.Ctx(ctx)

	walletId := c.Msg.WalletId

	// Wallet ID validation only - cheques work the same for all wallet types
	_, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	// Check if cheque exists
	cheque, err := cheques.Get(ctx, s.database, walletId, c.Msg.Id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, connect.NewError(connect.CodeNotFound, errors.New("cheque not found"))
		}
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to get cheque: %w", err))
	}

	// Only allow deletion of unfunded or swept cheques
	// Any recorded incoming funds (full or partial) but not swept = still has money, can't delete
	if (cheque.IsFunded() || cheque.IsPartiallyFunded()) && cheque.SweptTxid == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("cannot delete funded cheque"))
	}

	// Delete the cheque
	err = cheques.Delete(ctx, s.database, walletId, c.Msg.Id)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to delete cheque: %w", err))
	}

	log.Info().
		Int64("id", c.Msg.Id).
		Str("address", cheque.Address).
		Msg("cheque deleted")

	return connect.NewResponse(&emptypb.Empty{}), nil
}

// Helper function to convert model Cheque to protobuf Cheque
func (s *Server) chequeToPb(c *cheques.Cheque) *pb.Cheque {
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

	// Only include private key if cheque is funded and wallet is unlocked
	if c.IsFunded() && s.walletEngine.IsUnlocked() {
		privateKeyWIF, err := s.chequeEngine.DeriveChequePrivateKey(c.WalletID, c.DerivationIndex)
		if err == nil {
			pbCheque.PrivateKeyWif = &privateKeyWIF
		}
	}

	return pbCheque
}

// serializeTx serializes a transaction to hex string
func (s *Server) serializeTx(tx *wire.MsgTx) (string, error) {
	var txBytes bytes.Buffer
	if err := tx.Serialize(&txBytes); err != nil {
		return "", fmt.Errorf("serialize transaction: %w", err)
	}
	return hex.EncodeToString(txBytes.Bytes()), nil
}

// SetUTXOMetadata implements walletv1connect.WalletServiceHandler.
func (s *Server) SetUTXOMetadata(ctx context.Context, c *connect.Request[pb.SetUTXOMetadataRequest]) (*connect.Response[emptypb.Empty], error) {
	if c.Msg.Outpoint == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("outpoint is required"))
	}

	var isFrozen *bool
	if c.Msg.IsFrozen != nil {
		isFrozen = c.Msg.IsFrozen
	}
	var label *string
	if c.Msg.Label != nil {
		label = c.Msg.Label
	}

	if err := utxometadata.Set(ctx, s.database, c.Msg.Outpoint, isFrozen, label); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to set UTXO metadata: %w", err))
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}

// GetUTXOMetadata implements walletv1connect.WalletServiceHandler.
func (s *Server) GetUTXOMetadata(ctx context.Context, c *connect.Request[pb.GetUTXOMetadataRequest]) (*connect.Response[pb.GetUTXOMetadataResponse], error) {
	metadata, err := utxometadata.Get(ctx, s.database, c.Msg.Outpoints)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to get UTXO metadata: %w", err))
	}

	result := make(map[string]*pb.UTXOMetadata)
	for outpoint, entry := range metadata {
		result[outpoint] = &pb.UTXOMetadata{
			Outpoint: entry.Outpoint,
			IsFrozen: entry.IsFrozen,
			Label:    entry.Label,
		}
	}

	return connect.NewResponse(&pb.GetUTXOMetadataResponse{
		Metadata: result,
	}), nil
}

// SetCoinSelectionStrategy implements walletv1connect.WalletServiceHandler.
func (s *Server) SetCoinSelectionStrategy(ctx context.Context, c *connect.Request[pb.SetCoinSelectionStrategyRequest]) (*connect.Response[emptypb.Empty], error) {
	strategyStr := strconv.Itoa(int(c.Msg.Strategy))
	if err := preferences.Set(ctx, s.database, preferences.KeyCoinSelectionStrategy, strategyStr); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to set coin selection strategy: %w", err))
	}
	return connect.NewResponse(&emptypb.Empty{}), nil
}

// GetCoinSelectionStrategy implements walletv1connect.WalletServiceHandler.
func (s *Server) GetCoinSelectionStrategy(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.GetCoinSelectionStrategyResponse], error) {
	value, err := preferences.Get(ctx, s.database, preferences.KeyCoinSelectionStrategy)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to get coin selection strategy: %w", err))
	}

	strategy := pb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_LARGEST_FIRST // default
	if value != "" {
		if parsed, err := strconv.Atoi(value); err == nil {
			strategy = pb.CoinSelectionStrategy(parsed)
		}
	}

	return connect.NewResponse(&pb.GetCoinSelectionStrategyResponse{
		Strategy: strategy,
	}), nil
}

// GetTransactionDetails implements walletv1connect.WalletServiceHandler.
// Returns enriched transaction details with resolved input values/addresses.
func (s *Server) GetTransactionDetails(ctx context.Context, c *connect.Request[pb.GetTransactionDetailsRequest]) (*connect.Response[pb.GetTransactionDetailsResponse], error) {
	txid := c.Msg.Txid
	if txid == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("txid required"))
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	// Fetch the raw transaction with prevout info
	rawTx, err := bitcoind.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
		Txid:      txid,
		Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_PREVOUT_INFO,
	}))
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("transaction not found: %w", err))
	}

	// Build enriched inputs by fetching referenced transactions
	var inputs []*pb.TransactionInput
	var totalInputSats int64

	for i, vin := range rawTx.Msg.Inputs {
		isCoinbase := vin.Coinbase != ""

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

		// For non-coinbase inputs, fetch the referenced transaction to get value/address
		if !isCoinbase && vin.Txid != "" {
			prevTx, err := bitcoind.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
				Txid:      vin.Txid,
				Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_PREVOUT_INFO,
			}))
			if err == nil && int(vin.Vout) < len(prevTx.Msg.Outputs) {
				prevOut := prevTx.Msg.Outputs[vin.Vout]
				input.ValueSats = int64(prevOut.Amount * 100_000_000)
				if prevOut.ScriptPubKey != nil {
					input.Address = prevOut.ScriptPubKey.Address
				}
				totalInputSats += input.ValueSats
			}
		}

		inputs = append(inputs, input)
	}

	// Build outputs
	var outputs []*pb.TransactionOutput
	var totalOutputSats int64

	for i, vout := range rawTx.Msg.Outputs {
		valueSats := int64(vout.Amount * 100_000_000)
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

	// Compute fee (inputs - outputs)
	feeSats := totalInputSats - totalOutputSats
	if feeSats < 0 {
		feeSats = 0 // Coinbase transactions have no inputs
	}

	var feeRate float64
	if rawTx.Msg.Vsize > 0 {
		feeRate = float64(feeSats) / float64(rawTx.Msg.Vsize)
	}

	// Get block time as unix timestamp
	var blockTime int64
	if rawTx.Msg.BlockTime != nil {
		blockTime = rawTx.Msg.BlockTime.AsTime().Unix()
	}

	// Get hex from the Tx field
	var hexStr string
	if rawTx.Msg.Tx != nil {
		hexStr = rawTx.Msg.Tx.Hex
	}

	return connect.NewResponse(&pb.GetTransactionDetailsResponse{
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
	}), nil
}

// GetUTXODistribution implements walletv1connect.WalletServiceHandler.
// Returns UTXO distribution data for chart visualization.
func (s *Server) GetUTXODistribution(ctx context.Context, c *connect.Request[pb.GetUTXODistributionRequest]) (*connect.Response[pb.GetUTXODistributionResponse], error) {
	walletId := c.Msg.WalletId

	maxBuckets := int(c.Msg.MaxBuckets)
	if maxBuckets <= 0 {
		maxBuckets = 6
	}

	// Reuse the existing ListUnspent logic to get UTXOs
	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("get wallet type: %w", err))
	}

	// Simple label getter since we don't need labels for distribution
	getLabel := func(addr string) string { return "" }

	var utxos []*pb.UnspentOutput
	switch walletType {
	case engines.WalletTypeElectrum:
		utxos, err = s.listUnspentElectrum(ctx, walletId, getLabel)
	case engines.WalletTypeBitcoinCore:
		utxos, err = s.listUnspentBitcoinCore(ctx, walletId, getLabel)
	default:
		err = fmt.Errorf("unknown wallet type: %s", walletType)
	}
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("list unspent: %w", err))
	}

	if len(utxos) == 0 {
		return connect.NewResponse(&pb.GetUTXODistributionResponse{
			Buckets: []*pb.UTXOBucket{},
		}), nil
	}

	// Find min and max UTXO values
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

	// Generate dynamic bucket ranges based on the wallet's actual UTXO distribution
	ranges := generateDynamicBuckets(minVal, maxVal, maxBuckets)

	// Initialize buckets for each range
	bucketData := make([]struct {
		valueSats int64
		count     int32
		outpoints []string
	}, len(ranges))

	// Categorize each UTXO into the appropriate bucket
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

	// Build response buckets, only including non-empty ones
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

	return connect.NewResponse(&pb.GetUTXODistributionResponse{
		Buckets: buckets,
	}), nil
}

// bucketRange defines a value range for UTXO distribution
type bucketRange struct {
	minSats uint64
	maxSats uint64
	label   string
}

// generateDynamicBuckets creates bucket ranges that adapt to the wallet's actual UTXO values
func generateDynamicBuckets(minVal, maxVal uint64, numBuckets int) []bucketRange {
	// Use predefined boundaries based on Bitcoin denominations
	// These are logarithmically spaced for good distribution
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

	// Find which boundaries are relevant for this wallet's range
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

	// Build the bucket ranges
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

	// Add final bucket for remaining values
	ranges = append(ranges, bucketRange{
		minSats: prevBoundary,
		maxSats: maxVal,
		label:   formatBucketRange(prevBoundary, maxVal),
	})

	return ranges
}

// formatBucketRange creates a human-readable label for a bucket range
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
			return fmt.Sprintf("%.5f", btc)
		}
	}

	// No unit: the ticker depends on the active network, which the client knows.
	return fmt.Sprintf("%s - %s", formatVal(minBTC), formatVal(maxBTC))
}

// BumpFee implements RBF (Replace-By-Fee) for unconfirmed transactions.
// Uses Bitcoin Core's bumpfee command with automatic fee estimation.
func (s *Server) BumpFee(ctx context.Context, c *connect.Request[pb.BumpFeeRequest]) (*connect.Response[pb.BumpFeeResponse], error) {
	log := zerolog.Ctx(ctx)
	txid := c.Msg.Txid

	if txid == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("txid required"))
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	// Get the list of loaded wallets to find one that owns this transaction
	listResp, err := s.data.ListWallets(ctx, &emptypb.Empty{})
	if err != nil {
		return nil, fmt.Errorf("list wallets: %w", err)
	}

	// Try each wallet until one successfully bumps the fee
	var bumpResp *connect.Response[corepb.BumpFeeResponse]
	for _, walletName := range listResp.Wallets {
		resp, err := bitcoind.BumpFee(ctx, connect.NewRequest(&corepb.BumpFeeRequest{
			Wallet: walletName,
			Txid:   txid,
		}))
		if err == nil {
			bumpResp = resp
			break
		}
	}

	if bumpResp == nil {
		return nil, fmt.Errorf("could not bump fee: transaction not found in any wallet")
	}

	log.Info().
		Str("old_txid", txid).
		Str("new_txid", bumpResp.Msg.Txid).
		Float64("original_fee", bumpResp.Msg.OriginalFee).
		Float64("new_fee", bumpResp.Msg.NewFee).
		Msg("RBF transaction broadcast via Core bumpfee")

	return connect.NewResponse(&pb.BumpFeeResponse{
		Txid:        bumpResp.Msg.Txid,
		OriginalFee: bumpResp.Msg.OriginalFee,
		NewFee:      bumpResp.Msg.NewFee,
	}), nil
}

// SelectCoins implements walletv1connect.WalletServiceHandler.
func (s *Server) SelectCoins(ctx context.Context, c *connect.Request[pb.SelectCoinsRequest]) (*connect.Response[pb.SelectCoinsResponse], error) {
	// Get all UTXOs for the wallet
	unspentResp, err := s.ListUnspent(ctx, connect.NewRequest(&pb.ListUnspentRequest{
		WalletId: c.Msg.WalletId,
	}))
	if err != nil {
		return nil, fmt.Errorf("list unspent: %w", err)
	}

	// Build frozen and required outpoints maps
	frozenOutpoints := make(map[string]bool)
	for _, outpoint := range c.Msg.FrozenOutpoints {
		frozenOutpoints[outpoint] = true
	}

	requiredOutpoints := make(map[string]bool)
	for _, outpoint := range c.Msg.RequiredOutpoints {
		requiredOutpoints[outpoint] = true
	}

	// Set defaults
	numOutputs := int(c.Msg.NumOutputs)
	if numOutputs <= 0 {
		numOutputs = 2
	}

	strategy := c.Msg.Strategy
	if strategy == pb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_UNSPECIFIED {
		strategy = pb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_LARGEST_FIRST
	}

	// Run coin selection
	result, err := engines.SelectCoins(
		unspentResp.Msg.Utxos,
		frozenOutpoints,
		c.Msg.TargetSats,
		c.Msg.FeeSatsPerVbyte,
		numOutputs,
		strategy,
		requiredOutpoints,
	)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	return connect.NewResponse(&pb.SelectCoinsResponse{
		SelectedUtxos:  result.SelectedUTXOs,
		TotalInputSats: result.TotalInputSats,
		FeeSats:        result.FeeSats,
		ChangeSats:     result.ChangeSats,
	}), nil
}

// CreateBackup implements walletv1connect.WalletServiceHandler.
func (s *Server) CreateBackup(ctx context.Context, _ *connect.Request[emptypb.Empty]) (*connect.Response[pb.CreateBackupResponse], error) {
	data, filename, err := s.backupEngine.CreateBackup(ctx)
	if err != nil {
		return nil, fmt.Errorf("create backup: %w", err)
	}

	return connect.NewResponse(&pb.CreateBackupResponse{
		BackupData:        data,
		SuggestedFilename: filename,
	}), nil
}

// RestoreBackup implements walletv1connect.WalletServiceHandler.
func (s *Server) RestoreBackup(ctx context.Context, c *connect.Request[pb.RestoreBackupRequest]) (*connect.Response[emptypb.Empty], error) {
	if len(c.Msg.BackupData) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("backup_data is required"))
	}
	if c.Msg.Filename == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("filename is required"))
	}

	if err := s.backupEngine.RestoreBackup(ctx, c.Msg.BackupData, c.Msg.Filename); err != nil {
		return nil, fmt.Errorf("restore backup: %w", err)
	}

	// Reboot the L1 stack so the enforcer picks up the restored wallet. On
	// first launch nothing is running yet, so this boots it from scratch; on a
	// live wallet it restarts. Owning this here means the frontend just calls
	// RestoreBackup — it doesn't hand-sequence binary stops/starts.
	if s.restartL1 != nil {
		if err := s.restartL1(ctx); err != nil {
			return nil, fmt.Errorf("restore backup: restart L1 stack: %w", err)
		}
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}

// ValidateBackup implements walletv1connect.WalletServiceHandler.
func (s *Server) ValidateBackup(ctx context.Context, c *connect.Request[pb.ValidateBackupRequest]) (*connect.Response[pb.ValidateBackupResponse], error) {
	if len(c.Msg.BackupData) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("backup_data is required"))
	}
	if c.Msg.Filename == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("filename is required"))
	}

	contents, err := s.backupEngine.ValidateBackup(ctx, c.Msg.BackupData, c.Msg.Filename)
	if err != nil {
		return connect.NewResponse(&pb.ValidateBackupResponse{
			Valid:        false,
			ErrorMessage: err.Error(),
		}), nil
	}

	return connect.NewResponse(&pb.ValidateBackupResponse{
		Valid:           true,
		HasWallet:       contents.HasWallet,
		HasMultisig:     contents.HasMultisig,
		HasTransactions: contents.HasTransactions,
	}), nil
}
