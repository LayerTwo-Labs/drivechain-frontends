//
//  Generated code. Do not modify.
//  source: multisig/v1/multisig.proto
//

import "package:connectrpc/connect.dart" as connect;
import "multisig.pb.dart" as multisigv1multisig;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;
import "multisig.connect.spec.dart" as specs;

extension type MultisigServiceClient(connect.Transport _transport) {
  /// Group CRUD
  Future<multisigv1multisig.ListGroupsResponse> listGroups(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.listGroups,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.SaveGroupResponse> saveGroup(
    multisigv1multisig.SaveGroupRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.saveGroup,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<googleprotobufempty.Empty> deleteGroup(
    multisigv1multisig.DeleteGroupRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.deleteGroup,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Transaction CRUD
  Future<multisigv1multisig.ListTransactionsResponse> listTransactions(
    multisigv1multisig.ListTransactionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.listTransactions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.MultisigTransaction> getTransaction(
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

  Future<multisigv1multisig.MultisigTransaction> getTransactionByTxid(
    multisigv1multisig.GetTransactionByTxidRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.getTransactionByTxid,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<multisigv1multisig.SaveTransactionResponse> saveTransaction(
    multisigv1multisig.SaveTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.saveTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Solo key management
  Future<multisigv1multisig.ListSoloKeysResponse> listSoloKeys(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.listSoloKeys,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<googleprotobufempty.Empty> addSoloKey(
    multisigv1multisig.AddSoloKeyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.addSoloKey,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Account index
  Future<multisigv1multisig.GetNextAccountIndexResponse> getNextAccountIndex(
    multisigv1multisig.GetNextAccountIndexRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigService.getNextAccountIndex,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
