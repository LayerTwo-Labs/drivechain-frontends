import 'package:sail_ui/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart' as core_pb;

/// Plain-old-data representation of bitcoind's `getpeerinfo` response.
/// Decoupled from any RPC client — populated either from a btc-buf
/// `Peer` proto via [PeerInfo.fromProto] or from a raw JSON map via
/// [PeerInfo.fromMap].
class PeerInfo {
  final int id;
  final String addr;
  final String addrBind;
  final String addrLocal;
  final String network;
  final String services;
  final List<String> serviceNames;
  final bool relayTxes;
  final int lastSend;
  final int lastRecv;
  final int lastTransaction;
  final int lastBlock;
  final int bytesSent;
  final int bytesRecv;
  final int connTime;
  final int timeOffset;
  final double pingTime;
  final double minPing;
  final int version;
  final String subVer;
  final bool inbound;
  final bool bip152HbTo;
  final bool bip152HbFrom;
  final int startingHeight;
  final int presyncedHeaders;
  final int syncedHeaders;
  final int syncedBlocks;
  final List<String> inflight;
  final bool addrRelayEnabled;
  final int addrProcessed;
  final int addrRateLimited;
  final List<String> permissions;
  final double minFeeFilter;
  final Map<String, int> bytesSentPerMsg;
  final Map<String, int> bytesRecvPerMsg;
  final String connectionType;
  final String transportProtocolType;
  final String sessionId;

  PeerInfo({
    required this.id,
    required this.addr,
    required this.addrBind,
    required this.addrLocal,
    required this.network,
    required this.services,
    required this.serviceNames,
    required this.relayTxes,
    required this.lastSend,
    required this.lastRecv,
    required this.lastTransaction,
    required this.lastBlock,
    required this.bytesSent,
    required this.bytesRecv,
    required this.connTime,
    required this.timeOffset,
    required this.pingTime,
    required this.minPing,
    required this.version,
    required this.subVer,
    required this.inbound,
    required this.bip152HbTo,
    required this.bip152HbFrom,
    required this.startingHeight,
    required this.presyncedHeaders,
    required this.syncedHeaders,
    required this.syncedBlocks,
    required this.inflight,
    required this.addrRelayEnabled,
    required this.addrProcessed,
    required this.addrRateLimited,
    required this.permissions,
    required this.minFeeFilter,
    required this.bytesSentPerMsg,
    required this.bytesRecvPerMsg,
    required this.connectionType,
    required this.transportProtocolType,
    required this.sessionId,
  });

  factory PeerInfo.fromProto(core_pb.Peer p) {
    String stripPrefix(String s, String prefix) =>
        s.startsWith(prefix) ? s.substring(prefix.length).toLowerCase() : s.toLowerCase();
    int tsSeconds(bool has, int Function() get) => has ? get() : 0;
    double durSeconds(bool has, double Function() get) => has ? get() : 0.0;

    return PeerInfo(
      id: p.id,
      addr: p.addr,
      addrBind: p.addrBind,
      addrLocal: p.addrLocal,
      network: stripPrefix(p.network.name, 'NETWORK_'),
      services: p.services,
      serviceNames: List<String>.from(p.servicesNames),
      relayTxes: p.relayTransactions,
      lastSend: tsSeconds(p.hasLastSendAt(), () => p.lastSendAt.seconds.toInt()),
      lastRecv: tsSeconds(p.hasLastRecvAt(), () => p.lastRecvAt.seconds.toInt()),
      lastTransaction: tsSeconds(p.hasLastTransactionAt(), () => p.lastTransactionAt.seconds.toInt()),
      lastBlock: tsSeconds(p.hasLastBlockAt(), () => p.lastBlockAt.seconds.toInt()),
      bytesSent: p.bytesSent.toInt(),
      bytesRecv: p.bytesReceived.toInt(),
      connTime: tsSeconds(p.hasConnectedAt(), () => p.connectedAt.seconds.toInt()),
      timeOffset: tsSeconds(p.hasTimeOffset(), () => p.timeOffset.seconds.toInt()),
      pingTime: durSeconds(p.hasPingTime(), () => p.pingTime.seconds.toDouble() + p.pingTime.nanos / 1e9),
      minPing: durSeconds(p.hasMinPing(), () => p.minPing.seconds.toDouble() + p.minPing.nanos / 1e9),
      version: p.version,
      subVer: p.subver,
      inbound: p.inbound,
      bip152HbTo: p.bip152HbTo,
      bip152HbFrom: p.bip152HbFrom,
      startingHeight: p.startingHeight,
      presyncedHeaders: p.presyncedHeaders,
      syncedHeaders: p.syncedHeaders,
      syncedBlocks: p.syncedBlocks,
      inflight: p.inflight.map((e) => e.toString()).toList(),
      addrRelayEnabled: p.addrRelayEnabled,
      addrProcessed: p.addrProcessed.toInt(),
      addrRateLimited: p.addrRateLimited.toInt(),
      permissions: List<String>.from(p.permissions),
      minFeeFilter: p.minFeeFilter,
      bytesSentPerMsg: p.bytesSentPerMsg.map((k, v) => MapEntry(k, v.toInt())),
      bytesRecvPerMsg: p.bytesReceivedPerMsg.map((k, v) => MapEntry(k, v.toInt())),
      connectionType: stripPrefix(p.connectionType.name, 'CONNECTION_TYPE_'),
      transportProtocolType: stripPrefix(p.transportProtocol.name, 'TRANSPORT_PROTOCOL_'),
      sessionId: p.sessionId,
    );
  }

  factory PeerInfo.fromMap(Map<String, dynamic> map) {
    return PeerInfo(
      id: map['id'] ?? 0,
      addr: map['addr'] ?? '',
      addrBind: map['addrbind'] ?? '',
      addrLocal: map['addrlocal'] ?? '',
      network: map['network'] ?? '',
      services: map['services'] ?? '',
      serviceNames: List<String>.from(map['servicesnames'] ?? []),
      relayTxes: map['relaytxes'] ?? false,
      lastSend: map['lastsend'] ?? 0,
      lastRecv: map['lastrecv'] ?? 0,
      lastTransaction: map['last_transaction'] ?? 0,
      lastBlock: map['last_block'] ?? 0,
      bytesSent: map['bytessent'] ?? 0,
      bytesRecv: map['bytesrecv'] ?? 0,
      connTime: map['conntime'] ?? 0,
      timeOffset: map['timeoffset'] ?? 0,
      pingTime: (map['pingtime'] ?? 0.0).toDouble(),
      minPing: (map['minping'] ?? 0.0).toDouble(),
      version: map['version'] ?? 0,
      subVer: map['subver'] ?? '',
      inbound: map['inbound'] ?? false,
      bip152HbTo: map['bip152_hb_to'] ?? false,
      bip152HbFrom: map['bip152_hb_from'] ?? false,
      startingHeight: map['startingheight'] ?? 0,
      presyncedHeaders: map['presynced_headers'] ?? -1,
      syncedHeaders: map['synced_headers'] ?? 0,
      syncedBlocks: map['synced_blocks'] ?? 0,
      inflight: List<String>.from(map['inflight'] ?? []),
      addrRelayEnabled: map['addr_relay_enabled'] ?? false,
      addrProcessed: map['addr_processed'] ?? 0,
      addrRateLimited: map['addr_rate_limited'] ?? 0,
      permissions: List<String>.from(map['permissions'] ?? []),
      minFeeFilter: (map['minfeefilter'] ?? 0.0).toDouble(),
      bytesSentPerMsg: Map<String, int>.from(map['bytessent_per_msg'] ?? {}),
      bytesRecvPerMsg: Map<String, int>.from(map['bytesrecv_per_msg'] ?? {}),
      connectionType: map['connection_type'] ?? '',
      transportProtocolType: map['transport_protocol_type'] ?? '',
      sessionId: map['session_id'] ?? '',
    );
  }

  @override
  String toString() {
    return 'PeerInfo{id: $id, addr: $addr, network: $network, version: $version, subVer: $subVer}';
  }
}
