//
//  Generated code. Do not modify.
//  source: utils/v1/utils.proto
//

import "package:connectrpc/connect.dart" as connect;
import "utils.pb.dart" as utilsv1utils;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

abstract final class UtilsService {
  /// Fully-qualified name of the UtilsService service.
  static const name = 'utils.v1.UtilsService';

  /// Bitcoin URI parsing (BIP-0021)
  static const parseBitcoinURI = connect.Spec(
    '/$name/ParseBitcoinURI',
    connect.StreamType.unary,
    utilsv1utils.ParseBitcoinURIRequest.new,
    utilsv1utils.ParseBitcoinURIResponse.new,
  );

  static const validateBitcoinURI = connect.Spec(
    '/$name/ValidateBitcoinURI',
    connect.StreamType.unary,
    utilsv1utils.ValidateBitcoinURIRequest.new,
    utilsv1utils.ValidateBitcoinURIResponse.new,
  );

  /// Base58Check encoding/decoding
  static const decodeBase58Check = connect.Spec(
    '/$name/DecodeBase58Check',
    connect.StreamType.unary,
    utilsv1utils.DecodeBase58CheckRequest.new,
    utilsv1utils.DecodeBase58CheckResponse.new,
  );

  static const encodeBase58Check = connect.Spec(
    '/$name/EncodeBase58Check',
    connect.StreamType.unary,
    utilsv1utils.EncodeBase58CheckRequest.new,
    utilsv1utils.EncodeBase58CheckResponse.new,
  );

  /// Merkle Tree calculation
  static const calculateMerkleTree = connect.Spec(
    '/$name/CalculateMerkleTree',
    connect.StreamType.unary,
    utilsv1utils.CalculateMerkleTreeRequest.new,
    utilsv1utils.CalculateMerkleTreeResponse.new,
  );

  /// Paper Wallet generation
  static const generatePaperWallet = connect.Spec(
    '/$name/GeneratePaperWallet',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    utilsv1utils.GeneratePaperWalletResponse.new,
  );

  static const validateWIF = connect.Spec(
    '/$name/ValidateWIF',
    connect.StreamType.unary,
    utilsv1utils.ValidateWIFRequest.new,
    utilsv1utils.ValidateWIFResponse.new,
  );

  static const wIFToAddress = connect.Spec(
    '/$name/WIFToAddress',
    connect.StreamType.unary,
    utilsv1utils.WIFToAddressRequest.new,
    utilsv1utils.WIFToAddressResponse.new,
  );
}
