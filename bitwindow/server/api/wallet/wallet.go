package api_wallet

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"sort"
	"strconv"
	"strings"
	"time"

	"connectrpc.com/connect"
	drivechain "github.com/LayerTwo-Labs/sidesail/bitwindow/server/drivechain"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	bitwindowdv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	commonv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
	cryptov1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/crypto/v1"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/crypto/v1/cryptov1connect"
	validatorpb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/logpool"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/addressbook"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/preferences"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/transactions"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/utxometadata"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/wallet"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
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
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
	wallet *service.Service[validatorrpc.WalletServiceClient],
	crypto *service.Service[cryptorpc.CryptoServiceClient],
	chequeEngine *engines.ChequeEngine,
	walletEngine *engines.WalletEngine,
	walletDir string,
) *Server {
	s := &Server{
		database:     database,
		bitcoind:     bitcoind,
		wallet:       wallet,
		crypto:       crypto,
		chequeEngine: chequeEngine,
		walletEngine: walletEngine,
		walletDir:    walletDir,
	}

	// Initialize watch wallet in background
	go func() {
		// Use background context since this runs independently of startup
		bgCtx := context.Background()
		if err := s.ensureWatchWallet(bgCtx); err != nil {
			zerolog.Ctx(bgCtx).Warn().Err(err).Msg("failed to initialize watch wallet")
		}
	}()

	// Start background sync of Bitcoin Core addresses to addressbook
	go s.startAddressSyncLoop(ctx)

	return s
}

type Server struct {
	database     *sql.DB
	bitcoind     *service.Service[corerpc.BitcoinServiceClient]
	wallet       *service.Service[validatorrpc.WalletServiceClient]
	crypto       *service.Service[cryptorpc.CryptoServiceClient]
	chequeEngine *engines.ChequeEngine
	walletEngine *engines.WalletEngine
	walletDir    string
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
	if err := s.walletEngine.CreateBitcoinCoreWalletFromSeed(ctx, coreWalletName, seedHex); err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("create Bitcoin Core wallet failed")
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("create wallet: %w", err))
	}

	// Get first address for verification
	bitcoindClient, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("get bitcoind client: %w", err))
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
	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	if walletType == engines.WalletTypeEnforcer {
		// Route to enforcer
		if s.wallet == nil {
			return nil, errors.New("enforcer wallet not connected")
		}

		var feeRate *validatorpb.SendTransactionRequest_FeeRate
		if c.Msg.FeeSatPerVbyte != 0 {
			feeRate = &validatorpb.SendTransactionRequest_FeeRate{
				Fee: &validatorpb.SendTransactionRequest_FeeRate_SatPerVbyte{SatPerVbyte: c.Msg.FeeSatPerVbyte},
			}
		}
		if c.Msg.FixedFeeSats != 0 {
			feeRate = &validatorpb.SendTransactionRequest_FeeRate{
				Fee: &validatorpb.SendTransactionRequest_FeeRate_Sats{Sats: c.Msg.FixedFeeSats},
			}
		}

		var opReturnMessage *commonv1.Hex
		if c.Msg.OpReturnMessage != "" {
			opReturnMessage = &commonv1.Hex{
				Hex: &wrapperspb.StringValue{
					Value: hex.EncodeToString([]byte(c.Msg.OpReturnMessage)),
				},
			}
		}

		wallet, err := s.wallet.Get(ctx)
		if err != nil {
			return nil, err
		}

		created, err := wallet.SendTransaction(ctx, connect.NewRequest(&validatorpb.SendTransactionRequest{
			Destinations:    c.Msg.Destinations,
			FeeRate:         feeRate,
			OpReturnMessage: opReturnMessage,
			RequiredUtxos: lo.Map(c.Msg.RequiredInputs, func(u *pb.UnspentOutput, _ int) *validatorpb.SendTransactionRequest_RequiredUtxo {
				parts := strings.Split(u.Output, ":")
				if len(parts) != 2 {
					return nil
				}
				txid := parts[0]
				vout, err := strconv.ParseUint(parts[1], 10, 32)
				if err != nil {
					return nil
				}

				return &validatorpb.SendTransactionRequest_RequiredUtxo{
					Txid: &commonv1.ReverseHex{
						Hex: &wrapperspb.StringValue{Value: txid},
					},
					Vout: uint32(vout),
				}
			}),
		}))
		if err != nil {
			err = fmt.Errorf("enforcer/wallet: could not send transaction: %w", err)
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not send transaction")
			return nil, err
		}

		log.Info().Msgf("send tx: broadcast transaction (enforcer): %s", created.Msg.Txid)

		return connect.NewResponse(&pb.SendTransactionResponse{
			Txid: created.Msg.Txid.Hex.Value,
		}), nil
	}

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
		txid, err := s.sendWithRequiredInputs(ctx, bitcoind, coreWalletName, c.Msg.RequiredInputs, destinations)
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

// sendWithRequiredInputs creates and broadcasts a transaction using specific inputs.
// This is used when the caller wants to spend specific UTXOs.
func (s *Server) sendWithRequiredInputs(
	ctx context.Context,
	bitcoind corerpc.BitcoinServiceClient,
	walletName string,
	requiredInputs []*pb.UnspentOutput,
	destinations map[string]float64,
) (string, error) {
	log := zerolog.Ctx(ctx)

	// Build inputs for CreateRawTransaction
	inputs := make([]*corepb.CreateRawTransactionRequest_Input, 0, len(requiredInputs))
	for _, utxo := range requiredInputs {
		parts := strings.Split(utxo.Output, ":")
		if len(parts) != 2 {
			return "", fmt.Errorf("invalid UTXO format: %s", utxo.Output)
		}
		txid := parts[0]
		vout, err := strconv.ParseUint(parts[1], 10, 32)
		if err != nil {
			return "", fmt.Errorf("invalid vout in UTXO %s: %w", utxo.Output, err)
		}
		inputs = append(inputs, &corepb.CreateRawTransactionRequest_Input{
			Txid: txid,
			Vout: uint32(vout),
		})
	}

	// Create raw transaction
	createResp, err := bitcoind.CreateRawTransaction(ctx, connect.NewRequest(&corepb.CreateRawTransactionRequest{
		Inputs:  inputs,
		Outputs: destinations,
	}))
	if err != nil {
		return "", fmt.Errorf("create raw transaction: %w", err)
	}

	rawTxHex := createResp.Msg.Tx.Hex
	log.Debug().Msgf("created raw transaction: %s", rawTxHex)

	// Sign the transaction using signrawtransactionwithwallet
	signResp, err := bitcoind.SignRawTransactionWithWallet(ctx, connect.NewRequest(&corepb.SignRawTransactionWithWalletRequest{
		HexString: rawTxHex,
		Wallet:    walletName,
	}))
	if err != nil {
		return "", fmt.Errorf("sign transaction: %w", err)
	}

	if !signResp.Msg.Complete {
		return "", fmt.Errorf("transaction signing incomplete")
	}

	signedTxHex := signResp.Msg.Hex
	log.Debug().Msgf("signed transaction: %s", signedTxHex)

	// Broadcast the signed transaction
	sendResp, err := bitcoind.SendRawTransaction(ctx, connect.NewRequest(&corepb.SendRawTransactionRequest{
		HexString: signedTxHex,
	}))
	if err != nil {
		return "", fmt.Errorf("broadcast transaction: %w", err)
	}

	return sendResp.Msg.Txid, nil
}

// GetNewAddress implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) GetNewAddress(ctx context.Context, c *connect.Request[pb.GetNewAddressRequest]) (*connect.Response[pb.GetNewAddressResponse], error) {
	walletId := c.Msg.WalletId

	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	// For Bitcoin Core wallets, derive addresses and find the first unused one
	// This prevents address reuse and gaps in the derivation path
	if walletType == engines.WalletTypeBitcoinCore || walletType == engines.WalletTypeWatchOnly {
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
	case engines.WalletTypeEnforcer:
		// Enforcer path
		wallet, err := s.wallet.Get(ctx)
		if err != nil {
			return nil, err
		}
		resp, err := wallet.CreateNewAddress(ctx, connect.NewRequest(&validatorpb.CreateNewAddressRequest{}))
		if err != nil {
			err = fmt.Errorf("enforcer/wallet: could not create new address: %w", err)
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not create new address")
			return nil, err
		}
		address = resp.Msg.Address

	case engines.WalletTypeBitcoinCore:
		// Bitcoin Core path
		address, err = s.getBitcoinCoreAddress(ctx, walletId, s.walletEngine.GetBitcoinCoreWalletName)
		if err != nil {
			return nil, err
		}

	case engines.WalletTypeWatchOnly:
		// Watch-only wallet path
		address, err = s.getBitcoinCoreAddress(ctx, walletId, s.walletEngine.EnsureWatchOnlyWallet)
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

	seedHex := walletInfo.Master.SeedHex
	if seedHex == "" {
		return "", nil, fmt.Errorf("wallet has no seed")
	}

	// Decode seed
	seed, err := hex.DecodeString(seedHex)
	if err != nil {
		return "", nil, fmt.Errorf("decode seed: %w", err)
	}

	// Derive master key
	masterKey, err := hdkeychain.NewMaster(seed, s.walletEngine.GetChainParams())
	if err != nil {
		return "", nil, fmt.Errorf("derive master key: %w", err)
	}

	// Derive to BIP84 receiving path: m/84'/coinType'/0'/0
	chainParams := s.walletEngine.GetChainParams()
	coinType := uint32(0)
	if chainParams.Name != "mainnet" {
		coinType = 1
	}

	purpose, err := masterKey.Derive(hdkeychain.HardenedKeyStart + 84)
	if err != nil {
		return "", nil, fmt.Errorf("derive purpose: %w", err)
	}

	coin, err := purpose.Derive(hdkeychain.HardenedKeyStart + coinType)
	if err != nil {
		return "", nil, fmt.Errorf("derive coin: %w", err)
	}

	account, err := coin.Derive(hdkeychain.HardenedKeyStart + 0)
	if err != nil {
		return "", nil, fmt.Errorf("derive account: %w", err)
	}

	// Receiving addresses (external chain = 0)
	external, err := account.Derive(0)
	if err != nil {
		return "", nil, fmt.Errorf("derive external chain: %w", err)
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return "", nil, err
	}

	walletName, err := s.walletEngine.GetBitcoinCoreWalletName(ctx, walletId)
	if err != nil {
		return "", nil, fmt.Errorf("get wallet name: %w", err)
	}

	// Get all transactions once to avoid repeated RPC calls
	txResp, err := bitcoind.ListTransactions(ctx, connect.NewRequest(&corepb.ListTransactionsRequest{
		Wallet: walletName,
		Count:  1000, // Check recent transactions
	}))
	if err != nil {
		return "", nil, fmt.Errorf("list transactions: %w", err)
	}

	// Build a map of used addresses for fast lookup
	usedAddresses := make(map[string]bool)
	for _, tx := range txResp.Msg.Transactions {
		for _, detail := range tx.Details {
			usedAddresses[detail.Address] = true
		}
	}

	var derivedAddresses []DerivedAddress
	firstUnusedAddress := ""

	// Derive addresses and check usage
	// BIP44 gap limit is 20, but we'll check more to be safe
	for i := uint32(0); i < 100; i++ {
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
		if wallet.WalletType != engines.WalletTypeBitcoinCore && wallet.WalletType != engines.WalletTypeWatchOnly {
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
		Wallet: walletName,
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
	case engines.WalletTypeEnforcer:
		// Enforcer path
		wallet, err := s.wallet.Get(ctx)
		if err != nil {
			return nil, err
		}
		balance, err := wallet.GetBalance(ctx, connect.NewRequest(&validatorpb.GetBalanceRequest{}))
		if err != nil {
			return nil, fmt.Errorf("enforcer/wallet: could not get balance: %w", err)
		}

		return connect.NewResponse(&pb.GetBalanceResponse{
			ConfirmedSatoshi: balance.Msg.ConfirmedSats,
			PendingSatoshi:   balance.Msg.PendingSats,
		}), nil

	case engines.WalletTypeBitcoinCore:
		coreWalletName, err := s.walletEngine.GetBitcoinCoreWalletName(ctx, walletId)
		if err != nil {
			return nil, fmt.Errorf("get bitcoin core wallet: %w", err)
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

		confirmedSats := uint64(balancesResp.Msg.Mine.Trusted * 100_000_000)
		pendingSats := uint64(balancesResp.Msg.Mine.UntrustedPending * 100_000_000)

		return connect.NewResponse(&pb.GetBalanceResponse{
			ConfirmedSatoshi: confirmedSats,
			PendingSatoshi:   pendingSats,
		}), nil

	case engines.WalletTypeWatchOnly:
		watchWalletName, err := s.walletEngine.EnsureWatchOnlyWallet(ctx, walletId)
		if err != nil {
			return nil, fmt.Errorf("get watch-only wallet: %w", err)
		}

		bitcoindClient, err := s.bitcoind.Get(ctx)
		if err != nil {
			return nil, fmt.Errorf("get bitcoind client: %w", err)
		}

		balancesResp, err := bitcoindClient.GetBalances(ctx, connect.NewRequest(&corepb.GetBalancesRequest{
			Wallet: watchWalletName,
		}))
		if err != nil {
			return nil, fmt.Errorf("get balances from bitcoin core: %w", err)
		}

		confirmedSats := uint64(balancesResp.Msg.Watchonly.Trusted * 100_000_000)
		pendingSats := uint64(balancesResp.Msg.Watchonly.UntrustedPending * 100_000_000)

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

	if walletType == engines.WalletTypeEnforcer {
		// Enforcer path
		wallet, err := s.wallet.Get(ctx)
		if err != nil {
			return nil, err
		}

		txs, err := wallet.ListTransactions(ctx, connect.NewRequest(&validatorpb.ListTransactionsRequest{}))
		if err != nil {
			return nil, fmt.Errorf("enforcer/wallet: could not list transactions: %w", err)
		}

		// Fetch address book entries for label lookup
		addressBookEntries, err := addressbook.List(ctx, s.database)
		if err != nil {
			return nil, fmt.Errorf("enforcer/wallet: could not list addressbook: %w", err)
		}

		notes, err := transactions.List(ctx, s.database)
		if err != nil {
			return nil, fmt.Errorf("enforcer/wallet: could not list transactions: %w", err)
		}
		noteMap := make(map[string]string)
		for _, note := range notes {
			noteMap[note.TxID] = note.Note
		}

		// Use logpool to fetch info for all transaction info in parallel
		pool := logpool.NewWithResults[*pb.WalletTransaction](ctx, "wallet/ListTransactions")
		for _, tx := range txs.Msg.Transactions {
			txid := tx.Txid.Hex.Value
			// For sent transactions, try to extract the destination address from the outputs
			pool.Go(txid, func(ctx context.Context) (*pb.WalletTransaction, error) {
				note := noteMap[txid]

				var confirmation *pb.Confirmation
				if tx.ConfirmationInfo != nil {
					var timestamp *timestamppb.Timestamp
					if tx.ConfirmationInfo.Timestamp != nil {
						timestamp = &timestamppb.Timestamp{Seconds: tx.ConfirmationInfo.Timestamp.Seconds}
					}
					confirmation = &pb.Confirmation{
						Height:    tx.ConfirmationInfo.Height,
						Timestamp: timestamp,
					}
				}

				address, label, err := extractAddress(tx, addressBookEntries, s.chequeEngine.GetChainParams())
				if err != nil {
					return nil, fmt.Errorf("enforcer/wallet: could not extract address: %w", err)
				}

				return &pb.WalletTransaction{
					Txid:             tx.Txid.Hex.Value,
					FeeSats:          tx.FeeSats,
					ReceivedSatoshi:  tx.ReceivedSats,
					SentSatoshi:      tx.SentSats,
					Address:          address,
					AddressLabel:     label,
					Note:             note,
					ConfirmationTime: confirmation,
				}, nil
			})
		}

		transactionsWithInfo, err := pool.Wait(ctx)
		if err != nil {
			return nil, fmt.Errorf("enforcer/wallet: failed to fetch transaction info: %w", err)
		}

		res := &pb.ListTransactionsResponse{
			Transactions: transactionsWithInfo,
		}

		return connect.NewResponse(res), nil
	}

	// Bitcoin Core path
	coreWalletName, err := s.walletEngine.GetBitcoinCoreWalletName(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get Bitcoin Core wallet: %w", err)
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("get bitcoind client: %w", err)
	}

	txsResp, err := bitcoind.ListTransactions(ctx, connect.NewRequest(&corepb.ListTransactionsRequest{
		Wallet: coreWalletName,
		Count:  1000, // Get last 1000 transactions
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoin core list transactions: %w", err)
	}

	// Fetch address book and notes
	addressBookEntries, err := addressbook.List(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("list addressbook: %w", err)
	}

	notes, err := transactions.List(ctx, s.database)
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
	for _, tx := range txsResp.Msg.Transactions {
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

func extractAddress(tx *validatorpb.WalletTransaction, addressBookEntries []addressbook.Entry, chainParams *chaincfg.Params) (string, string, error) {
	matchAddressLabel := func(addr string) string {
		for _, entry := range addressBookEntries {
			if entry.Address == addr {
				return entry.Label
			}
		}
		return ""
	}

	if tx.RawTransaction == nil {
		// oh well then, never mind it!
		return "", "", nil
	}

	rawBytes, err := hex.DecodeString(tx.RawTransaction.Hex.Value)
	if err != nil {
		return "", "", fmt.Errorf("could not decode raw tx hex: %w", err)
	}
	decodedTx, err := btcutil.NewTxFromBytes(rawBytes)
	if err != nil {
		return "", "", fmt.Errorf("could not decode raw transaction: %w", err)
	}

	// Heuristic: for sent tx, use the first output that is not a change address (not in addressbook as receive)
	// for received tx, use the first output that is in the addressbook as receive
	var address string
	for _, txOut := range decodedTx.MsgTx().TxOut {
		_, addrs, _, err := txscript.ExtractPkScriptAddrs(txOut.PkScript, chainParams)
		if err == nil && len(addrs) > 0 {
			addr := addrs[0].EncodeAddress()
			// Try to find a matching addressbook entry
			label := matchAddressLabel(addr)
			// If this is a receive, prefer addressbook entries with receive direction or empty label
			if tx.ReceivedSats > 0 && label != "" {
				address = addr
				break
			}
			// If this is a send, prefer addresses not in the addressbook (likely external)
			if tx.SentSats > 0 && label == "" {
				address = addr
				break
			}
		}
	}
	// Fallback: just use the first output address if nothing else
	if address == "" && len(decodedTx.MsgTx().TxOut) > 0 {
		_, addrs, _, err := txscript.ExtractPkScriptAddrs(decodedTx.MsgTx().TxOut[0].PkScript, chainParams)
		if err == nil && len(addrs) > 0 {
			address = addrs[0].EncodeAddress()
		}
	}

	return address, matchAddressLabel(address), nil
}

// ListSidechainDeposits implements walletv1connect.WalletServiceHandler.
func (s *Server) ListSidechainDeposits(ctx context.Context, c *connect.Request[pb.ListSidechainDepositsRequest]) (*connect.Response[pb.ListSidechainDepositsResponse], error) {
	walletId := c.Msg.WalletId

	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	// Sidechain deposits only work with enforcer wallet
	if walletType != engines.WalletTypeEnforcer {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("sidechain operations only supported with enforcer wallet"))
	}

	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not get bitcoind: %w", err)
	}

	deposits, err := wallet.ListSidechainDepositTransactions(ctx, connect.NewRequest(&validatorpb.ListSidechainDepositTransactionsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not list sidechain deposits: %w", err)
	}

	// Fetch current height from bitcoind
	chainInfo, err := bitcoind.GetBlockchainInfo(ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not get block chain info: %w", err)
	}

	var response pb.ListSidechainDepositsResponse
	for _, tx := range deposits.Msg.Transactions {
		if c.Msg.Slot != 0 && tx.SidechainNumber.Value != uint32(c.Msg.Slot) {
			continue
		}

		response.Deposits = append(response.Deposits, &pb.ListSidechainDepositsResponse_SidechainDeposit{
			Txid:          tx.Tx.Txid.Hex.Value,
			Amount:        int64(tx.Tx.SentSats),
			Fee:           int64(tx.Tx.FeeSats),
			Confirmations: int32(chainInfo.Msg.Blocks - tx.Tx.ConfirmationInfo.Height),
		})
	}

	return connect.NewResponse(&response), nil
}

// CreateSidechainDeposit implements walletv1connect.WalletServiceHandler.
func (s *Server) CreateSidechainDeposit(ctx context.Context, c *connect.Request[pb.CreateSidechainDepositRequest]) (*connect.Response[pb.CreateSidechainDepositResponse], error) {
	walletId := c.Msg.WalletId

	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	// Sidechain deposits only work with enforcer wallet
	if walletType != engines.WalletTypeEnforcer {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("sidechain operations only supported with enforcer wallet"))
	}

	if s.wallet == nil {
		return nil, errors.New("wallet not connected")
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

	amount, err := btcutil.NewAmount(c.Msg.Amount)
	if err != nil || amount < 0 {
		return nil, fmt.Errorf("invalid amount, must be a BTC-amount greater than zero")
	}

	fee, err := btcutil.NewAmount(c.Msg.Fee)
	if err != nil || fee < 0 {
		return nil, fmt.Errorf("invalid fee, must be a BTC-amount greater than zero")
	}

	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	created, err := wallet.CreateDepositTransaction(ctx, connect.NewRequest(&validatorpb.CreateDepositTransactionRequest{
		SidechainId: &wrapperspb.UInt32Value{Value: uint32(*slot)},
		Address:     &wrapperspb.StringValue{Value: depositAddress},
		ValueSats:   &wrapperspb.UInt64Value{Value: uint64(amount)},
		FeeSats:     &wrapperspb.UInt64Value{Value: uint64(fee)},
	}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not create deposit transaction: %w", err)
	}

	zerolog.Ctx(ctx).Info().Msgf("create deposit tx: broadcast transaction: %s", created.Msg.Txid)

	return connect.NewResponse(&pb.CreateSidechainDepositResponse{
		Txid: created.Msg.Txid.Hex.Value,
	}), nil
}

// SignMessage implements walletv1connect.WalletServiceHandler.
func (s *Server) SignMessage(ctx context.Context, c *connect.Request[pb.SignMessageRequest]) (*connect.Response[pb.SignMessageResponse], error) {
	walletId := c.Msg.WalletId

	// Wallet ID validation only - signing works the same for both wallet types
	_, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, err
	}

	res, err := crypto.Secp256K1Sign(ctx, connect.NewRequest(&cryptov1.Secp256K1SignRequest{
		Message: &commonv1.Hex{
			Hex: &wrapperspb.StringValue{Value: c.Msg.Message},
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
	walletId := c.Msg.WalletId

	// Wallet ID validation only - verification works the same for both wallet types
	_, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	crypto, err := s.crypto.Get(ctx)
	if err != nil {
		return nil, err
	}

	res, err := crypto.Secp256K1Verify(ctx, connect.NewRequest(&cryptov1.Secp256K1VerifyRequest{
		Message: &commonv1.Hex{
			Hex: &wrapperspb.StringValue{Value: c.Msg.Message},
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
	if walletType == engines.WalletTypeEnforcer {
		utxos, err = s.listUnspentEnforcer(ctx, getLabel)
	} else {
		utxos, err = s.listUnspentBitcoinCore(ctx, walletId, getLabel)
	}
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&pb.ListUnspentResponse{Utxos: utxos}), nil
}

func (s *Server) listUnspentEnforcer(ctx context.Context, getLabel func(string) string) ([]*pb.UnspentOutput, error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}

	utxos, err := wallet.ListUnspentOutputs(ctx, connect.NewRequest(&validatorpb.ListUnspentOutputsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not list unspent outputs: %w", err)
	}

	denials, err := deniability.List(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not list denials: %w", err)
	}

	var utxosWithInfo []*pb.UnspentOutput
	for _, utxo := range utxos.Msg.Outputs {
		var receivedAt *timestamppb.Timestamp
		if utxo.UnconfirmedLastSeen != nil {
			receivedAt = utxo.UnconfirmedLastSeen
		} else if utxo.ConfirmedAtTime != nil {
			receivedAt = utxo.ConfirmedAtTime
		}

		utxosWithInfo = append(utxosWithInfo, &pb.UnspentOutput{
			Output:     fmt.Sprintf("%s:%d", utxo.Txid.Hex.Value, utxo.Vout),
			Address:    utxo.Address.Value,
			Label:      getLabel(utxo.Address.Value),
			ValueSats:  utxo.ValueSats,
			ReceivedAt: receivedAt,
			IsChange:   utxo.IsInternal,
			DenialInfo: s.addDenialInfo(utxo, denials),
		})
	}

	return utxosWithInfo, nil
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

	// Collect unique txids to fetch timestamps
	txidSet := make(map[string]struct{})
	for _, utxo := range resp.Msg.Unspent {
		txidSet[utxo.Txid] = struct{}{}
	}

	txTimestamps := make(map[string]*timestamppb.Timestamp)
	for txid := range txidSet {
		txResp, err := bitcoind.GetTransaction(ctx, connect.NewRequest(&corepb.GetTransactionRequest{
			Txid:   txid,
			Wallet: coreWalletName,
		}))
		if err != nil {
			zerolog.Ctx(ctx).Warn().Err(err).Str("txid", txid).Msg("failed to get transaction timestamp")
			continue
		}
		if txResp.Msg.TimeReceived != nil {
			txTimestamps[txid] = txResp.Msg.TimeReceived
		} else if txResp.Msg.Time != nil {
			txTimestamps[txid] = txResp.Msg.Time
		}
	}

	var utxosWithInfo []*pb.UnspentOutput
	for _, utxo := range resp.Msg.Unspent {
		valueSats := uint64(utxo.Amount * 100000000)

		utxosWithInfo = append(utxosWithInfo, &pb.UnspentOutput{
			Output:     fmt.Sprintf("%s:%d", utxo.Txid, utxo.Vout),
			Address:    utxo.Address,
			Label:      getLabel(utxo.Address),
			ValueSats:  valueSats,
			ReceivedAt: txTimestamps[utxo.Txid],
			IsChange:   false,
			DenialInfo: s.addDenialInfoForCore(utxo.Txid, int32(utxo.Vout), denials),
		})
	}

	return utxosWithInfo, nil
}

func (s *Server) addDenialInfo(utxo *validatorpb.ListUnspentOutputsResponse_Output, denials []deniability.Denial) *bitwindowdv1.DenialInfo {
	sort.Slice(denials, func(i, j int) bool {
		return denials[i].UpdatedAt.Before(denials[j].UpdatedAt)
	})

	denialInfo, found := lo.Find(denials, func(d deniability.Denial) bool {
		if d.TipTXID == utxo.Txid.Hex.Value && d.TipVout == int32(utxo.Vout) {
			// check directly for tip first
			return true
		}

		// then look through executions
		return lo.ContainsBy(d.ExecutedDenials, func(e deniability.ExecutedDenial) bool {
			return e.ToTxID == utxo.Txid.Hex.Value
		})
	})

	if !found {
		return nil
	}

	return s.denialToProto(utxo, denialInfo)
}

func (s *Server) denialToProto(utxo *validatorpb.ListUnspentOutputsResponse_Output, d deniability.Denial) *bitwindowdv1.DenialInfo {
	var cancelTime *timestamppb.Timestamp
	if d.CancelledAt != nil {
		cancelTime = timestamppb.New(*d.CancelledAt)
	}

	var pausedAt *timestamppb.Timestamp
	if d.PausedAt != nil {
		pausedAt = timestamppb.New(*d.PausedAt)
	}

	var nextExecutionTime *timestamppb.Timestamp
	isTip := d.TipTXID == utxo.Txid.Hex.Value && d.TipVout == int32(utxo.Vout)
	if d.NextExecution != nil && isTip {
		nextExecutionTime = timestamppb.New(*d.NextExecution)
	}

	sort.Slice(d.ExecutedDenials, func(i, j int) bool {
		return d.ExecutedDenials[i].CreatedAt.Before(d.ExecutedDenials[j].CreatedAt)
	})
	uniqueBeforeThisUTXO := lo.UniqBy(d.ExecutedDenials, func(e deniability.ExecutedDenial) string {
		return e.ToTxID
	})

	// Find the index of the current UTXO in the sorted list
	executionIndex := -1
	for i, e := range uniqueBeforeThisUTXO {
		if e.ToTxID == utxo.Txid.Hex.Value {
			executionIndex = i
			break
		}
	}

	// a utxo/denial match is change if the txid matches (has an execution), but the tip vout is not
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
		// hops completed == index of execution +1 (no execution == 0 hops completed)
		HopsCompleted: uint32(executionIndex) + 1,
		IsChange:      isChange,
	}
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

	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	if walletType != engines.WalletTypeEnforcer {
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

	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}

	utxos, err := wallet.ListUnspentOutputs(ctx, connect.NewRequest(&validatorpb.ListUnspentOutputsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not list unspent outputs: %w", err)
	}

	currentAddress, err := s.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{WalletId: walletId}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not get current address: %w", err)
	}

	// Fetch the addressbook entries once for label lookup
	addressBookEntries, err := addressbook.List(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not list addressbook: %w", err)
	}
	// Helper to find label for an address
	getLabel := func(addr string) string {
		for _, entry := range addressBookEntries {
			if entry.Address == addr {
				return entry.Label
			}
		}
		return ""
	}

	// Use a map[string]*pb.ListReceiveAddressesResponse_ReceiveAddress to accumulate results
	addressMap := make(map[string]*pb.ReceiveAddress)

	for _, utxo := range utxos.Msg.Outputs {

		utxoTimestamp := utxo.UnconfirmedLastSeen
		if utxoTimestamp == nil {
			utxoTimestamp = utxo.ConfirmedAtTime
		}

		var address string
		if utxo.Address != nil {
			address = utxo.Address.Value
		}
		if _, ok := addressMap[address]; !ok {

			addressMap[address] = &pb.ReceiveAddress{
				Address:    address,
				Label:      getLabel(address),
				IsChange:   utxo.IsInternal,
				LastUsedAt: utxoTimestamp,
			}
		}
		addressMap[address].CurrentBalanceSat += utxo.ValueSats
		if addressMap[address].LastUsedAt == nil {
			addressMap[address].LastUsedAt = utxoTimestamp
		} else if utxoTimestamp.AsTime().After(addressMap[address].LastUsedAt.AsTime()) {
			// the current utxo is more recent than the last used at time
			addressMap[address].LastUsedAt = utxoTimestamp
		}
	}

	var historicAddresses []*pb.ReceiveAddress
	for _, addr := range addressMap {
		historicAddresses = append(historicAddresses, addr)
	}
	// Append currentAddress to the end of the list
	historicAddresses = append(historicAddresses, &pb.ReceiveAddress{
		Address:           currentAddress.Msg.Address,
		Label:             getLabel(currentAddress.Msg.Address),
		IsChange:          false,
		CurrentBalanceSat: 0,
		LastUsedAt:        nil,
	})

	return connect.NewResponse(&pb.ListReceiveAddressesResponse{
		Addresses: historicAddresses,
	}), nil
}

// GetStats implements walletv1connect.WalletServiceHandler.
func (s *Server) GetStats(ctx context.Context, c *connect.Request[pb.GetStatsRequest]) (*connect.Response[pb.GetStatsResponse], error) {
	walletId := c.Msg.WalletId

	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, fmt.Errorf("get wallet type: %w", err)
	}

	if walletType != engines.WalletTypeEnforcer {
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

		// Count transactions since the start of the current month
		now := time.Now()
		currentYear, currentMonth, _ := now.Date()
		currentMonthStart := time.Date(currentYear, currentMonth, 1, 0, 0, 0, 0, now.Location())
		transactionCountSinceMonth := int64(0)
		for _, tx := range txs.Msg.Transactions {
			if tx.ConfirmationTime != nil && tx.ConfirmationTime.Timestamp != nil {
				t := tx.ConfirmationTime.Timestamp.AsTime()
				if t.After(currentMonthStart) || t.Equal(currentMonthStart) {
					transactionCountSinceMonth++
				}
			}
		}

		// Bitcoin Core wallets don't track sidechain deposits separately
		return connect.NewResponse(&pb.GetStatsResponse{
			UtxosCurrent:                      utxoCount,
			UtxosUniqueAddresses:              uniqueAddressCount,
			SidechainDepositVolume:            0,
			SidechainDepositVolumeLast_30Days: 0,
			TransactionCountTotal:             transactionCount,
			TransactionCountSinceMonth:        transactionCountSinceMonth,
		}), nil
	}

	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}

	// 1. Get all UTXOs and count them
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

	// 2. Get all wallet transactions and count them
	txs, err := wallet.ListTransactions(ctx, connect.NewRequest(&validatorpb.ListTransactionsRequest{}))
	if err != nil {
		return nil, err
	}
	transactionCount := int64(len(txs.Msg.Transactions))

	// Count transactions since the start of the current month
	now := time.Now()
	currentYear, currentMonth, _ := now.Date()
	currentMonthStart := time.Date(currentYear, currentMonth, 1, 0, 0, 0, 0, now.Location())
	transactionCountSinceMonth := int64(0)
	for _, tx := range txs.Msg.Transactions {
		if tx.ConfirmationInfo.Timestamp != nil {
			t := tx.ConfirmationInfo.Timestamp.AsTime()
			if t.After(currentMonthStart) || t.Equal(currentMonthStart) {
				transactionCountSinceMonth++
			}
		}
	}

	// 3. Get all sidechain deposit transactions and sum their amounts
	sidechainDeposits, err := wallet.ListSidechainDepositTransactions(ctx, connect.NewRequest(&validatorpb.ListSidechainDepositTransactionsRequest{}))
	if err != nil {
		return nil, err
	}
	var depositSum int64
	var depositSumLast30Days int64
	// Calculate 30 days ago from now
	thirtyDaysAgo := now.AddDate(0, 0, -30)
	for _, dep := range sidechainDeposits.Msg.Transactions {
		if dep.Tx != nil {
			amt := int64(dep.Tx.SentSats)
			depositSum += amt
			if dep.Tx.ConfirmationInfo.Timestamp != nil {
				t := dep.Tx.ConfirmationInfo.Timestamp.AsTime()
				if t.After(thirtyDaysAgo) {
					depositSumLast30Days += amt
				}
			}
		}
	}

	return connect.NewResponse(&pb.GetStatsResponse{
		UtxosCurrent:                      utxoCount,
		UtxosUniqueAddresses:              uniqueAddressCount,
		SidechainDepositVolume:            depositSum,
		SidechainDepositVolumeLast_30Days: depositSumLast30Days,
		TransactionCountTotal:             transactionCount,
		TransactionCountSinceMonth:        transactionCountSinceMonth,
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
		if err == sql.ErrNoRows {
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
		if err == sql.ErrNoRows {
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
		if err == sql.ErrNoRows {
			return nil, connect.NewError(connect.CodeNotFound, errors.New("cheque not found"))
		}
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to get cheque: %w", err))
	}

	// Ensure the watch wallet exists before querying
	if err := s.ensureWatchWallet(ctx); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("ensure watch wallet: %w", err))
	}

	// Query bitcoind for UTXOs on address using the watch wallet
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("bitcoind not available: %w", err))
	}

	log.Debug().
		Str("address", cheque.Address).
		Str("wallet", engines.ChequeWalletName).
		Msg("CheckChequeFunding: querying UTXOs")

	utxos, err := bitcoind.ListUnspent(ctx, connect.NewRequest(&corepb.ListUnspentRequest{
		MinimumConfirmations: lo.ToPtr(uint32(0)), // Include unconfirmed
		Addresses:            []string{cheque.Address},
		Wallet:               engines.ChequeWalletName,
	}))
	if err != nil {
		log.Error().Err(err).Str("address", cheque.Address).Msg("failed to query UTXOs")
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to query UTXOs: %w", err))
	}

	log.Debug().
		Str("address", cheque.Address).
		Int("utxo_count", len(utxos.Msg.Unspent)).
		Msg("CheckChequeFunding: UTXOs found")

	if len(utxos.Msg.Unspent) > 0 {
		// Calculate total amount
		var totalAmount float64
		var txid string
		for _, utxo := range utxos.Msg.Unspent {
			totalAmount += utxo.Amount
			txid = utxo.Txid
		}

		// Convert BTC to satoshis
		amountSats := uint64(totalAmount * 100000000)

		// Update DB if not already funded
		if cheque.FundedTxid == nil {
			if err := cheques.UpdateFunding(ctx, s.database, walletId, c.Msg.Id, txid, amountSats); err != nil {
				log.Error().Err(err).Msg("failed to update cheque funding")
				return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to update funding: %w", err))
			}

			log.Info().
				Int64("id", c.Msg.Id).
				Str("address", cheque.Address).
				Uint64("amount_sats", amountSats).
				Str("txid", txid).
				Msg("cheque funded")

			// Re-fetch to get updated funded_at timestamp
			cheque, err = cheques.Get(ctx, s.database, walletId, c.Msg.Id)
			if err != nil {
				return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to refetch cheque: %w", err))
			}
		}

		resp := &pb.CheckChequeFundingResponse{
			Funded:           true,
			ActualAmountSats: amountSats,
			FundedTxid:       txid,
		}
		if cheque.FundedAt != nil {
			resp.FundedAt = timestamppb.New(*cheque.FundedAt)
		}
		return connect.NewResponse(resp), nil
	}

	// No UTXOs found - if cheque was funded, it means it was swept
	if cheque.FundedTxid != nil && cheque.SweptTxid == nil {
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

	// Decode the WIF
	wifKey, err := btcutil.DecodeWIF(c.Msg.PrivateKeyWif)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("invalid WIF: %w", err))
	}

	// Derive address from the private key
	pubKey := wifKey.PrivKey.PubKey()
	pubKeyHash := btcutil.Hash160(pubKey.SerializeCompressed())
	address, err := btcutil.NewAddressWitnessPubKeyHash(pubKeyHash, s.chequeEngine.GetChainParams())
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("create address: %w", err))
	}

	addressStr := address.EncodeAddress()

	// Get bitcoind client
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("bitcoind not available: %w", err))
	}

	// Query UTXOs for this address
	log.Debug().
		Str("address", addressStr).
		Str("wallet", engines.ChequeWalletName).
		Msg("SweepCheque: querying UTXOs")

	utxos, err := bitcoind.ListUnspent(ctx, connect.NewRequest(&corepb.ListUnspentRequest{
		MinimumConfirmations: lo.ToPtr(uint32(0)), // Include unconfirmed
		Addresses:            []string{addressStr},
		Wallet:               engines.ChequeWalletName,
	}))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to query UTXOs: %w", err))
	}

	if len(utxos.Msg.Unspent) == 0 {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("no funds found at this address"))
	}

	// Calculate total amount in satoshis
	totalAmountBTC := lo.SumBy(utxos.Msg.Unspent, func(utxo *corepb.UnspentOutput) float64 {
		return utxo.Amount
	})
	totalAmount := uint64(totalAmountBTC * 1e8)

	// Set fee rate
	feeSatPerVbyte := c.Msg.FeeSatPerVbyte
	if feeSatPerVbyte == 0 {
		feeSatPerVbyte = 2
	}

	unsignedTx, err := s.buildSweepTx(c.Msg.DestinationAddress, utxos.Msg.Unspent, feeSatPerVbyte)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("build transaction: %w", err))
	}

	signedTx, err := s.signSweepTx(unsignedTx, c.Msg.PrivateKeyWif, addressStr, utxos.Msg.Unspent)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("sign transaction: %w", err))
	}

	txHex, err := s.serializeTx(signedTx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("serialize transaction: %w", err))
	}

	res, err := bitcoind.SendRawTransaction(ctx, &connect.Request[corepb.SendRawTransactionRequest]{
		Msg: &corepb.SendRawTransactionRequest{
			HexString: txHex,
		},
	})
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("broadcast transaction: %w", err))
	}

	// Try to find and mark the cheque as swept in database if it exists
	cheque, err := cheques.GetByAddress(ctx, s.database, walletId, addressStr)
	if err == nil && cheque.SweptTxid == nil {
		if err := cheques.UpdateSwept(ctx, s.database, walletId, cheque.ID, res.Msg.Txid); err != nil {
			log.Warn().Err(err).Msg("failed to mark cheque as swept in database")
		}
	}

	log.Info().
		Str("from", addressStr).
		Str("to", c.Msg.DestinationAddress).
		Str("txid", res.Msg.Txid).
		Uint64("amount_sats", totalAmount).
		Msg("cheque swept successfully")

	return connect.NewResponse(&pb.SweepChequeResponse{
		Txid:       res.Msg.Txid,
		AmountSats: totalAmount,
	}), nil
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
		if err == sql.ErrNoRows {
			return nil, connect.NewError(connect.CodeNotFound, errors.New("cheque not found"))
		}
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to get cheque: %w", err))
	}

	// Only allow deletion of unfunded or swept cheques
	// Funded but not swept = still has money, can't delete
	if cheque.FundedTxid != nil && cheque.SweptTxid == nil {
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
		Funded:             c.FundedTxid != nil,
		CreatedAt:          timestamppb.New(c.CreatedAt),
	}

	if c.FundedTxid != nil {
		pbCheque.FundedTxid = c.FundedTxid
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
	if c.FundedTxid != nil && s.walletEngine.IsUnlocked() {
		privateKeyWIF, err := s.chequeEngine.DeriveChequePrivateKey(c.WalletID, c.DerivationIndex)
		if err == nil {
			pbCheque.PrivateKeyWif = &privateKeyWIF
		}
	}

	return pbCheque
}

// buildSweepTx builds an unsigned transaction to sweep cheque funds
func (s *Server) buildSweepTx(
	destAddress string,
	utxos []*corepb.UnspentOutput,
	feeSatPerVbyte uint64,
) (*wire.MsgTx, error) {
	// Calculate total amount in satoshis
	var totalSats uint64
	for _, utxo := range utxos {
		totalSats += uint64(utxo.Amount * 1e8)
	}

	// Estimate transaction size (P2WPKH input is ~68 vbytes, P2WPKH output is ~31 vbytes, overhead ~11 vbytes)
	estimatedVbytes := uint64(len(utxos)*68 + 31 + 11)
	feeSats := estimatedVbytes * feeSatPerVbyte

	// Check if we have enough to cover the fee
	if totalSats <= feeSats {
		return nil, fmt.Errorf("insufficient funds: total %d sats, fee %d sats", totalSats, feeSats)
	}

	// Parse destination address
	destAddr, err := btcutil.DecodeAddress(destAddress, s.chequeEngine.GetChainParams())
	if err != nil {
		return nil, fmt.Errorf("decode destination address: %w", err)
	}

	// Create new transaction
	tx := wire.NewMsgTx(wire.TxVersion)

	// Add inputs from UTXOs
	for _, utxo := range utxos {
		txHash, err := chainhash.NewHashFromStr(utxo.Txid)
		if err != nil {
			return nil, fmt.Errorf("parse txid: %w", err)
		}

		outPoint := wire.NewOutPoint(txHash, utxo.Vout)
		txIn := wire.NewTxIn(outPoint, nil, nil)
		tx.AddTxIn(txIn)
	}

	// Add output (total minus fees)
	pkScript, err := txscript.PayToAddrScript(destAddr)
	if err != nil {
		return nil, fmt.Errorf("create output script: %w", err)
	}

	outputSats := totalSats - feeSats
	txOut := wire.NewTxOut(int64(outputSats), pkScript)
	tx.AddTxOut(txOut)

	return tx, nil
}

// signSweepTx signs a sweep transaction with the provided WIF key
func (s *Server) signSweepTx(
	tx *wire.MsgTx,
	wifKey string,
	sourceAddress string,
	utxos []*corepb.UnspentOutput,
) (*wire.MsgTx, error) {
	// Decode WIF private key
	wif, err := btcutil.DecodeWIF(wifKey)
	if err != nil {
		return nil, fmt.Errorf("decode WIF: %w", err)
	}

	// Parse source address to get pubkey script
	sourceAddr, err := btcutil.DecodeAddress(sourceAddress, s.chequeEngine.GetChainParams())
	if err != nil {
		return nil, fmt.Errorf("decode source address: %w", err)
	}

	sourcePkScript, err := txscript.PayToAddrScript(sourceAddr)
	if err != nil {
		return nil, fmt.Errorf("create source script: %w", err)
	}

	// Sign each input
	for i, utxo := range utxos {
		// For P2WPKH, we need to sign using witness v0
		witnessScript, err := txscript.WitnessSignature(
			tx, txscript.NewTxSigHashes(tx, txscript.NewCannedPrevOutputFetcher(
				sourcePkScript,
				int64(utxo.Amount*1e8),
			)),
			i,
			int64(utxo.Amount*1e8),
			sourcePkScript,
			txscript.SigHashAll,
			wif.PrivKey,
			true, // compress pubkey
		)
		if err != nil {
			return nil, fmt.Errorf("create witness signature for input %d: %w", i, err)
		}

		tx.TxIn[i].Witness = witnessScript
	}

	return tx, nil
}

// serializeTx serializes a transaction to hex string
func (s *Server) serializeTx(tx *wire.MsgTx) (string, error) {
	var txBytes bytes.Buffer
	if err := tx.Serialize(&txBytes); err != nil {
		return "", fmt.Errorf("serialize transaction: %w", err)
	}
	return hex.EncodeToString(txBytes.Bytes()), nil
}

// ensureWatchWallet ensures the watch-only wallet exists
func (s *Server) ensureWatchWallet(ctx context.Context) error {
	log := zerolog.Ctx(ctx)

	// Debug: Check if context is already canceled
	if ctx.Err() != nil {
		log.Error().Err(ctx.Err()).Msg("ensureWatchWallet called with canceled context!")
		return fmt.Errorf("context already canceled: %w", ctx.Err())
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return fmt.Errorf("bitcoind not available: %w", err)
	}

	// Check if wallet already exists by listing wallets
	wallets, err := bitcoind.ListWallets(ctx, connect.NewRequest(&emptypb.Empty{}))
	if err != nil {
		return fmt.Errorf("failed to list wallets: %w", err)
	}

	walletExists := lo.Contains(wallets.Msg.Wallets, engines.ChequeWalletName)

	// Create or load wallet if it doesn't exist in memory
	if !walletExists {
		log.Info().Msg("creating cheque wallet (watch-only)")

		// Debug: Check context again before CreateWallet
		if ctx.Err() != nil {
			log.Error().Err(ctx.Err()).Msg("context canceled before CreateWallet!")
			return fmt.Errorf("context canceled before CreateWallet: %w", ctx.Err())
		}

		_, err = bitcoind.CreateWallet(ctx, connect.NewRequest(&corepb.CreateWalletRequest{
			Name:               engines.ChequeWalletName,
			DisablePrivateKeys: true, // Watch-only wallet
			Blank:              true,
		}))
		if err != nil {
			log.Warn().Err(err).Msg("CreateWallet returned error")
			// If wallet exists on disk but not loaded, try loading it
			if strings.Contains(err.Error(), "already exists") || strings.Contains(err.Error(), "Database already exists") {
				log.Info().Msg("cheque wallet exists on disk, loading it")
				_, loadErr := bitcoind.LoadWallet(ctx, connect.NewRequest(&corepb.LoadWalletRequest{
					Filename: engines.ChequeWalletName,
				}))
				if loadErr != nil {
					log.Error().Err(loadErr).Msg("Failed to load existing cheque wallet")
					return fmt.Errorf("load cheque wallet: %w", loadErr)
				}
				log.Info().Msg("cheque wallet loaded successfully")
			} else {
				log.Error().Err(err).Msg("Failed to create cheque wallet with unexpected error")
				return fmt.Errorf("create cheque wallet: %w", err)
			}
		} else {
			log.Info().Msg("cheque wallet created successfully")
		}
	}

	return nil
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
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("get bitcoind client: %w", err))
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
		maxBuckets = 10
	}

	// Reuse the existing ListUnspent logic to get UTXOs
	walletType, err := s.walletEngine.GetWalletBackendType(ctx, walletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("get wallet type: %w", err))
	}

	// Simple label getter since we don't need labels for distribution
	getLabel := func(addr string) string { return "" }

	var utxos []*pb.UnspentOutput
	if walletType == engines.WalletTypeEnforcer {
		utxos, err = s.listUnspentEnforcer(ctx, getLabel)
	} else {
		utxos, err = s.listUnspentBitcoinCore(ctx, walletId, getLabel)
	}
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("list unspent: %w", err))
	}

	if len(utxos) == 0 {
		return connect.NewResponse(&pb.GetUTXODistributionResponse{
			Buckets: []*pb.UTXOBucket{},
		}), nil
	}

	// Sort UTXOs by value descending
	sort.Slice(utxos, func(i, j int) bool {
		return utxos[i].ValueSats > utxos[j].ValueSats
	})

	// Build buckets: top N individual UTXOs, rest aggregated into "Other"
	var buckets []*pb.UTXOBucket

	// First pass: count how many times each value appears in top N
	valueCounts := make(map[uint64]int)
	for i, utxo := range utxos {
		if i >= maxBuckets {
			break
		}
		valueCounts[utxo.ValueSats]++
	}

	// Second pass: build buckets, adding txid to duplicates
	for i, utxo := range utxos {
		if i < maxBuckets {
			label := formatSatsForChart(utxo.ValueSats)

			// If this value appears more than once, add short txid to differentiate
			if valueCounts[utxo.ValueSats] > 1 {
				// Extract short txid from output (format: txid:vout)
				parts := strings.Split(utxo.Output, ":")
				if len(parts) > 0 && len(parts[0]) >= 8 {
					label = fmt.Sprintf("%s (%s..)", label, parts[0][:8])
				}
			}

			// Individual bucket for top UTXOs
			buckets = append(buckets, &pb.UTXOBucket{
				Label:     label,
				ValueSats: int64(utxo.ValueSats),
				Count:     1,
				Outpoints: []string{utxo.Output},
			})
		} else {
			// Aggregate rest into "Other" bucket
			if len(buckets) == maxBuckets {
				buckets = append(buckets, &pb.UTXOBucket{
					Label:     "Other",
					ValueSats: 0,
					Count:     0,
					Outpoints: []string{},
				})
			}
			other := buckets[maxBuckets]
			other.ValueSats += int64(utxo.ValueSats)
			other.Count++
			other.Outpoints = append(other.Outpoints, utxo.Output)
		}
	}

	// Update "Other" label with count
	if len(buckets) > maxBuckets {
		buckets[maxBuckets].Label = fmt.Sprintf("Other (%d)", buckets[maxBuckets].Count)
	}

	return connect.NewResponse(&pb.GetUTXODistributionResponse{
		Buckets: buckets,
	}), nil
}

// formatSatsForChart formats satoshis for chart display
func formatSatsForChart(sats uint64) string {
	btc := float64(sats) / 100_000_000
	if btc >= 1 {
		return fmt.Sprintf("%.2f BTC", btc)
	} else if btc >= 0.001 {
		return fmt.Sprintf("%.4f BTC", btc)
	} else if btc >= 0.00001 {
		return fmt.Sprintf("%.6f BTC", btc)
	}
	return fmt.Sprintf("%d sats", sats)
}
