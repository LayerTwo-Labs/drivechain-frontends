import 'dart:convert';

import 'package:connectrpc/protobuf.dart';
import 'package:sail_ui/rpcs/keepalive_http_client.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:convert/convert.dart' show hex;
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/gen/bitnames/v1/bitnames.connect.client.dart';
import 'package:sail_ui/gen/bitnames/v1/bitnames.pb.dart' as pb;
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/rpcs/thunder_utxo.dart';
import 'package:sail_ui/settings/client_settings.dart';
import 'package:sail_ui/settings/hash_plaintext_settings.dart';
import 'package:sail_ui/widgets/components/core_transaction.dart';

/// API to the bitnames server.
abstract class BitnamesRPC extends SidechainRPC {
  BitnamesRPC({required super.binaryType});

  /// Get balance in sats
  Future<BalanceResponse> getBalance();

  /// Get BitName data
  Future<BitNameData?> getBitNameData(String name);

  /// List all BitNames
  Future<List<BitnameEntry>> listBitNames();

  /// Connect to a peer
  Future<void> connectPeer(String address);

  /// List peers
  Future<List<BitnamesPeerInfo>> listPeers();

  /// Register a BitName
  Future<String> registerBitName(String plainName, BitNameData? data);

  /// Reserve a BitName
  Future<String> reserveBitName(String name);

  /// Get block data
  Future<Map<String, dynamic>?> getBlock(String hash);

  /// Get mainchain blocks that commit to a specified block hash
  Future<String> getBMMInclusions(String blockHash);

  /// Get the best known mainchain block hash
  Future<String?> getBestMainchainBlockHash();

  /// Get the best sidechain block hash known by Bitnames
  Future<String?> getBestSidechainBlockHash();

  /// Generate a mnemonic seed phrase
  Future<String> generateMnemonic();

  /// Set the wallet seed from a mnemonic seed phrase
  Future<void> setSeedFromMnemonic(String mnemonic);

  /// Get total sidechain wealth in sats
  Future<int> getSidechainWealth();

  /// Get a new encryption key
  Future<String> getNewEncryptionKey();

  /// Get a new verifying/signing key
  Future<String> getNewVerifyingKey();

  /// Create a deposit to an address
  Future<String> createDeposit({
    required String address,
    required int feeSats,
    required int valueSats,
  });

  /// Decrypt a message with the specified encryption key
  Future<String> decryptMsg({
    required String ciphertext,
    required String encryptionPubkey,
  });

  /// Encrypt a message to the specified encryption pubkey
  Future<String> encryptMsg({
    required String msg,
    required String encryptionPubkey,
  });

  /// Get a new address
  Future<String> getNewAddress();

  /// Get the current block count
  @override
  Future<int> getBlockCount();

  /// Get all paymail
  Future<Map<String, dynamic>> getPaymail();

  /// Get wallet addresses, sorted by base58 encoding
  Future<List<String>> getWalletAddresses();

  /// Get wallet UTXOs
  Future<List<dynamic>> getWalletUTXOs();

  /// List all UTXOs
  @override
  Future<List<SidechainUTXO>> listUTXOs();

  /// List owned UTXOs
  Future<List<dynamic>> myUTXOs();

  /// Get OpenAPI schema
  Future<Map<String, dynamic>> openapiSchema();

  /// Resolve a commitment from a BitName
  Future<String> resolveCommit(String bitname);

  /// Sign an arbitrary message with the specified verifying key
  Future<String> signArbitraryMsg({
    required String msg,
    required String verifyingKey,
  });

  /// Sign an arbitrary message with the secret key for the specified address
  Future<Map<String, String>> signArbitraryMsgAsAddr({
    required String msg,
    required String address,
  });

  /// Transfer funds to the specified address
  Future<String> transfer({
    required String dest,
    required int value,
    required int fee,
    String? memo,
  });
}

class BitnamesLive extends BitnamesRPC {
  @override
  final log = GetIt.I.get<Logger>();

  late BitnamesServiceClient _client;

  BitnamesLive() : super(binaryType: BinaryType.bitnames) {
    final transport = connect.Transport(
      baseUrl: 'http://localhost:30400',
      codec: const ProtoCodec(),
      httpClient: unaryHttpClient(),
    );
    _client = BitnamesServiceClient(transport);
  }

  @override
  Future<List<String>> binaryArgs() async => [];

  @override
  Future<(double, double)> balance() async {
    final resp = await _client.getBalance(pb.GetBalanceRequest());
    final confirmed = satoshiToBTC(resp.availableSats.toInt());
    final unconfirmed = satoshiToBTC((resp.totalSats - resp.availableSats).toInt());
    return (confirmed, unconfirmed);
  }

  @override
  Future<int> getBlockCount() async {
    final resp = await _client.getBlockCount(pb.GetBlockCountRequest());
    return resp.count.toInt();
  }

  @override
  Future<void> stopRPC() async {
    await _client.stop(pb.StopRequest());
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final blocks = await getBlockCount();
    final explorerHeaders = await fetchExplorerHeaders();
    final headers = explorerHeaders ?? blocks;
    final bestBlockHash = await getBestSidechainBlockHash();

    return BlockchainInfo(
      chain: 'signet',
      blocks: blocks,
      headers: headers,
      bestBlockHash: bestBlockHash ?? '',
      difficulty: 0,
      time: 0,
      medianTime: 0,
      verificationProgress: 100.0,
      initialBlockDownload: false,
      chainWork: '',
      sizeOnDisk: 0,
      pruned: false,
      warnings: [],
    );
  }

  @override
  List<String> getMethods() => bitnamesRPCMethods;

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async {
    final paramsJson = params != null ? jsonEncode(params) : '';
    final resp = await _client.callRaw(pb.CallRawRequest(method: method, paramsJson: paramsJson));
    if (resp.resultJson.isEmpty) return null;
    return jsonDecode(resp.resultJson);
  }

  @override
  Future<String> getDepositAddress() async {
    final resp = await _client.getNewAddress(pb.GetNewAddressRequest());
    return formatDepositAddress(resp.address, chain.slot);
  }

  @override
  Future<String> getSideAddress() async {
    final resp = await _client.getNewAddress(pb.GetNewAddressRequest());
    return resp.address;
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    throw UnimplementedError();
  }

  @override
  Future<double> sideEstimateFee() async => 0.00001;

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    final resp = await _client.transfer(
      pb.TransferRequest(
        address: address,
        amountSats: Int64(btcToSatoshi(amount).toInt()),
        feeSats: Int64(btcToSatoshi(0.00001).toInt()),
      ),
    );
    return resp.txid;
  }

  @override
  Future<BalanceResponse> getBalance() async {
    final resp = await _client.getBalance(pb.GetBalanceRequest());
    return BalanceResponse(
      totalSats: resp.totalSats.toInt(),
      availableSats: resp.availableSats.toInt(),
    );
  }

  @override
  Future<BitNameData?> getBitNameData(String name) async {
    final resp = await _client.getBitNameData(pb.GetBitNameDataRequest(name: name));
    if (resp.dataJson.isEmpty) return null;
    final decoded = jsonDecode(resp.dataJson) as Map<String, dynamic>;
    return BitNameData.fromJson(decoded);
  }

  @override
  Future<List<BitnameEntry>> listBitNames() async {
    final clientSettings = GetIt.I.get<ClientSettings>();

    Map<String, String>? hashNameMapping;
    try {
      final settingValue = await clientSettings.getValue(
        HashNameMappingSetting(),
      );
      hashNameMapping = Map.fromEntries(
        settingValue.value.entries.map((e) => MapEntry(e.key, e.value.name)),
      );
    } catch (e) {
      // do nothing
    }

    final resp = await _client.listBitNames(pb.ListBitNamesRequest());
    if (resp.bitnamesJson.isEmpty) return [];
    final response = jsonDecode(resp.bitnamesJson) as List<dynamic>;
    return response.map<BitnameEntry>((item) {
      if (item is! List || item.length != 2) {
        throw FormatException('Invalid bitname entry format: $item');
      }

      final hash = item[0] as String;
      final detailsMap = item[1] as Map<String, dynamic>;

      String? parseCommitment(dynamic value) {
        if (value == null) return null;
        if (value is String) return value;
        if (value is List) {
          return value.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');
        }
        return value.toString();
      }

      final parsedDetails = Map<String, dynamic>.from(detailsMap);
      if (detailsMap.containsKey('commitment')) {
        parsedDetails['commitment'] = parseCommitment(detailsMap['commitment']);
      }

      final details = BitnameDetails.fromJson(parsedDetails);
      return BitnameEntry(
        hash: hash,
        details: details,
        plaintextName: hashNameMapping?[hash],
      );
    }).toList();
  }

  @override
  Future<void> connectPeer(String address) async {
    await _client.connectPeer(pb.ConnectPeerRequest(address: address));
  }

  @override
  Future<List<BitnamesPeerInfo>> listPeers() async {
    final resp = await _client.listPeers(pb.ListPeersRequest());
    if (resp.peersJson.isEmpty) return [];
    final decoded = jsonDecode(resp.peersJson) as List<dynamic>;
    return decoded.map((e) => BitnamesPeerInfo.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<String> registerBitName(String plainName, BitNameData? data) async {
    final dataJson = data != null ? jsonEncode(data.toJson()) : '';
    final resp = await _client.registerBitName(
      pb.RegisterBitNameRequest(
        plainName: plainName,
        dataJson: dataJson,
      ),
    );
    return resp.txid;
  }

  @override
  Future<String> reserveBitName(String name) async {
    final resp = await _client.reserveBitName(pb.ReserveBitNameRequest(name: name));
    return resp.txid;
  }

  @override
  Future<Map<String, dynamic>?> getBlock(String hash) async {
    final resp = await _client.getBlock(pb.GetBlockRequest(hash: hash));
    if (resp.blockJson.isEmpty) return null;
    return jsonDecode(resp.blockJson) as Map<String, dynamic>;
  }

  @override
  Future<String> getBMMInclusions(String blockHash) async {
    final resp = await _client.getBmmInclusions(pb.GetBmmInclusionsRequest(blockHash: blockHash));
    return resp.inclusions;
  }

  @override
  Future<String?> getBestMainchainBlockHash() async {
    final resp = await _client.getBestMainchainBlockHash(pb.GetBestMainchainBlockHashRequest());
    return resp.hash.isEmpty ? null : resp.hash;
  }

  @override
  Future<String?> getBestSidechainBlockHash() async {
    final resp = await _client.getBestSidechainBlockHash(pb.GetBestSidechainBlockHashRequest());
    return resp.hash.isEmpty ? null : resp.hash;
  }

  @override
  Future<int?> getLatestFailedWithdrawalBundleHeight() async {
    final resp = await _client.getLatestFailedWithdrawalBundleHeight(
      pb.GetLatestFailedWithdrawalBundleHeightRequest(),
    );
    return resp.height == 0 ? null : resp.height.toInt();
  }

  @override
  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle() async {
    final resp = await _client.getPendingWithdrawalBundle(pb.GetPendingWithdrawalBundleRequest());
    if (resp.bundleJson.isEmpty) return null;
    final decoded = jsonDecode(resp.bundleJson);
    return PendingWithdrawalBundle.fromJson(decoded as Map<String, dynamic>);
  }

  @override
  Future<String> generateMnemonic() async {
    final resp = await _client.generateMnemonic(pb.GenerateMnemonicRequest());
    return resp.mnemonic;
  }

  @override
  Future<void> setSeedFromMnemonic(String mnemonic) async {
    await _client.setSeedFromMnemonic(pb.SetSeedFromMnemonicRequest(mnemonic: mnemonic));
  }

  @override
  Future<int> getSidechainWealth() async {
    final resp = await _client.getSidechainWealth(pb.GetSidechainWealthRequest());
    return resp.sats.toInt();
  }

  @override
  Future<String> getNewEncryptionKey() async {
    final resp = await _client.getNewEncryptionKey(pb.GetNewEncryptionKeyRequest());
    return resp.key;
  }

  @override
  Future<String> getNewVerifyingKey() async {
    final resp = await _client.getNewVerifyingKey(pb.GetNewVerifyingKeyRequest());
    return resp.key;
  }

  @override
  Future<String> createDeposit({
    required String address,
    required int feeSats,
    required int valueSats,
  }) async {
    final resp = await _client.createDeposit(
      pb.CreateDepositRequest(
        address: address,
        valueSats: Int64(valueSats),
        feeSats: Int64(feeSats),
      ),
    );
    return resp.txid;
  }

  @override
  Future<String> decryptMsg({
    required String ciphertext,
    required String encryptionPubkey,
  }) async {
    final resp = await _client.decryptMsg(
      pb.DecryptMsgRequest(
        ciphertext: ciphertext,
        encryptionPubkey: encryptionPubkey,
      ),
    );
    // The backend returns raw hex; convert to string
    final bytes = hex.decode(resp.plaintext);
    final decoded = utf8.decode(bytes);
    return decoded;
  }

  @override
  Future<String> encryptMsg({
    required String msg,
    required String encryptionPubkey,
  }) async {
    final resp = await _client.encryptMsg(
      pb.EncryptMsgRequest(
        msg: msg,
        encryptionPubkey: encryptionPubkey,
      ),
    );
    return resp.ciphertext;
  }

  @override
  Future<String> getNewAddress() async {
    final resp = await _client.getNewAddress(pb.GetNewAddressRequest());
    return resp.address;
  }

  @override
  Future<Map<String, dynamic>> getPaymail() async {
    final resp = await _client.getPaymail(pb.GetPaymailRequest());
    if (resp.paymailJson.isEmpty) return {};
    return jsonDecode(resp.paymailJson) as Map<String, dynamic>;
  }

  @override
  Future<String> resolveCommit(String bitname) async {
    final resp = await _client.resolveCommit(pb.ResolveCommitRequest(bitname: bitname));
    return resp.commitment;
  }

  @override
  Future<String> signArbitraryMsg({
    required String msg,
    required String verifyingKey,
  }) async {
    final resp = await _client.signArbitraryMsg(
      pb.SignArbitraryMsgRequest(
        msg: msg,
        verifyingKey: verifyingKey,
      ),
    );
    return resp.signature;
  }

  @override
  Future<Map<String, String>> signArbitraryMsgAsAddr({
    required String msg,
    required String address,
  }) async {
    final resp = await _client.signArbitraryMsgAsAddr(
      pb.SignArbitraryMsgAsAddrRequest(
        msg: msg,
        address: address,
      ),
    );
    return {
      'verifying_key': resp.verifyingKey,
      'signature': resp.signature,
    };
  }

  @override
  Future<List<String>> getWalletAddresses() async {
    final resp = await _client.getWalletAddresses(pb.GetWalletAddressesRequest());
    return resp.addresses.toList();
  }

  @override
  Future<List<dynamic>> getWalletUTXOs() async {
    final resp = await _client.getWalletUtxos(pb.GetWalletUtxosRequest());
    if (resp.utxosJson.isEmpty) return [];
    return jsonDecode(resp.utxosJson) as List<dynamic>;
  }

  @override
  Future<List<BitnamesUTXO>> listUTXOs() async {
    final resp = await _client.getWalletUtxos(pb.GetWalletUtxosRequest());
    if (resp.utxosJson.isEmpty) return [];
    final decoded = jsonDecode(resp.utxosJson) as List<dynamic>;
    return decoded.map((e) => BitnamesUTXO.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SidechainUTXO>> listAllUTXOs() async {
    final resp = await _client.listUtxos(pb.ListUtxosRequest());
    if (resp.utxosJson.isEmpty) return [];
    final decoded = jsonDecode(resp.utxosJson) as List<dynamic>;
    return decoded.map((e) => BitnamesUTXO.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<dynamic>> myUTXOs() async {
    final resp = await _client.myUtxos(pb.MyUtxosRequest());
    if (resp.utxosJson.isEmpty) return [];
    return jsonDecode(resp.utxosJson) as List<dynamic>;
  }

  @override
  Future<Map<String, dynamic>> openapiSchema() async {
    final resp = await _client.openapiSchema(pb.OpenapiSchemaRequest());
    if (resp.schemaJson.isEmpty) return {};
    return jsonDecode(resp.schemaJson) as Map<String, dynamic>;
  }

  Future<void> stop() async {
    await _client.stop(pb.StopRequest());
  }

  @override
  Future<String> transfer({
    required String dest,
    required int value,
    required int fee,
    String? memo,
  }) async {
    final resp = await _client.transfer(
      pb.TransferRequest(
        address: dest,
        amountSats: Int64(value),
        feeSats: Int64(fee),
        memo: memo,
      ),
    );
    return resp.txid;
  }

  @override
  Future<String> withdraw(
    String mainchainAddress,
    int amountSats,
    int sidechainFeeSats,
    int mainchainFeeSats,
  ) async {
    final resp = await _client.withdraw(
      pb.WithdrawRequest(
        address: mainchainAddress,
        amountSats: Int64(amountSats),
        sideFeeSats: Int64(sidechainFeeSats),
        mainFeeSats: Int64(mainchainFeeSats),
      ),
    );
    return resp.txid;
  }

  @override
  Future<BmmResult> mine(int feeSats) async {
    final resp = await _client.mine(pb.MineRequest(feeSats: Int64(feeSats)));
    final decoded = jsonDecode(resp.bmmResultJson);
    return BmmResult.fromMap(decoded);
  }
}

final bitnamesRPCMethods = [
  'balance',
  'bitname_data',
  'bitnames',
  'connect_peer',
  'create_deposit',
  'decrypt_msg',
  'encrypt_msg',
  'format_deposit_address',
  'generate_mnemonic',
  'get_best_mainchain_block_hash',
  'get_best_sidechain_block_hash',
  'get_block',
  'get_bmm_inclusions',
  'get_new_address',
  'get_new_encryption_key',
  'get_new_verifying_key',
  'getblockcount',
  'get_paymail',
  'get_wallet_addresses',
  'get_wallet_utxos',
  'latest_failed_withdrawal_bundle_height',
  'list_peers',
  'list_utxos',
  'mine',
  'my_utxos',
  'openapi_schema',
  'pending_withdrawal_bundle',
  'register_bitname',
  'reserve_bitname',
  'resolve_commit',
  'set_seed_from_mnemonic',
  'sidechain_wealth',
  'sign_arbitrary_msg',
  'sign_arbitrary_msg_as_addr',
  'stop',
  'transfer',
  'verify_signature',
  'withdraw',
];

// Models for Bitnames RPC responses
class BitNameData {
  final String? commitment;
  final String? encryptionPubkey;
  final int? paymailFeeSats;
  final String? signingPubkey;
  final String? socketAddrV4;
  final String? socketAddrV6;

  BitNameData({
    this.commitment,
    this.encryptionPubkey,
    this.paymailFeeSats,
    this.signingPubkey,
    this.socketAddrV4,
    this.socketAddrV6,
  });

  Map<String, dynamic> toJson() => {
    if (commitment != null) 'commitment': commitment,
    if (encryptionPubkey != null) 'encryption_pubkey': encryptionPubkey,
    if (paymailFeeSats != null) 'paymail_fee_sats': paymailFeeSats,
    if (signingPubkey != null) 'signing_pubkey': signingPubkey,
    if (socketAddrV4 != null) 'socket_addr_v4': socketAddrV4,
    if (socketAddrV6 != null) 'socket_addr_v6': socketAddrV6,
  };

  factory BitNameData.fromJson(Map<String, dynamic> json) => BitNameData(
    commitment: json['commitment'] as String?,
    encryptionPubkey: json['encryption_pubkey'] as String?,
    paymailFeeSats: json['paymail_fee_sats'] as int?,
    signingPubkey: json['signing_pubkey'] as String?,
    socketAddrV4: json['socket_addr_v4'] as String?,
    socketAddrV6: json['socket_addr_v6'] as String?,
  );
}

class BalanceResponse {
  final int totalSats;
  final int availableSats;

  BalanceResponse({required this.totalSats, required this.availableSats});

  factory BalanceResponse.fromJson(Map<String, dynamic> json) => BalanceResponse(
    totalSats: json['total_sats'] as int,
    availableSats: json['available_sats'] as int,
  );
}

class BitnamesPeerInfo {
  final String address;
  final String status;

  BitnamesPeerInfo({required this.address, required this.status});

  factory BitnamesPeerInfo.fromJson(Map<String, dynamic> json) => BitnamesPeerInfo(
    address: json['address'] as String,
    status: json['status'] as String,
  );
}

class BitnameEntry {
  final String hash;
  final String? plaintextName;
  final BitnameDetails details;

  BitnameEntry({required this.hash, required this.details, this.plaintextName});
}

class BitnameDetails {
  final String seqId;
  final String? commitment;
  final String? socketAddrV4;
  final String? socketAddrV6;
  final String? encryptionPubkey;
  final String? signingPubkey;
  final int? paymailFeeSats;

  BitnameDetails({
    required this.seqId,
    this.commitment,
    this.socketAddrV4,
    this.socketAddrV6,
    this.encryptionPubkey,
    this.signingPubkey,
    this.paymailFeeSats,
  });

  factory BitnameDetails.fromJson(Map<String, dynamic> json) => BitnameDetails(
    seqId: json['seq_id'] as String,
    commitment: json['commitment'] as String?,
    socketAddrV4: json['socket_addr_v4'] as String?,
    socketAddrV6: json['socket_addr_v6'] as String?,
    encryptionPubkey: json['encryption_pubkey'] as String?,
    signingPubkey: json['signing_pubkey'] as String?,
    paymailFeeSats: json['paymail_fee_sats'] as int?,
  );
}
