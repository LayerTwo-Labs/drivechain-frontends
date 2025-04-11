//
//  Generated code. Do not modify.
//  source: multisig/v1/multisig.proto
//

import "package:connectrpc/connect.dart" as connect;
import "multisig.pb.dart" as multisigv1multisig;
import "multisig.connect.spec.dart" as specs;

/// Service definition for multisig operations
extension type MultisigServiceClient (connect.Transport _transport) {
  /// Address management
  Future<multisigv1multisig.AddMultisigAddressResponse> addMultisigAddress(
    multisigv1multisig.AddMultisigAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.addMultisigAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.ImportAddressResponse> importAddress(
    multisigv1multisig.ImportAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.importAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.GetAddressInfoResponse> getAddressInfo(
    multisigv1multisig.GetAddressInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.getAddressInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// UTXO management
  Future<multisigv1multisig.ListUnspentResponse> listUnspent(
    multisigv1multisig.ListUnspentRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.listUnspent,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.ListAddressGroupingsResponse> listAddressGroupings(
    multisigv1multisig.ListAddressGroupingsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.listAddressGroupings,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Transaction creation
  Future<multisigv1multisig.CreateRawTransactionResponse> createRawTransaction(
    multisigv1multisig.CreateRawTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.createRawTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.CreatePsbtResponse> createPsbt(
    multisigv1multisig.CreatePsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.createPsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.WalletCreateFundedPsbtResponse> walletCreateFundedPsbt(
    multisigv1multisig.WalletCreateFundedPsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.walletCreateFundedPsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// PSBT handling
  Future<multisigv1multisig.DecodePsbtResponse> decodePsbt(
    multisigv1multisig.DecodePsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.decodePsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.AnalyzePsbtResponse> analyzePsbt(
    multisigv1multisig.AnalyzePsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.analyzePsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.WalletProcessPsbtResponse> walletProcessPsbt(
    multisigv1multisig.WalletProcessPsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.walletProcessPsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.CombinePsbtResponse> combinePsbt(
    multisigv1multisig.CombinePsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.combinePsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.FinalizePsbtResponse> finalizePsbt(
    multisigv1multisig.FinalizePsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.finalizePsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.UtxoUpdatePsbtResponse> utxoUpdatePsbt(
    multisigv1multisig.UtxoUpdatePsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.utxoUpdatePsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.JoinPsbtsResponse> joinPsbts(
    multisigv1multisig.JoinPsbtsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.joinPsbts,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Transaction signing
  Future<multisigv1multisig.SignRawTransactionWithWalletResponse> signRawTransactionWithWallet(
    multisigv1multisig.SignRawTransactionWithWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.signRawTransactionWithWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Transaction misc
  Future<multisigv1multisig.SendRawTransactionResponse> sendRawTransaction(
    multisigv1multisig.SendRawTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.sendRawTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.TestMempoolAcceptResponse> testMempoolAccept(
    multisigv1multisig.TestMempoolAcceptRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.testMempoolAccept,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.GetTransactionResponse> getTransaction(
    multisigv1multisig.GetTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.getTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
