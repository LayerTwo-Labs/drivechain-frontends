import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/rpc.dart';

Future<String> fetchWithdrawalBundleStatus() async {
  try {
    final status = await rpc.call("getwithdrawalbundle", []);

    log.i(
      "fetched withdrawal bundle status: no clue what happens now",
      error: status,
    );
    return status.toString();
  } on RPCException catch (e) {
    if (e.errorCode != errNoWithdrawalBundle) {
      return "unexpected withdrawal bundle status: $e";
    }

    return "no withdrawal bundle yet";
  } catch (e) {
    log.e("could not fetch withdrawal bundle: $e", error: e);
    rethrow;
  }
}
