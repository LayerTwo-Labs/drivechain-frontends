import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/chains.dart';
import 'package:sail_ui/widgets/components/core_transaction.dart';

/// RPC connection for all sidechain nodes
abstract class SidechainRPC extends RPCConnection {
  SidechainRPC({
    required super.conf,
    required this.chain,
    required super.binary,
    required super.restartOnFailure,
  });

  Future<dynamic> callRAW(String method, [List<dynamic>? params]);

  Future<List<CoreTransaction>> listTransactions();
  List<String> getMethods();

  Future<String> mainSend(
    String address,
    double amount,
    double sidechainFee,
    double mainchainFee,
  );
  Future<String> getDepositAddress();

  Future<String> sideSend(
    String address,
    double amount,
    bool subtractFeeFromAmount,
  );
  Future<String> getSideAddress();
  Future<double> sideEstimateFee();

  Sidechain chain;
}

class RPCError {
  static const errMisc = -3;
  static const errNoWithdrawalBundle = -100;
  static const errWithdrawalNotFound = -101;
}
