import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:fixnum/fixnum.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.connect.client.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

/// Shared wallet RPC client backed by orchestrator WalletManagerService.
///
/// This is the shared wallet boundary for BitWindow and sidechain frontends
/// when wallet/runtime ownership lives in orchestrator.
class OrchestratorWalletRPC {
  late WalletManagerServiceClient _client;

  static const _defaultTransactionCount = 100;

  OrchestratorWalletRPC({required String host, required int port}) {
    final transport = connect.Transport(
      baseUrl: 'http://$host:$port',
      codec: const ProtoCodec(),
      httpClient: createHttpClient(),
    );
    _client = WalletManagerServiceClient(transport);
  }

  Future<wmpb.GetWalletStatusResponse> getWalletStatus() {
    return _client.getWalletStatus(wmpb.GetWalletStatusRequest());
  }

  Future<wmpb.ListWalletsResponse> listWallets() {
    return _client.listWallets(wmpb.ListWalletsRequest());
  }

  Future<wmpb.GenerateWalletResponse> generateWallet({
    required String name,
    String? customMnemonic,
    String? passphrase,
  }) {
    return _client.generateWallet(
      wmpb.GenerateWalletRequest(
        name: name,
        customMnemonic: customMnemonic ?? '',
        passphrase: passphrase ?? '',
      ),
    );
  }

  Future<wmpb.UnlockWalletResponse> unlockWallet(String password) {
    return _client.unlockWallet(wmpb.UnlockWalletRequest(password: password));
  }

  Future<wmpb.LockWalletResponse> lockWallet() {
    return _client.lockWallet(wmpb.LockWalletRequest());
  }

  Future<wmpb.EncryptWalletResponse> encryptWallet(String password) {
    return _client.encryptWallet(wmpb.EncryptWalletRequest(password: password));
  }

  Future<wmpb.ChangePasswordResponse> changePassword(
    String oldPassword,
    String newPassword,
  ) {
    return _client.changePassword(
      wmpb.ChangePasswordRequest(
        oldPassword: oldPassword,
        newPassword: newPassword,
      ),
    );
  }

  Future<wmpb.RemoveEncryptionResponse> removeEncryption(String password) {
    return _client.removeEncryption(
      wmpb.RemoveEncryptionRequest(password: password),
    );
  }

  Future<wmpb.CreateWatchOnlyWalletResponse> createWatchOnlyWallet({
    required String name,
    required String xpubOrDescriptor,
    required String gradientJson,
  }) {
    return _client.createWatchOnlyWallet(
      wmpb.CreateWatchOnlyWalletRequest(
        name: name,
        xpubOrDescriptor: xpubOrDescriptor,
        gradientJson: gradientJson,
      ),
    );
  }

  Future<wmpb.SwitchWalletResponse> switchWallet(String walletId) {
    return _client.switchWallet(wmpb.SwitchWalletRequest(walletId: walletId));
  }

  Future<wmpb.UpdateWalletMetadataResponse> updateWalletMetadata({
    required String walletId,
    required String name,
    required String gradientJson,
  }) {
    return _client.updateWalletMetadata(
      wmpb.UpdateWalletMetadataRequest(
        walletId: walletId,
        name: name,
        gradientJson: gradientJson,
      ),
    );
  }

  Future<wmpb.DeleteWalletResponse> deleteWallet(String walletId) {
    return _client.deleteWallet(wmpb.DeleteWalletRequest(walletId: walletId));
  }

  Future<wmpb.DeleteAllWalletsResponse> deleteAllWallets() {
    return _client.deleteAllWallets(wmpb.DeleteAllWalletsRequest());
  }

  Future<wmpb.GetBalanceResponse> getBalance(String walletId) {
    return _client.getBalance(wmpb.GetBalanceRequest(walletId: walletId));
  }

  Future<wmpb.GetNewAddressResponse> getNewAddress(String walletId) {
    return _client.getNewAddress(wmpb.GetNewAddressRequest(walletId: walletId));
  }

  Future<wmpb.SendTransactionResponse> sendTransaction({
    required String walletId,
    required Map<String, int> destinations,
    int? feeRateSatPerVbyte,
    bool subtractFeeFromAmount = false,
    String? opReturnHex,
  }) {
    return _client.sendTransaction(
      wmpb.SendTransactionRequest(
        walletId: walletId,
        destinations: destinations.map((key, value) => MapEntry(key, Int64(value))),
        feeRateSatPerVbyte: Int64(feeRateSatPerVbyte ?? 0),
        subtractFeeFromAmount: subtractFeeFromAmount,
        opReturnHex: opReturnHex ?? '',
      ),
    );
  }

  Future<wmpb.ListTransactionsResponse> listTransactions({
    required String walletId,
    int count = _defaultTransactionCount,
  }) {
    return _client.listTransactions(
      wmpb.ListTransactionsRequest(walletId: walletId, count: count),
    );
  }

  Future<wmpb.ListUnspentResponse> listUnspent(String walletId) {
    return _client.listUnspent(wmpb.ListUnspentRequest(walletId: walletId));
  }

  Future<wmpb.ListReceiveAddressesResponse> listReceiveAddresses(String walletId) {
    return _client.listReceiveAddresses(
      wmpb.ListReceiveAddressesRequest(walletId: walletId),
    );
  }

  Future<wmpb.GetTransactionDetailsResponse> getTransactionDetails({
    required String walletId,
    required String txid,
  }) {
    return _client.getTransactionDetails(
      wmpb.GetTransactionDetailsRequest(walletId: walletId, txid: txid),
    );
  }

  Future<wmpb.BumpFeeResponse> bumpFee({
    required String walletId,
    required String txid,
    int? newFeeRate,
  }) {
    return _client.bumpFee(
      wmpb.BumpFeeRequest(
        walletId: walletId,
        txid: txid,
        newFeeRate: Int64(newFeeRate ?? 0),
      ),
    );
  }
}
