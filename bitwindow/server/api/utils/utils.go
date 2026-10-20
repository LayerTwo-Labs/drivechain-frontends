package utils

import (
	"context"
	"math"

	"connectrpc.com/connect/v2"
	"github.com/btcsuite/btcd/chaincfg"
	"google.golang.org/protobuf/types/known/emptypb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	utilspb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/utils/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/utils/v1/utilsv1connect"
)

var _ rpc.UtilsServiceHandler = new(Server)

type Server struct {
	chainParams *chaincfg.Params
}

func New(chainParams *chaincfg.Params) *Server {
	return &Server{
		chainParams: chainParams,
	}
}

// ParseBitcoinURI implements utilsv1connect.UtilsServiceHandler
func (s *Server) ParseBitcoinURI(_ context.Context, req *utilspb.ParseBitcoinURIRequest) (*utilspb.ParseBitcoinURIResponse, error) {
	result, err := engines.ParseBitcoinURI(req.Uri)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	return &utilspb.ParseBitcoinURIResponse{
		Address:     result.Address,
		Amount:      result.Amount,
		Label:       result.Label,
		Message:     result.Message,
		ExtraParams: result.ExtraParams,
	}, nil
}

// ValidateBitcoinURI implements utilsv1connect.UtilsServiceHandler
func (s *Server) ValidateBitcoinURI(_ context.Context, req *utilspb.ValidateBitcoinURIRequest) (*utilspb.ValidateBitcoinURIResponse, error) {
	_, err := engines.ParseBitcoinURI(req.Uri)
	valid := err == nil
	errorMsg := ""
	if err != nil {
		errorMsg = err.Error()
	}

	return &utilspb.ValidateBitcoinURIResponse{
		Valid: valid,
		Error: errorMsg,
	}, nil
}

// DecodeBase58Check implements utilsv1connect.UtilsServiceHandler
func (s *Server) DecodeBase58Check(_ context.Context, req *utilspb.DecodeBase58CheckRequest) (*utilspb.DecodeBase58CheckResponse, error) {
	result, err := engines.DecodeBase58Check(req.Input)
	if err != nil {
		return &utilspb.DecodeBase58CheckResponse{
			Valid: false,
			Error: err.Error(),
		}, nil
	}

	return &utilspb.DecodeBase58CheckResponse{
		Valid:         true,
		VersionByte:   int32(result.VersionByte),
		Payload:       result.Payload,
		Checksum:      result.Checksum,
		ChecksumValid: result.ChecksumValid,
		AddressType:   result.AddressType,
	}, nil
}

// EncodeBase58Check implements utilsv1connect.UtilsServiceHandler
func (s *Server) EncodeBase58Check(_ context.Context, req *utilspb.EncodeBase58CheckRequest) (*utilspb.EncodeBase58CheckResponse, error) {
	if req.VersionByte < 0 || req.VersionByte > math.MaxUint8 {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "version byte %d is not in the range 0 to 255", req.VersionByte)
	}
	return &utilspb.EncodeBase58CheckResponse{
		Encoded: engines.EncodeBase58Check(int(req.VersionByte), req.Data),
	}, nil
}

// CalculateMerkleTree implements utilsv1connect.UtilsServiceHandler
func (s *Server) CalculateMerkleTree(_ context.Context, req *utilspb.CalculateMerkleTreeRequest) (*utilspb.CalculateMerkleTreeResponse, error) {
	result, err := engines.CalculateMerkleTree(req.Txids)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	formatted := result.FormattedText
	if !req.ShowRcb {
		formatted = engines.FormatMerkleTree(result.Levels, nil)
	}

	levels := make([]*utilspb.MerkleTreeLevel, len(result.Levels))
	for i, level := range result.Levels {
		var rcb []string
		if i < len(result.RCBLevels) {
			rcb = result.RCBLevels[i]
		}
		levels[i] = &utilspb.MerkleTreeLevel{
			Level:  int32(i),
			Hashes: level,
			Rcb:    rcb,
		}
	}

	return &utilspb.CalculateMerkleTreeResponse{
		MerkleRoot:    result.MerkleRoot,
		Levels:        levels,
		FormattedText: formatted,
	}, nil
}

// GeneratePaperWallet implements utilsv1connect.UtilsServiceHandler
func (s *Server) GeneratePaperWallet(_ context.Context, _ *emptypb.Empty) (*utilspb.GeneratePaperWalletResponse, error) {
	keypair, err := engines.GeneratePaperWallet(s.chainParams)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	return &utilspb.GeneratePaperWalletResponse{
		PrivateKeyWif: keypair.PrivateKeyWIF,
		PublicAddress: keypair.PublicAddress,
		PrivateKeyHex: keypair.PrivateKeyHex,
	}, nil
}

// ValidateWIF implements utilsv1connect.UtilsServiceHandler
func (s *Server) ValidateWIF(_ context.Context, req *utilspb.ValidateWIFRequest) (*utilspb.ValidateWIFResponse, error) {
	valid := engines.ValidateWIF(req.Wif, s.chainParams)

	return &utilspb.ValidateWIFResponse{
		Valid: valid,
	}, nil
}

// WIFToAddress implements utilsv1connect.UtilsServiceHandler
func (s *Server) WIFToAddress(_ context.Context, req *utilspb.WIFToAddressRequest) (*utilspb.WIFToAddressResponse, error) {
	address, err := engines.WIFToAddress(req.Wif, s.chainParams)
	if err != nil {
		return &utilspb.WIFToAddressResponse{
			Error: err.Error(),
		}, nil
	}

	return &utilspb.WIFToAddressResponse{
		Address: address,
	}, nil
}
