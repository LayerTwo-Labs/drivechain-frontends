//
//  Generated code. Do not modify.
//  source: multisig/v1/multisig.proto
//

import "package:connectrpc/connect.dart" as connect;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;
import "multisig.pb.dart" as multisigv1multisig;

abstract final class MultisigService {
  /// Fully-qualified name of the MultisigService service.
  static const name = 'multisig.v1.MultisigService';

  /// Group CRUD
  static const listGroups = connect.Spec(
    '/$name/ListGroups',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    multisigv1multisig.ListGroupsResponse.new,
  );

  static const saveGroup = connect.Spec(
    '/$name/SaveGroup',
    connect.StreamType.unary,
    multisigv1multisig.SaveGroupRequest.new,
    multisigv1multisig.SaveGroupResponse.new,
  );

  static const deleteGroup = connect.Spec(
    '/$name/DeleteGroup',
    connect.StreamType.unary,
    multisigv1multisig.DeleteGroupRequest.new,
    googleprotobufempty.Empty.new,
  );

  /// Transaction CRUD
  static const listTransactions = connect.Spec(
    '/$name/ListTransactions',
    connect.StreamType.unary,
    multisigv1multisig.ListTransactionsRequest.new,
    multisigv1multisig.ListTransactionsResponse.new,
  );

  static const getTransaction = connect.Spec(
    '/$name/GetTransaction',
    connect.StreamType.unary,
    multisigv1multisig.GetTransactionRequest.new,
    multisigv1multisig.MultisigTransaction.new,
  );

  static const getTransactionByTxid = connect.Spec(
    '/$name/GetTransactionByTxid',
    connect.StreamType.unary,
    multisigv1multisig.GetTransactionByTxidRequest.new,
    multisigv1multisig.MultisigTransaction.new,
  );

  static const saveTransaction = connect.Spec(
    '/$name/SaveTransaction',
    connect.StreamType.unary,
    multisigv1multisig.SaveTransactionRequest.new,
    multisigv1multisig.SaveTransactionResponse.new,
  );

  /// Solo key management
  static const listSoloKeys = connect.Spec(
    '/$name/ListSoloKeys',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    multisigv1multisig.ListSoloKeysResponse.new,
  );

  static const addSoloKey = connect.Spec(
    '/$name/AddSoloKey',
    connect.StreamType.unary,
    multisigv1multisig.AddSoloKeyRequest.new,
    googleprotobufempty.Empty.new,
  );

  /// Account index
  static const getNextAccountIndex = connect.Spec(
    '/$name/GetNextAccountIndex',
    connect.StreamType.unary,
    multisigv1multisig.GetNextAccountIndexRequest.new,
    multisigv1multisig.GetNextAccountIndexResponse.new,
  );
}
