package api_utils

import (
	"context"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	utilspb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/utils/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/utils/v1/utilsv1connect"
	"github.com/btcsuite/btcd/chaincfg"
	"google.golang.org/protobuf/types/known/emptypb"
)

var _ rpc.UtilsServiceHandler = new(Server)

// Server implements the UtilsService
type Server struct {
	chainParams *chaincfg.Params
}

// New creates a new Utils API server
func New(chainParams *chaincfg.Params) *Server {
	return &Server{
		chainParams: chainParams,
	}
}

// ParseBitcoinURI implements utilsv1connect.UtilsServiceHandler
func (s *Server) ParseBitcoinURI(_ context.Context, req *connect.Request[utilspb.ParseBitcoinURIRequest]) (*connect.Response[utilspb.ParseBitcoinURIResponse], error) {
	result, err := engines.ParseBitcoinURI(req.Msg.Uri)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	return connect.NewResponse(&utilspb.ParseBitcoinURIResponse{
		Address:     result.Address,
		Amount:      result.Amount,
		Label:       result.Label,
		Message:     result.Message,
		ExtraParams: result.ExtraParams,
	}), nil
}

// ValidateBitcoinURI implements utilsv1connect.UtilsServiceHandler
func (s *Server) ValidateBitcoinURI(_ context.Context, req *connect.Request[utilspb.ValidateBitcoinURIRequest]) (*connect.Response[utilspb.ValidateBitcoinURIResponse], error) {
	_, err := engines.ParseBitcoinURI(req.Msg.Uri)
	valid := err == nil
	errorMsg := ""
	if err != nil {
		errorMsg = err.Error()
	}

	return connect.NewResponse(&utilspb.ValidateBitcoinURIResponse{
		Valid: valid,
		Error: errorMsg,
	}), nil
}

// DecodeBase58Check implements utilsv1connect.UtilsServiceHandler
func (s *Server) DecodeBase58Check(_ context.Context, req *connect.Request[utilspb.DecodeBase58CheckRequest]) (*connect.Response[utilspb.DecodeBase58CheckResponse], error) {
	result, err := engines.DecodeBase58Check(req.Msg.Input)
	if err != nil {
		return connect.NewResponse(&utilspb.DecodeBase58CheckResponse{
			Valid: false,
			Error: err.Error(),
		}), nil
	}

	return connect.NewResponse(&utilspb.DecodeBase58CheckResponse{
		Valid:         true,
		VersionByte:   int32(result.VersionByte),
		Payload:       result.Payload,
		Checksum:      result.Checksum,
		ChecksumValid: result.ChecksumValid,
		AddressType:   result.AddressType,
	}), nil
}

// EncodeBase58Check implements utilsv1connect.UtilsServiceHandler
func (s *Server) EncodeBase58Check(_ context.Context, req *connect.Request[utilspb.EncodeBase58CheckRequest]) (*connect.Response[utilspb.EncodeBase58CheckResponse], error) {
	encoded, err := engines.EncodeBase58Check(int(req.Msg.VersionByte), req.Msg.Data)
	if err != nil {
		return connect.NewResponse(&utilspb.EncodeBase58CheckResponse{
			Error: err.Error(),
		}), nil
	}

	return connect.NewResponse(&utilspb.EncodeBase58CheckResponse{
		Encoded: encoded,
	}), nil
}

// CalculateMerkleTree implements utilsv1connect.UtilsServiceHandler
func (s *Server) CalculateMerkleTree(_ context.Context, req *connect.Request[utilspb.CalculateMerkleTreeRequest]) (*connect.Response[utilspb.CalculateMerkleTreeResponse], error) {
	result, err := engines.CalculateMerkleTree(req.Msg.Txids)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	// Convert levels to proto format
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

	return connect.NewResponse(&utilspb.CalculateMerkleTreeResponse{
		MerkleRoot:    result.MerkleRoot,
		Levels:        levels,
		FormattedText: result.FormattedText,
	}), nil
}

// GeneratePaperWallet implements utilsv1connect.UtilsServiceHandler
func (s *Server) GeneratePaperWallet(_ context.Context, _ *connect.Request[emptypb.Empty]) (*connect.Response[utilspb.GeneratePaperWalletResponse], error) {
	keypair, err := engines.GeneratePaperWallet(s.chainParams)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&utilspb.GeneratePaperWalletResponse{
		PrivateKeyWif: keypair.PrivateKeyWIF,
		PublicAddress: keypair.PublicAddress,
		PrivateKeyHex: keypair.PrivateKeyHex,
	}), nil
}

// ValidateWIF implements utilsv1connect.UtilsServiceHandler
func (s *Server) ValidateWIF(_ context.Context, req *connect.Request[utilspb.ValidateWIFRequest]) (*connect.Response[utilspb.ValidateWIFResponse], error) {
	valid := engines.ValidateWIF(req.Msg.Wif, s.chainParams)

	return connect.NewResponse(&utilspb.ValidateWIFResponse{
		Valid: valid,
	}), nil
}

// WIFToAddress implements utilsv1connect.UtilsServiceHandler
func (s *Server) WIFToAddress(_ context.Context, req *connect.Request[utilspb.WIFToAddressRequest]) (*connect.Response[utilspb.WIFToAddressResponse], error) {
	address, err := engines.WIFToAddress(req.Msg.Wif, s.chainParams)
	if err != nil {
		return connect.NewResponse(&utilspb.WIFToAddressResponse{
			Error: err.Error(),
		}), nil
	}

	return connect.NewResponse(&utilspb.WIFToAddressResponse{
		Address: address,
	}), nil
}
