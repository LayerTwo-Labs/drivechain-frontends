package api_bitdrive

import (
	"context"
	"database/sql"
	"encoding/hex"
	"fmt"

	"connectrpc.com/connect"
	commonv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
	validatorpb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	bitdrivev1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitdrive/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitdrive/v1/bitdrivev1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/bitdrive"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

var _ rpc.BitDriveServiceHandler = new(Server)

// New creates a new BitDrive API server
func New(
	database *sql.DB,
	wallet *service.Service[validatorrpc.WalletServiceClient],
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
	bitdriveEngine *engines.BitDriveEngine,
) *Server {
	return &Server{
		database:       database,
		wallet:         wallet,
		bitcoind:       bitcoind,
		bitdriveEngine: bitdriveEngine,
	}
}

type Server struct {
	database       *sql.DB
	wallet         *service.Service[validatorrpc.WalletServiceClient]
	bitcoind       *service.Service[corerpc.BitcoinServiceClient]
	bitdriveEngine *engines.BitDriveEngine
}

// StoreFile implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) StoreFile(ctx context.Context, req *connect.Request[bitdrivev1.StoreFileRequest]) (*connect.Response[bitdrivev1.StoreFileResponse], error) {
	log := zerolog.Ctx(ctx)

	content := req.Msg.Content
	if len(content) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("content is required"))
	}

	if err := engines.ValidateFileSize(content); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	// Encode for OP_RETURN
	metadataB64, contentStr, timestamp, err := s.bitdriveEngine.EncodeOPReturnData(ctx, content, req.Msg.Encrypt)
	if err != nil {
		return nil, fmt.Errorf("encode OP_RETURN data: %w", err)
	}

	opReturnData := engines.FormatOPReturnData(metadataB64, contentStr)

	// Send transaction
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("get wallet: %w", err)
	}

	sendReq := &validatorpb.SendTransactionRequest{
		OpReturnMessage: &commonv1.Hex{
			Hex: &wrapperspb.StringValue{
				Value: hex.EncodeToString([]byte(opReturnData)),
			},
		},
	}

	if req.Msg.FeeSatPerVbyte > 0 {
		sendReq.FeeRate = &validatorpb.SendTransactionRequest_FeeRate{
			Fee: &validatorpb.SendTransactionRequest_FeeRate_SatPerVbyte{
				SatPerVbyte: req.Msg.FeeSatPerVbyte,
			},
		}
	}

	resp, err := wallet.SendTransaction(ctx, connect.NewRequest(sendReq))
	if err != nil {
		return nil, fmt.Errorf("send transaction: %w", err)
	}

	txid := resp.Msg.Txid.Hex.Value

	log.Info().
		Str("txid", txid).
		Bool("encrypted", req.Msg.Encrypt).
		Int("size", len(content)).
		Uint32("timestamp", timestamp).
		Msg("stored BitDrive file")

	// Parse metadata to get file type
	metadata, _ := engines.ParseMetadata(metadataB64)
	fileType := ""
	if metadata != nil {
		fileType = metadata.FileType
	}

	return connect.NewResponse(&bitdrivev1.StoreFileResponse{
		Txid:      txid,
		FileType:  fileType,
		Encrypted: req.Msg.Encrypt,
	}), nil
}

// RetrieveContent implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) RetrieveContent(ctx context.Context, req *connect.Request[bitdrivev1.RetrieveContentRequest]) (*connect.Response[bitdrivev1.RetrieveContentResponse], error) {
	if req.Msg.Txid == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("txid is required"))
	}

	// Get OP_RETURN data
	opReturns, err := opreturns.List(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("list OP_RETURNs: %w", err)
	}

	var opReturn *opreturns.OPReturn
	for _, op := range opReturns {
		if op.TxID == req.Msg.Txid {
			opReturn = &op
			break
		}
	}

	if opReturn == nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("OP_RETURN not found for txid %s", req.Msg.Txid))
	}

	// Decode content
	opReturnMessage := opreturns.OPReturnToReadable(opReturn.Data)
	content, metadata, err := s.bitdriveEngine.DecodeOPReturnData(ctx, opReturnMessage)
	if err != nil {
		return nil, fmt.Errorf("decode OP_RETURN data: %w", err)
	}

	return connect.NewResponse(&bitdrivev1.RetrieveContentResponse{
		Content:   content,
		FileType:  metadata.FileType,
		Encrypted: metadata.Encrypted,
		Timestamp: metadata.Timestamp,
	}), nil
}

// ScanForFiles implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) ScanForFiles(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[bitdrivev1.ScanForFilesResponse], error) {
	log := zerolog.Ctx(ctx)

	// Get all OP_RETURNs
	allOpReturns, err := opreturns.List(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("list OP_RETURNs: %w", err)
	}

	var pendingFiles []*bitdrivev1.PendingFile
	totalScanned := 0

	for _, opReturn := range allOpReturns {
		opReturnMessage := opreturns.OPReturnToReadable(opReturn.Data)

		// Check if this is a BitDrive transaction
		if !engines.IsBitDriveTransaction(opReturnMessage) {
			continue
		}
		totalScanned++

		// Parse metadata
		metadataB64, _, err := engines.ParseOPReturnParts(opReturnMessage)
		if err != nil {
			continue
		}

		metadata, err := engines.ParseMetadata(metadataB64)
		if err != nil {
			continue
		}

		// Skip multisig transactions in scan
		if metadata.IsMultisig {
			continue
		}

		// Check if already downloaded
		exists, err := bitdrive.Exists(ctx, s.database, opReturn.TxID)
		if err != nil {
			log.Warn().Err(err).Str("txid", opReturn.TxID).Msg("error checking if file exists")
			continue
		}
		if exists {
			continue
		}

		pendingFiles = append(pendingFiles, &bitdrivev1.PendingFile{
			Txid:      opReturn.TxID,
			Encrypted: metadata.Encrypted,
			Timestamp: metadata.Timestamp,
			FileType:  metadata.FileType,
			Filename:  fmt.Sprintf("%d.%s", metadata.Timestamp, metadata.FileType),
		})
	}

	log.Info().
		Int("pending", len(pendingFiles)).
		Int("total_scanned", totalScanned).
		Msg("scanned for BitDrive files")

	return connect.NewResponse(&bitdrivev1.ScanForFilesResponse{
		PendingFiles: pendingFiles,
		TotalScanned: uint32(totalScanned),
	}), nil
}

// DownloadPendingFiles implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) DownloadPendingFiles(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[bitdrivev1.DownloadPendingFilesResponse], error) {
	log := zerolog.Ctx(ctx)

	// First scan for pending files
	scanResp, err := s.ScanForFiles(ctx, connect.NewRequest(&emptypb.Empty{}))
	if err != nil {
		return nil, fmt.Errorf("scan for files: %w", err)
	}

	var downloadedCount, failedCount uint32

	// Get all OP_RETURNs
	allOpReturns, err := opreturns.List(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("list OP_RETURNs: %w", err)
	}

	for _, pending := range scanResp.Msg.PendingFiles {
		// Find matching OP_RETURN
		var opReturn *opreturns.OPReturn
		for _, op := range allOpReturns {
			if op.TxID == pending.Txid {
				opReturn = &op
				break
			}
		}

		if opReturn == nil {
			failedCount++
			continue
		}

		opReturnMessage := opreturns.OPReturnToReadable(opReturn.Data)
		content, metadata, err := s.bitdriveEngine.DecodeOPReturnData(ctx, opReturnMessage)
		if err != nil {
			log.Warn().Err(err).Str("txid", pending.Txid).Msg("failed to decode content")
			failedCount++
			continue
		}

		// Save file
		if err := s.bitdriveEngine.SaveFile(ctx, pending.Txid, content, metadata); err != nil {
			log.Warn().Err(err).Str("txid", pending.Txid).Msg("failed to save file")
			failedCount++
			continue
		}

		downloadedCount++
	}

	log.Info().
		Uint32("downloaded", downloadedCount).
		Uint32("failed", failedCount).
		Msg("downloaded pending BitDrive files")

	return connect.NewResponse(&bitdrivev1.DownloadPendingFilesResponse{
		DownloadedCount: downloadedCount,
		FailedCount:     failedCount,
	}), nil
}

// ListFiles implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) ListFiles(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[bitdrivev1.ListFilesResponse], error) {
	files, err := s.bitdriveEngine.ListFiles(ctx)
	if err != nil {
		return nil, fmt.Errorf("list files: %w", err)
	}

	return connect.NewResponse(&bitdrivev1.ListFilesResponse{
		Files: lo.Map(files, func(f bitdrive.File, _ int) *bitdrivev1.BitDriveFile {
			return fileToProto(f)
		}),
	}), nil
}

func fileToProto(f bitdrive.File) *bitdrivev1.BitDriveFile {
	return &bitdrivev1.BitDriveFile{
		Id:        f.ID,
		Filename:  f.Filename,
		FileType:  f.FileType,
		SizeBytes: f.SizeBytes,
		Encrypted: f.Encrypted,
		Txid:      f.TxID,
		Timestamp: f.Timestamp,
		CreatedAt: timestamppb.New(f.CreatedAt),
	}
}

// GetFile implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) GetFile(ctx context.Context, req *connect.Request[bitdrivev1.GetFileRequest]) (*connect.Response[bitdrivev1.GetFileResponse], error) {
	var file *bitdrive.File
	var err error

	switch {
	case req.Msg.Id > 0:
		file, err = bitdrive.GetByID(ctx, s.database, req.Msg.Id)
	case req.Msg.Txid != "":
		file, err = bitdrive.GetByTxID(ctx, s.database, req.Msg.Txid)
	default:
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("id or txid is required"))
	}

	if err != nil {
		return nil, fmt.Errorf("get file: %w", err)
	}
	if file == nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("file not found"))
	}

	// Read file content
	content, err := s.bitdriveEngine.GetFileContent(ctx, file.Filename)
	if err != nil {
		return nil, fmt.Errorf("read file content: %w", err)
	}

	return connect.NewResponse(&bitdrivev1.GetFileResponse{
		File:    fileToProto(*file),
		Content: content,
	}), nil
}

// DeleteFile implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) DeleteFile(ctx context.Context, req *connect.Request[bitdrivev1.DeleteFileRequest]) (*connect.Response[emptypb.Empty], error) {
	if req.Msg.Id <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("id is required"))
	}

	if err := s.bitdriveEngine.DeleteFile(ctx, req.Msg.Id); err != nil {
		return nil, fmt.Errorf("delete file: %w", err)
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}

// StoreMultisigData implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) StoreMultisigData(ctx context.Context, req *connect.Request[bitdrivev1.StoreMultisigDataRequest]) (*connect.Response[bitdrivev1.StoreMultisigDataResponse], error) {
	log := zerolog.Ctx(ctx)

	if len(req.Msg.JsonData) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("json_data is required"))
	}

	// Encode multisig data
	opReturnData, err := s.bitdriveEngine.EncodeMultisigData(ctx, req.Msg.JsonData, req.Msg.Encrypt)
	if err != nil {
		return nil, fmt.Errorf("encode multisig data: %w", err)
	}

	// Send transaction
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("get wallet: %w", err)
	}

	sendReq := &validatorpb.SendTransactionRequest{
		OpReturnMessage: &commonv1.Hex{
			Hex: &wrapperspb.StringValue{
				Value: hex.EncodeToString([]byte(opReturnData)),
			},
		},
	}

	if req.Msg.FeeSatPerVbyte > 0 {
		sendReq.FeeRate = &validatorpb.SendTransactionRequest_FeeRate{
			Fee: &validatorpb.SendTransactionRequest_FeeRate_SatPerVbyte{
				SatPerVbyte: req.Msg.FeeSatPerVbyte,
			},
		}
	}

	resp, err := wallet.SendTransaction(ctx, connect.NewRequest(sendReq))
	if err != nil {
		return nil, fmt.Errorf("send transaction: %w", err)
	}

	txid := resp.Msg.Txid.Hex.Value

	log.Info().
		Str("txid", txid).
		Bool("encrypted", req.Msg.Encrypt).
		Int("size", len(req.Msg.JsonData)).
		Msg("stored multisig data")

	return connect.NewResponse(&bitdrivev1.StoreMultisigDataResponse{
		Txid: txid,
	}), nil
}

// WipeData implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) WipeData(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[emptypb.Empty], error) {
	if err := s.bitdriveEngine.WipeData(ctx); err != nil {
		return nil, fmt.Errorf("wipe data: %w", err)
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}
