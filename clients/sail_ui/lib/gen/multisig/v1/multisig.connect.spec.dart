//
//  Generated code. Do not modify.
//  source: multisig/v1/multisig.proto
//

import "package:connectrpc/connect.dart" as connect;
import "multisig.pb.dart" as multisigv1multisig;

/// Service definition for multisig operations
abstract final class MultisigService {
  /// Fully-qualified name of the MultisigService service.
  static const name = 'multisig.v1.MultisigService';

  /// Address management
  static const addMultisigAddress = connect.Spec(
    '/$name/AddMultisigAddress',
    connect.StreamType.unary,
    multisigv1multisig.AddMultisigAddressRequest.new,
    multisigv1multisig.AddMultisigAddressResponse.new,
  );

  static const importAddress = connect.Spec(
    '/$name/ImportAddress',
    connect.StreamType.unary,
    multisigv1multisig.ImportAddressRequest.new,
    multisigv1multisig.ImportAddressResponse.new,
  );

  static const getAddressInfo = connect.Spec(
    '/$name/GetAddressInfo',
    connect.StreamType.unary,
    multisigv1multisig.GetAddressInfoRequest.new,
    multisigv1multisig.GetAddressInfoResponse.new,
  );

  /// UTXO management
  static const listUnspent = connect.Spec(
    '/$name/ListUnspent',
    connect.StreamType.unary,
    multisigv1multisig.ListUnspentRequest.new,
    multisigv1multisig.ListUnspentResponse.new,
  );

  static const listAddressGroupings = connect.Spec(
    '/$name/ListAddressGroupings',
    connect.StreamType.unary,
    multisigv1multisig.ListAddressGroupingsRequest.new,
    multisigv1multisig.ListAddressGroupingsResponse.new,
  );

  /// Transaction creation
  static const createRawTransaction = connect.Spec(
    '/$name/CreateRawTransaction',
    connect.StreamType.unary,
    multisigv1multisig.CreateRawTransactionRequest.new,
    multisigv1multisig.CreateRawTransactionResponse.new,
  );

  static const createPsbt = connect.Spec(
    '/$name/CreatePsbt',
    connect.StreamType.unary,
    multisigv1multisig.CreatePsbtRequest.new,
    multisigv1multisig.CreatePsbtResponse.new,
  );

  static const walletCreateFundedPsbt = connect.Spec(
    '/$name/WalletCreateFundedPsbt',
    connect.StreamType.unary,
    multisigv1multisig.WalletCreateFundedPsbtRequest.new,
    multisigv1multisig.WalletCreateFundedPsbtResponse.new,
  );

  /// PSBT handling
  static const decodePsbt = connect.Spec(
    '/$name/DecodePsbt',
    connect.StreamType.unary,
    multisigv1multisig.DecodePsbtRequest.new,
    multisigv1multisig.DecodePsbtResponse.new,
  );

  static const analyzePsbt = connect.Spec(
    '/$name/AnalyzePsbt',
    connect.StreamType.unary,
    multisigv1multisig.AnalyzePsbtRequest.new,
    multisigv1multisig.AnalyzePsbtResponse.new,
  );

  static const walletProcessPsbt = connect.Spec(
    '/$name/WalletProcessPsbt',
    connect.StreamType.unary,
    multisigv1multisig.WalletProcessPsbtRequest.new,
    multisigv1multisig.WalletProcessPsbtResponse.new,
  );

  static const combinePsbt = connect.Spec(
    '/$name/CombinePsbt',
    connect.StreamType.unary,
    multisigv1multisig.CombinePsbtRequest.new,
    multisigv1multisig.CombinePsbtResponse.new,
  );

  static const finalizePsbt = connect.Spec(
    '/$name/FinalizePsbt',
    connect.StreamType.unary,
    multisigv1multisig.FinalizePsbtRequest.new,
    multisigv1multisig.FinalizePsbtResponse.new,
  );

  static const utxoUpdatePsbt = connect.Spec(
    '/$name/UtxoUpdatePsbt',
    connect.StreamType.unary,
    multisigv1multisig.UtxoUpdatePsbtRequest.new,
    multisigv1multisig.UtxoUpdatePsbtResponse.new,
  );

  static const joinPsbts = connect.Spec(
    '/$name/JoinPsbts',
    connect.StreamType.unary,
    multisigv1multisig.JoinPsbtsRequest.new,
    multisigv1multisig.JoinPsbtsResponse.new,
  );

  /// Transaction signing
  static const signRawTransactionWithWallet = connect.Spec(
    '/$name/SignRawTransactionWithWallet',
    connect.StreamType.unary,
    multisigv1multisig.SignRawTransactionWithWalletRequest.new,
    multisigv1multisig.SignRawTransactionWithWalletResponse.new,
  );

  /// Transaction misc
  static const sendRawTransaction = connect.Spec(
    '/$name/SendRawTransaction',
    connect.StreamType.unary,
    multisigv1multisig.SendRawTransactionRequest.new,
    multisigv1multisig.SendRawTransactionResponse.new,
  );

  static const testMempoolAccept = connect.Spec(
    '/$name/TestMempoolAccept',
    connect.StreamType.unary,
    multisigv1multisig.TestMempoolAcceptRequest.new,
    multisigv1multisig.TestMempoolAcceptResponse.new,
  );

  static const getTransaction = connect.Spec(
    '/$name/GetTransaction',
    connect.StreamType.unary,
    multisigv1multisig.GetTransactionRequest.new,
    multisigv1multisig.GetTransactionResponse.new,
  );
}
