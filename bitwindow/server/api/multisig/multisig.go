package api_multisig

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/multisig/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/multisig/v1/multisigv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/multisig"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

var _ rpc.MultisigServiceHandler = new(Server)

type Server struct {
	store *multisig.Store
}

func New(db *sql.DB) *Server {
	return &Server{store: multisig.NewStore(db)}
}

// Store exposes the underlying store for migration use.
func (s *Server) Store() *multisig.Store {
	return s.store
}

// ─── Groups ────────────────────────────────────────────────────────

func (s *Server) ListGroups(
	ctx context.Context,
	req *connect.Request[emptypb.Empty],
) (*connect.Response[pb.ListGroupsResponse], error) {
	groups, err := s.store.ListGroups(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("list groups: %w", err))
	}

	var pbGroups []*pb.MultisigGroup
	for _, g := range groups {
		pbGroup, err := s.groupToProto(ctx, g)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err)
		}
		pbGroups = append(pbGroups, pbGroup)
	}

	return connect.NewResponse(&pb.ListGroupsResponse{Groups: pbGroups}), nil
}

func (s *Server) SaveGroup(
	ctx context.Context,
	req *connect.Request[pb.SaveGroupRequest],
) (*connect.Response[pb.SaveGroupResponse], error) {
	pg := req.Msg.Group
	if pg == nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("group is required"))
	}
	if pg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("group id is required"))
	}

	g := multisig.Group{
		ID:                pg.Id,
		Name:              pg.Name,
		N:                 int(pg.N),
		M:                 int(pg.M),
		Created:           pg.Created,
		Txid:              pg.Txid,
		Descriptor:        pg.BaseDescriptor,
		DescriptorReceive: pg.DescriptorReceive,
		DescriptorChange:  pg.DescriptorChange,
		WatchWalletName:   pg.WatchWalletName,
		Balance:           pg.Balance,
		Utxos:             int(pg.Utxos),
		NextReceiveIndex:  int(pg.NextReceiveIndex),
		NextChangeIndex:   int(pg.NextChangeIndex),
	}

	// Build keys
	var keys []multisig.Key
	for i, k := range pg.Keys {
		keys = append(keys, multisig.Key{
			GroupID:        pg.Id,
			Owner:          k.Owner,
			Xpub:           k.Xpub,
			DerivationPath: k.DerivationPath,
			Fingerprint:    k.Fingerprint,
			OriginPath:     k.OriginPath,
			IsWallet:       k.IsWallet,
			SortOrder:      i,
		})
	}

	// Build key PSBTs indexed by xpub (key ID resolved inside atomic op)
	xpubToPSBTs := make(map[string][]multisig.KeyPSBT)
	for _, k := range pg.Keys {
		for txID, activePSBT := range k.ActivePsbts {
			initialPSBT := k.InitialPsbts[txID]
			xpubToPSBTs[k.Xpub] = append(xpubToPSBTs[k.Xpub], multisig.KeyPSBT{
				TransactionID: txID,
				ActivePSBT:    activePSBT,
				InitialPSBT:   initialPSBT,
			})
		}
	}

	// Build addresses
	var addrs []multisig.Address
	for _, a := range pg.ReceiveAddresses {
		addrs = append(addrs, multisig.Address{
			GroupID:  pg.Id,
			AddrType: "receive",
			Index:    int(a.Index),
			Addr:     a.Address,
			Used:     a.Used,
		})
	}
	for _, a := range pg.ChangeAddresses {
		addrs = append(addrs, multisig.Address{
			GroupID:  pg.Id,
			AddrType: "change",
			Index:    int(a.Index),
			Addr:     a.Address,
			Used:     a.Used,
		})
	}

	// Build UTXO details
	var utxos []multisig.UtxoDetail
	for _, u := range pg.UtxoDetails {
		utxos = append(utxos, multisig.UtxoDetail{
			GroupID:       pg.Id,
			Txid:          u.Txid,
			Vout:          int(u.Vout),
			Address:       u.Address,
			Amount:        u.Amount,
			Confirmations: int(u.Confirmations),
			ScriptPubKey:  u.ScriptPubKey,
			Spendable:     u.Spendable,
			Solvable:      u.Solvable,
			Safe:          u.Safe,
		})
	}

	// Persist everything atomically
	if err := s.store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{
		Group:          g,
		Keys:           keys,
		XpubToPSBTs:    xpubToPSBTs,
		Addresses:      addrs,
		UtxoDetails:    utxos,
		TransactionIDs: pg.TransactionIds,
	}); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("save group atomic: %w", err))
	}

	// Re-read the saved group
	saved, err := s.groupToProto(ctx, g)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&pb.SaveGroupResponse{Group: saved}), nil
}

func (s *Server) DeleteGroup(
	ctx context.Context,
	req *connect.Request[pb.DeleteGroupRequest],
) (*connect.Response[emptypb.Empty], error) {
	if err := s.store.DeleteGroup(ctx, req.Msg.GroupId); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("delete group: %w", err))
	}
	return connect.NewResponse(&emptypb.Empty{}), nil
}

// ─── Transactions ──────────────────────────────────────────────────

func (s *Server) ListTransactions(
	ctx context.Context,
	req *connect.Request[pb.ListTransactionsRequest],
) (*connect.Response[pb.ListTransactionsResponse], error) {
	txns, err := s.store.ListTransactions(ctx, req.Msg.GroupId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("list transactions: %w", err))
	}

	var pbTxns []*pb.MultisigTransaction
	for _, t := range txns {
		pbTx, err := s.txToProto(ctx, t)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err)
		}
		pbTxns = append(pbTxns, pbTx)
	}

	return connect.NewResponse(&pb.ListTransactionsResponse{Transactions: pbTxns}), nil
}

func (s *Server) GetTransaction(
	ctx context.Context,
	req *connect.Request[pb.GetTransactionRequest],
) (*connect.Response[pb.MultisigTransaction], error) {
	t, err := s.store.GetTransaction(ctx, req.Msg.TransactionId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	if t == nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("transaction not found: %s", req.Msg.TransactionId))
	}

	pbTx, err := s.txToProto(ctx, *t)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(pbTx), nil
}

func (s *Server) GetTransactionByTxid(
	ctx context.Context,
	req *connect.Request[pb.GetTransactionByTxidRequest],
) (*connect.Response[pb.MultisigTransaction], error) {
	t, err := s.store.GetTransactionByTxid(ctx, req.Msg.Txid)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	if t == nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("transaction not found for txid: %s", req.Msg.Txid))
	}

	pbTx, err := s.txToProto(ctx, *t)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(pbTx), nil
}

func (s *Server) SaveTransaction(
	ctx context.Context,
	req *connect.Request[pb.SaveTransactionRequest],
) (*connect.Response[pb.SaveTransactionResponse], error) {
	pt := req.Msg.Transaction
	if pt == nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("transaction is required"))
	}

	t := multisig.Transaction{
		ID:                 pt.Id,
		GroupID:            pt.GroupId,
		InitialPSBT:        pt.InitialPsbt,
		CombinedPSBT:       pt.CombinedPsbt,
		FinalHex:           pt.FinalHex,
		Txid:               pt.Txid,
		Status:             int(pt.Status),
		Type:               int(pt.Type),
		Amount:             pt.Amount,
		Destination:        pt.Destination,
		Fee:                pt.Fee,
		Confirmations:      int(pt.Confirmations),
		RequiredSignatures: int(pt.RequiredSignatures),
	}

	if pt.Created != nil {
		t.Created = pt.Created.Seconds
	}
	if pt.BroadcastTime != nil {
		bt := pt.BroadcastTime.Seconds
		t.BroadcastTime = &bt
	}

	// Build key PSBTs
	var psbts []multisig.TxKeyPSBT
	for _, kp := range pt.KeyPsbts {
		var signedAt *int64
		if kp.SignedAt != nil {
			sa := kp.SignedAt.Seconds
			signedAt = &sa
		}
		psbts = append(psbts, multisig.TxKeyPSBT{
			TransactionID: pt.Id,
			KeyID:         kp.KeyId,
			PSBT:          kp.Psbt,
			IsSigned:      kp.IsSigned,
			SignedAt:      signedAt,
		})
	}

	// Build inputs
	var inputs []multisig.TxInput
	for _, inp := range pt.Inputs {
		inputs = append(inputs, multisig.TxInput{
			TransactionID: pt.Id,
			Txid:          inp.Txid,
			Vout:          int(inp.Vout),
			Address:       inp.Address,
			Amount:        inp.Amount,
			Confirmations: int(inp.Confirmations),
		})
	}

	// Persist everything atomically
	if err := s.store.SaveTransactionAtomic(ctx, multisig.SaveTransactionAtomicParams{
		Transaction: t,
		KeyPSBTs:    psbts,
		Inputs:      inputs,
	}); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("save transaction atomic: %w", err))
	}

	// Re-read
	saved, err := s.store.GetTransaction(ctx, pt.Id)
	if err != nil || saved == nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("re-read transaction: %w", err))
	}

	pbTx, err := s.txToProto(ctx, *saved)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&pb.SaveTransactionResponse{Transaction: pbTx}), nil
}

// ─── Solo Keys ─────────────────────────────────────────────────────

func (s *Server) ListSoloKeys(
	ctx context.Context,
	req *connect.Request[emptypb.Empty],
) (*connect.Response[pb.ListSoloKeysResponse], error) {
	keys, err := s.store.ListSoloKeys(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	var pbKeys []*pb.SoloKey
	for _, k := range keys {
		pbKeys = append(pbKeys, &pb.SoloKey{
			Xpub:           k.Xpub,
			DerivationPath: k.DerivationPath,
			Fingerprint:    k.Fingerprint,
			OriginPath:     k.OriginPath,
			Owner:          k.Owner,
		})
	}

	return connect.NewResponse(&pb.ListSoloKeysResponse{Keys: pbKeys}), nil
}

func (s *Server) AddSoloKey(
	ctx context.Context,
	req *connect.Request[pb.AddSoloKeyRequest],
) (*connect.Response[emptypb.Empty], error) {
	k := req.Msg.Key
	if k == nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("key is required"))
	}

	if err := s.store.AddSoloKey(ctx, multisig.SoloKey{
		Xpub:           k.Xpub,
		DerivationPath: k.DerivationPath,
		Fingerprint:    k.Fingerprint,
		OriginPath:     k.OriginPath,
		Owner:          k.Owner,
	}); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}

// ─── Account Index ─────────────────────────────────────────────────

func (s *Server) GetNextAccountIndex(
	ctx context.Context,
	req *connect.Request[pb.GetNextAccountIndexRequest],
) (*connect.Response[pb.GetNextAccountIndexResponse], error) {
	var additional []int
	for _, idx := range req.Msg.AdditionalUsedIndices {
		additional = append(additional, int(idx))
	}

	next, err := s.store.GetNextAccountIndex(ctx, additional)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&pb.GetNextAccountIndexResponse{NextIndex: int32(next)}), nil
}

// ─── Converters ────────────────────────────────────────────────────

func (s *Server) groupToProto(ctx context.Context, g multisig.Group) (*pb.MultisigGroup, error) {
	pg := &pb.MultisigGroup{
		Id:                g.ID,
		Name:              g.Name,
		N:                 int32(g.N),
		M:                 int32(g.M),
		Created:           g.Created,
		Txid:              g.Txid,
		BaseDescriptor:    g.Descriptor,
		DescriptorReceive: g.DescriptorReceive,
		DescriptorChange:  g.DescriptorChange,
		WatchWalletName:   g.WatchWalletName,
		Balance:           g.Balance,
		Utxos:             int32(g.Utxos),
		NextReceiveIndex:  int32(g.NextReceiveIndex),
		NextChangeIndex:   int32(g.NextChangeIndex),
	}

	// Load keys
	keys, err := s.store.ListKeysForGroup(ctx, g.ID)
	if err != nil {
		return nil, fmt.Errorf("list keys for %s: %w", g.ID, err)
	}

	// Load key PSBTs
	keyPSBTs, err := s.store.ListKeyPSBTs(ctx, g.ID)
	if err != nil {
		return nil, fmt.Errorf("list key psbts for %s: %w", g.ID, err)
	}

	// Build PSBT maps per key ID
	activePSBTsByKey := make(map[int64]map[string]string)
	initialPSBTsByKey := make(map[int64]map[string]string)
	for _, kp := range keyPSBTs {
		if _, ok := activePSBTsByKey[kp.KeyID]; !ok {
			activePSBTsByKey[kp.KeyID] = make(map[string]string)
			initialPSBTsByKey[kp.KeyID] = make(map[string]string)
		}
		if kp.ActivePSBT != "" {
			activePSBTsByKey[kp.KeyID][kp.TransactionID] = kp.ActivePSBT
		}
		if kp.InitialPSBT != "" {
			initialPSBTsByKey[kp.KeyID][kp.TransactionID] = kp.InitialPSBT
		}
	}

	for _, k := range keys {
		pbKey := &pb.MultisigKey{
			Owner:          k.Owner,
			Xpub:           k.Xpub,
			DerivationPath: k.DerivationPath,
			Fingerprint:    k.Fingerprint,
			OriginPath:     k.OriginPath,
			IsWallet:       k.IsWallet,
			ActivePsbts:    activePSBTsByKey[k.ID],
			InitialPsbts:   initialPSBTsByKey[k.ID],
		}
		pg.Keys = append(pg.Keys, pbKey)
	}

	// Load addresses
	addrs, err := s.store.ListAddresses(ctx, g.ID)
	if err != nil {
		return nil, fmt.Errorf("list addresses for %s: %w", g.ID, err)
	}
	for _, a := range addrs {
		pbAddr := &pb.AddressInfo{
			Index:   int32(a.Index),
			Address: a.Addr,
			Used:    a.Used,
		}
		if a.AddrType == "receive" {
			pg.ReceiveAddresses = append(pg.ReceiveAddresses, pbAddr)
		} else {
			pg.ChangeAddresses = append(pg.ChangeAddresses, pbAddr)
		}
	}

	// Load UTXO details
	utxos, err := s.store.ListUtxoDetails(ctx, g.ID)
	if err != nil {
		return nil, fmt.Errorf("list utxos for %s: %w", g.ID, err)
	}
	for _, u := range utxos {
		pg.UtxoDetails = append(pg.UtxoDetails, &pb.UtxoDetail{
			Txid:          u.Txid,
			Vout:          int32(u.Vout),
			Address:       u.Address,
			Amount:        u.Amount,
			Confirmations: int32(u.Confirmations),
			ScriptPubKey:  u.ScriptPubKey,
			Spendable:     u.Spendable,
			Solvable:      u.Solvable,
			Safe:          u.Safe,
		})
	}

	// Load transaction IDs
	txIDs, err := s.store.ListGroupTransactionIDs(ctx, g.ID)
	if err != nil {
		return nil, fmt.Errorf("list tx ids for %s: %w", g.ID, err)
	}
	pg.TransactionIds = txIDs

	return pg, nil
}

func (s *Server) txToProto(ctx context.Context, t multisig.Transaction) (*pb.MultisigTransaction, error) {
	pt := &pb.MultisigTransaction{
		Id:                 t.ID,
		GroupId:            t.GroupID,
		InitialPsbt:        t.InitialPSBT,
		CombinedPsbt:       t.CombinedPSBT,
		FinalHex:           t.FinalHex,
		Txid:               t.Txid,
		Status:             pb.TxStatus(t.Status),
		Type:               pb.TxType(t.Type),
		Amount:             t.Amount,
		Destination:        t.Destination,
		Fee:                t.Fee,
		Confirmations:      int32(t.Confirmations),
		RequiredSignatures: int32(t.RequiredSignatures),
	}

	if t.Created != 0 {
		pt.Created = timestamppb.New(timeFromUnix(t.Created))
	}
	if t.BroadcastTime != nil {
		pt.BroadcastTime = timestamppb.New(timeFromUnix(*t.BroadcastTime))
	}

	// Load key PSBTs
	keyPSBTs, err := s.store.ListTxKeyPSBTs(ctx, t.ID)
	if err != nil {
		return nil, fmt.Errorf("list key psbts for tx %s: %w", t.ID, err)
	}
	for _, kp := range keyPSBTs {
		pbKP := &pb.KeyPSBTStatus{
			KeyId:    kp.KeyID,
			Psbt:     kp.PSBT,
			IsSigned: kp.IsSigned,
		}
		if kp.SignedAt != nil {
			pbKP.SignedAt = timestamppb.New(timeFromUnix(*kp.SignedAt))
		}
		pt.KeyPsbts = append(pt.KeyPsbts, pbKP)
	}

	// Load inputs
	inputs, err := s.store.ListTxInputs(ctx, t.ID)
	if err != nil {
		return nil, fmt.Errorf("list inputs for tx %s: %w", t.ID, err)
	}
	for _, inp := range inputs {
		pt.Inputs = append(pt.Inputs, &pb.UtxoDetail{
			Txid:          inp.Txid,
			Vout:          int32(inp.Vout),
			Address:       inp.Address,
			Amount:        inp.Amount,
			Confirmations: int32(inp.Confirmations),
		})
	}

	return pt, nil
}

func timeFromUnix(unix int64) time.Time {
	return time.Unix(unix, 0)
}
