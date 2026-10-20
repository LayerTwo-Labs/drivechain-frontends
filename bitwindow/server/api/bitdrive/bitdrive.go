package bitdrive

import (
	"context"
	"database/sql"
	"fmt"

	"connectrpc.com/connect/v2"
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

func New(
	database *sql.DB,
	bitdriveEngine *engines.BitDriveEngine,
) *Server {
	return &Server{
		database:       database,
		bitdriveEngine: bitdriveEngine,
	}
}

type Server struct {
	database       *sql.DB
	bitdriveEngine *engines.BitDriveEngine
}

// StoreFile implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) StoreFile(ctx context.Context, req *bitdrivev1.StoreFileRequest) (*bitdrivev1.StoreFileResponse, error) {
	if len(req.Content) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, "content is required")
	}

	txid, fileType, err := s.bitdriveEngine.StoreFile(ctx, req.Content, req.Encrypt, req.FeeSatPerVbyte)
	if err != nil {
		return nil, err
	}

	return &bitdrivev1.StoreFileResponse{
		Txid:      txid,
		FileType:  fileType,
		Encrypted: req.Encrypt,
	}, nil
}

// RetrieveContent implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) RetrieveContent(ctx context.Context, req *bitdrivev1.RetrieveContentRequest) (*bitdrivev1.RetrieveContentResponse, error) {
	if req.Txid == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "txid is required")
	}

	opReturn, err := opreturns.GetByTxID(ctx, s.database, req.Txid)
	if err != nil {
		return nil, fmt.Errorf("get OP_RETURN: %w", err)
	}

	if opReturn == nil {
		return nil, connect.Errorf(connect.CodeNotFound, "OP_RETURN not found for txid %s", req.Txid)
	}

	// Decode content
	opReturnMessage := opreturns.OPReturnToReadable(opReturn.Data)
	content, metadata, err := s.bitdriveEngine.DecodeOPReturnData(ctx, opReturnMessage)
	if err != nil {
		return nil, fmt.Errorf("decode OP_RETURN data: %w", err)
	}

	return &bitdrivev1.RetrieveContentResponse{
		Content:   content,
		FileType:  metadata.FileType,
		Encrypted: metadata.Encrypted,
		Timestamp: metadata.Timestamp,
	}, nil
}

// ScanForFiles implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) ScanForFiles(ctx context.Context, req *emptypb.Empty) (*bitdrivev1.ScanForFilesResponse, error) {
	pending, scanned, err := s.bitdriveEngine.ScanForFiles(ctx)
	if err != nil {
		return nil, fmt.Errorf("scan for files: %w", err)
	}

	return &bitdrivev1.ScanForFilesResponse{
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
	}, nil
}

// DownloadPendingFiles implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) DownloadPendingFiles(ctx context.Context, req *emptypb.Empty) (*bitdrivev1.DownloadPendingFilesResponse, error) {
	downloaded, failed, err := s.bitdriveEngine.DownloadPendingFiles(ctx)
	if err != nil {
		return nil, fmt.Errorf("download pending files: %w", err)
	}

	return &bitdrivev1.DownloadPendingFilesResponse{
		DownloadedCount: downloaded,
		FailedCount:     failed,
	}, nil
}

// ListFiles implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) ListFiles(ctx context.Context, req *emptypb.Empty) (*bitdrivev1.ListFilesResponse, error) {
	files, err := s.bitdriveEngine.ListFiles(ctx)
	if err != nil {
		return nil, fmt.Errorf("list files: %w", err)
	}

	return &bitdrivev1.ListFilesResponse{
		Files: lo.Map(files, func(f bitdrive.File, _ int) *bitdrivev1.BitDriveFile {
			return fileToProto(f)
		}),
	}, nil
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
func (s *Server) GetFile(ctx context.Context, req *bitdrivev1.GetFileRequest) (*bitdrivev1.GetFileResponse, error) {
	var file *bitdrive.File
	var err error

	switch {
	case req.Id > 0:
		file, err = bitdrive.GetByID(ctx, s.database, req.Id)
	case req.Txid != "":
		file, err = bitdrive.GetByTxID(ctx, s.database, req.Txid)
	default:
		return nil, connect.NewError(connect.CodeInvalidArgument, "id or txid is required")
	}

	if err != nil {
		return nil, fmt.Errorf("get file: %w", err)
	}
	if file == nil {
		return nil, connect.NewError(connect.CodeNotFound, "file not found")
	}

	// Read file content
	content, err := s.bitdriveEngine.GetFileContent(ctx, file.Filename)
	if err != nil {
		return nil, fmt.Errorf("read file content: %w", err)
	}

	return &bitdrivev1.GetFileResponse{
		File:    fileToProto(*file),
		Content: content,
	}, nil
}

// DeleteFile implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) DeleteFile(ctx context.Context, req *bitdrivev1.DeleteFileRequest) (*emptypb.Empty, error) {
	if req.Id <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, "id is required")
	}

	if err := s.bitdriveEngine.DeleteFile(ctx, req.Id); err != nil {
		return nil, fmt.Errorf("delete file: %w", err)
	}

	return &emptypb.Empty{}, nil
}

// StoreMultisigData implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) StoreMultisigData(ctx context.Context, req *bitdrivev1.StoreMultisigDataRequest) (*bitdrivev1.StoreMultisigDataResponse, error) {
	if len(req.JsonData) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, "json_data is required")
	}

	txid, err := s.bitdriveEngine.StoreMultisigData(ctx, req.JsonData, req.Encrypt, req.FeeSatPerVbyte)
	if err != nil {
		return nil, err
	}

	return &bitdrivev1.StoreMultisigDataResponse{
		Txid: txid,
	}, nil
}

// WipeData implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) WipeData(ctx context.Context, req *emptypb.Empty) (*emptypb.Empty, error) {
	if err := s.bitdriveEngine.WipeData(ctx); err != nil {
		return nil, fmt.Errorf("wipe data: %w", err)
	}

	return &emptypb.Empty{}, nil
}

// GetBitdriveDir implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) GetBitdriveDir(ctx context.Context, req *emptypb.Empty) (*bitdrivev1.GetBitdriveDirResponse, error) {
	return &bitdrivev1.GetBitdriveDirResponse{
		Path: s.bitdriveEngine.GetDir(),
	}, nil
}

// OpenBitdriveDir implements bitdrivev1connect.BitDriveServiceHandler.
func (s *Server) OpenBitdriveDir(ctx context.Context, req *emptypb.Empty) (*emptypb.Empty, error) {
	if err := s.bitdriveEngine.OpenDir(ctx); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("open bitdrive dir: %s", err)).WithCause(err)
	}
	return &emptypb.Empty{}, nil
}
