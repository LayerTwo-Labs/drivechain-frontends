//
//  Generated code. Do not modify.
//  source: bitcoin/bitcoind/v1alpha/bitcoin.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../../google/protobuf/duration.pb.dart' as $1;
import '../../../google/protobuf/empty.pb.dart' as $3;
import '../../../google/protobuf/timestamp.pb.dart' as $0;
import '../../../google/protobuf/wrappers.pb.dart' as $2;
import 'bitcoin.pbenum.dart';

export 'bitcoin.pbenum.dart';

class GetBlockchainInfoRequest extends $pb.GeneratedMessage {
  factory GetBlockchainInfoRequest() => create();
  GetBlockchainInfoRequest._() : super();
  factory GetBlockchainInfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockchainInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockchainInfoRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockchainInfoRequest clone() => GetBlockchainInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockchainInfoRequest copyWith(void Function(GetBlockchainInfoRequest) updates) => super.copyWith((message) => updates(message as GetBlockchainInfoRequest)) as GetBlockchainInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockchainInfoRequest create() => GetBlockchainInfoRequest._();
  GetBlockchainInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetBlockchainInfoRequest> createRepeated() => $pb.PbList<GetBlockchainInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBlockchainInfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockchainInfoRequest>(create);
  static GetBlockchainInfoRequest? _defaultInstance;
}

class GetBlockchainInfoResponse extends $pb.GeneratedMessage {
  factory GetBlockchainInfoResponse({
    $core.String? bestBlockHash,
    $core.String? chain,
    $core.String? chainWork,
    $core.bool? initialBlockDownload,
    $core.int? blocks,
    $core.int? headers,
    $core.double? verificationProgress,
  }) {
    final $result = create();
    if (bestBlockHash != null) {
      $result.bestBlockHash = bestBlockHash;
    }
    if (chain != null) {
      $result.chain = chain;
    }
    if (chainWork != null) {
      $result.chainWork = chainWork;
    }
    if (initialBlockDownload != null) {
      $result.initialBlockDownload = initialBlockDownload;
    }
    if (blocks != null) {
      $result.blocks = blocks;
    }
    if (headers != null) {
      $result.headers = headers;
    }
    if (verificationProgress != null) {
      $result.verificationProgress = verificationProgress;
    }
    return $result;
  }
  GetBlockchainInfoResponse._() : super();
  factory GetBlockchainInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockchainInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockchainInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'bestBlockHash')
    ..aOS(2, _omitFieldNames ? '' : 'chain')
    ..aOS(3, _omitFieldNames ? '' : 'chainWork')
    ..aOB(4, _omitFieldNames ? '' : 'initialBlockDownload')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'blocks', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'headers', $pb.PbFieldType.OU3)
    ..a<$core.double>(7, _omitFieldNames ? '' : 'verificationProgress', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockchainInfoResponse clone() => GetBlockchainInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockchainInfoResponse copyWith(void Function(GetBlockchainInfoResponse) updates) => super.copyWith((message) => updates(message as GetBlockchainInfoResponse)) as GetBlockchainInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockchainInfoResponse create() => GetBlockchainInfoResponse._();
  GetBlockchainInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetBlockchainInfoResponse> createRepeated() => $pb.PbList<GetBlockchainInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBlockchainInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockchainInfoResponse>(create);
  static GetBlockchainInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get bestBlockHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set bestBlockHash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBestBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBestBlockHash() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get chain => $_getSZ(1);
  @$pb.TagNumber(2)
  set chain($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasChain() => $_has(1);
  @$pb.TagNumber(2)
  void clearChain() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get chainWork => $_getSZ(2);
  @$pb.TagNumber(3)
  set chainWork($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasChainWork() => $_has(2);
  @$pb.TagNumber(3)
  void clearChainWork() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get initialBlockDownload => $_getBF(3);
  @$pb.TagNumber(4)
  set initialBlockDownload($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasInitialBlockDownload() => $_has(3);
  @$pb.TagNumber(4)
  void clearInitialBlockDownload() => clearField(4);

  /// The height of the most-work fully-validated chain.
  @$pb.TagNumber(5)
  $core.int get blocks => $_getIZ(4);
  @$pb.TagNumber(5)
  set blocks($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasBlocks() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlocks() => clearField(5);

  /// The current number of validated headers.
  @$pb.TagNumber(6)
  $core.int get headers => $_getIZ(5);
  @$pb.TagNumber(6)
  set headers($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasHeaders() => $_has(5);
  @$pb.TagNumber(6)
  void clearHeaders() => clearField(6);

  @$pb.TagNumber(7)
  $core.double get verificationProgress => $_getN(6);
  @$pb.TagNumber(7)
  set verificationProgress($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasVerificationProgress() => $_has(6);
  @$pb.TagNumber(7)
  void clearVerificationProgress() => clearField(7);
}

class GetPeerInfoRequest extends $pb.GeneratedMessage {
  factory GetPeerInfoRequest() => create();
  GetPeerInfoRequest._() : super();
  factory GetPeerInfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetPeerInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPeerInfoRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetPeerInfoRequest clone() => GetPeerInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetPeerInfoRequest copyWith(void Function(GetPeerInfoRequest) updates) => super.copyWith((message) => updates(message as GetPeerInfoRequest)) as GetPeerInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPeerInfoRequest create() => GetPeerInfoRequest._();
  GetPeerInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetPeerInfoRequest> createRepeated() => $pb.PbList<GetPeerInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetPeerInfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPeerInfoRequest>(create);
  static GetPeerInfoRequest? _defaultInstance;
}

class Peer extends $pb.GeneratedMessage {
  factory Peer({
    $core.int? id,
    $core.String? addr,
    $core.String? addrBind,
    $core.String? addrLocal,
    Peer_Network? network,
    $fixnum.Int64? mappedAs,
    $core.String? services,
    $core.Iterable<$core.String>? servicesNames,
    $core.bool? relayTransactions,
    $0.Timestamp? lastSendAt,
    $0.Timestamp? lastRecvAt,
    $0.Timestamp? lastTransactionAt,
    $0.Timestamp? lastBlockAt,
    $fixnum.Int64? bytesSent,
    $fixnum.Int64? bytesReceived,
    $0.Timestamp? connectedAt,
    $1.Duration? timeOffset,
    $1.Duration? pingTime,
    $1.Duration? minPing,
    $1.Duration? pingWait,
    $core.int? version,
    $core.String? subver,
    $core.bool? inbound,
    $core.bool? bip152HbTo,
    $core.bool? bip152HbFrom,
    $core.int? startingHeight,
    $core.int? presyncedHeaders,
    $core.int? syncedHeaders,
    $core.int? syncedBlocks,
    $core.Iterable<$core.int>? inflight,
    $core.bool? addrRelayEnabled,
    $fixnum.Int64? addrProcessed,
    $fixnum.Int64? addrRateLimited,
    $core.Iterable<$core.String>? permissions,
    $core.double? minFeeFilter,
    $core.Map<$core.String, $fixnum.Int64>? bytesSentPerMsg,
    $core.Map<$core.String, $fixnum.Int64>? bytesReceivedPerMsg,
    Peer_ConnectionType? connectionType,
    Peer_TransportProtocol? transportProtocol,
    $core.String? sessionId,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (addr != null) {
      $result.addr = addr;
    }
    if (addrBind != null) {
      $result.addrBind = addrBind;
    }
    if (addrLocal != null) {
      $result.addrLocal = addrLocal;
    }
    if (network != null) {
      $result.network = network;
    }
    if (mappedAs != null) {
      $result.mappedAs = mappedAs;
    }
    if (services != null) {
      $result.services = services;
    }
    if (servicesNames != null) {
      $result.servicesNames.addAll(servicesNames);
    }
    if (relayTransactions != null) {
      $result.relayTransactions = relayTransactions;
    }
    if (lastSendAt != null) {
      $result.lastSendAt = lastSendAt;
    }
    if (lastRecvAt != null) {
      $result.lastRecvAt = lastRecvAt;
    }
    if (lastTransactionAt != null) {
      $result.lastTransactionAt = lastTransactionAt;
    }
    if (lastBlockAt != null) {
      $result.lastBlockAt = lastBlockAt;
    }
    if (bytesSent != null) {
      $result.bytesSent = bytesSent;
    }
    if (bytesReceived != null) {
      $result.bytesReceived = bytesReceived;
    }
    if (connectedAt != null) {
      $result.connectedAt = connectedAt;
    }
    if (timeOffset != null) {
      $result.timeOffset = timeOffset;
    }
    if (pingTime != null) {
      $result.pingTime = pingTime;
    }
    if (minPing != null) {
      $result.minPing = minPing;
    }
    if (pingWait != null) {
      $result.pingWait = pingWait;
    }
    if (version != null) {
      $result.version = version;
    }
    if (subver != null) {
      $result.subver = subver;
    }
    if (inbound != null) {
      $result.inbound = inbound;
    }
    if (bip152HbTo != null) {
      $result.bip152HbTo = bip152HbTo;
    }
    if (bip152HbFrom != null) {
      $result.bip152HbFrom = bip152HbFrom;
    }
    if (startingHeight != null) {
      $result.startingHeight = startingHeight;
    }
    if (presyncedHeaders != null) {
      $result.presyncedHeaders = presyncedHeaders;
    }
    if (syncedHeaders != null) {
      $result.syncedHeaders = syncedHeaders;
    }
    if (syncedBlocks != null) {
      $result.syncedBlocks = syncedBlocks;
    }
    if (inflight != null) {
      $result.inflight.addAll(inflight);
    }
    if (addrRelayEnabled != null) {
      $result.addrRelayEnabled = addrRelayEnabled;
    }
    if (addrProcessed != null) {
      $result.addrProcessed = addrProcessed;
    }
    if (addrRateLimited != null) {
      $result.addrRateLimited = addrRateLimited;
    }
    if (permissions != null) {
      $result.permissions.addAll(permissions);
    }
    if (minFeeFilter != null) {
      $result.minFeeFilter = minFeeFilter;
    }
    if (bytesSentPerMsg != null) {
      $result.bytesSentPerMsg.addAll(bytesSentPerMsg);
    }
    if (bytesReceivedPerMsg != null) {
      $result.bytesReceivedPerMsg.addAll(bytesReceivedPerMsg);
    }
    if (connectionType != null) {
      $result.connectionType = connectionType;
    }
    if (transportProtocol != null) {
      $result.transportProtocol = transportProtocol;
    }
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    return $result;
  }
  Peer._() : super();
  factory Peer.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Peer.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Peer', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'addr')
    ..aOS(3, _omitFieldNames ? '' : 'addrBind')
    ..aOS(4, _omitFieldNames ? '' : 'addrLocal')
    ..e<Peer_Network>(5, _omitFieldNames ? '' : 'network', $pb.PbFieldType.OE, defaultOrMaker: Peer_Network.NETWORK_UNSPECIFIED, valueOf: Peer_Network.valueOf, enumValues: Peer_Network.values)
    ..aInt64(6, _omitFieldNames ? '' : 'mappedAs')
    ..aOS(7, _omitFieldNames ? '' : 'services')
    ..pPS(8, _omitFieldNames ? '' : 'servicesNames')
    ..aOB(9, _omitFieldNames ? '' : 'relayTransactions')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'lastSendAt', subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'lastRecvAt', subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'lastTransactionAt', subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'lastBlockAt', subBuilder: $0.Timestamp.create)
    ..a<$fixnum.Int64>(14, _omitFieldNames ? '' : 'bytesSent', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(15, _omitFieldNames ? '' : 'bytesReceived', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<$0.Timestamp>(16, _omitFieldNames ? '' : 'connectedAt', subBuilder: $0.Timestamp.create)
    ..aOM<$1.Duration>(17, _omitFieldNames ? '' : 'timeOffset', subBuilder: $1.Duration.create)
    ..aOM<$1.Duration>(18, _omitFieldNames ? '' : 'pingTime', subBuilder: $1.Duration.create)
    ..aOM<$1.Duration>(19, _omitFieldNames ? '' : 'minPing', subBuilder: $1.Duration.create)
    ..aOM<$1.Duration>(20, _omitFieldNames ? '' : 'pingWait', subBuilder: $1.Duration.create)
    ..a<$core.int>(21, _omitFieldNames ? '' : 'version', $pb.PbFieldType.OU3)
    ..aOS(22, _omitFieldNames ? '' : 'subver')
    ..aOB(23, _omitFieldNames ? '' : 'inbound')
    ..aOB(24, _omitFieldNames ? '' : 'bip152HbTo')
    ..aOB(25, _omitFieldNames ? '' : 'bip152HbFrom')
    ..a<$core.int>(26, _omitFieldNames ? '' : 'startingHeight', $pb.PbFieldType.O3)
    ..a<$core.int>(27, _omitFieldNames ? '' : 'presyncedHeaders', $pb.PbFieldType.O3)
    ..a<$core.int>(28, _omitFieldNames ? '' : 'syncedHeaders', $pb.PbFieldType.O3)
    ..a<$core.int>(29, _omitFieldNames ? '' : 'syncedBlocks', $pb.PbFieldType.O3)
    ..p<$core.int>(30, _omitFieldNames ? '' : 'inflight', $pb.PbFieldType.K3)
    ..aOB(31, _omitFieldNames ? '' : 'addrRelayEnabled')
    ..aInt64(32, _omitFieldNames ? '' : 'addrProcessed')
    ..aInt64(33, _omitFieldNames ? '' : 'addrRateLimited')
    ..pPS(34, _omitFieldNames ? '' : 'permissions')
    ..a<$core.double>(35, _omitFieldNames ? '' : 'minFeeFilter', $pb.PbFieldType.OD)
    ..m<$core.String, $fixnum.Int64>(36, _omitFieldNames ? '' : 'bytesSentPerMsg', entryClassName: 'Peer.BytesSentPerMsgEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.O6, packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..m<$core.String, $fixnum.Int64>(37, _omitFieldNames ? '' : 'bytesReceivedPerMsg', entryClassName: 'Peer.BytesReceivedPerMsgEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.O6, packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..e<Peer_ConnectionType>(38, _omitFieldNames ? '' : 'connectionType', $pb.PbFieldType.OE, defaultOrMaker: Peer_ConnectionType.CONNECTION_TYPE_UNSPECIFIED, valueOf: Peer_ConnectionType.valueOf, enumValues: Peer_ConnectionType.values)
    ..e<Peer_TransportProtocol>(39, _omitFieldNames ? '' : 'transportProtocol', $pb.PbFieldType.OE, defaultOrMaker: Peer_TransportProtocol.TRANSPORT_PROTOCOL_UNSPECIFIED, valueOf: Peer_TransportProtocol.valueOf, enumValues: Peer_TransportProtocol.values)
    ..aOS(40, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Peer clone() => Peer()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Peer copyWith(void Function(Peer) updates) => super.copyWith((message) => updates(message as Peer)) as Peer;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Peer create() => Peer._();
  Peer createEmptyInstance() => create();
  static $pb.PbList<Peer> createRepeated() => $pb.PbList<Peer>();
  @$core.pragma('dart2js:noInline')
  static Peer getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Peer>(create);
  static Peer? _defaultInstance;

  /// Peer index
  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  /// The IP address and port of the peer (host:port)
  @$pb.TagNumber(2)
  $core.String get addr => $_getSZ(1);
  @$pb.TagNumber(2)
  set addr($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddr() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddr() => clearField(2);

  /// Bind address of the connection to the peer (ip:port)
  @$pb.TagNumber(3)
  $core.String get addrBind => $_getSZ(2);
  @$pb.TagNumber(3)
  set addrBind($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAddrBind() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddrBind() => clearField(3);

  /// Local address as reported by the peer (ip:port)
  @$pb.TagNumber(4)
  $core.String get addrLocal => $_getSZ(3);
  @$pb.TagNumber(4)
  set addrLocal($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAddrLocal() => $_has(3);
  @$pb.TagNumber(4)
  void clearAddrLocal() => clearField(4);

  @$pb.TagNumber(5)
  Peer_Network get network => $_getN(4);
  @$pb.TagNumber(5)
  set network(Peer_Network v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasNetwork() => $_has(4);
  @$pb.TagNumber(5)
  void clearNetwork() => clearField(5);

  /// The AS in the BGP route to the peer used for diversifying peer selection
  @$pb.TagNumber(6)
  $fixnum.Int64 get mappedAs => $_getI64(5);
  @$pb.TagNumber(6)
  set mappedAs($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMappedAs() => $_has(5);
  @$pb.TagNumber(6)
  void clearMappedAs() => clearField(6);

  /// The services offered (hex)
  @$pb.TagNumber(7)
  $core.String get services => $_getSZ(6);
  @$pb.TagNumber(7)
  set services($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasServices() => $_has(6);
  @$pb.TagNumber(7)
  void clearServices() => clearField(7);

  /// The services offered, in human-readable form
  @$pb.TagNumber(8)
  $core.List<$core.String> get servicesNames => $_getList(7);

  /// Whether we relay transactions to this peer
  @$pb.TagNumber(9)
  $core.bool get relayTransactions => $_getBF(8);
  @$pb.TagNumber(9)
  set relayTransactions($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasRelayTransactions() => $_has(8);
  @$pb.TagNumber(9)
  void clearRelayTransactions() => clearField(9);

  /// The time of the last send
  @$pb.TagNumber(10)
  $0.Timestamp get lastSendAt => $_getN(9);
  @$pb.TagNumber(10)
  set lastSendAt($0.Timestamp v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasLastSendAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearLastSendAt() => clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureLastSendAt() => $_ensure(9);

  /// The time of the last receive
  @$pb.TagNumber(11)
  $0.Timestamp get lastRecvAt => $_getN(10);
  @$pb.TagNumber(11)
  set lastRecvAt($0.Timestamp v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasLastRecvAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearLastRecvAt() => clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureLastRecvAt() => $_ensure(10);

  /// The time of the last valid transaction received from this peer
  @$pb.TagNumber(12)
  $0.Timestamp get lastTransactionAt => $_getN(11);
  @$pb.TagNumber(12)
  set lastTransactionAt($0.Timestamp v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasLastTransactionAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearLastTransactionAt() => clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureLastTransactionAt() => $_ensure(11);

  /// The time of the last block received from this peer
  @$pb.TagNumber(13)
  $0.Timestamp get lastBlockAt => $_getN(12);
  @$pb.TagNumber(13)
  set lastBlockAt($0.Timestamp v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasLastBlockAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearLastBlockAt() => clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureLastBlockAt() => $_ensure(12);

  /// The total bytes sent
  @$pb.TagNumber(14)
  $fixnum.Int64 get bytesSent => $_getI64(13);
  @$pb.TagNumber(14)
  set bytesSent($fixnum.Int64 v) { $_setInt64(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasBytesSent() => $_has(13);
  @$pb.TagNumber(14)
  void clearBytesSent() => clearField(14);

  /// The total bytes received
  @$pb.TagNumber(15)
  $fixnum.Int64 get bytesReceived => $_getI64(14);
  @$pb.TagNumber(15)
  set bytesReceived($fixnum.Int64 v) { $_setInt64(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasBytesReceived() => $_has(14);
  @$pb.TagNumber(15)
  void clearBytesReceived() => clearField(15);

  /// The time of the connection
  @$pb.TagNumber(16)
  $0.Timestamp get connectedAt => $_getN(15);
  @$pb.TagNumber(16)
  set connectedAt($0.Timestamp v) { setField(16, v); }
  @$pb.TagNumber(16)
  $core.bool hasConnectedAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearConnectedAt() => clearField(16);
  @$pb.TagNumber(16)
  $0.Timestamp ensureConnectedAt() => $_ensure(15);

  /// The time offset
  @$pb.TagNumber(17)
  $1.Duration get timeOffset => $_getN(16);
  @$pb.TagNumber(17)
  set timeOffset($1.Duration v) { setField(17, v); }
  @$pb.TagNumber(17)
  $core.bool hasTimeOffset() => $_has(16);
  @$pb.TagNumber(17)
  void clearTimeOffset() => clearField(17);
  @$pb.TagNumber(17)
  $1.Duration ensureTimeOffset() => $_ensure(16);

  /// The last ping time, if any
  @$pb.TagNumber(18)
  $1.Duration get pingTime => $_getN(17);
  @$pb.TagNumber(18)
  set pingTime($1.Duration v) { setField(18, v); }
  @$pb.TagNumber(18)
  $core.bool hasPingTime() => $_has(17);
  @$pb.TagNumber(18)
  void clearPingTime() => clearField(18);
  @$pb.TagNumber(18)
  $1.Duration ensurePingTime() => $_ensure(17);

  /// The minimum observed ping time, if any
  @$pb.TagNumber(19)
  $1.Duration get minPing => $_getN(18);
  @$pb.TagNumber(19)
  set minPing($1.Duration v) { setField(19, v); }
  @$pb.TagNumber(19)
  $core.bool hasMinPing() => $_has(18);
  @$pb.TagNumber(19)
  void clearMinPing() => clearField(19);
  @$pb.TagNumber(19)
  $1.Duration ensureMinPing() => $_ensure(18);

  /// The duration of an outstanding ping, if any
  @$pb.TagNumber(20)
  $1.Duration get pingWait => $_getN(19);
  @$pb.TagNumber(20)
  set pingWait($1.Duration v) { setField(20, v); }
  @$pb.TagNumber(20)
  $core.bool hasPingWait() => $_has(19);
  @$pb.TagNumber(20)
  void clearPingWait() => clearField(20);
  @$pb.TagNumber(20)
  $1.Duration ensurePingWait() => $_ensure(19);

  /// The peer version, such as 70001
  @$pb.TagNumber(21)
  $core.int get version => $_getIZ(20);
  @$pb.TagNumber(21)
  set version($core.int v) { $_setUnsignedInt32(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasVersion() => $_has(20);
  @$pb.TagNumber(21)
  void clearVersion() => clearField(21);

  /// The string version
  @$pb.TagNumber(22)
  $core.String get subver => $_getSZ(21);
  @$pb.TagNumber(22)
  set subver($core.String v) { $_setString(21, v); }
  @$pb.TagNumber(22)
  $core.bool hasSubver() => $_has(21);
  @$pb.TagNumber(22)
  void clearSubver() => clearField(22);

  /// Inbound (true) or Outbound (false)
  @$pb.TagNumber(23)
  $core.bool get inbound => $_getBF(22);
  @$pb.TagNumber(23)
  set inbound($core.bool v) { $_setBool(22, v); }
  @$pb.TagNumber(23)
  $core.bool hasInbound() => $_has(22);
  @$pb.TagNumber(23)
  void clearInbound() => clearField(23);

  /// Whether we selected peer as (compact blocks) high-bandwidth peer
  @$pb.TagNumber(24)
  $core.bool get bip152HbTo => $_getBF(23);
  @$pb.TagNumber(24)
  set bip152HbTo($core.bool v) { $_setBool(23, v); }
  @$pb.TagNumber(24)
  $core.bool hasBip152HbTo() => $_has(23);
  @$pb.TagNumber(24)
  void clearBip152HbTo() => clearField(24);

  /// Whether peer selected us as (compact blocks) high-bandwidth peer
  @$pb.TagNumber(25)
  $core.bool get bip152HbFrom => $_getBF(24);
  @$pb.TagNumber(25)
  set bip152HbFrom($core.bool v) { $_setBool(24, v); }
  @$pb.TagNumber(25)
  $core.bool hasBip152HbFrom() => $_has(24);
  @$pb.TagNumber(25)
  void clearBip152HbFrom() => clearField(25);

  /// The starting height (block) of the peer
  @$pb.TagNumber(26)
  $core.int get startingHeight => $_getIZ(25);
  @$pb.TagNumber(26)
  set startingHeight($core.int v) { $_setSignedInt32(25, v); }
  @$pb.TagNumber(26)
  $core.bool hasStartingHeight() => $_has(25);
  @$pb.TagNumber(26)
  void clearStartingHeight() => clearField(26);

  /// The current height of header pre-synchronization with this peer, or -1 if no low-work sync is in progress
  @$pb.TagNumber(27)
  $core.int get presyncedHeaders => $_getIZ(26);
  @$pb.TagNumber(27)
  set presyncedHeaders($core.int v) { $_setSignedInt32(26, v); }
  @$pb.TagNumber(27)
  $core.bool hasPresyncedHeaders() => $_has(26);
  @$pb.TagNumber(27)
  void clearPresyncedHeaders() => clearField(27);

  /// The last header we have in common with this peer
  @$pb.TagNumber(28)
  $core.int get syncedHeaders => $_getIZ(27);
  @$pb.TagNumber(28)
  set syncedHeaders($core.int v) { $_setSignedInt32(27, v); }
  @$pb.TagNumber(28)
  $core.bool hasSyncedHeaders() => $_has(27);
  @$pb.TagNumber(28)
  void clearSyncedHeaders() => clearField(28);

  /// The last block we have in common with this peer
  @$pb.TagNumber(29)
  $core.int get syncedBlocks => $_getIZ(28);
  @$pb.TagNumber(29)
  set syncedBlocks($core.int v) { $_setSignedInt32(28, v); }
  @$pb.TagNumber(29)
  $core.bool hasSyncedBlocks() => $_has(28);
  @$pb.TagNumber(29)
  void clearSyncedBlocks() => clearField(29);

  /// The heights of blocks we're currently asking from this peer
  @$pb.TagNumber(30)
  $core.List<$core.int> get inflight => $_getList(29);

  /// Whether we participate in address relay with this peer
  @$pb.TagNumber(31)
  $core.bool get addrRelayEnabled => $_getBF(30);
  @$pb.TagNumber(31)
  set addrRelayEnabled($core.bool v) { $_setBool(30, v); }
  @$pb.TagNumber(31)
  $core.bool hasAddrRelayEnabled() => $_has(30);
  @$pb.TagNumber(31)
  void clearAddrRelayEnabled() => clearField(31);

  /// The total number of addresses processed, excluding those dropped due to rate limiting
  @$pb.TagNumber(32)
  $fixnum.Int64 get addrProcessed => $_getI64(31);
  @$pb.TagNumber(32)
  set addrProcessed($fixnum.Int64 v) { $_setInt64(31, v); }
  @$pb.TagNumber(32)
  $core.bool hasAddrProcessed() => $_has(31);
  @$pb.TagNumber(32)
  void clearAddrProcessed() => clearField(32);

  /// The total number of addresses dropped due to rate limiting
  @$pb.TagNumber(33)
  $fixnum.Int64 get addrRateLimited => $_getI64(32);
  @$pb.TagNumber(33)
  set addrRateLimited($fixnum.Int64 v) { $_setInt64(32, v); }
  @$pb.TagNumber(33)
  $core.bool hasAddrRateLimited() => $_has(32);
  @$pb.TagNumber(33)
  void clearAddrRateLimited() => clearField(33);

  /// Any special permissions that have been granted to this peer
  @$pb.TagNumber(34)
  $core.List<$core.String> get permissions => $_getList(33);

  /// The minimum fee rate for transactions this peer accepts
  @$pb.TagNumber(35)
  $core.double get minFeeFilter => $_getN(34);
  @$pb.TagNumber(35)
  set minFeeFilter($core.double v) { $_setDouble(34, v); }
  @$pb.TagNumber(35)
  $core.bool hasMinFeeFilter() => $_has(34);
  @$pb.TagNumber(35)
  void clearMinFeeFilter() => clearField(35);

  /// The total bytes sent aggregated by message type
  @$pb.TagNumber(36)
  $core.Map<$core.String, $fixnum.Int64> get bytesSentPerMsg => $_getMap(35);

  /// The total bytes received aggregated by message type
  @$pb.TagNumber(37)
  $core.Map<$core.String, $fixnum.Int64> get bytesReceivedPerMsg => $_getMap(36);

  /// Type of connection
  @$pb.TagNumber(38)
  Peer_ConnectionType get connectionType => $_getN(37);
  @$pb.TagNumber(38)
  set connectionType(Peer_ConnectionType v) { setField(38, v); }
  @$pb.TagNumber(38)
  $core.bool hasConnectionType() => $_has(37);
  @$pb.TagNumber(38)
  void clearConnectionType() => clearField(38);

  /// Type of transport protocol
  @$pb.TagNumber(39)
  Peer_TransportProtocol get transportProtocol => $_getN(38);
  @$pb.TagNumber(39)
  set transportProtocol(Peer_TransportProtocol v) { setField(39, v); }
  @$pb.TagNumber(39)
  $core.bool hasTransportProtocol() => $_has(38);
  @$pb.TagNumber(39)
  void clearTransportProtocol() => clearField(39);

  /// The session ID for this connection, or empty if there is none (v2 transport protocol only)
  @$pb.TagNumber(40)
  $core.String get sessionId => $_getSZ(39);
  @$pb.TagNumber(40)
  set sessionId($core.String v) { $_setString(39, v); }
  @$pb.TagNumber(40)
  $core.bool hasSessionId() => $_has(39);
  @$pb.TagNumber(40)
  void clearSessionId() => clearField(40);
}

class GetPeerInfoResponse extends $pb.GeneratedMessage {
  factory GetPeerInfoResponse({
    $core.Iterable<Peer>? peers,
  }) {
    final $result = create();
    if (peers != null) {
      $result.peers.addAll(peers);
    }
    return $result;
  }
  GetPeerInfoResponse._() : super();
  factory GetPeerInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetPeerInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPeerInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pc<Peer>(1, _omitFieldNames ? '' : 'peers', $pb.PbFieldType.PM, subBuilder: Peer.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetPeerInfoResponse clone() => GetPeerInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetPeerInfoResponse copyWith(void Function(GetPeerInfoResponse) updates) => super.copyWith((message) => updates(message as GetPeerInfoResponse)) as GetPeerInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPeerInfoResponse create() => GetPeerInfoResponse._();
  GetPeerInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetPeerInfoResponse> createRepeated() => $pb.PbList<GetPeerInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetPeerInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPeerInfoResponse>(create);
  static GetPeerInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Peer> get peers => $_getList(0);
}

class GetNewAddressRequest extends $pb.GeneratedMessage {
  factory GetNewAddressRequest({
    $core.String? label,
    $core.String? addressType,
    $core.String? wallet,
  }) {
    final $result = create();
    if (label != null) {
      $result.label = label;
    }
    if (addressType != null) {
      $result.addressType = addressType;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  GetNewAddressRequest._() : super();
  factory GetNewAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aOS(2, _omitFieldNames ? '' : 'addressType')
    ..aOS(3, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNewAddressRequest clone() => GetNewAddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNewAddressRequest copyWith(void Function(GetNewAddressRequest) updates) => super.copyWith((message) => updates(message as GetNewAddressRequest)) as GetNewAddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewAddressRequest create() => GetNewAddressRequest._();
  GetNewAddressRequest createEmptyInstance() => create();
  static $pb.PbList<GetNewAddressRequest> createRepeated() => $pb.PbList<GetNewAddressRequest>();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNewAddressRequest>(create);
  static GetNewAddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get addressType => $_getSZ(1);
  @$pb.TagNumber(2)
  set addressType($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddressType() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddressType() => clearField(2);

  /// Only needs to be set if dealing with multiple wallets at the same time.
  /// TODO: better suited as a header?
  @$pb.TagNumber(3)
  $core.String get wallet => $_getSZ(2);
  @$pb.TagNumber(3)
  set wallet($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWallet() => $_has(2);
  @$pb.TagNumber(3)
  void clearWallet() => clearField(3);
}

class GetNewAddressResponse extends $pb.GeneratedMessage {
  factory GetNewAddressResponse({
    $core.String? address,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  GetNewAddressResponse._() : super();
  factory GetNewAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNewAddressResponse clone() => GetNewAddressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNewAddressResponse copyWith(void Function(GetNewAddressResponse) updates) => super.copyWith((message) => updates(message as GetNewAddressResponse)) as GetNewAddressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewAddressResponse create() => GetNewAddressResponse._();
  GetNewAddressResponse createEmptyInstance() => create();
  static $pb.PbList<GetNewAddressResponse> createRepeated() => $pb.PbList<GetNewAddressResponse>();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNewAddressResponse>(create);
  static GetNewAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class GetWalletInfoRequest extends $pb.GeneratedMessage {
  factory GetWalletInfoRequest({
    $core.String? wallet,
  }) {
    final $result = create();
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  GetWalletInfoRequest._() : super();
  factory GetWalletInfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWalletInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletInfoRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWalletInfoRequest clone() => GetWalletInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWalletInfoRequest copyWith(void Function(GetWalletInfoRequest) updates) => super.copyWith((message) => updates(message as GetWalletInfoRequest)) as GetWalletInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWalletInfoRequest create() => GetWalletInfoRequest._();
  GetWalletInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetWalletInfoRequest> createRepeated() => $pb.PbList<GetWalletInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetWalletInfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWalletInfoRequest>(create);
  static GetWalletInfoRequest? _defaultInstance;

  /// Only needs to be set if dealing with multiple wallets at the same time.
  /// TODO: better suited as a header?
  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => clearField(1);
}

class GetWalletInfoResponse extends $pb.GeneratedMessage {
  factory GetWalletInfoResponse({
    $core.String? walletName,
    $fixnum.Int64? walletVersion,
    $core.String? format,
    $fixnum.Int64? txCount,
    $fixnum.Int64? keyPoolSize,
    $fixnum.Int64? keyPoolSizeHdInternal,
    $core.double? payTxFee,
    $core.bool? privateKeysEnabled,
    $core.bool? avoidReuse,
    WalletScan? scanning,
    $core.bool? descriptors,
    $core.bool? externalSigner,
  }) {
    final $result = create();
    if (walletName != null) {
      $result.walletName = walletName;
    }
    if (walletVersion != null) {
      $result.walletVersion = walletVersion;
    }
    if (format != null) {
      $result.format = format;
    }
    if (txCount != null) {
      $result.txCount = txCount;
    }
    if (keyPoolSize != null) {
      $result.keyPoolSize = keyPoolSize;
    }
    if (keyPoolSizeHdInternal != null) {
      $result.keyPoolSizeHdInternal = keyPoolSizeHdInternal;
    }
    if (payTxFee != null) {
      $result.payTxFee = payTxFee;
    }
    if (privateKeysEnabled != null) {
      $result.privateKeysEnabled = privateKeysEnabled;
    }
    if (avoidReuse != null) {
      $result.avoidReuse = avoidReuse;
    }
    if (scanning != null) {
      $result.scanning = scanning;
    }
    if (descriptors != null) {
      $result.descriptors = descriptors;
    }
    if (externalSigner != null) {
      $result.externalSigner = externalSigner;
    }
    return $result;
  }
  GetWalletInfoResponse._() : super();
  factory GetWalletInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWalletInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletName')
    ..aInt64(2, _omitFieldNames ? '' : 'walletVersion')
    ..aOS(3, _omitFieldNames ? '' : 'format')
    ..aInt64(7, _omitFieldNames ? '' : 'txCount')
    ..aInt64(8, _omitFieldNames ? '' : 'keyPoolSize')
    ..aInt64(9, _omitFieldNames ? '' : 'keyPoolSizeHdInternal')
    ..a<$core.double>(10, _omitFieldNames ? '' : 'payTxFee', $pb.PbFieldType.OD)
    ..aOB(11, _omitFieldNames ? '' : 'privateKeysEnabled')
    ..aOB(12, _omitFieldNames ? '' : 'avoidReuse')
    ..aOM<WalletScan>(13, _omitFieldNames ? '' : 'scanning', subBuilder: WalletScan.create)
    ..aOB(14, _omitFieldNames ? '' : 'descriptors')
    ..aOB(15, _omitFieldNames ? '' : 'externalSigner')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWalletInfoResponse clone() => GetWalletInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWalletInfoResponse copyWith(void Function(GetWalletInfoResponse) updates) => super.copyWith((message) => updates(message as GetWalletInfoResponse)) as GetWalletInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWalletInfoResponse create() => GetWalletInfoResponse._();
  GetWalletInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetWalletInfoResponse> createRepeated() => $pb.PbList<GetWalletInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetWalletInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWalletInfoResponse>(create);
  static GetWalletInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletName => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletName() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletName() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get walletVersion => $_getI64(1);
  @$pb.TagNumber(2)
  set walletVersion($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWalletVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletVersion() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get format => $_getSZ(2);
  @$pb.TagNumber(3)
  set format($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFormat() => $_has(2);
  @$pb.TagNumber(3)
  void clearFormat() => clearField(3);

  @$pb.TagNumber(7)
  $fixnum.Int64 get txCount => $_getI64(3);
  @$pb.TagNumber(7)
  set txCount($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(7)
  $core.bool hasTxCount() => $_has(3);
  @$pb.TagNumber(7)
  void clearTxCount() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get keyPoolSize => $_getI64(4);
  @$pb.TagNumber(8)
  set keyPoolSize($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(8)
  $core.bool hasKeyPoolSize() => $_has(4);
  @$pb.TagNumber(8)
  void clearKeyPoolSize() => clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get keyPoolSizeHdInternal => $_getI64(5);
  @$pb.TagNumber(9)
  set keyPoolSizeHdInternal($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(9)
  $core.bool hasKeyPoolSizeHdInternal() => $_has(5);
  @$pb.TagNumber(9)
  void clearKeyPoolSizeHdInternal() => clearField(9);

  @$pb.TagNumber(10)
  $core.double get payTxFee => $_getN(6);
  @$pb.TagNumber(10)
  set payTxFee($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(10)
  $core.bool hasPayTxFee() => $_has(6);
  @$pb.TagNumber(10)
  void clearPayTxFee() => clearField(10);

  @$pb.TagNumber(11)
  $core.bool get privateKeysEnabled => $_getBF(7);
  @$pb.TagNumber(11)
  set privateKeysEnabled($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(11)
  $core.bool hasPrivateKeysEnabled() => $_has(7);
  @$pb.TagNumber(11)
  void clearPrivateKeysEnabled() => clearField(11);

  @$pb.TagNumber(12)
  $core.bool get avoidReuse => $_getBF(8);
  @$pb.TagNumber(12)
  set avoidReuse($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(12)
  $core.bool hasAvoidReuse() => $_has(8);
  @$pb.TagNumber(12)
  void clearAvoidReuse() => clearField(12);

  /// Not set if no scan is in progress.
  @$pb.TagNumber(13)
  WalletScan get scanning => $_getN(9);
  @$pb.TagNumber(13)
  set scanning(WalletScan v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasScanning() => $_has(9);
  @$pb.TagNumber(13)
  void clearScanning() => clearField(13);
  @$pb.TagNumber(13)
  WalletScan ensureScanning() => $_ensure(9);

  @$pb.TagNumber(14)
  $core.bool get descriptors => $_getBF(10);
  @$pb.TagNumber(14)
  set descriptors($core.bool v) { $_setBool(10, v); }
  @$pb.TagNumber(14)
  $core.bool hasDescriptors() => $_has(10);
  @$pb.TagNumber(14)
  void clearDescriptors() => clearField(14);

  @$pb.TagNumber(15)
  $core.bool get externalSigner => $_getBF(11);
  @$pb.TagNumber(15)
  set externalSigner($core.bool v) { $_setBool(11, v); }
  @$pb.TagNumber(15)
  $core.bool hasExternalSigner() => $_has(11);
  @$pb.TagNumber(15)
  void clearExternalSigner() => clearField(15);
}

class GetBalancesRequest extends $pb.GeneratedMessage {
  factory GetBalancesRequest({
    $core.String? wallet,
  }) {
    final $result = create();
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  GetBalancesRequest._() : super();
  factory GetBalancesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBalancesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalancesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBalancesRequest clone() => GetBalancesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBalancesRequest copyWith(void Function(GetBalancesRequest) updates) => super.copyWith((message) => updates(message as GetBalancesRequest)) as GetBalancesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBalancesRequest create() => GetBalancesRequest._();
  GetBalancesRequest createEmptyInstance() => create();
  static $pb.PbList<GetBalancesRequest> createRepeated() => $pb.PbList<GetBalancesRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBalancesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalancesRequest>(create);
  static GetBalancesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => clearField(1);
}

/// balances from outputs that the wallet can sign
class GetBalancesResponse_Mine extends $pb.GeneratedMessage {
  factory GetBalancesResponse_Mine({
    $core.double? trusted,
    $core.double? untrustedPending,
    $core.double? immature,
    $core.double? used,
  }) {
    final $result = create();
    if (trusted != null) {
      $result.trusted = trusted;
    }
    if (untrustedPending != null) {
      $result.untrustedPending = untrustedPending;
    }
    if (immature != null) {
      $result.immature = immature;
    }
    if (used != null) {
      $result.used = used;
    }
    return $result;
  }
  GetBalancesResponse_Mine._() : super();
  factory GetBalancesResponse_Mine.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBalancesResponse_Mine.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalancesResponse.Mine', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'trusted', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'untrustedPending', $pb.PbFieldType.OD)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'immature', $pb.PbFieldType.OD)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'used', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBalancesResponse_Mine clone() => GetBalancesResponse_Mine()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBalancesResponse_Mine copyWith(void Function(GetBalancesResponse_Mine) updates) => super.copyWith((message) => updates(message as GetBalancesResponse_Mine)) as GetBalancesResponse_Mine;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBalancesResponse_Mine create() => GetBalancesResponse_Mine._();
  GetBalancesResponse_Mine createEmptyInstance() => create();
  static $pb.PbList<GetBalancesResponse_Mine> createRepeated() => $pb.PbList<GetBalancesResponse_Mine>();
  @$core.pragma('dart2js:noInline')
  static GetBalancesResponse_Mine getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalancesResponse_Mine>(create);
  static GetBalancesResponse_Mine? _defaultInstance;

  /// trusted balance (outputs created by the wallet or confirmed outputs)
  @$pb.TagNumber(1)
  $core.double get trusted => $_getN(0);
  @$pb.TagNumber(1)
  set trusted($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTrusted() => $_has(0);
  @$pb.TagNumber(1)
  void clearTrusted() => clearField(1);

  /// untrusted pending balance (outputs created by others that are in the mempool)
  @$pb.TagNumber(2)
  $core.double get untrustedPending => $_getN(1);
  @$pb.TagNumber(2)
  set untrustedPending($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUntrustedPending() => $_has(1);
  @$pb.TagNumber(2)
  void clearUntrustedPending() => clearField(2);

  /// balance from immature coinbase outputs
  @$pb.TagNumber(3)
  $core.double get immature => $_getN(2);
  @$pb.TagNumber(3)
  set immature($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasImmature() => $_has(2);
  @$pb.TagNumber(3)
  void clearImmature() => clearField(3);

  /// only present if avoid_reuse is set) balance from coins sent to addresses that were previously spent from (potentially privacy violating
  @$pb.TagNumber(4)
  $core.double get used => $_getN(3);
  @$pb.TagNumber(4)
  set used($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUsed() => $_has(3);
  @$pb.TagNumber(4)
  void clearUsed() => clearField(4);
}

/// watchonly balances (not present if wallet does not watch anything)
class GetBalancesResponse_Watchonly extends $pb.GeneratedMessage {
  factory GetBalancesResponse_Watchonly({
    $core.double? trusted,
    $core.double? untrustedPending,
    $core.double? immature,
  }) {
    final $result = create();
    if (trusted != null) {
      $result.trusted = trusted;
    }
    if (untrustedPending != null) {
      $result.untrustedPending = untrustedPending;
    }
    if (immature != null) {
      $result.immature = immature;
    }
    return $result;
  }
  GetBalancesResponse_Watchonly._() : super();
  factory GetBalancesResponse_Watchonly.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBalancesResponse_Watchonly.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalancesResponse.Watchonly', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'trusted', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'untrustedPending', $pb.PbFieldType.OD)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'immature', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBalancesResponse_Watchonly clone() => GetBalancesResponse_Watchonly()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBalancesResponse_Watchonly copyWith(void Function(GetBalancesResponse_Watchonly) updates) => super.copyWith((message) => updates(message as GetBalancesResponse_Watchonly)) as GetBalancesResponse_Watchonly;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBalancesResponse_Watchonly create() => GetBalancesResponse_Watchonly._();
  GetBalancesResponse_Watchonly createEmptyInstance() => create();
  static $pb.PbList<GetBalancesResponse_Watchonly> createRepeated() => $pb.PbList<GetBalancesResponse_Watchonly>();
  @$core.pragma('dart2js:noInline')
  static GetBalancesResponse_Watchonly getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalancesResponse_Watchonly>(create);
  static GetBalancesResponse_Watchonly? _defaultInstance;

  /// trusted balance (outputs created by the wallet or confirmed outputs)
  @$pb.TagNumber(1)
  $core.double get trusted => $_getN(0);
  @$pb.TagNumber(1)
  set trusted($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTrusted() => $_has(0);
  @$pb.TagNumber(1)
  void clearTrusted() => clearField(1);

  /// untrusted pending balance (outputs created by others that are in the mempool)
  @$pb.TagNumber(2)
  $core.double get untrustedPending => $_getN(1);
  @$pb.TagNumber(2)
  set untrustedPending($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUntrustedPending() => $_has(1);
  @$pb.TagNumber(2)
  void clearUntrustedPending() => clearField(2);

  /// balance from immature coinbase outputs
  @$pb.TagNumber(3)
  $core.double get immature => $_getN(2);
  @$pb.TagNumber(3)
  set immature($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasImmature() => $_has(2);
  @$pb.TagNumber(3)
  void clearImmature() => clearField(3);
}

class GetBalancesResponse extends $pb.GeneratedMessage {
  factory GetBalancesResponse({
    GetBalancesResponse_Mine? mine,
    GetBalancesResponse_Watchonly? watchonly,
  }) {
    final $result = create();
    if (mine != null) {
      $result.mine = mine;
    }
    if (watchonly != null) {
      $result.watchonly = watchonly;
    }
    return $result;
  }
  GetBalancesResponse._() : super();
  factory GetBalancesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBalancesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalancesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOM<GetBalancesResponse_Mine>(1, _omitFieldNames ? '' : 'mine', subBuilder: GetBalancesResponse_Mine.create)
    ..aOM<GetBalancesResponse_Watchonly>(2, _omitFieldNames ? '' : 'watchonly', subBuilder: GetBalancesResponse_Watchonly.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBalancesResponse clone() => GetBalancesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBalancesResponse copyWith(void Function(GetBalancesResponse) updates) => super.copyWith((message) => updates(message as GetBalancesResponse)) as GetBalancesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBalancesResponse create() => GetBalancesResponse._();
  GetBalancesResponse createEmptyInstance() => create();
  static $pb.PbList<GetBalancesResponse> createRepeated() => $pb.PbList<GetBalancesResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBalancesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalancesResponse>(create);
  static GetBalancesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GetBalancesResponse_Mine get mine => $_getN(0);
  @$pb.TagNumber(1)
  set mine(GetBalancesResponse_Mine v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasMine() => $_has(0);
  @$pb.TagNumber(1)
  void clearMine() => clearField(1);
  @$pb.TagNumber(1)
  GetBalancesResponse_Mine ensureMine() => $_ensure(0);

  @$pb.TagNumber(2)
  GetBalancesResponse_Watchonly get watchonly => $_getN(1);
  @$pb.TagNumber(2)
  set watchonly(GetBalancesResponse_Watchonly v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasWatchonly() => $_has(1);
  @$pb.TagNumber(2)
  void clearWatchonly() => clearField(2);
  @$pb.TagNumber(2)
  GetBalancesResponse_Watchonly ensureWatchonly() => $_ensure(1);
}

class WalletScan extends $pb.GeneratedMessage {
  factory WalletScan({
    $fixnum.Int64? duration,
    $core.double? progress,
  }) {
    final $result = create();
    if (duration != null) {
      $result.duration = duration;
    }
    if (progress != null) {
      $result.progress = progress;
    }
    return $result;
  }
  WalletScan._() : super();
  factory WalletScan.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WalletScan.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WalletScan', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'duration')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'progress', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WalletScan clone() => WalletScan()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WalletScan copyWith(void Function(WalletScan) updates) => super.copyWith((message) => updates(message as WalletScan)) as WalletScan;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WalletScan create() => WalletScan._();
  WalletScan createEmptyInstance() => create();
  static $pb.PbList<WalletScan> createRepeated() => $pb.PbList<WalletScan>();
  @$core.pragma('dart2js:noInline')
  static WalletScan getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WalletScan>(create);
  static WalletScan? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get duration => $_getI64(0);
  @$pb.TagNumber(1)
  set duration($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDuration() => $_has(0);
  @$pb.TagNumber(1)
  void clearDuration() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get progress => $_getN(1);
  @$pb.TagNumber(2)
  set progress($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProgress() => $_has(1);
  @$pb.TagNumber(2)
  void clearProgress() => clearField(2);
}

class GetTransactionRequest extends $pb.GeneratedMessage {
  factory GetTransactionRequest({
    $core.String? txid,
    $core.bool? includeWatchonly,
    $core.bool? verbose,
    $core.String? wallet,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (includeWatchonly != null) {
      $result.includeWatchonly = includeWatchonly;
    }
    if (verbose != null) {
      $result.verbose = verbose;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  GetTransactionRequest._() : super();
  factory GetTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOB(2, _omitFieldNames ? '' : 'includeWatchonly')
    ..aOB(3, _omitFieldNames ? '' : 'verbose')
    ..aOS(4, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransactionRequest clone() => GetTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransactionRequest copyWith(void Function(GetTransactionRequest) updates) => super.copyWith((message) => updates(message as GetTransactionRequest)) as GetTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionRequest create() => GetTransactionRequest._();
  GetTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<GetTransactionRequest> createRepeated() => $pb.PbList<GetTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static GetTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransactionRequest>(create);
  static GetTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get includeWatchonly => $_getBF(1);
  @$pb.TagNumber(2)
  set includeWatchonly($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIncludeWatchonly() => $_has(1);
  @$pb.TagNumber(2)
  void clearIncludeWatchonly() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get verbose => $_getBF(2);
  @$pb.TagNumber(3)
  set verbose($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasVerbose() => $_has(2);
  @$pb.TagNumber(3)
  void clearVerbose() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get wallet => $_getSZ(3);
  @$pb.TagNumber(4)
  set wallet($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWallet() => $_has(3);
  @$pb.TagNumber(4)
  void clearWallet() => clearField(4);
}

class GetTransactionResponse_Details extends $pb.GeneratedMessage {
  factory GetTransactionResponse_Details({
    $core.bool? involvesWatchOnly,
    $core.String? address,
    GetTransactionResponse_Category? category,
    $core.double? amount,
    $core.int? vout,
    $core.double? fee,
  }) {
    final $result = create();
    if (involvesWatchOnly != null) {
      $result.involvesWatchOnly = involvesWatchOnly;
    }
    if (address != null) {
      $result.address = address;
    }
    if (category != null) {
      $result.category = category;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (fee != null) {
      $result.fee = fee;
    }
    return $result;
  }
  GetTransactionResponse_Details._() : super();
  factory GetTransactionResponse_Details.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionResponse_Details.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionResponse.Details', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'involvesWatchOnly')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..e<GetTransactionResponse_Category>(3, _omitFieldNames ? '' : 'category', $pb.PbFieldType.OE, defaultOrMaker: GetTransactionResponse_Category.CATEGORY_UNSPECIFIED, valueOf: GetTransactionResponse_Category.valueOf, enumValues: GetTransactionResponse_Category.values)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
    ..a<$core.double>(7, _omitFieldNames ? '' : 'fee', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransactionResponse_Details clone() => GetTransactionResponse_Details()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransactionResponse_Details copyWith(void Function(GetTransactionResponse_Details) updates) => super.copyWith((message) => updates(message as GetTransactionResponse_Details)) as GetTransactionResponse_Details;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionResponse_Details create() => GetTransactionResponse_Details._();
  GetTransactionResponse_Details createEmptyInstance() => create();
  static $pb.PbList<GetTransactionResponse_Details> createRepeated() => $pb.PbList<GetTransactionResponse_Details>();
  @$core.pragma('dart2js:noInline')
  static GetTransactionResponse_Details getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransactionResponse_Details>(create);
  static GetTransactionResponse_Details? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get involvesWatchOnly => $_getBF(0);
  @$pb.TagNumber(1)
  set involvesWatchOnly($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasInvolvesWatchOnly() => $_has(0);
  @$pb.TagNumber(1)
  void clearInvolvesWatchOnly() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);

  @$pb.TagNumber(3)
  GetTransactionResponse_Category get category => $_getN(2);
  @$pb.TagNumber(3)
  set category(GetTransactionResponse_Category v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasCategory() => $_has(2);
  @$pb.TagNumber(3)
  void clearCategory() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get amount => $_getN(3);
  @$pb.TagNumber(4)
  set amount($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => clearField(4);

  /// string label = 5;
  @$pb.TagNumber(6)
  $core.int get vout => $_getIZ(4);
  @$pb.TagNumber(6)
  set vout($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasVout() => $_has(4);
  @$pb.TagNumber(6)
  void clearVout() => clearField(6);

  @$pb.TagNumber(7)
  $core.double get fee => $_getN(5);
  @$pb.TagNumber(7)
  set fee($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(7)
  $core.bool hasFee() => $_has(5);
  @$pb.TagNumber(7)
  void clearFee() => clearField(7);
}

/// Commented fields are not present in btcd/rpcclient
class GetTransactionResponse extends $pb.GeneratedMessage {
  factory GetTransactionResponse({
    $core.double? amount,
    $core.double? fee,
    $core.int? confirmations,
    $core.String? blockHash,
    $core.int? blockIndex,
    $0.Timestamp? blockTime,
    $core.String? txid,
    $core.Iterable<$core.String>? walletConflicts,
    $core.String? replacedByTxid,
    $core.String? replacesTxid,
    $0.Timestamp? time,
    $0.Timestamp? timeReceived,
    GetTransactionResponse_Replaceable? bip125Replaceable,
    $core.Iterable<GetTransactionResponse_Details>? details,
    $core.String? hex,
  }) {
    final $result = create();
    if (amount != null) {
      $result.amount = amount;
    }
    if (fee != null) {
      $result.fee = fee;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    if (blockIndex != null) {
      $result.blockIndex = blockIndex;
    }
    if (blockTime != null) {
      $result.blockTime = blockTime;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (walletConflicts != null) {
      $result.walletConflicts.addAll(walletConflicts);
    }
    if (replacedByTxid != null) {
      $result.replacedByTxid = replacedByTxid;
    }
    if (replacesTxid != null) {
      $result.replacesTxid = replacesTxid;
    }
    if (time != null) {
      $result.time = time;
    }
    if (timeReceived != null) {
      $result.timeReceived = timeReceived;
    }
    if (bip125Replaceable != null) {
      $result.bip125Replaceable = bip125Replaceable;
    }
    if (details != null) {
      $result.details.addAll(details);
    }
    if (hex != null) {
      $result.hex = hex;
    }
    return $result;
  }
  GetTransactionResponse._() : super();
  factory GetTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'fee', $pb.PbFieldType.OD)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..aOS(6, _omitFieldNames ? '' : 'blockHash')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'blockIndex', $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'blockTime', subBuilder: $0.Timestamp.create)
    ..aOS(10, _omitFieldNames ? '' : 'txid')
    ..pPS(12, _omitFieldNames ? '' : 'walletConflicts')
    ..aOS(13, _omitFieldNames ? '' : 'replacedByTxid')
    ..aOS(14, _omitFieldNames ? '' : 'replacesTxid')
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'time', subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(18, _omitFieldNames ? '' : 'timeReceived', subBuilder: $0.Timestamp.create)
    ..e<GetTransactionResponse_Replaceable>(19, _omitFieldNames ? '' : 'bip125Replaceable', $pb.PbFieldType.OE, defaultOrMaker: GetTransactionResponse_Replaceable.REPLACEABLE_UNSPECIFIED, valueOf: GetTransactionResponse_Replaceable.valueOf, enumValues: GetTransactionResponse_Replaceable.values)
    ..pc<GetTransactionResponse_Details>(21, _omitFieldNames ? '' : 'details', $pb.PbFieldType.PM, subBuilder: GetTransactionResponse_Details.create)
    ..aOS(22, _omitFieldNames ? '' : 'hex')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransactionResponse clone() => GetTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransactionResponse copyWith(void Function(GetTransactionResponse) updates) => super.copyWith((message) => updates(message as GetTransactionResponse)) as GetTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionResponse create() => GetTransactionResponse._();
  GetTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<GetTransactionResponse> createRepeated() => $pb.PbList<GetTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static GetTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransactionResponse>(create);
  static GetTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get amount => $_getN(0);
  @$pb.TagNumber(1)
  set amount($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAmount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAmount() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get fee => $_getN(1);
  @$pb.TagNumber(2)
  set fee($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFee() => $_has(1);
  @$pb.TagNumber(2)
  void clearFee() => clearField(2);

  /// The number of confirmations for the transaction. Negative
  /// confirmations means the transaction conflicted that many
  /// blocks ago.
  @$pb.TagNumber(3)
  $core.int get confirmations => $_getIZ(2);
  @$pb.TagNumber(3)
  set confirmations($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasConfirmations() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfirmations() => clearField(3);

  /// bool generated = 4;
  /// bool trusted = 5;
  @$pb.TagNumber(6)
  $core.String get blockHash => $_getSZ(3);
  @$pb.TagNumber(6)
  set blockHash($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(6)
  $core.bool hasBlockHash() => $_has(3);
  @$pb.TagNumber(6)
  void clearBlockHash() => clearField(6);

  /// string block_height = 7;
  @$pb.TagNumber(8)
  $core.int get blockIndex => $_getIZ(4);
  @$pb.TagNumber(8)
  set blockIndex($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(8)
  $core.bool hasBlockIndex() => $_has(4);
  @$pb.TagNumber(8)
  void clearBlockIndex() => clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get blockTime => $_getN(5);
  @$pb.TagNumber(9)
  set blockTime($0.Timestamp v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasBlockTime() => $_has(5);
  @$pb.TagNumber(9)
  void clearBlockTime() => clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureBlockTime() => $_ensure(5);

  @$pb.TagNumber(10)
  $core.String get txid => $_getSZ(6);
  @$pb.TagNumber(10)
  set txid($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(10)
  $core.bool hasTxid() => $_has(6);
  @$pb.TagNumber(10)
  void clearTxid() => clearField(10);

  /// string witness_txid = 11;
  @$pb.TagNumber(12)
  $core.List<$core.String> get walletConflicts => $_getList(7);

  @$pb.TagNumber(13)
  $core.String get replacedByTxid => $_getSZ(8);
  @$pb.TagNumber(13)
  set replacedByTxid($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(13)
  $core.bool hasReplacedByTxid() => $_has(8);
  @$pb.TagNumber(13)
  void clearReplacedByTxid() => clearField(13);

  @$pb.TagNumber(14)
  $core.String get replacesTxid => $_getSZ(9);
  @$pb.TagNumber(14)
  set replacesTxid($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(14)
  $core.bool hasReplacesTxid() => $_has(9);
  @$pb.TagNumber(14)
  void clearReplacesTxid() => clearField(14);

  /// string comment = 15;
  /// string to = 16;
  @$pb.TagNumber(17)
  $0.Timestamp get time => $_getN(10);
  @$pb.TagNumber(17)
  set time($0.Timestamp v) { setField(17, v); }
  @$pb.TagNumber(17)
  $core.bool hasTime() => $_has(10);
  @$pb.TagNumber(17)
  void clearTime() => clearField(17);
  @$pb.TagNumber(17)
  $0.Timestamp ensureTime() => $_ensure(10);

  @$pb.TagNumber(18)
  $0.Timestamp get timeReceived => $_getN(11);
  @$pb.TagNumber(18)
  set timeReceived($0.Timestamp v) { setField(18, v); }
  @$pb.TagNumber(18)
  $core.bool hasTimeReceived() => $_has(11);
  @$pb.TagNumber(18)
  void clearTimeReceived() => clearField(18);
  @$pb.TagNumber(18)
  $0.Timestamp ensureTimeReceived() => $_ensure(11);

  ///  Whether this transaction signals BIP125 (Replace-by-fee, RBF) replaceability
  ///  or has an unconfirmed ancestor signaling BIP125 replaceability. May be unspecified
  ///  for unconfirmed transactions not in the mempool because their
  ///  unconfirmed ancestors are unknown.
  ///
  ///  Note that this is always set to 'no' once the transaction is confirmed.
  @$pb.TagNumber(19)
  GetTransactionResponse_Replaceable get bip125Replaceable => $_getN(12);
  @$pb.TagNumber(19)
  set bip125Replaceable(GetTransactionResponse_Replaceable v) { setField(19, v); }
  @$pb.TagNumber(19)
  $core.bool hasBip125Replaceable() => $_has(12);
  @$pb.TagNumber(19)
  void clearBip125Replaceable() => clearField(19);

  @$pb.TagNumber(21)
  $core.List<GetTransactionResponse_Details> get details => $_getList(13);

  @$pb.TagNumber(22)
  $core.String get hex => $_getSZ(14);
  @$pb.TagNumber(22)
  set hex($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(22)
  $core.bool hasHex() => $_has(14);
  @$pb.TagNumber(22)
  void clearHex() => clearField(22);
}

class GetRawTransactionRequest extends $pb.GeneratedMessage {
  factory GetRawTransactionRequest({
    $core.String? txid,
    $core.bool? verbose,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (verbose != null) {
      $result.verbose = verbose;
    }
    return $result;
  }
  GetRawTransactionRequest._() : super();
  factory GetRawTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetRawTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRawTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOB(2, _omitFieldNames ? '' : 'verbose')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetRawTransactionRequest clone() => GetRawTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetRawTransactionRequest copyWith(void Function(GetRawTransactionRequest) updates) => super.copyWith((message) => updates(message as GetRawTransactionRequest)) as GetRawTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRawTransactionRequest create() => GetRawTransactionRequest._();
  GetRawTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<GetRawTransactionRequest> createRepeated() => $pb.PbList<GetRawTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static GetRawTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetRawTransactionRequest>(create);
  static GetRawTransactionRequest? _defaultInstance;

  /// The transaction ID. Required.
  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  /// If false, returns just the hex string. Otherwise, returns the complete object.
  @$pb.TagNumber(2)
  $core.bool get verbose => $_getBF(1);
  @$pb.TagNumber(2)
  set verbose($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVerbose() => $_has(1);
  @$pb.TagNumber(2)
  void clearVerbose() => clearField(2);
}

class ScriptSig extends $pb.GeneratedMessage {
  factory ScriptSig({
    $core.String? asm,
    $core.String? hex,
  }) {
    final $result = create();
    if (asm != null) {
      $result.asm = asm;
    }
    if (hex != null) {
      $result.hex = hex;
    }
    return $result;
  }
  ScriptSig._() : super();
  factory ScriptSig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ScriptSig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScriptSig', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'asm')
    ..aOS(2, _omitFieldNames ? '' : 'hex')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ScriptSig clone() => ScriptSig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ScriptSig copyWith(void Function(ScriptSig) updates) => super.copyWith((message) => updates(message as ScriptSig)) as ScriptSig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScriptSig create() => ScriptSig._();
  ScriptSig createEmptyInstance() => create();
  static $pb.PbList<ScriptSig> createRepeated() => $pb.PbList<ScriptSig>();
  @$core.pragma('dart2js:noInline')
  static ScriptSig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScriptSig>(create);
  static ScriptSig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get asm => $_getSZ(0);
  @$pb.TagNumber(1)
  set asm($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAsm() => $_has(0);
  @$pb.TagNumber(1)
  void clearAsm() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get hex => $_getSZ(1);
  @$pb.TagNumber(2)
  set hex($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearHex() => clearField(2);
}

class Input extends $pb.GeneratedMessage {
  factory Input({
    $core.String? txid,
    $core.int? vout,
    $core.String? coinbase,
    ScriptSig? scriptSig,
    $core.int? sequence,
    $core.Iterable<$core.String>? witness,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (coinbase != null) {
      $result.coinbase = coinbase;
    }
    if (scriptSig != null) {
      $result.scriptSig = scriptSig;
    }
    if (sequence != null) {
      $result.sequence = sequence;
    }
    if (witness != null) {
      $result.witness.addAll(witness);
    }
    return $result;
  }
  Input._() : super();
  factory Input.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Input.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Input', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'coinbase')
    ..aOM<ScriptSig>(4, _omitFieldNames ? '' : 'scriptSig', subBuilder: ScriptSig.create)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'sequence', $pb.PbFieldType.OU3)
    ..pPS(6, _omitFieldNames ? '' : 'witness')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Input clone() => Input()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Input copyWith(void Function(Input) updates) => super.copyWith((message) => updates(message as Input)) as Input;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Input create() => Input._();
  Input createEmptyInstance() => create();
  static $pb.PbList<Input> createRepeated() => $pb.PbList<Input>();
  @$core.pragma('dart2js:noInline')
  static Input getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Input>(create);
  static Input? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get coinbase => $_getSZ(2);
  @$pb.TagNumber(3)
  set coinbase($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCoinbase() => $_has(2);
  @$pb.TagNumber(3)
  void clearCoinbase() => clearField(3);

  @$pb.TagNumber(4)
  ScriptSig get scriptSig => $_getN(3);
  @$pb.TagNumber(4)
  set scriptSig(ScriptSig v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasScriptSig() => $_has(3);
  @$pb.TagNumber(4)
  void clearScriptSig() => clearField(4);
  @$pb.TagNumber(4)
  ScriptSig ensureScriptSig() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.int get sequence => $_getIZ(4);
  @$pb.TagNumber(5)
  set sequence($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSequence() => $_has(4);
  @$pb.TagNumber(5)
  void clearSequence() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.String> get witness => $_getList(5);
}

class ScriptPubKey extends $pb.GeneratedMessage {
  factory ScriptPubKey({
    $core.String? type,
    $core.String? address,
    $core.String? asm,
    $core.String? hex,
    $core.Iterable<$core.String>? addresses,
    $core.int? reqSigs,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (address != null) {
      $result.address = address;
    }
    if (asm != null) {
      $result.asm = asm;
    }
    if (hex != null) {
      $result.hex = hex;
    }
    if (addresses != null) {
      $result.addresses.addAll(addresses);
    }
    if (reqSigs != null) {
      $result.reqSigs = reqSigs;
    }
    return $result;
  }
  ScriptPubKey._() : super();
  factory ScriptPubKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ScriptPubKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScriptPubKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aOS(3, _omitFieldNames ? '' : 'asm')
    ..aOS(4, _omitFieldNames ? '' : 'hex')
    ..pPS(5, _omitFieldNames ? '' : 'addresses')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'reqSigs', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ScriptPubKey clone() => ScriptPubKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ScriptPubKey copyWith(void Function(ScriptPubKey) updates) => super.copyWith((message) => updates(message as ScriptPubKey)) as ScriptPubKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScriptPubKey create() => ScriptPubKey._();
  ScriptPubKey createEmptyInstance() => create();
  static $pb.PbList<ScriptPubKey> createRepeated() => $pb.PbList<ScriptPubKey>();
  @$core.pragma('dart2js:noInline')
  static ScriptPubKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScriptPubKey>(create);
  static ScriptPubKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get asm => $_getSZ(2);
  @$pb.TagNumber(3)
  set asm($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAsm() => $_has(2);
  @$pb.TagNumber(3)
  void clearAsm() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get hex => $_getSZ(3);
  @$pb.TagNumber(4)
  set hex($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHex() => $_has(3);
  @$pb.TagNumber(4)
  void clearHex() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.String> get addresses => $_getList(4);

  @$pb.TagNumber(6)
  $core.int get reqSigs => $_getIZ(5);
  @$pb.TagNumber(6)
  set reqSigs($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasReqSigs() => $_has(5);
  @$pb.TagNumber(6)
  void clearReqSigs() => clearField(6);
}

class Output extends $pb.GeneratedMessage {
  factory Output({
    $core.double? amount,
    $core.int? vout,
    ScriptPubKey? scriptPubKey,
    ScriptSig? scriptSig,
  }) {
    final $result = create();
    if (amount != null) {
      $result.amount = amount;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (scriptPubKey != null) {
      $result.scriptPubKey = scriptPubKey;
    }
    if (scriptSig != null) {
      $result.scriptSig = scriptSig;
    }
    return $result;
  }
  Output._() : super();
  factory Output.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Output.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Output', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
    ..aOM<ScriptPubKey>(3, _omitFieldNames ? '' : 'scriptPubKey', subBuilder: ScriptPubKey.create)
    ..aOM<ScriptSig>(4, _omitFieldNames ? '' : 'scriptSig', subBuilder: ScriptSig.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Output clone() => Output()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Output copyWith(void Function(Output) updates) => super.copyWith((message) => updates(message as Output)) as Output;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Output create() => Output._();
  Output createEmptyInstance() => create();
  static $pb.PbList<Output> createRepeated() => $pb.PbList<Output>();
  @$core.pragma('dart2js:noInline')
  static Output getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Output>(create);
  static Output? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get amount => $_getN(0);
  @$pb.TagNumber(1)
  set amount($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAmount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAmount() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => clearField(2);

  @$pb.TagNumber(3)
  ScriptPubKey get scriptPubKey => $_getN(2);
  @$pb.TagNumber(3)
  set scriptPubKey(ScriptPubKey v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasScriptPubKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearScriptPubKey() => clearField(3);
  @$pb.TagNumber(3)
  ScriptPubKey ensureScriptPubKey() => $_ensure(2);

  @$pb.TagNumber(4)
  ScriptSig get scriptSig => $_getN(3);
  @$pb.TagNumber(4)
  set scriptSig(ScriptSig v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasScriptSig() => $_has(3);
  @$pb.TagNumber(4)
  void clearScriptSig() => clearField(4);
  @$pb.TagNumber(4)
  ScriptSig ensureScriptSig() => $_ensure(3);
}

class GetRawTransactionResponse extends $pb.GeneratedMessage {
  factory GetRawTransactionResponse({
    RawTransaction? tx,
    $core.Iterable<Input>? inputs,
    $core.Iterable<Output>? outputs,
    $core.String? blockhash,
    $core.int? confirmations,
    $fixnum.Int64? time,
    $fixnum.Int64? blocktime,
    $core.String? txid,
    $core.String? hash,
    $core.int? size,
    $core.int? vsize,
    $core.int? weight,
    $core.int? version,
    $core.int? locktime,
  }) {
    final $result = create();
    if (tx != null) {
      $result.tx = tx;
    }
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    if (blockhash != null) {
      $result.blockhash = blockhash;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (time != null) {
      $result.time = time;
    }
    if (blocktime != null) {
      $result.blocktime = blocktime;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    if (size != null) {
      $result.size = size;
    }
    if (vsize != null) {
      $result.vsize = vsize;
    }
    if (weight != null) {
      $result.weight = weight;
    }
    if (version != null) {
      $result.version = version;
    }
    if (locktime != null) {
      $result.locktime = locktime;
    }
    return $result;
  }
  GetRawTransactionResponse._() : super();
  factory GetRawTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetRawTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRawTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOM<RawTransaction>(1, _omitFieldNames ? '' : 'tx', subBuilder: RawTransaction.create)
    ..pc<Input>(2, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: Input.create)
    ..pc<Output>(3, _omitFieldNames ? '' : 'outputs', $pb.PbFieldType.PM, subBuilder: Output.create)
    ..aOS(4, _omitFieldNames ? '' : 'blockhash')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.OU3)
    ..aInt64(6, _omitFieldNames ? '' : 'time')
    ..aInt64(7, _omitFieldNames ? '' : 'blocktime')
    ..aOS(8, _omitFieldNames ? '' : 'txid')
    ..aOS(9, _omitFieldNames ? '' : 'hash')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'size', $pb.PbFieldType.O3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'vsize', $pb.PbFieldType.O3)
    ..a<$core.int>(12, _omitFieldNames ? '' : 'weight', $pb.PbFieldType.O3)
    ..a<$core.int>(13, _omitFieldNames ? '' : 'version', $pb.PbFieldType.OU3)
    ..a<$core.int>(14, _omitFieldNames ? '' : 'locktime', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetRawTransactionResponse clone() => GetRawTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetRawTransactionResponse copyWith(void Function(GetRawTransactionResponse) updates) => super.copyWith((message) => updates(message as GetRawTransactionResponse)) as GetRawTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRawTransactionResponse create() => GetRawTransactionResponse._();
  GetRawTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<GetRawTransactionResponse> createRepeated() => $pb.PbList<GetRawTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static GetRawTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetRawTransactionResponse>(create);
  static GetRawTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RawTransaction get tx => $_getN(0);
  @$pb.TagNumber(1)
  set tx(RawTransaction v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTx() => $_has(0);
  @$pb.TagNumber(1)
  void clearTx() => clearField(1);
  @$pb.TagNumber(1)
  RawTransaction ensureTx() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<Input> get inputs => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<Output> get outputs => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get blockhash => $_getSZ(3);
  @$pb.TagNumber(4)
  set blockhash($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBlockhash() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockhash() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get confirmations => $_getIZ(4);
  @$pb.TagNumber(5)
  set confirmations($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasConfirmations() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmations() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get time => $_getI64(5);
  @$pb.TagNumber(6)
  set time($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearTime() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get blocktime => $_getI64(6);
  @$pb.TagNumber(7)
  set blocktime($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasBlocktime() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlocktime() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get txid => $_getSZ(7);
  @$pb.TagNumber(8)
  set txid($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasTxid() => $_has(7);
  @$pb.TagNumber(8)
  void clearTxid() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get hash => $_getSZ(8);
  @$pb.TagNumber(9)
  set hash($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasHash() => $_has(8);
  @$pb.TagNumber(9)
  void clearHash() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get size => $_getIZ(9);
  @$pb.TagNumber(10)
  set size($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasSize() => $_has(9);
  @$pb.TagNumber(10)
  void clearSize() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get vsize => $_getIZ(10);
  @$pb.TagNumber(11)
  set vsize($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasVsize() => $_has(10);
  @$pb.TagNumber(11)
  void clearVsize() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get weight => $_getIZ(11);
  @$pb.TagNumber(12)
  set weight($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasWeight() => $_has(11);
  @$pb.TagNumber(12)
  void clearWeight() => clearField(12);

  @$pb.TagNumber(13)
  $core.int get version => $_getIZ(12);
  @$pb.TagNumber(13)
  set version($core.int v) { $_setUnsignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasVersion() => $_has(12);
  @$pb.TagNumber(13)
  void clearVersion() => clearField(13);

  @$pb.TagNumber(14)
  $core.int get locktime => $_getIZ(13);
  @$pb.TagNumber(14)
  set locktime($core.int v) { $_setUnsignedInt32(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasLocktime() => $_has(13);
  @$pb.TagNumber(14)
  void clearLocktime() => clearField(14);
}

class SendRequest extends $pb.GeneratedMessage {
  factory SendRequest({
    $core.Map<$core.String, $core.double>? destinations,
    $core.int? confTarget,
    $core.String? wallet,
    $core.bool? includeUnsafe,
    $core.Iterable<$core.String>? subtractFeeFromOutputs,
    $2.BoolValue? addToWallet,
    $core.double? feeRate,
  }) {
    final $result = create();
    if (destinations != null) {
      $result.destinations.addAll(destinations);
    }
    if (confTarget != null) {
      $result.confTarget = confTarget;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    if (includeUnsafe != null) {
      $result.includeUnsafe = includeUnsafe;
    }
    if (subtractFeeFromOutputs != null) {
      $result.subtractFeeFromOutputs.addAll(subtractFeeFromOutputs);
    }
    if (addToWallet != null) {
      $result.addToWallet = addToWallet;
    }
    if (feeRate != null) {
      $result.feeRate = feeRate;
    }
    return $result;
  }
  SendRequest._() : super();
  factory SendRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..m<$core.String, $core.double>(1, _omitFieldNames ? '' : 'destinations', entryClassName: 'SendRequest.DestinationsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OD, packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..a<$core.int>(2, _omitFieldNames ? '' : 'confTarget', $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'wallet')
    ..aOB(4, _omitFieldNames ? '' : 'includeUnsafe')
    ..pPS(5, _omitFieldNames ? '' : 'subtractFeeFromOutputs')
    ..aOM<$2.BoolValue>(6, _omitFieldNames ? '' : 'addToWallet', subBuilder: $2.BoolValue.create)
    ..a<$core.double>(7, _omitFieldNames ? '' : 'feeRate', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendRequest clone() => SendRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendRequest copyWith(void Function(SendRequest) updates) => super.copyWith((message) => updates(message as SendRequest)) as SendRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendRequest create() => SendRequest._();
  SendRequest createEmptyInstance() => create();
  static $pb.PbList<SendRequest> createRepeated() => $pb.PbList<SendRequest>();
  @$core.pragma('dart2js:noInline')
  static SendRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendRequest>(create);
  static SendRequest? _defaultInstance;

  /// bitcoin address -> BTC amount
  @$pb.TagNumber(1)
  $core.Map<$core.String, $core.double> get destinations => $_getMap(0);

  /// Confirmation target in blocks.
  @$pb.TagNumber(2)
  $core.int get confTarget => $_getIZ(1);
  @$pb.TagNumber(2)
  set confTarget($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasConfTarget() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfTarget() => clearField(2);

  /// Only needs to be set if dealing with multiple wallets at the same time.
  /// TODO: better suited as a header?
  @$pb.TagNumber(3)
  $core.String get wallet => $_getSZ(2);
  @$pb.TagNumber(3)
  set wallet($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWallet() => $_has(2);
  @$pb.TagNumber(3)
  void clearWallet() => clearField(3);

  /// Include inputs that are not safe to spend (unconfirmed transactions from
  /// outside keys and unconfirmed replacement transactions.
  @$pb.TagNumber(4)
  $core.bool get includeUnsafe => $_getBF(3);
  @$pb.TagNumber(4)
  set includeUnsafe($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIncludeUnsafe() => $_has(3);
  @$pb.TagNumber(4)
  void clearIncludeUnsafe() => clearField(4);

  /// Outouts to subtract the fee from, specified as as address from the
  /// 'destinations' field. The fee will be equally deducted from the amount of
  /// each specified output.
  @$pb.TagNumber(5)
  $core.List<$core.String> get subtractFeeFromOutputs => $_getList(4);

  ///  When false, returns a serialized transaction which will not be added
  ///  to the wallet or broadcast.
  ///
  ///  This is a 'bool value' instead of a plain bool. This is clunky to
  ///  work with, but the alternative would have been to either:
  ///
  ///  1. Have this be a bool with the default value as the opposite of
  ///     Bitcoin Core
  ///  2. Rename the parameter to something else.
  ///
  ///  Both of these seem bad.
  @$pb.TagNumber(6)
  $2.BoolValue get addToWallet => $_getN(5);
  @$pb.TagNumber(6)
  set addToWallet($2.BoolValue v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasAddToWallet() => $_has(5);
  @$pb.TagNumber(6)
  void clearAddToWallet() => clearField(6);
  @$pb.TagNumber(6)
  $2.BoolValue ensureAddToWallet() => $_ensure(5);

  /// Satoshis per virtual byte (sat/vB).
  @$pb.TagNumber(7)
  $core.double get feeRate => $_getN(6);
  @$pb.TagNumber(7)
  set feeRate($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasFeeRate() => $_has(6);
  @$pb.TagNumber(7)
  void clearFeeRate() => clearField(7);
}

class SendResponse extends $pb.GeneratedMessage {
  factory SendResponse({
    $core.String? txid,
    $core.bool? complete,
    RawTransaction? tx,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (complete != null) {
      $result.complete = complete;
    }
    if (tx != null) {
      $result.tx = tx;
    }
    return $result;
  }
  SendResponse._() : super();
  factory SendResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOB(2, _omitFieldNames ? '' : 'complete')
    ..aOM<RawTransaction>(3, _omitFieldNames ? '' : 'tx', subBuilder: RawTransaction.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendResponse clone() => SendResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendResponse copyWith(void Function(SendResponse) updates) => super.copyWith((message) => updates(message as SendResponse)) as SendResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendResponse create() => SendResponse._();
  SendResponse createEmptyInstance() => create();
  static $pb.PbList<SendResponse> createRepeated() => $pb.PbList<SendResponse>();
  @$core.pragma('dart2js:noInline')
  static SendResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendResponse>(create);
  static SendResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get complete => $_getBF(1);
  @$pb.TagNumber(2)
  set complete($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasComplete() => $_has(1);
  @$pb.TagNumber(2)
  void clearComplete() => clearField(2);

  /// If 'add_to_wallet' is false, the raw transaction with signature(s)
  @$pb.TagNumber(3)
  RawTransaction get tx => $_getN(2);
  @$pb.TagNumber(3)
  set tx(RawTransaction v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasTx() => $_has(2);
  @$pb.TagNumber(3)
  void clearTx() => clearField(3);
  @$pb.TagNumber(3)
  RawTransaction ensureTx() => $_ensure(2);
}

class SendToAddressRequest extends $pb.GeneratedMessage {
  factory SendToAddressRequest({
    $core.String? address,
    $core.double? amount,
    $core.String? comment,
    $core.String? commentTo,
    $core.String? wallet,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (comment != null) {
      $result.comment = comment;
    }
    if (commentTo != null) {
      $result.commentTo = commentTo;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  SendToAddressRequest._() : super();
  factory SendToAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendToAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendToAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..aOS(3, _omitFieldNames ? '' : 'comment')
    ..aOS(4, _omitFieldNames ? '' : 'commentTo')
    ..aOS(5, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendToAddressRequest clone() => SendToAddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendToAddressRequest copyWith(void Function(SendToAddressRequest) updates) => super.copyWith((message) => updates(message as SendToAddressRequest)) as SendToAddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendToAddressRequest create() => SendToAddressRequest._();
  SendToAddressRequest createEmptyInstance() => create();
  static $pb.PbList<SendToAddressRequest> createRepeated() => $pb.PbList<SendToAddressRequest>();
  @$core.pragma('dart2js:noInline')
  static SendToAddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendToAddressRequest>(create);
  static SendToAddressRequest? _defaultInstance;

  /// The bitcoin address to send to.
  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  /// The amount in BTC to send. eg 0.1
  @$pb.TagNumber(2)
  $core.double get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);

  /// A comment used to store what the transaction is for. Not part of the transaction, just kept in your wallet.
  @$pb.TagNumber(3)
  $core.String get comment => $_getSZ(2);
  @$pb.TagNumber(3)
  set comment($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasComment() => $_has(2);
  @$pb.TagNumber(3)
  void clearComment() => clearField(3);

  /// A comment to store the name of the person or organization to which you're sending the transaction. Not part of the transaction, just kept in your wallet.
  @$pb.TagNumber(4)
  $core.String get commentTo => $_getSZ(3);
  @$pb.TagNumber(4)
  set commentTo($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCommentTo() => $_has(3);
  @$pb.TagNumber(4)
  void clearCommentTo() => clearField(4);

  /// Only needs to be set if dealing with multiple wallets at the same time.
  @$pb.TagNumber(5)
  $core.String get wallet => $_getSZ(4);
  @$pb.TagNumber(5)
  set wallet($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasWallet() => $_has(4);
  @$pb.TagNumber(5)
  void clearWallet() => clearField(5);
}

class SendToAddressResponse extends $pb.GeneratedMessage {
  factory SendToAddressResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  SendToAddressResponse._() : super();
  factory SendToAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendToAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendToAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendToAddressResponse clone() => SendToAddressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendToAddressResponse copyWith(void Function(SendToAddressResponse) updates) => super.copyWith((message) => updates(message as SendToAddressResponse)) as SendToAddressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendToAddressResponse create() => SendToAddressResponse._();
  SendToAddressResponse createEmptyInstance() => create();
  static $pb.PbList<SendToAddressResponse> createRepeated() => $pb.PbList<SendToAddressResponse>();
  @$core.pragma('dart2js:noInline')
  static SendToAddressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendToAddressResponse>(create);
  static SendToAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class EstimateSmartFeeRequest extends $pb.GeneratedMessage {
  factory EstimateSmartFeeRequest({
    $fixnum.Int64? confTarget,
    EstimateSmartFeeRequest_EstimateMode? estimateMode,
  }) {
    final $result = create();
    if (confTarget != null) {
      $result.confTarget = confTarget;
    }
    if (estimateMode != null) {
      $result.estimateMode = estimateMode;
    }
    return $result;
  }
  EstimateSmartFeeRequest._() : super();
  factory EstimateSmartFeeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EstimateSmartFeeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EstimateSmartFeeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'confTarget')
    ..e<EstimateSmartFeeRequest_EstimateMode>(2, _omitFieldNames ? '' : 'estimateMode', $pb.PbFieldType.OE, defaultOrMaker: EstimateSmartFeeRequest_EstimateMode.ESTIMATE_MODE_UNSPECIFIED, valueOf: EstimateSmartFeeRequest_EstimateMode.valueOf, enumValues: EstimateSmartFeeRequest_EstimateMode.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EstimateSmartFeeRequest clone() => EstimateSmartFeeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EstimateSmartFeeRequest copyWith(void Function(EstimateSmartFeeRequest) updates) => super.copyWith((message) => updates(message as EstimateSmartFeeRequest)) as EstimateSmartFeeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EstimateSmartFeeRequest create() => EstimateSmartFeeRequest._();
  EstimateSmartFeeRequest createEmptyInstance() => create();
  static $pb.PbList<EstimateSmartFeeRequest> createRepeated() => $pb.PbList<EstimateSmartFeeRequest>();
  @$core.pragma('dart2js:noInline')
  static EstimateSmartFeeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EstimateSmartFeeRequest>(create);
  static EstimateSmartFeeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get confTarget => $_getI64(0);
  @$pb.TagNumber(1)
  set confTarget($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConfTarget() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfTarget() => clearField(1);

  @$pb.TagNumber(2)
  EstimateSmartFeeRequest_EstimateMode get estimateMode => $_getN(1);
  @$pb.TagNumber(2)
  set estimateMode(EstimateSmartFeeRequest_EstimateMode v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasEstimateMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearEstimateMode() => clearField(2);
}

class EstimateSmartFeeResponse extends $pb.GeneratedMessage {
  factory EstimateSmartFeeResponse({
    $core.double? feeRate,
    $core.Iterable<$core.String>? errors,
    $fixnum.Int64? blocks,
  }) {
    final $result = create();
    if (feeRate != null) {
      $result.feeRate = feeRate;
    }
    if (errors != null) {
      $result.errors.addAll(errors);
    }
    if (blocks != null) {
      $result.blocks = blocks;
    }
    return $result;
  }
  EstimateSmartFeeResponse._() : super();
  factory EstimateSmartFeeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EstimateSmartFeeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EstimateSmartFeeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'feeRate', $pb.PbFieldType.OD)
    ..pPS(2, _omitFieldNames ? '' : 'errors')
    ..aInt64(3, _omitFieldNames ? '' : 'blocks')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EstimateSmartFeeResponse clone() => EstimateSmartFeeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EstimateSmartFeeResponse copyWith(void Function(EstimateSmartFeeResponse) updates) => super.copyWith((message) => updates(message as EstimateSmartFeeResponse)) as EstimateSmartFeeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EstimateSmartFeeResponse create() => EstimateSmartFeeResponse._();
  EstimateSmartFeeResponse createEmptyInstance() => create();
  static $pb.PbList<EstimateSmartFeeResponse> createRepeated() => $pb.PbList<EstimateSmartFeeResponse>();
  @$core.pragma('dart2js:noInline')
  static EstimateSmartFeeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EstimateSmartFeeResponse>(create);
  static EstimateSmartFeeResponse? _defaultInstance;

  /// Estimate fee rate in BTC/kvB (only present if no errors were encountered)
  @$pb.TagNumber(1)
  $core.double get feeRate => $_getN(0);
  @$pb.TagNumber(1)
  set feeRate($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFeeRate() => $_has(0);
  @$pb.TagNumber(1)
  void clearFeeRate() => clearField(1);

  /// Errors encountered during processing (if there are any)
  @$pb.TagNumber(2)
  $core.List<$core.String> get errors => $_getList(1);

  /// Block number where estimate was found.
  @$pb.TagNumber(3)
  $fixnum.Int64 get blocks => $_getI64(2);
  @$pb.TagNumber(3)
  set blocks($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBlocks() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlocks() => clearField(3);
}

class DecodeRawTransactionRequest extends $pb.GeneratedMessage {
  factory DecodeRawTransactionRequest({
    RawTransaction? tx,
  }) {
    final $result = create();
    if (tx != null) {
      $result.tx = tx;
    }
    return $result;
  }
  DecodeRawTransactionRequest._() : super();
  factory DecodeRawTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodeRawTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodeRawTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOM<RawTransaction>(1, _omitFieldNames ? '' : 'tx', subBuilder: RawTransaction.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodeRawTransactionRequest clone() => DecodeRawTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodeRawTransactionRequest copyWith(void Function(DecodeRawTransactionRequest) updates) => super.copyWith((message) => updates(message as DecodeRawTransactionRequest)) as DecodeRawTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodeRawTransactionRequest create() => DecodeRawTransactionRequest._();
  DecodeRawTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<DecodeRawTransactionRequest> createRepeated() => $pb.PbList<DecodeRawTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static DecodeRawTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodeRawTransactionRequest>(create);
  static DecodeRawTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  RawTransaction get tx => $_getN(0);
  @$pb.TagNumber(1)
  set tx(RawTransaction v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTx() => $_has(0);
  @$pb.TagNumber(1)
  void clearTx() => clearField(1);
  @$pb.TagNumber(1)
  RawTransaction ensureTx() => $_ensure(0);
}

class RawTransaction extends $pb.GeneratedMessage {
  factory RawTransaction({
    $core.List<$core.int>? data,
    $core.String? hex,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    if (hex != null) {
      $result.hex = hex;
    }
    return $result;
  }
  RawTransaction._() : super();
  factory RawTransaction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RawTransaction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RawTransaction', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'hex')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RawTransaction clone() => RawTransaction()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RawTransaction copyWith(void Function(RawTransaction) updates) => super.copyWith((message) => updates(message as RawTransaction)) as RawTransaction;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RawTransaction create() => RawTransaction._();
  RawTransaction createEmptyInstance() => create();
  static $pb.PbList<RawTransaction> createRepeated() => $pb.PbList<RawTransaction>();
  @$core.pragma('dart2js:noInline')
  static RawTransaction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RawTransaction>(create);
  static RawTransaction? _defaultInstance;

  /// Raw transaction data
  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);

  /// Hex-encoded raw transaction data
  @$pb.TagNumber(2)
  $core.String get hex => $_getSZ(1);
  @$pb.TagNumber(2)
  set hex($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearHex() => clearField(2);
}

class DecodeRawTransactionResponse extends $pb.GeneratedMessage {
  factory DecodeRawTransactionResponse({
    $core.String? txid,
    $core.String? hash,
    $core.int? size,
    $core.int? virtualSize,
    $core.int? weight,
    $core.int? version,
    $core.int? locktime,
    $core.Iterable<Input>? inputs,
    $core.Iterable<Output>? outputs,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    if (size != null) {
      $result.size = size;
    }
    if (virtualSize != null) {
      $result.virtualSize = virtualSize;
    }
    if (weight != null) {
      $result.weight = weight;
    }
    if (version != null) {
      $result.version = version;
    }
    if (locktime != null) {
      $result.locktime = locktime;
    }
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    return $result;
  }
  DecodeRawTransactionResponse._() : super();
  factory DecodeRawTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodeRawTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodeRawTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'size', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'virtualSize', $pb.PbFieldType.OU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'weight', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'version', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'locktime', $pb.PbFieldType.OU3)
    ..pc<Input>(8, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: Input.create)
    ..pc<Output>(9, _omitFieldNames ? '' : 'outputs', $pb.PbFieldType.PM, subBuilder: Output.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodeRawTransactionResponse clone() => DecodeRawTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodeRawTransactionResponse copyWith(void Function(DecodeRawTransactionResponse) updates) => super.copyWith((message) => updates(message as DecodeRawTransactionResponse)) as DecodeRawTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodeRawTransactionResponse create() => DecodeRawTransactionResponse._();
  DecodeRawTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<DecodeRawTransactionResponse> createRepeated() => $pb.PbList<DecodeRawTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static DecodeRawTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodeRawTransactionResponse>(create);
  static DecodeRawTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => clearField(2);

  /// The serialized transaction size
  @$pb.TagNumber(3)
  $core.int get size => $_getIZ(2);
  @$pb.TagNumber(3)
  set size($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearSize() => clearField(3);

  /// The virtual transaction size (differs from
  /// 'size' for witness transactions).
  @$pb.TagNumber(4)
  $core.int get virtualSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set virtualSize($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVirtualSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearVirtualSize() => clearField(4);

  /// The transaction's weight
  @$pb.TagNumber(5)
  $core.int get weight => $_getIZ(4);
  @$pb.TagNumber(5)
  set weight($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasWeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearWeight() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get version => $_getIZ(5);
  @$pb.TagNumber(6)
  set version($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersion() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get locktime => $_getIZ(6);
  @$pb.TagNumber(7)
  set locktime($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasLocktime() => $_has(6);
  @$pb.TagNumber(7)
  void clearLocktime() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<Input> get inputs => $_getList(7);

  @$pb.TagNumber(9)
  $core.List<Output> get outputs => $_getList(8);
}

class ImportDescriptorsRequest_Request extends $pb.GeneratedMessage {
  factory ImportDescriptorsRequest_Request({
    $core.String? descriptor,
    $core.bool? active,
    $core.int? rangeStart,
    $core.int? rangeEnd,
    $0.Timestamp? timestamp,
    $core.bool? internal,
    $core.String? label,
  }) {
    final $result = create();
    if (descriptor != null) {
      $result.descriptor = descriptor;
    }
    if (active != null) {
      $result.active = active;
    }
    if (rangeStart != null) {
      $result.rangeStart = rangeStart;
    }
    if (rangeEnd != null) {
      $result.rangeEnd = rangeEnd;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (internal != null) {
      $result.internal = internal;
    }
    if (label != null) {
      $result.label = label;
    }
    return $result;
  }
  ImportDescriptorsRequest_Request._() : super();
  factory ImportDescriptorsRequest_Request.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportDescriptorsRequest_Request.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportDescriptorsRequest.Request', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'descriptor')
    ..aOB(2, _omitFieldNames ? '' : 'active')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'rangeStart', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'rangeEnd', $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'timestamp', subBuilder: $0.Timestamp.create)
    ..aOB(6, _omitFieldNames ? '' : 'internal')
    ..aOS(7, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportDescriptorsRequest_Request clone() => ImportDescriptorsRequest_Request()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportDescriptorsRequest_Request copyWith(void Function(ImportDescriptorsRequest_Request) updates) => super.copyWith((message) => updates(message as ImportDescriptorsRequest_Request)) as ImportDescriptorsRequest_Request;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportDescriptorsRequest_Request create() => ImportDescriptorsRequest_Request._();
  ImportDescriptorsRequest_Request createEmptyInstance() => create();
  static $pb.PbList<ImportDescriptorsRequest_Request> createRepeated() => $pb.PbList<ImportDescriptorsRequest_Request>();
  @$core.pragma('dart2js:noInline')
  static ImportDescriptorsRequest_Request getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportDescriptorsRequest_Request>(create);
  static ImportDescriptorsRequest_Request? _defaultInstance;

  /// Descriptor to import
  @$pb.TagNumber(1)
  $core.String get descriptor => $_getSZ(0);
  @$pb.TagNumber(1)
  set descriptor($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDescriptor() => $_has(0);
  @$pb.TagNumber(1)
  void clearDescriptor() => clearField(1);

  /// Set this descriptor to be the active descriptor for the corresponding type/externality.
  @$pb.TagNumber(2)
  $core.bool get active => $_getBF(1);
  @$pb.TagNumber(2)
  set active($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasActive() => $_has(1);
  @$pb.TagNumber(2)
  void clearActive() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get rangeStart => $_getIZ(2);
  @$pb.TagNumber(3)
  set rangeStart($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRangeStart() => $_has(2);
  @$pb.TagNumber(3)
  void clearRangeStart() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get rangeEnd => $_getIZ(3);
  @$pb.TagNumber(4)
  set rangeEnd($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRangeEnd() => $_has(3);
  @$pb.TagNumber(4)
  void clearRangeEnd() => clearField(4);

  /// Nil passes 'now' to Bitcoin Core, which bypasses scanning.
  @$pb.TagNumber(5)
  $0.Timestamp get timestamp => $_getN(4);
  @$pb.TagNumber(5)
  set timestamp($0.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureTimestamp() => $_ensure(4);

  /// Whether matching outputs should be treated as not incoming payments (e.g. change)
  @$pb.TagNumber(6)
  $core.bool get internal => $_getBF(5);
  @$pb.TagNumber(6)
  set internal($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasInternal() => $_has(5);
  @$pb.TagNumber(6)
  void clearInternal() => clearField(6);

  /// Label to assign to the address, only allowed with internal = false. Disabled for ranged descriptors.
  @$pb.TagNumber(7)
  $core.String get label => $_getSZ(6);
  @$pb.TagNumber(7)
  set label($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasLabel() => $_has(6);
  @$pb.TagNumber(7)
  void clearLabel() => clearField(7);
}

class ImportDescriptorsRequest extends $pb.GeneratedMessage {
  factory ImportDescriptorsRequest({
    $core.String? wallet,
    $core.Iterable<ImportDescriptorsRequest_Request>? requests,
  }) {
    final $result = create();
    if (wallet != null) {
      $result.wallet = wallet;
    }
    if (requests != null) {
      $result.requests.addAll(requests);
    }
    return $result;
  }
  ImportDescriptorsRequest._() : super();
  factory ImportDescriptorsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportDescriptorsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportDescriptorsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..pc<ImportDescriptorsRequest_Request>(2, _omitFieldNames ? '' : 'requests', $pb.PbFieldType.PM, subBuilder: ImportDescriptorsRequest_Request.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportDescriptorsRequest clone() => ImportDescriptorsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportDescriptorsRequest copyWith(void Function(ImportDescriptorsRequest) updates) => super.copyWith((message) => updates(message as ImportDescriptorsRequest)) as ImportDescriptorsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportDescriptorsRequest create() => ImportDescriptorsRequest._();
  ImportDescriptorsRequest createEmptyInstance() => create();
  static $pb.PbList<ImportDescriptorsRequest> createRepeated() => $pb.PbList<ImportDescriptorsRequest>();
  @$core.pragma('dart2js:noInline')
  static ImportDescriptorsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportDescriptorsRequest>(create);
  static ImportDescriptorsRequest? _defaultInstance;

  /// Only needs to be set if dealing with multiple wallets at the same time.
  /// TODO: better suited as a header?
  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<ImportDescriptorsRequest_Request> get requests => $_getList(1);
}

class ImportDescriptorsResponse_Error extends $pb.GeneratedMessage {
  factory ImportDescriptorsResponse_Error({
    $core.int? code,
    $core.String? message,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  ImportDescriptorsResponse_Error._() : super();
  factory ImportDescriptorsResponse_Error.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportDescriptorsResponse_Error.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportDescriptorsResponse.Error', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportDescriptorsResponse_Error clone() => ImportDescriptorsResponse_Error()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportDescriptorsResponse_Error copyWith(void Function(ImportDescriptorsResponse_Error) updates) => super.copyWith((message) => updates(message as ImportDescriptorsResponse_Error)) as ImportDescriptorsResponse_Error;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportDescriptorsResponse_Error create() => ImportDescriptorsResponse_Error._();
  ImportDescriptorsResponse_Error createEmptyInstance() => create();
  static $pb.PbList<ImportDescriptorsResponse_Error> createRepeated() => $pb.PbList<ImportDescriptorsResponse_Error>();
  @$core.pragma('dart2js:noInline')
  static ImportDescriptorsResponse_Error getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportDescriptorsResponse_Error>(create);
  static ImportDescriptorsResponse_Error? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
}

class ImportDescriptorsResponse_Response extends $pb.GeneratedMessage {
  factory ImportDescriptorsResponse_Response({
    $core.bool? success,
    $core.Iterable<$core.String>? warnings,
    ImportDescriptorsResponse_Error? error,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (warnings != null) {
      $result.warnings.addAll(warnings);
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  ImportDescriptorsResponse_Response._() : super();
  factory ImportDescriptorsResponse_Response.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportDescriptorsResponse_Response.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportDescriptorsResponse.Response', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..pPS(2, _omitFieldNames ? '' : 'warnings')
    ..aOM<ImportDescriptorsResponse_Error>(3, _omitFieldNames ? '' : 'error', subBuilder: ImportDescriptorsResponse_Error.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportDescriptorsResponse_Response clone() => ImportDescriptorsResponse_Response()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportDescriptorsResponse_Response copyWith(void Function(ImportDescriptorsResponse_Response) updates) => super.copyWith((message) => updates(message as ImportDescriptorsResponse_Response)) as ImportDescriptorsResponse_Response;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportDescriptorsResponse_Response create() => ImportDescriptorsResponse_Response._();
  ImportDescriptorsResponse_Response createEmptyInstance() => create();
  static $pb.PbList<ImportDescriptorsResponse_Response> createRepeated() => $pb.PbList<ImportDescriptorsResponse_Response>();
  @$core.pragma('dart2js:noInline')
  static ImportDescriptorsResponse_Response getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportDescriptorsResponse_Response>(create);
  static ImportDescriptorsResponse_Response? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get warnings => $_getList(1);

  @$pb.TagNumber(3)
  ImportDescriptorsResponse_Error get error => $_getN(2);
  @$pb.TagNumber(3)
  set error(ImportDescriptorsResponse_Error v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => clearField(3);
  @$pb.TagNumber(3)
  ImportDescriptorsResponse_Error ensureError() => $_ensure(2);
}

class ImportDescriptorsResponse extends $pb.GeneratedMessage {
  factory ImportDescriptorsResponse({
    $core.Iterable<ImportDescriptorsResponse_Response>? responses,
  }) {
    final $result = create();
    if (responses != null) {
      $result.responses.addAll(responses);
    }
    return $result;
  }
  ImportDescriptorsResponse._() : super();
  factory ImportDescriptorsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportDescriptorsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportDescriptorsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pc<ImportDescriptorsResponse_Response>(1, _omitFieldNames ? '' : 'responses', $pb.PbFieldType.PM, subBuilder: ImportDescriptorsResponse_Response.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportDescriptorsResponse clone() => ImportDescriptorsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportDescriptorsResponse copyWith(void Function(ImportDescriptorsResponse) updates) => super.copyWith((message) => updates(message as ImportDescriptorsResponse)) as ImportDescriptorsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportDescriptorsResponse create() => ImportDescriptorsResponse._();
  ImportDescriptorsResponse createEmptyInstance() => create();
  static $pb.PbList<ImportDescriptorsResponse> createRepeated() => $pb.PbList<ImportDescriptorsResponse>();
  @$core.pragma('dart2js:noInline')
  static ImportDescriptorsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportDescriptorsResponse>(create);
  static ImportDescriptorsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ImportDescriptorsResponse_Response> get responses => $_getList(0);
}

class GetDescriptorInfoRequest extends $pb.GeneratedMessage {
  factory GetDescriptorInfoRequest({
    $core.String? descriptor,
  }) {
    final $result = create();
    if (descriptor != null) {
      $result.descriptor = descriptor;
    }
    return $result;
  }
  GetDescriptorInfoRequest._() : super();
  factory GetDescriptorInfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetDescriptorInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDescriptorInfoRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'descriptor')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetDescriptorInfoRequest clone() => GetDescriptorInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetDescriptorInfoRequest copyWith(void Function(GetDescriptorInfoRequest) updates) => super.copyWith((message) => updates(message as GetDescriptorInfoRequest)) as GetDescriptorInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDescriptorInfoRequest create() => GetDescriptorInfoRequest._();
  GetDescriptorInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetDescriptorInfoRequest> createRepeated() => $pb.PbList<GetDescriptorInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetDescriptorInfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetDescriptorInfoRequest>(create);
  static GetDescriptorInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get descriptor => $_getSZ(0);
  @$pb.TagNumber(1)
  set descriptor($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDescriptor() => $_has(0);
  @$pb.TagNumber(1)
  void clearDescriptor() => clearField(1);
}

class GetDescriptorInfoResponse extends $pb.GeneratedMessage {
  factory GetDescriptorInfoResponse({
    $core.String? descriptor,
    $core.String? checksum,
    $core.bool? isRange,
    $core.bool? isSolvable,
    $core.bool? hasPrivateKeys,
  }) {
    final $result = create();
    if (descriptor != null) {
      $result.descriptor = descriptor;
    }
    if (checksum != null) {
      $result.checksum = checksum;
    }
    if (isRange != null) {
      $result.isRange = isRange;
    }
    if (isSolvable != null) {
      $result.isSolvable = isSolvable;
    }
    if (hasPrivateKeys != null) {
      $result.hasPrivateKeys = hasPrivateKeys;
    }
    return $result;
  }
  GetDescriptorInfoResponse._() : super();
  factory GetDescriptorInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetDescriptorInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDescriptorInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'descriptor')
    ..aOS(2, _omitFieldNames ? '' : 'checksum')
    ..aOB(3, _omitFieldNames ? '' : 'isRange')
    ..aOB(4, _omitFieldNames ? '' : 'isSolvable')
    ..aOB(5, _omitFieldNames ? '' : 'hasPrivateKeys')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetDescriptorInfoResponse clone() => GetDescriptorInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetDescriptorInfoResponse copyWith(void Function(GetDescriptorInfoResponse) updates) => super.copyWith((message) => updates(message as GetDescriptorInfoResponse)) as GetDescriptorInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDescriptorInfoResponse create() => GetDescriptorInfoResponse._();
  GetDescriptorInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetDescriptorInfoResponse> createRepeated() => $pb.PbList<GetDescriptorInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetDescriptorInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetDescriptorInfoResponse>(create);
  static GetDescriptorInfoResponse? _defaultInstance;

  /// The descriptor in canonical form, without private keys.
  @$pb.TagNumber(1)
  $core.String get descriptor => $_getSZ(0);
  @$pb.TagNumber(1)
  set descriptor($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDescriptor() => $_has(0);
  @$pb.TagNumber(1)
  void clearDescriptor() => clearField(1);

  /// The checksum for the input descriptor
  @$pb.TagNumber(2)
  $core.String get checksum => $_getSZ(1);
  @$pb.TagNumber(2)
  set checksum($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasChecksum() => $_has(1);
  @$pb.TagNumber(2)
  void clearChecksum() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isRange => $_getBF(2);
  @$pb.TagNumber(3)
  set isRange($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsRange() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsRange() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isSolvable => $_getBF(3);
  @$pb.TagNumber(4)
  set isSolvable($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsSolvable() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsSolvable() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get hasPrivateKeys => $_getBF(4);
  @$pb.TagNumber(5)
  set hasPrivateKeys($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHasPrivateKeys() => $_has(4);
  @$pb.TagNumber(5)
  void clearHasPrivateKeys() => clearField(5);
}

class GetBlockRequest extends $pb.GeneratedMessage {
  factory GetBlockRequest({
    $core.String? hash,
    GetBlockRequest_Verbosity? verbosity,
    $core.int? height,
  }) {
    final $result = create();
    if (hash != null) {
      $result.hash = hash;
    }
    if (verbosity != null) {
      $result.verbosity = verbosity;
    }
    if (height != null) {
      $result.height = height;
    }
    return $result;
  }
  GetBlockRequest._() : super();
  factory GetBlockRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..e<GetBlockRequest_Verbosity>(2, _omitFieldNames ? '' : 'verbosity', $pb.PbFieldType.OE, defaultOrMaker: GetBlockRequest_Verbosity.VERBOSITY_UNSPECIFIED, valueOf: GetBlockRequest_Verbosity.valueOf, enumValues: GetBlockRequest_Verbosity.values)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'height', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockRequest clone() => GetBlockRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockRequest copyWith(void Function(GetBlockRequest) updates) => super.copyWith((message) => updates(message as GetBlockRequest)) as GetBlockRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockRequest create() => GetBlockRequest._();
  GetBlockRequest createEmptyInstance() => create();
  static $pb.PbList<GetBlockRequest> createRepeated() => $pb.PbList<GetBlockRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBlockRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockRequest>(create);
  static GetBlockRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => clearField(1);

  @$pb.TagNumber(2)
  GetBlockRequest_Verbosity get verbosity => $_getN(1);
  @$pb.TagNumber(2)
  set verbosity(GetBlockRequest_Verbosity v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasVerbosity() => $_has(1);
  @$pb.TagNumber(2)
  void clearVerbosity() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get height => $_getIZ(2);
  @$pb.TagNumber(3)
  set height($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeight() => clearField(3);
}

class GetBlockResponse extends $pb.GeneratedMessage {
  factory GetBlockResponse({
    $core.String? hex,
    $core.String? hash,
    $core.int? confirmations,
    $core.int? height,
    $core.int? version,
    $core.String? versionHex,
    $core.String? merkleRoot,
    $0.Timestamp? time,
    $core.int? nonce,
    $core.String? bits,
    $core.double? difficulty,
    $core.String? previousBlockHash,
    $core.String? nextBlockHash,
    $core.int? strippedSize,
    $core.int? size,
    $core.int? weight,
    $core.Iterable<$core.String>? txids,
  }) {
    final $result = create();
    if (hex != null) {
      $result.hex = hex;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (height != null) {
      $result.height = height;
    }
    if (version != null) {
      $result.version = version;
    }
    if (versionHex != null) {
      $result.versionHex = versionHex;
    }
    if (merkleRoot != null) {
      $result.merkleRoot = merkleRoot;
    }
    if (time != null) {
      $result.time = time;
    }
    if (nonce != null) {
      $result.nonce = nonce;
    }
    if (bits != null) {
      $result.bits = bits;
    }
    if (difficulty != null) {
      $result.difficulty = difficulty;
    }
    if (previousBlockHash != null) {
      $result.previousBlockHash = previousBlockHash;
    }
    if (nextBlockHash != null) {
      $result.nextBlockHash = nextBlockHash;
    }
    if (strippedSize != null) {
      $result.strippedSize = strippedSize;
    }
    if (size != null) {
      $result.size = size;
    }
    if (weight != null) {
      $result.weight = weight;
    }
    if (txids != null) {
      $result.txids.addAll(txids);
    }
    return $result;
  }
  GetBlockResponse._() : super();
  factory GetBlockResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hex')
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'version', $pb.PbFieldType.O3)
    ..aOS(6, _omitFieldNames ? '' : 'versionHex')
    ..aOS(7, _omitFieldNames ? '' : 'merkleRoot')
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'time', subBuilder: $0.Timestamp.create)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'nonce', $pb.PbFieldType.OU3)
    ..aOS(10, _omitFieldNames ? '' : 'bits')
    ..a<$core.double>(11, _omitFieldNames ? '' : 'difficulty', $pb.PbFieldType.OD)
    ..aOS(12, _omitFieldNames ? '' : 'previousBlockHash')
    ..aOS(13, _omitFieldNames ? '' : 'nextBlockHash')
    ..a<$core.int>(14, _omitFieldNames ? '' : 'strippedSize', $pb.PbFieldType.O3)
    ..a<$core.int>(15, _omitFieldNames ? '' : 'size', $pb.PbFieldType.O3)
    ..a<$core.int>(16, _omitFieldNames ? '' : 'weight', $pb.PbFieldType.O3)
    ..pPS(17, _omitFieldNames ? '' : 'txids')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockResponse clone() => GetBlockResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockResponse copyWith(void Function(GetBlockResponse) updates) => super.copyWith((message) => updates(message as GetBlockResponse)) as GetBlockResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockResponse create() => GetBlockResponse._();
  GetBlockResponse createEmptyInstance() => create();
  static $pb.PbList<GetBlockResponse> createRepeated() => $pb.PbList<GetBlockResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBlockResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockResponse>(create);
  static GetBlockResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hex => $_getSZ(0);
  @$pb.TagNumber(1)
  set hex($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearHex() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get confirmations => $_getIZ(2);
  @$pb.TagNumber(3)
  set confirmations($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasConfirmations() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfirmations() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get height => $_getIZ(3);
  @$pb.TagNumber(4)
  set height($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeight() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get version => $_getIZ(4);
  @$pb.TagNumber(5)
  set version($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get versionHex => $_getSZ(5);
  @$pb.TagNumber(6)
  set versionHex($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasVersionHex() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersionHex() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get merkleRoot => $_getSZ(6);
  @$pb.TagNumber(7)
  set merkleRoot($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMerkleRoot() => $_has(6);
  @$pb.TagNumber(7)
  void clearMerkleRoot() => clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get time => $_getN(7);
  @$pb.TagNumber(8)
  set time($0.Timestamp v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearTime() => clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureTime() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.int get nonce => $_getIZ(8);
  @$pb.TagNumber(9)
  set nonce($core.int v) { $_setUnsignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasNonce() => $_has(8);
  @$pb.TagNumber(9)
  void clearNonce() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get bits => $_getSZ(9);
  @$pb.TagNumber(10)
  set bits($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasBits() => $_has(9);
  @$pb.TagNumber(10)
  void clearBits() => clearField(10);

  @$pb.TagNumber(11)
  $core.double get difficulty => $_getN(10);
  @$pb.TagNumber(11)
  set difficulty($core.double v) { $_setDouble(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasDifficulty() => $_has(10);
  @$pb.TagNumber(11)
  void clearDifficulty() => clearField(11);

  /// Expected number of hashes required to produce the chain up to this block (in hex)
  /// string chainwork = 12; // not in rpcclient
  @$pb.TagNumber(12)
  $core.String get previousBlockHash => $_getSZ(11);
  @$pb.TagNumber(12)
  set previousBlockHash($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasPreviousBlockHash() => $_has(11);
  @$pb.TagNumber(12)
  void clearPreviousBlockHash() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get nextBlockHash => $_getSZ(12);
  @$pb.TagNumber(13)
  set nextBlockHash($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasNextBlockHash() => $_has(12);
  @$pb.TagNumber(13)
  void clearNextBlockHash() => clearField(13);

  @$pb.TagNumber(14)
  $core.int get strippedSize => $_getIZ(13);
  @$pb.TagNumber(14)
  set strippedSize($core.int v) { $_setSignedInt32(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasStrippedSize() => $_has(13);
  @$pb.TagNumber(14)
  void clearStrippedSize() => clearField(14);

  @$pb.TagNumber(15)
  $core.int get size => $_getIZ(14);
  @$pb.TagNumber(15)
  set size($core.int v) { $_setSignedInt32(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasSize() => $_has(14);
  @$pb.TagNumber(15)
  void clearSize() => clearField(15);

  @$pb.TagNumber(16)
  $core.int get weight => $_getIZ(15);
  @$pb.TagNumber(16)
  set weight($core.int v) { $_setSignedInt32(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasWeight() => $_has(15);
  @$pb.TagNumber(16)
  void clearWeight() => clearField(16);

  /// List of transactions in the block, by TXID.
  @$pb.TagNumber(17)
  $core.List<$core.String> get txids => $_getList(16);
}

class BumpFeeRequest extends $pb.GeneratedMessage {
  factory BumpFeeRequest({
    $core.String? wallet,
    $core.String? txid,
  }) {
    final $result = create();
    if (wallet != null) {
      $result.wallet = wallet;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  BumpFeeRequest._() : super();
  factory BumpFeeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BumpFeeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BumpFeeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BumpFeeRequest clone() => BumpFeeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BumpFeeRequest copyWith(void Function(BumpFeeRequest) updates) => super.copyWith((message) => updates(message as BumpFeeRequest)) as BumpFeeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BumpFeeRequest create() => BumpFeeRequest._();
  BumpFeeRequest createEmptyInstance() => create();
  static $pb.PbList<BumpFeeRequest> createRepeated() => $pb.PbList<BumpFeeRequest>();
  @$core.pragma('dart2js:noInline')
  static BumpFeeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BumpFeeRequest>(create);
  static BumpFeeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => clearField(1);

  /// The TXID to be bumped
  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => clearField(2);
}

class BumpFeeResponse extends $pb.GeneratedMessage {
  factory BumpFeeResponse({
    $core.String? txid,
    $core.double? originalFee,
    $core.double? newFee,
    $core.Iterable<$core.String>? errors,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (originalFee != null) {
      $result.originalFee = originalFee;
    }
    if (newFee != null) {
      $result.newFee = newFee;
    }
    if (errors != null) {
      $result.errors.addAll(errors);
    }
    return $result;
  }
  BumpFeeResponse._() : super();
  factory BumpFeeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BumpFeeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BumpFeeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'originalFee', $pb.PbFieldType.OD)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'newFee', $pb.PbFieldType.OD)
    ..pPS(4, _omitFieldNames ? '' : 'errors')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BumpFeeResponse clone() => BumpFeeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BumpFeeResponse copyWith(void Function(BumpFeeResponse) updates) => super.copyWith((message) => updates(message as BumpFeeResponse)) as BumpFeeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BumpFeeResponse create() => BumpFeeResponse._();
  BumpFeeResponse createEmptyInstance() => create();
  static $pb.PbList<BumpFeeResponse> createRepeated() => $pb.PbList<BumpFeeResponse>();
  @$core.pragma('dart2js:noInline')
  static BumpFeeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BumpFeeResponse>(create);
  static BumpFeeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get originalFee => $_getN(1);
  @$pb.TagNumber(2)
  set originalFee($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOriginalFee() => $_has(1);
  @$pb.TagNumber(2)
  void clearOriginalFee() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get newFee => $_getN(2);
  @$pb.TagNumber(3)
  set newFee($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNewFee() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewFee() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.String> get errors => $_getList(3);
}

class ListSinceBlockRequest extends $pb.GeneratedMessage {
  factory ListSinceBlockRequest({
    $core.String? wallet,
    $core.String? hash,
  }) {
    final $result = create();
    if (wallet != null) {
      $result.wallet = wallet;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    return $result;
  }
  ListSinceBlockRequest._() : super();
  factory ListSinceBlockRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSinceBlockRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSinceBlockRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSinceBlockRequest clone() => ListSinceBlockRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSinceBlockRequest copyWith(void Function(ListSinceBlockRequest) updates) => super.copyWith((message) => updates(message as ListSinceBlockRequest)) as ListSinceBlockRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSinceBlockRequest create() => ListSinceBlockRequest._();
  ListSinceBlockRequest createEmptyInstance() => create();
  static $pb.PbList<ListSinceBlockRequest> createRepeated() => $pb.PbList<ListSinceBlockRequest>();
  @$core.pragma('dart2js:noInline')
  static ListSinceBlockRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSinceBlockRequest>(create);
  static ListSinceBlockRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => clearField(1);

  /// If set, the block hash to list transactions since, otherwise list all transactions.
  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => clearField(2);
}

class ListSinceBlockResponse extends $pb.GeneratedMessage {
  factory ListSinceBlockResponse({
    $core.Iterable<GetTransactionResponse>? transactions,
  }) {
    final $result = create();
    if (transactions != null) {
      $result.transactions.addAll(transactions);
    }
    return $result;
  }
  ListSinceBlockResponse._() : super();
  factory ListSinceBlockResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSinceBlockResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSinceBlockResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pc<GetTransactionResponse>(1, _omitFieldNames ? '' : 'transactions', $pb.PbFieldType.PM, subBuilder: GetTransactionResponse.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSinceBlockResponse clone() => ListSinceBlockResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSinceBlockResponse copyWith(void Function(ListSinceBlockResponse) updates) => super.copyWith((message) => updates(message as ListSinceBlockResponse)) as ListSinceBlockResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSinceBlockResponse create() => ListSinceBlockResponse._();
  ListSinceBlockResponse createEmptyInstance() => create();
  static $pb.PbList<ListSinceBlockResponse> createRepeated() => $pb.PbList<ListSinceBlockResponse>();
  @$core.pragma('dart2js:noInline')
  static ListSinceBlockResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSinceBlockResponse>(create);
  static ListSinceBlockResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GetTransactionResponse> get transactions => $_getList(0);
}

class GetRawMempoolRequest extends $pb.GeneratedMessage {
  factory GetRawMempoolRequest({
    $core.bool? verbose,
  }) {
    final $result = create();
    if (verbose != null) {
      $result.verbose = verbose;
    }
    return $result;
  }
  GetRawMempoolRequest._() : super();
  factory GetRawMempoolRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetRawMempoolRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRawMempoolRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'verbose')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetRawMempoolRequest clone() => GetRawMempoolRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetRawMempoolRequest copyWith(void Function(GetRawMempoolRequest) updates) => super.copyWith((message) => updates(message as GetRawMempoolRequest)) as GetRawMempoolRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRawMempoolRequest create() => GetRawMempoolRequest._();
  GetRawMempoolRequest createEmptyInstance() => create();
  static $pb.PbList<GetRawMempoolRequest> createRepeated() => $pb.PbList<GetRawMempoolRequest>();
  @$core.pragma('dart2js:noInline')
  static GetRawMempoolRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetRawMempoolRequest>(create);
  static GetRawMempoolRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get verbose => $_getBF(0);
  @$pb.TagNumber(1)
  set verbose($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVerbose() => $_has(0);
  @$pb.TagNumber(1)
  void clearVerbose() => clearField(1);
}

/// All values are in whole bitcoins
class MempoolEntry_Fees extends $pb.GeneratedMessage {
  factory MempoolEntry_Fees({
    $core.double? base,
    $core.double? modified,
    $core.double? ancestor,
    $core.double? descendant,
  }) {
    final $result = create();
    if (base != null) {
      $result.base = base;
    }
    if (modified != null) {
      $result.modified = modified;
    }
    if (ancestor != null) {
      $result.ancestor = ancestor;
    }
    if (descendant != null) {
      $result.descendant = descendant;
    }
    return $result;
  }
  MempoolEntry_Fees._() : super();
  factory MempoolEntry_Fees.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MempoolEntry_Fees.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MempoolEntry.Fees', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'base', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'modified', $pb.PbFieldType.OD)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'ancestor', $pb.PbFieldType.OD)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'descendant', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MempoolEntry_Fees clone() => MempoolEntry_Fees()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MempoolEntry_Fees copyWith(void Function(MempoolEntry_Fees) updates) => super.copyWith((message) => updates(message as MempoolEntry_Fees)) as MempoolEntry_Fees;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MempoolEntry_Fees create() => MempoolEntry_Fees._();
  MempoolEntry_Fees createEmptyInstance() => create();
  static $pb.PbList<MempoolEntry_Fees> createRepeated() => $pb.PbList<MempoolEntry_Fees>();
  @$core.pragma('dart2js:noInline')
  static MempoolEntry_Fees getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MempoolEntry_Fees>(create);
  static MempoolEntry_Fees? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get base => $_getN(0);
  @$pb.TagNumber(1)
  set base($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBase() => $_has(0);
  @$pb.TagNumber(1)
  void clearBase() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get modified => $_getN(1);
  @$pb.TagNumber(2)
  set modified($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasModified() => $_has(1);
  @$pb.TagNumber(2)
  void clearModified() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get ancestor => $_getN(2);
  @$pb.TagNumber(3)
  set ancestor($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAncestor() => $_has(2);
  @$pb.TagNumber(3)
  void clearAncestor() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get descendant => $_getN(3);
  @$pb.TagNumber(4)
  set descendant($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDescendant() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescendant() => clearField(4);
}

class MempoolEntry extends $pb.GeneratedMessage {
  factory MempoolEntry({
    $core.int? virtualSize,
    $core.int? weight,
    $0.Timestamp? time,
    $core.int? descendantCount,
    $core.int? descendantSize,
    $core.int? ancestorCount,
    $core.int? ancestorSize,
    $core.String? witnessTxid,
    MempoolEntry_Fees? fees,
    $core.Iterable<$core.String>? depends,
    $core.Iterable<$core.String>? spentBy,
    $core.bool? bip125Replaceable,
    $core.bool? unbroadcast,
  }) {
    final $result = create();
    if (virtualSize != null) {
      $result.virtualSize = virtualSize;
    }
    if (weight != null) {
      $result.weight = weight;
    }
    if (time != null) {
      $result.time = time;
    }
    if (descendantCount != null) {
      $result.descendantCount = descendantCount;
    }
    if (descendantSize != null) {
      $result.descendantSize = descendantSize;
    }
    if (ancestorCount != null) {
      $result.ancestorCount = ancestorCount;
    }
    if (ancestorSize != null) {
      $result.ancestorSize = ancestorSize;
    }
    if (witnessTxid != null) {
      $result.witnessTxid = witnessTxid;
    }
    if (fees != null) {
      $result.fees = fees;
    }
    if (depends != null) {
      $result.depends.addAll(depends);
    }
    if (spentBy != null) {
      $result.spentBy.addAll(spentBy);
    }
    if (bip125Replaceable != null) {
      $result.bip125Replaceable = bip125Replaceable;
    }
    if (unbroadcast != null) {
      $result.unbroadcast = unbroadcast;
    }
    return $result;
  }
  MempoolEntry._() : super();
  factory MempoolEntry.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MempoolEntry.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MempoolEntry', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'virtualSize', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'weight', $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'time', subBuilder: $0.Timestamp.create)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'descendantCount', $pb.PbFieldType.OU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'descendantSize', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'ancestorCount', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'ancestorSize', $pb.PbFieldType.OU3)
    ..aOS(8, _omitFieldNames ? '' : 'witnessTxid')
    ..aOM<MempoolEntry_Fees>(9, _omitFieldNames ? '' : 'fees', subBuilder: MempoolEntry_Fees.create)
    ..pPS(10, _omitFieldNames ? '' : 'depends')
    ..pPS(11, _omitFieldNames ? '' : 'spentBy')
    ..aOB(12, _omitFieldNames ? '' : 'bip125Replaceable')
    ..aOB(13, _omitFieldNames ? '' : 'unbroadcast')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MempoolEntry clone() => MempoolEntry()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MempoolEntry copyWith(void Function(MempoolEntry) updates) => super.copyWith((message) => updates(message as MempoolEntry)) as MempoolEntry;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MempoolEntry create() => MempoolEntry._();
  MempoolEntry createEmptyInstance() => create();
  static $pb.PbList<MempoolEntry> createRepeated() => $pb.PbList<MempoolEntry>();
  @$core.pragma('dart2js:noInline')
  static MempoolEntry getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MempoolEntry>(create);
  static MempoolEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get virtualSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set virtualSize($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVirtualSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearVirtualSize() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get weight => $_getIZ(1);
  @$pb.TagNumber(2)
  set weight($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearWeight() => clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get time => $_getN(2);
  @$pb.TagNumber(3)
  set time($0.Timestamp v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearTime() => clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureTime() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.int get descendantCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set descendantCount($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDescendantCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescendantCount() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get descendantSize => $_getIZ(4);
  @$pb.TagNumber(5)
  set descendantSize($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDescendantSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescendantSize() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get ancestorCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set ancestorCount($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAncestorCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearAncestorCount() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get ancestorSize => $_getIZ(6);
  @$pb.TagNumber(7)
  set ancestorSize($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasAncestorSize() => $_has(6);
  @$pb.TagNumber(7)
  void clearAncestorSize() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get witnessTxid => $_getSZ(7);
  @$pb.TagNumber(8)
  set witnessTxid($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasWitnessTxid() => $_has(7);
  @$pb.TagNumber(8)
  void clearWitnessTxid() => clearField(8);

  @$pb.TagNumber(9)
  MempoolEntry_Fees get fees => $_getN(8);
  @$pb.TagNumber(9)
  set fees(MempoolEntry_Fees v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasFees() => $_has(8);
  @$pb.TagNumber(9)
  void clearFees() => clearField(9);
  @$pb.TagNumber(9)
  MempoolEntry_Fees ensureFees() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.List<$core.String> get depends => $_getList(9);

  @$pb.TagNumber(11)
  $core.List<$core.String> get spentBy => $_getList(10);

  @$pb.TagNumber(12)
  $core.bool get bip125Replaceable => $_getBF(11);
  @$pb.TagNumber(12)
  set bip125Replaceable($core.bool v) { $_setBool(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasBip125Replaceable() => $_has(11);
  @$pb.TagNumber(12)
  void clearBip125Replaceable() => clearField(12);

  /// A transaction is unbroadcast if initial broadcast not yet
  /// acknowledged by any peers.
  @$pb.TagNumber(13)
  $core.bool get unbroadcast => $_getBF(12);
  @$pb.TagNumber(13)
  set unbroadcast($core.bool v) { $_setBool(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasUnbroadcast() => $_has(12);
  @$pb.TagNumber(13)
  void clearUnbroadcast() => clearField(13);
}

class GetRawMempoolResponse extends $pb.GeneratedMessage {
  factory GetRawMempoolResponse({
    $core.Iterable<$core.String>? txids,
    $core.Map<$core.String, MempoolEntry>? transactions,
  }) {
    final $result = create();
    if (txids != null) {
      $result.txids.addAll(txids);
    }
    if (transactions != null) {
      $result.transactions.addAll(transactions);
    }
    return $result;
  }
  GetRawMempoolResponse._() : super();
  factory GetRawMempoolResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetRawMempoolResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRawMempoolResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'txids')
    ..m<$core.String, MempoolEntry>(2, _omitFieldNames ? '' : 'transactions', entryClassName: 'GetRawMempoolResponse.TransactionsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OM, valueCreator: MempoolEntry.create, valueDefaultOrMaker: MempoolEntry.getDefault, packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetRawMempoolResponse clone() => GetRawMempoolResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetRawMempoolResponse copyWith(void Function(GetRawMempoolResponse) updates) => super.copyWith((message) => updates(message as GetRawMempoolResponse)) as GetRawMempoolResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRawMempoolResponse create() => GetRawMempoolResponse._();
  GetRawMempoolResponse createEmptyInstance() => create();
  static $pb.PbList<GetRawMempoolResponse> createRepeated() => $pb.PbList<GetRawMempoolResponse>();
  @$core.pragma('dart2js:noInline')
  static GetRawMempoolResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetRawMempoolResponse>(create);
  static GetRawMempoolResponse? _defaultInstance;

  /// Only set if this is a non-verbose response
  @$pb.TagNumber(1)
  $core.List<$core.String> get txids => $_getList(0);

  /// Only set if this is a verbose response
  @$pb.TagNumber(2)
  $core.Map<$core.String, MempoolEntry> get transactions => $_getMap(1);
}

class GetBlockHashRequest extends $pb.GeneratedMessage {
  factory GetBlockHashRequest({
    $core.int? height,
  }) {
    final $result = create();
    if (height != null) {
      $result.height = height;
    }
    return $result;
  }
  GetBlockHashRequest._() : super();
  factory GetBlockHashRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockHashRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockHashRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockHashRequest clone() => GetBlockHashRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockHashRequest copyWith(void Function(GetBlockHashRequest) updates) => super.copyWith((message) => updates(message as GetBlockHashRequest)) as GetBlockHashRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockHashRequest create() => GetBlockHashRequest._();
  GetBlockHashRequest createEmptyInstance() => create();
  static $pb.PbList<GetBlockHashRequest> createRepeated() => $pb.PbList<GetBlockHashRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBlockHashRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockHashRequest>(create);
  static GetBlockHashRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get height => $_getIZ(0);
  @$pb.TagNumber(1)
  set height($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => clearField(1);
}

class GetBlockHashResponse extends $pb.GeneratedMessage {
  factory GetBlockHashResponse({
    $core.String? hash,
  }) {
    final $result = create();
    if (hash != null) {
      $result.hash = hash;
    }
    return $result;
  }
  GetBlockHashResponse._() : super();
  factory GetBlockHashResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockHashResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockHashResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockHashResponse clone() => GetBlockHashResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockHashResponse copyWith(void Function(GetBlockHashResponse) updates) => super.copyWith((message) => updates(message as GetBlockHashResponse)) as GetBlockHashResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockHashResponse create() => GetBlockHashResponse._();
  GetBlockHashResponse createEmptyInstance() => create();
  static $pb.PbList<GetBlockHashResponse> createRepeated() => $pb.PbList<GetBlockHashResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBlockHashResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockHashResponse>(create);
  static GetBlockHashResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => clearField(1);
}

class ListTransactionsRequest extends $pb.GeneratedMessage {
  factory ListTransactionsRequest({
    $core.String? wallet,
    $core.int? count,
    $core.int? skip,
  }) {
    final $result = create();
    if (wallet != null) {
      $result.wallet = wallet;
    }
    if (count != null) {
      $result.count = count;
    }
    if (skip != null) {
      $result.skip = skip;
    }
    return $result;
  }
  ListTransactionsRequest._() : super();
  factory ListTransactionsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListTransactionsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'count', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'skip', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListTransactionsRequest clone() => ListTransactionsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListTransactionsRequest copyWith(void Function(ListTransactionsRequest) updates) => super.copyWith((message) => updates(message as ListTransactionsRequest)) as ListTransactionsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTransactionsRequest create() => ListTransactionsRequest._();
  ListTransactionsRequest createEmptyInstance() => create();
  static $pb.PbList<ListTransactionsRequest> createRepeated() => $pb.PbList<ListTransactionsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListTransactionsRequest>(create);
  static ListTransactionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => clearField(1);

  /// Defaults to 10
  @$pb.TagNumber(2)
  $core.int get count => $_getIZ(1);
  @$pb.TagNumber(2)
  set count($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get skip => $_getIZ(2);
  @$pb.TagNumber(3)
  set skip($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSkip() => $_has(2);
  @$pb.TagNumber(3)
  void clearSkip() => clearField(3);
}

class ListTransactionsResponse extends $pb.GeneratedMessage {
  factory ListTransactionsResponse({
    $core.Iterable<GetTransactionResponse>? transactions,
  }) {
    final $result = create();
    if (transactions != null) {
      $result.transactions.addAll(transactions);
    }
    return $result;
  }
  ListTransactionsResponse._() : super();
  factory ListTransactionsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListTransactionsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pc<GetTransactionResponse>(1, _omitFieldNames ? '' : 'transactions', $pb.PbFieldType.PM, subBuilder: GetTransactionResponse.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListTransactionsResponse clone() => ListTransactionsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListTransactionsResponse copyWith(void Function(ListTransactionsResponse) updates) => super.copyWith((message) => updates(message as ListTransactionsResponse)) as ListTransactionsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTransactionsResponse create() => ListTransactionsResponse._();
  ListTransactionsResponse createEmptyInstance() => create();
  static $pb.PbList<ListTransactionsResponse> createRepeated() => $pb.PbList<ListTransactionsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListTransactionsResponse>(create);
  static ListTransactionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GetTransactionResponse> get transactions => $_getList(0);
}

class ListWalletsResponse extends $pb.GeneratedMessage {
  factory ListWalletsResponse({
    $core.Iterable<$core.String>? wallets,
  }) {
    final $result = create();
    if (wallets != null) {
      $result.wallets.addAll(wallets);
    }
    return $result;
  }
  ListWalletsResponse._() : super();
  factory ListWalletsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListWalletsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListWalletsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'wallets')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListWalletsResponse clone() => ListWalletsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListWalletsResponse copyWith(void Function(ListWalletsResponse) updates) => super.copyWith((message) => updates(message as ListWalletsResponse)) as ListWalletsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListWalletsResponse create() => ListWalletsResponse._();
  ListWalletsResponse createEmptyInstance() => create();
  static $pb.PbList<ListWalletsResponse> createRepeated() => $pb.PbList<ListWalletsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListWalletsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListWalletsResponse>(create);
  static ListWalletsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get wallets => $_getList(0);
}

class ListUnspentRequest extends $pb.GeneratedMessage {
  factory ListUnspentRequest({
    $core.String? wallet,
    $core.int? minimumConfirmations,
    $core.int? maximumConfirmations,
    $core.Iterable<$core.String>? addresses,
    $core.bool? includeUnsafe,
    $core.bool? includeWatchOnly,
  }) {
    final $result = create();
    if (wallet != null) {
      $result.wallet = wallet;
    }
    if (minimumConfirmations != null) {
      $result.minimumConfirmations = minimumConfirmations;
    }
    if (maximumConfirmations != null) {
      $result.maximumConfirmations = maximumConfirmations;
    }
    if (addresses != null) {
      $result.addresses.addAll(addresses);
    }
    if (includeUnsafe != null) {
      $result.includeUnsafe = includeUnsafe;
    }
    if (includeWatchOnly != null) {
      $result.includeWatchOnly = includeWatchOnly;
    }
    return $result;
  }
  ListUnspentRequest._() : super();
  factory ListUnspentRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListUnspentRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUnspentRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'minimumConfirmations', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'maximumConfirmations', $pb.PbFieldType.OU3)
    ..pPS(4, _omitFieldNames ? '' : 'addresses')
    ..aOB(5, _omitFieldNames ? '' : 'includeUnsafe')
    ..aOB(6, _omitFieldNames ? '' : 'includeWatchOnly')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListUnspentRequest clone() => ListUnspentRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListUnspentRequest copyWith(void Function(ListUnspentRequest) updates) => super.copyWith((message) => updates(message as ListUnspentRequest)) as ListUnspentRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUnspentRequest create() => ListUnspentRequest._();
  ListUnspentRequest createEmptyInstance() => create();
  static $pb.PbList<ListUnspentRequest> createRepeated() => $pb.PbList<ListUnspentRequest>();
  @$core.pragma('dart2js:noInline')
  static ListUnspentRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUnspentRequest>(create);
  static ListUnspentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => clearField(1);

  /// The minimum confirmations to filter
  @$pb.TagNumber(2)
  $core.int get minimumConfirmations => $_getIZ(1);
  @$pb.TagNumber(2)
  set minimumConfirmations($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMinimumConfirmations() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinimumConfirmations() => clearField(2);

  /// The maximum confirmations to filter
  @$pb.TagNumber(3)
  $core.int get maximumConfirmations => $_getIZ(2);
  @$pb.TagNumber(3)
  set maximumConfirmations($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMaximumConfirmations() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaximumConfirmations() => clearField(3);

  /// The bitcoin addresses to filter
  @$pb.TagNumber(4)
  $core.List<$core.String> get addresses => $_getList(3);

  /// Whether to include unsafe outputs
  @$pb.TagNumber(5)
  $core.bool get includeUnsafe => $_getBF(4);
  @$pb.TagNumber(5)
  set includeUnsafe($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIncludeUnsafe() => $_has(4);
  @$pb.TagNumber(5)
  void clearIncludeUnsafe() => clearField(5);

  /// Whether to include watch-only addresses
  @$pb.TagNumber(6)
  $core.bool get includeWatchOnly => $_getBF(5);
  @$pb.TagNumber(6)
  set includeWatchOnly($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIncludeWatchOnly() => $_has(5);
  @$pb.TagNumber(6)
  void clearIncludeWatchOnly() => clearField(6);
}

class UnspentOutput extends $pb.GeneratedMessage {
  factory UnspentOutput({
    $core.String? txid,
    $core.int? vout,
    $core.String? address,
    $core.String? scriptPubKey,
    $core.double? amount,
    $core.int? confirmations,
    $core.String? redeemScript,
    $core.bool? spendable,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (address != null) {
      $result.address = address;
    }
    if (scriptPubKey != null) {
      $result.scriptPubKey = scriptPubKey;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (redeemScript != null) {
      $result.redeemScript = redeemScript;
    }
    if (spendable != null) {
      $result.spendable = spendable;
    }
    return $result;
  }
  UnspentOutput._() : super();
  factory UnspentOutput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnspentOutput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnspentOutput', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aOS(5, _omitFieldNames ? '' : 'scriptPubKey')
    ..a<$core.double>(6, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.OU3)
    ..aOS(11, _omitFieldNames ? '' : 'redeemScript')
    ..aOB(13, _omitFieldNames ? '' : 'spendable')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnspentOutput clone() => UnspentOutput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnspentOutput copyWith(void Function(UnspentOutput) updates) => super.copyWith((message) => updates(message as UnspentOutput)) as UnspentOutput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnspentOutput create() => UnspentOutput._();
  UnspentOutput createEmptyInstance() => create();
  static $pb.PbList<UnspentOutput> createRepeated() => $pb.PbList<UnspentOutput>();
  @$core.pragma('dart2js:noInline')
  static UnspentOutput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnspentOutput>(create);
  static UnspentOutput? _defaultInstance;

  /// The transaction id
  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  /// The vout value
  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => clearField(2);

  /// The bitcoin address (optional)
  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => clearField(3);

  /// The output script
  @$pb.TagNumber(5)
  $core.String get scriptPubKey => $_getSZ(3);
  @$pb.TagNumber(5)
  set scriptPubKey($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(5)
  $core.bool hasScriptPubKey() => $_has(3);
  @$pb.TagNumber(5)
  void clearScriptPubKey() => clearField(5);

  /// The transaction output amount in BTC
  @$pb.TagNumber(6)
  $core.double get amount => $_getN(4);
  @$pb.TagNumber(6)
  set amount($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasAmount() => $_has(4);
  @$pb.TagNumber(6)
  void clearAmount() => clearField(6);

  /// The number of confirmations
  @$pb.TagNumber(7)
  $core.int get confirmations => $_getIZ(5);
  @$pb.TagNumber(7)
  set confirmations($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(7)
  $core.bool hasConfirmations() => $_has(5);
  @$pb.TagNumber(7)
  void clearConfirmations() => clearField(7);

  /// The redeem script if the output script is P2SH (optional)
  @$pb.TagNumber(11)
  $core.String get redeemScript => $_getSZ(6);
  @$pb.TagNumber(11)
  set redeemScript($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(11)
  $core.bool hasRedeemScript() => $_has(6);
  @$pb.TagNumber(11)
  void clearRedeemScript() => clearField(11);

  /// Whether we have the private keys to spend this output
  @$pb.TagNumber(13)
  $core.bool get spendable => $_getBF(7);
  @$pb.TagNumber(13)
  set spendable($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(13)
  $core.bool hasSpendable() => $_has(7);
  @$pb.TagNumber(13)
  void clearSpendable() => clearField(13);
}

class ListUnspentResponse extends $pb.GeneratedMessage {
  factory ListUnspentResponse({
    $core.Iterable<UnspentOutput>? unspent,
  }) {
    final $result = create();
    if (unspent != null) {
      $result.unspent.addAll(unspent);
    }
    return $result;
  }
  ListUnspentResponse._() : super();
  factory ListUnspentResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListUnspentResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUnspentResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pc<UnspentOutput>(1, _omitFieldNames ? '' : 'unspent', $pb.PbFieldType.PM, subBuilder: UnspentOutput.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListUnspentResponse clone() => ListUnspentResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListUnspentResponse copyWith(void Function(ListUnspentResponse) updates) => super.copyWith((message) => updates(message as ListUnspentResponse)) as ListUnspentResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUnspentResponse create() => ListUnspentResponse._();
  ListUnspentResponse createEmptyInstance() => create();
  static $pb.PbList<ListUnspentResponse> createRepeated() => $pb.PbList<ListUnspentResponse>();
  @$core.pragma('dart2js:noInline')
  static ListUnspentResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUnspentResponse>(create);
  static ListUnspentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<UnspentOutput> get unspent => $_getList(0);
}

class GetAddressInfoRequest extends $pb.GeneratedMessage {
  factory GetAddressInfoRequest({
    $core.String? address,
    $core.String? wallet,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  GetAddressInfoRequest._() : super();
  factory GetAddressInfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAddressInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressInfoRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAddressInfoRequest clone() => GetAddressInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAddressInfoRequest copyWith(void Function(GetAddressInfoRequest) updates) => super.copyWith((message) => updates(message as GetAddressInfoRequest)) as GetAddressInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAddressInfoRequest create() => GetAddressInfoRequest._();
  GetAddressInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetAddressInfoRequest> createRepeated() => $pb.PbList<GetAddressInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetAddressInfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAddressInfoRequest>(create);
  static GetAddressInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class GetAddressInfoResponse extends $pb.GeneratedMessage {
  factory GetAddressInfoResponse({
    $core.String? address,
    $core.String? scriptPubKey,
    $core.bool? isMine,
    $core.bool? isWatchOnly,
    $core.bool? solvable,
    $core.bool? isScript,
    $core.bool? isChange,
    $core.bool? isWitness,
    $core.int? witnessVersion,
    $core.String? witnessProgram,
    $core.String? scriptType,
    $core.bool? isCompressed,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (scriptPubKey != null) {
      $result.scriptPubKey = scriptPubKey;
    }
    if (isMine != null) {
      $result.isMine = isMine;
    }
    if (isWatchOnly != null) {
      $result.isWatchOnly = isWatchOnly;
    }
    if (solvable != null) {
      $result.solvable = solvable;
    }
    if (isScript != null) {
      $result.isScript = isScript;
    }
    if (isChange != null) {
      $result.isChange = isChange;
    }
    if (isWitness != null) {
      $result.isWitness = isWitness;
    }
    if (witnessVersion != null) {
      $result.witnessVersion = witnessVersion;
    }
    if (witnessProgram != null) {
      $result.witnessProgram = witnessProgram;
    }
    if (scriptType != null) {
      $result.scriptType = scriptType;
    }
    if (isCompressed != null) {
      $result.isCompressed = isCompressed;
    }
    return $result;
  }
  GetAddressInfoResponse._() : super();
  factory GetAddressInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAddressInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'scriptPubKey')
    ..aOB(3, _omitFieldNames ? '' : 'isMine')
    ..aOB(4, _omitFieldNames ? '' : 'isWatchOnly')
    ..aOB(5, _omitFieldNames ? '' : 'solvable')
    ..aOB(6, _omitFieldNames ? '' : 'isScript')
    ..aOB(7, _omitFieldNames ? '' : 'isChange')
    ..aOB(8, _omitFieldNames ? '' : 'isWitness')
    ..a<$core.int>(9, _omitFieldNames ? '' : 'witnessVersion', $pb.PbFieldType.OU3)
    ..aOS(10, _omitFieldNames ? '' : 'witnessProgram')
    ..aOS(11, _omitFieldNames ? '' : 'scriptType')
    ..aOB(12, _omitFieldNames ? '' : 'isCompressed')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAddressInfoResponse clone() => GetAddressInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAddressInfoResponse copyWith(void Function(GetAddressInfoResponse) updates) => super.copyWith((message) => updates(message as GetAddressInfoResponse)) as GetAddressInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAddressInfoResponse create() => GetAddressInfoResponse._();
  GetAddressInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetAddressInfoResponse> createRepeated() => $pb.PbList<GetAddressInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetAddressInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAddressInfoResponse>(create);
  static GetAddressInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  /// Hex-encoded script pub key
  @$pb.TagNumber(2)
  $core.String get scriptPubKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set scriptPubKey($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasScriptPubKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearScriptPubKey() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isMine => $_getBF(2);
  @$pb.TagNumber(3)
  set isMine($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsMine() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsMine() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isWatchOnly => $_getBF(3);
  @$pb.TagNumber(4)
  set isWatchOnly($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsWatchOnly() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsWatchOnly() => clearField(4);

  /// If Core knows how to spend coins sent to this address, ignoring
  /// possible lack of private keys.
  @$pb.TagNumber(5)
  $core.bool get solvable => $_getBF(4);
  @$pb.TagNumber(5)
  set solvable($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSolvable() => $_has(4);
  @$pb.TagNumber(5)
  void clearSolvable() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isScript => $_getBF(5);
  @$pb.TagNumber(6)
  set isScript($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsScript() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsScript() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isChange => $_getBF(6);
  @$pb.TagNumber(7)
  set isChange($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasIsChange() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsChange() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isWitness => $_getBF(7);
  @$pb.TagNumber(8)
  set isWitness($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasIsWitness() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsWitness() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get witnessVersion => $_getIZ(8);
  @$pb.TagNumber(9)
  set witnessVersion($core.int v) { $_setUnsignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasWitnessVersion() => $_has(8);
  @$pb.TagNumber(9)
  void clearWitnessVersion() => clearField(9);

  /// Hex-encoded
  @$pb.TagNumber(10)
  $core.String get witnessProgram => $_getSZ(9);
  @$pb.TagNumber(10)
  set witnessProgram($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasWitnessProgram() => $_has(9);
  @$pb.TagNumber(10)
  void clearWitnessProgram() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get scriptType => $_getSZ(10);
  @$pb.TagNumber(11)
  set scriptType($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasScriptType() => $_has(10);
  @$pb.TagNumber(11)
  void clearScriptType() => clearField(11);

  @$pb.TagNumber(12)
  $core.bool get isCompressed => $_getBF(11);
  @$pb.TagNumber(12)
  set isCompressed($core.bool v) { $_setBool(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasIsCompressed() => $_has(11);
  @$pb.TagNumber(12)
  void clearIsCompressed() => clearField(12);
}

/// Request/Response messages for new endpoints
class CreateWalletRequest extends $pb.GeneratedMessage {
  factory CreateWalletRequest({
    $core.String? name,
    $core.bool? disablePrivateKeys,
    $core.bool? blank,
    $core.String? passphrase,
    $core.bool? avoidReuse,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (disablePrivateKeys != null) {
      $result.disablePrivateKeys = disablePrivateKeys;
    }
    if (blank != null) {
      $result.blank = blank;
    }
    if (passphrase != null) {
      $result.passphrase = passphrase;
    }
    if (avoidReuse != null) {
      $result.avoidReuse = avoidReuse;
    }
    return $result;
  }
  CreateWalletRequest._() : super();
  factory CreateWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOB(2, _omitFieldNames ? '' : 'disablePrivateKeys')
    ..aOB(3, _omitFieldNames ? '' : 'blank')
    ..aOS(4, _omitFieldNames ? '' : 'passphrase')
    ..aOB(5, _omitFieldNames ? '' : 'avoidReuse')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateWalletRequest clone() => CreateWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateWalletRequest copyWith(void Function(CreateWalletRequest) updates) => super.copyWith((message) => updates(message as CreateWalletRequest)) as CreateWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateWalletRequest create() => CreateWalletRequest._();
  CreateWalletRequest createEmptyInstance() => create();
  static $pb.PbList<CreateWalletRequest> createRepeated() => $pb.PbList<CreateWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateWalletRequest>(create);
  static CreateWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get disablePrivateKeys => $_getBF(1);
  @$pb.TagNumber(2)
  set disablePrivateKeys($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDisablePrivateKeys() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisablePrivateKeys() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get blank => $_getBF(2);
  @$pb.TagNumber(3)
  set blank($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBlank() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlank() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get passphrase => $_getSZ(3);
  @$pb.TagNumber(4)
  set passphrase($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPassphrase() => $_has(3);
  @$pb.TagNumber(4)
  void clearPassphrase() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get avoidReuse => $_getBF(4);
  @$pb.TagNumber(5)
  set avoidReuse($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAvoidReuse() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvoidReuse() => clearField(5);
}

class CreateWalletResponse extends $pb.GeneratedMessage {
  factory CreateWalletResponse({
    $core.String? name,
    $core.String? warning,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (warning != null) {
      $result.warning = warning;
    }
    return $result;
  }
  CreateWalletResponse._() : super();
  factory CreateWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'warning')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateWalletResponse clone() => CreateWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateWalletResponse copyWith(void Function(CreateWalletResponse) updates) => super.copyWith((message) => updates(message as CreateWalletResponse)) as CreateWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateWalletResponse create() => CreateWalletResponse._();
  CreateWalletResponse createEmptyInstance() => create();
  static $pb.PbList<CreateWalletResponse> createRepeated() => $pb.PbList<CreateWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateWalletResponse>(create);
  static CreateWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get warning => $_getSZ(1);
  @$pb.TagNumber(2)
  set warning($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWarning() => $_has(1);
  @$pb.TagNumber(2)
  void clearWarning() => clearField(2);
}

class BackupWalletRequest extends $pb.GeneratedMessage {
  factory BackupWalletRequest({
    $core.String? destination,
    $core.String? wallet,
  }) {
    final $result = create();
    if (destination != null) {
      $result.destination = destination;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  BackupWalletRequest._() : super();
  factory BackupWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BackupWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BackupWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'destination')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BackupWalletRequest clone() => BackupWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BackupWalletRequest copyWith(void Function(BackupWalletRequest) updates) => super.copyWith((message) => updates(message as BackupWalletRequest)) as BackupWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BackupWalletRequest create() => BackupWalletRequest._();
  BackupWalletRequest createEmptyInstance() => create();
  static $pb.PbList<BackupWalletRequest> createRepeated() => $pb.PbList<BackupWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static BackupWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BackupWalletRequest>(create);
  static BackupWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get destination => $_getSZ(0);
  @$pb.TagNumber(1)
  set destination($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDestination() => $_has(0);
  @$pb.TagNumber(1)
  void clearDestination() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class BackupWalletResponse extends $pb.GeneratedMessage {
  factory BackupWalletResponse() => create();
  BackupWalletResponse._() : super();
  factory BackupWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BackupWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BackupWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BackupWalletResponse clone() => BackupWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BackupWalletResponse copyWith(void Function(BackupWalletResponse) updates) => super.copyWith((message) => updates(message as BackupWalletResponse)) as BackupWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BackupWalletResponse create() => BackupWalletResponse._();
  BackupWalletResponse createEmptyInstance() => create();
  static $pb.PbList<BackupWalletResponse> createRepeated() => $pb.PbList<BackupWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static BackupWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BackupWalletResponse>(create);
  static BackupWalletResponse? _defaultInstance;
}

class DumpWalletRequest extends $pb.GeneratedMessage {
  factory DumpWalletRequest({
    $core.String? filename,
    $core.String? wallet,
  }) {
    final $result = create();
    if (filename != null) {
      $result.filename = filename;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  DumpWalletRequest._() : super();
  factory DumpWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DumpWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DumpWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filename')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DumpWalletRequest clone() => DumpWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DumpWalletRequest copyWith(void Function(DumpWalletRequest) updates) => super.copyWith((message) => updates(message as DumpWalletRequest)) as DumpWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DumpWalletRequest create() => DumpWalletRequest._();
  DumpWalletRequest createEmptyInstance() => create();
  static $pb.PbList<DumpWalletRequest> createRepeated() => $pb.PbList<DumpWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static DumpWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DumpWalletRequest>(create);
  static DumpWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filename => $_getSZ(0);
  @$pb.TagNumber(1)
  set filename($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFilename() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilename() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class DumpWalletResponse extends $pb.GeneratedMessage {
  factory DumpWalletResponse({
    $core.String? filename,
  }) {
    final $result = create();
    if (filename != null) {
      $result.filename = filename;
    }
    return $result;
  }
  DumpWalletResponse._() : super();
  factory DumpWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DumpWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DumpWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filename')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DumpWalletResponse clone() => DumpWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DumpWalletResponse copyWith(void Function(DumpWalletResponse) updates) => super.copyWith((message) => updates(message as DumpWalletResponse)) as DumpWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DumpWalletResponse create() => DumpWalletResponse._();
  DumpWalletResponse createEmptyInstance() => create();
  static $pb.PbList<DumpWalletResponse> createRepeated() => $pb.PbList<DumpWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static DumpWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DumpWalletResponse>(create);
  static DumpWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filename => $_getSZ(0);
  @$pb.TagNumber(1)
  set filename($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFilename() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilename() => clearField(1);
}

class ImportWalletRequest extends $pb.GeneratedMessage {
  factory ImportWalletRequest({
    $core.String? filename,
    $core.String? wallet,
  }) {
    final $result = create();
    if (filename != null) {
      $result.filename = filename;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  ImportWalletRequest._() : super();
  factory ImportWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filename')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportWalletRequest clone() => ImportWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportWalletRequest copyWith(void Function(ImportWalletRequest) updates) => super.copyWith((message) => updates(message as ImportWalletRequest)) as ImportWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportWalletRequest create() => ImportWalletRequest._();
  ImportWalletRequest createEmptyInstance() => create();
  static $pb.PbList<ImportWalletRequest> createRepeated() => $pb.PbList<ImportWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static ImportWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportWalletRequest>(create);
  static ImportWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filename => $_getSZ(0);
  @$pb.TagNumber(1)
  set filename($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFilename() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilename() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class ImportWalletResponse extends $pb.GeneratedMessage {
  factory ImportWalletResponse() => create();
  ImportWalletResponse._() : super();
  factory ImportWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportWalletResponse clone() => ImportWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportWalletResponse copyWith(void Function(ImportWalletResponse) updates) => super.copyWith((message) => updates(message as ImportWalletResponse)) as ImportWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportWalletResponse create() => ImportWalletResponse._();
  ImportWalletResponse createEmptyInstance() => create();
  static $pb.PbList<ImportWalletResponse> createRepeated() => $pb.PbList<ImportWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static ImportWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportWalletResponse>(create);
  static ImportWalletResponse? _defaultInstance;
}

class UnloadWalletRequest extends $pb.GeneratedMessage {
  factory UnloadWalletRequest({
    $core.String? walletName,
    $core.String? wallet,
  }) {
    final $result = create();
    if (walletName != null) {
      $result.walletName = walletName;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  UnloadWalletRequest._() : super();
  factory UnloadWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnloadWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnloadWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletName')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnloadWalletRequest clone() => UnloadWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnloadWalletRequest copyWith(void Function(UnloadWalletRequest) updates) => super.copyWith((message) => updates(message as UnloadWalletRequest)) as UnloadWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnloadWalletRequest create() => UnloadWalletRequest._();
  UnloadWalletRequest createEmptyInstance() => create();
  static $pb.PbList<UnloadWalletRequest> createRepeated() => $pb.PbList<UnloadWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static UnloadWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnloadWalletRequest>(create);
  static UnloadWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletName => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletName() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class UnloadWalletResponse extends $pb.GeneratedMessage {
  factory UnloadWalletResponse() => create();
  UnloadWalletResponse._() : super();
  factory UnloadWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnloadWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnloadWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnloadWalletResponse clone() => UnloadWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnloadWalletResponse copyWith(void Function(UnloadWalletResponse) updates) => super.copyWith((message) => updates(message as UnloadWalletResponse)) as UnloadWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnloadWalletResponse create() => UnloadWalletResponse._();
  UnloadWalletResponse createEmptyInstance() => create();
  static $pb.PbList<UnloadWalletResponse> createRepeated() => $pb.PbList<UnloadWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static UnloadWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnloadWalletResponse>(create);
  static UnloadWalletResponse? _defaultInstance;
}

class DumpPrivKeyRequest extends $pb.GeneratedMessage {
  factory DumpPrivKeyRequest({
    $core.String? address,
    $core.String? wallet,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  DumpPrivKeyRequest._() : super();
  factory DumpPrivKeyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DumpPrivKeyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DumpPrivKeyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DumpPrivKeyRequest clone() => DumpPrivKeyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DumpPrivKeyRequest copyWith(void Function(DumpPrivKeyRequest) updates) => super.copyWith((message) => updates(message as DumpPrivKeyRequest)) as DumpPrivKeyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DumpPrivKeyRequest create() => DumpPrivKeyRequest._();
  DumpPrivKeyRequest createEmptyInstance() => create();
  static $pb.PbList<DumpPrivKeyRequest> createRepeated() => $pb.PbList<DumpPrivKeyRequest>();
  @$core.pragma('dart2js:noInline')
  static DumpPrivKeyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DumpPrivKeyRequest>(create);
  static DumpPrivKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class DumpPrivKeyResponse extends $pb.GeneratedMessage {
  factory DumpPrivKeyResponse({
    $core.String? privateKey,
  }) {
    final $result = create();
    if (privateKey != null) {
      $result.privateKey = privateKey;
    }
    return $result;
  }
  DumpPrivKeyResponse._() : super();
  factory DumpPrivKeyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DumpPrivKeyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DumpPrivKeyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'privateKey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DumpPrivKeyResponse clone() => DumpPrivKeyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DumpPrivKeyResponse copyWith(void Function(DumpPrivKeyResponse) updates) => super.copyWith((message) => updates(message as DumpPrivKeyResponse)) as DumpPrivKeyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DumpPrivKeyResponse create() => DumpPrivKeyResponse._();
  DumpPrivKeyResponse createEmptyInstance() => create();
  static $pb.PbList<DumpPrivKeyResponse> createRepeated() => $pb.PbList<DumpPrivKeyResponse>();
  @$core.pragma('dart2js:noInline')
  static DumpPrivKeyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DumpPrivKeyResponse>(create);
  static DumpPrivKeyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get privateKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set privateKey($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPrivateKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrivateKey() => clearField(1);
}

class ImportPrivKeyRequest extends $pb.GeneratedMessage {
  factory ImportPrivKeyRequest({
    $core.String? privateKey,
    $core.String? label,
    $core.bool? rescan,
    $core.String? wallet,
  }) {
    final $result = create();
    if (privateKey != null) {
      $result.privateKey = privateKey;
    }
    if (label != null) {
      $result.label = label;
    }
    if (rescan != null) {
      $result.rescan = rescan;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  ImportPrivKeyRequest._() : super();
  factory ImportPrivKeyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportPrivKeyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportPrivKeyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'privateKey')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOB(3, _omitFieldNames ? '' : 'rescan')
    ..aOS(4, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportPrivKeyRequest clone() => ImportPrivKeyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportPrivKeyRequest copyWith(void Function(ImportPrivKeyRequest) updates) => super.copyWith((message) => updates(message as ImportPrivKeyRequest)) as ImportPrivKeyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportPrivKeyRequest create() => ImportPrivKeyRequest._();
  ImportPrivKeyRequest createEmptyInstance() => create();
  static $pb.PbList<ImportPrivKeyRequest> createRepeated() => $pb.PbList<ImportPrivKeyRequest>();
  @$core.pragma('dart2js:noInline')
  static ImportPrivKeyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportPrivKeyRequest>(create);
  static ImportPrivKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get privateKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set privateKey($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPrivateKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrivateKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get rescan => $_getBF(2);
  @$pb.TagNumber(3)
  set rescan($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRescan() => $_has(2);
  @$pb.TagNumber(3)
  void clearRescan() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get wallet => $_getSZ(3);
  @$pb.TagNumber(4)
  set wallet($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWallet() => $_has(3);
  @$pb.TagNumber(4)
  void clearWallet() => clearField(4);
}

class ImportPrivKeyResponse extends $pb.GeneratedMessage {
  factory ImportPrivKeyResponse() => create();
  ImportPrivKeyResponse._() : super();
  factory ImportPrivKeyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportPrivKeyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportPrivKeyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportPrivKeyResponse clone() => ImportPrivKeyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportPrivKeyResponse copyWith(void Function(ImportPrivKeyResponse) updates) => super.copyWith((message) => updates(message as ImportPrivKeyResponse)) as ImportPrivKeyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportPrivKeyResponse create() => ImportPrivKeyResponse._();
  ImportPrivKeyResponse createEmptyInstance() => create();
  static $pb.PbList<ImportPrivKeyResponse> createRepeated() => $pb.PbList<ImportPrivKeyResponse>();
  @$core.pragma('dart2js:noInline')
  static ImportPrivKeyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportPrivKeyResponse>(create);
  static ImportPrivKeyResponse? _defaultInstance;
}

class ImportAddressRequest extends $pb.GeneratedMessage {
  factory ImportAddressRequest({
    $core.String? address,
    $core.String? label,
    $core.bool? rescan,
    $core.String? wallet,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (label != null) {
      $result.label = label;
    }
    if (rescan != null) {
      $result.rescan = rescan;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  ImportAddressRequest._() : super();
  factory ImportAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOB(3, _omitFieldNames ? '' : 'rescan')
    ..aOS(4, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportAddressRequest clone() => ImportAddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportAddressRequest copyWith(void Function(ImportAddressRequest) updates) => super.copyWith((message) => updates(message as ImportAddressRequest)) as ImportAddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportAddressRequest create() => ImportAddressRequest._();
  ImportAddressRequest createEmptyInstance() => create();
  static $pb.PbList<ImportAddressRequest> createRepeated() => $pb.PbList<ImportAddressRequest>();
  @$core.pragma('dart2js:noInline')
  static ImportAddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportAddressRequest>(create);
  static ImportAddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get rescan => $_getBF(2);
  @$pb.TagNumber(3)
  set rescan($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRescan() => $_has(2);
  @$pb.TagNumber(3)
  void clearRescan() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get wallet => $_getSZ(3);
  @$pb.TagNumber(4)
  set wallet($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWallet() => $_has(3);
  @$pb.TagNumber(4)
  void clearWallet() => clearField(4);
}

class ImportAddressResponse extends $pb.GeneratedMessage {
  factory ImportAddressResponse() => create();
  ImportAddressResponse._() : super();
  factory ImportAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportAddressResponse clone() => ImportAddressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportAddressResponse copyWith(void Function(ImportAddressResponse) updates) => super.copyWith((message) => updates(message as ImportAddressResponse)) as ImportAddressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportAddressResponse create() => ImportAddressResponse._();
  ImportAddressResponse createEmptyInstance() => create();
  static $pb.PbList<ImportAddressResponse> createRepeated() => $pb.PbList<ImportAddressResponse>();
  @$core.pragma('dart2js:noInline')
  static ImportAddressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportAddressResponse>(create);
  static ImportAddressResponse? _defaultInstance;
}

class ImportPubKeyRequest extends $pb.GeneratedMessage {
  factory ImportPubKeyRequest({
    $core.String? pubkey,
    $core.bool? rescan,
    $core.String? wallet,
  }) {
    final $result = create();
    if (pubkey != null) {
      $result.pubkey = pubkey;
    }
    if (rescan != null) {
      $result.rescan = rescan;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  ImportPubKeyRequest._() : super();
  factory ImportPubKeyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportPubKeyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportPubKeyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pubkey')
    ..aOB(2, _omitFieldNames ? '' : 'rescan')
    ..aOS(3, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportPubKeyRequest clone() => ImportPubKeyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportPubKeyRequest copyWith(void Function(ImportPubKeyRequest) updates) => super.copyWith((message) => updates(message as ImportPubKeyRequest)) as ImportPubKeyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportPubKeyRequest create() => ImportPubKeyRequest._();
  ImportPubKeyRequest createEmptyInstance() => create();
  static $pb.PbList<ImportPubKeyRequest> createRepeated() => $pb.PbList<ImportPubKeyRequest>();
  @$core.pragma('dart2js:noInline')
  static ImportPubKeyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportPubKeyRequest>(create);
  static ImportPubKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pubkey => $_getSZ(0);
  @$pb.TagNumber(1)
  set pubkey($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPubkey() => $_has(0);
  @$pb.TagNumber(1)
  void clearPubkey() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get rescan => $_getBF(1);
  @$pb.TagNumber(2)
  set rescan($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRescan() => $_has(1);
  @$pb.TagNumber(2)
  void clearRescan() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get wallet => $_getSZ(2);
  @$pb.TagNumber(3)
  set wallet($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWallet() => $_has(2);
  @$pb.TagNumber(3)
  void clearWallet() => clearField(3);
}

class ImportPubKeyResponse extends $pb.GeneratedMessage {
  factory ImportPubKeyResponse() => create();
  ImportPubKeyResponse._() : super();
  factory ImportPubKeyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportPubKeyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportPubKeyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportPubKeyResponse clone() => ImportPubKeyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportPubKeyResponse copyWith(void Function(ImportPubKeyResponse) updates) => super.copyWith((message) => updates(message as ImportPubKeyResponse)) as ImportPubKeyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportPubKeyResponse create() => ImportPubKeyResponse._();
  ImportPubKeyResponse createEmptyInstance() => create();
  static $pb.PbList<ImportPubKeyResponse> createRepeated() => $pb.PbList<ImportPubKeyResponse>();
  @$core.pragma('dart2js:noInline')
  static ImportPubKeyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportPubKeyResponse>(create);
  static ImportPubKeyResponse? _defaultInstance;
}

class KeyPoolRefillRequest extends $pb.GeneratedMessage {
  factory KeyPoolRefillRequest({
    $core.int? newSize,
    $core.String? wallet,
  }) {
    final $result = create();
    if (newSize != null) {
      $result.newSize = newSize;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  KeyPoolRefillRequest._() : super();
  factory KeyPoolRefillRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KeyPoolRefillRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KeyPoolRefillRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'newSize', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  KeyPoolRefillRequest clone() => KeyPoolRefillRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  KeyPoolRefillRequest copyWith(void Function(KeyPoolRefillRequest) updates) => super.copyWith((message) => updates(message as KeyPoolRefillRequest)) as KeyPoolRefillRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KeyPoolRefillRequest create() => KeyPoolRefillRequest._();
  KeyPoolRefillRequest createEmptyInstance() => create();
  static $pb.PbList<KeyPoolRefillRequest> createRepeated() => $pb.PbList<KeyPoolRefillRequest>();
  @$core.pragma('dart2js:noInline')
  static KeyPoolRefillRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyPoolRefillRequest>(create);
  static KeyPoolRefillRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get newSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set newSize($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasNewSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearNewSize() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class KeyPoolRefillResponse extends $pb.GeneratedMessage {
  factory KeyPoolRefillResponse() => create();
  KeyPoolRefillResponse._() : super();
  factory KeyPoolRefillResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KeyPoolRefillResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KeyPoolRefillResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  KeyPoolRefillResponse clone() => KeyPoolRefillResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  KeyPoolRefillResponse copyWith(void Function(KeyPoolRefillResponse) updates) => super.copyWith((message) => updates(message as KeyPoolRefillResponse)) as KeyPoolRefillResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KeyPoolRefillResponse create() => KeyPoolRefillResponse._();
  KeyPoolRefillResponse createEmptyInstance() => create();
  static $pb.PbList<KeyPoolRefillResponse> createRepeated() => $pb.PbList<KeyPoolRefillResponse>();
  @$core.pragma('dart2js:noInline')
  static KeyPoolRefillResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyPoolRefillResponse>(create);
  static KeyPoolRefillResponse? _defaultInstance;
}

class GetAccountRequest extends $pb.GeneratedMessage {
  factory GetAccountRequest({
    $core.String? address,
    $core.String? wallet,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  GetAccountRequest._() : super();
  factory GetAccountRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAccountRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAccountRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAccountRequest clone() => GetAccountRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAccountRequest copyWith(void Function(GetAccountRequest) updates) => super.copyWith((message) => updates(message as GetAccountRequest)) as GetAccountRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAccountRequest create() => GetAccountRequest._();
  GetAccountRequest createEmptyInstance() => create();
  static $pb.PbList<GetAccountRequest> createRepeated() => $pb.PbList<GetAccountRequest>();
  @$core.pragma('dart2js:noInline')
  static GetAccountRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAccountRequest>(create);
  static GetAccountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class GetAccountResponse extends $pb.GeneratedMessage {
  factory GetAccountResponse({
    $core.String? account,
  }) {
    final $result = create();
    if (account != null) {
      $result.account = account;
    }
    return $result;
  }
  GetAccountResponse._() : super();
  factory GetAccountResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAccountResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAccountResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'account')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAccountResponse clone() => GetAccountResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAccountResponse copyWith(void Function(GetAccountResponse) updates) => super.copyWith((message) => updates(message as GetAccountResponse)) as GetAccountResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAccountResponse create() => GetAccountResponse._();
  GetAccountResponse createEmptyInstance() => create();
  static $pb.PbList<GetAccountResponse> createRepeated() => $pb.PbList<GetAccountResponse>();
  @$core.pragma('dart2js:noInline')
  static GetAccountResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAccountResponse>(create);
  static GetAccountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get account => $_getSZ(0);
  @$pb.TagNumber(1)
  set account($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccount() => clearField(1);
}

class SetAccountRequest extends $pb.GeneratedMessage {
  factory SetAccountRequest({
    $core.String? address,
    $core.String? account,
    $core.String? wallet,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (account != null) {
      $result.account = account;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  SetAccountRequest._() : super();
  factory SetAccountRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetAccountRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetAccountRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'account')
    ..aOS(3, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetAccountRequest clone() => SetAccountRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetAccountRequest copyWith(void Function(SetAccountRequest) updates) => super.copyWith((message) => updates(message as SetAccountRequest)) as SetAccountRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetAccountRequest create() => SetAccountRequest._();
  SetAccountRequest createEmptyInstance() => create();
  static $pb.PbList<SetAccountRequest> createRepeated() => $pb.PbList<SetAccountRequest>();
  @$core.pragma('dart2js:noInline')
  static SetAccountRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetAccountRequest>(create);
  static SetAccountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get account => $_getSZ(1);
  @$pb.TagNumber(2)
  set account($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAccount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccount() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get wallet => $_getSZ(2);
  @$pb.TagNumber(3)
  set wallet($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWallet() => $_has(2);
  @$pb.TagNumber(3)
  void clearWallet() => clearField(3);
}

class SetAccountResponse extends $pb.GeneratedMessage {
  factory SetAccountResponse() => create();
  SetAccountResponse._() : super();
  factory SetAccountResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetAccountResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetAccountResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetAccountResponse clone() => SetAccountResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetAccountResponse copyWith(void Function(SetAccountResponse) updates) => super.copyWith((message) => updates(message as SetAccountResponse)) as SetAccountResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetAccountResponse create() => SetAccountResponse._();
  SetAccountResponse createEmptyInstance() => create();
  static $pb.PbList<SetAccountResponse> createRepeated() => $pb.PbList<SetAccountResponse>();
  @$core.pragma('dart2js:noInline')
  static SetAccountResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetAccountResponse>(create);
  static SetAccountResponse? _defaultInstance;
}

class GetAddressesByAccountRequest extends $pb.GeneratedMessage {
  factory GetAddressesByAccountRequest({
    $core.String? account,
    $core.String? wallet,
  }) {
    final $result = create();
    if (account != null) {
      $result.account = account;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  GetAddressesByAccountRequest._() : super();
  factory GetAddressesByAccountRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAddressesByAccountRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressesByAccountRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'account')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAddressesByAccountRequest clone() => GetAddressesByAccountRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAddressesByAccountRequest copyWith(void Function(GetAddressesByAccountRequest) updates) => super.copyWith((message) => updates(message as GetAddressesByAccountRequest)) as GetAddressesByAccountRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAddressesByAccountRequest create() => GetAddressesByAccountRequest._();
  GetAddressesByAccountRequest createEmptyInstance() => create();
  static $pb.PbList<GetAddressesByAccountRequest> createRepeated() => $pb.PbList<GetAddressesByAccountRequest>();
  @$core.pragma('dart2js:noInline')
  static GetAddressesByAccountRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAddressesByAccountRequest>(create);
  static GetAddressesByAccountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get account => $_getSZ(0);
  @$pb.TagNumber(1)
  set account($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccount() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class GetAddressesByAccountResponse extends $pb.GeneratedMessage {
  factory GetAddressesByAccountResponse({
    $core.Iterable<$core.String>? addresses,
  }) {
    final $result = create();
    if (addresses != null) {
      $result.addresses.addAll(addresses);
    }
    return $result;
  }
  GetAddressesByAccountResponse._() : super();
  factory GetAddressesByAccountResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAddressesByAccountResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressesByAccountResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'addresses')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAddressesByAccountResponse clone() => GetAddressesByAccountResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAddressesByAccountResponse copyWith(void Function(GetAddressesByAccountResponse) updates) => super.copyWith((message) => updates(message as GetAddressesByAccountResponse)) as GetAddressesByAccountResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAddressesByAccountResponse create() => GetAddressesByAccountResponse._();
  GetAddressesByAccountResponse createEmptyInstance() => create();
  static $pb.PbList<GetAddressesByAccountResponse> createRepeated() => $pb.PbList<GetAddressesByAccountResponse>();
  @$core.pragma('dart2js:noInline')
  static GetAddressesByAccountResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAddressesByAccountResponse>(create);
  static GetAddressesByAccountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get addresses => $_getList(0);
}

class ListAccountsRequest extends $pb.GeneratedMessage {
  factory ListAccountsRequest({
    $core.int? minConf,
    $core.String? wallet,
  }) {
    final $result = create();
    if (minConf != null) {
      $result.minConf = minConf;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  ListAccountsRequest._() : super();
  factory ListAccountsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListAccountsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListAccountsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'minConf', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListAccountsRequest clone() => ListAccountsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListAccountsRequest copyWith(void Function(ListAccountsRequest) updates) => super.copyWith((message) => updates(message as ListAccountsRequest)) as ListAccountsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAccountsRequest create() => ListAccountsRequest._();
  ListAccountsRequest createEmptyInstance() => create();
  static $pb.PbList<ListAccountsRequest> createRepeated() => $pb.PbList<ListAccountsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListAccountsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListAccountsRequest>(create);
  static ListAccountsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get minConf => $_getIZ(0);
  @$pb.TagNumber(1)
  set minConf($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMinConf() => $_has(0);
  @$pb.TagNumber(1)
  void clearMinConf() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class ListAccountsResponse extends $pb.GeneratedMessage {
  factory ListAccountsResponse({
    $core.Map<$core.String, $core.double>? accounts,
  }) {
    final $result = create();
    if (accounts != null) {
      $result.accounts.addAll(accounts);
    }
    return $result;
  }
  ListAccountsResponse._() : super();
  factory ListAccountsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListAccountsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListAccountsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..m<$core.String, $core.double>(1, _omitFieldNames ? '' : 'accounts', entryClassName: 'ListAccountsResponse.AccountsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OD, packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListAccountsResponse clone() => ListAccountsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListAccountsResponse copyWith(void Function(ListAccountsResponse) updates) => super.copyWith((message) => updates(message as ListAccountsResponse)) as ListAccountsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAccountsResponse create() => ListAccountsResponse._();
  ListAccountsResponse createEmptyInstance() => create();
  static $pb.PbList<ListAccountsResponse> createRepeated() => $pb.PbList<ListAccountsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListAccountsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListAccountsResponse>(create);
  static ListAccountsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$core.String, $core.double> get accounts => $_getMap(0);
}

class AddMultisigAddressRequest extends $pb.GeneratedMessage {
  factory AddMultisigAddressRequest({
    $core.int? requiredSigs,
    $core.Iterable<$core.String>? keys,
    $core.String? label,
    $core.String? wallet,
  }) {
    final $result = create();
    if (requiredSigs != null) {
      $result.requiredSigs = requiredSigs;
    }
    if (keys != null) {
      $result.keys.addAll(keys);
    }
    if (label != null) {
      $result.label = label;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  AddMultisigAddressRequest._() : super();
  factory AddMultisigAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddMultisigAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddMultisigAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'requiredSigs', $pb.PbFieldType.O3)
    ..pPS(2, _omitFieldNames ? '' : 'keys')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..aOS(4, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddMultisigAddressRequest clone() => AddMultisigAddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddMultisigAddressRequest copyWith(void Function(AddMultisigAddressRequest) updates) => super.copyWith((message) => updates(message as AddMultisigAddressRequest)) as AddMultisigAddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddMultisigAddressRequest create() => AddMultisigAddressRequest._();
  AddMultisigAddressRequest createEmptyInstance() => create();
  static $pb.PbList<AddMultisigAddressRequest> createRepeated() => $pb.PbList<AddMultisigAddressRequest>();
  @$core.pragma('dart2js:noInline')
  static AddMultisigAddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddMultisigAddressRequest>(create);
  static AddMultisigAddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get requiredSigs => $_getIZ(0);
  @$pb.TagNumber(1)
  set requiredSigs($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRequiredSigs() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequiredSigs() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get keys => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get wallet => $_getSZ(3);
  @$pb.TagNumber(4)
  set wallet($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWallet() => $_has(3);
  @$pb.TagNumber(4)
  void clearWallet() => clearField(4);
}

class AddMultisigAddressResponse extends $pb.GeneratedMessage {
  factory AddMultisigAddressResponse({
    $core.String? address,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  AddMultisigAddressResponse._() : super();
  factory AddMultisigAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddMultisigAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddMultisigAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddMultisigAddressResponse clone() => AddMultisigAddressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddMultisigAddressResponse copyWith(void Function(AddMultisigAddressResponse) updates) => super.copyWith((message) => updates(message as AddMultisigAddressResponse)) as AddMultisigAddressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddMultisigAddressResponse create() => AddMultisigAddressResponse._();
  AddMultisigAddressResponse createEmptyInstance() => create();
  static $pb.PbList<AddMultisigAddressResponse> createRepeated() => $pb.PbList<AddMultisigAddressResponse>();
  @$core.pragma('dart2js:noInline')
  static AddMultisigAddressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddMultisigAddressResponse>(create);
  static AddMultisigAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class CreateMultisigRequest extends $pb.GeneratedMessage {
  factory CreateMultisigRequest({
    $core.int? requiredSigs,
    $core.Iterable<$core.String>? keys,
  }) {
    final $result = create();
    if (requiredSigs != null) {
      $result.requiredSigs = requiredSigs;
    }
    if (keys != null) {
      $result.keys.addAll(keys);
    }
    return $result;
  }
  CreateMultisigRequest._() : super();
  factory CreateMultisigRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateMultisigRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateMultisigRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'requiredSigs', $pb.PbFieldType.O3)
    ..pPS(2, _omitFieldNames ? '' : 'keys')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateMultisigRequest clone() => CreateMultisigRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateMultisigRequest copyWith(void Function(CreateMultisigRequest) updates) => super.copyWith((message) => updates(message as CreateMultisigRequest)) as CreateMultisigRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateMultisigRequest create() => CreateMultisigRequest._();
  CreateMultisigRequest createEmptyInstance() => create();
  static $pb.PbList<CreateMultisigRequest> createRepeated() => $pb.PbList<CreateMultisigRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateMultisigRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateMultisigRequest>(create);
  static CreateMultisigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get requiredSigs => $_getIZ(0);
  @$pb.TagNumber(1)
  set requiredSigs($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRequiredSigs() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequiredSigs() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get keys => $_getList(1);
}

class CreateMultisigResponse extends $pb.GeneratedMessage {
  factory CreateMultisigResponse({
    $core.String? address,
    $core.String? redeemScript,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (redeemScript != null) {
      $result.redeemScript = redeemScript;
    }
    return $result;
  }
  CreateMultisigResponse._() : super();
  factory CreateMultisigResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateMultisigResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateMultisigResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'redeemScript')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateMultisigResponse clone() => CreateMultisigResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateMultisigResponse copyWith(void Function(CreateMultisigResponse) updates) => super.copyWith((message) => updates(message as CreateMultisigResponse)) as CreateMultisigResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateMultisigResponse create() => CreateMultisigResponse._();
  CreateMultisigResponse createEmptyInstance() => create();
  static $pb.PbList<CreateMultisigResponse> createRepeated() => $pb.PbList<CreateMultisigResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateMultisigResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateMultisigResponse>(create);
  static CreateMultisigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get redeemScript => $_getSZ(1);
  @$pb.TagNumber(2)
  set redeemScript($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRedeemScript() => $_has(1);
  @$pb.TagNumber(2)
  void clearRedeemScript() => clearField(2);
}

class CreateRawTransactionRequest_Input extends $pb.GeneratedMessage {
  factory CreateRawTransactionRequest_Input({
    $core.String? txid,
    $core.int? vout,
    $core.int? sequence,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (sequence != null) {
      $result.sequence = sequence;
    }
    return $result;
  }
  CreateRawTransactionRequest_Input._() : super();
  factory CreateRawTransactionRequest_Input.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateRawTransactionRequest_Input.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateRawTransactionRequest.Input', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'sequence', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateRawTransactionRequest_Input clone() => CreateRawTransactionRequest_Input()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateRawTransactionRequest_Input copyWith(void Function(CreateRawTransactionRequest_Input) updates) => super.copyWith((message) => updates(message as CreateRawTransactionRequest_Input)) as CreateRawTransactionRequest_Input;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionRequest_Input create() => CreateRawTransactionRequest_Input._();
  CreateRawTransactionRequest_Input createEmptyInstance() => create();
  static $pb.PbList<CreateRawTransactionRequest_Input> createRepeated() => $pb.PbList<CreateRawTransactionRequest_Input>();
  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionRequest_Input getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateRawTransactionRequest_Input>(create);
  static CreateRawTransactionRequest_Input? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get sequence => $_getIZ(2);
  @$pb.TagNumber(3)
  set sequence($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSequence() => $_has(2);
  @$pb.TagNumber(3)
  void clearSequence() => clearField(3);
}

/// Transaction creation messages
class CreateRawTransactionRequest extends $pb.GeneratedMessage {
  factory CreateRawTransactionRequest({
    $core.Iterable<CreateRawTransactionRequest_Input>? inputs,
    $core.Map<$core.String, $core.double>? outputs,
    $core.int? locktime,
  }) {
    final $result = create();
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    if (locktime != null) {
      $result.locktime = locktime;
    }
    return $result;
  }
  CreateRawTransactionRequest._() : super();
  factory CreateRawTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateRawTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateRawTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pc<CreateRawTransactionRequest_Input>(1, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: CreateRawTransactionRequest_Input.create)
    ..m<$core.String, $core.double>(2, _omitFieldNames ? '' : 'outputs', entryClassName: 'CreateRawTransactionRequest.OutputsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OD, packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..a<$core.int>(3, _omitFieldNames ? '' : 'locktime', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateRawTransactionRequest clone() => CreateRawTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateRawTransactionRequest copyWith(void Function(CreateRawTransactionRequest) updates) => super.copyWith((message) => updates(message as CreateRawTransactionRequest)) as CreateRawTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionRequest create() => CreateRawTransactionRequest._();
  CreateRawTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<CreateRawTransactionRequest> createRepeated() => $pb.PbList<CreateRawTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateRawTransactionRequest>(create);
  static CreateRawTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<CreateRawTransactionRequest_Input> get inputs => $_getList(0);

  @$pb.TagNumber(2)
  $core.Map<$core.String, $core.double> get outputs => $_getMap(1);

  @$pb.TagNumber(3)
  $core.int get locktime => $_getIZ(2);
  @$pb.TagNumber(3)
  set locktime($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLocktime() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocktime() => clearField(3);
}

class CreateRawTransactionResponse extends $pb.GeneratedMessage {
  factory CreateRawTransactionResponse({
    RawTransaction? tx,
  }) {
    final $result = create();
    if (tx != null) {
      $result.tx = tx;
    }
    return $result;
  }
  CreateRawTransactionResponse._() : super();
  factory CreateRawTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateRawTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateRawTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOM<RawTransaction>(1, _omitFieldNames ? '' : 'tx', subBuilder: RawTransaction.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateRawTransactionResponse clone() => CreateRawTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateRawTransactionResponse copyWith(void Function(CreateRawTransactionResponse) updates) => super.copyWith((message) => updates(message as CreateRawTransactionResponse)) as CreateRawTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionResponse create() => CreateRawTransactionResponse._();
  CreateRawTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<CreateRawTransactionResponse> createRepeated() => $pb.PbList<CreateRawTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateRawTransactionResponse>(create);
  static CreateRawTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RawTransaction get tx => $_getN(0);
  @$pb.TagNumber(1)
  set tx(RawTransaction v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTx() => $_has(0);
  @$pb.TagNumber(1)
  void clearTx() => clearField(1);
  @$pb.TagNumber(1)
  RawTransaction ensureTx() => $_ensure(0);
}

class CreatePsbtRequest_Input extends $pb.GeneratedMessage {
  factory CreatePsbtRequest_Input({
    $core.String? txid,
    $core.int? vout,
    $core.int? sequence,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (sequence != null) {
      $result.sequence = sequence;
    }
    return $result;
  }
  CreatePsbtRequest_Input._() : super();
  factory CreatePsbtRequest_Input.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreatePsbtRequest_Input.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePsbtRequest.Input', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'sequence', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreatePsbtRequest_Input clone() => CreatePsbtRequest_Input()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreatePsbtRequest_Input copyWith(void Function(CreatePsbtRequest_Input) updates) => super.copyWith((message) => updates(message as CreatePsbtRequest_Input)) as CreatePsbtRequest_Input;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePsbtRequest_Input create() => CreatePsbtRequest_Input._();
  CreatePsbtRequest_Input createEmptyInstance() => create();
  static $pb.PbList<CreatePsbtRequest_Input> createRepeated() => $pb.PbList<CreatePsbtRequest_Input>();
  @$core.pragma('dart2js:noInline')
  static CreatePsbtRequest_Input getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePsbtRequest_Input>(create);
  static CreatePsbtRequest_Input? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get sequence => $_getIZ(2);
  @$pb.TagNumber(3)
  set sequence($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSequence() => $_has(2);
  @$pb.TagNumber(3)
  void clearSequence() => clearField(3);
}

class CreatePsbtRequest extends $pb.GeneratedMessage {
  factory CreatePsbtRequest({
    $core.Iterable<CreatePsbtRequest_Input>? inputs,
    $core.Map<$core.String, $core.double>? outputs,
    $core.int? locktime,
    $core.bool? replaceable,
  }) {
    final $result = create();
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    if (locktime != null) {
      $result.locktime = locktime;
    }
    if (replaceable != null) {
      $result.replaceable = replaceable;
    }
    return $result;
  }
  CreatePsbtRequest._() : super();
  factory CreatePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreatePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pc<CreatePsbtRequest_Input>(1, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: CreatePsbtRequest_Input.create)
    ..m<$core.String, $core.double>(2, _omitFieldNames ? '' : 'outputs', entryClassName: 'CreatePsbtRequest.OutputsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OD, packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..a<$core.int>(3, _omitFieldNames ? '' : 'locktime', $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'replaceable')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreatePsbtRequest clone() => CreatePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreatePsbtRequest copyWith(void Function(CreatePsbtRequest) updates) => super.copyWith((message) => updates(message as CreatePsbtRequest)) as CreatePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePsbtRequest create() => CreatePsbtRequest._();
  CreatePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<CreatePsbtRequest> createRepeated() => $pb.PbList<CreatePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static CreatePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePsbtRequest>(create);
  static CreatePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<CreatePsbtRequest_Input> get inputs => $_getList(0);

  @$pb.TagNumber(2)
  $core.Map<$core.String, $core.double> get outputs => $_getMap(1);

  @$pb.TagNumber(3)
  $core.int get locktime => $_getIZ(2);
  @$pb.TagNumber(3)
  set locktime($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLocktime() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocktime() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get replaceable => $_getBF(3);
  @$pb.TagNumber(4)
  set replaceable($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasReplaceable() => $_has(3);
  @$pb.TagNumber(4)
  void clearReplaceable() => clearField(4);
}

class CreatePsbtResponse extends $pb.GeneratedMessage {
  factory CreatePsbtResponse({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  CreatePsbtResponse._() : super();
  factory CreatePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreatePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreatePsbtResponse clone() => CreatePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreatePsbtResponse copyWith(void Function(CreatePsbtResponse) updates) => super.copyWith((message) => updates(message as CreatePsbtResponse)) as CreatePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePsbtResponse create() => CreatePsbtResponse._();
  CreatePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<CreatePsbtResponse> createRepeated() => $pb.PbList<CreatePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static CreatePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePsbtResponse>(create);
  static CreatePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class DecodePsbtRequest extends $pb.GeneratedMessage {
  factory DecodePsbtRequest({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  DecodePsbtRequest._() : super();
  factory DecodePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtRequest clone() => DecodePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtRequest copyWith(void Function(DecodePsbtRequest) updates) => super.copyWith((message) => updates(message as DecodePsbtRequest)) as DecodePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtRequest create() => DecodePsbtRequest._();
  DecodePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtRequest> createRepeated() => $pb.PbList<DecodePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtRequest>(create);
  static DecodePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class DecodePsbtResponse_WitnessUtxo extends $pb.GeneratedMessage {
  factory DecodePsbtResponse_WitnessUtxo({
    $core.double? amount,
    ScriptPubKey? scriptPubKey,
  }) {
    final $result = create();
    if (amount != null) {
      $result.amount = amount;
    }
    if (scriptPubKey != null) {
      $result.scriptPubKey = scriptPubKey;
    }
    return $result;
  }
  DecodePsbtResponse_WitnessUtxo._() : super();
  factory DecodePsbtResponse_WitnessUtxo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtResponse_WitnessUtxo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse.WitnessUtxo', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..aOM<ScriptPubKey>(2, _omitFieldNames ? '' : 'scriptPubKey', subBuilder: ScriptPubKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_WitnessUtxo clone() => DecodePsbtResponse_WitnessUtxo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_WitnessUtxo copyWith(void Function(DecodePsbtResponse_WitnessUtxo) updates) => super.copyWith((message) => updates(message as DecodePsbtResponse_WitnessUtxo)) as DecodePsbtResponse_WitnessUtxo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_WitnessUtxo create() => DecodePsbtResponse_WitnessUtxo._();
  DecodePsbtResponse_WitnessUtxo createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtResponse_WitnessUtxo> createRepeated() => $pb.PbList<DecodePsbtResponse_WitnessUtxo>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_WitnessUtxo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse_WitnessUtxo>(create);
  static DecodePsbtResponse_WitnessUtxo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get amount => $_getN(0);
  @$pb.TagNumber(1)
  set amount($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAmount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAmount() => clearField(1);

  @$pb.TagNumber(2)
  ScriptPubKey get scriptPubKey => $_getN(1);
  @$pb.TagNumber(2)
  set scriptPubKey(ScriptPubKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasScriptPubKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearScriptPubKey() => clearField(2);
  @$pb.TagNumber(2)
  ScriptPubKey ensureScriptPubKey() => $_ensure(1);
}

class DecodePsbtResponse_RedeemScript extends $pb.GeneratedMessage {
  factory DecodePsbtResponse_RedeemScript({
    $core.String? asm,
    $core.String? hex,
    $core.String? type,
  }) {
    final $result = create();
    if (asm != null) {
      $result.asm = asm;
    }
    if (hex != null) {
      $result.hex = hex;
    }
    if (type != null) {
      $result.type = type;
    }
    return $result;
  }
  DecodePsbtResponse_RedeemScript._() : super();
  factory DecodePsbtResponse_RedeemScript.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtResponse_RedeemScript.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse.RedeemScript', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'asm')
    ..aOS(2, _omitFieldNames ? '' : 'hex')
    ..aOS(3, _omitFieldNames ? '' : 'type')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_RedeemScript clone() => DecodePsbtResponse_RedeemScript()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_RedeemScript copyWith(void Function(DecodePsbtResponse_RedeemScript) updates) => super.copyWith((message) => updates(message as DecodePsbtResponse_RedeemScript)) as DecodePsbtResponse_RedeemScript;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_RedeemScript create() => DecodePsbtResponse_RedeemScript._();
  DecodePsbtResponse_RedeemScript createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtResponse_RedeemScript> createRepeated() => $pb.PbList<DecodePsbtResponse_RedeemScript>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_RedeemScript getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse_RedeemScript>(create);
  static DecodePsbtResponse_RedeemScript? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get asm => $_getSZ(0);
  @$pb.TagNumber(1)
  set asm($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAsm() => $_has(0);
  @$pb.TagNumber(1)
  void clearAsm() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get hex => $_getSZ(1);
  @$pb.TagNumber(2)
  set hex($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearHex() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => clearField(3);
}

class DecodePsbtResponse_Bip32Deriv extends $pb.GeneratedMessage {
  factory DecodePsbtResponse_Bip32Deriv({
    $core.String? pubkey,
    $core.String? masterFingerprint,
    $core.String? path,
  }) {
    final $result = create();
    if (pubkey != null) {
      $result.pubkey = pubkey;
    }
    if (masterFingerprint != null) {
      $result.masterFingerprint = masterFingerprint;
    }
    if (path != null) {
      $result.path = path;
    }
    return $result;
  }
  DecodePsbtResponse_Bip32Deriv._() : super();
  factory DecodePsbtResponse_Bip32Deriv.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtResponse_Bip32Deriv.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse.Bip32Deriv', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pubkey')
    ..aOS(2, _omitFieldNames ? '' : 'masterFingerprint')
    ..aOS(3, _omitFieldNames ? '' : 'path')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_Bip32Deriv clone() => DecodePsbtResponse_Bip32Deriv()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_Bip32Deriv copyWith(void Function(DecodePsbtResponse_Bip32Deriv) updates) => super.copyWith((message) => updates(message as DecodePsbtResponse_Bip32Deriv)) as DecodePsbtResponse_Bip32Deriv;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_Bip32Deriv create() => DecodePsbtResponse_Bip32Deriv._();
  DecodePsbtResponse_Bip32Deriv createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtResponse_Bip32Deriv> createRepeated() => $pb.PbList<DecodePsbtResponse_Bip32Deriv>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_Bip32Deriv getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse_Bip32Deriv>(create);
  static DecodePsbtResponse_Bip32Deriv? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pubkey => $_getSZ(0);
  @$pb.TagNumber(1)
  set pubkey($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPubkey() => $_has(0);
  @$pb.TagNumber(1)
  void clearPubkey() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get masterFingerprint => $_getSZ(1);
  @$pb.TagNumber(2)
  set masterFingerprint($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMasterFingerprint() => $_has(1);
  @$pb.TagNumber(2)
  void clearMasterFingerprint() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get path => $_getSZ(2);
  @$pb.TagNumber(3)
  set path($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearPath() => clearField(3);
}

class DecodePsbtResponse_Input extends $pb.GeneratedMessage {
  factory DecodePsbtResponse_Input({
    DecodeRawTransactionResponse? nonWitnessUtxo,
    DecodePsbtResponse_WitnessUtxo? witnessUtxo,
    $core.Map<$core.String, $core.String>? partialSignatures,
    $core.String? sighash,
    DecodePsbtResponse_RedeemScript? redeemScript,
    DecodePsbtResponse_RedeemScript? witnessScript,
    $core.Iterable<DecodePsbtResponse_Bip32Deriv>? bip32Derivs,
    ScriptSig? finalScriptsig,
    $core.Iterable<$core.String>? finalScriptwitness,
    $core.Map<$core.String, $core.String>? unknown,
  }) {
    final $result = create();
    if (nonWitnessUtxo != null) {
      $result.nonWitnessUtxo = nonWitnessUtxo;
    }
    if (witnessUtxo != null) {
      $result.witnessUtxo = witnessUtxo;
    }
    if (partialSignatures != null) {
      $result.partialSignatures.addAll(partialSignatures);
    }
    if (sighash != null) {
      $result.sighash = sighash;
    }
    if (redeemScript != null) {
      $result.redeemScript = redeemScript;
    }
    if (witnessScript != null) {
      $result.witnessScript = witnessScript;
    }
    if (bip32Derivs != null) {
      $result.bip32Derivs.addAll(bip32Derivs);
    }
    if (finalScriptsig != null) {
      $result.finalScriptsig = finalScriptsig;
    }
    if (finalScriptwitness != null) {
      $result.finalScriptwitness.addAll(finalScriptwitness);
    }
    if (unknown != null) {
      $result.unknown.addAll(unknown);
    }
    return $result;
  }
  DecodePsbtResponse_Input._() : super();
  factory DecodePsbtResponse_Input.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtResponse_Input.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse.Input', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOM<DecodeRawTransactionResponse>(1, _omitFieldNames ? '' : 'nonWitnessUtxo', subBuilder: DecodeRawTransactionResponse.create)
    ..aOM<DecodePsbtResponse_WitnessUtxo>(2, _omitFieldNames ? '' : 'witnessUtxo', subBuilder: DecodePsbtResponse_WitnessUtxo.create)
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'partialSignatures', entryClassName: 'DecodePsbtResponse.Input.PartialSignaturesEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..aOS(4, _omitFieldNames ? '' : 'sighash')
    ..aOM<DecodePsbtResponse_RedeemScript>(5, _omitFieldNames ? '' : 'redeemScript', subBuilder: DecodePsbtResponse_RedeemScript.create)
    ..aOM<DecodePsbtResponse_RedeemScript>(6, _omitFieldNames ? '' : 'witnessScript', subBuilder: DecodePsbtResponse_RedeemScript.create)
    ..pc<DecodePsbtResponse_Bip32Deriv>(7, _omitFieldNames ? '' : 'bip32Derivs', $pb.PbFieldType.PM, subBuilder: DecodePsbtResponse_Bip32Deriv.create)
    ..aOM<ScriptSig>(8, _omitFieldNames ? '' : 'finalScriptsig', subBuilder: ScriptSig.create)
    ..pPS(9, _omitFieldNames ? '' : 'finalScriptwitness')
    ..m<$core.String, $core.String>(10, _omitFieldNames ? '' : 'unknown', entryClassName: 'DecodePsbtResponse.Input.UnknownEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_Input clone() => DecodePsbtResponse_Input()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_Input copyWith(void Function(DecodePsbtResponse_Input) updates) => super.copyWith((message) => updates(message as DecodePsbtResponse_Input)) as DecodePsbtResponse_Input;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_Input create() => DecodePsbtResponse_Input._();
  DecodePsbtResponse_Input createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtResponse_Input> createRepeated() => $pb.PbList<DecodePsbtResponse_Input>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_Input getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse_Input>(create);
  static DecodePsbtResponse_Input? _defaultInstance;

  @$pb.TagNumber(1)
  DecodeRawTransactionResponse get nonWitnessUtxo => $_getN(0);
  @$pb.TagNumber(1)
  set nonWitnessUtxo(DecodeRawTransactionResponse v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasNonWitnessUtxo() => $_has(0);
  @$pb.TagNumber(1)
  void clearNonWitnessUtxo() => clearField(1);
  @$pb.TagNumber(1)
  DecodeRawTransactionResponse ensureNonWitnessUtxo() => $_ensure(0);

  @$pb.TagNumber(2)
  DecodePsbtResponse_WitnessUtxo get witnessUtxo => $_getN(1);
  @$pb.TagNumber(2)
  set witnessUtxo(DecodePsbtResponse_WitnessUtxo v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasWitnessUtxo() => $_has(1);
  @$pb.TagNumber(2)
  void clearWitnessUtxo() => clearField(2);
  @$pb.TagNumber(2)
  DecodePsbtResponse_WitnessUtxo ensureWitnessUtxo() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.Map<$core.String, $core.String> get partialSignatures => $_getMap(2);

  @$pb.TagNumber(4)
  $core.String get sighash => $_getSZ(3);
  @$pb.TagNumber(4)
  set sighash($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSighash() => $_has(3);
  @$pb.TagNumber(4)
  void clearSighash() => clearField(4);

  @$pb.TagNumber(5)
  DecodePsbtResponse_RedeemScript get redeemScript => $_getN(4);
  @$pb.TagNumber(5)
  set redeemScript(DecodePsbtResponse_RedeemScript v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasRedeemScript() => $_has(4);
  @$pb.TagNumber(5)
  void clearRedeemScript() => clearField(5);
  @$pb.TagNumber(5)
  DecodePsbtResponse_RedeemScript ensureRedeemScript() => $_ensure(4);

  @$pb.TagNumber(6)
  DecodePsbtResponse_RedeemScript get witnessScript => $_getN(5);
  @$pb.TagNumber(6)
  set witnessScript(DecodePsbtResponse_RedeemScript v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasWitnessScript() => $_has(5);
  @$pb.TagNumber(6)
  void clearWitnessScript() => clearField(6);
  @$pb.TagNumber(6)
  DecodePsbtResponse_RedeemScript ensureWitnessScript() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.List<DecodePsbtResponse_Bip32Deriv> get bip32Derivs => $_getList(6);

  @$pb.TagNumber(8)
  ScriptSig get finalScriptsig => $_getN(7);
  @$pb.TagNumber(8)
  set finalScriptsig(ScriptSig v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasFinalScriptsig() => $_has(7);
  @$pb.TagNumber(8)
  void clearFinalScriptsig() => clearField(8);
  @$pb.TagNumber(8)
  ScriptSig ensureFinalScriptsig() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.List<$core.String> get finalScriptwitness => $_getList(8);

  @$pb.TagNumber(10)
  $core.Map<$core.String, $core.String> get unknown => $_getMap(9);
}

class DecodePsbtResponse_Output extends $pb.GeneratedMessage {
  factory DecodePsbtResponse_Output({
    DecodePsbtResponse_RedeemScript? redeemScript,
    DecodePsbtResponse_RedeemScript? witnessScript,
    $core.Iterable<DecodePsbtResponse_Bip32Deriv>? bip32Derivs,
    $core.Map<$core.String, $core.String>? unknown,
  }) {
    final $result = create();
    if (redeemScript != null) {
      $result.redeemScript = redeemScript;
    }
    if (witnessScript != null) {
      $result.witnessScript = witnessScript;
    }
    if (bip32Derivs != null) {
      $result.bip32Derivs.addAll(bip32Derivs);
    }
    if (unknown != null) {
      $result.unknown.addAll(unknown);
    }
    return $result;
  }
  DecodePsbtResponse_Output._() : super();
  factory DecodePsbtResponse_Output.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtResponse_Output.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse.Output', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOM<DecodePsbtResponse_RedeemScript>(1, _omitFieldNames ? '' : 'redeemScript', subBuilder: DecodePsbtResponse_RedeemScript.create)
    ..aOM<DecodePsbtResponse_RedeemScript>(2, _omitFieldNames ? '' : 'witnessScript', subBuilder: DecodePsbtResponse_RedeemScript.create)
    ..pc<DecodePsbtResponse_Bip32Deriv>(3, _omitFieldNames ? '' : 'bip32Derivs', $pb.PbFieldType.PM, subBuilder: DecodePsbtResponse_Bip32Deriv.create)
    ..m<$core.String, $core.String>(4, _omitFieldNames ? '' : 'unknown', entryClassName: 'DecodePsbtResponse.Output.UnknownEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_Output clone() => DecodePsbtResponse_Output()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_Output copyWith(void Function(DecodePsbtResponse_Output) updates) => super.copyWith((message) => updates(message as DecodePsbtResponse_Output)) as DecodePsbtResponse_Output;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_Output create() => DecodePsbtResponse_Output._();
  DecodePsbtResponse_Output createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtResponse_Output> createRepeated() => $pb.PbList<DecodePsbtResponse_Output>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_Output getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse_Output>(create);
  static DecodePsbtResponse_Output? _defaultInstance;

  @$pb.TagNumber(1)
  DecodePsbtResponse_RedeemScript get redeemScript => $_getN(0);
  @$pb.TagNumber(1)
  set redeemScript(DecodePsbtResponse_RedeemScript v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasRedeemScript() => $_has(0);
  @$pb.TagNumber(1)
  void clearRedeemScript() => clearField(1);
  @$pb.TagNumber(1)
  DecodePsbtResponse_RedeemScript ensureRedeemScript() => $_ensure(0);

  @$pb.TagNumber(2)
  DecodePsbtResponse_RedeemScript get witnessScript => $_getN(1);
  @$pb.TagNumber(2)
  set witnessScript(DecodePsbtResponse_RedeemScript v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasWitnessScript() => $_has(1);
  @$pb.TagNumber(2)
  void clearWitnessScript() => clearField(2);
  @$pb.TagNumber(2)
  DecodePsbtResponse_RedeemScript ensureWitnessScript() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.List<DecodePsbtResponse_Bip32Deriv> get bip32Derivs => $_getList(2);

  @$pb.TagNumber(4)
  $core.Map<$core.String, $core.String> get unknown => $_getMap(3);
}

class DecodePsbtResponse extends $pb.GeneratedMessage {
  factory DecodePsbtResponse({
    DecodeRawTransactionResponse? tx,
    $core.Map<$core.String, $core.String>? unknown,
    $core.Iterable<DecodePsbtResponse_Input>? inputs,
    $core.Iterable<DecodePsbtResponse_Output>? outputs,
    $core.double? fee,
  }) {
    final $result = create();
    if (tx != null) {
      $result.tx = tx;
    }
    if (unknown != null) {
      $result.unknown.addAll(unknown);
    }
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    if (fee != null) {
      $result.fee = fee;
    }
    return $result;
  }
  DecodePsbtResponse._() : super();
  factory DecodePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOM<DecodeRawTransactionResponse>(1, _omitFieldNames ? '' : 'tx', subBuilder: DecodeRawTransactionResponse.create)
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'unknown', entryClassName: 'DecodePsbtResponse.UnknownEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..pc<DecodePsbtResponse_Input>(3, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: DecodePsbtResponse_Input.create)
    ..pc<DecodePsbtResponse_Output>(4, _omitFieldNames ? '' : 'outputs', $pb.PbFieldType.PM, subBuilder: DecodePsbtResponse_Output.create)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'fee', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse clone() => DecodePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse copyWith(void Function(DecodePsbtResponse) updates) => super.copyWith((message) => updates(message as DecodePsbtResponse)) as DecodePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse create() => DecodePsbtResponse._();
  DecodePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtResponse> createRepeated() => $pb.PbList<DecodePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse>(create);
  static DecodePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DecodeRawTransactionResponse get tx => $_getN(0);
  @$pb.TagNumber(1)
  set tx(DecodeRawTransactionResponse v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTx() => $_has(0);
  @$pb.TagNumber(1)
  void clearTx() => clearField(1);
  @$pb.TagNumber(1)
  DecodeRawTransactionResponse ensureTx() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.Map<$core.String, $core.String> get unknown => $_getMap(1);

  @$pb.TagNumber(3)
  $core.List<DecodePsbtResponse_Input> get inputs => $_getList(2);

  @$pb.TagNumber(4)
  $core.List<DecodePsbtResponse_Output> get outputs => $_getList(3);

  @$pb.TagNumber(5)
  $core.double get fee => $_getN(4);
  @$pb.TagNumber(5)
  set fee($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFee() => $_has(4);
  @$pb.TagNumber(5)
  void clearFee() => clearField(5);
}

class AnalyzePsbtRequest extends $pb.GeneratedMessage {
  factory AnalyzePsbtRequest({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  AnalyzePsbtRequest._() : super();
  factory AnalyzePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AnalyzePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnalyzePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AnalyzePsbtRequest clone() => AnalyzePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AnalyzePsbtRequest copyWith(void Function(AnalyzePsbtRequest) updates) => super.copyWith((message) => updates(message as AnalyzePsbtRequest)) as AnalyzePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtRequest create() => AnalyzePsbtRequest._();
  AnalyzePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<AnalyzePsbtRequest> createRepeated() => $pb.PbList<AnalyzePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnalyzePsbtRequest>(create);
  static AnalyzePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class AnalyzePsbtResponse_Input_Missing extends $pb.GeneratedMessage {
  factory AnalyzePsbtResponse_Input_Missing({
    $core.Iterable<$core.String>? pubkeys,
    $core.Iterable<$core.String>? signatures,
    $core.String? redeemScript,
    $core.String? witnessScript,
  }) {
    final $result = create();
    if (pubkeys != null) {
      $result.pubkeys.addAll(pubkeys);
    }
    if (signatures != null) {
      $result.signatures.addAll(signatures);
    }
    if (redeemScript != null) {
      $result.redeemScript = redeemScript;
    }
    if (witnessScript != null) {
      $result.witnessScript = witnessScript;
    }
    return $result;
  }
  AnalyzePsbtResponse_Input_Missing._() : super();
  factory AnalyzePsbtResponse_Input_Missing.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AnalyzePsbtResponse_Input_Missing.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnalyzePsbtResponse.Input.Missing', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'pubkeys')
    ..pPS(2, _omitFieldNames ? '' : 'signatures')
    ..aOS(3, _omitFieldNames ? '' : 'redeemScript')
    ..aOS(4, _omitFieldNames ? '' : 'witnessScript')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AnalyzePsbtResponse_Input_Missing clone() => AnalyzePsbtResponse_Input_Missing()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AnalyzePsbtResponse_Input_Missing copyWith(void Function(AnalyzePsbtResponse_Input_Missing) updates) => super.copyWith((message) => updates(message as AnalyzePsbtResponse_Input_Missing)) as AnalyzePsbtResponse_Input_Missing;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse_Input_Missing create() => AnalyzePsbtResponse_Input_Missing._();
  AnalyzePsbtResponse_Input_Missing createEmptyInstance() => create();
  static $pb.PbList<AnalyzePsbtResponse_Input_Missing> createRepeated() => $pb.PbList<AnalyzePsbtResponse_Input_Missing>();
  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse_Input_Missing getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnalyzePsbtResponse_Input_Missing>(create);
  static AnalyzePsbtResponse_Input_Missing? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get pubkeys => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$core.String> get signatures => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get redeemScript => $_getSZ(2);
  @$pb.TagNumber(3)
  set redeemScript($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRedeemScript() => $_has(2);
  @$pb.TagNumber(3)
  void clearRedeemScript() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get witnessScript => $_getSZ(3);
  @$pb.TagNumber(4)
  set witnessScript($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWitnessScript() => $_has(3);
  @$pb.TagNumber(4)
  void clearWitnessScript() => clearField(4);
}

class AnalyzePsbtResponse_Input extends $pb.GeneratedMessage {
  factory AnalyzePsbtResponse_Input({
    $core.bool? hasUtxo,
    $core.bool? isFinal,
    AnalyzePsbtResponse_Input_Missing? missing,
    $core.String? next,
  }) {
    final $result = create();
    if (hasUtxo != null) {
      $result.hasUtxo = hasUtxo;
    }
    if (isFinal != null) {
      $result.isFinal = isFinal;
    }
    if (missing != null) {
      $result.missing = missing;
    }
    if (next != null) {
      $result.next = next;
    }
    return $result;
  }
  AnalyzePsbtResponse_Input._() : super();
  factory AnalyzePsbtResponse_Input.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AnalyzePsbtResponse_Input.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnalyzePsbtResponse.Input', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'hasUtxo')
    ..aOB(2, _omitFieldNames ? '' : 'isFinal')
    ..aOM<AnalyzePsbtResponse_Input_Missing>(3, _omitFieldNames ? '' : 'missing', subBuilder: AnalyzePsbtResponse_Input_Missing.create)
    ..aOS(4, _omitFieldNames ? '' : 'next')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AnalyzePsbtResponse_Input clone() => AnalyzePsbtResponse_Input()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AnalyzePsbtResponse_Input copyWith(void Function(AnalyzePsbtResponse_Input) updates) => super.copyWith((message) => updates(message as AnalyzePsbtResponse_Input)) as AnalyzePsbtResponse_Input;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse_Input create() => AnalyzePsbtResponse_Input._();
  AnalyzePsbtResponse_Input createEmptyInstance() => create();
  static $pb.PbList<AnalyzePsbtResponse_Input> createRepeated() => $pb.PbList<AnalyzePsbtResponse_Input>();
  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse_Input getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnalyzePsbtResponse_Input>(create);
  static AnalyzePsbtResponse_Input? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get hasUtxo => $_getBF(0);
  @$pb.TagNumber(1)
  set hasUtxo($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHasUtxo() => $_has(0);
  @$pb.TagNumber(1)
  void clearHasUtxo() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isFinal => $_getBF(1);
  @$pb.TagNumber(2)
  set isFinal($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIsFinal() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsFinal() => clearField(2);

  @$pb.TagNumber(3)
  AnalyzePsbtResponse_Input_Missing get missing => $_getN(2);
  @$pb.TagNumber(3)
  set missing(AnalyzePsbtResponse_Input_Missing v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasMissing() => $_has(2);
  @$pb.TagNumber(3)
  void clearMissing() => clearField(3);
  @$pb.TagNumber(3)
  AnalyzePsbtResponse_Input_Missing ensureMissing() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get next => $_getSZ(3);
  @$pb.TagNumber(4)
  set next($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNext() => $_has(3);
  @$pb.TagNumber(4)
  void clearNext() => clearField(4);
}

class AnalyzePsbtResponse extends $pb.GeneratedMessage {
  factory AnalyzePsbtResponse({
    $core.Iterable<AnalyzePsbtResponse_Input>? inputs,
    $core.double? estimatedVsize,
    $core.double? estimatedFeerate,
    $core.double? fee,
    $core.String? next,
    $core.String? error,
  }) {
    final $result = create();
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (estimatedVsize != null) {
      $result.estimatedVsize = estimatedVsize;
    }
    if (estimatedFeerate != null) {
      $result.estimatedFeerate = estimatedFeerate;
    }
    if (fee != null) {
      $result.fee = fee;
    }
    if (next != null) {
      $result.next = next;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  AnalyzePsbtResponse._() : super();
  factory AnalyzePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AnalyzePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnalyzePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pc<AnalyzePsbtResponse_Input>(1, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: AnalyzePsbtResponse_Input.create)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'estimatedVsize', $pb.PbFieldType.OD)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'estimatedFeerate', $pb.PbFieldType.OD)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'fee', $pb.PbFieldType.OD)
    ..aOS(5, _omitFieldNames ? '' : 'next')
    ..aOS(6, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AnalyzePsbtResponse clone() => AnalyzePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AnalyzePsbtResponse copyWith(void Function(AnalyzePsbtResponse) updates) => super.copyWith((message) => updates(message as AnalyzePsbtResponse)) as AnalyzePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse create() => AnalyzePsbtResponse._();
  AnalyzePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<AnalyzePsbtResponse> createRepeated() => $pb.PbList<AnalyzePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnalyzePsbtResponse>(create);
  static AnalyzePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<AnalyzePsbtResponse_Input> get inputs => $_getList(0);

  @$pb.TagNumber(2)
  $core.double get estimatedVsize => $_getN(1);
  @$pb.TagNumber(2)
  set estimatedVsize($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEstimatedVsize() => $_has(1);
  @$pb.TagNumber(2)
  void clearEstimatedVsize() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get estimatedFeerate => $_getN(2);
  @$pb.TagNumber(3)
  set estimatedFeerate($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEstimatedFeerate() => $_has(2);
  @$pb.TagNumber(3)
  void clearEstimatedFeerate() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get fee => $_getN(3);
  @$pb.TagNumber(4)
  set fee($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFee() => $_has(3);
  @$pb.TagNumber(4)
  void clearFee() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get next => $_getSZ(4);
  @$pb.TagNumber(5)
  set next($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasNext() => $_has(4);
  @$pb.TagNumber(5)
  void clearNext() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get error => $_getSZ(5);
  @$pb.TagNumber(6)
  set error($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasError() => $_has(5);
  @$pb.TagNumber(6)
  void clearError() => clearField(6);
}

class CombinePsbtRequest extends $pb.GeneratedMessage {
  factory CombinePsbtRequest({
    $core.Iterable<$core.String>? psbts,
  }) {
    final $result = create();
    if (psbts != null) {
      $result.psbts.addAll(psbts);
    }
    return $result;
  }
  CombinePsbtRequest._() : super();
  factory CombinePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CombinePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CombinePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'psbts')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CombinePsbtRequest clone() => CombinePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CombinePsbtRequest copyWith(void Function(CombinePsbtRequest) updates) => super.copyWith((message) => updates(message as CombinePsbtRequest)) as CombinePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CombinePsbtRequest create() => CombinePsbtRequest._();
  CombinePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<CombinePsbtRequest> createRepeated() => $pb.PbList<CombinePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static CombinePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CombinePsbtRequest>(create);
  static CombinePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get psbts => $_getList(0);
}

class CombinePsbtResponse extends $pb.GeneratedMessage {
  factory CombinePsbtResponse({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  CombinePsbtResponse._() : super();
  factory CombinePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CombinePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CombinePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CombinePsbtResponse clone() => CombinePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CombinePsbtResponse copyWith(void Function(CombinePsbtResponse) updates) => super.copyWith((message) => updates(message as CombinePsbtResponse)) as CombinePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CombinePsbtResponse create() => CombinePsbtResponse._();
  CombinePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<CombinePsbtResponse> createRepeated() => $pb.PbList<CombinePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static CombinePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CombinePsbtResponse>(create);
  static CombinePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class UtxoUpdatePsbtRequest extends $pb.GeneratedMessage {
  factory UtxoUpdatePsbtRequest({
    $core.String? psbt,
    $core.Iterable<Descriptor>? descriptors,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    if (descriptors != null) {
      $result.descriptors.addAll(descriptors);
    }
    return $result;
  }
  UtxoUpdatePsbtRequest._() : super();
  factory UtxoUpdatePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UtxoUpdatePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UtxoUpdatePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..pc<Descriptor>(2, _omitFieldNames ? '' : 'descriptors', $pb.PbFieldType.PM, subBuilder: Descriptor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UtxoUpdatePsbtRequest clone() => UtxoUpdatePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UtxoUpdatePsbtRequest copyWith(void Function(UtxoUpdatePsbtRequest) updates) => super.copyWith((message) => updates(message as UtxoUpdatePsbtRequest)) as UtxoUpdatePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UtxoUpdatePsbtRequest create() => UtxoUpdatePsbtRequest._();
  UtxoUpdatePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<UtxoUpdatePsbtRequest> createRepeated() => $pb.PbList<UtxoUpdatePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static UtxoUpdatePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UtxoUpdatePsbtRequest>(create);
  static UtxoUpdatePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<Descriptor> get descriptors => $_getList(1);
}

class UtxoUpdatePsbtResponse extends $pb.GeneratedMessage {
  factory UtxoUpdatePsbtResponse({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  UtxoUpdatePsbtResponse._() : super();
  factory UtxoUpdatePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UtxoUpdatePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UtxoUpdatePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UtxoUpdatePsbtResponse clone() => UtxoUpdatePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UtxoUpdatePsbtResponse copyWith(void Function(UtxoUpdatePsbtResponse) updates) => super.copyWith((message) => updates(message as UtxoUpdatePsbtResponse)) as UtxoUpdatePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UtxoUpdatePsbtResponse create() => UtxoUpdatePsbtResponse._();
  UtxoUpdatePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<UtxoUpdatePsbtResponse> createRepeated() => $pb.PbList<UtxoUpdatePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static UtxoUpdatePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UtxoUpdatePsbtResponse>(create);
  static UtxoUpdatePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class JoinPsbtsRequest extends $pb.GeneratedMessage {
  factory JoinPsbtsRequest({
    $core.Iterable<$core.String>? psbts,
  }) {
    final $result = create();
    if (psbts != null) {
      $result.psbts.addAll(psbts);
    }
    return $result;
  }
  JoinPsbtsRequest._() : super();
  factory JoinPsbtsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory JoinPsbtsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinPsbtsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'psbts')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  JoinPsbtsRequest clone() => JoinPsbtsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  JoinPsbtsRequest copyWith(void Function(JoinPsbtsRequest) updates) => super.copyWith((message) => updates(message as JoinPsbtsRequest)) as JoinPsbtsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinPsbtsRequest create() => JoinPsbtsRequest._();
  JoinPsbtsRequest createEmptyInstance() => create();
  static $pb.PbList<JoinPsbtsRequest> createRepeated() => $pb.PbList<JoinPsbtsRequest>();
  @$core.pragma('dart2js:noInline')
  static JoinPsbtsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinPsbtsRequest>(create);
  static JoinPsbtsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get psbts => $_getList(0);
}

class JoinPsbtsResponse extends $pb.GeneratedMessage {
  factory JoinPsbtsResponse({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  JoinPsbtsResponse._() : super();
  factory JoinPsbtsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory JoinPsbtsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinPsbtsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  JoinPsbtsResponse clone() => JoinPsbtsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  JoinPsbtsResponse copyWith(void Function(JoinPsbtsResponse) updates) => super.copyWith((message) => updates(message as JoinPsbtsResponse)) as JoinPsbtsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinPsbtsResponse create() => JoinPsbtsResponse._();
  JoinPsbtsResponse createEmptyInstance() => create();
  static $pb.PbList<JoinPsbtsResponse> createRepeated() => $pb.PbList<JoinPsbtsResponse>();
  @$core.pragma('dart2js:noInline')
  static JoinPsbtsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinPsbtsResponse>(create);
  static JoinPsbtsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class TestMempoolAcceptRequest extends $pb.GeneratedMessage {
  factory TestMempoolAcceptRequest({
    $core.Iterable<$core.String>? rawtxs,
    $core.double? maxFeeRate,
  }) {
    final $result = create();
    if (rawtxs != null) {
      $result.rawtxs.addAll(rawtxs);
    }
    if (maxFeeRate != null) {
      $result.maxFeeRate = maxFeeRate;
    }
    return $result;
  }
  TestMempoolAcceptRequest._() : super();
  factory TestMempoolAcceptRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TestMempoolAcceptRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TestMempoolAcceptRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'rawtxs')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'maxFeeRate', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptRequest clone() => TestMempoolAcceptRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptRequest copyWith(void Function(TestMempoolAcceptRequest) updates) => super.copyWith((message) => updates(message as TestMempoolAcceptRequest)) as TestMempoolAcceptRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptRequest create() => TestMempoolAcceptRequest._();
  TestMempoolAcceptRequest createEmptyInstance() => create();
  static $pb.PbList<TestMempoolAcceptRequest> createRepeated() => $pb.PbList<TestMempoolAcceptRequest>();
  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TestMempoolAcceptRequest>(create);
  static TestMempoolAcceptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get rawtxs => $_getList(0);

  @$pb.TagNumber(2)
  $core.double get maxFeeRate => $_getN(1);
  @$pb.TagNumber(2)
  set maxFeeRate($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMaxFeeRate() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxFeeRate() => clearField(2);
}

class TestMempoolAcceptResponse_Result extends $pb.GeneratedMessage {
  factory TestMempoolAcceptResponse_Result({
    $core.String? txid,
    $core.bool? allowed,
    $core.String? rejectReason,
    $core.int? vsize,
    $core.double? fees,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (allowed != null) {
      $result.allowed = allowed;
    }
    if (rejectReason != null) {
      $result.rejectReason = rejectReason;
    }
    if (vsize != null) {
      $result.vsize = vsize;
    }
    if (fees != null) {
      $result.fees = fees;
    }
    return $result;
  }
  TestMempoolAcceptResponse_Result._() : super();
  factory TestMempoolAcceptResponse_Result.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TestMempoolAcceptResponse_Result.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TestMempoolAcceptResponse.Result', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOB(2, _omitFieldNames ? '' : 'allowed')
    ..aOS(3, _omitFieldNames ? '' : 'rejectReason')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'vsize', $pb.PbFieldType.OU3)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'fees', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptResponse_Result clone() => TestMempoolAcceptResponse_Result()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptResponse_Result copyWith(void Function(TestMempoolAcceptResponse_Result) updates) => super.copyWith((message) => updates(message as TestMempoolAcceptResponse_Result)) as TestMempoolAcceptResponse_Result;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptResponse_Result create() => TestMempoolAcceptResponse_Result._();
  TestMempoolAcceptResponse_Result createEmptyInstance() => create();
  static $pb.PbList<TestMempoolAcceptResponse_Result> createRepeated() => $pb.PbList<TestMempoolAcceptResponse_Result>();
  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptResponse_Result getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TestMempoolAcceptResponse_Result>(create);
  static TestMempoolAcceptResponse_Result? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get allowed => $_getBF(1);
  @$pb.TagNumber(2)
  set allowed($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAllowed() => $_has(1);
  @$pb.TagNumber(2)
  void clearAllowed() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get rejectReason => $_getSZ(2);
  @$pb.TagNumber(3)
  set rejectReason($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRejectReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearRejectReason() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get vsize => $_getIZ(3);
  @$pb.TagNumber(4)
  set vsize($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVsize() => $_has(3);
  @$pb.TagNumber(4)
  void clearVsize() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get fees => $_getN(4);
  @$pb.TagNumber(5)
  set fees($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFees() => $_has(4);
  @$pb.TagNumber(5)
  void clearFees() => clearField(5);
}

class TestMempoolAcceptResponse extends $pb.GeneratedMessage {
  factory TestMempoolAcceptResponse({
    $core.Iterable<TestMempoolAcceptResponse_Result>? results,
  }) {
    final $result = create();
    if (results != null) {
      $result.results.addAll(results);
    }
    return $result;
  }
  TestMempoolAcceptResponse._() : super();
  factory TestMempoolAcceptResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TestMempoolAcceptResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TestMempoolAcceptResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pc<TestMempoolAcceptResponse_Result>(1, _omitFieldNames ? '' : 'results', $pb.PbFieldType.PM, subBuilder: TestMempoolAcceptResponse_Result.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptResponse clone() => TestMempoolAcceptResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptResponse copyWith(void Function(TestMempoolAcceptResponse) updates) => super.copyWith((message) => updates(message as TestMempoolAcceptResponse)) as TestMempoolAcceptResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptResponse create() => TestMempoolAcceptResponse._();
  TestMempoolAcceptResponse createEmptyInstance() => create();
  static $pb.PbList<TestMempoolAcceptResponse> createRepeated() => $pb.PbList<TestMempoolAcceptResponse>();
  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TestMempoolAcceptResponse>(create);
  static TestMempoolAcceptResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<TestMempoolAcceptResponse_Result> get results => $_getList(0);
}

enum DescriptorRange_RangeType {
  end, 
  range, 
  notSet
}

/// Add a new message for descriptor range
class DescriptorRange extends $pb.GeneratedMessage {
  factory DescriptorRange({
    $core.int? end,
    Range? range,
  }) {
    final $result = create();
    if (end != null) {
      $result.end = end;
    }
    if (range != null) {
      $result.range = range;
    }
    return $result;
  }
  DescriptorRange._() : super();
  factory DescriptorRange.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DescriptorRange.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, DescriptorRange_RangeType> _DescriptorRange_RangeTypeByTag = {
    1 : DescriptorRange_RangeType.end,
    2 : DescriptorRange_RangeType.range,
    0 : DescriptorRange_RangeType.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DescriptorRange', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..a<$core.int>(1, _omitFieldNames ? '' : 'end', $pb.PbFieldType.O3)
    ..aOM<Range>(2, _omitFieldNames ? '' : 'range', subBuilder: Range.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DescriptorRange clone() => DescriptorRange()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DescriptorRange copyWith(void Function(DescriptorRange) updates) => super.copyWith((message) => updates(message as DescriptorRange)) as DescriptorRange;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DescriptorRange create() => DescriptorRange._();
  DescriptorRange createEmptyInstance() => create();
  static $pb.PbList<DescriptorRange> createRepeated() => $pb.PbList<DescriptorRange>();
  @$core.pragma('dart2js:noInline')
  static DescriptorRange getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DescriptorRange>(create);
  static DescriptorRange? _defaultInstance;

  DescriptorRange_RangeType whichRangeType() => _DescriptorRange_RangeTypeByTag[$_whichOneof(0)]!;
  void clearRangeType() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get end => $_getIZ(0);
  @$pb.TagNumber(1)
  set end($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEnd() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnd() => clearField(1);

  @$pb.TagNumber(2)
  Range get range => $_getN(1);
  @$pb.TagNumber(2)
  set range(Range v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasRange() => $_has(1);
  @$pb.TagNumber(2)
  void clearRange() => clearField(2);
  @$pb.TagNumber(2)
  Range ensureRange() => $_ensure(1);
}

/// Add a new message for begin/end range
class Range extends $pb.GeneratedMessage {
  factory Range({
    $core.int? begin,
    $core.int? end,
  }) {
    final $result = create();
    if (begin != null) {
      $result.begin = begin;
    }
    if (end != null) {
      $result.end = end;
    }
    return $result;
  }
  Range._() : super();
  factory Range.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Range.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Range', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'begin', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'end', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Range clone() => Range()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Range copyWith(void Function(Range) updates) => super.copyWith((message) => updates(message as Range)) as Range;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Range create() => Range._();
  Range createEmptyInstance() => create();
  static $pb.PbList<Range> createRepeated() => $pb.PbList<Range>();
  @$core.pragma('dart2js:noInline')
  static Range getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Range>(create);
  static Range? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get begin => $_getIZ(0);
  @$pb.TagNumber(1)
  set begin($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBegin() => $_has(0);
  @$pb.TagNumber(1)
  void clearBegin() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get end => $_getIZ(1);
  @$pb.TagNumber(2)
  set end($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEnd() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnd() => clearField(2);
}

enum Descriptor_Descriptor {
  stringDescriptor, 
  objectDescriptor, 
  notSet
}

/// Add a new message for descriptor
class Descriptor extends $pb.GeneratedMessage {
  factory Descriptor({
    $core.String? stringDescriptor,
    DescriptorObject? objectDescriptor,
  }) {
    final $result = create();
    if (stringDescriptor != null) {
      $result.stringDescriptor = stringDescriptor;
    }
    if (objectDescriptor != null) {
      $result.objectDescriptor = objectDescriptor;
    }
    return $result;
  }
  Descriptor._() : super();
  factory Descriptor.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Descriptor.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, Descriptor_Descriptor> _Descriptor_DescriptorByTag = {
    1 : Descriptor_Descriptor.stringDescriptor,
    2 : Descriptor_Descriptor.objectDescriptor,
    0 : Descriptor_Descriptor.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Descriptor', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOS(1, _omitFieldNames ? '' : 'stringDescriptor')
    ..aOM<DescriptorObject>(2, _omitFieldNames ? '' : 'objectDescriptor', subBuilder: DescriptorObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Descriptor clone() => Descriptor()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Descriptor copyWith(void Function(Descriptor) updates) => super.copyWith((message) => updates(message as Descriptor)) as Descriptor;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Descriptor create() => Descriptor._();
  Descriptor createEmptyInstance() => create();
  static $pb.PbList<Descriptor> createRepeated() => $pb.PbList<Descriptor>();
  @$core.pragma('dart2js:noInline')
  static Descriptor getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Descriptor>(create);
  static Descriptor? _defaultInstance;

  Descriptor_Descriptor whichDescriptor() => _Descriptor_DescriptorByTag[$_whichOneof(0)]!;
  void clearDescriptor() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get stringDescriptor => $_getSZ(0);
  @$pb.TagNumber(1)
  set stringDescriptor($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStringDescriptor() => $_has(0);
  @$pb.TagNumber(1)
  void clearStringDescriptor() => clearField(1);

  @$pb.TagNumber(2)
  DescriptorObject get objectDescriptor => $_getN(1);
  @$pb.TagNumber(2)
  set objectDescriptor(DescriptorObject v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasObjectDescriptor() => $_has(1);
  @$pb.TagNumber(2)
  void clearObjectDescriptor() => clearField(2);
  @$pb.TagNumber(2)
  DescriptorObject ensureObjectDescriptor() => $_ensure(1);
}

/// Add a new message for descriptor objects
class DescriptorObject extends $pb.GeneratedMessage {
  factory DescriptorObject({
    $core.String? desc,
    DescriptorRange? range,
  }) {
    final $result = create();
    if (desc != null) {
      $result.desc = desc;
    }
    if (range != null) {
      $result.range = range;
    }
    return $result;
  }
  DescriptorObject._() : super();
  factory DescriptorObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DescriptorObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DescriptorObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'desc')
    ..aOM<DescriptorRange>(2, _omitFieldNames ? '' : 'range', subBuilder: DescriptorRange.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DescriptorObject clone() => DescriptorObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DescriptorObject copyWith(void Function(DescriptorObject) updates) => super.copyWith((message) => updates(message as DescriptorObject)) as DescriptorObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DescriptorObject create() => DescriptorObject._();
  DescriptorObject createEmptyInstance() => create();
  static $pb.PbList<DescriptorObject> createRepeated() => $pb.PbList<DescriptorObject>();
  @$core.pragma('dart2js:noInline')
  static DescriptorObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DescriptorObject>(create);
  static DescriptorObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get desc => $_getSZ(0);
  @$pb.TagNumber(1)
  set desc($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDesc() => $_has(0);
  @$pb.TagNumber(1)
  void clearDesc() => clearField(1);

  @$pb.TagNumber(2)
  DescriptorRange get range => $_getN(1);
  @$pb.TagNumber(2)
  set range(DescriptorRange v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasRange() => $_has(1);
  @$pb.TagNumber(2)
  void clearRange() => clearField(2);
  @$pb.TagNumber(2)
  DescriptorRange ensureRange() => $_ensure(1);
}

class GetZmqNotificationsResponse_Notification extends $pb.GeneratedMessage {
  factory GetZmqNotificationsResponse_Notification({
    $core.String? type,
    $core.String? address,
    $fixnum.Int64? highWaterMark,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (address != null) {
      $result.address = address;
    }
    if (highWaterMark != null) {
      $result.highWaterMark = highWaterMark;
    }
    return $result;
  }
  GetZmqNotificationsResponse_Notification._() : super();
  factory GetZmqNotificationsResponse_Notification.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetZmqNotificationsResponse_Notification.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetZmqNotificationsResponse.Notification', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aInt64(3, _omitFieldNames ? '' : 'highWaterMark')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetZmqNotificationsResponse_Notification clone() => GetZmqNotificationsResponse_Notification()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetZmqNotificationsResponse_Notification copyWith(void Function(GetZmqNotificationsResponse_Notification) updates) => super.copyWith((message) => updates(message as GetZmqNotificationsResponse_Notification)) as GetZmqNotificationsResponse_Notification;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetZmqNotificationsResponse_Notification create() => GetZmqNotificationsResponse_Notification._();
  GetZmqNotificationsResponse_Notification createEmptyInstance() => create();
  static $pb.PbList<GetZmqNotificationsResponse_Notification> createRepeated() => $pb.PbList<GetZmqNotificationsResponse_Notification>();
  @$core.pragma('dart2js:noInline')
  static GetZmqNotificationsResponse_Notification getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetZmqNotificationsResponse_Notification>(create);
  static GetZmqNotificationsResponse_Notification? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get highWaterMark => $_getI64(2);
  @$pb.TagNumber(3)
  set highWaterMark($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHighWaterMark() => $_has(2);
  @$pb.TagNumber(3)
  void clearHighWaterMark() => clearField(3);
}

class GetZmqNotificationsResponse extends $pb.GeneratedMessage {
  factory GetZmqNotificationsResponse({
    $core.Iterable<GetZmqNotificationsResponse_Notification>? notifications,
  }) {
    final $result = create();
    if (notifications != null) {
      $result.notifications.addAll(notifications);
    }
    return $result;
  }
  GetZmqNotificationsResponse._() : super();
  factory GetZmqNotificationsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetZmqNotificationsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetZmqNotificationsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..pc<GetZmqNotificationsResponse_Notification>(1, _omitFieldNames ? '' : 'notifications', $pb.PbFieldType.PM, subBuilder: GetZmqNotificationsResponse_Notification.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetZmqNotificationsResponse clone() => GetZmqNotificationsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetZmqNotificationsResponse copyWith(void Function(GetZmqNotificationsResponse) updates) => super.copyWith((message) => updates(message as GetZmqNotificationsResponse)) as GetZmqNotificationsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetZmqNotificationsResponse create() => GetZmqNotificationsResponse._();
  GetZmqNotificationsResponse createEmptyInstance() => create();
  static $pb.PbList<GetZmqNotificationsResponse> createRepeated() => $pb.PbList<GetZmqNotificationsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetZmqNotificationsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetZmqNotificationsResponse>(create);
  static GetZmqNotificationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GetZmqNotificationsResponse_Notification> get notifications => $_getList(0);
}

class BitcoinServiceApi {
  $pb.RpcClient _client;
  BitcoinServiceApi(this._client);

  $async.Future<GetBlockchainInfoResponse> getBlockchainInfo($pb.ClientContext? ctx, GetBlockchainInfoRequest request) =>
    _client.invoke<GetBlockchainInfoResponse>(ctx, 'BitcoinService', 'GetBlockchainInfo', request, GetBlockchainInfoResponse())
  ;
  $async.Future<GetPeerInfoResponse> getPeerInfo($pb.ClientContext? ctx, GetPeerInfoRequest request) =>
    _client.invoke<GetPeerInfoResponse>(ctx, 'BitcoinService', 'GetPeerInfo', request, GetPeerInfoResponse())
  ;
  $async.Future<GetTransactionResponse> getTransaction($pb.ClientContext? ctx, GetTransactionRequest request) =>
    _client.invoke<GetTransactionResponse>(ctx, 'BitcoinService', 'GetTransaction', request, GetTransactionResponse())
  ;
  $async.Future<ListSinceBlockResponse> listSinceBlock($pb.ClientContext? ctx, ListSinceBlockRequest request) =>
    _client.invoke<ListSinceBlockResponse>(ctx, 'BitcoinService', 'ListSinceBlock', request, ListSinceBlockResponse())
  ;
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, GetNewAddressRequest request) =>
    _client.invoke<GetNewAddressResponse>(ctx, 'BitcoinService', 'GetNewAddress', request, GetNewAddressResponse())
  ;
  $async.Future<GetWalletInfoResponse> getWalletInfo($pb.ClientContext? ctx, GetWalletInfoRequest request) =>
    _client.invoke<GetWalletInfoResponse>(ctx, 'BitcoinService', 'GetWalletInfo', request, GetWalletInfoResponse())
  ;
  $async.Future<GetBalancesResponse> getBalances($pb.ClientContext? ctx, GetBalancesRequest request) =>
    _client.invoke<GetBalancesResponse>(ctx, 'BitcoinService', 'GetBalances', request, GetBalancesResponse())
  ;
  $async.Future<SendResponse> send($pb.ClientContext? ctx, SendRequest request) =>
    _client.invoke<SendResponse>(ctx, 'BitcoinService', 'Send', request, SendResponse())
  ;
  $async.Future<SendToAddressResponse> sendToAddress($pb.ClientContext? ctx, SendToAddressRequest request) =>
    _client.invoke<SendToAddressResponse>(ctx, 'BitcoinService', 'SendToAddress', request, SendToAddressResponse())
  ;
  $async.Future<BumpFeeResponse> bumpFee($pb.ClientContext? ctx, BumpFeeRequest request) =>
    _client.invoke<BumpFeeResponse>(ctx, 'BitcoinService', 'BumpFee', request, BumpFeeResponse())
  ;
  $async.Future<EstimateSmartFeeResponse> estimateSmartFee($pb.ClientContext? ctx, EstimateSmartFeeRequest request) =>
    _client.invoke<EstimateSmartFeeResponse>(ctx, 'BitcoinService', 'EstimateSmartFee', request, EstimateSmartFeeResponse())
  ;
  $async.Future<ImportDescriptorsResponse> importDescriptors($pb.ClientContext? ctx, ImportDescriptorsRequest request) =>
    _client.invoke<ImportDescriptorsResponse>(ctx, 'BitcoinService', 'ImportDescriptors', request, ImportDescriptorsResponse())
  ;
  $async.Future<ListWalletsResponse> listWallets($pb.ClientContext? ctx, $3.Empty request) =>
    _client.invoke<ListWalletsResponse>(ctx, 'BitcoinService', 'ListWallets', request, ListWalletsResponse())
  ;
  $async.Future<ListUnspentResponse> listUnspent($pb.ClientContext? ctx, ListUnspentRequest request) =>
    _client.invoke<ListUnspentResponse>(ctx, 'BitcoinService', 'ListUnspent', request, ListUnspentResponse())
  ;
  $async.Future<ListTransactionsResponse> listTransactions($pb.ClientContext? ctx, ListTransactionsRequest request) =>
    _client.invoke<ListTransactionsResponse>(ctx, 'BitcoinService', 'ListTransactions', request, ListTransactionsResponse())
  ;
  $async.Future<GetDescriptorInfoResponse> getDescriptorInfo($pb.ClientContext? ctx, GetDescriptorInfoRequest request) =>
    _client.invoke<GetDescriptorInfoResponse>(ctx, 'BitcoinService', 'GetDescriptorInfo', request, GetDescriptorInfoResponse())
  ;
  $async.Future<GetAddressInfoResponse> getAddressInfo($pb.ClientContext? ctx, GetAddressInfoRequest request) =>
    _client.invoke<GetAddressInfoResponse>(ctx, 'BitcoinService', 'GetAddressInfo', request, GetAddressInfoResponse())
  ;
  $async.Future<GetRawMempoolResponse> getRawMempool($pb.ClientContext? ctx, GetRawMempoolRequest request) =>
    _client.invoke<GetRawMempoolResponse>(ctx, 'BitcoinService', 'GetRawMempool', request, GetRawMempoolResponse())
  ;
  $async.Future<GetRawTransactionResponse> getRawTransaction($pb.ClientContext? ctx, GetRawTransactionRequest request) =>
    _client.invoke<GetRawTransactionResponse>(ctx, 'BitcoinService', 'GetRawTransaction', request, GetRawTransactionResponse())
  ;
  $async.Future<DecodeRawTransactionResponse> decodeRawTransaction($pb.ClientContext? ctx, DecodeRawTransactionRequest request) =>
    _client.invoke<DecodeRawTransactionResponse>(ctx, 'BitcoinService', 'DecodeRawTransaction', request, DecodeRawTransactionResponse())
  ;
  $async.Future<CreateRawTransactionResponse> createRawTransaction($pb.ClientContext? ctx, CreateRawTransactionRequest request) =>
    _client.invoke<CreateRawTransactionResponse>(ctx, 'BitcoinService', 'CreateRawTransaction', request, CreateRawTransactionResponse())
  ;
  $async.Future<GetBlockResponse> getBlock($pb.ClientContext? ctx, GetBlockRequest request) =>
    _client.invoke<GetBlockResponse>(ctx, 'BitcoinService', 'GetBlock', request, GetBlockResponse())
  ;
  $async.Future<GetBlockHashResponse> getBlockHash($pb.ClientContext? ctx, GetBlockHashRequest request) =>
    _client.invoke<GetBlockHashResponse>(ctx, 'BitcoinService', 'GetBlockHash', request, GetBlockHashResponse())
  ;
  $async.Future<CreateWalletResponse> createWallet($pb.ClientContext? ctx, CreateWalletRequest request) =>
    _client.invoke<CreateWalletResponse>(ctx, 'BitcoinService', 'CreateWallet', request, CreateWalletResponse())
  ;
  $async.Future<BackupWalletResponse> backupWallet($pb.ClientContext? ctx, BackupWalletRequest request) =>
    _client.invoke<BackupWalletResponse>(ctx, 'BitcoinService', 'BackupWallet', request, BackupWalletResponse())
  ;
  $async.Future<DumpWalletResponse> dumpWallet($pb.ClientContext? ctx, DumpWalletRequest request) =>
    _client.invoke<DumpWalletResponse>(ctx, 'BitcoinService', 'DumpWallet', request, DumpWalletResponse())
  ;
  $async.Future<ImportWalletResponse> importWallet($pb.ClientContext? ctx, ImportWalletRequest request) =>
    _client.invoke<ImportWalletResponse>(ctx, 'BitcoinService', 'ImportWallet', request, ImportWalletResponse())
  ;
  $async.Future<UnloadWalletResponse> unloadWallet($pb.ClientContext? ctx, UnloadWalletRequest request) =>
    _client.invoke<UnloadWalletResponse>(ctx, 'BitcoinService', 'UnloadWallet', request, UnloadWalletResponse())
  ;
  $async.Future<DumpPrivKeyResponse> dumpPrivKey($pb.ClientContext? ctx, DumpPrivKeyRequest request) =>
    _client.invoke<DumpPrivKeyResponse>(ctx, 'BitcoinService', 'DumpPrivKey', request, DumpPrivKeyResponse())
  ;
  $async.Future<ImportPrivKeyResponse> importPrivKey($pb.ClientContext? ctx, ImportPrivKeyRequest request) =>
    _client.invoke<ImportPrivKeyResponse>(ctx, 'BitcoinService', 'ImportPrivKey', request, ImportPrivKeyResponse())
  ;
  $async.Future<ImportAddressResponse> importAddress($pb.ClientContext? ctx, ImportAddressRequest request) =>
    _client.invoke<ImportAddressResponse>(ctx, 'BitcoinService', 'ImportAddress', request, ImportAddressResponse())
  ;
  $async.Future<ImportPubKeyResponse> importPubKey($pb.ClientContext? ctx, ImportPubKeyRequest request) =>
    _client.invoke<ImportPubKeyResponse>(ctx, 'BitcoinService', 'ImportPubKey', request, ImportPubKeyResponse())
  ;
  $async.Future<KeyPoolRefillResponse> keyPoolRefill($pb.ClientContext? ctx, KeyPoolRefillRequest request) =>
    _client.invoke<KeyPoolRefillResponse>(ctx, 'BitcoinService', 'KeyPoolRefill', request, KeyPoolRefillResponse())
  ;
  $async.Future<GetAccountResponse> getAccount($pb.ClientContext? ctx, GetAccountRequest request) =>
    _client.invoke<GetAccountResponse>(ctx, 'BitcoinService', 'GetAccount', request, GetAccountResponse())
  ;
  $async.Future<SetAccountResponse> setAccount($pb.ClientContext? ctx, SetAccountRequest request) =>
    _client.invoke<SetAccountResponse>(ctx, 'BitcoinService', 'SetAccount', request, SetAccountResponse())
  ;
  $async.Future<GetAddressesByAccountResponse> getAddressesByAccount($pb.ClientContext? ctx, GetAddressesByAccountRequest request) =>
    _client.invoke<GetAddressesByAccountResponse>(ctx, 'BitcoinService', 'GetAddressesByAccount', request, GetAddressesByAccountResponse())
  ;
  $async.Future<ListAccountsResponse> listAccounts($pb.ClientContext? ctx, ListAccountsRequest request) =>
    _client.invoke<ListAccountsResponse>(ctx, 'BitcoinService', 'ListAccounts', request, ListAccountsResponse())
  ;
  $async.Future<AddMultisigAddressResponse> addMultisigAddress($pb.ClientContext? ctx, AddMultisigAddressRequest request) =>
    _client.invoke<AddMultisigAddressResponse>(ctx, 'BitcoinService', 'AddMultisigAddress', request, AddMultisigAddressResponse())
  ;
  $async.Future<CreateMultisigResponse> createMultisig($pb.ClientContext? ctx, CreateMultisigRequest request) =>
    _client.invoke<CreateMultisigResponse>(ctx, 'BitcoinService', 'CreateMultisig', request, CreateMultisigResponse())
  ;
  $async.Future<CreatePsbtResponse> createPsbt($pb.ClientContext? ctx, CreatePsbtRequest request) =>
    _client.invoke<CreatePsbtResponse>(ctx, 'BitcoinService', 'CreatePsbt', request, CreatePsbtResponse())
  ;
  $async.Future<DecodePsbtResponse> decodePsbt($pb.ClientContext? ctx, DecodePsbtRequest request) =>
    _client.invoke<DecodePsbtResponse>(ctx, 'BitcoinService', 'DecodePsbt', request, DecodePsbtResponse())
  ;
  $async.Future<AnalyzePsbtResponse> analyzePsbt($pb.ClientContext? ctx, AnalyzePsbtRequest request) =>
    _client.invoke<AnalyzePsbtResponse>(ctx, 'BitcoinService', 'AnalyzePsbt', request, AnalyzePsbtResponse())
  ;
  $async.Future<CombinePsbtResponse> combinePsbt($pb.ClientContext? ctx, CombinePsbtRequest request) =>
    _client.invoke<CombinePsbtResponse>(ctx, 'BitcoinService', 'CombinePsbt', request, CombinePsbtResponse())
  ;
  $async.Future<UtxoUpdatePsbtResponse> utxoUpdatePsbt($pb.ClientContext? ctx, UtxoUpdatePsbtRequest request) =>
    _client.invoke<UtxoUpdatePsbtResponse>(ctx, 'BitcoinService', 'UtxoUpdatePsbt', request, UtxoUpdatePsbtResponse())
  ;
  $async.Future<JoinPsbtsResponse> joinPsbts($pb.ClientContext? ctx, JoinPsbtsRequest request) =>
    _client.invoke<JoinPsbtsResponse>(ctx, 'BitcoinService', 'JoinPsbts', request, JoinPsbtsResponse())
  ;
  $async.Future<TestMempoolAcceptResponse> testMempoolAccept($pb.ClientContext? ctx, TestMempoolAcceptRequest request) =>
    _client.invoke<TestMempoolAcceptResponse>(ctx, 'BitcoinService', 'TestMempoolAccept', request, TestMempoolAcceptResponse())
  ;
  $async.Future<GetZmqNotificationsResponse> getZmqNotifications($pb.ClientContext? ctx, $3.Empty request) =>
    _client.invoke<GetZmqNotificationsResponse>(ctx, 'BitcoinService', 'GetZmqNotifications', request, GetZmqNotificationsResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
