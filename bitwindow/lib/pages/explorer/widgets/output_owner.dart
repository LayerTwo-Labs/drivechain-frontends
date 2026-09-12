import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

/// How the active wallet owns [output]. Null when it owns no part of it.
String? outputOwnerLabel(TransactionOutput output) {
  if (output.isChange) {
    return 'Your change';
  }
  if (output.isMine) {
    return 'Your address';
  }
  return null;
}
