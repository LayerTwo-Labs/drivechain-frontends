import 'dart:convert';

import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:fixnum/fixnum.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart' as bwpb;
import 'package:sail_ui/gen/google/protobuf/empty.pb.dart' as emptypb;
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.connect.client.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

/// Shared wallet RPC client backed by orchestrator WalletManagerService.
///
/// This is the shared wallet boundary for BitWindow and sidechain frontends
/// when wallet/runtime ownership lives in orchestrator. Splits unary
/// (HTTP/1.1) and streaming (HTTP/2) over two transports — see
/// [OrchestratorRPC] for why.
class OrchestratorWalletRPC {
  late WalletManagerServiceClient _unaryClient;
  late WalletManagerServiceClient _streamClient;

  static const _defaultTransactionCount = 100;

  /// Create from the two transports owned by [OrchestratorRPC]. Unary RPCs
  /// go to [unary], server-streaming RPCs (currently just `watchWalletData`)
  /// go to [stream].
  OrchestratorWalletRPC.fromTransports({
    required connect.Transport unary,
    required connect.Transport stream,
  }) {
    _unaryClient = WalletManagerServiceClient(unary);
    _streamClient = WalletManagerServiceClient(stream);
  }

  Future<wmpb.GetWalletStatusResponse> getWalletStatus() {
    return _unaryClient.getWalletStatus(wmpb.GetWalletStatusRequest());
  }

  Future<wmpb.ListWalletsResponse> listWallets() {
    return _unaryClient.listWallets(wmpb.ListWalletsRequest());
  }

  Future<wmpb.GenerateWalletResponse> generateWallet({
    required String name,
    String? customMnemonic,
    String? passphrase,
  }) {
    return _unaryClient.generateWallet(
      wmpb.GenerateWalletRequest(
        name: name,
        customMnemonic: customMnemonic ?? '',
        passphrase: passphrase ?? '',
      ),
    );
  }

  Future<wmpb.UnlockWalletResponse> unlockWallet(String password) {
    return _unaryClient.unlockWallet(wmpb.UnlockWalletRequest(password: password));
  }

  Future<wmpb.LockWalletResponse> lockWallet() {
    return _unaryClient.lockWallet(wmpb.LockWalletRequest());
  }

  Future<wmpb.EncryptWalletResponse> encryptWallet(String password) {
    return _unaryClient.encryptWallet(wmpb.EncryptWalletRequest(password: password));
  }

  Future<wmpb.ChangePasswordResponse> changePassword(
    String oldPassword,
    String newPassword,
  ) {
    return _unaryClient.changePassword(
      wmpb.ChangePasswordRequest(
        oldPassword: oldPassword,
        newPassword: newPassword,
      ),
    );
  }

  Future<wmpb.RemoveEncryptionResponse> removeEncryption(String password) {
    return _unaryClient.removeEncryption(
      wmpb.RemoveEncryptionRequest(password: password),
    );
  }

  Future<wmpb.CreateWatchOnlyWalletResponse> createWatchOnlyWallet({
    required String name,
    required String xpubOrDescriptor,
    required String gradientJson,
  }) {
    return _unaryClient.createWatchOnlyWallet(
      wmpb.CreateWatchOnlyWalletRequest(
        name: name,
        xpubOrDescriptor: xpubOrDescriptor,
        gradientJson: gradientJson,
      ),
    );
  }

  Future<wmpb.SwitchWalletResponse> switchWallet(String walletId) {
    return _unaryClient.switchWallet(wmpb.SwitchWalletRequest(walletId: walletId));
  }

  Future<wmpb.UpdateWalletMetadataResponse> updateWalletMetadata({
    required String walletId,
    required String name,
    required String gradientJson,
  }) {
    return _unaryClient.updateWalletMetadata(
      wmpb.UpdateWalletMetadataRequest(
        walletId: walletId,
        name: name,
        gradientJson: gradientJson,
      ),
    );
  }

  Future<wmpb.DeleteWalletResponse> deleteWallet(String walletId) {
    return _unaryClient.deleteWallet(wmpb.DeleteWalletRequest(walletId: walletId));
  }

  Future<wmpb.DeleteAllWalletsResponse> deleteAllWallets() {
    return _unaryClient.deleteAllWallets(wmpb.DeleteAllWalletsRequest());
  }

  Future<wmpb.GetBalanceResponse> getBalance(String walletId) {
    return _unaryClient.getBalance(wmpb.GetBalanceRequest(walletId: walletId));
  }

  Future<wmpb.GetNewAddressResponse> getNewAddress(String walletId) {
    return _unaryClient.getNewAddress(wmpb.GetNewAddressRequest(walletId: walletId));
  }

  Future<wmpb.SendTransactionResponse> sendTransaction({
    required String walletId,
    required Map<String, int> destinations,
    int? feeRateSatPerVbyte,
    int? fixedFeeSats,
    bool subtractFeeFromAmount = false,
    String? opReturnMessage,
    String? opReturnHex,
    List<bwpb.UnspentOutput>? requiredInputs,
  }) {
    final resolvedOpReturnHex =
        opReturnHex ?? (opReturnMessage == null ? null : _bytesToHex(utf8.encode(opReturnMessage)));

    return _unaryClient.sendTransaction(
      wmpb.SendTransactionRequest(
        walletId: walletId,
        destinations: destinations.map((key, value) => MapEntry(key, Int64(value))),
        feeRateSatPerVbyte: Int64(feeRateSatPerVbyte ?? 0),
        subtractFeeFromAmount: subtractFeeFromAmount,
        opReturnHex: resolvedOpReturnHex ?? '',
        fixedFeeSats: Int64(fixedFeeSats ?? 0),
        requiredInputs: requiredInputs?.map(_mapRequiredInput).toList() ?? [],
      ),
    );
  }

  Future<wmpb.ListTransactionsResponse> listTransactions({
    required String walletId,
    int count = _defaultTransactionCount,
  }) {
    return _unaryClient.listTransactions(
      wmpb.ListTransactionsRequest(walletId: walletId, count: count),
    );
  }

  Future<wmpb.ListUnspentResponse> listUnspent(String walletId) {
    return _unaryClient.listUnspent(wmpb.ListUnspentRequest(walletId: walletId));
  }

  Future<wmpb.ListReceiveAddressesResponse> listReceiveAddresses(String walletId) {
    return _unaryClient.listReceiveAddresses(
      wmpb.ListReceiveAddressesRequest(walletId: walletId),
    );
  }

  Future<bwpb.GetTransactionDetailsResponse> getTransactionDetails({
    required String walletId,
    required String txid,
  }) async {
    final response = await _unaryClient.getTransactionDetails(
      wmpb.GetTransactionDetailsRequest(walletId: walletId, txid: txid),
    );

    return bwpb.GetTransactionDetailsResponse(
      txid: response.transaction.txid,
      blockhash: response.blockhash,
      confirmations: response.confirmations,
      blockTime: response.blockTime,
      version: response.version,
      locktime: response.locktime,
      sizeBytes: response.sizeBytes,
      vsizeVbytes: response.vsizeVbytes,
      weightWu: response.weightWu,
      feeSats: Int64(response.feeSats.toInt()),
      feeRateSatVb: response.feeRateSatVb,
      inputs: response.inputs.map(_mapTransactionInput).toList(),
      totalInputSats: Int64(response.totalInputSats.toInt()),
      outputs: response.outputs.map(_mapTransactionOutput).toList(),
      totalOutputSats: Int64(response.totalOutputSats.toInt()),
      hex: response.rawHex,
    );
  }

  Future<wmpb.BumpFeeResponse> bumpFee({
    required String walletId,
    required String txid,
    int? newFeeRate,
  }) {
    return _unaryClient.bumpFee(
      wmpb.BumpFeeRequest(
        walletId: walletId,
        txid: txid,
        newFeeRate: Int64(newFeeRate ?? 0),
      ),
    );
  }

  Stream<wmpb.WatchWalletDataResponse> watchWalletData() {
    return _streamClient.watchWalletData(emptypb.Empty());
  }

  Future<wmpb.ListCoreVariantsResponse> listCoreVariants() {
    return _unaryClient.listCoreVariants(wmpb.ListCoreVariantsRequest());
  }

  Future<wmpb.GetCoreVariantResponse> getCoreVariant() {
    return _unaryClient.getCoreVariant(wmpb.GetCoreVariantRequest());
  }

  Future<wmpb.SetCoreVariantResponse> setCoreVariant(String id) {
    return _unaryClient.setCoreVariant(wmpb.SetCoreVariantRequest(id: id));
  }

  Future<wmpb.GetTestSidechainsResponse> getTestSidechains() {
    return _unaryClient.getTestSidechains(wmpb.GetTestSidechainsRequest());
  }

  Future<wmpb.SetTestSidechainsResponse> setTestSidechains(bool enabled) {
    return _unaryClient.setTestSidechains(wmpb.SetTestSidechainsRequest(enabled: enabled));
  }

  String _bytesToHex(List<int> bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  wmpb.UnspentOutput _mapRequiredInput(bwpb.UnspentOutput utxo) {
    final (txid, vout) = _parseOutpoint(utxo.output);
    return wmpb.UnspentOutput(
      txid: txid,
      vout: vout,
      address: utxo.address,
      amountSats: Int64(utxo.valueSats.toInt()),
      label: utxo.label,
    );
  }

  (String, int) _parseOutpoint(String outpoint) {
    final parts = outpoint.split(':');
    if (parts.length != 2) {
      throw ArgumentError('invalid outpoint: $outpoint');
    }

    final vout = int.tryParse(parts[1]);
    if (vout == null) {
      throw ArgumentError('invalid outpoint vout: $outpoint');
    }

    return (parts[0], vout);
  }

  bwpb.TransactionInput _mapTransactionInput(wmpb.TransactionInput input) {
    return bwpb.TransactionInput(
      index: input.index,
      prevTxid: input.prevTxid,
      prevVout: input.prevVout,
      address: input.address,
      valueSats: Int64(input.valueSats.toInt()),
      scriptSigAsm: input.scriptSigAsm,
      scriptSigHex: input.scriptSigHex,
      witness: input.witness,
      sequence: Int64(input.sequence.toInt()),
      isCoinbase: input.isCoinbase,
    );
  }

  bwpb.TransactionOutput _mapTransactionOutput(wmpb.TransactionOutput output) {
    return bwpb.TransactionOutput(
      index: output.index,
      valueSats: Int64(output.valueSats.toInt()),
      address: output.address,
      scriptType: output.scriptType,
      scriptPubkeyAsm: output.scriptPubkeyAsm,
      scriptPubkeyHex: output.scriptPubkeyHex,
    );
  }
}
