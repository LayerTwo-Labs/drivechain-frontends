package api_wallet

import (
	"context"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"connectrpc.com/connect"
	drivechain "github.com/LayerTwo-Labs/sidesail/bitwindow/server/drivechain"
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
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/rs/zerolog"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

var _ rpc.WalletServiceHandler = new(Server)

// New creates a new Server and starts the balance update loop
func New(
	ctx context.Context,
	database *sql.DB,
	bitcoind *service.Service[*coreproxy.Bitcoind],
	wallet *service.Service[validatorrpc.WalletServiceClient],
	crypto *service.Service[cryptorpc.CryptoServiceClient],
) *Server {
	s := &Server{
		database: database,
		bitcoind: bitcoind,
		wallet:   wallet,
		crypto:   crypto,
	}
	return s
}

type Server struct {
	database *sql.DB
	bitcoind *service.Service[*coreproxy.Bitcoind]
	wallet   *service.Service[validatorrpc.WalletServiceClient]
	crypto   *service.Service[cryptorpc.CryptoServiceClient]
}

// SendTransaction implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) SendTransaction(ctx context.Context, c *connect.Request[pb.SendTransactionRequest]) (*connect.Response[pb.SendTransactionResponse], error) {
	if s.wallet == nil {
		return nil, errors.New("wallet not connected")
	}

	if c.Msg.Destination == "" {
		err := errors.New("must provide a destination")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if c.Msg.FeeRate < 0 {
		err := errors.New("fee rate cannot be negative")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	const dustLimit = 546
	if c.Msg.Amount < dustLimit {
		err := fmt.Errorf(
			"amount to %s is below dust limit (%s): %s",
			c.Msg.Destination, btcutil.Amount(dustLimit), btcutil.Amount(c.Msg.Amount),
		)
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	log := zerolog.Ctx(ctx)

	destinations := make(map[string]uint64)
	destinations[c.Msg.Destination] = c.Msg.Amount

	var feeRate *validatorpb.SendTransactionRequest_FeeRate
	if c.Msg.FeeRate != 0 {
		btcPerByte, err := btcutil.NewAmount(c.Msg.FeeRate / 1000)
		if err != nil {
			return nil, err
		}
		satoshiPerVByte := uint64(btcPerByte.ToUnit(btcutil.AmountSatoshi))
		feeRate = &validatorpb.SendTransactionRequest_FeeRate{
			Fee: &validatorpb.SendTransactionRequest_FeeRate_SatPerVbyte{SatPerVbyte: satoshiPerVByte},
		}
	}

	// Add OP_RETURN message if provided
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
		Destinations:    destinations,
		FeeRate:         feeRate,
		OpReturnMessage: opReturnMessage,
	}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not send transaction: %w", err)
	}

	if c.Msg.Label != "" {
		direction, err := addressbook.DirectionFromProto(bitwindowdv1.Direction_DIRECTION_SEND)
		if err != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, err)
		}

		err = addressbook.Create(ctx, s.database, c.Msg.Label, c.Msg.Destination, direction)
		if err != nil {
			if err.Error() == addressbook.ErrUniqueAddress {
				// that's fine! Don't do anything
			} else {
				return nil, fmt.Errorf("could not create address book entry: %w", err)
			}
		}
	}

	log.Info().Msgf("send tx: broadcast transaction: %s", created.Msg.Txid)

	return connect.NewResponse(&pb.SendTransactionResponse{
		Txid: created.Msg.Txid.Hex.Value,
	}), nil
}

// GetNewAddress implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) GetNewAddress(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.GetNewAddressResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	address, err := wallet.CreateNewAddress(ctx, connect.NewRequest(&validatorpb.CreateNewAddressRequest{}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not create new address: %w", err)
	}

	// store all receiving addresses in the book! But with an empty label
	err = addressbook.Create(ctx, s.database, "", address.Msg.Address, addressbook.DirectionReceive)
	if err != nil {
		if err.Error() == addressbook.ErrUniqueAddress {
			// that's fine, already added! Don't do anything
		} else {
			return nil, fmt.Errorf("could not create address book entry: %w", err)
		}
	}

	return connect.NewResponse(&pb.GetNewAddressResponse{
		Address: address.Msg.Address,
	}), nil
}

// GetBalance implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) GetBalance(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.GetBalanceResponse], error) {
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
}

// ListTransactions implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListTransactions(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.ListTransactionsResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not get bitcoind: %w", err)
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
	getLabel := func(addr string) string {
		for _, entry := range addressBookEntries {
			if entry.Address == addr {
				return entry.Label
			}
		}
		return ""
	}

	// Use logpool to fetch info for all transaction info in parallel
	pool := logpool.NewWithResults[*pb.WalletTransaction](ctx, "wallet/ListTransactions")
	for _, tx := range txs.Msg.Transactions {
		txid := tx.Txid.Hex.Value
		// For sent transactions, try to extract the destination address from the outputs
		pool.Go(txid, func(ctx context.Context) (*pb.WalletTransaction, error) {
			rawTxResp, err := bitcoind.GetRawTransaction(ctx, &connect.Request[corepb.GetRawTransactionRequest]{
				Msg: &corepb.GetRawTransactionRequest{
					Txid: txid,
				},
			})
			if err != nil {
				return nil, fmt.Errorf("enforcer/wallet: could not get raw transaction: %w", err)
			}
			rawBytes, err := hex.DecodeString(rawTxResp.Msg.Tx.Hex)
			if err != nil {
				return nil, fmt.Errorf("could not decode raw tx hex: %w", err)
			}
			decodedTx, err := btcutil.NewTxFromBytes(rawBytes)
			if err != nil {
				return nil, fmt.Errorf("could not decode raw transaction: %w", err)
			}

			// Heuristic: for sent tx, use the first output that is not a change address (not in addressbook as receive)
			// for received tx, use the first output that is in the addressbook as receive
			var address string
			for _, txOut := range decodedTx.MsgTx().TxOut {
				_, addrs, _, err := txscript.ExtractPkScriptAddrs(txOut.PkScript, &chaincfg.SigNetParams)
				if err == nil && len(addrs) > 0 {
					addr := addrs[0].EncodeAddress()
					// Try to find a matching addressbook entry
					label := getLabel(addr)
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
				_, addrs, _, err := txscript.ExtractPkScriptAddrs(decodedTx.MsgTx().TxOut[0].PkScript, &chaincfg.SigNetParams)
				if err == nil && len(addrs) > 0 {
					address = addrs[0].EncodeAddress()
				}
			}
			label := getLabel(address)

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

			return &pb.WalletTransaction{
				Txid:             tx.Txid.Hex.Value,
				FeeSats:          tx.FeeSats,
				ReceivedSatoshi:  tx.ReceivedSats,
				SentSatoshi:      tx.SentSats,
				Address:          address,
				Label:            label,
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

// ListSidechainDeposits implements walletv1connect.WalletServiceHandler.
func (s *Server) ListSidechainDeposits(ctx context.Context, c *connect.Request[pb.ListSidechainDepositsRequest]) (*connect.Response[pb.ListSidechainDepositsResponse], error) {
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
func (s *Server) ListUnspent(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.ListUnspentResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not get bitcoind: %w", err)
	}

	// First get all UTXOs from the wallet
	utxos, err := wallet.ListUnspentOutputs(ctx, connect.NewRequest(&validatorpb.ListUnspentOutputsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not list unspent outputs: %w", err)
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

	// Use logpool to fetch all UTXO info in parallel
	pool := logpool.NewWithResults[*pb.UnspentOutput](ctx, "wallet/ListUnspent")
	for _, utxo := range utxos.Msg.Outputs {
		pool.Go(fmt.Sprintf("%s:%d", utxo.Txid.Hex.Value, utxo.Vout), func(ctx context.Context) (*pb.UnspentOutput, error) {
			address, err := s.getAddressFromOutpoint(ctx, bitcoind, utxo.Txid.Hex.Value, int(utxo.Vout))
			if err != nil {
				zerolog.Ctx(ctx).Error().Msgf("could not get address from outpoint: %s", err)
				// bitcoin core probably doesnt know about the tx yet,
				// chugging on with empty address info is fine!
			}

			// Try to get the timestamp from the transaction (if available)
			var receivedAt *timestamppb.Timestamp
			if utxo.UnconfirmedLastSeen != nil {
				receivedAt = utxo.UnconfirmedLastSeen
			} else if utxo.ConfirmedAtTime != nil {
				receivedAt = utxo.ConfirmedAtTime
			}

			return &pb.UnspentOutput{
				Output:     fmt.Sprintf("%s:%d", utxo.Txid.Hex.Value, utxo.Vout),
				Address:    address,
				Label:      getLabel(address),
				Value:      utxo.ValueSats,
				ReceivedAt: receivedAt,
				IsChange:   utxo.IsInternal,
			}, nil
		})
	}

	utxosWithInfo, err := pool.Wait(ctx)
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: failed to fetch UTXO info: %w", err)
	}

	return connect.NewResponse(&pb.ListUnspentResponse{
		Utxos: utxosWithInfo,
	}), nil
}

func (s *Server) getAddressFromOutpoint(ctx context.Context, bitcoind *coreproxy.Bitcoind, txid string, vout int) (string, error) {
	rawTxResp, err := bitcoind.GetRawTransaction(ctx, &connect.Request[corepb.GetRawTransactionRequest]{
		Msg: &corepb.GetRawTransactionRequest{
			Txid: txid,
		},
	})
	if err != nil {
		return "", fmt.Errorf("enforcer/wallet: could not get raw transaction: %w", err)
	}

	rawBytes, err := hex.DecodeString(rawTxResp.Msg.Tx.Hex)
	if err != nil {
		return "", fmt.Errorf("could not decode raw tx hex: %w", err)
	}
	decodedTx, err := btcutil.NewTxFromBytes(rawBytes)
	if err != nil {
		return "", fmt.Errorf("could not decode raw transaction: %w", err)
	}
	if vout < 0 || vout >= len(decodedTx.MsgTx().TxOut) {
		return "", fmt.Errorf("enforcer/wallet: vout %d out of range for tx %s", vout, txid)
	}
	txOut := decodedTx.MsgTx().TxOut[vout]

	// Extract address from scriptPubKey
	var address string
	_, addrs, _, err := txscript.ExtractPkScriptAddrs(txOut.PkScript, &chaincfg.SigNetParams)
	if err == nil && len(addrs) > 0 {
		address = addrs[0].EncodeAddress()
	}

	return address, nil
}

// ListReceiveAddresses implements walletv1connect.WalletServiceHandler.
func (s *Server) ListReceiveAddresses(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.ListReceiveAddressesResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	utxos, err := wallet.ListUnspentOutputs(ctx, connect.NewRequest(&validatorpb.ListUnspentOutputsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: could not list unspent outputs: %w", err)
	}

	currentAddress, err := s.GetNewAddress(ctx, connect.NewRequest(&emptypb.Empty{}))
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
		address, err := s.getAddressFromOutpoint(ctx, bitcoind, utxo.Txid.Hex.Value, int(utxo.Vout))
		if err != nil {
			return nil, fmt.Errorf("enforcer/wallet: could not get address from outpoint: %w", err)
		}
		if address == "" {
			continue
		}
		utxoTimestamp := utxo.UnconfirmedLastSeen
		if utxoTimestamp == nil {
			utxoTimestamp = utxo.ConfirmedAtTime
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
func (s *Server) GetStats(ctx context.Context, c *connect.Request[emptypb.Empty]) (*connect.Response[pb.GetStatsResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}

	// 1. Get all UTXOs and count them
	utxos, err := s.ListUnspent(ctx, connect.NewRequest(&emptypb.Empty{}))
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
			amt := int64(dep.Tx.ReceivedSats)
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
