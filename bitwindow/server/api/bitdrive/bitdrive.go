package api_bitdrive

import (
	"context"
	"database/sql"
	"fmt"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	bitdrivev1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitdrive/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitdrive/v1/bitdrivev1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/bitdrive"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
)

var _ rpc.BitDriveServiceHandler = new(Server)

// New creates a new BitDrive API server
func New(
	database *sql.DB,
	bitdriveEngine *engines.BitDriveEngine,
	walletEngine *engines.WalletEngine,
) *Server {
	return &Server{
		database:       database,
		bitdriveEngine: bitdriveEngine,
		walletEngine:   walletEngine,
	}
}

type Server struct {
	database       *sql.DB
	bitdriveEngine *engines.BitDriveEngine
	walletEngine   *engines.WalletEngine
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

	metadata, err := engines.ParseMetadata(metadataB64)
	if err != nil {
		return nil, fmt.Errorf("parse encoded metadata: %w", err)
	}

	opReturnData := engines.FormatOPReturnData(metadataB64, contentStr)

	// Broadcast the OP_RETURN through the active wallet's backend (electrum or
	// enforcer) so BitDrive works regardless of whether a local enforcer runs.
	txid, err := s.walletEngine.BroadcastOpReturn(ctx, []byte(opReturnData), req.Msg.FeeSatPerVbyte, 0)
	if err != nil {
		return nil, fmt.Errorf("send transaction: %w", err)
	}

	log.Info().
		Str("txid", txid).
		Bool("encrypted", req.Msg.Encrypt).
		Int("size", len(content)).
		Uint32("timestamp", timestamp).
		Msg("stored BitDrive file")

	return connect.NewResponse(&bitdrivev1.StoreFileResponse{
		Txid:      txid,
		FileType:  metadata.FileType,
		Encrypted: req.Msg.Encrypt,
	}), nil
}

// RetrieveContent implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) RetrieveContent(ctx context.Context, req *connect.Request[bitdrivev1.RetrieveContentRequest]) (*connect.Response[bitdrivev1.RetrieveContentResponse], error) {
	if req.Msg.Txid == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("txid is required"))
	}

	opReturn, err := opreturns.GetByTxID(ctx, s.database, req.Msg.Txid)
	if err != nil {
		return nil, fmt.Errorf("get OP_RETURN: %w", err)
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
	pending, scanned, err := s.bitdriveEngine.ScanForFiles(ctx)
	if err != nil {
		return nil, fmt.Errorf("scan for files: %w", err)
	}

	return connect.NewResponse(&bitdrivev1.ScanForFilesResponse{
		PendingFiles: lo.Map(pending, func(p engines.PendingBitDriveFile, _ int) *bitdrivev1.PendingFile {
			return &bitdrivev1.PendingFile{
				Txid:      p.OPReturn.TxID,
				Encrypted: p.Metadata.Encrypted,
				Timestamp: p.Metadata.Timestamp,
				FileType:  p.Metadata.FileType,
				Filename:  fmt.Sprintf("%d_%s.%s", p.Metadata.Timestamp, p.OPReturn.TxID, p.Metadata.FileType),
			}
		}),
		TotalScanned: uint32(scanned),
	}), nil
}

// DownloadPendingFiles implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) DownloadPendingFiles(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[bitdrivev1.DownloadPendingFilesResponse], error) {
	downloaded, failed, err := s.bitdriveEngine.DownloadPendingFiles(ctx)
	if err != nil {
		return nil, fmt.Errorf("download pending files: %w", err)
	}

	return connect.NewResponse(&bitdrivev1.DownloadPendingFilesResponse{
		DownloadedCount: downloaded,
		FailedCount:     failed,
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

	// Broadcast the OP_RETURN through the active wallet's backend (electrum or
	// enforcer) so BitDrive works regardless of whether a local enforcer runs.
	txid, err := s.walletEngine.BroadcastOpReturn(ctx, []byte(opReturnData), req.Msg.FeeSatPerVbyte, 0)
	if err != nil {
		return nil, fmt.Errorf("send transaction: %w", err)
	}

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

// GetBitdriveDir implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) GetBitdriveDir(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[bitdrivev1.GetBitdriveDirResponse], error) {
	return connect.NewResponse(&bitdrivev1.GetBitdriveDirResponse{
		Path: s.bitdriveEngine.GetDir(),
	}), nil
}

// OpenBitdriveDir implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) OpenBitdriveDir(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[emptypb.Empty], error) {
	if err := s.bitdriveEngine.OpenDir(ctx); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("open bitdrive dir: %w", err))
	}
	return connect.NewResponse(&emptypb.Empty{}), nil
}
