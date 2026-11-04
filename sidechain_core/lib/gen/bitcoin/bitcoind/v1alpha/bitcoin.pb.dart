// This is a generated file - do not edit.
//
// Generated from bitcoin/bitcoind/v1alpha/bitcoin.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/duration.pb.dart' as $1;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $3;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $0;
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart' as $2;

import 'bitcoin.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'bitcoin.pbenum.dart';

class GetBlockchainInfoRequest extends $pb.GeneratedMessage {
  factory GetBlockchainInfoRequest() => GetBlockchainInfoRequest._();

  GetBlockchainInfoRequest._();

  factory GetBlockchainInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockchainInfoRequest()..mergeFromBuffer(data, registry);
  factory GetBlockchainInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockchainInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockchainInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetBlockchainInfoRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockchainInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockchainInfoRequest copyWith(void Function(GetBlockchainInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetBlockchainInfoRequest)) as GetBlockchainInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockchainInfoRequest() / GetBlockchainInfoRequest.new instead')
  static GetBlockchainInfoRequest create() => GetBlockchainInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockchainInfoRequest._();
  @$core.override
  GetBlockchainInfoRequest createEmptyInstance() => GetBlockchainInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBlockchainInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockchainInfoRequest>(GetBlockchainInfoRequest.$_createMessage);
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
    final result = GetBlockchainInfoResponse._();
    if (bestBlockHash != null) result.bestBlockHash = bestBlockHash;
    if (chain != null) result.chain = chain;
    if (chainWork != null) result.chainWork = chainWork;
    if (initialBlockDownload != null) result.initialBlockDownload = initialBlockDownload;
    if (blocks != null) result.blocks = blocks;
    if (headers != null) result.headers = headers;
    if (verificationProgress != null) result.verificationProgress = verificationProgress;
    return result;
  }

  GetBlockchainInfoResponse._();

  factory GetBlockchainInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockchainInfoResponse()..mergeFromBuffer(data, registry);
  factory GetBlockchainInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockchainInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockchainInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetBlockchainInfoResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'bestBlockHash')
    ..aOS(2, _omitFieldNames ? '' : 'chain')
    ..aOS(3, _omitFieldNames ? '' : 'chainWork')
    ..aOB(4, _omitFieldNames ? '' : 'initialBlockDownload')
    ..aI(5, _omitFieldNames ? '' : 'blocks', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'headers', fieldType: $pb.PbFieldType.OU3)
    ..aD(7, _omitFieldNames ? '' : 'verificationProgress')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockchainInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockchainInfoResponse copyWith(void Function(GetBlockchainInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetBlockchainInfoResponse)) as GetBlockchainInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockchainInfoResponse() / GetBlockchainInfoResponse.new instead')
  static GetBlockchainInfoResponse create() => GetBlockchainInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockchainInfoResponse._();
  @$core.override
  GetBlockchainInfoResponse createEmptyInstance() => GetBlockchainInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBlockchainInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockchainInfoResponse>(GetBlockchainInfoResponse.$_createMessage);
  static GetBlockchainInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get bestBlockHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set bestBlockHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBestBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBestBlockHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get chain => $_getSZ(1);
  @$pb.TagNumber(2)
  set chain($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChain() => $_has(1);
  @$pb.TagNumber(2)
  void clearChain() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get chainWork => $_getSZ(2);
  @$pb.TagNumber(3)
  set chainWork($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChainWork() => $_has(2);
  @$pb.TagNumber(3)
  void clearChainWork() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get initialBlockDownload => $_getBF(3);
  @$pb.TagNumber(4)
  set initialBlockDownload($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInitialBlockDownload() => $_has(3);
  @$pb.TagNumber(4)
  void clearInitialBlockDownload() => $_clearField(4);

  /// The height of the most-work fully-validated chain.
  @$pb.TagNumber(5)
  $core.int get blocks => $_getIZ(4);
  @$pb.TagNumber(5)
  set blocks($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBlocks() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlocks() => $_clearField(5);

  /// The current number of validated headers.
  @$pb.TagNumber(6)
  $core.int get headers => $_getIZ(5);
  @$pb.TagNumber(6)
  set headers($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHeaders() => $_has(5);
  @$pb.TagNumber(6)
  void clearHeaders() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get verificationProgress => $_getN(6);
  @$pb.TagNumber(7)
  set verificationProgress($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasVerificationProgress() => $_has(6);
  @$pb.TagNumber(7)
  void clearVerificationProgress() => $_clearField(7);
}

class GetPeerInfoRequest extends $pb.GeneratedMessage {
  factory GetPeerInfoRequest() => GetPeerInfoRequest._();

  GetPeerInfoRequest._();

  factory GetPeerInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPeerInfoRequest()..mergeFromBuffer(data, registry);
  factory GetPeerInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPeerInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPeerInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetPeerInfoRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPeerInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPeerInfoRequest copyWith(void Function(GetPeerInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetPeerInfoRequest)) as GetPeerInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetPeerInfoRequest() / GetPeerInfoRequest.new instead')
  static GetPeerInfoRequest create() => GetPeerInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetPeerInfoRequest._();
  @$core.override
  GetPeerInfoRequest createEmptyInstance() => GetPeerInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetPeerInfoRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPeerInfoRequest>(GetPeerInfoRequest.$_createMessage);
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
    $core.Iterable<$core.MapEntry<$core.String, $fixnum.Int64>>? bytesSentPerMsg,
    $core.Iterable<$core.MapEntry<$core.String, $fixnum.Int64>>? bytesReceivedPerMsg,
    Peer_ConnectionType? connectionType,
    Peer_TransportProtocol? transportProtocol,
    $core.String? sessionId,
  }) {
    final result = Peer._();
    if (id != null) result.id = id;
    if (addr != null) result.addr = addr;
    if (addrBind != null) result.addrBind = addrBind;
    if (addrLocal != null) result.addrLocal = addrLocal;
    if (network != null) result.network = network;
    if (mappedAs != null) result.mappedAs = mappedAs;
    if (services != null) result.services = services;
    if (servicesNames != null) result.servicesNames.addAll(servicesNames);
    if (relayTransactions != null) result.relayTransactions = relayTransactions;
    if (lastSendAt != null) result.lastSendAt = lastSendAt;
    if (lastRecvAt != null) result.lastRecvAt = lastRecvAt;
    if (lastTransactionAt != null) result.lastTransactionAt = lastTransactionAt;
    if (lastBlockAt != null) result.lastBlockAt = lastBlockAt;
    if (bytesSent != null) result.bytesSent = bytesSent;
    if (bytesReceived != null) result.bytesReceived = bytesReceived;
    if (connectedAt != null) result.connectedAt = connectedAt;
    if (timeOffset != null) result.timeOffset = timeOffset;
    if (pingTime != null) result.pingTime = pingTime;
    if (minPing != null) result.minPing = minPing;
    if (pingWait != null) result.pingWait = pingWait;
    if (version != null) result.version = version;
    if (subver != null) result.subver = subver;
    if (inbound != null) result.inbound = inbound;
    if (bip152HbTo != null) result.bip152HbTo = bip152HbTo;
    if (bip152HbFrom != null) result.bip152HbFrom = bip152HbFrom;
    if (startingHeight != null) result.startingHeight = startingHeight;
    if (presyncedHeaders != null) result.presyncedHeaders = presyncedHeaders;
    if (syncedHeaders != null) result.syncedHeaders = syncedHeaders;
    if (syncedBlocks != null) result.syncedBlocks = syncedBlocks;
    if (inflight != null) result.inflight.addAll(inflight);
    if (addrRelayEnabled != null) result.addrRelayEnabled = addrRelayEnabled;
    if (addrProcessed != null) result.addrProcessed = addrProcessed;
    if (addrRateLimited != null) result.addrRateLimited = addrRateLimited;
    if (permissions != null) result.permissions.addAll(permissions);
    if (minFeeFilter != null) result.minFeeFilter = minFeeFilter;
    if (bytesSentPerMsg != null) result.bytesSentPerMsg.addEntries(bytesSentPerMsg);
    if (bytesReceivedPerMsg != null) result.bytesReceivedPerMsg.addEntries(bytesReceivedPerMsg);
    if (connectionType != null) result.connectionType = connectionType;
    if (transportProtocol != null) result.transportProtocol = transportProtocol;
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  Peer._();

  factory Peer.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Peer()..mergeFromBuffer(data, registry);
  factory Peer.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Peer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Peer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: Peer.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'addr')
    ..aOS(3, _omitFieldNames ? '' : 'addrBind')
    ..aOS(4, _omitFieldNames ? '' : 'addrLocal')
    ..aE<Peer_Network>(5, _omitFieldNames ? '' : 'network', enumValues: Peer_Network.values)
    ..aInt64(6, _omitFieldNames ? '' : 'mappedAs')
    ..aOS(7, _omitFieldNames ? '' : 'services')
    ..pPS(8, _omitFieldNames ? '' : 'servicesNames')
    ..aOB(9, _omitFieldNames ? '' : 'relayTransactions')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'lastSendAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'lastRecvAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'lastTransactionAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'lastBlockAt', subBuilder: $0.Timestamp.$_createMessage)
    ..a<$fixnum.Int64>(14, _omitFieldNames ? '' : 'bytesSent', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(15, _omitFieldNames ? '' : 'bytesReceived', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<$0.Timestamp>(16, _omitFieldNames ? '' : 'connectedAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$1.Duration>(17, _omitFieldNames ? '' : 'timeOffset', subBuilder: $1.Duration.$_createMessage)
    ..aOM<$1.Duration>(18, _omitFieldNames ? '' : 'pingTime', subBuilder: $1.Duration.$_createMessage)
    ..aOM<$1.Duration>(19, _omitFieldNames ? '' : 'minPing', subBuilder: $1.Duration.$_createMessage)
    ..aOM<$1.Duration>(20, _omitFieldNames ? '' : 'pingWait', subBuilder: $1.Duration.$_createMessage)
    ..aI(21, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..aOS(22, _omitFieldNames ? '' : 'subver')
    ..aOB(23, _omitFieldNames ? '' : 'inbound')
    ..aOB(24, _omitFieldNames ? '' : 'bip152HbTo')
    ..aOB(25, _omitFieldNames ? '' : 'bip152HbFrom')
    ..aI(26, _omitFieldNames ? '' : 'startingHeight')
    ..aI(27, _omitFieldNames ? '' : 'presyncedHeaders')
    ..aI(28, _omitFieldNames ? '' : 'syncedHeaders')
    ..aI(29, _omitFieldNames ? '' : 'syncedBlocks')
    ..p<$core.int>(30, _omitFieldNames ? '' : 'inflight', $pb.PbFieldType.K3)
    ..aOB(31, _omitFieldNames ? '' : 'addrRelayEnabled')
    ..aInt64(32, _omitFieldNames ? '' : 'addrProcessed')
    ..aInt64(33, _omitFieldNames ? '' : 'addrRateLimited')
    ..pPS(34, _omitFieldNames ? '' : 'permissions')
    ..aD(35, _omitFieldNames ? '' : 'minFeeFilter')
    ..m<$core.String, $fixnum.Int64>(36, _omitFieldNames ? '' : 'bytesSentPerMsg',
        entryClassName: 'Peer.BytesSentPerMsgEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O6,
        packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..m<$core.String, $fixnum.Int64>(37, _omitFieldNames ? '' : 'bytesReceivedPerMsg',
        entryClassName: 'Peer.BytesReceivedPerMsgEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O6,
        packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..aE<Peer_ConnectionType>(38, _omitFieldNames ? '' : 'connectionType', enumValues: Peer_ConnectionType.values)
    ..aE<Peer_TransportProtocol>(39, _omitFieldNames ? '' : 'transportProtocol',
        enumValues: Peer_TransportProtocol.values)
    ..aOS(40, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Peer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Peer copyWith(void Function(Peer) updates) => super.copyWith((message) => updates(message as Peer)) as Peer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Peer() / Peer.new instead')
  static Peer create() => Peer._();
  static $pb.GeneratedMessage $_createMessage() => Peer._();
  @$core.override
  Peer createEmptyInstance() => Peer._();
  @$core.pragma('dart2js:noInline')
  static Peer getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Peer>(Peer.$_createMessage);
  static Peer? _defaultInstance;

  /// Peer index
  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// The IP address and port of the peer (host:port)
  @$pb.TagNumber(2)
  $core.String get addr => $_getSZ(1);
  @$pb.TagNumber(2)
  set addr($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddr() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddr() => $_clearField(2);

  /// Bind address of the connection to the peer (ip:port)
  @$pb.TagNumber(3)
  $core.String get addrBind => $_getSZ(2);
  @$pb.TagNumber(3)
  set addrBind($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddrBind() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddrBind() => $_clearField(3);

  /// Local address as reported by the peer (ip:port)
  @$pb.TagNumber(4)
  $core.String get addrLocal => $_getSZ(3);
  @$pb.TagNumber(4)
  set addrLocal($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAddrLocal() => $_has(3);
  @$pb.TagNumber(4)
  void clearAddrLocal() => $_clearField(4);

  @$pb.TagNumber(5)
  Peer_Network get network => $_getN(4);
  @$pb.TagNumber(5)
  set network(Peer_Network value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasNetwork() => $_has(4);
  @$pb.TagNumber(5)
  void clearNetwork() => $_clearField(5);

  /// The AS in the BGP route to the peer used for diversifying peer selection
  @$pb.TagNumber(6)
  $fixnum.Int64 get mappedAs => $_getI64(5);
  @$pb.TagNumber(6)
  set mappedAs($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMappedAs() => $_has(5);
  @$pb.TagNumber(6)
  void clearMappedAs() => $_clearField(6);

  /// The services offered (hex)
  @$pb.TagNumber(7)
  $core.String get services => $_getSZ(6);
  @$pb.TagNumber(7)
  set services($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasServices() => $_has(6);
  @$pb.TagNumber(7)
  void clearServices() => $_clearField(7);

  /// The services offered, in human-readable form
  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get servicesNames => $_getList(7);

  /// Whether we relay transactions to this peer
  @$pb.TagNumber(9)
  $core.bool get relayTransactions => $_getBF(8);
  @$pb.TagNumber(9)
  set relayTransactions($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRelayTransactions() => $_has(8);
  @$pb.TagNumber(9)
  void clearRelayTransactions() => $_clearField(9);

  /// The time of the last send
  @$pb.TagNumber(10)
  $0.Timestamp get lastSendAt => $_getN(9);
  @$pb.TagNumber(10)
  set lastSendAt($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasLastSendAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearLastSendAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureLastSendAt() => $_ensure(9);

  /// The time of the last receive
  @$pb.TagNumber(11)
  $0.Timestamp get lastRecvAt => $_getN(10);
  @$pb.TagNumber(11)
  set lastRecvAt($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasLastRecvAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearLastRecvAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureLastRecvAt() => $_ensure(10);

  /// The time of the last valid transaction received from this peer
  @$pb.TagNumber(12)
  $0.Timestamp get lastTransactionAt => $_getN(11);
  @$pb.TagNumber(12)
  set lastTransactionAt($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasLastTransactionAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearLastTransactionAt() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureLastTransactionAt() => $_ensure(11);

  /// The time of the last block received from this peer
  @$pb.TagNumber(13)
  $0.Timestamp get lastBlockAt => $_getN(12);
  @$pb.TagNumber(13)
  set lastBlockAt($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasLastBlockAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearLastBlockAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureLastBlockAt() => $_ensure(12);

  /// The total bytes sent
  @$pb.TagNumber(14)
  $fixnum.Int64 get bytesSent => $_getI64(13);
  @$pb.TagNumber(14)
  set bytesSent($fixnum.Int64 value) => $_setInt64(13, value);
  @$pb.TagNumber(14)
  $core.bool hasBytesSent() => $_has(13);
  @$pb.TagNumber(14)
  void clearBytesSent() => $_clearField(14);

  /// The total bytes received
  @$pb.TagNumber(15)
  $fixnum.Int64 get bytesReceived => $_getI64(14);
  @$pb.TagNumber(15)
  set bytesReceived($fixnum.Int64 value) => $_setInt64(14, value);
  @$pb.TagNumber(15)
  $core.bool hasBytesReceived() => $_has(14);
  @$pb.TagNumber(15)
  void clearBytesReceived() => $_clearField(15);

  /// The time of the connection
  @$pb.TagNumber(16)
  $0.Timestamp get connectedAt => $_getN(15);
  @$pb.TagNumber(16)
  set connectedAt($0.Timestamp value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasConnectedAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearConnectedAt() => $_clearField(16);
  @$pb.TagNumber(16)
  $0.Timestamp ensureConnectedAt() => $_ensure(15);

  /// The time offset
  @$pb.TagNumber(17)
  $1.Duration get timeOffset => $_getN(16);
  @$pb.TagNumber(17)
  set timeOffset($1.Duration value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasTimeOffset() => $_has(16);
  @$pb.TagNumber(17)
  void clearTimeOffset() => $_clearField(17);
  @$pb.TagNumber(17)
  $1.Duration ensureTimeOffset() => $_ensure(16);

  /// The last ping time, if any
  @$pb.TagNumber(18)
  $1.Duration get pingTime => $_getN(17);
  @$pb.TagNumber(18)
  set pingTime($1.Duration value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasPingTime() => $_has(17);
  @$pb.TagNumber(18)
  void clearPingTime() => $_clearField(18);
  @$pb.TagNumber(18)
  $1.Duration ensurePingTime() => $_ensure(17);

  /// The minimum observed ping time, if any
  @$pb.TagNumber(19)
  $1.Duration get minPing => $_getN(18);
  @$pb.TagNumber(19)
  set minPing($1.Duration value) => $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasMinPing() => $_has(18);
  @$pb.TagNumber(19)
  void clearMinPing() => $_clearField(19);
  @$pb.TagNumber(19)
  $1.Duration ensureMinPing() => $_ensure(18);

  /// The duration of an outstanding ping, if any
  @$pb.TagNumber(20)
  $1.Duration get pingWait => $_getN(19);
  @$pb.TagNumber(20)
  set pingWait($1.Duration value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasPingWait() => $_has(19);
  @$pb.TagNumber(20)
  void clearPingWait() => $_clearField(20);
  @$pb.TagNumber(20)
  $1.Duration ensurePingWait() => $_ensure(19);

  /// The peer version, such as 70001
  @$pb.TagNumber(21)
  $core.int get version => $_getIZ(20);
  @$pb.TagNumber(21)
  set version($core.int value) => $_setUnsignedInt32(20, value);
  @$pb.TagNumber(21)
  $core.bool hasVersion() => $_has(20);
  @$pb.TagNumber(21)
  void clearVersion() => $_clearField(21);

  /// The string version
  @$pb.TagNumber(22)
  $core.String get subver => $_getSZ(21);
  @$pb.TagNumber(22)
  set subver($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasSubver() => $_has(21);
  @$pb.TagNumber(22)
  void clearSubver() => $_clearField(22);

  /// Inbound (true) or Outbound (false)
  @$pb.TagNumber(23)
  $core.bool get inbound => $_getBF(22);
  @$pb.TagNumber(23)
  set inbound($core.bool value) => $_setBool(22, value);
  @$pb.TagNumber(23)
  $core.bool hasInbound() => $_has(22);
  @$pb.TagNumber(23)
  void clearInbound() => $_clearField(23);

  /// Whether we selected peer as (compact blocks) high-bandwidth peer
  @$pb.TagNumber(24)
  $core.bool get bip152HbTo => $_getBF(23);
  @$pb.TagNumber(24)
  set bip152HbTo($core.bool value) => $_setBool(23, value);
  @$pb.TagNumber(24)
  $core.bool hasBip152HbTo() => $_has(23);
  @$pb.TagNumber(24)
  void clearBip152HbTo() => $_clearField(24);

  /// Whether peer selected us as (compact blocks) high-bandwidth peer
  @$pb.TagNumber(25)
  $core.bool get bip152HbFrom => $_getBF(24);
  @$pb.TagNumber(25)
  set bip152HbFrom($core.bool value) => $_setBool(24, value);
  @$pb.TagNumber(25)
  $core.bool hasBip152HbFrom() => $_has(24);
  @$pb.TagNumber(25)
  void clearBip152HbFrom() => $_clearField(25);

  /// The starting height (block) of the peer
  @$pb.TagNumber(26)
  $core.int get startingHeight => $_getIZ(25);
  @$pb.TagNumber(26)
  set startingHeight($core.int value) => $_setSignedInt32(25, value);
  @$pb.TagNumber(26)
  $core.bool hasStartingHeight() => $_has(25);
  @$pb.TagNumber(26)
  void clearStartingHeight() => $_clearField(26);

  /// The current height of header pre-synchronization with this peer, or -1 if no low-work sync is in progress
  @$pb.TagNumber(27)
  $core.int get presyncedHeaders => $_getIZ(26);
  @$pb.TagNumber(27)
  set presyncedHeaders($core.int value) => $_setSignedInt32(26, value);
  @$pb.TagNumber(27)
  $core.bool hasPresyncedHeaders() => $_has(26);
  @$pb.TagNumber(27)
  void clearPresyncedHeaders() => $_clearField(27);

  /// The last header we have in common with this peer
  @$pb.TagNumber(28)
  $core.int get syncedHeaders => $_getIZ(27);
  @$pb.TagNumber(28)
  set syncedHeaders($core.int value) => $_setSignedInt32(27, value);
  @$pb.TagNumber(28)
  $core.bool hasSyncedHeaders() => $_has(27);
  @$pb.TagNumber(28)
  void clearSyncedHeaders() => $_clearField(28);

  /// The last block we have in common with this peer
  @$pb.TagNumber(29)
  $core.int get syncedBlocks => $_getIZ(28);
  @$pb.TagNumber(29)
  set syncedBlocks($core.int value) => $_setSignedInt32(28, value);
  @$pb.TagNumber(29)
  $core.bool hasSyncedBlocks() => $_has(28);
  @$pb.TagNumber(29)
  void clearSyncedBlocks() => $_clearField(29);

  /// The heights of blocks we're currently asking from this peer
  @$pb.TagNumber(30)
  $pb.PbList<$core.int> get inflight => $_getList(29);

  /// Whether we participate in address relay with this peer
  @$pb.TagNumber(31)
  $core.bool get addrRelayEnabled => $_getBF(30);
  @$pb.TagNumber(31)
  set addrRelayEnabled($core.bool value) => $_setBool(30, value);
  @$pb.TagNumber(31)
  $core.bool hasAddrRelayEnabled() => $_has(30);
  @$pb.TagNumber(31)
  void clearAddrRelayEnabled() => $_clearField(31);

  /// The total number of addresses processed, excluding those dropped due to rate limiting
  @$pb.TagNumber(32)
  $fixnum.Int64 get addrProcessed => $_getI64(31);
  @$pb.TagNumber(32)
  set addrProcessed($fixnum.Int64 value) => $_setInt64(31, value);
  @$pb.TagNumber(32)
  $core.bool hasAddrProcessed() => $_has(31);
  @$pb.TagNumber(32)
  void clearAddrProcessed() => $_clearField(32);

  /// The total number of addresses dropped due to rate limiting
  @$pb.TagNumber(33)
  $fixnum.Int64 get addrRateLimited => $_getI64(32);
  @$pb.TagNumber(33)
  set addrRateLimited($fixnum.Int64 value) => $_setInt64(32, value);
  @$pb.TagNumber(33)
  $core.bool hasAddrRateLimited() => $_has(32);
  @$pb.TagNumber(33)
  void clearAddrRateLimited() => $_clearField(33);

  /// Any special permissions that have been granted to this peer
  @$pb.TagNumber(34)
  $pb.PbList<$core.String> get permissions => $_getList(33);

  /// The minimum fee rate for transactions this peer accepts
  @$pb.TagNumber(35)
  $core.double get minFeeFilter => $_getN(34);
  @$pb.TagNumber(35)
  set minFeeFilter($core.double value) => $_setDouble(34, value);
  @$pb.TagNumber(35)
  $core.bool hasMinFeeFilter() => $_has(34);
  @$pb.TagNumber(35)
  void clearMinFeeFilter() => $_clearField(35);

  /// The total bytes sent aggregated by message type
  @$pb.TagNumber(36)
  $pb.PbMap<$core.String, $fixnum.Int64> get bytesSentPerMsg => $_getMap(35);

  /// The total bytes received aggregated by message type
  @$pb.TagNumber(37)
  $pb.PbMap<$core.String, $fixnum.Int64> get bytesReceivedPerMsg => $_getMap(36);

  /// Type of connection
  @$pb.TagNumber(38)
  Peer_ConnectionType get connectionType => $_getN(37);
  @$pb.TagNumber(38)
  set connectionType(Peer_ConnectionType value) => $_setField(38, value);
  @$pb.TagNumber(38)
  $core.bool hasConnectionType() => $_has(37);
  @$pb.TagNumber(38)
  void clearConnectionType() => $_clearField(38);

  /// Type of transport protocol
  @$pb.TagNumber(39)
  Peer_TransportProtocol get transportProtocol => $_getN(38);
  @$pb.TagNumber(39)
  set transportProtocol(Peer_TransportProtocol value) => $_setField(39, value);
  @$pb.TagNumber(39)
  $core.bool hasTransportProtocol() => $_has(38);
  @$pb.TagNumber(39)
  void clearTransportProtocol() => $_clearField(39);

  /// The session ID for this connection, or empty if there is none (v2 transport protocol only)
  @$pb.TagNumber(40)
  $core.String get sessionId => $_getSZ(39);
  @$pb.TagNumber(40)
  set sessionId($core.String value) => $_setString(39, value);
  @$pb.TagNumber(40)
  $core.bool hasSessionId() => $_has(39);
  @$pb.TagNumber(40)
  void clearSessionId() => $_clearField(40);
}

class GetPeerInfoResponse extends $pb.GeneratedMessage {
  factory GetPeerInfoResponse({
    $core.Iterable<Peer>? peers,
  }) {
    final result = GetPeerInfoResponse._();
    if (peers != null) result.peers.addAll(peers);
    return result;
  }

  GetPeerInfoResponse._();

  factory GetPeerInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPeerInfoResponse()..mergeFromBuffer(data, registry);
  factory GetPeerInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPeerInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPeerInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetPeerInfoResponse.$_createMessage)
    ..pPM<Peer>(1, _omitFieldNames ? '' : 'peers', subBuilder: Peer.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPeerInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPeerInfoResponse copyWith(void Function(GetPeerInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetPeerInfoResponse)) as GetPeerInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetPeerInfoResponse() / GetPeerInfoResponse.new instead')
  static GetPeerInfoResponse create() => GetPeerInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetPeerInfoResponse._();
  @$core.override
  GetPeerInfoResponse createEmptyInstance() => GetPeerInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetPeerInfoResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPeerInfoResponse>(GetPeerInfoResponse.$_createMessage);
  static GetPeerInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Peer> get peers => $_getList(0);
}

class GetNetworkInfoRequest extends $pb.GeneratedMessage {
  factory GetNetworkInfoRequest() => GetNetworkInfoRequest._();

  GetNetworkInfoRequest._();

  factory GetNetworkInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNetworkInfoRequest()..mergeFromBuffer(data, registry);
  factory GetNetworkInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNetworkInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNetworkInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetNetworkInfoRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNetworkInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNetworkInfoRequest copyWith(void Function(GetNetworkInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetNetworkInfoRequest)) as GetNetworkInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNetworkInfoRequest() / GetNetworkInfoRequest.new instead')
  static GetNetworkInfoRequest create() => GetNetworkInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetNetworkInfoRequest._();
  @$core.override
  GetNetworkInfoRequest createEmptyInstance() => GetNetworkInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetNetworkInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNetworkInfoRequest>(GetNetworkInfoRequest.$_createMessage);
  static GetNetworkInfoRequest? _defaultInstance;
}

class GetNetworkInfoResponse_Network extends $pb.GeneratedMessage {
  factory GetNetworkInfoResponse_Network({
    $core.String? name,
    $core.bool? limited,
    $core.bool? reachable,
    $core.String? proxy,
    $core.bool? proxyRandomizeCredentials,
  }) {
    final result = GetNetworkInfoResponse_Network._();
    if (name != null) result.name = name;
    if (limited != null) result.limited = limited;
    if (reachable != null) result.reachable = reachable;
    if (proxy != null) result.proxy = proxy;
    if (proxyRandomizeCredentials != null) result.proxyRandomizeCredentials = proxyRandomizeCredentials;
    return result;
  }

  GetNetworkInfoResponse_Network._();

  factory GetNetworkInfoResponse_Network.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNetworkInfoResponse_Network()..mergeFromBuffer(data, registry);
  factory GetNetworkInfoResponse_Network.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNetworkInfoResponse_Network()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNetworkInfoResponse.Network',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetNetworkInfoResponse_Network.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOB(2, _omitFieldNames ? '' : 'limited')
    ..aOB(3, _omitFieldNames ? '' : 'reachable')
    ..aOS(4, _omitFieldNames ? '' : 'proxy')
    ..aOB(5, _omitFieldNames ? '' : 'proxyRandomizeCredentials')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNetworkInfoResponse_Network clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNetworkInfoResponse_Network copyWith(void Function(GetNetworkInfoResponse_Network) updates) =>
      super.copyWith((message) => updates(message as GetNetworkInfoResponse_Network)) as GetNetworkInfoResponse_Network;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNetworkInfoResponse_Network() / GetNetworkInfoResponse_Network.new instead')
  static GetNetworkInfoResponse_Network create() => GetNetworkInfoResponse_Network._();
  static $pb.GeneratedMessage $_createMessage() => GetNetworkInfoResponse_Network._();
  @$core.override
  GetNetworkInfoResponse_Network createEmptyInstance() => GetNetworkInfoResponse_Network._();
  @$core.pragma('dart2js:noInline')
  static GetNetworkInfoResponse_Network getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNetworkInfoResponse_Network>(GetNetworkInfoResponse_Network.$_createMessage);
  static GetNetworkInfoResponse_Network? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get limited => $_getBF(1);
  @$pb.TagNumber(2)
  set limited($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimited() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimited() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get reachable => $_getBF(2);
  @$pb.TagNumber(3)
  set reachable($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReachable() => $_has(2);
  @$pb.TagNumber(3)
  void clearReachable() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get proxy => $_getSZ(3);
  @$pb.TagNumber(4)
  set proxy($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProxy() => $_has(3);
  @$pb.TagNumber(4)
  void clearProxy() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get proxyRandomizeCredentials => $_getBF(4);
  @$pb.TagNumber(5)
  set proxyRandomizeCredentials($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProxyRandomizeCredentials() => $_has(4);
  @$pb.TagNumber(5)
  void clearProxyRandomizeCredentials() => $_clearField(5);
}

class GetNetworkInfoResponse_LocalAddress extends $pb.GeneratedMessage {
  factory GetNetworkInfoResponse_LocalAddress({
    $core.String? address,
    $core.int? port,
    $core.int? score,
  }) {
    final result = GetNetworkInfoResponse_LocalAddress._();
    if (address != null) result.address = address;
    if (port != null) result.port = port;
    if (score != null) result.score = score;
    return result;
  }

  GetNetworkInfoResponse_LocalAddress._();

  factory GetNetworkInfoResponse_LocalAddress.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNetworkInfoResponse_LocalAddress()..mergeFromBuffer(data, registry);
  factory GetNetworkInfoResponse_LocalAddress.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNetworkInfoResponse_LocalAddress()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNetworkInfoResponse.LocalAddress',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetNetworkInfoResponse_LocalAddress.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aI(2, _omitFieldNames ? '' : 'port', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'score')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNetworkInfoResponse_LocalAddress clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNetworkInfoResponse_LocalAddress copyWith(void Function(GetNetworkInfoResponse_LocalAddress) updates) =>
      super.copyWith((message) => updates(message as GetNetworkInfoResponse_LocalAddress))
          as GetNetworkInfoResponse_LocalAddress;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNetworkInfoResponse_LocalAddress() / GetNetworkInfoResponse_LocalAddress.new instead')
  static GetNetworkInfoResponse_LocalAddress create() => GetNetworkInfoResponse_LocalAddress._();
  static $pb.GeneratedMessage $_createMessage() => GetNetworkInfoResponse_LocalAddress._();
  @$core.override
  GetNetworkInfoResponse_LocalAddress createEmptyInstance() => GetNetworkInfoResponse_LocalAddress._();
  @$core.pragma('dart2js:noInline')
  static GetNetworkInfoResponse_LocalAddress getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNetworkInfoResponse_LocalAddress>(
          GetNetworkInfoResponse_LocalAddress.$_createMessage);
  static GetNetworkInfoResponse_LocalAddress? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get port => $_getIZ(1);
  @$pb.TagNumber(2)
  set port($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPort() => $_has(1);
  @$pb.TagNumber(2)
  void clearPort() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get score => $_getIZ(2);
  @$pb.TagNumber(3)
  set score($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScore() => $_has(2);
  @$pb.TagNumber(3)
  void clearScore() => $_clearField(3);
}

class GetNetworkInfoResponse extends $pb.GeneratedMessage {
  factory GetNetworkInfoResponse({
    $core.int? version,
    $core.String? subversion,
    $core.int? protocolVersion,
    $core.String? localServices,
    $core.Iterable<$core.String>? localServicesNames,
    $core.bool? localRelay,
    $fixnum.Int64? timeOffset,
    $core.int? connections,
    $core.int? connectionsIn,
    $core.int? connectionsOut,
    $core.bool? networkActive,
    $core.Iterable<GetNetworkInfoResponse_Network>? networks,
    $core.double? relayFee,
    $core.double? incrementalFee,
    $core.Iterable<GetNetworkInfoResponse_LocalAddress>? localAddresses,
    $core.Iterable<$core.String>? warnings,
  }) {
    final result = GetNetworkInfoResponse._();
    if (version != null) result.version = version;
    if (subversion != null) result.subversion = subversion;
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    if (localServices != null) result.localServices = localServices;
    if (localServicesNames != null) result.localServicesNames.addAll(localServicesNames);
    if (localRelay != null) result.localRelay = localRelay;
    if (timeOffset != null) result.timeOffset = timeOffset;
    if (connections != null) result.connections = connections;
    if (connectionsIn != null) result.connectionsIn = connectionsIn;
    if (connectionsOut != null) result.connectionsOut = connectionsOut;
    if (networkActive != null) result.networkActive = networkActive;
    if (networks != null) result.networks.addAll(networks);
    if (relayFee != null) result.relayFee = relayFee;
    if (incrementalFee != null) result.incrementalFee = incrementalFee;
    if (localAddresses != null) result.localAddresses.addAll(localAddresses);
    if (warnings != null) result.warnings.addAll(warnings);
    return result;
  }

  GetNetworkInfoResponse._();

  factory GetNetworkInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNetworkInfoResponse()..mergeFromBuffer(data, registry);
  factory GetNetworkInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNetworkInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNetworkInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetNetworkInfoResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'version')
    ..aOS(2, _omitFieldNames ? '' : 'subversion')
    ..aI(3, _omitFieldNames ? '' : 'protocolVersion')
    ..aOS(4, _omitFieldNames ? '' : 'localServices')
    ..pPS(5, _omitFieldNames ? '' : 'localServicesNames')
    ..aOB(6, _omitFieldNames ? '' : 'localRelay')
    ..aInt64(7, _omitFieldNames ? '' : 'timeOffset')
    ..aI(8, _omitFieldNames ? '' : 'connections')
    ..aI(9, _omitFieldNames ? '' : 'connectionsIn')
    ..aI(10, _omitFieldNames ? '' : 'connectionsOut')
    ..aOB(11, _omitFieldNames ? '' : 'networkActive')
    ..pPM<GetNetworkInfoResponse_Network>(12, _omitFieldNames ? '' : 'networks',
        subBuilder: GetNetworkInfoResponse_Network.$_createMessage)
    ..aD(13, _omitFieldNames ? '' : 'relayFee')
    ..aD(14, _omitFieldNames ? '' : 'incrementalFee')
    ..pPM<GetNetworkInfoResponse_LocalAddress>(15, _omitFieldNames ? '' : 'localAddresses',
        subBuilder: GetNetworkInfoResponse_LocalAddress.$_createMessage)
    ..pPS(16, _omitFieldNames ? '' : 'warnings')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNetworkInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNetworkInfoResponse copyWith(void Function(GetNetworkInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetNetworkInfoResponse)) as GetNetworkInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNetworkInfoResponse() / GetNetworkInfoResponse.new instead')
  static GetNetworkInfoResponse create() => GetNetworkInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetNetworkInfoResponse._();
  @$core.override
  GetNetworkInfoResponse createEmptyInstance() => GetNetworkInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetNetworkInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNetworkInfoResponse>(GetNetworkInfoResponse.$_createMessage);
  static GetNetworkInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get version => $_getIZ(0);
  @$pb.TagNumber(1)
  set version($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get subversion => $_getSZ(1);
  @$pb.TagNumber(2)
  set subversion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSubversion() => $_has(1);
  @$pb.TagNumber(2)
  void clearSubversion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get protocolVersion => $_getIZ(2);
  @$pb.TagNumber(3)
  set protocolVersion($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProtocolVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearProtocolVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get localServices => $_getSZ(3);
  @$pb.TagNumber(4)
  set localServices($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLocalServices() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocalServices() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get localServicesNames => $_getList(4);

  @$pb.TagNumber(6)
  $core.bool get localRelay => $_getBF(5);
  @$pb.TagNumber(6)
  set localRelay($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLocalRelay() => $_has(5);
  @$pb.TagNumber(6)
  void clearLocalRelay() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get timeOffset => $_getI64(6);
  @$pb.TagNumber(7)
  set timeOffset($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTimeOffset() => $_has(6);
  @$pb.TagNumber(7)
  void clearTimeOffset() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get connections => $_getIZ(7);
  @$pb.TagNumber(8)
  set connections($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasConnections() => $_has(7);
  @$pb.TagNumber(8)
  void clearConnections() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get connectionsIn => $_getIZ(8);
  @$pb.TagNumber(9)
  set connectionsIn($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasConnectionsIn() => $_has(8);
  @$pb.TagNumber(9)
  void clearConnectionsIn() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get connectionsOut => $_getIZ(9);
  @$pb.TagNumber(10)
  set connectionsOut($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasConnectionsOut() => $_has(9);
  @$pb.TagNumber(10)
  void clearConnectionsOut() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get networkActive => $_getBF(10);
  @$pb.TagNumber(11)
  set networkActive($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasNetworkActive() => $_has(10);
  @$pb.TagNumber(11)
  void clearNetworkActive() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<GetNetworkInfoResponse_Network> get networks => $_getList(11);

  @$pb.TagNumber(13)
  $core.double get relayFee => $_getN(12);
  @$pb.TagNumber(13)
  set relayFee($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasRelayFee() => $_has(12);
  @$pb.TagNumber(13)
  void clearRelayFee() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get incrementalFee => $_getN(13);
  @$pb.TagNumber(14)
  set incrementalFee($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasIncrementalFee() => $_has(13);
  @$pb.TagNumber(14)
  void clearIncrementalFee() => $_clearField(14);

  @$pb.TagNumber(15)
  $pb.PbList<GetNetworkInfoResponse_LocalAddress> get localAddresses => $_getList(14);

  @$pb.TagNumber(16)
  $pb.PbList<$core.String> get warnings => $_getList(15);
}

class GetNetTotalsRequest extends $pb.GeneratedMessage {
  factory GetNetTotalsRequest() => GetNetTotalsRequest._();

  GetNetTotalsRequest._();

  factory GetNetTotalsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNetTotalsRequest()..mergeFromBuffer(data, registry);
  factory GetNetTotalsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNetTotalsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNetTotalsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetNetTotalsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNetTotalsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNetTotalsRequest copyWith(void Function(GetNetTotalsRequest) updates) =>
      super.copyWith((message) => updates(message as GetNetTotalsRequest)) as GetNetTotalsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNetTotalsRequest() / GetNetTotalsRequest.new instead')
  static GetNetTotalsRequest create() => GetNetTotalsRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetNetTotalsRequest._();
  @$core.override
  GetNetTotalsRequest createEmptyInstance() => GetNetTotalsRequest._();
  @$core.pragma('dart2js:noInline')
  static GetNetTotalsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNetTotalsRequest>(GetNetTotalsRequest.$_createMessage);
  static GetNetTotalsRequest? _defaultInstance;
}

class GetNetTotalsResponse extends $pb.GeneratedMessage {
  factory GetNetTotalsResponse({
    $fixnum.Int64? totalBytesRecv,
    $fixnum.Int64? totalBytesSent,
    $fixnum.Int64? timeMillis,
  }) {
    final result = GetNetTotalsResponse._();
    if (totalBytesRecv != null) result.totalBytesRecv = totalBytesRecv;
    if (totalBytesSent != null) result.totalBytesSent = totalBytesSent;
    if (timeMillis != null) result.timeMillis = timeMillis;
    return result;
  }

  GetNetTotalsResponse._();

  factory GetNetTotalsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNetTotalsResponse()..mergeFromBuffer(data, registry);
  factory GetNetTotalsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNetTotalsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNetTotalsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetNetTotalsResponse.$_createMessage)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'totalBytesRecv', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'totalBytesSent', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(3, _omitFieldNames ? '' : 'timeMillis')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNetTotalsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNetTotalsResponse copyWith(void Function(GetNetTotalsResponse) updates) =>
      super.copyWith((message) => updates(message as GetNetTotalsResponse)) as GetNetTotalsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNetTotalsResponse() / GetNetTotalsResponse.new instead')
  static GetNetTotalsResponse create() => GetNetTotalsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetNetTotalsResponse._();
  @$core.override
  GetNetTotalsResponse createEmptyInstance() => GetNetTotalsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetNetTotalsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNetTotalsResponse>(GetNetTotalsResponse.$_createMessage);
  static GetNetTotalsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get totalBytesRecv => $_getI64(0);
  @$pb.TagNumber(1)
  set totalBytesRecv($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalBytesRecv() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalBytesRecv() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalBytesSent => $_getI64(1);
  @$pb.TagNumber(2)
  set totalBytesSent($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalBytesSent() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalBytesSent() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timeMillis => $_getI64(2);
  @$pb.TagNumber(3)
  set timeMillis($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimeMillis() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimeMillis() => $_clearField(3);
}

class GetNewAddressRequest extends $pb.GeneratedMessage {
  factory GetNewAddressRequest({
    $core.String? label,
    $core.String? addressType,
    $core.String? wallet,
  }) {
    final result = GetNewAddressRequest._();
    if (label != null) result.label = label;
    if (addressType != null) result.addressType = addressType;
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  GetNewAddressRequest._();

  factory GetNewAddressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressRequest()..mergeFromBuffer(data, registry);
  factory GetNewAddressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetNewAddressRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aOS(2, _omitFieldNames ? '' : 'addressType')
    ..aOS(3, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressRequest copyWith(void Function(GetNewAddressRequest) updates) =>
      super.copyWith((message) => updates(message as GetNewAddressRequest)) as GetNewAddressRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNewAddressRequest() / GetNewAddressRequest.new instead')
  static GetNewAddressRequest create() => GetNewAddressRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetNewAddressRequest._();
  @$core.override
  GetNewAddressRequest createEmptyInstance() => GetNewAddressRequest._();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNewAddressRequest>(GetNewAddressRequest.$_createMessage);
  static GetNewAddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get addressType => $_getSZ(1);
  @$pb.TagNumber(2)
  set addressType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddressType() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddressType() => $_clearField(2);

  /// Only needs to be set if dealing with multiple wallets at the same time.
  /// TODO: better suited as a header?
  @$pb.TagNumber(3)
  $core.String get wallet => $_getSZ(2);
  @$pb.TagNumber(3)
  set wallet($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWallet() => $_has(2);
  @$pb.TagNumber(3)
  void clearWallet() => $_clearField(3);
}

class GetNewAddressResponse extends $pb.GeneratedMessage {
  factory GetNewAddressResponse({
    $core.String? address,
  }) {
    final result = GetNewAddressResponse._();
    if (address != null) result.address = address;
    return result;
  }

  GetNewAddressResponse._();

  factory GetNewAddressResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressResponse()..mergeFromBuffer(data, registry);
  factory GetNewAddressResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetNewAddressResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressResponse copyWith(void Function(GetNewAddressResponse) updates) =>
      super.copyWith((message) => updates(message as GetNewAddressResponse)) as GetNewAddressResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNewAddressResponse() / GetNewAddressResponse.new instead')
  static GetNewAddressResponse create() => GetNewAddressResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetNewAddressResponse._();
  @$core.override
  GetNewAddressResponse createEmptyInstance() => GetNewAddressResponse._();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNewAddressResponse>(GetNewAddressResponse.$_createMessage);
  static GetNewAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);
}

class GetWalletInfoRequest extends $pb.GeneratedMessage {
  factory GetWalletInfoRequest({
    $core.String? wallet,
  }) {
    final result = GetWalletInfoRequest._();
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  GetWalletInfoRequest._();

  factory GetWalletInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletInfoRequest()..mergeFromBuffer(data, registry);
  factory GetWalletInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetWalletInfoRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletInfoRequest copyWith(void Function(GetWalletInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetWalletInfoRequest)) as GetWalletInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetWalletInfoRequest() / GetWalletInfoRequest.new instead')
  static GetWalletInfoRequest create() => GetWalletInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetWalletInfoRequest._();
  @$core.override
  GetWalletInfoRequest createEmptyInstance() => GetWalletInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetWalletInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWalletInfoRequest>(GetWalletInfoRequest.$_createMessage);
  static GetWalletInfoRequest? _defaultInstance;

  /// Only needs to be set if dealing with multiple wallets at the same time.
  /// TODO: better suited as a header?
  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => $_clearField(1);
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
    final result = GetWalletInfoResponse._();
    if (walletName != null) result.walletName = walletName;
    if (walletVersion != null) result.walletVersion = walletVersion;
    if (format != null) result.format = format;
    if (txCount != null) result.txCount = txCount;
    if (keyPoolSize != null) result.keyPoolSize = keyPoolSize;
    if (keyPoolSizeHdInternal != null) result.keyPoolSizeHdInternal = keyPoolSizeHdInternal;
    if (payTxFee != null) result.payTxFee = payTxFee;
    if (privateKeysEnabled != null) result.privateKeysEnabled = privateKeysEnabled;
    if (avoidReuse != null) result.avoidReuse = avoidReuse;
    if (scanning != null) result.scanning = scanning;
    if (descriptors != null) result.descriptors = descriptors;
    if (externalSigner != null) result.externalSigner = externalSigner;
    return result;
  }

  GetWalletInfoResponse._();

  factory GetWalletInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletInfoResponse()..mergeFromBuffer(data, registry);
  factory GetWalletInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetWalletInfoResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletName')
    ..aInt64(2, _omitFieldNames ? '' : 'walletVersion')
    ..aOS(3, _omitFieldNames ? '' : 'format')
    ..aInt64(7, _omitFieldNames ? '' : 'txCount')
    ..aInt64(8, _omitFieldNames ? '' : 'keyPoolSize')
    ..aInt64(9, _omitFieldNames ? '' : 'keyPoolSizeHdInternal')
    ..aD(10, _omitFieldNames ? '' : 'payTxFee')
    ..aOB(11, _omitFieldNames ? '' : 'privateKeysEnabled')
    ..aOB(12, _omitFieldNames ? '' : 'avoidReuse')
    ..aOM<WalletScan>(13, _omitFieldNames ? '' : 'scanning', subBuilder: WalletScan.$_createMessage)
    ..aOB(14, _omitFieldNames ? '' : 'descriptors')
    ..aOB(15, _omitFieldNames ? '' : 'externalSigner')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletInfoResponse copyWith(void Function(GetWalletInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetWalletInfoResponse)) as GetWalletInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetWalletInfoResponse() / GetWalletInfoResponse.new instead')
  static GetWalletInfoResponse create() => GetWalletInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetWalletInfoResponse._();
  @$core.override
  GetWalletInfoResponse createEmptyInstance() => GetWalletInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetWalletInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWalletInfoResponse>(GetWalletInfoResponse.$_createMessage);
  static GetWalletInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletName => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletName() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletName() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get walletVersion => $_getI64(1);
  @$pb.TagNumber(2)
  set walletVersion($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get format => $_getSZ(2);
  @$pb.TagNumber(3)
  set format($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFormat() => $_has(2);
  @$pb.TagNumber(3)
  void clearFormat() => $_clearField(3);

  @$pb.TagNumber(7)
  $fixnum.Int64 get txCount => $_getI64(3);
  @$pb.TagNumber(7)
  set txCount($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(7)
  $core.bool hasTxCount() => $_has(3);
  @$pb.TagNumber(7)
  void clearTxCount() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get keyPoolSize => $_getI64(4);
  @$pb.TagNumber(8)
  set keyPoolSize($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(8)
  $core.bool hasKeyPoolSize() => $_has(4);
  @$pb.TagNumber(8)
  void clearKeyPoolSize() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get keyPoolSizeHdInternal => $_getI64(5);
  @$pb.TagNumber(9)
  set keyPoolSizeHdInternal($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(9)
  $core.bool hasKeyPoolSizeHdInternal() => $_has(5);
  @$pb.TagNumber(9)
  void clearKeyPoolSizeHdInternal() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get payTxFee => $_getN(6);
  @$pb.TagNumber(10)
  set payTxFee($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(10)
  $core.bool hasPayTxFee() => $_has(6);
  @$pb.TagNumber(10)
  void clearPayTxFee() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get privateKeysEnabled => $_getBF(7);
  @$pb.TagNumber(11)
  set privateKeysEnabled($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(11)
  $core.bool hasPrivateKeysEnabled() => $_has(7);
  @$pb.TagNumber(11)
  void clearPrivateKeysEnabled() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get avoidReuse => $_getBF(8);
  @$pb.TagNumber(12)
  set avoidReuse($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(12)
  $core.bool hasAvoidReuse() => $_has(8);
  @$pb.TagNumber(12)
  void clearAvoidReuse() => $_clearField(12);

  /// Not set if no scan is in progress.
  @$pb.TagNumber(13)
  WalletScan get scanning => $_getN(9);
  @$pb.TagNumber(13)
  set scanning(WalletScan value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasScanning() => $_has(9);
  @$pb.TagNumber(13)
  void clearScanning() => $_clearField(13);
  @$pb.TagNumber(13)
  WalletScan ensureScanning() => $_ensure(9);

  @$pb.TagNumber(14)
  $core.bool get descriptors => $_getBF(10);
  @$pb.TagNumber(14)
  set descriptors($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(14)
  $core.bool hasDescriptors() => $_has(10);
  @$pb.TagNumber(14)
  void clearDescriptors() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get externalSigner => $_getBF(11);
  @$pb.TagNumber(15)
  set externalSigner($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(15)
  $core.bool hasExternalSigner() => $_has(11);
  @$pb.TagNumber(15)
  void clearExternalSigner() => $_clearField(15);
}

class GetBalancesRequest extends $pb.GeneratedMessage {
  factory GetBalancesRequest({
    $core.String? wallet,
  }) {
    final result = GetBalancesRequest._();
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  GetBalancesRequest._();

  factory GetBalancesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalancesRequest()..mergeFromBuffer(data, registry);
  factory GetBalancesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalancesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalancesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetBalancesRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalancesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalancesRequest copyWith(void Function(GetBalancesRequest) updates) =>
      super.copyWith((message) => updates(message as GetBalancesRequest)) as GetBalancesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBalancesRequest() / GetBalancesRequest.new instead')
  static GetBalancesRequest create() => GetBalancesRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBalancesRequest._();
  @$core.override
  GetBalancesRequest createEmptyInstance() => GetBalancesRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBalancesRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalancesRequest>(GetBalancesRequest.$_createMessage);
  static GetBalancesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => $_clearField(1);
}

/// balances from outputs that the wallet can sign
class GetBalancesResponse_Mine extends $pb.GeneratedMessage {
  factory GetBalancesResponse_Mine({
    $core.double? trusted,
    $core.double? untrustedPending,
    $core.double? immature,
    $core.double? used,
  }) {
    final result = GetBalancesResponse_Mine._();
    if (trusted != null) result.trusted = trusted;
    if (untrustedPending != null) result.untrustedPending = untrustedPending;
    if (immature != null) result.immature = immature;
    if (used != null) result.used = used;
    return result;
  }

  GetBalancesResponse_Mine._();

  factory GetBalancesResponse_Mine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalancesResponse_Mine()..mergeFromBuffer(data, registry);
  factory GetBalancesResponse_Mine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalancesResponse_Mine()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalancesResponse.Mine',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetBalancesResponse_Mine.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'trusted')
    ..aD(2, _omitFieldNames ? '' : 'untrustedPending')
    ..aD(3, _omitFieldNames ? '' : 'immature')
    ..aD(4, _omitFieldNames ? '' : 'used')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalancesResponse_Mine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalancesResponse_Mine copyWith(void Function(GetBalancesResponse_Mine) updates) =>
      super.copyWith((message) => updates(message as GetBalancesResponse_Mine)) as GetBalancesResponse_Mine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBalancesResponse_Mine() / GetBalancesResponse_Mine.new instead')
  static GetBalancesResponse_Mine create() => GetBalancesResponse_Mine._();
  static $pb.GeneratedMessage $_createMessage() => GetBalancesResponse_Mine._();
  @$core.override
  GetBalancesResponse_Mine createEmptyInstance() => GetBalancesResponse_Mine._();
  @$core.pragma('dart2js:noInline')
  static GetBalancesResponse_Mine getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBalancesResponse_Mine>(GetBalancesResponse_Mine.$_createMessage);
  static GetBalancesResponse_Mine? _defaultInstance;

  /// trusted balance (outputs created by the wallet or confirmed outputs)
  @$pb.TagNumber(1)
  $core.double get trusted => $_getN(0);
  @$pb.TagNumber(1)
  set trusted($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTrusted() => $_has(0);
  @$pb.TagNumber(1)
  void clearTrusted() => $_clearField(1);

  /// untrusted pending balance (outputs created by others that are in the mempool)
  @$pb.TagNumber(2)
  $core.double get untrustedPending => $_getN(1);
  @$pb.TagNumber(2)
  set untrustedPending($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUntrustedPending() => $_has(1);
  @$pb.TagNumber(2)
  void clearUntrustedPending() => $_clearField(2);

  /// balance from immature coinbase outputs
  @$pb.TagNumber(3)
  $core.double get immature => $_getN(2);
  @$pb.TagNumber(3)
  set immature($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasImmature() => $_has(2);
  @$pb.TagNumber(3)
  void clearImmature() => $_clearField(3);

  /// only present if avoid_reuse is set) balance from coins sent to addresses that were previously spent from (potentially privacy violating
  @$pb.TagNumber(4)
  $core.double get used => $_getN(3);
  @$pb.TagNumber(4)
  set used($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUsed() => $_has(3);
  @$pb.TagNumber(4)
  void clearUsed() => $_clearField(4);
}

/// watchonly balances (not present if wallet does not watch anything)
class GetBalancesResponse_Watchonly extends $pb.GeneratedMessage {
  factory GetBalancesResponse_Watchonly({
    $core.double? trusted,
    $core.double? untrustedPending,
    $core.double? immature,
  }) {
    final result = GetBalancesResponse_Watchonly._();
    if (trusted != null) result.trusted = trusted;
    if (untrustedPending != null) result.untrustedPending = untrustedPending;
    if (immature != null) result.immature = immature;
    return result;
  }

  GetBalancesResponse_Watchonly._();

  factory GetBalancesResponse_Watchonly.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalancesResponse_Watchonly()..mergeFromBuffer(data, registry);
  factory GetBalancesResponse_Watchonly.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalancesResponse_Watchonly()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalancesResponse.Watchonly',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetBalancesResponse_Watchonly.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'trusted')
    ..aD(2, _omitFieldNames ? '' : 'untrustedPending')
    ..aD(3, _omitFieldNames ? '' : 'immature')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalancesResponse_Watchonly clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalancesResponse_Watchonly copyWith(void Function(GetBalancesResponse_Watchonly) updates) =>
      super.copyWith((message) => updates(message as GetBalancesResponse_Watchonly)) as GetBalancesResponse_Watchonly;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBalancesResponse_Watchonly() / GetBalancesResponse_Watchonly.new instead')
  static GetBalancesResponse_Watchonly create() => GetBalancesResponse_Watchonly._();
  static $pb.GeneratedMessage $_createMessage() => GetBalancesResponse_Watchonly._();
  @$core.override
  GetBalancesResponse_Watchonly createEmptyInstance() => GetBalancesResponse_Watchonly._();
  @$core.pragma('dart2js:noInline')
  static GetBalancesResponse_Watchonly getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBalancesResponse_Watchonly>(GetBalancesResponse_Watchonly.$_createMessage);
  static GetBalancesResponse_Watchonly? _defaultInstance;

  /// trusted balance (outputs created by the wallet or confirmed outputs)
  @$pb.TagNumber(1)
  $core.double get trusted => $_getN(0);
  @$pb.TagNumber(1)
  set trusted($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTrusted() => $_has(0);
  @$pb.TagNumber(1)
  void clearTrusted() => $_clearField(1);

  /// untrusted pending balance (outputs created by others that are in the mempool)
  @$pb.TagNumber(2)
  $core.double get untrustedPending => $_getN(1);
  @$pb.TagNumber(2)
  set untrustedPending($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUntrustedPending() => $_has(1);
  @$pb.TagNumber(2)
  void clearUntrustedPending() => $_clearField(2);

  /// balance from immature coinbase outputs
  @$pb.TagNumber(3)
  $core.double get immature => $_getN(2);
  @$pb.TagNumber(3)
  set immature($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasImmature() => $_has(2);
  @$pb.TagNumber(3)
  void clearImmature() => $_clearField(3);
}

class GetBalancesResponse extends $pb.GeneratedMessage {
  factory GetBalancesResponse({
    GetBalancesResponse_Mine? mine,
    GetBalancesResponse_Watchonly? watchonly,
  }) {
    final result = GetBalancesResponse._();
    if (mine != null) result.mine = mine;
    if (watchonly != null) result.watchonly = watchonly;
    return result;
  }

  GetBalancesResponse._();

  factory GetBalancesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalancesResponse()..mergeFromBuffer(data, registry);
  factory GetBalancesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalancesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalancesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetBalancesResponse.$_createMessage)
    ..aOM<GetBalancesResponse_Mine>(1, _omitFieldNames ? '' : 'mine',
        subBuilder: GetBalancesResponse_Mine.$_createMessage)
    ..aOM<GetBalancesResponse_Watchonly>(2, _omitFieldNames ? '' : 'watchonly',
        subBuilder: GetBalancesResponse_Watchonly.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalancesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalancesResponse copyWith(void Function(GetBalancesResponse) updates) =>
      super.copyWith((message) => updates(message as GetBalancesResponse)) as GetBalancesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBalancesResponse() / GetBalancesResponse.new instead')
  static GetBalancesResponse create() => GetBalancesResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBalancesResponse._();
  @$core.override
  GetBalancesResponse createEmptyInstance() => GetBalancesResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBalancesResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalancesResponse>(GetBalancesResponse.$_createMessage);
  static GetBalancesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GetBalancesResponse_Mine get mine => $_getN(0);
  @$pb.TagNumber(1)
  set mine(GetBalancesResponse_Mine value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMine() => $_has(0);
  @$pb.TagNumber(1)
  void clearMine() => $_clearField(1);
  @$pb.TagNumber(1)
  GetBalancesResponse_Mine ensureMine() => $_ensure(0);

  @$pb.TagNumber(2)
  GetBalancesResponse_Watchonly get watchonly => $_getN(1);
  @$pb.TagNumber(2)
  set watchonly(GetBalancesResponse_Watchonly value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasWatchonly() => $_has(1);
  @$pb.TagNumber(2)
  void clearWatchonly() => $_clearField(2);
  @$pb.TagNumber(2)
  GetBalancesResponse_Watchonly ensureWatchonly() => $_ensure(1);
}

class WalletScan extends $pb.GeneratedMessage {
  factory WalletScan({
    $fixnum.Int64? duration,
    $core.double? progress,
  }) {
    final result = WalletScan._();
    if (duration != null) result.duration = duration;
    if (progress != null) result.progress = progress;
    return result;
  }

  WalletScan._();

  factory WalletScan.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WalletScan()..mergeFromBuffer(data, registry);
  factory WalletScan.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WalletScan()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WalletScan',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: WalletScan.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'duration')
    ..aD(2, _omitFieldNames ? '' : 'progress')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WalletScan clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WalletScan copyWith(void Function(WalletScan) updates) =>
      super.copyWith((message) => updates(message as WalletScan)) as WalletScan;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WalletScan() / WalletScan.new instead')
  static WalletScan create() => WalletScan._();
  static $pb.GeneratedMessage $_createMessage() => WalletScan._();
  @$core.override
  WalletScan createEmptyInstance() => WalletScan._();
  @$core.pragma('dart2js:noInline')
  static WalletScan getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WalletScan>(WalletScan.$_createMessage);
  static WalletScan? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get duration => $_getI64(0);
  @$pb.TagNumber(1)
  set duration($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDuration() => $_has(0);
  @$pb.TagNumber(1)
  void clearDuration() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get progress => $_getN(1);
  @$pb.TagNumber(2)
  set progress($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProgress() => $_has(1);
  @$pb.TagNumber(2)
  void clearProgress() => $_clearField(2);
}

class GetTransactionRequest extends $pb.GeneratedMessage {
  factory GetTransactionRequest({
    $core.String? txid,
    $core.bool? verbose,
    $core.String? wallet,
  }) {
    final result = GetTransactionRequest._();
    if (txid != null) result.txid = txid;
    if (verbose != null) result.verbose = verbose;
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  GetTransactionRequest._();

  factory GetTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionRequest()..mergeFromBuffer(data, registry);
  factory GetTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetTransactionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOB(3, _omitFieldNames ? '' : 'verbose')
    ..aOS(4, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionRequest copyWith(void Function(GetTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as GetTransactionRequest)) as GetTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTransactionRequest() / GetTransactionRequest.new instead')
  static GetTransactionRequest create() => GetTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetTransactionRequest._();
  @$core.override
  GetTransactionRequest createEmptyInstance() => GetTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static GetTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionRequest>(GetTransactionRequest.$_createMessage);
  static GetTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(3)
  $core.bool get verbose => $_getBF(1);
  @$pb.TagNumber(3)
  set verbose($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(3)
  $core.bool hasVerbose() => $_has(1);
  @$pb.TagNumber(3)
  void clearVerbose() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get wallet => $_getSZ(2);
  @$pb.TagNumber(4)
  set wallet($core.String value) => $_setString(2, value);
  @$pb.TagNumber(4)
  $core.bool hasWallet() => $_has(2);
  @$pb.TagNumber(4)
  void clearWallet() => $_clearField(4);
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
    final result = GetTransactionResponse_Details._();
    if (involvesWatchOnly != null) result.involvesWatchOnly = involvesWatchOnly;
    if (address != null) result.address = address;
    if (category != null) result.category = category;
    if (amount != null) result.amount = amount;
    if (vout != null) result.vout = vout;
    if (fee != null) result.fee = fee;
    return result;
  }

  GetTransactionResponse_Details._();

  factory GetTransactionResponse_Details.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionResponse_Details()..mergeFromBuffer(data, registry);
  factory GetTransactionResponse_Details.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionResponse_Details()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionResponse.Details',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetTransactionResponse_Details.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'involvesWatchOnly')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aE<GetTransactionResponse_Category>(3, _omitFieldNames ? '' : 'category',
        enumValues: GetTransactionResponse_Category.values)
    ..aD(4, _omitFieldNames ? '' : 'amount')
    ..aI(6, _omitFieldNames ? '' : 'vout', fieldType: $pb.PbFieldType.OU3)
    ..aD(7, _omitFieldNames ? '' : 'fee')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionResponse_Details clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionResponse_Details copyWith(void Function(GetTransactionResponse_Details) updates) =>
      super.copyWith((message) => updates(message as GetTransactionResponse_Details)) as GetTransactionResponse_Details;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTransactionResponse_Details() / GetTransactionResponse_Details.new instead')
  static GetTransactionResponse_Details create() => GetTransactionResponse_Details._();
  static $pb.GeneratedMessage $_createMessage() => GetTransactionResponse_Details._();
  @$core.override
  GetTransactionResponse_Details createEmptyInstance() => GetTransactionResponse_Details._();
  @$core.pragma('dart2js:noInline')
  static GetTransactionResponse_Details getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionResponse_Details>(GetTransactionResponse_Details.$_createMessage);
  static GetTransactionResponse_Details? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get involvesWatchOnly => $_getBF(0);
  @$pb.TagNumber(1)
  set involvesWatchOnly($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInvolvesWatchOnly() => $_has(0);
  @$pb.TagNumber(1)
  void clearInvolvesWatchOnly() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  GetTransactionResponse_Category get category => $_getN(2);
  @$pb.TagNumber(3)
  set category(GetTransactionResponse_Category value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCategory() => $_has(2);
  @$pb.TagNumber(3)
  void clearCategory() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get amount => $_getN(3);
  @$pb.TagNumber(4)
  set amount($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => $_clearField(4);

  /// string label = 5;
  @$pb.TagNumber(6)
  $core.int get vout => $_getIZ(4);
  @$pb.TagNumber(6)
  set vout($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(6)
  $core.bool hasVout() => $_has(4);
  @$pb.TagNumber(6)
  void clearVout() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get fee => $_getN(5);
  @$pb.TagNumber(7)
  set fee($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(7)
  $core.bool hasFee() => $_has(5);
  @$pb.TagNumber(7)
  void clearFee() => $_clearField(7);
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
    final result = GetTransactionResponse._();
    if (amount != null) result.amount = amount;
    if (fee != null) result.fee = fee;
    if (confirmations != null) result.confirmations = confirmations;
    if (blockHash != null) result.blockHash = blockHash;
    if (blockIndex != null) result.blockIndex = blockIndex;
    if (blockTime != null) result.blockTime = blockTime;
    if (txid != null) result.txid = txid;
    if (walletConflicts != null) result.walletConflicts.addAll(walletConflicts);
    if (replacedByTxid != null) result.replacedByTxid = replacedByTxid;
    if (replacesTxid != null) result.replacesTxid = replacesTxid;
    if (time != null) result.time = time;
    if (timeReceived != null) result.timeReceived = timeReceived;
    if (bip125Replaceable != null) result.bip125Replaceable = bip125Replaceable;
    if (details != null) result.details.addAll(details);
    if (hex != null) result.hex = hex;
    return result;
  }

  GetTransactionResponse._();

  factory GetTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionResponse()..mergeFromBuffer(data, registry);
  factory GetTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetTransactionResponse.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'amount')
    ..aD(2, _omitFieldNames ? '' : 'fee')
    ..aI(3, _omitFieldNames ? '' : 'confirmations')
    ..aOS(6, _omitFieldNames ? '' : 'blockHash')
    ..aI(8, _omitFieldNames ? '' : 'blockIndex', fieldType: $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'blockTime', subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(10, _omitFieldNames ? '' : 'txid')
    ..pPS(12, _omitFieldNames ? '' : 'walletConflicts')
    ..aOS(13, _omitFieldNames ? '' : 'replacedByTxid')
    ..aOS(14, _omitFieldNames ? '' : 'replacesTxid')
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'time', subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(18, _omitFieldNames ? '' : 'timeReceived', subBuilder: $0.Timestamp.$_createMessage)
    ..aE<GetTransactionResponse_Replaceable>(19, _omitFieldNames ? '' : 'bip125Replaceable',
        enumValues: GetTransactionResponse_Replaceable.values)
    ..pPM<GetTransactionResponse_Details>(21, _omitFieldNames ? '' : 'details',
        subBuilder: GetTransactionResponse_Details.$_createMessage)
    ..aOS(22, _omitFieldNames ? '' : 'hex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionResponse copyWith(void Function(GetTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as GetTransactionResponse)) as GetTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTransactionResponse() / GetTransactionResponse.new instead')
  static GetTransactionResponse create() => GetTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetTransactionResponse._();
  @$core.override
  GetTransactionResponse createEmptyInstance() => GetTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static GetTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionResponse>(GetTransactionResponse.$_createMessage);
  static GetTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get amount => $_getN(0);
  @$pb.TagNumber(1)
  set amount($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAmount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAmount() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get fee => $_getN(1);
  @$pb.TagNumber(2)
  set fee($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFee() => $_has(1);
  @$pb.TagNumber(2)
  void clearFee() => $_clearField(2);

  /// The number of confirmations for the transaction. Negative
  /// confirmations means the transaction conflicted that many
  /// blocks ago.
  @$pb.TagNumber(3)
  $core.int get confirmations => $_getIZ(2);
  @$pb.TagNumber(3)
  set confirmations($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConfirmations() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfirmations() => $_clearField(3);

  /// bool generated = 4;
  /// bool trusted = 5;
  @$pb.TagNumber(6)
  $core.String get blockHash => $_getSZ(3);
  @$pb.TagNumber(6)
  set blockHash($core.String value) => $_setString(3, value);
  @$pb.TagNumber(6)
  $core.bool hasBlockHash() => $_has(3);
  @$pb.TagNumber(6)
  void clearBlockHash() => $_clearField(6);

  /// string block_height = 7;
  @$pb.TagNumber(8)
  $core.int get blockIndex => $_getIZ(4);
  @$pb.TagNumber(8)
  set blockIndex($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(8)
  $core.bool hasBlockIndex() => $_has(4);
  @$pb.TagNumber(8)
  void clearBlockIndex() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get blockTime => $_getN(5);
  @$pb.TagNumber(9)
  set blockTime($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasBlockTime() => $_has(5);
  @$pb.TagNumber(9)
  void clearBlockTime() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureBlockTime() => $_ensure(5);

  @$pb.TagNumber(10)
  $core.String get txid => $_getSZ(6);
  @$pb.TagNumber(10)
  set txid($core.String value) => $_setString(6, value);
  @$pb.TagNumber(10)
  $core.bool hasTxid() => $_has(6);
  @$pb.TagNumber(10)
  void clearTxid() => $_clearField(10);

  /// string witness_txid = 11;
  @$pb.TagNumber(12)
  $pb.PbList<$core.String> get walletConflicts => $_getList(7);

  @$pb.TagNumber(13)
  $core.String get replacedByTxid => $_getSZ(8);
  @$pb.TagNumber(13)
  set replacedByTxid($core.String value) => $_setString(8, value);
  @$pb.TagNumber(13)
  $core.bool hasReplacedByTxid() => $_has(8);
  @$pb.TagNumber(13)
  void clearReplacedByTxid() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get replacesTxid => $_getSZ(9);
  @$pb.TagNumber(14)
  set replacesTxid($core.String value) => $_setString(9, value);
  @$pb.TagNumber(14)
  $core.bool hasReplacesTxid() => $_has(9);
  @$pb.TagNumber(14)
  void clearReplacesTxid() => $_clearField(14);

  /// string comment = 15;
  /// string to = 16;
  @$pb.TagNumber(17)
  $0.Timestamp get time => $_getN(10);
  @$pb.TagNumber(17)
  set time($0.Timestamp value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasTime() => $_has(10);
  @$pb.TagNumber(17)
  void clearTime() => $_clearField(17);
  @$pb.TagNumber(17)
  $0.Timestamp ensureTime() => $_ensure(10);

  @$pb.TagNumber(18)
  $0.Timestamp get timeReceived => $_getN(11);
  @$pb.TagNumber(18)
  set timeReceived($0.Timestamp value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasTimeReceived() => $_has(11);
  @$pb.TagNumber(18)
  void clearTimeReceived() => $_clearField(18);
  @$pb.TagNumber(18)
  $0.Timestamp ensureTimeReceived() => $_ensure(11);

  /// Whether this transaction signals BIP125 (Replace-by-fee, RBF) replaceability
  /// or has an unconfirmed ancestor signaling BIP125 replaceability. May be unspecified
  /// for unconfirmed transactions not in the mempool because their
  /// unconfirmed ancestors are unknown.
  ///
  /// Note that this is always set to 'no' once the transaction is confirmed.
  @$pb.TagNumber(19)
  GetTransactionResponse_Replaceable get bip125Replaceable => $_getN(12);
  @$pb.TagNumber(19)
  set bip125Replaceable(GetTransactionResponse_Replaceable value) => $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasBip125Replaceable() => $_has(12);
  @$pb.TagNumber(19)
  void clearBip125Replaceable() => $_clearField(19);

  @$pb.TagNumber(21)
  $pb.PbList<GetTransactionResponse_Details> get details => $_getList(13);

  @$pb.TagNumber(22)
  $core.String get hex => $_getSZ(14);
  @$pb.TagNumber(22)
  set hex($core.String value) => $_setString(14, value);
  @$pb.TagNumber(22)
  $core.bool hasHex() => $_has(14);
  @$pb.TagNumber(22)
  void clearHex() => $_clearField(22);
}

class GetRawTransactionRequest extends $pb.GeneratedMessage {
  factory GetRawTransactionRequest({
    $core.String? txid,
    GetRawTransactionRequest_Verbosity? verbosity,
    $core.String? blockhash,
  }) {
    final result = GetRawTransactionRequest._();
    if (txid != null) result.txid = txid;
    if (verbosity != null) result.verbosity = verbosity;
    if (blockhash != null) result.blockhash = blockhash;
    return result;
  }

  GetRawTransactionRequest._();

  factory GetRawTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRawTransactionRequest()..mergeFromBuffer(data, registry);
  factory GetRawTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRawTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRawTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetRawTransactionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aE<GetRawTransactionRequest_Verbosity>(2, _omitFieldNames ? '' : 'verbosity',
        enumValues: GetRawTransactionRequest_Verbosity.values)
    ..aOS(3, _omitFieldNames ? '' : 'blockhash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRawTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRawTransactionRequest copyWith(void Function(GetRawTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as GetRawTransactionRequest)) as GetRawTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetRawTransactionRequest() / GetRawTransactionRequest.new instead')
  static GetRawTransactionRequest create() => GetRawTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetRawTransactionRequest._();
  @$core.override
  GetRawTransactionRequest createEmptyInstance() => GetRawTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static GetRawTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRawTransactionRequest>(GetRawTransactionRequest.$_createMessage);
  static GetRawTransactionRequest? _defaultInstance;

  /// The transaction ID. Required.
  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  /// Note: this does NOT map to the Bitcoin Core verbosity parameter.
  /// Core 0 -> VERBOSITY_RAW_DATA
  /// Core 1 -> VERBOSITY_UNSPECIFIED
  /// Core 2 -> VERBOSITY_TX_INFO
  /// Core 3 -> VERBOSITY_TX_PREVOUT_INFO
  @$pb.TagNumber(2)
  GetRawTransactionRequest_Verbosity get verbosity => $_getN(1);
  @$pb.TagNumber(2)
  set verbosity(GetRawTransactionRequest_Verbosity value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasVerbosity() => $_has(1);
  @$pb.TagNumber(2)
  void clearVerbosity() => $_clearField(2);

  /// The block in which to look for the transaction
  @$pb.TagNumber(3)
  $core.String get blockhash => $_getSZ(2);
  @$pb.TagNumber(3)
  set blockhash($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBlockhash() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockhash() => $_clearField(3);
}

class ScriptSig extends $pb.GeneratedMessage {
  factory ScriptSig({
    $core.String? asm,
    $core.String? hex,
  }) {
    final result = ScriptSig._();
    if (asm != null) result.asm = asm;
    if (hex != null) result.hex = hex;
    return result;
  }

  ScriptSig._();

  factory ScriptSig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ScriptSig()..mergeFromBuffer(data, registry);
  factory ScriptSig.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ScriptSig()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScriptSig',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ScriptSig.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'asm')
    ..aOS(2, _omitFieldNames ? '' : 'hex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScriptSig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScriptSig copyWith(void Function(ScriptSig) updates) =>
      super.copyWith((message) => updates(message as ScriptSig)) as ScriptSig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ScriptSig() / ScriptSig.new instead')
  static ScriptSig create() => ScriptSig._();
  static $pb.GeneratedMessage $_createMessage() => ScriptSig._();
  @$core.override
  ScriptSig createEmptyInstance() => ScriptSig._();
  @$core.pragma('dart2js:noInline')
  static ScriptSig getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScriptSig>(ScriptSig.$_createMessage);
  static ScriptSig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get asm => $_getSZ(0);
  @$pb.TagNumber(1)
  set asm($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAsm() => $_has(0);
  @$pb.TagNumber(1)
  void clearAsm() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get hex => $_getSZ(1);
  @$pb.TagNumber(2)
  set hex($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearHex() => $_clearField(2);
}

class PreviousOutput extends $pb.GeneratedMessage {
  factory PreviousOutput({
    $core.bool? generated,
    $core.int? height,
    $core.double? amount,
    ScriptPubKey? scriptPubKey,
  }) {
    final result = PreviousOutput._();
    if (generated != null) result.generated = generated;
    if (height != null) result.height = height;
    if (amount != null) result.amount = amount;
    if (scriptPubKey != null) result.scriptPubKey = scriptPubKey;
    return result;
  }

  PreviousOutput._();

  factory PreviousOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviousOutput()..mergeFromBuffer(data, registry);
  factory PreviousOutput.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviousOutput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PreviousOutput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: PreviousOutput.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'generated')
    ..aI(2, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..aD(3, _omitFieldNames ? '' : 'amount')
    ..aOM<ScriptPubKey>(4, _omitFieldNames ? '' : 'scriptPubKey', subBuilder: ScriptPubKey.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviousOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviousOutput copyWith(void Function(PreviousOutput) updates) =>
      super.copyWith((message) => updates(message as PreviousOutput)) as PreviousOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PreviousOutput() / PreviousOutput.new instead')
  static PreviousOutput create() => PreviousOutput._();
  static $pb.GeneratedMessage $_createMessage() => PreviousOutput._();
  @$core.override
  PreviousOutput createEmptyInstance() => PreviousOutput._();
  @$core.pragma('dart2js:noInline')
  static PreviousOutput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PreviousOutput>(PreviousOutput.$_createMessage);
  static PreviousOutput? _defaultInstance;

  /// Indicates the previous output was a coinbase output.
  @$pb.TagNumber(1)
  $core.bool get generated => $_getBF(0);
  @$pb.TagNumber(1)
  set generated($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGenerated() => $_has(0);
  @$pb.TagNumber(1)
  void clearGenerated() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get height => $_getIZ(1);
  @$pb.TagNumber(2)
  set height($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => $_clearField(2);

  /// BTC amount of the previous output.
  @$pb.TagNumber(3)
  $core.double get amount => $_getN(2);
  @$pb.TagNumber(3)
  set amount($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => $_clearField(3);

  @$pb.TagNumber(4)
  ScriptPubKey get scriptPubKey => $_getN(3);
  @$pb.TagNumber(4)
  set scriptPubKey(ScriptPubKey value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasScriptPubKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearScriptPubKey() => $_clearField(4);
  @$pb.TagNumber(4)
  ScriptPubKey ensureScriptPubKey() => $_ensure(3);
}

class Input extends $pb.GeneratedMessage {
  factory Input({
    $core.String? txid,
    $core.int? vout,
    $core.String? coinbase,
    ScriptSig? scriptSig,
    $core.int? sequence,
    $core.Iterable<$core.String>? witness,
    PreviousOutput? previousOutput,
  }) {
    final result = Input._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (coinbase != null) result.coinbase = coinbase;
    if (scriptSig != null) result.scriptSig = scriptSig;
    if (sequence != null) result.sequence = sequence;
    if (witness != null) result.witness.addAll(witness);
    if (previousOutput != null) result.previousOutput = previousOutput;
    return result;
  }

  Input._();

  factory Input.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Input()..mergeFromBuffer(data, registry);
  factory Input.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Input()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Input',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: Input.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'vout', fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'coinbase')
    ..aOM<ScriptSig>(4, _omitFieldNames ? '' : 'scriptSig', subBuilder: ScriptSig.$_createMessage)
    ..aI(5, _omitFieldNames ? '' : 'sequence', fieldType: $pb.PbFieldType.OU3)
    ..pPS(6, _omitFieldNames ? '' : 'witness')
    ..aOM<PreviousOutput>(7, _omitFieldNames ? '' : 'previousOutput', subBuilder: PreviousOutput.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Input clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Input copyWith(void Function(Input) updates) => super.copyWith((message) => updates(message as Input)) as Input;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Input() / Input.new instead')
  static Input create() => Input._();
  static $pb.GeneratedMessage $_createMessage() => Input._();
  @$core.override
  Input createEmptyInstance() => Input._();
  @$core.pragma('dart2js:noInline')
  static Input getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Input>(Input.$_createMessage);
  static Input? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get coinbase => $_getSZ(2);
  @$pb.TagNumber(3)
  set coinbase($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCoinbase() => $_has(2);
  @$pb.TagNumber(3)
  void clearCoinbase() => $_clearField(3);

  @$pb.TagNumber(4)
  ScriptSig get scriptSig => $_getN(3);
  @$pb.TagNumber(4)
  set scriptSig(ScriptSig value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasScriptSig() => $_has(3);
  @$pb.TagNumber(4)
  void clearScriptSig() => $_clearField(4);
  @$pb.TagNumber(4)
  ScriptSig ensureScriptSig() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.int get sequence => $_getIZ(4);
  @$pb.TagNumber(5)
  set sequence($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSequence() => $_has(4);
  @$pb.TagNumber(5)
  void clearSequence() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get witness => $_getList(5);

  @$pb.TagNumber(7)
  PreviousOutput get previousOutput => $_getN(6);
  @$pb.TagNumber(7)
  set previousOutput(PreviousOutput value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasPreviousOutput() => $_has(6);
  @$pb.TagNumber(7)
  void clearPreviousOutput() => $_clearField(7);
  @$pb.TagNumber(7)
  PreviousOutput ensurePreviousOutput() => $_ensure(6);
}

class ScriptPubKey extends $pb.GeneratedMessage {
  factory ScriptPubKey({
    $core.String? type,
    $core.String? address,
    $core.String? asm,
    $core.String? hex,
    $core.int? reqSigs,
  }) {
    final result = ScriptPubKey._();
    if (type != null) result.type = type;
    if (address != null) result.address = address;
    if (asm != null) result.asm = asm;
    if (hex != null) result.hex = hex;
    if (reqSigs != null) result.reqSigs = reqSigs;
    return result;
  }

  ScriptPubKey._();

  factory ScriptPubKey.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ScriptPubKey()..mergeFromBuffer(data, registry);
  factory ScriptPubKey.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ScriptPubKey()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScriptPubKey',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ScriptPubKey.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aOS(3, _omitFieldNames ? '' : 'asm')
    ..aOS(4, _omitFieldNames ? '' : 'hex')
    ..aI(6, _omitFieldNames ? '' : 'reqSigs', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScriptPubKey clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScriptPubKey copyWith(void Function(ScriptPubKey) updates) =>
      super.copyWith((message) => updates(message as ScriptPubKey)) as ScriptPubKey;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ScriptPubKey() / ScriptPubKey.new instead')
  static ScriptPubKey create() => ScriptPubKey._();
  static $pb.GeneratedMessage $_createMessage() => ScriptPubKey._();
  @$core.override
  ScriptPubKey createEmptyInstance() => ScriptPubKey._();
  @$core.pragma('dart2js:noInline')
  static ScriptPubKey getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScriptPubKey>(ScriptPubKey.$_createMessage);
  static ScriptPubKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get asm => $_getSZ(2);
  @$pb.TagNumber(3)
  set asm($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAsm() => $_has(2);
  @$pb.TagNumber(3)
  void clearAsm() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get hex => $_getSZ(3);
  @$pb.TagNumber(4)
  set hex($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHex() => $_has(3);
  @$pb.TagNumber(4)
  void clearHex() => $_clearField(4);

  @$pb.TagNumber(6)
  $core.int get reqSigs => $_getIZ(4);
  @$pb.TagNumber(6)
  set reqSigs($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(6)
  $core.bool hasReqSigs() => $_has(4);
  @$pb.TagNumber(6)
  void clearReqSigs() => $_clearField(6);
}

class Output extends $pb.GeneratedMessage {
  factory Output({
    $core.double? amount,
    $core.int? vout,
    ScriptPubKey? scriptPubKey,
    ScriptSig? scriptSig,
  }) {
    final result = Output._();
    if (amount != null) result.amount = amount;
    if (vout != null) result.vout = vout;
    if (scriptPubKey != null) result.scriptPubKey = scriptPubKey;
    if (scriptSig != null) result.scriptSig = scriptSig;
    return result;
  }

  Output._();

  factory Output.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Output()..mergeFromBuffer(data, registry);
  factory Output.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Output()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Output',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: Output.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'amount')
    ..aI(2, _omitFieldNames ? '' : 'vout', fieldType: $pb.PbFieldType.OU3)
    ..aOM<ScriptPubKey>(3, _omitFieldNames ? '' : 'scriptPubKey', subBuilder: ScriptPubKey.$_createMessage)
    ..aOM<ScriptSig>(4, _omitFieldNames ? '' : 'scriptSig', subBuilder: ScriptSig.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Output clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Output copyWith(void Function(Output) updates) => super.copyWith((message) => updates(message as Output)) as Output;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Output() / Output.new instead')
  static Output create() => Output._();
  static $pb.GeneratedMessage $_createMessage() => Output._();
  @$core.override
  Output createEmptyInstance() => Output._();
  @$core.pragma('dart2js:noInline')
  static Output getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Output>(Output.$_createMessage);
  static Output? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get amount => $_getN(0);
  @$pb.TagNumber(1)
  set amount($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAmount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAmount() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);

  @$pb.TagNumber(3)
  ScriptPubKey get scriptPubKey => $_getN(2);
  @$pb.TagNumber(3)
  set scriptPubKey(ScriptPubKey value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasScriptPubKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearScriptPubKey() => $_clearField(3);
  @$pb.TagNumber(3)
  ScriptPubKey ensureScriptPubKey() => $_ensure(2);

  @$pb.TagNumber(4)
  ScriptSig get scriptSig => $_getN(3);
  @$pb.TagNumber(4)
  set scriptSig(ScriptSig value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasScriptSig() => $_has(3);
  @$pb.TagNumber(4)
  void clearScriptSig() => $_clearField(4);
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
    $0.Timestamp? blockTime,
    $core.String? txid,
    $core.String? hash,
    $core.int? size,
    $core.int? vsize,
    $core.int? weight,
    $core.int? version,
    $core.int? locktime,
    $core.double? fee,
  }) {
    final result = GetRawTransactionResponse._();
    if (tx != null) result.tx = tx;
    if (inputs != null) result.inputs.addAll(inputs);
    if (outputs != null) result.outputs.addAll(outputs);
    if (blockhash != null) result.blockhash = blockhash;
    if (confirmations != null) result.confirmations = confirmations;
    if (blockTime != null) result.blockTime = blockTime;
    if (txid != null) result.txid = txid;
    if (hash != null) result.hash = hash;
    if (size != null) result.size = size;
    if (vsize != null) result.vsize = vsize;
    if (weight != null) result.weight = weight;
    if (version != null) result.version = version;
    if (locktime != null) result.locktime = locktime;
    if (fee != null) result.fee = fee;
    return result;
  }

  GetRawTransactionResponse._();

  factory GetRawTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRawTransactionResponse()..mergeFromBuffer(data, registry);
  factory GetRawTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRawTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRawTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetRawTransactionResponse.$_createMessage)
    ..aOM<RawTransaction>(1, _omitFieldNames ? '' : 'tx', subBuilder: RawTransaction.$_createMessage)
    ..pPM<Input>(2, _omitFieldNames ? '' : 'inputs', subBuilder: Input.$_createMessage)
    ..pPM<Output>(3, _omitFieldNames ? '' : 'outputs', subBuilder: Output.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'blockhash')
    ..aI(5, _omitFieldNames ? '' : 'confirmations', fieldType: $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'blockTime', subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'txid')
    ..aOS(9, _omitFieldNames ? '' : 'hash')
    ..aI(10, _omitFieldNames ? '' : 'size')
    ..aI(11, _omitFieldNames ? '' : 'vsize')
    ..aI(12, _omitFieldNames ? '' : 'weight')
    ..aI(13, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..aI(14, _omitFieldNames ? '' : 'locktime', fieldType: $pb.PbFieldType.OU3)
    ..aD(15, _omitFieldNames ? '' : 'fee')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRawTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRawTransactionResponse copyWith(void Function(GetRawTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as GetRawTransactionResponse)) as GetRawTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetRawTransactionResponse() / GetRawTransactionResponse.new instead')
  static GetRawTransactionResponse create() => GetRawTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetRawTransactionResponse._();
  @$core.override
  GetRawTransactionResponse createEmptyInstance() => GetRawTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static GetRawTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRawTransactionResponse>(GetRawTransactionResponse.$_createMessage);
  static GetRawTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RawTransaction get tx => $_getN(0);
  @$pb.TagNumber(1)
  set tx(RawTransaction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTx() => $_has(0);
  @$pb.TagNumber(1)
  void clearTx() => $_clearField(1);
  @$pb.TagNumber(1)
  RawTransaction ensureTx() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<Input> get inputs => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<Output> get outputs => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get blockhash => $_getSZ(3);
  @$pb.TagNumber(4)
  set blockhash($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBlockhash() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockhash() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get confirmations => $_getIZ(4);
  @$pb.TagNumber(5)
  set confirmations($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConfirmations() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmations() => $_clearField(5);

  @$pb.TagNumber(7)
  $0.Timestamp get blockTime => $_getN(5);
  @$pb.TagNumber(7)
  set blockTime($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasBlockTime() => $_has(5);
  @$pb.TagNumber(7)
  void clearBlockTime() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureBlockTime() => $_ensure(5);

  @$pb.TagNumber(8)
  $core.String get txid => $_getSZ(6);
  @$pb.TagNumber(8)
  set txid($core.String value) => $_setString(6, value);
  @$pb.TagNumber(8)
  $core.bool hasTxid() => $_has(6);
  @$pb.TagNumber(8)
  void clearTxid() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get hash => $_getSZ(7);
  @$pb.TagNumber(9)
  set hash($core.String value) => $_setString(7, value);
  @$pb.TagNumber(9)
  $core.bool hasHash() => $_has(7);
  @$pb.TagNumber(9)
  void clearHash() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get size => $_getIZ(8);
  @$pb.TagNumber(10)
  set size($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(10)
  $core.bool hasSize() => $_has(8);
  @$pb.TagNumber(10)
  void clearSize() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get vsize => $_getIZ(9);
  @$pb.TagNumber(11)
  set vsize($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(11)
  $core.bool hasVsize() => $_has(9);
  @$pb.TagNumber(11)
  void clearVsize() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get weight => $_getIZ(10);
  @$pb.TagNumber(12)
  set weight($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(12)
  $core.bool hasWeight() => $_has(10);
  @$pb.TagNumber(12)
  void clearWeight() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get version => $_getIZ(11);
  @$pb.TagNumber(13)
  set version($core.int value) => $_setUnsignedInt32(11, value);
  @$pb.TagNumber(13)
  $core.bool hasVersion() => $_has(11);
  @$pb.TagNumber(13)
  void clearVersion() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get locktime => $_getIZ(12);
  @$pb.TagNumber(14)
  set locktime($core.int value) => $_setUnsignedInt32(12, value);
  @$pb.TagNumber(14)
  $core.bool hasLocktime() => $_has(12);
  @$pb.TagNumber(14)
  void clearLocktime() => $_clearField(14);

  /// Transaction fee in BTC. Only set for for TX info verbosity.
  @$pb.TagNumber(15)
  $core.double get fee => $_getN(13);
  @$pb.TagNumber(15)
  set fee($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(15)
  $core.bool hasFee() => $_has(13);
  @$pb.TagNumber(15)
  void clearFee() => $_clearField(15);
}

class SendRequest extends $pb.GeneratedMessage {
  factory SendRequest({
    $core.Iterable<$core.MapEntry<$core.String, $core.double>>? destinations,
    $core.int? confTarget,
    $core.String? wallet,
    $core.bool? includeUnsafe,
    $core.Iterable<$core.String>? subtractFeeFromOutputs,
    $2.BoolValue? addToWallet,
    $core.double? feeRate,
  }) {
    final result = SendRequest._();
    if (destinations != null) result.destinations.addEntries(destinations);
    if (confTarget != null) result.confTarget = confTarget;
    if (wallet != null) result.wallet = wallet;
    if (includeUnsafe != null) result.includeUnsafe = includeUnsafe;
    if (subtractFeeFromOutputs != null) result.subtractFeeFromOutputs.addAll(subtractFeeFromOutputs);
    if (addToWallet != null) result.addToWallet = addToWallet;
    if (feeRate != null) result.feeRate = feeRate;
    return result;
  }

  SendRequest._();

  factory SendRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendRequest()..mergeFromBuffer(data, registry);
  factory SendRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: SendRequest.$_createMessage)
    ..m<$core.String, $core.double>(1, _omitFieldNames ? '' : 'destinations',
        entryClassName: 'SendRequest.DestinationsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OD,
        packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..aI(2, _omitFieldNames ? '' : 'confTarget', fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'wallet')
    ..aOB(4, _omitFieldNames ? '' : 'includeUnsafe')
    ..pPS(5, _omitFieldNames ? '' : 'subtractFeeFromOutputs')
    ..aOM<$2.BoolValue>(6, _omitFieldNames ? '' : 'addToWallet', subBuilder: $2.BoolValue.$_createMessage)
    ..aD(7, _omitFieldNames ? '' : 'feeRate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendRequest copyWith(void Function(SendRequest) updates) =>
      super.copyWith((message) => updates(message as SendRequest)) as SendRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendRequest() / SendRequest.new instead')
  static SendRequest create() => SendRequest._();
  static $pb.GeneratedMessage $_createMessage() => SendRequest._();
  @$core.override
  SendRequest createEmptyInstance() => SendRequest._();
  @$core.pragma('dart2js:noInline')
  static SendRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendRequest>(SendRequest.$_createMessage);
  static SendRequest? _defaultInstance;

  /// bitcoin address -> BTC amount
  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $core.double> get destinations => $_getMap(0);

  /// Confirmation target in blocks.
  @$pb.TagNumber(2)
  $core.int get confTarget => $_getIZ(1);
  @$pb.TagNumber(2)
  set confTarget($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConfTarget() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfTarget() => $_clearField(2);

  /// Only needs to be set if dealing with multiple wallets at the same time.
  /// TODO: better suited as a header?
  @$pb.TagNumber(3)
  $core.String get wallet => $_getSZ(2);
  @$pb.TagNumber(3)
  set wallet($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWallet() => $_has(2);
  @$pb.TagNumber(3)
  void clearWallet() => $_clearField(3);

  /// Include inputs that are not safe to spend (unconfirmed transactions from
  /// outside keys and unconfirmed replacement transactions.
  @$pb.TagNumber(4)
  $core.bool get includeUnsafe => $_getBF(3);
  @$pb.TagNumber(4)
  set includeUnsafe($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIncludeUnsafe() => $_has(3);
  @$pb.TagNumber(4)
  void clearIncludeUnsafe() => $_clearField(4);

  /// Outouts to subtract the fee from, specified as as address from the
  /// 'destinations' field. The fee will be equally deducted from the amount of
  /// each specified output.
  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get subtractFeeFromOutputs => $_getList(4);

  /// When false, returns a serialized transaction which will not be added
  /// to the wallet or broadcast.
  ///
  /// This is a 'bool value' instead of a plain bool. This is clunky to
  /// work with, but the alternative would have been to either:
  ///
  /// 1. Have this be a bool with the default value as the opposite of
  ///    Bitcoin Core
  /// 2. Rename the parameter to something else.
  ///
  /// Both of these seem bad.
  @$pb.TagNumber(6)
  $2.BoolValue get addToWallet => $_getN(5);
  @$pb.TagNumber(6)
  set addToWallet($2.BoolValue value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasAddToWallet() => $_has(5);
  @$pb.TagNumber(6)
  void clearAddToWallet() => $_clearField(6);
  @$pb.TagNumber(6)
  $2.BoolValue ensureAddToWallet() => $_ensure(5);

  /// Satoshis per virtual byte (sat/vB).
  @$pb.TagNumber(7)
  $core.double get feeRate => $_getN(6);
  @$pb.TagNumber(7)
  set feeRate($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFeeRate() => $_has(6);
  @$pb.TagNumber(7)
  void clearFeeRate() => $_clearField(7);
}

class SendResponse extends $pb.GeneratedMessage {
  factory SendResponse({
    $core.String? txid,
    $core.bool? complete,
    RawTransaction? tx,
  }) {
    final result = SendResponse._();
    if (txid != null) result.txid = txid;
    if (complete != null) result.complete = complete;
    if (tx != null) result.tx = tx;
    return result;
  }

  SendResponse._();

  factory SendResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendResponse()..mergeFromBuffer(data, registry);
  factory SendResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: SendResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOB(2, _omitFieldNames ? '' : 'complete')
    ..aOM<RawTransaction>(3, _omitFieldNames ? '' : 'tx', subBuilder: RawTransaction.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendResponse copyWith(void Function(SendResponse) updates) =>
      super.copyWith((message) => updates(message as SendResponse)) as SendResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendResponse() / SendResponse.new instead')
  static SendResponse create() => SendResponse._();
  static $pb.GeneratedMessage $_createMessage() => SendResponse._();
  @$core.override
  SendResponse createEmptyInstance() => SendResponse._();
  @$core.pragma('dart2js:noInline')
  static SendResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendResponse>(SendResponse.$_createMessage);
  static SendResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get complete => $_getBF(1);
  @$pb.TagNumber(2)
  set complete($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasComplete() => $_has(1);
  @$pb.TagNumber(2)
  void clearComplete() => $_clearField(2);

  /// If 'add_to_wallet' is false, the raw transaction with signature(s)
  @$pb.TagNumber(3)
  RawTransaction get tx => $_getN(2);
  @$pb.TagNumber(3)
  set tx(RawTransaction value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTx() => $_has(2);
  @$pb.TagNumber(3)
  void clearTx() => $_clearField(3);
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
    final result = SendToAddressRequest._();
    if (address != null) result.address = address;
    if (amount != null) result.amount = amount;
    if (comment != null) result.comment = comment;
    if (commentTo != null) result.commentTo = commentTo;
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  SendToAddressRequest._();

  factory SendToAddressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendToAddressRequest()..mergeFromBuffer(data, registry);
  factory SendToAddressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendToAddressRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendToAddressRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: SendToAddressRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aD(2, _omitFieldNames ? '' : 'amount')
    ..aOS(3, _omitFieldNames ? '' : 'comment')
    ..aOS(4, _omitFieldNames ? '' : 'commentTo')
    ..aOS(5, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendToAddressRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendToAddressRequest copyWith(void Function(SendToAddressRequest) updates) =>
      super.copyWith((message) => updates(message as SendToAddressRequest)) as SendToAddressRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendToAddressRequest() / SendToAddressRequest.new instead')
  static SendToAddressRequest create() => SendToAddressRequest._();
  static $pb.GeneratedMessage $_createMessage() => SendToAddressRequest._();
  @$core.override
  SendToAddressRequest createEmptyInstance() => SendToAddressRequest._();
  @$core.pragma('dart2js:noInline')
  static SendToAddressRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendToAddressRequest>(SendToAddressRequest.$_createMessage);
  static SendToAddressRequest? _defaultInstance;

  /// The bitcoin address to send to.
  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  /// The amount in BTC to send. eg 0.1
  @$pb.TagNumber(2)
  $core.double get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);

  /// A comment used to store what the transaction is for. Not part of the transaction, just kept in your wallet.
  @$pb.TagNumber(3)
  $core.String get comment => $_getSZ(2);
  @$pb.TagNumber(3)
  set comment($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasComment() => $_has(2);
  @$pb.TagNumber(3)
  void clearComment() => $_clearField(3);

  /// A comment to store the name of the person or organization to which you're sending the transaction. Not part of the transaction, just kept in your wallet.
  @$pb.TagNumber(4)
  $core.String get commentTo => $_getSZ(3);
  @$pb.TagNumber(4)
  set commentTo($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCommentTo() => $_has(3);
  @$pb.TagNumber(4)
  void clearCommentTo() => $_clearField(4);

  /// Only needs to be set if dealing with multiple wallets at the same time.
  @$pb.TagNumber(5)
  $core.String get wallet => $_getSZ(4);
  @$pb.TagNumber(5)
  set wallet($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWallet() => $_has(4);
  @$pb.TagNumber(5)
  void clearWallet() => $_clearField(5);
}

class SendToAddressResponse extends $pb.GeneratedMessage {
  factory SendToAddressResponse({
    $core.String? txid,
  }) {
    final result = SendToAddressResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  SendToAddressResponse._();

  factory SendToAddressResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendToAddressResponse()..mergeFromBuffer(data, registry);
  factory SendToAddressResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendToAddressResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendToAddressResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: SendToAddressResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendToAddressResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendToAddressResponse copyWith(void Function(SendToAddressResponse) updates) =>
      super.copyWith((message) => updates(message as SendToAddressResponse)) as SendToAddressResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendToAddressResponse() / SendToAddressResponse.new instead')
  static SendToAddressResponse create() => SendToAddressResponse._();
  static $pb.GeneratedMessage $_createMessage() => SendToAddressResponse._();
  @$core.override
  SendToAddressResponse createEmptyInstance() => SendToAddressResponse._();
  @$core.pragma('dart2js:noInline')
  static SendToAddressResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendToAddressResponse>(SendToAddressResponse.$_createMessage);
  static SendToAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class EstimateSmartFeeRequest extends $pb.GeneratedMessage {
  factory EstimateSmartFeeRequest({
    $fixnum.Int64? confTarget,
    EstimateSmartFeeRequest_EstimateMode? estimateMode,
  }) {
    final result = EstimateSmartFeeRequest._();
    if (confTarget != null) result.confTarget = confTarget;
    if (estimateMode != null) result.estimateMode = estimateMode;
    return result;
  }

  EstimateSmartFeeRequest._();

  factory EstimateSmartFeeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateSmartFeeRequest()..mergeFromBuffer(data, registry);
  factory EstimateSmartFeeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateSmartFeeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EstimateSmartFeeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: EstimateSmartFeeRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'confTarget')
    ..aE<EstimateSmartFeeRequest_EstimateMode>(2, _omitFieldNames ? '' : 'estimateMode',
        enumValues: EstimateSmartFeeRequest_EstimateMode.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateSmartFeeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateSmartFeeRequest copyWith(void Function(EstimateSmartFeeRequest) updates) =>
      super.copyWith((message) => updates(message as EstimateSmartFeeRequest)) as EstimateSmartFeeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EstimateSmartFeeRequest() / EstimateSmartFeeRequest.new instead')
  static EstimateSmartFeeRequest create() => EstimateSmartFeeRequest._();
  static $pb.GeneratedMessage $_createMessage() => EstimateSmartFeeRequest._();
  @$core.override
  EstimateSmartFeeRequest createEmptyInstance() => EstimateSmartFeeRequest._();
  @$core.pragma('dart2js:noInline')
  static EstimateSmartFeeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EstimateSmartFeeRequest>(EstimateSmartFeeRequest.$_createMessage);
  static EstimateSmartFeeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get confTarget => $_getI64(0);
  @$pb.TagNumber(1)
  set confTarget($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfTarget() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfTarget() => $_clearField(1);

  @$pb.TagNumber(2)
  EstimateSmartFeeRequest_EstimateMode get estimateMode => $_getN(1);
  @$pb.TagNumber(2)
  set estimateMode(EstimateSmartFeeRequest_EstimateMode value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEstimateMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearEstimateMode() => $_clearField(2);
}

class EstimateSmartFeeResponse extends $pb.GeneratedMessage {
  factory EstimateSmartFeeResponse({
    $core.double? feeRate,
    $core.Iterable<$core.String>? errors,
    $fixnum.Int64? blocks,
  }) {
    final result = EstimateSmartFeeResponse._();
    if (feeRate != null) result.feeRate = feeRate;
    if (errors != null) result.errors.addAll(errors);
    if (blocks != null) result.blocks = blocks;
    return result;
  }

  EstimateSmartFeeResponse._();

  factory EstimateSmartFeeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateSmartFeeResponse()..mergeFromBuffer(data, registry);
  factory EstimateSmartFeeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateSmartFeeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EstimateSmartFeeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: EstimateSmartFeeResponse.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'feeRate')
    ..pPS(2, _omitFieldNames ? '' : 'errors')
    ..aInt64(3, _omitFieldNames ? '' : 'blocks')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateSmartFeeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateSmartFeeResponse copyWith(void Function(EstimateSmartFeeResponse) updates) =>
      super.copyWith((message) => updates(message as EstimateSmartFeeResponse)) as EstimateSmartFeeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EstimateSmartFeeResponse() / EstimateSmartFeeResponse.new instead')
  static EstimateSmartFeeResponse create() => EstimateSmartFeeResponse._();
  static $pb.GeneratedMessage $_createMessage() => EstimateSmartFeeResponse._();
  @$core.override
  EstimateSmartFeeResponse createEmptyInstance() => EstimateSmartFeeResponse._();
  @$core.pragma('dart2js:noInline')
  static EstimateSmartFeeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EstimateSmartFeeResponse>(EstimateSmartFeeResponse.$_createMessage);
  static EstimateSmartFeeResponse? _defaultInstance;

  /// Estimate fee rate in BTC/kvB (only present if no errors were encountered)
  @$pb.TagNumber(1)
  $core.double get feeRate => $_getN(0);
  @$pb.TagNumber(1)
  set feeRate($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFeeRate() => $_has(0);
  @$pb.TagNumber(1)
  void clearFeeRate() => $_clearField(1);

  /// Errors encountered during processing (if there are any)
  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get errors => $_getList(1);

  /// Block number where estimate was found.
  @$pb.TagNumber(3)
  $fixnum.Int64 get blocks => $_getI64(2);
  @$pb.TagNumber(3)
  set blocks($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBlocks() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlocks() => $_clearField(3);
}

class DecodeRawTransactionRequest extends $pb.GeneratedMessage {
  factory DecodeRawTransactionRequest({
    RawTransaction? tx,
  }) {
    final result = DecodeRawTransactionRequest._();
    if (tx != null) result.tx = tx;
    return result;
  }

  DecodeRawTransactionRequest._();

  factory DecodeRawTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodeRawTransactionRequest()..mergeFromBuffer(data, registry);
  factory DecodeRawTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodeRawTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodeRawTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: DecodeRawTransactionRequest.$_createMessage)
    ..aOM<RawTransaction>(1, _omitFieldNames ? '' : 'tx', subBuilder: RawTransaction.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodeRawTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodeRawTransactionRequest copyWith(void Function(DecodeRawTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as DecodeRawTransactionRequest)) as DecodeRawTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DecodeRawTransactionRequest() / DecodeRawTransactionRequest.new instead')
  static DecodeRawTransactionRequest create() => DecodeRawTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => DecodeRawTransactionRequest._();
  @$core.override
  DecodeRawTransactionRequest createEmptyInstance() => DecodeRawTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static DecodeRawTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecodeRawTransactionRequest>(DecodeRawTransactionRequest.$_createMessage);
  static DecodeRawTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  RawTransaction get tx => $_getN(0);
  @$pb.TagNumber(1)
  set tx(RawTransaction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTx() => $_has(0);
  @$pb.TagNumber(1)
  void clearTx() => $_clearField(1);
  @$pb.TagNumber(1)
  RawTransaction ensureTx() => $_ensure(0);
}

class RawTransaction extends $pb.GeneratedMessage {
  factory RawTransaction({
    $core.List<$core.int>? data,
    $core.String? hex,
  }) {
    final result = RawTransaction._();
    if (data != null) result.data = data;
    if (hex != null) result.hex = hex;
    return result;
  }

  RawTransaction._();

  factory RawTransaction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RawTransaction()..mergeFromBuffer(data, registry);
  factory RawTransaction.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RawTransaction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RawTransaction',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: RawTransaction.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'hex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawTransaction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawTransaction copyWith(void Function(RawTransaction) updates) =>
      super.copyWith((message) => updates(message as RawTransaction)) as RawTransaction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RawTransaction() / RawTransaction.new instead')
  static RawTransaction create() => RawTransaction._();
  static $pb.GeneratedMessage $_createMessage() => RawTransaction._();
  @$core.override
  RawTransaction createEmptyInstance() => RawTransaction._();
  @$core.pragma('dart2js:noInline')
  static RawTransaction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RawTransaction>(RawTransaction.$_createMessage);
  static RawTransaction? _defaultInstance;

  /// Raw transaction data
  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);

  /// Hex-encoded raw transaction data
  @$pb.TagNumber(2)
  $core.String get hex => $_getSZ(1);
  @$pb.TagNumber(2)
  set hex($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearHex() => $_clearField(2);
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
    final result = DecodeRawTransactionResponse._();
    if (txid != null) result.txid = txid;
    if (hash != null) result.hash = hash;
    if (size != null) result.size = size;
    if (virtualSize != null) result.virtualSize = virtualSize;
    if (weight != null) result.weight = weight;
    if (version != null) result.version = version;
    if (locktime != null) result.locktime = locktime;
    if (inputs != null) result.inputs.addAll(inputs);
    if (outputs != null) result.outputs.addAll(outputs);
    return result;
  }

  DecodeRawTransactionResponse._();

  factory DecodeRawTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodeRawTransactionResponse()..mergeFromBuffer(data, registry);
  factory DecodeRawTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodeRawTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodeRawTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: DecodeRawTransactionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..aI(3, _omitFieldNames ? '' : 'size', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'virtualSize', fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'weight', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'locktime', fieldType: $pb.PbFieldType.OU3)
    ..pPM<Input>(8, _omitFieldNames ? '' : 'inputs', subBuilder: Input.$_createMessage)
    ..pPM<Output>(9, _omitFieldNames ? '' : 'outputs', subBuilder: Output.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodeRawTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodeRawTransactionResponse copyWith(void Function(DecodeRawTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as DecodeRawTransactionResponse)) as DecodeRawTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DecodeRawTransactionResponse() / DecodeRawTransactionResponse.new instead')
  static DecodeRawTransactionResponse create() => DecodeRawTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => DecodeRawTransactionResponse._();
  @$core.override
  DecodeRawTransactionResponse createEmptyInstance() => DecodeRawTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static DecodeRawTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecodeRawTransactionResponse>(DecodeRawTransactionResponse.$_createMessage);
  static DecodeRawTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => $_clearField(2);

  /// The serialized transaction size
  @$pb.TagNumber(3)
  $core.int get size => $_getIZ(2);
  @$pb.TagNumber(3)
  set size($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearSize() => $_clearField(3);

  /// The virtual transaction size (differs from
  /// 'size' for witness transactions).
  @$pb.TagNumber(4)
  $core.int get virtualSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set virtualSize($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVirtualSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearVirtualSize() => $_clearField(4);

  /// The transaction's weight
  @$pb.TagNumber(5)
  $core.int get weight => $_getIZ(4);
  @$pb.TagNumber(5)
  set weight($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearWeight() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get version => $_getIZ(5);
  @$pb.TagNumber(6)
  set version($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersion() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get locktime => $_getIZ(6);
  @$pb.TagNumber(7)
  set locktime($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLocktime() => $_has(6);
  @$pb.TagNumber(7)
  void clearLocktime() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<Input> get inputs => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbList<Output> get outputs => $_getList(8);
}

class ListDescriptorsRequest extends $pb.GeneratedMessage {
  factory ListDescriptorsRequest({
    $core.String? wallet,
    $core.bool? includePrivateDescriptors,
  }) {
    final result = ListDescriptorsRequest._();
    if (wallet != null) result.wallet = wallet;
    if (includePrivateDescriptors != null) result.includePrivateDescriptors = includePrivateDescriptors;
    return result;
  }

  ListDescriptorsRequest._();

  factory ListDescriptorsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDescriptorsRequest()..mergeFromBuffer(data, registry);
  factory ListDescriptorsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDescriptorsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListDescriptorsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ListDescriptorsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..aOB(2, _omitFieldNames ? '' : 'includePrivateDescriptors')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDescriptorsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDescriptorsRequest copyWith(void Function(ListDescriptorsRequest) updates) =>
      super.copyWith((message) => updates(message as ListDescriptorsRequest)) as ListDescriptorsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListDescriptorsRequest() / ListDescriptorsRequest.new instead')
  static ListDescriptorsRequest create() => ListDescriptorsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListDescriptorsRequest._();
  @$core.override
  ListDescriptorsRequest createEmptyInstance() => ListDescriptorsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListDescriptorsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDescriptorsRequest>(ListDescriptorsRequest.$_createMessage);
  static ListDescriptorsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get includePrivateDescriptors => $_getBF(1);
  @$pb.TagNumber(2)
  set includePrivateDescriptors($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIncludePrivateDescriptors() => $_has(1);
  @$pb.TagNumber(2)
  void clearIncludePrivateDescriptors() => $_clearField(2);
}

class ListDescriptorsResponse_Range extends $pb.GeneratedMessage {
  factory ListDescriptorsResponse_Range({
    $core.int? start,
    $core.int? end,
  }) {
    final result = ListDescriptorsResponse_Range._();
    if (start != null) result.start = start;
    if (end != null) result.end = end;
    return result;
  }

  ListDescriptorsResponse_Range._();

  factory ListDescriptorsResponse_Range.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDescriptorsResponse_Range()..mergeFromBuffer(data, registry);
  factory ListDescriptorsResponse_Range.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDescriptorsResponse_Range()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListDescriptorsResponse.Range',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ListDescriptorsResponse_Range.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'start', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'end', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDescriptorsResponse_Range clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDescriptorsResponse_Range copyWith(void Function(ListDescriptorsResponse_Range) updates) =>
      super.copyWith((message) => updates(message as ListDescriptorsResponse_Range)) as ListDescriptorsResponse_Range;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListDescriptorsResponse_Range() / ListDescriptorsResponse_Range.new instead')
  static ListDescriptorsResponse_Range create() => ListDescriptorsResponse_Range._();
  static $pb.GeneratedMessage $_createMessage() => ListDescriptorsResponse_Range._();
  @$core.override
  ListDescriptorsResponse_Range createEmptyInstance() => ListDescriptorsResponse_Range._();
  @$core.pragma('dart2js:noInline')
  static ListDescriptorsResponse_Range getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDescriptorsResponse_Range>(ListDescriptorsResponse_Range.$_createMessage);
  static ListDescriptorsResponse_Range? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get start => $_getIZ(0);
  @$pb.TagNumber(1)
  set start($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStart() => $_has(0);
  @$pb.TagNumber(1)
  void clearStart() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get end => $_getIZ(1);
  @$pb.TagNumber(2)
  set end($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnd() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnd() => $_clearField(2);
}

class ListDescriptorsResponse_Descriptor extends $pb.GeneratedMessage {
  factory ListDescriptorsResponse_Descriptor({
    $core.String? descriptor,
    $0.Timestamp? timestamp,
    $core.bool? active,
    $core.bool? internal,
    ListDescriptorsResponse_Range? range,
    $core.int? nextIndex,
  }) {
    final result = ListDescriptorsResponse_Descriptor._();
    if (descriptor != null) result.descriptor = descriptor;
    if (timestamp != null) result.timestamp = timestamp;
    if (active != null) result.active = active;
    if (internal != null) result.internal = internal;
    if (range != null) result.range = range;
    if (nextIndex != null) result.nextIndex = nextIndex;
    return result;
  }

  ListDescriptorsResponse_Descriptor._();

  factory ListDescriptorsResponse_Descriptor.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDescriptorsResponse_Descriptor()..mergeFromBuffer(data, registry);
  factory ListDescriptorsResponse_Descriptor.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDescriptorsResponse_Descriptor()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListDescriptorsResponse.Descriptor',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ListDescriptorsResponse_Descriptor.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'descriptor')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp', subBuilder: $0.Timestamp.$_createMessage)
    ..aOB(3, _omitFieldNames ? '' : 'active')
    ..aOB(4, _omitFieldNames ? '' : 'internal')
    ..aOM<ListDescriptorsResponse_Range>(5, _omitFieldNames ? '' : 'range',
        subBuilder: ListDescriptorsResponse_Range.$_createMessage)
    ..aI(7, _omitFieldNames ? '' : 'nextIndex', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDescriptorsResponse_Descriptor clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDescriptorsResponse_Descriptor copyWith(void Function(ListDescriptorsResponse_Descriptor) updates) =>
      super.copyWith((message) => updates(message as ListDescriptorsResponse_Descriptor))
          as ListDescriptorsResponse_Descriptor;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListDescriptorsResponse_Descriptor() / ListDescriptorsResponse_Descriptor.new instead')
  static ListDescriptorsResponse_Descriptor create() => ListDescriptorsResponse_Descriptor._();
  static $pb.GeneratedMessage $_createMessage() => ListDescriptorsResponse_Descriptor._();
  @$core.override
  ListDescriptorsResponse_Descriptor createEmptyInstance() => ListDescriptorsResponse_Descriptor._();
  @$core.pragma('dart2js:noInline')
  static ListDescriptorsResponse_Descriptor getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDescriptorsResponse_Descriptor>(
          ListDescriptorsResponse_Descriptor.$_createMessage);
  static ListDescriptorsResponse_Descriptor? _defaultInstance;

  /// Can contain private keys. Sensitive!
  @$pb.TagNumber(1)
  $core.String get descriptor => $_getSZ(0);
  @$pb.TagNumber(1)
  set descriptor($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDescriptor() => $_has(0);
  @$pb.TagNumber(1)
  void clearDescriptor() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.bool get active => $_getBF(2);
  @$pb.TagNumber(3)
  set active($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasActive() => $_has(2);
  @$pb.TagNumber(3)
  void clearActive() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get internal => $_getBF(3);
  @$pb.TagNumber(4)
  set internal($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInternal() => $_has(3);
  @$pb.TagNumber(4)
  void clearInternal() => $_clearField(4);

  @$pb.TagNumber(5)
  ListDescriptorsResponse_Range get range => $_getN(4);
  @$pb.TagNumber(5)
  set range(ListDescriptorsResponse_Range value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRange() => $_has(4);
  @$pb.TagNumber(5)
  void clearRange() => $_clearField(5);
  @$pb.TagNumber(5)
  ListDescriptorsResponse_Range ensureRange() => $_ensure(4);

  /// Only present for ranged descriptors
  @$pb.TagNumber(7)
  $core.int get nextIndex => $_getIZ(5);
  @$pb.TagNumber(7)
  set nextIndex($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(7)
  $core.bool hasNextIndex() => $_has(5);
  @$pb.TagNumber(7)
  void clearNextIndex() => $_clearField(7);
}

class ListDescriptorsResponse extends $pb.GeneratedMessage {
  factory ListDescriptorsResponse({
    $core.Iterable<ListDescriptorsResponse_Descriptor>? descriptors,
  }) {
    final result = ListDescriptorsResponse._();
    if (descriptors != null) result.descriptors.addAll(descriptors);
    return result;
  }

  ListDescriptorsResponse._();

  factory ListDescriptorsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDescriptorsResponse()..mergeFromBuffer(data, registry);
  factory ListDescriptorsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDescriptorsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListDescriptorsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ListDescriptorsResponse.$_createMessage)
    ..pPM<ListDescriptorsResponse_Descriptor>(1, _omitFieldNames ? '' : 'descriptors',
        subBuilder: ListDescriptorsResponse_Descriptor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDescriptorsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDescriptorsResponse copyWith(void Function(ListDescriptorsResponse) updates) =>
      super.copyWith((message) => updates(message as ListDescriptorsResponse)) as ListDescriptorsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListDescriptorsResponse() / ListDescriptorsResponse.new instead')
  static ListDescriptorsResponse create() => ListDescriptorsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListDescriptorsResponse._();
  @$core.override
  ListDescriptorsResponse createEmptyInstance() => ListDescriptorsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListDescriptorsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDescriptorsResponse>(ListDescriptorsResponse.$_createMessage);
  static ListDescriptorsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ListDescriptorsResponse_Descriptor> get descriptors => $_getList(0);
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
    $core.int? nextIndex,
  }) {
    final result = ImportDescriptorsRequest_Request._();
    if (descriptor != null) result.descriptor = descriptor;
    if (active != null) result.active = active;
    if (rangeStart != null) result.rangeStart = rangeStart;
    if (rangeEnd != null) result.rangeEnd = rangeEnd;
    if (timestamp != null) result.timestamp = timestamp;
    if (internal != null) result.internal = internal;
    if (label != null) result.label = label;
    if (nextIndex != null) result.nextIndex = nextIndex;
    return result;
  }

  ImportDescriptorsRequest_Request._();

  factory ImportDescriptorsRequest_Request.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDescriptorsRequest_Request()..mergeFromBuffer(data, registry);
  factory ImportDescriptorsRequest_Request.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDescriptorsRequest_Request()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportDescriptorsRequest.Request',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ImportDescriptorsRequest_Request.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'descriptor')
    ..aOB(2, _omitFieldNames ? '' : 'active')
    ..aI(3, _omitFieldNames ? '' : 'rangeStart', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'rangeEnd', fieldType: $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'timestamp', subBuilder: $0.Timestamp.$_createMessage)
    ..aOB(6, _omitFieldNames ? '' : 'internal')
    ..aOS(7, _omitFieldNames ? '' : 'label')
    ..aI(8, _omitFieldNames ? '' : 'nextIndex', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDescriptorsRequest_Request clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDescriptorsRequest_Request copyWith(void Function(ImportDescriptorsRequest_Request) updates) =>
      super.copyWith((message) => updates(message as ImportDescriptorsRequest_Request))
          as ImportDescriptorsRequest_Request;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportDescriptorsRequest_Request() / ImportDescriptorsRequest_Request.new instead')
  static ImportDescriptorsRequest_Request create() => ImportDescriptorsRequest_Request._();
  static $pb.GeneratedMessage $_createMessage() => ImportDescriptorsRequest_Request._();
  @$core.override
  ImportDescriptorsRequest_Request createEmptyInstance() => ImportDescriptorsRequest_Request._();
  @$core.pragma('dart2js:noInline')
  static ImportDescriptorsRequest_Request getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportDescriptorsRequest_Request>(
          ImportDescriptorsRequest_Request.$_createMessage);
  static ImportDescriptorsRequest_Request? _defaultInstance;

  /// Descriptor to import
  @$pb.TagNumber(1)
  $core.String get descriptor => $_getSZ(0);
  @$pb.TagNumber(1)
  set descriptor($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDescriptor() => $_has(0);
  @$pb.TagNumber(1)
  void clearDescriptor() => $_clearField(1);

  /// Set this descriptor to be the active descriptor for the corresponding type/externality.
  @$pb.TagNumber(2)
  $core.bool get active => $_getBF(1);
  @$pb.TagNumber(2)
  set active($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasActive() => $_has(1);
  @$pb.TagNumber(2)
  void clearActive() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get rangeStart => $_getIZ(2);
  @$pb.TagNumber(3)
  set rangeStart($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRangeStart() => $_has(2);
  @$pb.TagNumber(3)
  void clearRangeStart() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get rangeEnd => $_getIZ(3);
  @$pb.TagNumber(4)
  set rangeEnd($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRangeEnd() => $_has(3);
  @$pb.TagNumber(4)
  void clearRangeEnd() => $_clearField(4);

  /// Nil passes 'now' to Bitcoin Core, which bypasses scanning.
  @$pb.TagNumber(5)
  $0.Timestamp get timestamp => $_getN(4);
  @$pb.TagNumber(5)
  set timestamp($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureTimestamp() => $_ensure(4);

  /// Whether matching outputs should be treated as not incoming payments (e.g. change)
  @$pb.TagNumber(6)
  $core.bool get internal => $_getBF(5);
  @$pb.TagNumber(6)
  set internal($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasInternal() => $_has(5);
  @$pb.TagNumber(6)
  void clearInternal() => $_clearField(6);

  /// Label to assign to the address, only allowed with internal = false. Disabled for ranged descriptors.
  @$pb.TagNumber(7)
  $core.String get label => $_getSZ(6);
  @$pb.TagNumber(7)
  set label($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLabel() => $_has(6);
  @$pb.TagNumber(7)
  void clearLabel() => $_clearField(7);

  /// If a ranged descriptor is set to active, this specifies the next index to generate addresses from
  @$pb.TagNumber(8)
  $core.int get nextIndex => $_getIZ(7);
  @$pb.TagNumber(8)
  set nextIndex($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNextIndex() => $_has(7);
  @$pb.TagNumber(8)
  void clearNextIndex() => $_clearField(8);
}

class ImportDescriptorsRequest extends $pb.GeneratedMessage {
  factory ImportDescriptorsRequest({
    $core.String? wallet,
    $core.Iterable<ImportDescriptorsRequest_Request>? requests,
  }) {
    final result = ImportDescriptorsRequest._();
    if (wallet != null) result.wallet = wallet;
    if (requests != null) result.requests.addAll(requests);
    return result;
  }

  ImportDescriptorsRequest._();

  factory ImportDescriptorsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDescriptorsRequest()..mergeFromBuffer(data, registry);
  factory ImportDescriptorsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDescriptorsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportDescriptorsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ImportDescriptorsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..pPM<ImportDescriptorsRequest_Request>(2, _omitFieldNames ? '' : 'requests',
        subBuilder: ImportDescriptorsRequest_Request.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDescriptorsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDescriptorsRequest copyWith(void Function(ImportDescriptorsRequest) updates) =>
      super.copyWith((message) => updates(message as ImportDescriptorsRequest)) as ImportDescriptorsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportDescriptorsRequest() / ImportDescriptorsRequest.new instead')
  static ImportDescriptorsRequest create() => ImportDescriptorsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ImportDescriptorsRequest._();
  @$core.override
  ImportDescriptorsRequest createEmptyInstance() => ImportDescriptorsRequest._();
  @$core.pragma('dart2js:noInline')
  static ImportDescriptorsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportDescriptorsRequest>(ImportDescriptorsRequest.$_createMessage);
  static ImportDescriptorsRequest? _defaultInstance;

  /// Only needs to be set if dealing with multiple wallets at the same time.
  /// TODO: better suited as a header?
  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<ImportDescriptorsRequest_Request> get requests => $_getList(1);
}

class ImportDescriptorsResponse_Error extends $pb.GeneratedMessage {
  factory ImportDescriptorsResponse_Error({
    $core.int? code,
    $core.String? message,
  }) {
    final result = ImportDescriptorsResponse_Error._();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    return result;
  }

  ImportDescriptorsResponse_Error._();

  factory ImportDescriptorsResponse_Error.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDescriptorsResponse_Error()..mergeFromBuffer(data, registry);
  factory ImportDescriptorsResponse_Error.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDescriptorsResponse_Error()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportDescriptorsResponse.Error',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ImportDescriptorsResponse_Error.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDescriptorsResponse_Error clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDescriptorsResponse_Error copyWith(void Function(ImportDescriptorsResponse_Error) updates) =>
      super.copyWith((message) => updates(message as ImportDescriptorsResponse_Error))
          as ImportDescriptorsResponse_Error;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportDescriptorsResponse_Error() / ImportDescriptorsResponse_Error.new instead')
  static ImportDescriptorsResponse_Error create() => ImportDescriptorsResponse_Error._();
  static $pb.GeneratedMessage $_createMessage() => ImportDescriptorsResponse_Error._();
  @$core.override
  ImportDescriptorsResponse_Error createEmptyInstance() => ImportDescriptorsResponse_Error._();
  @$core.pragma('dart2js:noInline')
  static ImportDescriptorsResponse_Error getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportDescriptorsResponse_Error>(
          ImportDescriptorsResponse_Error.$_createMessage);
  static ImportDescriptorsResponse_Error? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class ImportDescriptorsResponse_Response extends $pb.GeneratedMessage {
  factory ImportDescriptorsResponse_Response({
    $core.bool? success,
    $core.Iterable<$core.String>? warnings,
    ImportDescriptorsResponse_Error? error,
  }) {
    final result = ImportDescriptorsResponse_Response._();
    if (success != null) result.success = success;
    if (warnings != null) result.warnings.addAll(warnings);
    if (error != null) result.error = error;
    return result;
  }

  ImportDescriptorsResponse_Response._();

  factory ImportDescriptorsResponse_Response.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDescriptorsResponse_Response()..mergeFromBuffer(data, registry);
  factory ImportDescriptorsResponse_Response.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDescriptorsResponse_Response()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportDescriptorsResponse.Response',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ImportDescriptorsResponse_Response.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..pPS(2, _omitFieldNames ? '' : 'warnings')
    ..aOM<ImportDescriptorsResponse_Error>(3, _omitFieldNames ? '' : 'error',
        subBuilder: ImportDescriptorsResponse_Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDescriptorsResponse_Response clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDescriptorsResponse_Response copyWith(void Function(ImportDescriptorsResponse_Response) updates) =>
      super.copyWith((message) => updates(message as ImportDescriptorsResponse_Response))
          as ImportDescriptorsResponse_Response;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportDescriptorsResponse_Response() / ImportDescriptorsResponse_Response.new instead')
  static ImportDescriptorsResponse_Response create() => ImportDescriptorsResponse_Response._();
  static $pb.GeneratedMessage $_createMessage() => ImportDescriptorsResponse_Response._();
  @$core.override
  ImportDescriptorsResponse_Response createEmptyInstance() => ImportDescriptorsResponse_Response._();
  @$core.pragma('dart2js:noInline')
  static ImportDescriptorsResponse_Response getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportDescriptorsResponse_Response>(
          ImportDescriptorsResponse_Response.$_createMessage);
  static ImportDescriptorsResponse_Response? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get warnings => $_getList(1);

  @$pb.TagNumber(3)
  ImportDescriptorsResponse_Error get error => $_getN(2);
  @$pb.TagNumber(3)
  set error(ImportDescriptorsResponse_Error value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);
  @$pb.TagNumber(3)
  ImportDescriptorsResponse_Error ensureError() => $_ensure(2);
}

class ImportDescriptorsResponse extends $pb.GeneratedMessage {
  factory ImportDescriptorsResponse({
    $core.Iterable<ImportDescriptorsResponse_Response>? responses,
  }) {
    final result = ImportDescriptorsResponse._();
    if (responses != null) result.responses.addAll(responses);
    return result;
  }

  ImportDescriptorsResponse._();

  factory ImportDescriptorsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDescriptorsResponse()..mergeFromBuffer(data, registry);
  factory ImportDescriptorsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDescriptorsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportDescriptorsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ImportDescriptorsResponse.$_createMessage)
    ..pPM<ImportDescriptorsResponse_Response>(1, _omitFieldNames ? '' : 'responses',
        subBuilder: ImportDescriptorsResponse_Response.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDescriptorsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDescriptorsResponse copyWith(void Function(ImportDescriptorsResponse) updates) =>
      super.copyWith((message) => updates(message as ImportDescriptorsResponse)) as ImportDescriptorsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportDescriptorsResponse() / ImportDescriptorsResponse.new instead')
  static ImportDescriptorsResponse create() => ImportDescriptorsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ImportDescriptorsResponse._();
  @$core.override
  ImportDescriptorsResponse createEmptyInstance() => ImportDescriptorsResponse._();
  @$core.pragma('dart2js:noInline')
  static ImportDescriptorsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportDescriptorsResponse>(ImportDescriptorsResponse.$_createMessage);
  static ImportDescriptorsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ImportDescriptorsResponse_Response> get responses => $_getList(0);
}

class GetDescriptorInfoRequest extends $pb.GeneratedMessage {
  factory GetDescriptorInfoRequest({
    $core.String? descriptor,
  }) {
    final result = GetDescriptorInfoRequest._();
    if (descriptor != null) result.descriptor = descriptor;
    return result;
  }

  GetDescriptorInfoRequest._();

  factory GetDescriptorInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDescriptorInfoRequest()..mergeFromBuffer(data, registry);
  factory GetDescriptorInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDescriptorInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDescriptorInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetDescriptorInfoRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'descriptor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDescriptorInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDescriptorInfoRequest copyWith(void Function(GetDescriptorInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetDescriptorInfoRequest)) as GetDescriptorInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetDescriptorInfoRequest() / GetDescriptorInfoRequest.new instead')
  static GetDescriptorInfoRequest create() => GetDescriptorInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetDescriptorInfoRequest._();
  @$core.override
  GetDescriptorInfoRequest createEmptyInstance() => GetDescriptorInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetDescriptorInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDescriptorInfoRequest>(GetDescriptorInfoRequest.$_createMessage);
  static GetDescriptorInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get descriptor => $_getSZ(0);
  @$pb.TagNumber(1)
  set descriptor($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDescriptor() => $_has(0);
  @$pb.TagNumber(1)
  void clearDescriptor() => $_clearField(1);
}

class GetDescriptorInfoResponse extends $pb.GeneratedMessage {
  factory GetDescriptorInfoResponse({
    $core.String? descriptor,
    $core.String? checksum,
    $core.bool? isRange,
    $core.bool? isSolvable,
    $core.bool? hasPrivateKeys,
  }) {
    final result = GetDescriptorInfoResponse._();
    if (descriptor != null) result.descriptor = descriptor;
    if (checksum != null) result.checksum = checksum;
    if (isRange != null) result.isRange = isRange;
    if (isSolvable != null) result.isSolvable = isSolvable;
    if (hasPrivateKeys != null) result.hasPrivateKeys = hasPrivateKeys;
    return result;
  }

  GetDescriptorInfoResponse._();

  factory GetDescriptorInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDescriptorInfoResponse()..mergeFromBuffer(data, registry);
  factory GetDescriptorInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDescriptorInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDescriptorInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetDescriptorInfoResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'descriptor')
    ..aOS(2, _omitFieldNames ? '' : 'checksum')
    ..aOB(3, _omitFieldNames ? '' : 'isRange')
    ..aOB(4, _omitFieldNames ? '' : 'isSolvable')
    ..aOB(5, _omitFieldNames ? '' : 'hasPrivateKeys')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDescriptorInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDescriptorInfoResponse copyWith(void Function(GetDescriptorInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetDescriptorInfoResponse)) as GetDescriptorInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetDescriptorInfoResponse() / GetDescriptorInfoResponse.new instead')
  static GetDescriptorInfoResponse create() => GetDescriptorInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetDescriptorInfoResponse._();
  @$core.override
  GetDescriptorInfoResponse createEmptyInstance() => GetDescriptorInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetDescriptorInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDescriptorInfoResponse>(GetDescriptorInfoResponse.$_createMessage);
  static GetDescriptorInfoResponse? _defaultInstance;

  /// The descriptor in canonical form, without private keys.
  @$pb.TagNumber(1)
  $core.String get descriptor => $_getSZ(0);
  @$pb.TagNumber(1)
  set descriptor($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDescriptor() => $_has(0);
  @$pb.TagNumber(1)
  void clearDescriptor() => $_clearField(1);

  /// The checksum for the input descriptor
  @$pb.TagNumber(2)
  $core.String get checksum => $_getSZ(1);
  @$pb.TagNumber(2)
  set checksum($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChecksum() => $_has(1);
  @$pb.TagNumber(2)
  void clearChecksum() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isRange => $_getBF(2);
  @$pb.TagNumber(3)
  set isRange($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsRange() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsRange() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isSolvable => $_getBF(3);
  @$pb.TagNumber(4)
  set isSolvable($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsSolvable() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsSolvable() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get hasPrivateKeys => $_getBF(4);
  @$pb.TagNumber(5)
  set hasPrivateKeys($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHasPrivateKeys() => $_has(4);
  @$pb.TagNumber(5)
  void clearHasPrivateKeys() => $_clearField(5);
}

class GetBlockRequest extends $pb.GeneratedMessage {
  factory GetBlockRequest({
    $core.String? hash,
    GetBlockRequest_Verbosity? verbosity,
    $core.int? height,
  }) {
    final result = GetBlockRequest._();
    if (hash != null) result.hash = hash;
    if (verbosity != null) result.verbosity = verbosity;
    if (height != null) result.height = height;
    return result;
  }

  GetBlockRequest._();

  factory GetBlockRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockRequest()..mergeFromBuffer(data, registry);
  factory GetBlockRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetBlockRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..aE<GetBlockRequest_Verbosity>(2, _omitFieldNames ? '' : 'verbosity', enumValues: GetBlockRequest_Verbosity.values)
    ..aI(3, _omitFieldNames ? '' : 'height')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockRequest copyWith(void Function(GetBlockRequest) updates) =>
      super.copyWith((message) => updates(message as GetBlockRequest)) as GetBlockRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockRequest() / GetBlockRequest.new instead')
  static GetBlockRequest create() => GetBlockRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockRequest._();
  @$core.override
  GetBlockRequest createEmptyInstance() => GetBlockRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBlockRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockRequest>(GetBlockRequest.$_createMessage);
  static GetBlockRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => $_clearField(1);

  @$pb.TagNumber(2)
  GetBlockRequest_Verbosity get verbosity => $_getN(1);
  @$pb.TagNumber(2)
  set verbosity(GetBlockRequest_Verbosity value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasVerbosity() => $_has(1);
  @$pb.TagNumber(2)
  void clearVerbosity() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get height => $_getIZ(2);
  @$pb.TagNumber(3)
  set height($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeight() => $_clearField(3);
}

class GetBlockResponse_Transaction extends $pb.GeneratedMessage {
  factory GetBlockResponse_Transaction({
    $core.String? txid,
    $core.String? hash,
    $core.int? size,
    $core.int? vsize,
    $core.int? weight,
    $core.int? version,
    $core.int? locktime,
    $core.Iterable<Input>? inputs,
    $core.Iterable<Output>? outputs,
  }) {
    final result = GetBlockResponse_Transaction._();
    if (txid != null) result.txid = txid;
    if (hash != null) result.hash = hash;
    if (size != null) result.size = size;
    if (vsize != null) result.vsize = vsize;
    if (weight != null) result.weight = weight;
    if (version != null) result.version = version;
    if (locktime != null) result.locktime = locktime;
    if (inputs != null) result.inputs.addAll(inputs);
    if (outputs != null) result.outputs.addAll(outputs);
    return result;
  }

  GetBlockResponse_Transaction._();

  factory GetBlockResponse_Transaction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockResponse_Transaction()..mergeFromBuffer(data, registry);
  factory GetBlockResponse_Transaction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockResponse_Transaction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockResponse.Transaction',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetBlockResponse_Transaction.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..aI(3, _omitFieldNames ? '' : 'size')
    ..aI(4, _omitFieldNames ? '' : 'vsize')
    ..aI(5, _omitFieldNames ? '' : 'weight')
    ..aI(6, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'locktime', fieldType: $pb.PbFieldType.OU3)
    ..pPM<Input>(8, _omitFieldNames ? '' : 'inputs', subBuilder: Input.$_createMessage)
    ..pPM<Output>(9, _omitFieldNames ? '' : 'outputs', subBuilder: Output.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockResponse_Transaction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockResponse_Transaction copyWith(void Function(GetBlockResponse_Transaction) updates) =>
      super.copyWith((message) => updates(message as GetBlockResponse_Transaction)) as GetBlockResponse_Transaction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockResponse_Transaction() / GetBlockResponse_Transaction.new instead')
  static GetBlockResponse_Transaction create() => GetBlockResponse_Transaction._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockResponse_Transaction._();
  @$core.override
  GetBlockResponse_Transaction createEmptyInstance() => GetBlockResponse_Transaction._();
  @$core.pragma('dart2js:noInline')
  static GetBlockResponse_Transaction getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockResponse_Transaction>(GetBlockResponse_Transaction.$_createMessage);
  static GetBlockResponse_Transaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get size => $_getIZ(2);
  @$pb.TagNumber(3)
  set size($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearSize() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get vsize => $_getIZ(3);
  @$pb.TagNumber(4)
  set vsize($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVsize() => $_has(3);
  @$pb.TagNumber(4)
  void clearVsize() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get weight => $_getIZ(4);
  @$pb.TagNumber(5)
  set weight($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearWeight() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get version => $_getIZ(5);
  @$pb.TagNumber(6)
  set version($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersion() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get locktime => $_getIZ(6);
  @$pb.TagNumber(7)
  set locktime($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLocktime() => $_has(6);
  @$pb.TagNumber(7)
  void clearLocktime() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<Input> get inputs => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbList<Output> get outputs => $_getList(8);
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
    $0.Timestamp? medianTime,
    $core.String? target,
    $core.String? chainwork,
    $core.Iterable<GetBlockResponse_Transaction>? transactions,
  }) {
    final result = GetBlockResponse._();
    if (hex != null) result.hex = hex;
    if (hash != null) result.hash = hash;
    if (confirmations != null) result.confirmations = confirmations;
    if (height != null) result.height = height;
    if (version != null) result.version = version;
    if (versionHex != null) result.versionHex = versionHex;
    if (merkleRoot != null) result.merkleRoot = merkleRoot;
    if (time != null) result.time = time;
    if (nonce != null) result.nonce = nonce;
    if (bits != null) result.bits = bits;
    if (difficulty != null) result.difficulty = difficulty;
    if (previousBlockHash != null) result.previousBlockHash = previousBlockHash;
    if (nextBlockHash != null) result.nextBlockHash = nextBlockHash;
    if (strippedSize != null) result.strippedSize = strippedSize;
    if (size != null) result.size = size;
    if (weight != null) result.weight = weight;
    if (txids != null) result.txids.addAll(txids);
    if (medianTime != null) result.medianTime = medianTime;
    if (target != null) result.target = target;
    if (chainwork != null) result.chainwork = chainwork;
    if (transactions != null) result.transactions.addAll(transactions);
    return result;
  }

  GetBlockResponse._();

  factory GetBlockResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockResponse()..mergeFromBuffer(data, registry);
  factory GetBlockResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetBlockResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'hex')
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..aI(3, _omitFieldNames ? '' : 'confirmations')
    ..aI(4, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'version')
    ..aOS(6, _omitFieldNames ? '' : 'versionHex')
    ..aOS(7, _omitFieldNames ? '' : 'merkleRoot')
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'time', subBuilder: $0.Timestamp.$_createMessage)
    ..aI(9, _omitFieldNames ? '' : 'nonce', fieldType: $pb.PbFieldType.OU3)
    ..aOS(10, _omitFieldNames ? '' : 'bits')
    ..aD(11, _omitFieldNames ? '' : 'difficulty')
    ..aOS(12, _omitFieldNames ? '' : 'previousBlockHash')
    ..aOS(13, _omitFieldNames ? '' : 'nextBlockHash')
    ..aI(14, _omitFieldNames ? '' : 'strippedSize')
    ..aI(15, _omitFieldNames ? '' : 'size')
    ..aI(16, _omitFieldNames ? '' : 'weight')
    ..pPS(17, _omitFieldNames ? '' : 'txids')
    ..aOM<$0.Timestamp>(18, _omitFieldNames ? '' : 'medianTime', subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(19, _omitFieldNames ? '' : 'target')
    ..aOS(20, _omitFieldNames ? '' : 'chainwork')
    ..pPM<GetBlockResponse_Transaction>(21, _omitFieldNames ? '' : 'transactions',
        subBuilder: GetBlockResponse_Transaction.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockResponse copyWith(void Function(GetBlockResponse) updates) =>
      super.copyWith((message) => updates(message as GetBlockResponse)) as GetBlockResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockResponse() / GetBlockResponse.new instead')
  static GetBlockResponse create() => GetBlockResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockResponse._();
  @$core.override
  GetBlockResponse createEmptyInstance() => GetBlockResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBlockResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockResponse>(GetBlockResponse.$_createMessage);
  static GetBlockResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hex => $_getSZ(0);
  @$pb.TagNumber(1)
  set hex($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearHex() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get confirmations => $_getIZ(2);
  @$pb.TagNumber(3)
  set confirmations($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConfirmations() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfirmations() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get height => $_getIZ(3);
  @$pb.TagNumber(4)
  set height($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeight() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get version => $_getIZ(4);
  @$pb.TagNumber(5)
  set version($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get versionHex => $_getSZ(5);
  @$pb.TagNumber(6)
  set versionHex($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVersionHex() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersionHex() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get merkleRoot => $_getSZ(6);
  @$pb.TagNumber(7)
  set merkleRoot($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMerkleRoot() => $_has(6);
  @$pb.TagNumber(7)
  void clearMerkleRoot() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get time => $_getN(7);
  @$pb.TagNumber(8)
  set time($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearTime() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureTime() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.int get nonce => $_getIZ(8);
  @$pb.TagNumber(9)
  set nonce($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasNonce() => $_has(8);
  @$pb.TagNumber(9)
  void clearNonce() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get bits => $_getSZ(9);
  @$pb.TagNumber(10)
  set bits($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasBits() => $_has(9);
  @$pb.TagNumber(10)
  void clearBits() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get difficulty => $_getN(10);
  @$pb.TagNumber(11)
  set difficulty($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDifficulty() => $_has(10);
  @$pb.TagNumber(11)
  void clearDifficulty() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get previousBlockHash => $_getSZ(11);
  @$pb.TagNumber(12)
  set previousBlockHash($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPreviousBlockHash() => $_has(11);
  @$pb.TagNumber(12)
  void clearPreviousBlockHash() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get nextBlockHash => $_getSZ(12);
  @$pb.TagNumber(13)
  set nextBlockHash($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasNextBlockHash() => $_has(12);
  @$pb.TagNumber(13)
  void clearNextBlockHash() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get strippedSize => $_getIZ(13);
  @$pb.TagNumber(14)
  set strippedSize($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasStrippedSize() => $_has(13);
  @$pb.TagNumber(14)
  void clearStrippedSize() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get size => $_getIZ(14);
  @$pb.TagNumber(15)
  set size($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasSize() => $_has(14);
  @$pb.TagNumber(15)
  void clearSize() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.int get weight => $_getIZ(15);
  @$pb.TagNumber(16)
  set weight($core.int value) => $_setSignedInt32(15, value);
  @$pb.TagNumber(16)
  $core.bool hasWeight() => $_has(15);
  @$pb.TagNumber(16)
  void clearWeight() => $_clearField(16);

  /// List of transactions in the block, by TXID.
  /// Only set for verbosity level VERBOSITY_BLOCK_INFO
  @$pb.TagNumber(17)
  $pb.PbList<$core.String> get txids => $_getList(16);

  @$pb.TagNumber(18)
  $0.Timestamp get medianTime => $_getN(17);
  @$pb.TagNumber(18)
  set medianTime($0.Timestamp value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasMedianTime() => $_has(17);
  @$pb.TagNumber(18)
  void clearMedianTime() => $_clearField(18);
  @$pb.TagNumber(18)
  $0.Timestamp ensureMedianTime() => $_ensure(17);

  @$pb.TagNumber(19)
  $core.String get target => $_getSZ(18);
  @$pb.TagNumber(19)
  set target($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasTarget() => $_has(18);
  @$pb.TagNumber(19)
  void clearTarget() => $_clearField(19);

  /// Expected number of hashes required to produce the chain up to this block (in hex)
  @$pb.TagNumber(20)
  $core.String get chainwork => $_getSZ(19);
  @$pb.TagNumber(20)
  set chainwork($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasChainwork() => $_has(19);
  @$pb.TagNumber(20)
  void clearChainwork() => $_clearField(20);

  /// Only set for verbosity levels VERBOSITY_BLOCK_TX_INFO and VERBOSITY_BLOCK_TX_PREVOUT_INFO
  @$pb.TagNumber(21)
  $pb.PbList<GetBlockResponse_Transaction> get transactions => $_getList(20);
}

class BumpFeeRequest extends $pb.GeneratedMessage {
  factory BumpFeeRequest({
    $core.String? wallet,
    $core.String? txid,
  }) {
    final result = BumpFeeRequest._();
    if (wallet != null) result.wallet = wallet;
    if (txid != null) result.txid = txid;
    return result;
  }

  BumpFeeRequest._();

  factory BumpFeeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeeRequest()..mergeFromBuffer(data, registry);
  factory BumpFeeRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BumpFeeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: BumpFeeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeRequest copyWith(void Function(BumpFeeRequest) updates) =>
      super.copyWith((message) => updates(message as BumpFeeRequest)) as BumpFeeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BumpFeeRequest() / BumpFeeRequest.new instead')
  static BumpFeeRequest create() => BumpFeeRequest._();
  static $pb.GeneratedMessage $_createMessage() => BumpFeeRequest._();
  @$core.override
  BumpFeeRequest createEmptyInstance() => BumpFeeRequest._();
  @$core.pragma('dart2js:noInline')
  static BumpFeeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BumpFeeRequest>(BumpFeeRequest.$_createMessage);
  static BumpFeeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => $_clearField(1);

  /// The TXID to be bumped
  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => $_clearField(2);
}

class BumpFeeResponse extends $pb.GeneratedMessage {
  factory BumpFeeResponse({
    $core.String? txid,
    $core.double? originalFee,
    $core.double? newFee,
    $core.Iterable<$core.String>? errors,
  }) {
    final result = BumpFeeResponse._();
    if (txid != null) result.txid = txid;
    if (originalFee != null) result.originalFee = originalFee;
    if (newFee != null) result.newFee = newFee;
    if (errors != null) result.errors.addAll(errors);
    return result;
  }

  BumpFeeResponse._();

  factory BumpFeeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeeResponse()..mergeFromBuffer(data, registry);
  factory BumpFeeResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BumpFeeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: BumpFeeResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aD(2, _omitFieldNames ? '' : 'originalFee')
    ..aD(3, _omitFieldNames ? '' : 'newFee')
    ..pPS(4, _omitFieldNames ? '' : 'errors')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeResponse copyWith(void Function(BumpFeeResponse) updates) =>
      super.copyWith((message) => updates(message as BumpFeeResponse)) as BumpFeeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BumpFeeResponse() / BumpFeeResponse.new instead')
  static BumpFeeResponse create() => BumpFeeResponse._();
  static $pb.GeneratedMessage $_createMessage() => BumpFeeResponse._();
  @$core.override
  BumpFeeResponse createEmptyInstance() => BumpFeeResponse._();
  @$core.pragma('dart2js:noInline')
  static BumpFeeResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BumpFeeResponse>(BumpFeeResponse.$_createMessage);
  static BumpFeeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get originalFee => $_getN(1);
  @$pb.TagNumber(2)
  set originalFee($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOriginalFee() => $_has(1);
  @$pb.TagNumber(2)
  void clearOriginalFee() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get newFee => $_getN(2);
  @$pb.TagNumber(3)
  set newFee($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNewFee() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewFee() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get errors => $_getList(3);
}

class ListSinceBlockRequest extends $pb.GeneratedMessage {
  factory ListSinceBlockRequest({
    $core.String? wallet,
    $core.String? hash,
  }) {
    final result = ListSinceBlockRequest._();
    if (wallet != null) result.wallet = wallet;
    if (hash != null) result.hash = hash;
    return result;
  }

  ListSinceBlockRequest._();

  factory ListSinceBlockRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSinceBlockRequest()..mergeFromBuffer(data, registry);
  factory ListSinceBlockRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSinceBlockRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSinceBlockRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ListSinceBlockRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSinceBlockRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSinceBlockRequest copyWith(void Function(ListSinceBlockRequest) updates) =>
      super.copyWith((message) => updates(message as ListSinceBlockRequest)) as ListSinceBlockRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSinceBlockRequest() / ListSinceBlockRequest.new instead')
  static ListSinceBlockRequest create() => ListSinceBlockRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListSinceBlockRequest._();
  @$core.override
  ListSinceBlockRequest createEmptyInstance() => ListSinceBlockRequest._();
  @$core.pragma('dart2js:noInline')
  static ListSinceBlockRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSinceBlockRequest>(ListSinceBlockRequest.$_createMessage);
  static ListSinceBlockRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => $_clearField(1);

  /// If set, the block hash to list transactions since, otherwise list all transactions.
  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => $_clearField(2);
}

class ListSinceBlockResponse extends $pb.GeneratedMessage {
  factory ListSinceBlockResponse({
    $core.Iterable<GetTransactionResponse>? transactions,
  }) {
    final result = ListSinceBlockResponse._();
    if (transactions != null) result.transactions.addAll(transactions);
    return result;
  }

  ListSinceBlockResponse._();

  factory ListSinceBlockResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSinceBlockResponse()..mergeFromBuffer(data, registry);
  factory ListSinceBlockResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSinceBlockResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSinceBlockResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ListSinceBlockResponse.$_createMessage)
    ..pPM<GetTransactionResponse>(1, _omitFieldNames ? '' : 'transactions',
        subBuilder: GetTransactionResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSinceBlockResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSinceBlockResponse copyWith(void Function(ListSinceBlockResponse) updates) =>
      super.copyWith((message) => updates(message as ListSinceBlockResponse)) as ListSinceBlockResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSinceBlockResponse() / ListSinceBlockResponse.new instead')
  static ListSinceBlockResponse create() => ListSinceBlockResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListSinceBlockResponse._();
  @$core.override
  ListSinceBlockResponse createEmptyInstance() => ListSinceBlockResponse._();
  @$core.pragma('dart2js:noInline')
  static ListSinceBlockResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSinceBlockResponse>(ListSinceBlockResponse.$_createMessage);
  static ListSinceBlockResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GetTransactionResponse> get transactions => $_getList(0);
}

class GetRawMempoolRequest extends $pb.GeneratedMessage {
  factory GetRawMempoolRequest({
    $core.bool? verbose,
  }) {
    final result = GetRawMempoolRequest._();
    if (verbose != null) result.verbose = verbose;
    return result;
  }

  GetRawMempoolRequest._();

  factory GetRawMempoolRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRawMempoolRequest()..mergeFromBuffer(data, registry);
  factory GetRawMempoolRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRawMempoolRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRawMempoolRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetRawMempoolRequest.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'verbose')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRawMempoolRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRawMempoolRequest copyWith(void Function(GetRawMempoolRequest) updates) =>
      super.copyWith((message) => updates(message as GetRawMempoolRequest)) as GetRawMempoolRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetRawMempoolRequest() / GetRawMempoolRequest.new instead')
  static GetRawMempoolRequest create() => GetRawMempoolRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetRawMempoolRequest._();
  @$core.override
  GetRawMempoolRequest createEmptyInstance() => GetRawMempoolRequest._();
  @$core.pragma('dart2js:noInline')
  static GetRawMempoolRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRawMempoolRequest>(GetRawMempoolRequest.$_createMessage);
  static GetRawMempoolRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get verbose => $_getBF(0);
  @$pb.TagNumber(1)
  set verbose($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVerbose() => $_has(0);
  @$pb.TagNumber(1)
  void clearVerbose() => $_clearField(1);
}

/// All values are in whole bitcoins
class MempoolEntry_Fees extends $pb.GeneratedMessage {
  factory MempoolEntry_Fees({
    $core.double? base,
    $core.double? modified,
    $core.double? ancestor,
    $core.double? descendant,
  }) {
    final result = MempoolEntry_Fees._();
    if (base != null) result.base = base;
    if (modified != null) result.modified = modified;
    if (ancestor != null) result.ancestor = ancestor;
    if (descendant != null) result.descendant = descendant;
    return result;
  }

  MempoolEntry_Fees._();

  factory MempoolEntry_Fees.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MempoolEntry_Fees()..mergeFromBuffer(data, registry);
  factory MempoolEntry_Fees.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MempoolEntry_Fees()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MempoolEntry.Fees',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: MempoolEntry_Fees.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'base')
    ..aD(2, _omitFieldNames ? '' : 'modified')
    ..aD(3, _omitFieldNames ? '' : 'ancestor')
    ..aD(4, _omitFieldNames ? '' : 'descendant')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MempoolEntry_Fees clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MempoolEntry_Fees copyWith(void Function(MempoolEntry_Fees) updates) =>
      super.copyWith((message) => updates(message as MempoolEntry_Fees)) as MempoolEntry_Fees;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MempoolEntry_Fees() / MempoolEntry_Fees.new instead')
  static MempoolEntry_Fees create() => MempoolEntry_Fees._();
  static $pb.GeneratedMessage $_createMessage() => MempoolEntry_Fees._();
  @$core.override
  MempoolEntry_Fees createEmptyInstance() => MempoolEntry_Fees._();
  @$core.pragma('dart2js:noInline')
  static MempoolEntry_Fees getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MempoolEntry_Fees>(MempoolEntry_Fees.$_createMessage);
  static MempoolEntry_Fees? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get base => $_getN(0);
  @$pb.TagNumber(1)
  set base($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBase() => $_has(0);
  @$pb.TagNumber(1)
  void clearBase() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get modified => $_getN(1);
  @$pb.TagNumber(2)
  set modified($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasModified() => $_has(1);
  @$pb.TagNumber(2)
  void clearModified() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get ancestor => $_getN(2);
  @$pb.TagNumber(3)
  set ancestor($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAncestor() => $_has(2);
  @$pb.TagNumber(3)
  void clearAncestor() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get descendant => $_getN(3);
  @$pb.TagNumber(4)
  set descendant($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescendant() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescendant() => $_clearField(4);
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
    final result = MempoolEntry._();
    if (virtualSize != null) result.virtualSize = virtualSize;
    if (weight != null) result.weight = weight;
    if (time != null) result.time = time;
    if (descendantCount != null) result.descendantCount = descendantCount;
    if (descendantSize != null) result.descendantSize = descendantSize;
    if (ancestorCount != null) result.ancestorCount = ancestorCount;
    if (ancestorSize != null) result.ancestorSize = ancestorSize;
    if (witnessTxid != null) result.witnessTxid = witnessTxid;
    if (fees != null) result.fees = fees;
    if (depends != null) result.depends.addAll(depends);
    if (spentBy != null) result.spentBy.addAll(spentBy);
    if (bip125Replaceable != null) result.bip125Replaceable = bip125Replaceable;
    if (unbroadcast != null) result.unbroadcast = unbroadcast;
    return result;
  }

  MempoolEntry._();

  factory MempoolEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MempoolEntry()..mergeFromBuffer(data, registry);
  factory MempoolEntry.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MempoolEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MempoolEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: MempoolEntry.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'virtualSize', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'weight', fieldType: $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'time', subBuilder: $0.Timestamp.$_createMessage)
    ..aI(4, _omitFieldNames ? '' : 'descendantCount', fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'descendantSize', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'ancestorCount', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'ancestorSize', fieldType: $pb.PbFieldType.OU3)
    ..aOS(8, _omitFieldNames ? '' : 'witnessTxid')
    ..aOM<MempoolEntry_Fees>(9, _omitFieldNames ? '' : 'fees', subBuilder: MempoolEntry_Fees.$_createMessage)
    ..pPS(10, _omitFieldNames ? '' : 'depends')
    ..pPS(11, _omitFieldNames ? '' : 'spentBy')
    ..aOB(12, _omitFieldNames ? '' : 'bip125Replaceable')
    ..aOB(13, _omitFieldNames ? '' : 'unbroadcast')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MempoolEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MempoolEntry copyWith(void Function(MempoolEntry) updates) =>
      super.copyWith((message) => updates(message as MempoolEntry)) as MempoolEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MempoolEntry() / MempoolEntry.new instead')
  static MempoolEntry create() => MempoolEntry._();
  static $pb.GeneratedMessage $_createMessage() => MempoolEntry._();
  @$core.override
  MempoolEntry createEmptyInstance() => MempoolEntry._();
  @$core.pragma('dart2js:noInline')
  static MempoolEntry getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MempoolEntry>(MempoolEntry.$_createMessage);
  static MempoolEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get virtualSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set virtualSize($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVirtualSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearVirtualSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get weight => $_getIZ(1);
  @$pb.TagNumber(2)
  set weight($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearWeight() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get time => $_getN(2);
  @$pb.TagNumber(3)
  set time($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearTime() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureTime() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.int get descendantCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set descendantCount($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescendantCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescendantCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get descendantSize => $_getIZ(4);
  @$pb.TagNumber(5)
  set descendantSize($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescendantSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescendantSize() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get ancestorCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set ancestorCount($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAncestorCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearAncestorCount() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get ancestorSize => $_getIZ(6);
  @$pb.TagNumber(7)
  set ancestorSize($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAncestorSize() => $_has(6);
  @$pb.TagNumber(7)
  void clearAncestorSize() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get witnessTxid => $_getSZ(7);
  @$pb.TagNumber(8)
  set witnessTxid($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWitnessTxid() => $_has(7);
  @$pb.TagNumber(8)
  void clearWitnessTxid() => $_clearField(8);

  @$pb.TagNumber(9)
  MempoolEntry_Fees get fees => $_getN(8);
  @$pb.TagNumber(9)
  set fees(MempoolEntry_Fees value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasFees() => $_has(8);
  @$pb.TagNumber(9)
  void clearFees() => $_clearField(9);
  @$pb.TagNumber(9)
  MempoolEntry_Fees ensureFees() => $_ensure(8);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get depends => $_getList(9);

  @$pb.TagNumber(11)
  $pb.PbList<$core.String> get spentBy => $_getList(10);

  @$pb.TagNumber(12)
  $core.bool get bip125Replaceable => $_getBF(11);
  @$pb.TagNumber(12)
  set bip125Replaceable($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasBip125Replaceable() => $_has(11);
  @$pb.TagNumber(12)
  void clearBip125Replaceable() => $_clearField(12);

  /// A transaction is unbroadcast if initial broadcast not yet
  /// acknowledged by any peers.
  @$pb.TagNumber(13)
  $core.bool get unbroadcast => $_getBF(12);
  @$pb.TagNumber(13)
  set unbroadcast($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasUnbroadcast() => $_has(12);
  @$pb.TagNumber(13)
  void clearUnbroadcast() => $_clearField(13);
}

class GetRawMempoolResponse extends $pb.GeneratedMessage {
  factory GetRawMempoolResponse({
    $core.Iterable<$core.String>? txids,
    $core.Iterable<$core.MapEntry<$core.String, MempoolEntry>>? transactions,
  }) {
    final result = GetRawMempoolResponse._();
    if (txids != null) result.txids.addAll(txids);
    if (transactions != null) result.transactions.addEntries(transactions);
    return result;
  }

  GetRawMempoolResponse._();

  factory GetRawMempoolResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRawMempoolResponse()..mergeFromBuffer(data, registry);
  factory GetRawMempoolResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRawMempoolResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRawMempoolResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetRawMempoolResponse.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'txids')
    ..m<$core.String, MempoolEntry>(2, _omitFieldNames ? '' : 'transactions',
        entryClassName: 'GetRawMempoolResponse.TransactionsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: MempoolEntry.$_createMessage,
        valueDefaultOrMaker: MempoolEntry.getDefault,
        packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRawMempoolResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRawMempoolResponse copyWith(void Function(GetRawMempoolResponse) updates) =>
      super.copyWith((message) => updates(message as GetRawMempoolResponse)) as GetRawMempoolResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetRawMempoolResponse() / GetRawMempoolResponse.new instead')
  static GetRawMempoolResponse create() => GetRawMempoolResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetRawMempoolResponse._();
  @$core.override
  GetRawMempoolResponse createEmptyInstance() => GetRawMempoolResponse._();
  @$core.pragma('dart2js:noInline')
  static GetRawMempoolResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRawMempoolResponse>(GetRawMempoolResponse.$_createMessage);
  static GetRawMempoolResponse? _defaultInstance;

  /// Only set if this is a non-verbose response
  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get txids => $_getList(0);

  /// Only set if this is a verbose response
  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, MempoolEntry> get transactions => $_getMap(1);
}

class GetBlockHashRequest extends $pb.GeneratedMessage {
  factory GetBlockHashRequest({
    $core.int? height,
  }) {
    final result = GetBlockHashRequest._();
    if (height != null) result.height = height;
    return result;
  }

  GetBlockHashRequest._();

  factory GetBlockHashRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockHashRequest()..mergeFromBuffer(data, registry);
  factory GetBlockHashRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockHashRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockHashRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetBlockHashRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockHashRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockHashRequest copyWith(void Function(GetBlockHashRequest) updates) =>
      super.copyWith((message) => updates(message as GetBlockHashRequest)) as GetBlockHashRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockHashRequest() / GetBlockHashRequest.new instead')
  static GetBlockHashRequest create() => GetBlockHashRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockHashRequest._();
  @$core.override
  GetBlockHashRequest createEmptyInstance() => GetBlockHashRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBlockHashRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockHashRequest>(GetBlockHashRequest.$_createMessage);
  static GetBlockHashRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get height => $_getIZ(0);
  @$pb.TagNumber(1)
  set height($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => $_clearField(1);
}

class GetBlockHashResponse extends $pb.GeneratedMessage {
  factory GetBlockHashResponse({
    $core.String? hash,
  }) {
    final result = GetBlockHashResponse._();
    if (hash != null) result.hash = hash;
    return result;
  }

  GetBlockHashResponse._();

  factory GetBlockHashResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockHashResponse()..mergeFromBuffer(data, registry);
  factory GetBlockHashResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockHashResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockHashResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetBlockHashResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockHashResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockHashResponse copyWith(void Function(GetBlockHashResponse) updates) =>
      super.copyWith((message) => updates(message as GetBlockHashResponse)) as GetBlockHashResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockHashResponse() / GetBlockHashResponse.new instead')
  static GetBlockHashResponse create() => GetBlockHashResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockHashResponse._();
  @$core.override
  GetBlockHashResponse createEmptyInstance() => GetBlockHashResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBlockHashResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockHashResponse>(GetBlockHashResponse.$_createMessage);
  static GetBlockHashResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => $_clearField(1);
}

class ListTransactionsRequest extends $pb.GeneratedMessage {
  factory ListTransactionsRequest({
    $core.String? wallet,
    $core.int? count,
    $core.int? skip,
  }) {
    final result = ListTransactionsRequest._();
    if (wallet != null) result.wallet = wallet;
    if (count != null) result.count = count;
    if (skip != null) result.skip = skip;
    return result;
  }

  ListTransactionsRequest._();

  factory ListTransactionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsRequest()..mergeFromBuffer(data, registry);
  factory ListTransactionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ListTransactionsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..aI(2, _omitFieldNames ? '' : 'count', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'skip', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsRequest copyWith(void Function(ListTransactionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListTransactionsRequest)) as ListTransactionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListTransactionsRequest() / ListTransactionsRequest.new instead')
  static ListTransactionsRequest create() => ListTransactionsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListTransactionsRequest._();
  @$core.override
  ListTransactionsRequest createEmptyInstance() => ListTransactionsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTransactionsRequest>(ListTransactionsRequest.$_createMessage);
  static ListTransactionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => $_clearField(1);

  /// Defaults to 10
  @$pb.TagNumber(2)
  $core.int get count => $_getIZ(1);
  @$pb.TagNumber(2)
  set count($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get skip => $_getIZ(2);
  @$pb.TagNumber(3)
  set skip($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSkip() => $_has(2);
  @$pb.TagNumber(3)
  void clearSkip() => $_clearField(3);
}

class ListTransactionsResponse extends $pb.GeneratedMessage {
  factory ListTransactionsResponse({
    $core.Iterable<GetTransactionResponse>? transactions,
  }) {
    final result = ListTransactionsResponse._();
    if (transactions != null) result.transactions.addAll(transactions);
    return result;
  }

  ListTransactionsResponse._();

  factory ListTransactionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsResponse()..mergeFromBuffer(data, registry);
  factory ListTransactionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ListTransactionsResponse.$_createMessage)
    ..pPM<GetTransactionResponse>(1, _omitFieldNames ? '' : 'transactions',
        subBuilder: GetTransactionResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsResponse copyWith(void Function(ListTransactionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListTransactionsResponse)) as ListTransactionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListTransactionsResponse() / ListTransactionsResponse.new instead')
  static ListTransactionsResponse create() => ListTransactionsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListTransactionsResponse._();
  @$core.override
  ListTransactionsResponse createEmptyInstance() => ListTransactionsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTransactionsResponse>(ListTransactionsResponse.$_createMessage);
  static ListTransactionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GetTransactionResponse> get transactions => $_getList(0);
}

class ListWalletsResponse extends $pb.GeneratedMessage {
  factory ListWalletsResponse({
    $core.Iterable<$core.String>? wallets,
  }) {
    final result = ListWalletsResponse._();
    if (wallets != null) result.wallets.addAll(wallets);
    return result;
  }

  ListWalletsResponse._();

  factory ListWalletsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWalletsResponse()..mergeFromBuffer(data, registry);
  factory ListWalletsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWalletsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListWalletsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ListWalletsResponse.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'wallets')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWalletsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWalletsResponse copyWith(void Function(ListWalletsResponse) updates) =>
      super.copyWith((message) => updates(message as ListWalletsResponse)) as ListWalletsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListWalletsResponse() / ListWalletsResponse.new instead')
  static ListWalletsResponse create() => ListWalletsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListWalletsResponse._();
  @$core.override
  ListWalletsResponse createEmptyInstance() => ListWalletsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListWalletsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListWalletsResponse>(ListWalletsResponse.$_createMessage);
  static ListWalletsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get wallets => $_getList(0);
}

class ListUnspentRequest extends $pb.GeneratedMessage {
  factory ListUnspentRequest({
    $core.String? wallet,
    $core.int? minimumConfirmations,
    $core.int? maximumConfirmations,
    $core.Iterable<$core.String>? addresses,
    $core.bool? includeUnsafe,
  }) {
    final result = ListUnspentRequest._();
    if (wallet != null) result.wallet = wallet;
    if (minimumConfirmations != null) result.minimumConfirmations = minimumConfirmations;
    if (maximumConfirmations != null) result.maximumConfirmations = maximumConfirmations;
    if (addresses != null) result.addresses.addAll(addresses);
    if (includeUnsafe != null) result.includeUnsafe = includeUnsafe;
    return result;
  }

  ListUnspentRequest._();

  factory ListUnspentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUnspentRequest()..mergeFromBuffer(data, registry);
  factory ListUnspentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUnspentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUnspentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ListUnspentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..aI(2, _omitFieldNames ? '' : 'minimumConfirmations', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'maximumConfirmations', fieldType: $pb.PbFieldType.OU3)
    ..pPS(4, _omitFieldNames ? '' : 'addresses')
    ..aOB(5, _omitFieldNames ? '' : 'includeUnsafe')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentRequest copyWith(void Function(ListUnspentRequest) updates) =>
      super.copyWith((message) => updates(message as ListUnspentRequest)) as ListUnspentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListUnspentRequest() / ListUnspentRequest.new instead')
  static ListUnspentRequest create() => ListUnspentRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListUnspentRequest._();
  @$core.override
  ListUnspentRequest createEmptyInstance() => ListUnspentRequest._();
  @$core.pragma('dart2js:noInline')
  static ListUnspentRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUnspentRequest>(ListUnspentRequest.$_createMessage);
  static ListUnspentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => $_clearField(1);

  /// The minimum confirmations to filter
  @$pb.TagNumber(2)
  $core.int get minimumConfirmations => $_getIZ(1);
  @$pb.TagNumber(2)
  set minimumConfirmations($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMinimumConfirmations() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinimumConfirmations() => $_clearField(2);

  /// The maximum confirmations to filter
  @$pb.TagNumber(3)
  $core.int get maximumConfirmations => $_getIZ(2);
  @$pb.TagNumber(3)
  set maximumConfirmations($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaximumConfirmations() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaximumConfirmations() => $_clearField(3);

  /// The bitcoin addresses to filter
  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get addresses => $_getList(3);

  /// Whether to include unsafe outputs
  @$pb.TagNumber(5)
  $core.bool get includeUnsafe => $_getBF(4);
  @$pb.TagNumber(5)
  set includeUnsafe($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIncludeUnsafe() => $_has(4);
  @$pb.TagNumber(5)
  void clearIncludeUnsafe() => $_clearField(5);
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
    final result = UnspentOutput._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (address != null) result.address = address;
    if (scriptPubKey != null) result.scriptPubKey = scriptPubKey;
    if (amount != null) result.amount = amount;
    if (confirmations != null) result.confirmations = confirmations;
    if (redeemScript != null) result.redeemScript = redeemScript;
    if (spendable != null) result.spendable = spendable;
    return result;
  }

  UnspentOutput._();

  factory UnspentOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnspentOutput()..mergeFromBuffer(data, registry);
  factory UnspentOutput.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnspentOutput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnspentOutput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: UnspentOutput.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'vout', fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aOS(5, _omitFieldNames ? '' : 'scriptPubKey')
    ..aD(6, _omitFieldNames ? '' : 'amount')
    ..aI(7, _omitFieldNames ? '' : 'confirmations', fieldType: $pb.PbFieldType.OU3)
    ..aOS(11, _omitFieldNames ? '' : 'redeemScript')
    ..aOB(13, _omitFieldNames ? '' : 'spendable')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnspentOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnspentOutput copyWith(void Function(UnspentOutput) updates) =>
      super.copyWith((message) => updates(message as UnspentOutput)) as UnspentOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UnspentOutput() / UnspentOutput.new instead')
  static UnspentOutput create() => UnspentOutput._();
  static $pb.GeneratedMessage $_createMessage() => UnspentOutput._();
  @$core.override
  UnspentOutput createEmptyInstance() => UnspentOutput._();
  @$core.pragma('dart2js:noInline')
  static UnspentOutput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnspentOutput>(UnspentOutput.$_createMessage);
  static UnspentOutput? _defaultInstance;

  /// The transaction id
  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  /// The vout value
  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);

  /// The bitcoin address (optional)
  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => $_clearField(3);

  /// The output script
  @$pb.TagNumber(5)
  $core.String get scriptPubKey => $_getSZ(3);
  @$pb.TagNumber(5)
  set scriptPubKey($core.String value) => $_setString(3, value);
  @$pb.TagNumber(5)
  $core.bool hasScriptPubKey() => $_has(3);
  @$pb.TagNumber(5)
  void clearScriptPubKey() => $_clearField(5);

  /// The transaction output amount in BTC
  @$pb.TagNumber(6)
  $core.double get amount => $_getN(4);
  @$pb.TagNumber(6)
  set amount($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(6)
  $core.bool hasAmount() => $_has(4);
  @$pb.TagNumber(6)
  void clearAmount() => $_clearField(6);

  /// The number of confirmations
  @$pb.TagNumber(7)
  $core.int get confirmations => $_getIZ(5);
  @$pb.TagNumber(7)
  set confirmations($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(7)
  $core.bool hasConfirmations() => $_has(5);
  @$pb.TagNumber(7)
  void clearConfirmations() => $_clearField(7);

  /// The redeem script if the output script is P2SH (optional)
  @$pb.TagNumber(11)
  $core.String get redeemScript => $_getSZ(6);
  @$pb.TagNumber(11)
  set redeemScript($core.String value) => $_setString(6, value);
  @$pb.TagNumber(11)
  $core.bool hasRedeemScript() => $_has(6);
  @$pb.TagNumber(11)
  void clearRedeemScript() => $_clearField(11);

  /// Whether we have the private keys to spend this output
  @$pb.TagNumber(13)
  $core.bool get spendable => $_getBF(7);
  @$pb.TagNumber(13)
  set spendable($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(13)
  $core.bool hasSpendable() => $_has(7);
  @$pb.TagNumber(13)
  void clearSpendable() => $_clearField(13);
}

class ListUnspentResponse extends $pb.GeneratedMessage {
  factory ListUnspentResponse({
    $core.Iterable<UnspentOutput>? unspent,
  }) {
    final result = ListUnspentResponse._();
    if (unspent != null) result.unspent.addAll(unspent);
    return result;
  }

  ListUnspentResponse._();

  factory ListUnspentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUnspentResponse()..mergeFromBuffer(data, registry);
  factory ListUnspentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUnspentResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUnspentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ListUnspentResponse.$_createMessage)
    ..pPM<UnspentOutput>(1, _omitFieldNames ? '' : 'unspent', subBuilder: UnspentOutput.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentResponse copyWith(void Function(ListUnspentResponse) updates) =>
      super.copyWith((message) => updates(message as ListUnspentResponse)) as ListUnspentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListUnspentResponse() / ListUnspentResponse.new instead')
  static ListUnspentResponse create() => ListUnspentResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListUnspentResponse._();
  @$core.override
  ListUnspentResponse createEmptyInstance() => ListUnspentResponse._();
  @$core.pragma('dart2js:noInline')
  static ListUnspentResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUnspentResponse>(ListUnspentResponse.$_createMessage);
  static ListUnspentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<UnspentOutput> get unspent => $_getList(0);
}

class GetAddressInfoRequest extends $pb.GeneratedMessage {
  factory GetAddressInfoRequest({
    $core.String? address,
    $core.String? wallet,
  }) {
    final result = GetAddressInfoRequest._();
    if (address != null) result.address = address;
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  GetAddressInfoRequest._();

  factory GetAddressInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressInfoRequest()..mergeFromBuffer(data, registry);
  factory GetAddressInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetAddressInfoRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressInfoRequest copyWith(void Function(GetAddressInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetAddressInfoRequest)) as GetAddressInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetAddressInfoRequest() / GetAddressInfoRequest.new instead')
  static GetAddressInfoRequest create() => GetAddressInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetAddressInfoRequest._();
  @$core.override
  GetAddressInfoRequest createEmptyInstance() => GetAddressInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetAddressInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAddressInfoRequest>(GetAddressInfoRequest.$_createMessage);
  static GetAddressInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => $_clearField(2);
}

class GetAddressInfoResponse extends $pb.GeneratedMessage {
  factory GetAddressInfoResponse({
    $core.String? address,
    $core.String? scriptPubKey,
    $core.bool? isMine,
    $core.bool? solvable,
    $core.bool? isScript,
    $core.bool? isChange,
    $core.bool? isWitness,
    $core.int? witnessVersion,
    $core.String? witnessProgram,
    $core.String? scriptType,
    $core.bool? isCompressed,
  }) {
    final result = GetAddressInfoResponse._();
    if (address != null) result.address = address;
    if (scriptPubKey != null) result.scriptPubKey = scriptPubKey;
    if (isMine != null) result.isMine = isMine;
    if (solvable != null) result.solvable = solvable;
    if (isScript != null) result.isScript = isScript;
    if (isChange != null) result.isChange = isChange;
    if (isWitness != null) result.isWitness = isWitness;
    if (witnessVersion != null) result.witnessVersion = witnessVersion;
    if (witnessProgram != null) result.witnessProgram = witnessProgram;
    if (scriptType != null) result.scriptType = scriptType;
    if (isCompressed != null) result.isCompressed = isCompressed;
    return result;
  }

  GetAddressInfoResponse._();

  factory GetAddressInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressInfoResponse()..mergeFromBuffer(data, registry);
  factory GetAddressInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetAddressInfoResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'scriptPubKey')
    ..aOB(3, _omitFieldNames ? '' : 'isMine')
    ..aOB(5, _omitFieldNames ? '' : 'solvable')
    ..aOB(6, _omitFieldNames ? '' : 'isScript')
    ..aOB(7, _omitFieldNames ? '' : 'isChange')
    ..aOB(8, _omitFieldNames ? '' : 'isWitness')
    ..aI(9, _omitFieldNames ? '' : 'witnessVersion', fieldType: $pb.PbFieldType.OU3)
    ..aOS(10, _omitFieldNames ? '' : 'witnessProgram')
    ..aOS(11, _omitFieldNames ? '' : 'scriptType')
    ..aOB(12, _omitFieldNames ? '' : 'isCompressed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressInfoResponse copyWith(void Function(GetAddressInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetAddressInfoResponse)) as GetAddressInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetAddressInfoResponse() / GetAddressInfoResponse.new instead')
  static GetAddressInfoResponse create() => GetAddressInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetAddressInfoResponse._();
  @$core.override
  GetAddressInfoResponse createEmptyInstance() => GetAddressInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetAddressInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAddressInfoResponse>(GetAddressInfoResponse.$_createMessage);
  static GetAddressInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  /// Hex-encoded script pub key
  @$pb.TagNumber(2)
  $core.String get scriptPubKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set scriptPubKey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScriptPubKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearScriptPubKey() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isMine => $_getBF(2);
  @$pb.TagNumber(3)
  set isMine($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsMine() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsMine() => $_clearField(3);

  /// If Core knows how to spend coins sent to this address, ignoring
  /// possible lack of private keys.
  @$pb.TagNumber(5)
  $core.bool get solvable => $_getBF(3);
  @$pb.TagNumber(5)
  set solvable($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(5)
  $core.bool hasSolvable() => $_has(3);
  @$pb.TagNumber(5)
  void clearSolvable() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isScript => $_getBF(4);
  @$pb.TagNumber(6)
  set isScript($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(6)
  $core.bool hasIsScript() => $_has(4);
  @$pb.TagNumber(6)
  void clearIsScript() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isChange => $_getBF(5);
  @$pb.TagNumber(7)
  set isChange($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(7)
  $core.bool hasIsChange() => $_has(5);
  @$pb.TagNumber(7)
  void clearIsChange() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isWitness => $_getBF(6);
  @$pb.TagNumber(8)
  set isWitness($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(8)
  $core.bool hasIsWitness() => $_has(6);
  @$pb.TagNumber(8)
  void clearIsWitness() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get witnessVersion => $_getIZ(7);
  @$pb.TagNumber(9)
  set witnessVersion($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(9)
  $core.bool hasWitnessVersion() => $_has(7);
  @$pb.TagNumber(9)
  void clearWitnessVersion() => $_clearField(9);

  /// Hex-encoded
  @$pb.TagNumber(10)
  $core.String get witnessProgram => $_getSZ(8);
  @$pb.TagNumber(10)
  set witnessProgram($core.String value) => $_setString(8, value);
  @$pb.TagNumber(10)
  $core.bool hasWitnessProgram() => $_has(8);
  @$pb.TagNumber(10)
  void clearWitnessProgram() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get scriptType => $_getSZ(9);
  @$pb.TagNumber(11)
  set scriptType($core.String value) => $_setString(9, value);
  @$pb.TagNumber(11)
  $core.bool hasScriptType() => $_has(9);
  @$pb.TagNumber(11)
  void clearScriptType() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get isCompressed => $_getBF(10);
  @$pb.TagNumber(12)
  set isCompressed($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(12)
  $core.bool hasIsCompressed() => $_has(10);
  @$pb.TagNumber(12)
  void clearIsCompressed() => $_clearField(12);
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
    final result = CreateWalletRequest._();
    if (name != null) result.name = name;
    if (disablePrivateKeys != null) result.disablePrivateKeys = disablePrivateKeys;
    if (blank != null) result.blank = blank;
    if (passphrase != null) result.passphrase = passphrase;
    if (avoidReuse != null) result.avoidReuse = avoidReuse;
    return result;
  }

  CreateWalletRequest._();

  factory CreateWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateWalletRequest()..mergeFromBuffer(data, registry);
  factory CreateWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: CreateWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOB(2, _omitFieldNames ? '' : 'disablePrivateKeys')
    ..aOB(3, _omitFieldNames ? '' : 'blank')
    ..aOS(4, _omitFieldNames ? '' : 'passphrase')
    ..aOB(5, _omitFieldNames ? '' : 'avoidReuse')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateWalletRequest copyWith(void Function(CreateWalletRequest) updates) =>
      super.copyWith((message) => updates(message as CreateWalletRequest)) as CreateWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateWalletRequest() / CreateWalletRequest.new instead')
  static CreateWalletRequest create() => CreateWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateWalletRequest._();
  @$core.override
  CreateWalletRequest createEmptyInstance() => CreateWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateWalletRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateWalletRequest>(CreateWalletRequest.$_createMessage);
  static CreateWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get disablePrivateKeys => $_getBF(1);
  @$pb.TagNumber(2)
  set disablePrivateKeys($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisablePrivateKeys() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisablePrivateKeys() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get blank => $_getBF(2);
  @$pb.TagNumber(3)
  set blank($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBlank() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlank() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get passphrase => $_getSZ(3);
  @$pb.TagNumber(4)
  set passphrase($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPassphrase() => $_has(3);
  @$pb.TagNumber(4)
  void clearPassphrase() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get avoidReuse => $_getBF(4);
  @$pb.TagNumber(5)
  set avoidReuse($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAvoidReuse() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvoidReuse() => $_clearField(5);
}

class CreateWalletResponse extends $pb.GeneratedMessage {
  factory CreateWalletResponse({
    $core.String? name,
    $core.String? warning,
  }) {
    final result = CreateWalletResponse._();
    if (name != null) result.name = name;
    if (warning != null) result.warning = warning;
    return result;
  }

  CreateWalletResponse._();

  factory CreateWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateWalletResponse()..mergeFromBuffer(data, registry);
  factory CreateWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: CreateWalletResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'warning')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateWalletResponse copyWith(void Function(CreateWalletResponse) updates) =>
      super.copyWith((message) => updates(message as CreateWalletResponse)) as CreateWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateWalletResponse() / CreateWalletResponse.new instead')
  static CreateWalletResponse create() => CreateWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateWalletResponse._();
  @$core.override
  CreateWalletResponse createEmptyInstance() => CreateWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateWalletResponse>(CreateWalletResponse.$_createMessage);
  static CreateWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get warning => $_getSZ(1);
  @$pb.TagNumber(2)
  set warning($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWarning() => $_has(1);
  @$pb.TagNumber(2)
  void clearWarning() => $_clearField(2);
}

class LoadWalletRequest extends $pb.GeneratedMessage {
  factory LoadWalletRequest({
    $core.String? filename,
    $core.bool? loadOnStartup,
  }) {
    final result = LoadWalletRequest._();
    if (filename != null) result.filename = filename;
    if (loadOnStartup != null) result.loadOnStartup = loadOnStartup;
    return result;
  }

  LoadWalletRequest._();

  factory LoadWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadWalletRequest()..mergeFromBuffer(data, registry);
  factory LoadWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoadWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: LoadWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'filename')
    ..aOB(2, _omitFieldNames ? '' : 'loadOnStartup')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadWalletRequest copyWith(void Function(LoadWalletRequest) updates) =>
      super.copyWith((message) => updates(message as LoadWalletRequest)) as LoadWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LoadWalletRequest() / LoadWalletRequest.new instead')
  static LoadWalletRequest create() => LoadWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoadWalletRequest._();
  @$core.override
  LoadWalletRequest createEmptyInstance() => LoadWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static LoadWalletRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoadWalletRequest>(LoadWalletRequest.$_createMessage);
  static LoadWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filename => $_getSZ(0);
  @$pb.TagNumber(1)
  set filename($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFilename() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilename() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get loadOnStartup => $_getBF(1);
  @$pb.TagNumber(2)
  set loadOnStartup($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLoadOnStartup() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoadOnStartup() => $_clearField(2);
}

class LoadWalletResponse extends $pb.GeneratedMessage {
  factory LoadWalletResponse({
    $core.String? name,
    $core.Iterable<$core.String>? warnings,
  }) {
    final result = LoadWalletResponse._();
    if (name != null) result.name = name;
    if (warnings != null) result.warnings.addAll(warnings);
    return result;
  }

  LoadWalletResponse._();

  factory LoadWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadWalletResponse()..mergeFromBuffer(data, registry);
  factory LoadWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoadWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: LoadWalletResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..pPS(2, _omitFieldNames ? '' : 'warnings')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadWalletResponse copyWith(void Function(LoadWalletResponse) updates) =>
      super.copyWith((message) => updates(message as LoadWalletResponse)) as LoadWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LoadWalletResponse() / LoadWalletResponse.new instead')
  static LoadWalletResponse create() => LoadWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => LoadWalletResponse._();
  @$core.override
  LoadWalletResponse createEmptyInstance() => LoadWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static LoadWalletResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoadWalletResponse>(LoadWalletResponse.$_createMessage);
  static LoadWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get warnings => $_getList(1);
}

class BackupWalletRequest extends $pb.GeneratedMessage {
  factory BackupWalletRequest({
    $core.String? destination,
    $core.String? wallet,
  }) {
    final result = BackupWalletRequest._();
    if (destination != null) result.destination = destination;
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  BackupWalletRequest._();

  factory BackupWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BackupWalletRequest()..mergeFromBuffer(data, registry);
  factory BackupWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BackupWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BackupWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: BackupWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'destination')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BackupWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BackupWalletRequest copyWith(void Function(BackupWalletRequest) updates) =>
      super.copyWith((message) => updates(message as BackupWalletRequest)) as BackupWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BackupWalletRequest() / BackupWalletRequest.new instead')
  static BackupWalletRequest create() => BackupWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => BackupWalletRequest._();
  @$core.override
  BackupWalletRequest createEmptyInstance() => BackupWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static BackupWalletRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BackupWalletRequest>(BackupWalletRequest.$_createMessage);
  static BackupWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get destination => $_getSZ(0);
  @$pb.TagNumber(1)
  set destination($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDestination() => $_has(0);
  @$pb.TagNumber(1)
  void clearDestination() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => $_clearField(2);
}

class BackupWalletResponse extends $pb.GeneratedMessage {
  factory BackupWalletResponse() => BackupWalletResponse._();

  BackupWalletResponse._();

  factory BackupWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BackupWalletResponse()..mergeFromBuffer(data, registry);
  factory BackupWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BackupWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BackupWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: BackupWalletResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BackupWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BackupWalletResponse copyWith(void Function(BackupWalletResponse) updates) =>
      super.copyWith((message) => updates(message as BackupWalletResponse)) as BackupWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BackupWalletResponse() / BackupWalletResponse.new instead')
  static BackupWalletResponse create() => BackupWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => BackupWalletResponse._();
  @$core.override
  BackupWalletResponse createEmptyInstance() => BackupWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static BackupWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BackupWalletResponse>(BackupWalletResponse.$_createMessage);
  static BackupWalletResponse? _defaultInstance;
}

class UnloadWalletRequest extends $pb.GeneratedMessage {
  factory UnloadWalletRequest({
    $core.String? walletName,
    $core.String? wallet,
  }) {
    final result = UnloadWalletRequest._();
    if (walletName != null) result.walletName = walletName;
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  UnloadWalletRequest._();

  factory UnloadWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnloadWalletRequest()..mergeFromBuffer(data, registry);
  factory UnloadWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnloadWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnloadWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: UnloadWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletName')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnloadWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnloadWalletRequest copyWith(void Function(UnloadWalletRequest) updates) =>
      super.copyWith((message) => updates(message as UnloadWalletRequest)) as UnloadWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UnloadWalletRequest() / UnloadWalletRequest.new instead')
  static UnloadWalletRequest create() => UnloadWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => UnloadWalletRequest._();
  @$core.override
  UnloadWalletRequest createEmptyInstance() => UnloadWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static UnloadWalletRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnloadWalletRequest>(UnloadWalletRequest.$_createMessage);
  static UnloadWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletName => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletName() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => $_clearField(2);
}

class UnloadWalletResponse extends $pb.GeneratedMessage {
  factory UnloadWalletResponse() => UnloadWalletResponse._();

  UnloadWalletResponse._();

  factory UnloadWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnloadWalletResponse()..mergeFromBuffer(data, registry);
  factory UnloadWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnloadWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnloadWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: UnloadWalletResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnloadWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnloadWalletResponse copyWith(void Function(UnloadWalletResponse) updates) =>
      super.copyWith((message) => updates(message as UnloadWalletResponse)) as UnloadWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UnloadWalletResponse() / UnloadWalletResponse.new instead')
  static UnloadWalletResponse create() => UnloadWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => UnloadWalletResponse._();
  @$core.override
  UnloadWalletResponse createEmptyInstance() => UnloadWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static UnloadWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnloadWalletResponse>(UnloadWalletResponse.$_createMessage);
  static UnloadWalletResponse? _defaultInstance;
}

class RescanBlockchainRequest extends $pb.GeneratedMessage {
  factory RescanBlockchainRequest({
    $core.String? wallet,
    $core.int? startHeight,
    $core.int? endHeight,
  }) {
    final result = RescanBlockchainRequest._();
    if (wallet != null) result.wallet = wallet;
    if (startHeight != null) result.startHeight = startHeight;
    if (endHeight != null) result.endHeight = endHeight;
    return result;
  }

  RescanBlockchainRequest._();

  factory RescanBlockchainRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RescanBlockchainRequest()..mergeFromBuffer(data, registry);
  factory RescanBlockchainRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RescanBlockchainRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RescanBlockchainRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: RescanBlockchainRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..aI(2, _omitFieldNames ? '' : 'startHeight', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'endHeight', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RescanBlockchainRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RescanBlockchainRequest copyWith(void Function(RescanBlockchainRequest) updates) =>
      super.copyWith((message) => updates(message as RescanBlockchainRequest)) as RescanBlockchainRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RescanBlockchainRequest() / RescanBlockchainRequest.new instead')
  static RescanBlockchainRequest create() => RescanBlockchainRequest._();
  static $pb.GeneratedMessage $_createMessage() => RescanBlockchainRequest._();
  @$core.override
  RescanBlockchainRequest createEmptyInstance() => RescanBlockchainRequest._();
  @$core.pragma('dart2js:noInline')
  static RescanBlockchainRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RescanBlockchainRequest>(RescanBlockchainRequest.$_createMessage);
  static RescanBlockchainRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get startHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set startHeight($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartHeight() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get endHeight => $_getIZ(2);
  @$pb.TagNumber(3)
  set endHeight($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEndHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndHeight() => $_clearField(3);
}

class RescanBlockchainResponse extends $pb.GeneratedMessage {
  factory RescanBlockchainResponse({
    $core.int? startHeight,
    $core.int? stopHeight,
  }) {
    final result = RescanBlockchainResponse._();
    if (startHeight != null) result.startHeight = startHeight;
    if (stopHeight != null) result.stopHeight = stopHeight;
    return result;
  }

  RescanBlockchainResponse._();

  factory RescanBlockchainResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RescanBlockchainResponse()..mergeFromBuffer(data, registry);
  factory RescanBlockchainResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RescanBlockchainResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RescanBlockchainResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: RescanBlockchainResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'startHeight', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'stopHeight', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RescanBlockchainResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RescanBlockchainResponse copyWith(void Function(RescanBlockchainResponse) updates) =>
      super.copyWith((message) => updates(message as RescanBlockchainResponse)) as RescanBlockchainResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RescanBlockchainResponse() / RescanBlockchainResponse.new instead')
  static RescanBlockchainResponse create() => RescanBlockchainResponse._();
  static $pb.GeneratedMessage $_createMessage() => RescanBlockchainResponse._();
  @$core.override
  RescanBlockchainResponse createEmptyInstance() => RescanBlockchainResponse._();
  @$core.pragma('dart2js:noInline')
  static RescanBlockchainResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RescanBlockchainResponse>(RescanBlockchainResponse.$_createMessage);
  static RescanBlockchainResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get startHeight => $_getIZ(0);
  @$pb.TagNumber(1)
  set startHeight($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStartHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartHeight() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get stopHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set stopHeight($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStopHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearStopHeight() => $_clearField(2);
}

class AbortRescanRequest extends $pb.GeneratedMessage {
  factory AbortRescanRequest({
    $core.String? wallet,
  }) {
    final result = AbortRescanRequest._();
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  AbortRescanRequest._();

  factory AbortRescanRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AbortRescanRequest()..mergeFromBuffer(data, registry);
  factory AbortRescanRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AbortRescanRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AbortRescanRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: AbortRescanRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbortRescanRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbortRescanRequest copyWith(void Function(AbortRescanRequest) updates) =>
      super.copyWith((message) => updates(message as AbortRescanRequest)) as AbortRescanRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AbortRescanRequest() / AbortRescanRequest.new instead')
  static AbortRescanRequest create() => AbortRescanRequest._();
  static $pb.GeneratedMessage $_createMessage() => AbortRescanRequest._();
  @$core.override
  AbortRescanRequest createEmptyInstance() => AbortRescanRequest._();
  @$core.pragma('dart2js:noInline')
  static AbortRescanRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AbortRescanRequest>(AbortRescanRequest.$_createMessage);
  static AbortRescanRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wallet => $_getSZ(0);
  @$pb.TagNumber(1)
  set wallet($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => $_clearField(1);
}

class AbortRescanResponse extends $pb.GeneratedMessage {
  factory AbortRescanResponse({
    $core.bool? aborted,
  }) {
    final result = AbortRescanResponse._();
    if (aborted != null) result.aborted = aborted;
    return result;
  }

  AbortRescanResponse._();

  factory AbortRescanResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AbortRescanResponse()..mergeFromBuffer(data, registry);
  factory AbortRescanResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AbortRescanResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AbortRescanResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: AbortRescanResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'aborted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbortRescanResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbortRescanResponse copyWith(void Function(AbortRescanResponse) updates) =>
      super.copyWith((message) => updates(message as AbortRescanResponse)) as AbortRescanResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AbortRescanResponse() / AbortRescanResponse.new instead')
  static AbortRescanResponse create() => AbortRescanResponse._();
  static $pb.GeneratedMessage $_createMessage() => AbortRescanResponse._();
  @$core.override
  AbortRescanResponse createEmptyInstance() => AbortRescanResponse._();
  @$core.pragma('dart2js:noInline')
  static AbortRescanResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AbortRescanResponse>(AbortRescanResponse.$_createMessage);
  static AbortRescanResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get aborted => $_getBF(0);
  @$pb.TagNumber(1)
  set aborted($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAborted() => $_has(0);
  @$pb.TagNumber(1)
  void clearAborted() => $_clearField(1);
}

class KeyPoolRefillRequest extends $pb.GeneratedMessage {
  factory KeyPoolRefillRequest({
    $core.int? newSize,
    $core.String? wallet,
  }) {
    final result = KeyPoolRefillRequest._();
    if (newSize != null) result.newSize = newSize;
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  KeyPoolRefillRequest._();

  factory KeyPoolRefillRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyPoolRefillRequest()..mergeFromBuffer(data, registry);
  factory KeyPoolRefillRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyPoolRefillRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KeyPoolRefillRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: KeyPoolRefillRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'newSize', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyPoolRefillRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyPoolRefillRequest copyWith(void Function(KeyPoolRefillRequest) updates) =>
      super.copyWith((message) => updates(message as KeyPoolRefillRequest)) as KeyPoolRefillRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use KeyPoolRefillRequest() / KeyPoolRefillRequest.new instead')
  static KeyPoolRefillRequest create() => KeyPoolRefillRequest._();
  static $pb.GeneratedMessage $_createMessage() => KeyPoolRefillRequest._();
  @$core.override
  KeyPoolRefillRequest createEmptyInstance() => KeyPoolRefillRequest._();
  @$core.pragma('dart2js:noInline')
  static KeyPoolRefillRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KeyPoolRefillRequest>(KeyPoolRefillRequest.$_createMessage);
  static KeyPoolRefillRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get newSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set newSize($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNewSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearNewSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => $_clearField(2);
}

class KeyPoolRefillResponse extends $pb.GeneratedMessage {
  factory KeyPoolRefillResponse() => KeyPoolRefillResponse._();

  KeyPoolRefillResponse._();

  factory KeyPoolRefillResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyPoolRefillResponse()..mergeFromBuffer(data, registry);
  factory KeyPoolRefillResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyPoolRefillResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KeyPoolRefillResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: KeyPoolRefillResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyPoolRefillResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyPoolRefillResponse copyWith(void Function(KeyPoolRefillResponse) updates) =>
      super.copyWith((message) => updates(message as KeyPoolRefillResponse)) as KeyPoolRefillResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use KeyPoolRefillResponse() / KeyPoolRefillResponse.new instead')
  static KeyPoolRefillResponse create() => KeyPoolRefillResponse._();
  static $pb.GeneratedMessage $_createMessage() => KeyPoolRefillResponse._();
  @$core.override
  KeyPoolRefillResponse createEmptyInstance() => KeyPoolRefillResponse._();
  @$core.pragma('dart2js:noInline')
  static KeyPoolRefillResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KeyPoolRefillResponse>(KeyPoolRefillResponse.$_createMessage);
  static KeyPoolRefillResponse? _defaultInstance;
}

class GetAccountRequest extends $pb.GeneratedMessage {
  factory GetAccountRequest({
    $core.String? address,
    $core.String? wallet,
  }) {
    final result = GetAccountRequest._();
    if (address != null) result.address = address;
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  GetAccountRequest._();

  factory GetAccountRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAccountRequest()..mergeFromBuffer(data, registry);
  factory GetAccountRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAccountRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAccountRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetAccountRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAccountRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAccountRequest copyWith(void Function(GetAccountRequest) updates) =>
      super.copyWith((message) => updates(message as GetAccountRequest)) as GetAccountRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetAccountRequest() / GetAccountRequest.new instead')
  static GetAccountRequest create() => GetAccountRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetAccountRequest._();
  @$core.override
  GetAccountRequest createEmptyInstance() => GetAccountRequest._();
  @$core.pragma('dart2js:noInline')
  static GetAccountRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAccountRequest>(GetAccountRequest.$_createMessage);
  static GetAccountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => $_clearField(2);
}

class GetAccountResponse extends $pb.GeneratedMessage {
  factory GetAccountResponse({
    $core.String? account,
  }) {
    final result = GetAccountResponse._();
    if (account != null) result.account = account;
    return result;
  }

  GetAccountResponse._();

  factory GetAccountResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAccountResponse()..mergeFromBuffer(data, registry);
  factory GetAccountResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAccountResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAccountResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetAccountResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'account')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAccountResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAccountResponse copyWith(void Function(GetAccountResponse) updates) =>
      super.copyWith((message) => updates(message as GetAccountResponse)) as GetAccountResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetAccountResponse() / GetAccountResponse.new instead')
  static GetAccountResponse create() => GetAccountResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetAccountResponse._();
  @$core.override
  GetAccountResponse createEmptyInstance() => GetAccountResponse._();
  @$core.pragma('dart2js:noInline')
  static GetAccountResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAccountResponse>(GetAccountResponse.$_createMessage);
  static GetAccountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get account => $_getSZ(0);
  @$pb.TagNumber(1)
  set account($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccount() => $_clearField(1);
}

class SetAccountRequest extends $pb.GeneratedMessage {
  factory SetAccountRequest({
    $core.String? address,
    $core.String? account,
    $core.String? wallet,
  }) {
    final result = SetAccountRequest._();
    if (address != null) result.address = address;
    if (account != null) result.account = account;
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  SetAccountRequest._();

  factory SetAccountRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetAccountRequest()..mergeFromBuffer(data, registry);
  factory SetAccountRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetAccountRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetAccountRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: SetAccountRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'account')
    ..aOS(3, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAccountRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAccountRequest copyWith(void Function(SetAccountRequest) updates) =>
      super.copyWith((message) => updates(message as SetAccountRequest)) as SetAccountRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetAccountRequest() / SetAccountRequest.new instead')
  static SetAccountRequest create() => SetAccountRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetAccountRequest._();
  @$core.override
  SetAccountRequest createEmptyInstance() => SetAccountRequest._();
  @$core.pragma('dart2js:noInline')
  static SetAccountRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetAccountRequest>(SetAccountRequest.$_createMessage);
  static SetAccountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get account => $_getSZ(1);
  @$pb.TagNumber(2)
  set account($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAccount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get wallet => $_getSZ(2);
  @$pb.TagNumber(3)
  set wallet($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWallet() => $_has(2);
  @$pb.TagNumber(3)
  void clearWallet() => $_clearField(3);
}

class SetAccountResponse extends $pb.GeneratedMessage {
  factory SetAccountResponse() => SetAccountResponse._();

  SetAccountResponse._();

  factory SetAccountResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetAccountResponse()..mergeFromBuffer(data, registry);
  factory SetAccountResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetAccountResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetAccountResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: SetAccountResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAccountResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAccountResponse copyWith(void Function(SetAccountResponse) updates) =>
      super.copyWith((message) => updates(message as SetAccountResponse)) as SetAccountResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetAccountResponse() / SetAccountResponse.new instead')
  static SetAccountResponse create() => SetAccountResponse._();
  static $pb.GeneratedMessage $_createMessage() => SetAccountResponse._();
  @$core.override
  SetAccountResponse createEmptyInstance() => SetAccountResponse._();
  @$core.pragma('dart2js:noInline')
  static SetAccountResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetAccountResponse>(SetAccountResponse.$_createMessage);
  static SetAccountResponse? _defaultInstance;
}

class GetAddressesByAccountRequest extends $pb.GeneratedMessage {
  factory GetAddressesByAccountRequest({
    $core.String? account,
    $core.String? wallet,
  }) {
    final result = GetAddressesByAccountRequest._();
    if (account != null) result.account = account;
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  GetAddressesByAccountRequest._();

  factory GetAddressesByAccountRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressesByAccountRequest()..mergeFromBuffer(data, registry);
  factory GetAddressesByAccountRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressesByAccountRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressesByAccountRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetAddressesByAccountRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'account')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressesByAccountRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressesByAccountRequest copyWith(void Function(GetAddressesByAccountRequest) updates) =>
      super.copyWith((message) => updates(message as GetAddressesByAccountRequest)) as GetAddressesByAccountRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetAddressesByAccountRequest() / GetAddressesByAccountRequest.new instead')
  static GetAddressesByAccountRequest create() => GetAddressesByAccountRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetAddressesByAccountRequest._();
  @$core.override
  GetAddressesByAccountRequest createEmptyInstance() => GetAddressesByAccountRequest._();
  @$core.pragma('dart2js:noInline')
  static GetAddressesByAccountRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAddressesByAccountRequest>(GetAddressesByAccountRequest.$_createMessage);
  static GetAddressesByAccountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get account => $_getSZ(0);
  @$pb.TagNumber(1)
  set account($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccount() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => $_clearField(2);
}

class GetAddressesByAccountResponse extends $pb.GeneratedMessage {
  factory GetAddressesByAccountResponse({
    $core.Iterable<$core.String>? addresses,
  }) {
    final result = GetAddressesByAccountResponse._();
    if (addresses != null) result.addresses.addAll(addresses);
    return result;
  }

  GetAddressesByAccountResponse._();

  factory GetAddressesByAccountResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressesByAccountResponse()..mergeFromBuffer(data, registry);
  factory GetAddressesByAccountResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressesByAccountResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressesByAccountResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetAddressesByAccountResponse.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'addresses')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressesByAccountResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressesByAccountResponse copyWith(void Function(GetAddressesByAccountResponse) updates) =>
      super.copyWith((message) => updates(message as GetAddressesByAccountResponse)) as GetAddressesByAccountResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetAddressesByAccountResponse() / GetAddressesByAccountResponse.new instead')
  static GetAddressesByAccountResponse create() => GetAddressesByAccountResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetAddressesByAccountResponse._();
  @$core.override
  GetAddressesByAccountResponse createEmptyInstance() => GetAddressesByAccountResponse._();
  @$core.pragma('dart2js:noInline')
  static GetAddressesByAccountResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAddressesByAccountResponse>(GetAddressesByAccountResponse.$_createMessage);
  static GetAddressesByAccountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get addresses => $_getList(0);
}

class ListAccountsRequest extends $pb.GeneratedMessage {
  factory ListAccountsRequest({
    $core.int? minConf,
    $core.String? wallet,
  }) {
    final result = ListAccountsRequest._();
    if (minConf != null) result.minConf = minConf;
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  ListAccountsRequest._();

  factory ListAccountsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListAccountsRequest()..mergeFromBuffer(data, registry);
  factory ListAccountsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListAccountsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListAccountsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ListAccountsRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'minConf')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAccountsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAccountsRequest copyWith(void Function(ListAccountsRequest) updates) =>
      super.copyWith((message) => updates(message as ListAccountsRequest)) as ListAccountsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListAccountsRequest() / ListAccountsRequest.new instead')
  static ListAccountsRequest create() => ListAccountsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListAccountsRequest._();
  @$core.override
  ListAccountsRequest createEmptyInstance() => ListAccountsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListAccountsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListAccountsRequest>(ListAccountsRequest.$_createMessage);
  static ListAccountsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get minConf => $_getIZ(0);
  @$pb.TagNumber(1)
  set minConf($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMinConf() => $_has(0);
  @$pb.TagNumber(1)
  void clearMinConf() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => $_clearField(2);
}

class ListAccountsResponse extends $pb.GeneratedMessage {
  factory ListAccountsResponse({
    $core.Iterable<$core.MapEntry<$core.String, $core.double>>? accounts,
  }) {
    final result = ListAccountsResponse._();
    if (accounts != null) result.accounts.addEntries(accounts);
    return result;
  }

  ListAccountsResponse._();

  factory ListAccountsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListAccountsResponse()..mergeFromBuffer(data, registry);
  factory ListAccountsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListAccountsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListAccountsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: ListAccountsResponse.$_createMessage)
    ..m<$core.String, $core.double>(1, _omitFieldNames ? '' : 'accounts',
        entryClassName: 'ListAccountsResponse.AccountsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OD,
        packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAccountsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAccountsResponse copyWith(void Function(ListAccountsResponse) updates) =>
      super.copyWith((message) => updates(message as ListAccountsResponse)) as ListAccountsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListAccountsResponse() / ListAccountsResponse.new instead')
  static ListAccountsResponse create() => ListAccountsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListAccountsResponse._();
  @$core.override
  ListAccountsResponse createEmptyInstance() => ListAccountsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListAccountsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAccountsResponse>(ListAccountsResponse.$_createMessage);
  static ListAccountsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $core.double> get accounts => $_getMap(0);
}

class CreateMultisigRequest extends $pb.GeneratedMessage {
  factory CreateMultisigRequest({
    $core.int? requiredSigs,
    $core.Iterable<$core.String>? keys,
  }) {
    final result = CreateMultisigRequest._();
    if (requiredSigs != null) result.requiredSigs = requiredSigs;
    if (keys != null) result.keys.addAll(keys);
    return result;
  }

  CreateMultisigRequest._();

  factory CreateMultisigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateMultisigRequest()..mergeFromBuffer(data, registry);
  factory CreateMultisigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateMultisigRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateMultisigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: CreateMultisigRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'requiredSigs')
    ..pPS(2, _omitFieldNames ? '' : 'keys')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMultisigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMultisigRequest copyWith(void Function(CreateMultisigRequest) updates) =>
      super.copyWith((message) => updates(message as CreateMultisigRequest)) as CreateMultisigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateMultisigRequest() / CreateMultisigRequest.new instead')
  static CreateMultisigRequest create() => CreateMultisigRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateMultisigRequest._();
  @$core.override
  CreateMultisigRequest createEmptyInstance() => CreateMultisigRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateMultisigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateMultisigRequest>(CreateMultisigRequest.$_createMessage);
  static CreateMultisigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get requiredSigs => $_getIZ(0);
  @$pb.TagNumber(1)
  set requiredSigs($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequiredSigs() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequiredSigs() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get keys => $_getList(1);
}

class CreateMultisigResponse extends $pb.GeneratedMessage {
  factory CreateMultisigResponse({
    $core.String? address,
    $core.String? redeemScript,
  }) {
    final result = CreateMultisigResponse._();
    if (address != null) result.address = address;
    if (redeemScript != null) result.redeemScript = redeemScript;
    return result;
  }

  CreateMultisigResponse._();

  factory CreateMultisigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateMultisigResponse()..mergeFromBuffer(data, registry);
  factory CreateMultisigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateMultisigResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateMultisigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: CreateMultisigResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'redeemScript')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMultisigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMultisigResponse copyWith(void Function(CreateMultisigResponse) updates) =>
      super.copyWith((message) => updates(message as CreateMultisigResponse)) as CreateMultisigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateMultisigResponse() / CreateMultisigResponse.new instead')
  static CreateMultisigResponse create() => CreateMultisigResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateMultisigResponse._();
  @$core.override
  CreateMultisigResponse createEmptyInstance() => CreateMultisigResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateMultisigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateMultisigResponse>(CreateMultisigResponse.$_createMessage);
  static CreateMultisigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get redeemScript => $_getSZ(1);
  @$pb.TagNumber(2)
  set redeemScript($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRedeemScript() => $_has(1);
  @$pb.TagNumber(2)
  void clearRedeemScript() => $_clearField(2);
}

class CreateRawTransactionRequest_Input extends $pb.GeneratedMessage {
  factory CreateRawTransactionRequest_Input({
    $core.String? txid,
    $core.int? vout,
    $core.int? sequence,
  }) {
    final result = CreateRawTransactionRequest_Input._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (sequence != null) result.sequence = sequence;
    return result;
  }

  CreateRawTransactionRequest_Input._();

  factory CreateRawTransactionRequest_Input.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateRawTransactionRequest_Input()..mergeFromBuffer(data, registry);
  factory CreateRawTransactionRequest_Input.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateRawTransactionRequest_Input()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateRawTransactionRequest.Input',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: CreateRawTransactionRequest_Input.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'vout', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'sequence', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRawTransactionRequest_Input clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRawTransactionRequest_Input copyWith(void Function(CreateRawTransactionRequest_Input) updates) =>
      super.copyWith((message) => updates(message as CreateRawTransactionRequest_Input))
          as CreateRawTransactionRequest_Input;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateRawTransactionRequest_Input() / CreateRawTransactionRequest_Input.new instead')
  static CreateRawTransactionRequest_Input create() => CreateRawTransactionRequest_Input._();
  static $pb.GeneratedMessage $_createMessage() => CreateRawTransactionRequest_Input._();
  @$core.override
  CreateRawTransactionRequest_Input createEmptyInstance() => CreateRawTransactionRequest_Input._();
  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionRequest_Input getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateRawTransactionRequest_Input>(
          CreateRawTransactionRequest_Input.$_createMessage);
  static CreateRawTransactionRequest_Input? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get sequence => $_getIZ(2);
  @$pb.TagNumber(3)
  set sequence($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSequence() => $_has(2);
  @$pb.TagNumber(3)
  void clearSequence() => $_clearField(3);
}

/// Transaction creation messages
class CreateRawTransactionRequest extends $pb.GeneratedMessage {
  factory CreateRawTransactionRequest({
    $core.Iterable<CreateRawTransactionRequest_Input>? inputs,
    $core.Iterable<$core.MapEntry<$core.String, $core.double>>? outputs,
    $core.int? locktime,
  }) {
    final result = CreateRawTransactionRequest._();
    if (inputs != null) result.inputs.addAll(inputs);
    if (outputs != null) result.outputs.addEntries(outputs);
    if (locktime != null) result.locktime = locktime;
    return result;
  }

  CreateRawTransactionRequest._();

  factory CreateRawTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateRawTransactionRequest()..mergeFromBuffer(data, registry);
  factory CreateRawTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateRawTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateRawTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: CreateRawTransactionRequest.$_createMessage)
    ..pPM<CreateRawTransactionRequest_Input>(1, _omitFieldNames ? '' : 'inputs',
        subBuilder: CreateRawTransactionRequest_Input.$_createMessage)
    ..m<$core.String, $core.double>(2, _omitFieldNames ? '' : 'outputs',
        entryClassName: 'CreateRawTransactionRequest.OutputsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OD,
        packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..aI(3, _omitFieldNames ? '' : 'locktime', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRawTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRawTransactionRequest copyWith(void Function(CreateRawTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as CreateRawTransactionRequest)) as CreateRawTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateRawTransactionRequest() / CreateRawTransactionRequest.new instead')
  static CreateRawTransactionRequest create() => CreateRawTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateRawTransactionRequest._();
  @$core.override
  CreateRawTransactionRequest createEmptyInstance() => CreateRawTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateRawTransactionRequest>(CreateRawTransactionRequest.$_createMessage);
  static CreateRawTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CreateRawTransactionRequest_Input> get inputs => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $core.double> get outputs => $_getMap(1);

  @$pb.TagNumber(3)
  $core.int get locktime => $_getIZ(2);
  @$pb.TagNumber(3)
  set locktime($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLocktime() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocktime() => $_clearField(3);
}

class CreateRawTransactionResponse extends $pb.GeneratedMessage {
  factory CreateRawTransactionResponse({
    RawTransaction? tx,
  }) {
    final result = CreateRawTransactionResponse._();
    if (tx != null) result.tx = tx;
    return result;
  }

  CreateRawTransactionResponse._();

  factory CreateRawTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateRawTransactionResponse()..mergeFromBuffer(data, registry);
  factory CreateRawTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateRawTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateRawTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: CreateRawTransactionResponse.$_createMessage)
    ..aOM<RawTransaction>(1, _omitFieldNames ? '' : 'tx', subBuilder: RawTransaction.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRawTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRawTransactionResponse copyWith(void Function(CreateRawTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as CreateRawTransactionResponse)) as CreateRawTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateRawTransactionResponse() / CreateRawTransactionResponse.new instead')
  static CreateRawTransactionResponse create() => CreateRawTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateRawTransactionResponse._();
  @$core.override
  CreateRawTransactionResponse createEmptyInstance() => CreateRawTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateRawTransactionResponse>(CreateRawTransactionResponse.$_createMessage);
  static CreateRawTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RawTransaction get tx => $_getN(0);
  @$pb.TagNumber(1)
  set tx(RawTransaction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTx() => $_has(0);
  @$pb.TagNumber(1)
  void clearTx() => $_clearField(1);
  @$pb.TagNumber(1)
  RawTransaction ensureTx() => $_ensure(0);
}

class SendRawTransactionRequest extends $pb.GeneratedMessage {
  factory SendRawTransactionRequest({
    RawTransaction? tx,
    $core.double? maxFeeRate,
    $core.double? maxBurnAmount,
  }) {
    final result = SendRawTransactionRequest._();
    if (tx != null) result.tx = tx;
    if (maxFeeRate != null) result.maxFeeRate = maxFeeRate;
    if (maxBurnAmount != null) result.maxBurnAmount = maxBurnAmount;
    return result;
  }

  SendRawTransactionRequest._();

  factory SendRawTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendRawTransactionRequest()..mergeFromBuffer(data, registry);
  factory SendRawTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendRawTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendRawTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: SendRawTransactionRequest.$_createMessage)
    ..aOM<RawTransaction>(1, _omitFieldNames ? '' : 'tx', subBuilder: RawTransaction.$_createMessage)
    ..aD(2, _omitFieldNames ? '' : 'maxFeeRate')
    ..aD(3, _omitFieldNames ? '' : 'maxBurnAmount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendRawTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendRawTransactionRequest copyWith(void Function(SendRawTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as SendRawTransactionRequest)) as SendRawTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendRawTransactionRequest() / SendRawTransactionRequest.new instead')
  static SendRawTransactionRequest create() => SendRawTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => SendRawTransactionRequest._();
  @$core.override
  SendRawTransactionRequest createEmptyInstance() => SendRawTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static SendRawTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendRawTransactionRequest>(SendRawTransactionRequest.$_createMessage);
  static SendRawTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  RawTransaction get tx => $_getN(0);
  @$pb.TagNumber(1)
  set tx(RawTransaction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTx() => $_has(0);
  @$pb.TagNumber(1)
  void clearTx() => $_clearField(1);
  @$pb.TagNumber(1)
  RawTransaction ensureTx() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.double get maxFeeRate => $_getN(1);
  @$pb.TagNumber(2)
  set maxFeeRate($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxFeeRate() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxFeeRate() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get maxBurnAmount => $_getN(2);
  @$pb.TagNumber(3)
  set maxBurnAmount($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxBurnAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxBurnAmount() => $_clearField(3);
}

class SendRawTransactionResponse extends $pb.GeneratedMessage {
  factory SendRawTransactionResponse({
    $core.String? txid,
  }) {
    final result = SendRawTransactionResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  SendRawTransactionResponse._();

  factory SendRawTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendRawTransactionResponse()..mergeFromBuffer(data, registry);
  factory SendRawTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendRawTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendRawTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: SendRawTransactionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendRawTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendRawTransactionResponse copyWith(void Function(SendRawTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as SendRawTransactionResponse)) as SendRawTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendRawTransactionResponse() / SendRawTransactionResponse.new instead')
  static SendRawTransactionResponse create() => SendRawTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => SendRawTransactionResponse._();
  @$core.override
  SendRawTransactionResponse createEmptyInstance() => SendRawTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static SendRawTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendRawTransactionResponse>(SendRawTransactionResponse.$_createMessage);
  static SendRawTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class CreatePsbtRequest_Input extends $pb.GeneratedMessage {
  factory CreatePsbtRequest_Input({
    $core.String? txid,
    $core.int? vout,
    $core.int? sequence,
  }) {
    final result = CreatePsbtRequest_Input._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (sequence != null) result.sequence = sequence;
    return result;
  }

  CreatePsbtRequest_Input._();

  factory CreatePsbtRequest_Input.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePsbtRequest_Input()..mergeFromBuffer(data, registry);
  factory CreatePsbtRequest_Input.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePsbtRequest_Input()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePsbtRequest.Input',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: CreatePsbtRequest_Input.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'vout', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'sequence', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePsbtRequest_Input clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePsbtRequest_Input copyWith(void Function(CreatePsbtRequest_Input) updates) =>
      super.copyWith((message) => updates(message as CreatePsbtRequest_Input)) as CreatePsbtRequest_Input;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreatePsbtRequest_Input() / CreatePsbtRequest_Input.new instead')
  static CreatePsbtRequest_Input create() => CreatePsbtRequest_Input._();
  static $pb.GeneratedMessage $_createMessage() => CreatePsbtRequest_Input._();
  @$core.override
  CreatePsbtRequest_Input createEmptyInstance() => CreatePsbtRequest_Input._();
  @$core.pragma('dart2js:noInline')
  static CreatePsbtRequest_Input getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreatePsbtRequest_Input>(CreatePsbtRequest_Input.$_createMessage);
  static CreatePsbtRequest_Input? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get sequence => $_getIZ(2);
  @$pb.TagNumber(3)
  set sequence($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSequence() => $_has(2);
  @$pb.TagNumber(3)
  void clearSequence() => $_clearField(3);
}

class CreatePsbtRequest extends $pb.GeneratedMessage {
  factory CreatePsbtRequest({
    $core.Iterable<CreatePsbtRequest_Input>? inputs,
    $core.Iterable<$core.MapEntry<$core.String, $core.double>>? outputs,
    $core.int? locktime,
    $core.bool? replaceable,
  }) {
    final result = CreatePsbtRequest._();
    if (inputs != null) result.inputs.addAll(inputs);
    if (outputs != null) result.outputs.addEntries(outputs);
    if (locktime != null) result.locktime = locktime;
    if (replaceable != null) result.replaceable = replaceable;
    return result;
  }

  CreatePsbtRequest._();

  factory CreatePsbtRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePsbtRequest()..mergeFromBuffer(data, registry);
  factory CreatePsbtRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePsbtRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePsbtRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: CreatePsbtRequest.$_createMessage)
    ..pPM<CreatePsbtRequest_Input>(1, _omitFieldNames ? '' : 'inputs',
        subBuilder: CreatePsbtRequest_Input.$_createMessage)
    ..m<$core.String, $core.double>(2, _omitFieldNames ? '' : 'outputs',
        entryClassName: 'CreatePsbtRequest.OutputsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OD,
        packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..aI(3, _omitFieldNames ? '' : 'locktime', fieldType: $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'replaceable')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePsbtRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePsbtRequest copyWith(void Function(CreatePsbtRequest) updates) =>
      super.copyWith((message) => updates(message as CreatePsbtRequest)) as CreatePsbtRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreatePsbtRequest() / CreatePsbtRequest.new instead')
  static CreatePsbtRequest create() => CreatePsbtRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreatePsbtRequest._();
  @$core.override
  CreatePsbtRequest createEmptyInstance() => CreatePsbtRequest._();
  @$core.pragma('dart2js:noInline')
  static CreatePsbtRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePsbtRequest>(CreatePsbtRequest.$_createMessage);
  static CreatePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CreatePsbtRequest_Input> get inputs => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $core.double> get outputs => $_getMap(1);

  @$pb.TagNumber(3)
  $core.int get locktime => $_getIZ(2);
  @$pb.TagNumber(3)
  set locktime($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLocktime() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocktime() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get replaceable => $_getBF(3);
  @$pb.TagNumber(4)
  set replaceable($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReplaceable() => $_has(3);
  @$pb.TagNumber(4)
  void clearReplaceable() => $_clearField(4);
}

class CreatePsbtResponse extends $pb.GeneratedMessage {
  factory CreatePsbtResponse({
    $core.String? psbt,
  }) {
    final result = CreatePsbtResponse._();
    if (psbt != null) result.psbt = psbt;
    return result;
  }

  CreatePsbtResponse._();

  factory CreatePsbtResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePsbtResponse()..mergeFromBuffer(data, registry);
  factory CreatePsbtResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePsbtResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePsbtResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: CreatePsbtResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePsbtResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePsbtResponse copyWith(void Function(CreatePsbtResponse) updates) =>
      super.copyWith((message) => updates(message as CreatePsbtResponse)) as CreatePsbtResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreatePsbtResponse() / CreatePsbtResponse.new instead')
  static CreatePsbtResponse create() => CreatePsbtResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreatePsbtResponse._();
  @$core.override
  CreatePsbtResponse createEmptyInstance() => CreatePsbtResponse._();
  @$core.pragma('dart2js:noInline')
  static CreatePsbtResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePsbtResponse>(CreatePsbtResponse.$_createMessage);
  static CreatePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => $_clearField(1);
}

class DecodePsbtRequest extends $pb.GeneratedMessage {
  factory DecodePsbtRequest({
    $core.String? psbt,
  }) {
    final result = DecodePsbtRequest._();
    if (psbt != null) result.psbt = psbt;
    return result;
  }

  DecodePsbtRequest._();

  factory DecodePsbtRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodePsbtRequest()..mergeFromBuffer(data, registry);
  factory DecodePsbtRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodePsbtRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: DecodePsbtRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodePsbtRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodePsbtRequest copyWith(void Function(DecodePsbtRequest) updates) =>
      super.copyWith((message) => updates(message as DecodePsbtRequest)) as DecodePsbtRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DecodePsbtRequest() / DecodePsbtRequest.new instead')
  static DecodePsbtRequest create() => DecodePsbtRequest._();
  static $pb.GeneratedMessage $_createMessage() => DecodePsbtRequest._();
  @$core.override
  DecodePsbtRequest createEmptyInstance() => DecodePsbtRequest._();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtRequest>(DecodePsbtRequest.$_createMessage);
  static DecodePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => $_clearField(1);
}

class DecodePsbtResponse_WitnessUtxo extends $pb.GeneratedMessage {
  factory DecodePsbtResponse_WitnessUtxo({
    $core.double? amount,
    ScriptPubKey? scriptPubKey,
  }) {
    final result = DecodePsbtResponse_WitnessUtxo._();
    if (amount != null) result.amount = amount;
    if (scriptPubKey != null) result.scriptPubKey = scriptPubKey;
    return result;
  }

  DecodePsbtResponse_WitnessUtxo._();

  factory DecodePsbtResponse_WitnessUtxo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodePsbtResponse_WitnessUtxo()..mergeFromBuffer(data, registry);
  factory DecodePsbtResponse_WitnessUtxo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodePsbtResponse_WitnessUtxo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse.WitnessUtxo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: DecodePsbtResponse_WitnessUtxo.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'amount')
    ..aOM<ScriptPubKey>(2, _omitFieldNames ? '' : 'scriptPubKey', subBuilder: ScriptPubKey.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodePsbtResponse_WitnessUtxo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodePsbtResponse_WitnessUtxo copyWith(void Function(DecodePsbtResponse_WitnessUtxo) updates) =>
      super.copyWith((message) => updates(message as DecodePsbtResponse_WitnessUtxo)) as DecodePsbtResponse_WitnessUtxo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DecodePsbtResponse_WitnessUtxo() / DecodePsbtResponse_WitnessUtxo.new instead')
  static DecodePsbtResponse_WitnessUtxo create() => DecodePsbtResponse_WitnessUtxo._();
  static $pb.GeneratedMessage $_createMessage() => DecodePsbtResponse_WitnessUtxo._();
  @$core.override
  DecodePsbtResponse_WitnessUtxo createEmptyInstance() => DecodePsbtResponse_WitnessUtxo._();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_WitnessUtxo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse_WitnessUtxo>(DecodePsbtResponse_WitnessUtxo.$_createMessage);
  static DecodePsbtResponse_WitnessUtxo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get amount => $_getN(0);
  @$pb.TagNumber(1)
  set amount($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAmount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAmount() => $_clearField(1);

  @$pb.TagNumber(2)
  ScriptPubKey get scriptPubKey => $_getN(1);
  @$pb.TagNumber(2)
  set scriptPubKey(ScriptPubKey value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasScriptPubKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearScriptPubKey() => $_clearField(2);
  @$pb.TagNumber(2)
  ScriptPubKey ensureScriptPubKey() => $_ensure(1);
}

class DecodePsbtResponse_RedeemScript extends $pb.GeneratedMessage {
  factory DecodePsbtResponse_RedeemScript({
    $core.String? asm,
    $core.String? hex,
    $core.String? type,
  }) {
    final result = DecodePsbtResponse_RedeemScript._();
    if (asm != null) result.asm = asm;
    if (hex != null) result.hex = hex;
    if (type != null) result.type = type;
    return result;
  }

  DecodePsbtResponse_RedeemScript._();

  factory DecodePsbtResponse_RedeemScript.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodePsbtResponse_RedeemScript()..mergeFromBuffer(data, registry);
  factory DecodePsbtResponse_RedeemScript.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodePsbtResponse_RedeemScript()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse.RedeemScript',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: DecodePsbtResponse_RedeemScript.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'asm')
    ..aOS(2, _omitFieldNames ? '' : 'hex')
    ..aOS(3, _omitFieldNames ? '' : 'type')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodePsbtResponse_RedeemScript clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodePsbtResponse_RedeemScript copyWith(void Function(DecodePsbtResponse_RedeemScript) updates) =>
      super.copyWith((message) => updates(message as DecodePsbtResponse_RedeemScript))
          as DecodePsbtResponse_RedeemScript;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DecodePsbtResponse_RedeemScript() / DecodePsbtResponse_RedeemScript.new instead')
  static DecodePsbtResponse_RedeemScript create() => DecodePsbtResponse_RedeemScript._();
  static $pb.GeneratedMessage $_createMessage() => DecodePsbtResponse_RedeemScript._();
  @$core.override
  DecodePsbtResponse_RedeemScript createEmptyInstance() => DecodePsbtResponse_RedeemScript._();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_RedeemScript getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse_RedeemScript>(
          DecodePsbtResponse_RedeemScript.$_createMessage);
  static DecodePsbtResponse_RedeemScript? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get asm => $_getSZ(0);
  @$pb.TagNumber(1)
  set asm($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAsm() => $_has(0);
  @$pb.TagNumber(1)
  void clearAsm() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get hex => $_getSZ(1);
  @$pb.TagNumber(2)
  set hex($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearHex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);
}

class DecodePsbtResponse_Bip32Deriv extends $pb.GeneratedMessage {
  factory DecodePsbtResponse_Bip32Deriv({
    $core.String? pubkey,
    $core.String? masterFingerprint,
    $core.String? path,
  }) {
    final result = DecodePsbtResponse_Bip32Deriv._();
    if (pubkey != null) result.pubkey = pubkey;
    if (masterFingerprint != null) result.masterFingerprint = masterFingerprint;
    if (path != null) result.path = path;
    return result;
  }

  DecodePsbtResponse_Bip32Deriv._();

  factory DecodePsbtResponse_Bip32Deriv.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodePsbtResponse_Bip32Deriv()..mergeFromBuffer(data, registry);
  factory DecodePsbtResponse_Bip32Deriv.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodePsbtResponse_Bip32Deriv()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse.Bip32Deriv',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: DecodePsbtResponse_Bip32Deriv.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'pubkey')
    ..aOS(2, _omitFieldNames ? '' : 'masterFingerprint')
    ..aOS(3, _omitFieldNames ? '' : 'path')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodePsbtResponse_Bip32Deriv clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodePsbtResponse_Bip32Deriv copyWith(void Function(DecodePsbtResponse_Bip32Deriv) updates) =>
      super.copyWith((message) => updates(message as DecodePsbtResponse_Bip32Deriv)) as DecodePsbtResponse_Bip32Deriv;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DecodePsbtResponse_Bip32Deriv() / DecodePsbtResponse_Bip32Deriv.new instead')
  static DecodePsbtResponse_Bip32Deriv create() => DecodePsbtResponse_Bip32Deriv._();
  static $pb.GeneratedMessage $_createMessage() => DecodePsbtResponse_Bip32Deriv._();
  @$core.override
  DecodePsbtResponse_Bip32Deriv createEmptyInstance() => DecodePsbtResponse_Bip32Deriv._();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_Bip32Deriv getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse_Bip32Deriv>(DecodePsbtResponse_Bip32Deriv.$_createMessage);
  static DecodePsbtResponse_Bip32Deriv? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pubkey => $_getSZ(0);
  @$pb.TagNumber(1)
  set pubkey($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPubkey() => $_has(0);
  @$pb.TagNumber(1)
  void clearPubkey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get masterFingerprint => $_getSZ(1);
  @$pb.TagNumber(2)
  set masterFingerprint($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMasterFingerprint() => $_has(1);
  @$pb.TagNumber(2)
  void clearMasterFingerprint() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get path => $_getSZ(2);
  @$pb.TagNumber(3)
  set path($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearPath() => $_clearField(3);
}

class DecodePsbtResponse_Input extends $pb.GeneratedMessage {
  factory DecodePsbtResponse_Input({
    DecodeRawTransactionResponse? nonWitnessUtxo,
    DecodePsbtResponse_WitnessUtxo? witnessUtxo,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? partialSignatures,
    $core.String? sighash,
    DecodePsbtResponse_RedeemScript? redeemScript,
    DecodePsbtResponse_RedeemScript? witnessScript,
    $core.Iterable<DecodePsbtResponse_Bip32Deriv>? bip32Derivs,
    ScriptSig? finalScriptsig,
    $core.Iterable<$core.String>? finalScriptwitness,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? unknown,
  }) {
    final result = DecodePsbtResponse_Input._();
    if (nonWitnessUtxo != null) result.nonWitnessUtxo = nonWitnessUtxo;
    if (witnessUtxo != null) result.witnessUtxo = witnessUtxo;
    if (partialSignatures != null) result.partialSignatures.addEntries(partialSignatures);
    if (sighash != null) result.sighash = sighash;
    if (redeemScript != null) result.redeemScript = redeemScript;
    if (witnessScript != null) result.witnessScript = witnessScript;
    if (bip32Derivs != null) result.bip32Derivs.addAll(bip32Derivs);
    if (finalScriptsig != null) result.finalScriptsig = finalScriptsig;
    if (finalScriptwitness != null) result.finalScriptwitness.addAll(finalScriptwitness);
    if (unknown != null) result.unknown.addEntries(unknown);
    return result;
  }

  DecodePsbtResponse_Input._();

  factory DecodePsbtResponse_Input.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodePsbtResponse_Input()..mergeFromBuffer(data, registry);
  factory DecodePsbtResponse_Input.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodePsbtResponse_Input()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse.Input',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: DecodePsbtResponse_Input.$_createMessage)
    ..aOM<DecodeRawTransactionResponse>(1, _omitFieldNames ? '' : 'nonWitnessUtxo',
        subBuilder: DecodeRawTransactionResponse.$_createMessage)
    ..aOM<DecodePsbtResponse_WitnessUtxo>(2, _omitFieldNames ? '' : 'witnessUtxo',
        subBuilder: DecodePsbtResponse_WitnessUtxo.$_createMessage)
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'partialSignatures',
        entryClassName: 'DecodePsbtResponse.Input.PartialSignaturesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..aOS(4, _omitFieldNames ? '' : 'sighash')
    ..aOM<DecodePsbtResponse_RedeemScript>(5, _omitFieldNames ? '' : 'redeemScript',
        subBuilder: DecodePsbtResponse_RedeemScript.$_createMessage)
    ..aOM<DecodePsbtResponse_RedeemScript>(6, _omitFieldNames ? '' : 'witnessScript',
        subBuilder: DecodePsbtResponse_RedeemScript.$_createMessage)
    ..pPM<DecodePsbtResponse_Bip32Deriv>(7, _omitFieldNames ? '' : 'bip32Derivs',
        subBuilder: DecodePsbtResponse_Bip32Deriv.$_createMessage)
    ..aOM<ScriptSig>(8, _omitFieldNames ? '' : 'finalScriptsig', subBuilder: ScriptSig.$_createMessage)
    ..pPS(9, _omitFieldNames ? '' : 'finalScriptwitness')
    ..m<$core.String, $core.String>(10, _omitFieldNames ? '' : 'unknown',
        entryClassName: 'DecodePsbtResponse.Input.UnknownEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodePsbtResponse_Input clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodePsbtResponse_Input copyWith(void Function(DecodePsbtResponse_Input) updates) =>
      super.copyWith((message) => updates(message as DecodePsbtResponse_Input)) as DecodePsbtResponse_Input;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DecodePsbtResponse_Input() / DecodePsbtResponse_Input.new instead')
  static DecodePsbtResponse_Input create() => DecodePsbtResponse_Input._();
  static $pb.GeneratedMessage $_createMessage() => DecodePsbtResponse_Input._();
  @$core.override
  DecodePsbtResponse_Input createEmptyInstance() => DecodePsbtResponse_Input._();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_Input getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse_Input>(DecodePsbtResponse_Input.$_createMessage);
  static DecodePsbtResponse_Input? _defaultInstance;

  @$pb.TagNumber(1)
  DecodeRawTransactionResponse get nonWitnessUtxo => $_getN(0);
  @$pb.TagNumber(1)
  set nonWitnessUtxo(DecodeRawTransactionResponse value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasNonWitnessUtxo() => $_has(0);
  @$pb.TagNumber(1)
  void clearNonWitnessUtxo() => $_clearField(1);
  @$pb.TagNumber(1)
  DecodeRawTransactionResponse ensureNonWitnessUtxo() => $_ensure(0);

  @$pb.TagNumber(2)
  DecodePsbtResponse_WitnessUtxo get witnessUtxo => $_getN(1);
  @$pb.TagNumber(2)
  set witnessUtxo(DecodePsbtResponse_WitnessUtxo value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasWitnessUtxo() => $_has(1);
  @$pb.TagNumber(2)
  void clearWitnessUtxo() => $_clearField(2);
  @$pb.TagNumber(2)
  DecodePsbtResponse_WitnessUtxo ensureWitnessUtxo() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.String> get partialSignatures => $_getMap(2);

  @$pb.TagNumber(4)
  $core.String get sighash => $_getSZ(3);
  @$pb.TagNumber(4)
  set sighash($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSighash() => $_has(3);
  @$pb.TagNumber(4)
  void clearSighash() => $_clearField(4);

  @$pb.TagNumber(5)
  DecodePsbtResponse_RedeemScript get redeemScript => $_getN(4);
  @$pb.TagNumber(5)
  set redeemScript(DecodePsbtResponse_RedeemScript value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRedeemScript() => $_has(4);
  @$pb.TagNumber(5)
  void clearRedeemScript() => $_clearField(5);
  @$pb.TagNumber(5)
  DecodePsbtResponse_RedeemScript ensureRedeemScript() => $_ensure(4);

  @$pb.TagNumber(6)
  DecodePsbtResponse_RedeemScript get witnessScript => $_getN(5);
  @$pb.TagNumber(6)
  set witnessScript(DecodePsbtResponse_RedeemScript value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasWitnessScript() => $_has(5);
  @$pb.TagNumber(6)
  void clearWitnessScript() => $_clearField(6);
  @$pb.TagNumber(6)
  DecodePsbtResponse_RedeemScript ensureWitnessScript() => $_ensure(5);

  @$pb.TagNumber(7)
  $pb.PbList<DecodePsbtResponse_Bip32Deriv> get bip32Derivs => $_getList(6);

  @$pb.TagNumber(8)
  ScriptSig get finalScriptsig => $_getN(7);
  @$pb.TagNumber(8)
  set finalScriptsig(ScriptSig value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasFinalScriptsig() => $_has(7);
  @$pb.TagNumber(8)
  void clearFinalScriptsig() => $_clearField(8);
  @$pb.TagNumber(8)
  ScriptSig ensureFinalScriptsig() => $_ensure(7);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get finalScriptwitness => $_getList(8);

  @$pb.TagNumber(10)
  $pb.PbMap<$core.String, $core.String> get unknown => $_getMap(9);
}

class DecodePsbtResponse_Output extends $pb.GeneratedMessage {
  factory DecodePsbtResponse_Output({
    DecodePsbtResponse_RedeemScript? redeemScript,
    DecodePsbtResponse_RedeemScript? witnessScript,
    $core.Iterable<DecodePsbtResponse_Bip32Deriv>? bip32Derivs,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? unknown,
  }) {
    final result = DecodePsbtResponse_Output._();
    if (redeemScript != null) result.redeemScript = redeemScript;
    if (witnessScript != null) result.witnessScript = witnessScript;
    if (bip32Derivs != null) result.bip32Derivs.addAll(bip32Derivs);
    if (unknown != null) result.unknown.addEntries(unknown);
    return result;
  }

  DecodePsbtResponse_Output._();

  factory DecodePsbtResponse_Output.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodePsbtResponse_Output()..mergeFromBuffer(data, registry);
  factory DecodePsbtResponse_Output.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodePsbtResponse_Output()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse.Output',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: DecodePsbtResponse_Output.$_createMessage)
    ..aOM<DecodePsbtResponse_RedeemScript>(1, _omitFieldNames ? '' : 'redeemScript',
        subBuilder: DecodePsbtResponse_RedeemScript.$_createMessage)
    ..aOM<DecodePsbtResponse_RedeemScript>(2, _omitFieldNames ? '' : 'witnessScript',
        subBuilder: DecodePsbtResponse_RedeemScript.$_createMessage)
    ..pPM<DecodePsbtResponse_Bip32Deriv>(3, _omitFieldNames ? '' : 'bip32Derivs',
        subBuilder: DecodePsbtResponse_Bip32Deriv.$_createMessage)
    ..m<$core.String, $core.String>(4, _omitFieldNames ? '' : 'unknown',
        entryClassName: 'DecodePsbtResponse.Output.UnknownEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodePsbtResponse_Output clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodePsbtResponse_Output copyWith(void Function(DecodePsbtResponse_Output) updates) =>
      super.copyWith((message) => updates(message as DecodePsbtResponse_Output)) as DecodePsbtResponse_Output;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DecodePsbtResponse_Output() / DecodePsbtResponse_Output.new instead')
  static DecodePsbtResponse_Output create() => DecodePsbtResponse_Output._();
  static $pb.GeneratedMessage $_createMessage() => DecodePsbtResponse_Output._();
  @$core.override
  DecodePsbtResponse_Output createEmptyInstance() => DecodePsbtResponse_Output._();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_Output getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse_Output>(DecodePsbtResponse_Output.$_createMessage);
  static DecodePsbtResponse_Output? _defaultInstance;

  @$pb.TagNumber(1)
  DecodePsbtResponse_RedeemScript get redeemScript => $_getN(0);
  @$pb.TagNumber(1)
  set redeemScript(DecodePsbtResponse_RedeemScript value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRedeemScript() => $_has(0);
  @$pb.TagNumber(1)
  void clearRedeemScript() => $_clearField(1);
  @$pb.TagNumber(1)
  DecodePsbtResponse_RedeemScript ensureRedeemScript() => $_ensure(0);

  @$pb.TagNumber(2)
  DecodePsbtResponse_RedeemScript get witnessScript => $_getN(1);
  @$pb.TagNumber(2)
  set witnessScript(DecodePsbtResponse_RedeemScript value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasWitnessScript() => $_has(1);
  @$pb.TagNumber(2)
  void clearWitnessScript() => $_clearField(2);
  @$pb.TagNumber(2)
  DecodePsbtResponse_RedeemScript ensureWitnessScript() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<DecodePsbtResponse_Bip32Deriv> get bip32Derivs => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, $core.String> get unknown => $_getMap(3);
}

class DecodePsbtResponse extends $pb.GeneratedMessage {
  factory DecodePsbtResponse({
    DecodeRawTransactionResponse? tx,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? unknown,
    $core.Iterable<DecodePsbtResponse_Input>? inputs,
    $core.Iterable<DecodePsbtResponse_Output>? outputs,
    $core.double? fee,
  }) {
    final result = DecodePsbtResponse._();
    if (tx != null) result.tx = tx;
    if (unknown != null) result.unknown.addEntries(unknown);
    if (inputs != null) result.inputs.addAll(inputs);
    if (outputs != null) result.outputs.addAll(outputs);
    if (fee != null) result.fee = fee;
    return result;
  }

  DecodePsbtResponse._();

  factory DecodePsbtResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodePsbtResponse()..mergeFromBuffer(data, registry);
  factory DecodePsbtResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodePsbtResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: DecodePsbtResponse.$_createMessage)
    ..aOM<DecodeRawTransactionResponse>(1, _omitFieldNames ? '' : 'tx',
        subBuilder: DecodeRawTransactionResponse.$_createMessage)
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'unknown',
        entryClassName: 'DecodePsbtResponse.UnknownEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('bitcoin.bitcoind.v1alpha'))
    ..pPM<DecodePsbtResponse_Input>(3, _omitFieldNames ? '' : 'inputs',
        subBuilder: DecodePsbtResponse_Input.$_createMessage)
    ..pPM<DecodePsbtResponse_Output>(4, _omitFieldNames ? '' : 'outputs',
        subBuilder: DecodePsbtResponse_Output.$_createMessage)
    ..aD(5, _omitFieldNames ? '' : 'fee')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodePsbtResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodePsbtResponse copyWith(void Function(DecodePsbtResponse) updates) =>
      super.copyWith((message) => updates(message as DecodePsbtResponse)) as DecodePsbtResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DecodePsbtResponse() / DecodePsbtResponse.new instead')
  static DecodePsbtResponse create() => DecodePsbtResponse._();
  static $pb.GeneratedMessage $_createMessage() => DecodePsbtResponse._();
  @$core.override
  DecodePsbtResponse createEmptyInstance() => DecodePsbtResponse._();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse>(DecodePsbtResponse.$_createMessage);
  static DecodePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DecodeRawTransactionResponse get tx => $_getN(0);
  @$pb.TagNumber(1)
  set tx(DecodeRawTransactionResponse value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTx() => $_has(0);
  @$pb.TagNumber(1)
  void clearTx() => $_clearField(1);
  @$pb.TagNumber(1)
  DecodeRawTransactionResponse ensureTx() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $core.String> get unknown => $_getMap(1);

  @$pb.TagNumber(3)
  $pb.PbList<DecodePsbtResponse_Input> get inputs => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<DecodePsbtResponse_Output> get outputs => $_getList(3);

  @$pb.TagNumber(5)
  $core.double get fee => $_getN(4);
  @$pb.TagNumber(5)
  set fee($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFee() => $_has(4);
  @$pb.TagNumber(5)
  void clearFee() => $_clearField(5);
}

class AnalyzePsbtRequest extends $pb.GeneratedMessage {
  factory AnalyzePsbtRequest({
    $core.String? psbt,
  }) {
    final result = AnalyzePsbtRequest._();
    if (psbt != null) result.psbt = psbt;
    return result;
  }

  AnalyzePsbtRequest._();

  factory AnalyzePsbtRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AnalyzePsbtRequest()..mergeFromBuffer(data, registry);
  factory AnalyzePsbtRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AnalyzePsbtRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnalyzePsbtRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: AnalyzePsbtRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzePsbtRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzePsbtRequest copyWith(void Function(AnalyzePsbtRequest) updates) =>
      super.copyWith((message) => updates(message as AnalyzePsbtRequest)) as AnalyzePsbtRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AnalyzePsbtRequest() / AnalyzePsbtRequest.new instead')
  static AnalyzePsbtRequest create() => AnalyzePsbtRequest._();
  static $pb.GeneratedMessage $_createMessage() => AnalyzePsbtRequest._();
  @$core.override
  AnalyzePsbtRequest createEmptyInstance() => AnalyzePsbtRequest._();
  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnalyzePsbtRequest>(AnalyzePsbtRequest.$_createMessage);
  static AnalyzePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => $_clearField(1);
}

class AnalyzePsbtResponse_Input_Missing extends $pb.GeneratedMessage {
  factory AnalyzePsbtResponse_Input_Missing({
    $core.Iterable<$core.String>? pubkeys,
    $core.Iterable<$core.String>? signatures,
    $core.String? redeemScript,
    $core.String? witnessScript,
  }) {
    final result = AnalyzePsbtResponse_Input_Missing._();
    if (pubkeys != null) result.pubkeys.addAll(pubkeys);
    if (signatures != null) result.signatures.addAll(signatures);
    if (redeemScript != null) result.redeemScript = redeemScript;
    if (witnessScript != null) result.witnessScript = witnessScript;
    return result;
  }

  AnalyzePsbtResponse_Input_Missing._();

  factory AnalyzePsbtResponse_Input_Missing.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AnalyzePsbtResponse_Input_Missing()..mergeFromBuffer(data, registry);
  factory AnalyzePsbtResponse_Input_Missing.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AnalyzePsbtResponse_Input_Missing()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnalyzePsbtResponse.Input.Missing',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: AnalyzePsbtResponse_Input_Missing.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'pubkeys')
    ..pPS(2, _omitFieldNames ? '' : 'signatures')
    ..aOS(3, _omitFieldNames ? '' : 'redeemScript')
    ..aOS(4, _omitFieldNames ? '' : 'witnessScript')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzePsbtResponse_Input_Missing clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzePsbtResponse_Input_Missing copyWith(void Function(AnalyzePsbtResponse_Input_Missing) updates) =>
      super.copyWith((message) => updates(message as AnalyzePsbtResponse_Input_Missing))
          as AnalyzePsbtResponse_Input_Missing;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AnalyzePsbtResponse_Input_Missing() / AnalyzePsbtResponse_Input_Missing.new instead')
  static AnalyzePsbtResponse_Input_Missing create() => AnalyzePsbtResponse_Input_Missing._();
  static $pb.GeneratedMessage $_createMessage() => AnalyzePsbtResponse_Input_Missing._();
  @$core.override
  AnalyzePsbtResponse_Input_Missing createEmptyInstance() => AnalyzePsbtResponse_Input_Missing._();
  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse_Input_Missing getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnalyzePsbtResponse_Input_Missing>(
          AnalyzePsbtResponse_Input_Missing.$_createMessage);
  static AnalyzePsbtResponse_Input_Missing? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get pubkeys => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get signatures => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get redeemScript => $_getSZ(2);
  @$pb.TagNumber(3)
  set redeemScript($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRedeemScript() => $_has(2);
  @$pb.TagNumber(3)
  void clearRedeemScript() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get witnessScript => $_getSZ(3);
  @$pb.TagNumber(4)
  set witnessScript($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWitnessScript() => $_has(3);
  @$pb.TagNumber(4)
  void clearWitnessScript() => $_clearField(4);
}

class AnalyzePsbtResponse_Input extends $pb.GeneratedMessage {
  factory AnalyzePsbtResponse_Input({
    $core.bool? hasUtxo,
    $core.bool? isFinal,
    AnalyzePsbtResponse_Input_Missing? missing,
    $core.String? next,
  }) {
    final result = AnalyzePsbtResponse_Input._();
    if (hasUtxo != null) result.hasUtxo = hasUtxo;
    if (isFinal != null) result.isFinal = isFinal;
    if (missing != null) result.missing = missing;
    if (next != null) result.next = next;
    return result;
  }

  AnalyzePsbtResponse_Input._();

  factory AnalyzePsbtResponse_Input.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AnalyzePsbtResponse_Input()..mergeFromBuffer(data, registry);
  factory AnalyzePsbtResponse_Input.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AnalyzePsbtResponse_Input()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnalyzePsbtResponse.Input',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: AnalyzePsbtResponse_Input.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'hasUtxo')
    ..aOB(2, _omitFieldNames ? '' : 'isFinal')
    ..aOM<AnalyzePsbtResponse_Input_Missing>(3, _omitFieldNames ? '' : 'missing',
        subBuilder: AnalyzePsbtResponse_Input_Missing.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'next')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzePsbtResponse_Input clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzePsbtResponse_Input copyWith(void Function(AnalyzePsbtResponse_Input) updates) =>
      super.copyWith((message) => updates(message as AnalyzePsbtResponse_Input)) as AnalyzePsbtResponse_Input;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AnalyzePsbtResponse_Input() / AnalyzePsbtResponse_Input.new instead')
  static AnalyzePsbtResponse_Input create() => AnalyzePsbtResponse_Input._();
  static $pb.GeneratedMessage $_createMessage() => AnalyzePsbtResponse_Input._();
  @$core.override
  AnalyzePsbtResponse_Input createEmptyInstance() => AnalyzePsbtResponse_Input._();
  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse_Input getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnalyzePsbtResponse_Input>(AnalyzePsbtResponse_Input.$_createMessage);
  static AnalyzePsbtResponse_Input? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get hasUtxo => $_getBF(0);
  @$pb.TagNumber(1)
  set hasUtxo($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHasUtxo() => $_has(0);
  @$pb.TagNumber(1)
  void clearHasUtxo() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isFinal => $_getBF(1);
  @$pb.TagNumber(2)
  set isFinal($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsFinal() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsFinal() => $_clearField(2);

  @$pb.TagNumber(3)
  AnalyzePsbtResponse_Input_Missing get missing => $_getN(2);
  @$pb.TagNumber(3)
  set missing(AnalyzePsbtResponse_Input_Missing value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMissing() => $_has(2);
  @$pb.TagNumber(3)
  void clearMissing() => $_clearField(3);
  @$pb.TagNumber(3)
  AnalyzePsbtResponse_Input_Missing ensureMissing() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get next => $_getSZ(3);
  @$pb.TagNumber(4)
  set next($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNext() => $_has(3);
  @$pb.TagNumber(4)
  void clearNext() => $_clearField(4);
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
    final result = AnalyzePsbtResponse._();
    if (inputs != null) result.inputs.addAll(inputs);
    if (estimatedVsize != null) result.estimatedVsize = estimatedVsize;
    if (estimatedFeerate != null) result.estimatedFeerate = estimatedFeerate;
    if (fee != null) result.fee = fee;
    if (next != null) result.next = next;
    if (error != null) result.error = error;
    return result;
  }

  AnalyzePsbtResponse._();

  factory AnalyzePsbtResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AnalyzePsbtResponse()..mergeFromBuffer(data, registry);
  factory AnalyzePsbtResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AnalyzePsbtResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnalyzePsbtResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: AnalyzePsbtResponse.$_createMessage)
    ..pPM<AnalyzePsbtResponse_Input>(1, _omitFieldNames ? '' : 'inputs',
        subBuilder: AnalyzePsbtResponse_Input.$_createMessage)
    ..aD(2, _omitFieldNames ? '' : 'estimatedVsize')
    ..aD(3, _omitFieldNames ? '' : 'estimatedFeerate')
    ..aD(4, _omitFieldNames ? '' : 'fee')
    ..aOS(5, _omitFieldNames ? '' : 'next')
    ..aOS(6, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzePsbtResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzePsbtResponse copyWith(void Function(AnalyzePsbtResponse) updates) =>
      super.copyWith((message) => updates(message as AnalyzePsbtResponse)) as AnalyzePsbtResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AnalyzePsbtResponse() / AnalyzePsbtResponse.new instead')
  static AnalyzePsbtResponse create() => AnalyzePsbtResponse._();
  static $pb.GeneratedMessage $_createMessage() => AnalyzePsbtResponse._();
  @$core.override
  AnalyzePsbtResponse createEmptyInstance() => AnalyzePsbtResponse._();
  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnalyzePsbtResponse>(AnalyzePsbtResponse.$_createMessage);
  static AnalyzePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AnalyzePsbtResponse_Input> get inputs => $_getList(0);

  @$pb.TagNumber(2)
  $core.double get estimatedVsize => $_getN(1);
  @$pb.TagNumber(2)
  set estimatedVsize($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEstimatedVsize() => $_has(1);
  @$pb.TagNumber(2)
  void clearEstimatedVsize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get estimatedFeerate => $_getN(2);
  @$pb.TagNumber(3)
  set estimatedFeerate($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEstimatedFeerate() => $_has(2);
  @$pb.TagNumber(3)
  void clearEstimatedFeerate() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get fee => $_getN(3);
  @$pb.TagNumber(4)
  set fee($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFee() => $_has(3);
  @$pb.TagNumber(4)
  void clearFee() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get next => $_getSZ(4);
  @$pb.TagNumber(5)
  set next($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNext() => $_has(4);
  @$pb.TagNumber(5)
  void clearNext() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get error => $_getSZ(5);
  @$pb.TagNumber(6)
  set error($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasError() => $_has(5);
  @$pb.TagNumber(6)
  void clearError() => $_clearField(6);
}

class CombinePsbtRequest extends $pb.GeneratedMessage {
  factory CombinePsbtRequest({
    $core.Iterable<$core.String>? psbts,
  }) {
    final result = CombinePsbtRequest._();
    if (psbts != null) result.psbts.addAll(psbts);
    return result;
  }

  CombinePsbtRequest._();

  factory CombinePsbtRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CombinePsbtRequest()..mergeFromBuffer(data, registry);
  factory CombinePsbtRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CombinePsbtRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CombinePsbtRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: CombinePsbtRequest.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'psbts')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CombinePsbtRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CombinePsbtRequest copyWith(void Function(CombinePsbtRequest) updates) =>
      super.copyWith((message) => updates(message as CombinePsbtRequest)) as CombinePsbtRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CombinePsbtRequest() / CombinePsbtRequest.new instead')
  static CombinePsbtRequest create() => CombinePsbtRequest._();
  static $pb.GeneratedMessage $_createMessage() => CombinePsbtRequest._();
  @$core.override
  CombinePsbtRequest createEmptyInstance() => CombinePsbtRequest._();
  @$core.pragma('dart2js:noInline')
  static CombinePsbtRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CombinePsbtRequest>(CombinePsbtRequest.$_createMessage);
  static CombinePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get psbts => $_getList(0);
}

class CombinePsbtResponse extends $pb.GeneratedMessage {
  factory CombinePsbtResponse({
    $core.String? psbt,
  }) {
    final result = CombinePsbtResponse._();
    if (psbt != null) result.psbt = psbt;
    return result;
  }

  CombinePsbtResponse._();

  factory CombinePsbtResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CombinePsbtResponse()..mergeFromBuffer(data, registry);
  factory CombinePsbtResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CombinePsbtResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CombinePsbtResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: CombinePsbtResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CombinePsbtResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CombinePsbtResponse copyWith(void Function(CombinePsbtResponse) updates) =>
      super.copyWith((message) => updates(message as CombinePsbtResponse)) as CombinePsbtResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CombinePsbtResponse() / CombinePsbtResponse.new instead')
  static CombinePsbtResponse create() => CombinePsbtResponse._();
  static $pb.GeneratedMessage $_createMessage() => CombinePsbtResponse._();
  @$core.override
  CombinePsbtResponse createEmptyInstance() => CombinePsbtResponse._();
  @$core.pragma('dart2js:noInline')
  static CombinePsbtResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CombinePsbtResponse>(CombinePsbtResponse.$_createMessage);
  static CombinePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => $_clearField(1);
}

class UtxoUpdatePsbtRequest extends $pb.GeneratedMessage {
  factory UtxoUpdatePsbtRequest({
    $core.String? psbt,
    $core.Iterable<Descriptor>? descriptors,
  }) {
    final result = UtxoUpdatePsbtRequest._();
    if (psbt != null) result.psbt = psbt;
    if (descriptors != null) result.descriptors.addAll(descriptors);
    return result;
  }

  UtxoUpdatePsbtRequest._();

  factory UtxoUpdatePsbtRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UtxoUpdatePsbtRequest()..mergeFromBuffer(data, registry);
  factory UtxoUpdatePsbtRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UtxoUpdatePsbtRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UtxoUpdatePsbtRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: UtxoUpdatePsbtRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..pPM<Descriptor>(2, _omitFieldNames ? '' : 'descriptors', subBuilder: Descriptor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UtxoUpdatePsbtRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UtxoUpdatePsbtRequest copyWith(void Function(UtxoUpdatePsbtRequest) updates) =>
      super.copyWith((message) => updates(message as UtxoUpdatePsbtRequest)) as UtxoUpdatePsbtRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UtxoUpdatePsbtRequest() / UtxoUpdatePsbtRequest.new instead')
  static UtxoUpdatePsbtRequest create() => UtxoUpdatePsbtRequest._();
  static $pb.GeneratedMessage $_createMessage() => UtxoUpdatePsbtRequest._();
  @$core.override
  UtxoUpdatePsbtRequest createEmptyInstance() => UtxoUpdatePsbtRequest._();
  @$core.pragma('dart2js:noInline')
  static UtxoUpdatePsbtRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UtxoUpdatePsbtRequest>(UtxoUpdatePsbtRequest.$_createMessage);
  static UtxoUpdatePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Descriptor> get descriptors => $_getList(1);
}

class UtxoUpdatePsbtResponse extends $pb.GeneratedMessage {
  factory UtxoUpdatePsbtResponse({
    $core.String? psbt,
  }) {
    final result = UtxoUpdatePsbtResponse._();
    if (psbt != null) result.psbt = psbt;
    return result;
  }

  UtxoUpdatePsbtResponse._();

  factory UtxoUpdatePsbtResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UtxoUpdatePsbtResponse()..mergeFromBuffer(data, registry);
  factory UtxoUpdatePsbtResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UtxoUpdatePsbtResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UtxoUpdatePsbtResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: UtxoUpdatePsbtResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UtxoUpdatePsbtResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UtxoUpdatePsbtResponse copyWith(void Function(UtxoUpdatePsbtResponse) updates) =>
      super.copyWith((message) => updates(message as UtxoUpdatePsbtResponse)) as UtxoUpdatePsbtResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UtxoUpdatePsbtResponse() / UtxoUpdatePsbtResponse.new instead')
  static UtxoUpdatePsbtResponse create() => UtxoUpdatePsbtResponse._();
  static $pb.GeneratedMessage $_createMessage() => UtxoUpdatePsbtResponse._();
  @$core.override
  UtxoUpdatePsbtResponse createEmptyInstance() => UtxoUpdatePsbtResponse._();
  @$core.pragma('dart2js:noInline')
  static UtxoUpdatePsbtResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UtxoUpdatePsbtResponse>(UtxoUpdatePsbtResponse.$_createMessage);
  static UtxoUpdatePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => $_clearField(1);
}

class JoinPsbtsRequest extends $pb.GeneratedMessage {
  factory JoinPsbtsRequest({
    $core.Iterable<$core.String>? psbts,
  }) {
    final result = JoinPsbtsRequest._();
    if (psbts != null) result.psbts.addAll(psbts);
    return result;
  }

  JoinPsbtsRequest._();

  factory JoinPsbtsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      JoinPsbtsRequest()..mergeFromBuffer(data, registry);
  factory JoinPsbtsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      JoinPsbtsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinPsbtsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: JoinPsbtsRequest.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'psbts')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinPsbtsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinPsbtsRequest copyWith(void Function(JoinPsbtsRequest) updates) =>
      super.copyWith((message) => updates(message as JoinPsbtsRequest)) as JoinPsbtsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use JoinPsbtsRequest() / JoinPsbtsRequest.new instead')
  static JoinPsbtsRequest create() => JoinPsbtsRequest._();
  static $pb.GeneratedMessage $_createMessage() => JoinPsbtsRequest._();
  @$core.override
  JoinPsbtsRequest createEmptyInstance() => JoinPsbtsRequest._();
  @$core.pragma('dart2js:noInline')
  static JoinPsbtsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinPsbtsRequest>(JoinPsbtsRequest.$_createMessage);
  static JoinPsbtsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get psbts => $_getList(0);
}

class JoinPsbtsResponse extends $pb.GeneratedMessage {
  factory JoinPsbtsResponse({
    $core.String? psbt,
  }) {
    final result = JoinPsbtsResponse._();
    if (psbt != null) result.psbt = psbt;
    return result;
  }

  JoinPsbtsResponse._();

  factory JoinPsbtsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      JoinPsbtsResponse()..mergeFromBuffer(data, registry);
  factory JoinPsbtsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      JoinPsbtsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinPsbtsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: JoinPsbtsResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinPsbtsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinPsbtsResponse copyWith(void Function(JoinPsbtsResponse) updates) =>
      super.copyWith((message) => updates(message as JoinPsbtsResponse)) as JoinPsbtsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use JoinPsbtsResponse() / JoinPsbtsResponse.new instead')
  static JoinPsbtsResponse create() => JoinPsbtsResponse._();
  static $pb.GeneratedMessage $_createMessage() => JoinPsbtsResponse._();
  @$core.override
  JoinPsbtsResponse createEmptyInstance() => JoinPsbtsResponse._();
  @$core.pragma('dart2js:noInline')
  static JoinPsbtsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinPsbtsResponse>(JoinPsbtsResponse.$_createMessage);
  static JoinPsbtsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => $_clearField(1);
}

class TestMempoolAcceptRequest extends $pb.GeneratedMessage {
  factory TestMempoolAcceptRequest({
    $core.Iterable<$core.String>? rawtxs,
    $core.double? maxFeeRate,
  }) {
    final result = TestMempoolAcceptRequest._();
    if (rawtxs != null) result.rawtxs.addAll(rawtxs);
    if (maxFeeRate != null) result.maxFeeRate = maxFeeRate;
    return result;
  }

  TestMempoolAcceptRequest._();

  factory TestMempoolAcceptRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TestMempoolAcceptRequest()..mergeFromBuffer(data, registry);
  factory TestMempoolAcceptRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TestMempoolAcceptRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TestMempoolAcceptRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: TestMempoolAcceptRequest.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'rawtxs')
    ..aD(2, _omitFieldNames ? '' : 'maxFeeRate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestMempoolAcceptRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestMempoolAcceptRequest copyWith(void Function(TestMempoolAcceptRequest) updates) =>
      super.copyWith((message) => updates(message as TestMempoolAcceptRequest)) as TestMempoolAcceptRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TestMempoolAcceptRequest() / TestMempoolAcceptRequest.new instead')
  static TestMempoolAcceptRequest create() => TestMempoolAcceptRequest._();
  static $pb.GeneratedMessage $_createMessage() => TestMempoolAcceptRequest._();
  @$core.override
  TestMempoolAcceptRequest createEmptyInstance() => TestMempoolAcceptRequest._();
  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TestMempoolAcceptRequest>(TestMempoolAcceptRequest.$_createMessage);
  static TestMempoolAcceptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get rawtxs => $_getList(0);

  @$pb.TagNumber(2)
  $core.double get maxFeeRate => $_getN(1);
  @$pb.TagNumber(2)
  set maxFeeRate($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxFeeRate() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxFeeRate() => $_clearField(2);
}

class TestMempoolAcceptResponse_Result extends $pb.GeneratedMessage {
  factory TestMempoolAcceptResponse_Result({
    $core.String? txid,
    $core.bool? allowed,
    $core.String? rejectReason,
    $core.int? vsize,
    $core.double? fees,
  }) {
    final result = TestMempoolAcceptResponse_Result._();
    if (txid != null) result.txid = txid;
    if (allowed != null) result.allowed = allowed;
    if (rejectReason != null) result.rejectReason = rejectReason;
    if (vsize != null) result.vsize = vsize;
    if (fees != null) result.fees = fees;
    return result;
  }

  TestMempoolAcceptResponse_Result._();

  factory TestMempoolAcceptResponse_Result.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TestMempoolAcceptResponse_Result()..mergeFromBuffer(data, registry);
  factory TestMempoolAcceptResponse_Result.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TestMempoolAcceptResponse_Result()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TestMempoolAcceptResponse.Result',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: TestMempoolAcceptResponse_Result.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOB(2, _omitFieldNames ? '' : 'allowed')
    ..aOS(3, _omitFieldNames ? '' : 'rejectReason')
    ..aI(4, _omitFieldNames ? '' : 'vsize', fieldType: $pb.PbFieldType.OU3)
    ..aD(5, _omitFieldNames ? '' : 'fees')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestMempoolAcceptResponse_Result clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestMempoolAcceptResponse_Result copyWith(void Function(TestMempoolAcceptResponse_Result) updates) =>
      super.copyWith((message) => updates(message as TestMempoolAcceptResponse_Result))
          as TestMempoolAcceptResponse_Result;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TestMempoolAcceptResponse_Result() / TestMempoolAcceptResponse_Result.new instead')
  static TestMempoolAcceptResponse_Result create() => TestMempoolAcceptResponse_Result._();
  static $pb.GeneratedMessage $_createMessage() => TestMempoolAcceptResponse_Result._();
  @$core.override
  TestMempoolAcceptResponse_Result createEmptyInstance() => TestMempoolAcceptResponse_Result._();
  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptResponse_Result getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TestMempoolAcceptResponse_Result>(
          TestMempoolAcceptResponse_Result.$_createMessage);
  static TestMempoolAcceptResponse_Result? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get allowed => $_getBF(1);
  @$pb.TagNumber(2)
  set allowed($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAllowed() => $_has(1);
  @$pb.TagNumber(2)
  void clearAllowed() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get rejectReason => $_getSZ(2);
  @$pb.TagNumber(3)
  set rejectReason($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRejectReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearRejectReason() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get vsize => $_getIZ(3);
  @$pb.TagNumber(4)
  set vsize($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVsize() => $_has(3);
  @$pb.TagNumber(4)
  void clearVsize() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get fees => $_getN(4);
  @$pb.TagNumber(5)
  set fees($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFees() => $_has(4);
  @$pb.TagNumber(5)
  void clearFees() => $_clearField(5);
}

class TestMempoolAcceptResponse extends $pb.GeneratedMessage {
  factory TestMempoolAcceptResponse({
    $core.Iterable<TestMempoolAcceptResponse_Result>? results,
  }) {
    final result = TestMempoolAcceptResponse._();
    if (results != null) result.results.addAll(results);
    return result;
  }

  TestMempoolAcceptResponse._();

  factory TestMempoolAcceptResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TestMempoolAcceptResponse()..mergeFromBuffer(data, registry);
  factory TestMempoolAcceptResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TestMempoolAcceptResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TestMempoolAcceptResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: TestMempoolAcceptResponse.$_createMessage)
    ..pPM<TestMempoolAcceptResponse_Result>(1, _omitFieldNames ? '' : 'results',
        subBuilder: TestMempoolAcceptResponse_Result.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestMempoolAcceptResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestMempoolAcceptResponse copyWith(void Function(TestMempoolAcceptResponse) updates) =>
      super.copyWith((message) => updates(message as TestMempoolAcceptResponse)) as TestMempoolAcceptResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TestMempoolAcceptResponse() / TestMempoolAcceptResponse.new instead')
  static TestMempoolAcceptResponse create() => TestMempoolAcceptResponse._();
  static $pb.GeneratedMessage $_createMessage() => TestMempoolAcceptResponse._();
  @$core.override
  TestMempoolAcceptResponse createEmptyInstance() => TestMempoolAcceptResponse._();
  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TestMempoolAcceptResponse>(TestMempoolAcceptResponse.$_createMessage);
  static TestMempoolAcceptResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TestMempoolAcceptResponse_Result> get results => $_getList(0);
}

enum DescriptorRange_RangeType { end, range, notSet }

/// Add a new message for descriptor range
class DescriptorRange extends $pb.GeneratedMessage {
  factory DescriptorRange({
    $core.int? end,
    Range? range,
  }) {
    final result = DescriptorRange._();
    if (end != null) result.end = end;
    if (range != null) result.range = range;
    return result;
  }

  DescriptorRange._();

  factory DescriptorRange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DescriptorRange()..mergeFromBuffer(data, registry);
  factory DescriptorRange.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DescriptorRange()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, DescriptorRange_RangeType> _DescriptorRange_RangeTypeByTag = {
    1: DescriptorRange_RangeType.end,
    2: DescriptorRange_RangeType.range,
    0: DescriptorRange_RangeType.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DescriptorRange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: DescriptorRange.$_createMessage)
    ..oo(0, [1, 2])
    ..aI(1, _omitFieldNames ? '' : 'end')
    ..aOM<Range>(2, _omitFieldNames ? '' : 'range', subBuilder: Range.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DescriptorRange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DescriptorRange copyWith(void Function(DescriptorRange) updates) =>
      super.copyWith((message) => updates(message as DescriptorRange)) as DescriptorRange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DescriptorRange() / DescriptorRange.new instead')
  static DescriptorRange create() => DescriptorRange._();
  static $pb.GeneratedMessage $_createMessage() => DescriptorRange._();
  @$core.override
  DescriptorRange createEmptyInstance() => DescriptorRange._();
  @$core.pragma('dart2js:noInline')
  static DescriptorRange getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DescriptorRange>(DescriptorRange.$_createMessage);
  static DescriptorRange? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  DescriptorRange_RangeType whichRangeType() => _DescriptorRange_RangeTypeByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearRangeType() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get end => $_getIZ(0);
  @$pb.TagNumber(1)
  set end($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnd() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnd() => $_clearField(1);

  @$pb.TagNumber(2)
  Range get range => $_getN(1);
  @$pb.TagNumber(2)
  set range(Range value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRange() => $_has(1);
  @$pb.TagNumber(2)
  void clearRange() => $_clearField(2);
  @$pb.TagNumber(2)
  Range ensureRange() => $_ensure(1);
}

/// Add a new message for begin/end range
class Range extends $pb.GeneratedMessage {
  factory Range({
    $core.int? begin,
    $core.int? end,
  }) {
    final result = Range._();
    if (begin != null) result.begin = begin;
    if (end != null) result.end = end;
    return result;
  }

  Range._();

  factory Range.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Range()..mergeFromBuffer(data, registry);
  factory Range.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Range()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Range',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: Range.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'begin')
    ..aI(2, _omitFieldNames ? '' : 'end')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Range clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Range copyWith(void Function(Range) updates) => super.copyWith((message) => updates(message as Range)) as Range;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Range() / Range.new instead')
  static Range create() => Range._();
  static $pb.GeneratedMessage $_createMessage() => Range._();
  @$core.override
  Range createEmptyInstance() => Range._();
  @$core.pragma('dart2js:noInline')
  static Range getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Range>(Range.$_createMessage);
  static Range? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get begin => $_getIZ(0);
  @$pb.TagNumber(1)
  set begin($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBegin() => $_has(0);
  @$pb.TagNumber(1)
  void clearBegin() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get end => $_getIZ(1);
  @$pb.TagNumber(2)
  set end($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnd() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnd() => $_clearField(2);
}

enum Descriptor_Descriptor { stringDescriptor, objectDescriptor, notSet }

/// Add a new message for descriptor
class Descriptor extends $pb.GeneratedMessage {
  factory Descriptor({
    $core.String? stringDescriptor,
    DescriptorObject? objectDescriptor,
  }) {
    final result = Descriptor._();
    if (stringDescriptor != null) result.stringDescriptor = stringDescriptor;
    if (objectDescriptor != null) result.objectDescriptor = objectDescriptor;
    return result;
  }

  Descriptor._();

  factory Descriptor.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Descriptor()..mergeFromBuffer(data, registry);
  factory Descriptor.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Descriptor()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Descriptor_Descriptor> _Descriptor_DescriptorByTag = {
    1: Descriptor_Descriptor.stringDescriptor,
    2: Descriptor_Descriptor.objectDescriptor,
    0: Descriptor_Descriptor.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Descriptor',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: Descriptor.$_createMessage)
    ..oo(0, [1, 2])
    ..aOS(1, _omitFieldNames ? '' : 'stringDescriptor')
    ..aOM<DescriptorObject>(2, _omitFieldNames ? '' : 'objectDescriptor', subBuilder: DescriptorObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Descriptor clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Descriptor copyWith(void Function(Descriptor) updates) =>
      super.copyWith((message) => updates(message as Descriptor)) as Descriptor;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Descriptor() / Descriptor.new instead')
  static Descriptor create() => Descriptor._();
  static $pb.GeneratedMessage $_createMessage() => Descriptor._();
  @$core.override
  Descriptor createEmptyInstance() => Descriptor._();
  @$core.pragma('dart2js:noInline')
  static Descriptor getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Descriptor>(Descriptor.$_createMessage);
  static Descriptor? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  Descriptor_Descriptor whichDescriptor() => _Descriptor_DescriptorByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearDescriptor() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get stringDescriptor => $_getSZ(0);
  @$pb.TagNumber(1)
  set stringDescriptor($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStringDescriptor() => $_has(0);
  @$pb.TagNumber(1)
  void clearStringDescriptor() => $_clearField(1);

  @$pb.TagNumber(2)
  DescriptorObject get objectDescriptor => $_getN(1);
  @$pb.TagNumber(2)
  set objectDescriptor(DescriptorObject value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasObjectDescriptor() => $_has(1);
  @$pb.TagNumber(2)
  void clearObjectDescriptor() => $_clearField(2);
  @$pb.TagNumber(2)
  DescriptorObject ensureObjectDescriptor() => $_ensure(1);
}

/// Add a new message for descriptor objects
class DescriptorObject extends $pb.GeneratedMessage {
  factory DescriptorObject({
    $core.String? desc,
    DescriptorRange? range,
  }) {
    final result = DescriptorObject._();
    if (desc != null) result.desc = desc;
    if (range != null) result.range = range;
    return result;
  }

  DescriptorObject._();

  factory DescriptorObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DescriptorObject()..mergeFromBuffer(data, registry);
  factory DescriptorObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DescriptorObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DescriptorObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: DescriptorObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'desc')
    ..aOM<DescriptorRange>(2, _omitFieldNames ? '' : 'range', subBuilder: DescriptorRange.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DescriptorObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DescriptorObject copyWith(void Function(DescriptorObject) updates) =>
      super.copyWith((message) => updates(message as DescriptorObject)) as DescriptorObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DescriptorObject() / DescriptorObject.new instead')
  static DescriptorObject create() => DescriptorObject._();
  static $pb.GeneratedMessage $_createMessage() => DescriptorObject._();
  @$core.override
  DescriptorObject createEmptyInstance() => DescriptorObject._();
  @$core.pragma('dart2js:noInline')
  static DescriptorObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DescriptorObject>(DescriptorObject.$_createMessage);
  static DescriptorObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get desc => $_getSZ(0);
  @$pb.TagNumber(1)
  set desc($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDesc() => $_has(0);
  @$pb.TagNumber(1)
  void clearDesc() => $_clearField(1);

  @$pb.TagNumber(2)
  DescriptorRange get range => $_getN(1);
  @$pb.TagNumber(2)
  set range(DescriptorRange value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRange() => $_has(1);
  @$pb.TagNumber(2)
  void clearRange() => $_clearField(2);
  @$pb.TagNumber(2)
  DescriptorRange ensureRange() => $_ensure(1);
}

class GetZmqNotificationsResponse_Notification extends $pb.GeneratedMessage {
  factory GetZmqNotificationsResponse_Notification({
    $core.String? type,
    $core.String? address,
    $fixnum.Int64? highWaterMark,
  }) {
    final result = GetZmqNotificationsResponse_Notification._();
    if (type != null) result.type = type;
    if (address != null) result.address = address;
    if (highWaterMark != null) result.highWaterMark = highWaterMark;
    return result;
  }

  GetZmqNotificationsResponse_Notification._();

  factory GetZmqNotificationsResponse_Notification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetZmqNotificationsResponse_Notification()..mergeFromBuffer(data, registry);
  factory GetZmqNotificationsResponse_Notification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetZmqNotificationsResponse_Notification()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetZmqNotificationsResponse.Notification',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetZmqNotificationsResponse_Notification.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aInt64(3, _omitFieldNames ? '' : 'highWaterMark')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetZmqNotificationsResponse_Notification clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetZmqNotificationsResponse_Notification copyWith(void Function(GetZmqNotificationsResponse_Notification) updates) =>
      super.copyWith((message) => updates(message as GetZmqNotificationsResponse_Notification))
          as GetZmqNotificationsResponse_Notification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetZmqNotificationsResponse_Notification() / GetZmqNotificationsResponse_Notification.new instead')
  static GetZmqNotificationsResponse_Notification create() => GetZmqNotificationsResponse_Notification._();
  static $pb.GeneratedMessage $_createMessage() => GetZmqNotificationsResponse_Notification._();
  @$core.override
  GetZmqNotificationsResponse_Notification createEmptyInstance() => GetZmqNotificationsResponse_Notification._();
  @$core.pragma('dart2js:noInline')
  static GetZmqNotificationsResponse_Notification getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetZmqNotificationsResponse_Notification>(
          GetZmqNotificationsResponse_Notification.$_createMessage);
  static GetZmqNotificationsResponse_Notification? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get highWaterMark => $_getI64(2);
  @$pb.TagNumber(3)
  set highWaterMark($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHighWaterMark() => $_has(2);
  @$pb.TagNumber(3)
  void clearHighWaterMark() => $_clearField(3);
}

class GetZmqNotificationsResponse extends $pb.GeneratedMessage {
  factory GetZmqNotificationsResponse({
    $core.Iterable<GetZmqNotificationsResponse_Notification>? notifications,
  }) {
    final result = GetZmqNotificationsResponse._();
    if (notifications != null) result.notifications.addAll(notifications);
    return result;
  }

  GetZmqNotificationsResponse._();

  factory GetZmqNotificationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetZmqNotificationsResponse()..mergeFromBuffer(data, registry);
  factory GetZmqNotificationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetZmqNotificationsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetZmqNotificationsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: GetZmqNotificationsResponse.$_createMessage)
    ..pPM<GetZmqNotificationsResponse_Notification>(1, _omitFieldNames ? '' : 'notifications',
        subBuilder: GetZmqNotificationsResponse_Notification.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetZmqNotificationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetZmqNotificationsResponse copyWith(void Function(GetZmqNotificationsResponse) updates) =>
      super.copyWith((message) => updates(message as GetZmqNotificationsResponse)) as GetZmqNotificationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetZmqNotificationsResponse() / GetZmqNotificationsResponse.new instead')
  static GetZmqNotificationsResponse create() => GetZmqNotificationsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetZmqNotificationsResponse._();
  @$core.override
  GetZmqNotificationsResponse createEmptyInstance() => GetZmqNotificationsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetZmqNotificationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetZmqNotificationsResponse>(GetZmqNotificationsResponse.$_createMessage);
  static GetZmqNotificationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GetZmqNotificationsResponse_Notification> get notifications => $_getList(0);
}

class SignRawTransactionWithWalletRequest extends $pb.GeneratedMessage {
  factory SignRawTransactionWithWalletRequest({
    $core.String? hexString,
    $core.String? wallet,
  }) {
    final result = SignRawTransactionWithWalletRequest._();
    if (hexString != null) result.hexString = hexString;
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  SignRawTransactionWithWalletRequest._();

  factory SignRawTransactionWithWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignRawTransactionWithWalletRequest()..mergeFromBuffer(data, registry);
  factory SignRawTransactionWithWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignRawTransactionWithWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignRawTransactionWithWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: SignRawTransactionWithWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'hexString')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignRawTransactionWithWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignRawTransactionWithWalletRequest copyWith(void Function(SignRawTransactionWithWalletRequest) updates) =>
      super.copyWith((message) => updates(message as SignRawTransactionWithWalletRequest))
          as SignRawTransactionWithWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignRawTransactionWithWalletRequest() / SignRawTransactionWithWalletRequest.new instead')
  static SignRawTransactionWithWalletRequest create() => SignRawTransactionWithWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => SignRawTransactionWithWalletRequest._();
  @$core.override
  SignRawTransactionWithWalletRequest createEmptyInstance() => SignRawTransactionWithWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static SignRawTransactionWithWalletRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignRawTransactionWithWalletRequest>(
          SignRawTransactionWithWalletRequest.$_createMessage);
  static SignRawTransactionWithWalletRequest? _defaultInstance;

  /// The transaction hex string
  @$pb.TagNumber(1)
  $core.String get hexString => $_getSZ(0);
  @$pb.TagNumber(1)
  set hexString($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHexString() => $_has(0);
  @$pb.TagNumber(1)
  void clearHexString() => $_clearField(1);

  /// Only needs to be set if dealing with multiple wallets at the same time.
  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => $_clearField(2);
}

/// Script verification errors (if there are any)
class SignRawTransactionWithWalletResponse_Error extends $pb.GeneratedMessage {
  factory SignRawTransactionWithWalletResponse_Error({
    $core.String? txid,
    $core.int? vout,
    $core.Iterable<$core.String>? witness,
    $core.String? scriptSig,
    $core.int? sequence,
    $core.String? error,
  }) {
    final result = SignRawTransactionWithWalletResponse_Error._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (witness != null) result.witness.addAll(witness);
    if (scriptSig != null) result.scriptSig = scriptSig;
    if (sequence != null) result.sequence = sequence;
    if (error != null) result.error = error;
    return result;
  }

  SignRawTransactionWithWalletResponse_Error._();

  factory SignRawTransactionWithWalletResponse_Error.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignRawTransactionWithWalletResponse_Error()..mergeFromBuffer(data, registry);
  factory SignRawTransactionWithWalletResponse_Error.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignRawTransactionWithWalletResponse_Error()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SignRawTransactionWithWalletResponse.Error',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: SignRawTransactionWithWalletResponse_Error.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'vout', fieldType: $pb.PbFieldType.OU3)
    ..pPS(3, _omitFieldNames ? '' : 'witness')
    ..aOS(4, _omitFieldNames ? '' : 'scriptSig')
    ..aI(5, _omitFieldNames ? '' : 'sequence', fieldType: $pb.PbFieldType.OU3)
    ..aOS(6, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignRawTransactionWithWalletResponse_Error clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignRawTransactionWithWalletResponse_Error copyWith(
          void Function(SignRawTransactionWithWalletResponse_Error) updates) =>
      super.copyWith((message) => updates(message as SignRawTransactionWithWalletResponse_Error))
          as SignRawTransactionWithWalletResponse_Error;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SignRawTransactionWithWalletResponse_Error() / SignRawTransactionWithWalletResponse_Error.new instead')
  static SignRawTransactionWithWalletResponse_Error create() => SignRawTransactionWithWalletResponse_Error._();
  static $pb.GeneratedMessage $_createMessage() => SignRawTransactionWithWalletResponse_Error._();
  @$core.override
  SignRawTransactionWithWalletResponse_Error createEmptyInstance() => SignRawTransactionWithWalletResponse_Error._();
  @$core.pragma('dart2js:noInline')
  static SignRawTransactionWithWalletResponse_Error getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignRawTransactionWithWalletResponse_Error>(
          SignRawTransactionWithWalletResponse_Error.$_createMessage);
  static SignRawTransactionWithWalletResponse_Error? _defaultInstance;

  /// The hash of the referenced, previous transaction
  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  /// The index of the output to spent and used as input
  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);

  /// The witness data
  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get witness => $_getList(2);

  /// The hex-encoded signature script
  @$pb.TagNumber(4)
  $core.String get scriptSig => $_getSZ(3);
  @$pb.TagNumber(4)
  set scriptSig($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasScriptSig() => $_has(3);
  @$pb.TagNumber(4)
  void clearScriptSig() => $_clearField(4);

  /// Script sequence number
  @$pb.TagNumber(5)
  $core.int get sequence => $_getIZ(4);
  @$pb.TagNumber(5)
  set sequence($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSequence() => $_has(4);
  @$pb.TagNumber(5)
  void clearSequence() => $_clearField(5);

  /// Verification or signing error related to the input
  @$pb.TagNumber(6)
  $core.String get error => $_getSZ(5);
  @$pb.TagNumber(6)
  set error($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasError() => $_has(5);
  @$pb.TagNumber(6)
  void clearError() => $_clearField(6);
}

class SignRawTransactionWithWalletResponse extends $pb.GeneratedMessage {
  factory SignRawTransactionWithWalletResponse({
    $core.String? hex,
    $core.bool? complete,
    $core.Iterable<SignRawTransactionWithWalletResponse_Error>? errors,
  }) {
    final result = SignRawTransactionWithWalletResponse._();
    if (hex != null) result.hex = hex;
    if (complete != null) result.complete = complete;
    if (errors != null) result.errors.addAll(errors);
    return result;
  }

  SignRawTransactionWithWalletResponse._();

  factory SignRawTransactionWithWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignRawTransactionWithWalletResponse()..mergeFromBuffer(data, registry);
  factory SignRawTransactionWithWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignRawTransactionWithWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignRawTransactionWithWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'),
      createEmptyInstance: SignRawTransactionWithWalletResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'hex')
    ..aOB(2, _omitFieldNames ? '' : 'complete')
    ..pPM<SignRawTransactionWithWalletResponse_Error>(3, _omitFieldNames ? '' : 'errors',
        subBuilder: SignRawTransactionWithWalletResponse_Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignRawTransactionWithWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignRawTransactionWithWalletResponse copyWith(void Function(SignRawTransactionWithWalletResponse) updates) =>
      super.copyWith((message) => updates(message as SignRawTransactionWithWalletResponse))
          as SignRawTransactionWithWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignRawTransactionWithWalletResponse() / SignRawTransactionWithWalletResponse.new instead')
  static SignRawTransactionWithWalletResponse create() => SignRawTransactionWithWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => SignRawTransactionWithWalletResponse._();
  @$core.override
  SignRawTransactionWithWalletResponse createEmptyInstance() => SignRawTransactionWithWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static SignRawTransactionWithWalletResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignRawTransactionWithWalletResponse>(
          SignRawTransactionWithWalletResponse.$_createMessage);
  static SignRawTransactionWithWalletResponse? _defaultInstance;

  /// The hex-encoded raw transaction with signature(s)
  @$pb.TagNumber(1)
  $core.String get hex => $_getSZ(0);
  @$pb.TagNumber(1)
  set hex($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearHex() => $_clearField(1);

  /// If the transaction has a complete set of signatures
  @$pb.TagNumber(2)
  $core.bool get complete => $_getBF(1);
  @$pb.TagNumber(2)
  set complete($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasComplete() => $_has(1);
  @$pb.TagNumber(2)
  void clearComplete() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<SignRawTransactionWithWalletResponse_Error> get errors => $_getList(2);
}

class BitcoinServiceApi {
  final $pb.RpcClient _client;

  BitcoinServiceApi(this._client);

  $async.Future<GetBlockchainInfoResponse> getBlockchainInfo(
          $pb.ClientContext? ctx, GetBlockchainInfoRequest request) =>
      _client.invoke<GetBlockchainInfoResponse>(
          ctx, 'BitcoinService', 'GetBlockchainInfo', request, GetBlockchainInfoResponse());
  $async.Future<GetPeerInfoResponse> getPeerInfo($pb.ClientContext? ctx, GetPeerInfoRequest request) =>
      _client.invoke<GetPeerInfoResponse>(ctx, 'BitcoinService', 'GetPeerInfo', request, GetPeerInfoResponse());
  $async.Future<GetNetworkInfoResponse> getNetworkInfo($pb.ClientContext? ctx, GetNetworkInfoRequest request) => _client
      .invoke<GetNetworkInfoResponse>(ctx, 'BitcoinService', 'GetNetworkInfo', request, GetNetworkInfoResponse());
  $async.Future<GetNetTotalsResponse> getNetTotals($pb.ClientContext? ctx, GetNetTotalsRequest request) =>
      _client.invoke<GetNetTotalsResponse>(ctx, 'BitcoinService', 'GetNetTotals', request, GetNetTotalsResponse());

  /// Fetches in-wallet transactions
  $async.Future<GetTransactionResponse> getTransaction($pb.ClientContext? ctx, GetTransactionRequest request) => _client
      .invoke<GetTransactionResponse>(ctx, 'BitcoinService', 'GetTransaction', request, GetTransactionResponse());
  $async.Future<ListSinceBlockResponse> listSinceBlock($pb.ClientContext? ctx, ListSinceBlockRequest request) => _client
      .invoke<ListSinceBlockResponse>(ctx, 'BitcoinService', 'ListSinceBlock', request, ListSinceBlockResponse());

  /// Wallet stuff
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, GetNewAddressRequest request) =>
      _client.invoke<GetNewAddressResponse>(ctx, 'BitcoinService', 'GetNewAddress', request, GetNewAddressResponse());
  $async.Future<GetWalletInfoResponse> getWalletInfo($pb.ClientContext? ctx, GetWalletInfoRequest request) =>
      _client.invoke<GetWalletInfoResponse>(ctx, 'BitcoinService', 'GetWalletInfo', request, GetWalletInfoResponse());
  $async.Future<GetBalancesResponse> getBalances($pb.ClientContext? ctx, GetBalancesRequest request) =>
      _client.invoke<GetBalancesResponse>(ctx, 'BitcoinService', 'GetBalances', request, GetBalancesResponse());
  $async.Future<SendResponse> send($pb.ClientContext? ctx, SendRequest request) =>
      _client.invoke<SendResponse>(ctx, 'BitcoinService', 'Send', request, SendResponse());
  $async.Future<SendToAddressResponse> sendToAddress($pb.ClientContext? ctx, SendToAddressRequest request) =>
      _client.invoke<SendToAddressResponse>(ctx, 'BitcoinService', 'SendToAddress', request, SendToAddressResponse());
  $async.Future<BumpFeeResponse> bumpFee($pb.ClientContext? ctx, BumpFeeRequest request) =>
      _client.invoke<BumpFeeResponse>(ctx, 'BitcoinService', 'BumpFee', request, BumpFeeResponse());
  $async.Future<EstimateSmartFeeResponse> estimateSmartFee($pb.ClientContext? ctx, EstimateSmartFeeRequest request) =>
      _client.invoke<EstimateSmartFeeResponse>(
          ctx, 'BitcoinService', 'EstimateSmartFee', request, EstimateSmartFeeResponse());

  /// Import a descriptor. If importing a watch-only descriptor, the wallet itself needs
  /// to be watch-only as well. The descriptor also needs to be normalized, with a
  /// checksum. This can be obtained by running it through GetDescriptorInfo.
  $async.Future<ImportDescriptorsResponse> importDescriptors(
          $pb.ClientContext? ctx, ImportDescriptorsRequest request) =>
      _client.invoke<ImportDescriptorsResponse>(
          ctx, 'BitcoinService', 'ImportDescriptors', request, ImportDescriptorsResponse());
  $async.Future<ListDescriptorsResponse> listDescriptors($pb.ClientContext? ctx, ListDescriptorsRequest request) =>
      _client.invoke<ListDescriptorsResponse>(
          ctx, 'BitcoinService', 'ListDescriptors', request, ListDescriptorsResponse());
  $async.Future<ListWalletsResponse> listWallets($pb.ClientContext? ctx, $3.Empty request) =>
      _client.invoke<ListWalletsResponse>(ctx, 'BitcoinService', 'ListWallets', request, ListWalletsResponse());
  $async.Future<ListUnspentResponse> listUnspent($pb.ClientContext? ctx, ListUnspentRequest request) =>
      _client.invoke<ListUnspentResponse>(ctx, 'BitcoinService', 'ListUnspent', request, ListUnspentResponse());
  $async.Future<ListTransactionsResponse> listTransactions($pb.ClientContext? ctx, ListTransactionsRequest request) =>
      _client.invoke<ListTransactionsResponse>(
          ctx, 'BitcoinService', 'ListTransactions', request, ListTransactionsResponse());
  $async.Future<GetDescriptorInfoResponse> getDescriptorInfo(
          $pb.ClientContext? ctx, GetDescriptorInfoRequest request) =>
      _client.invoke<GetDescriptorInfoResponse>(
          ctx, 'BitcoinService', 'GetDescriptorInfo', request, GetDescriptorInfoResponse());
  $async.Future<GetAddressInfoResponse> getAddressInfo($pb.ClientContext? ctx, GetAddressInfoRequest request) => _client
      .invoke<GetAddressInfoResponse>(ctx, 'BitcoinService', 'GetAddressInfo', request, GetAddressInfoResponse());

  /// Mempool stuff
  $async.Future<GetRawMempoolResponse> getRawMempool($pb.ClientContext? ctx, GetRawMempoolRequest request) =>
      _client.invoke<GetRawMempoolResponse>(ctx, 'BitcoinService', 'GetRawMempool', request, GetRawMempoolResponse());

  /// Raw TX stuff
  $async.Future<GetRawTransactionResponse> getRawTransaction(
          $pb.ClientContext? ctx, GetRawTransactionRequest request) =>
      _client.invoke<GetRawTransactionResponse>(
          ctx, 'BitcoinService', 'GetRawTransaction', request, GetRawTransactionResponse());
  $async.Future<DecodeRawTransactionResponse> decodeRawTransaction(
          $pb.ClientContext? ctx, DecodeRawTransactionRequest request) =>
      _client.invoke<DecodeRawTransactionResponse>(
          ctx, 'BitcoinService', 'DecodeRawTransaction', request, DecodeRawTransactionResponse());
  $async.Future<CreateRawTransactionResponse> createRawTransaction(
          $pb.ClientContext? ctx, CreateRawTransactionRequest request) =>
      _client.invoke<CreateRawTransactionResponse>(
          ctx, 'BitcoinService', 'CreateRawTransaction', request, CreateRawTransactionResponse());
  $async.Future<SendRawTransactionResponse> sendRawTransaction(
          $pb.ClientContext? ctx, SendRawTransactionRequest request) =>
      _client.invoke<SendRawTransactionResponse>(
          ctx, 'BitcoinService', 'SendRawTransaction', request, SendRawTransactionResponse());
  $async.Future<SignRawTransactionWithWalletResponse> signRawTransactionWithWallet(
          $pb.ClientContext? ctx, SignRawTransactionWithWalletRequest request) =>
      _client.invoke<SignRawTransactionWithWalletResponse>(
          ctx, 'BitcoinService', 'SignRawTransactionWithWallet', request, SignRawTransactionWithWalletResponse());
  $async.Future<GetBlockResponse> getBlock($pb.ClientContext? ctx, GetBlockRequest request) =>
      _client.invoke<GetBlockResponse>(ctx, 'BitcoinService', 'GetBlock', request, GetBlockResponse());
  $async.Future<GetBlockHashResponse> getBlockHash($pb.ClientContext? ctx, GetBlockHashRequest request) =>
      _client.invoke<GetBlockHashResponse>(ctx, 'BitcoinService', 'GetBlockHash', request, GetBlockHashResponse());

  /// Wallet management
  $async.Future<CreateWalletResponse> createWallet($pb.ClientContext? ctx, CreateWalletRequest request) =>
      _client.invoke<CreateWalletResponse>(ctx, 'BitcoinService', 'CreateWallet', request, CreateWalletResponse());
  $async.Future<LoadWalletResponse> loadWallet($pb.ClientContext? ctx, LoadWalletRequest request) =>
      _client.invoke<LoadWalletResponse>(ctx, 'BitcoinService', 'LoadWallet', request, LoadWalletResponse());
  $async.Future<BackupWalletResponse> backupWallet($pb.ClientContext? ctx, BackupWalletRequest request) =>
      _client.invoke<BackupWalletResponse>(ctx, 'BitcoinService', 'BackupWallet', request, BackupWalletResponse());
  $async.Future<UnloadWalletResponse> unloadWallet($pb.ClientContext? ctx, UnloadWalletRequest request) =>
      _client.invoke<UnloadWalletResponse>(ctx, 'BitcoinService', 'UnloadWallet', request, UnloadWalletResponse());
  $async.Future<RescanBlockchainResponse> rescanBlockchain($pb.ClientContext? ctx, RescanBlockchainRequest request) =>
      _client.invoke<RescanBlockchainResponse>(
          ctx, 'BitcoinService', 'RescanBlockchain', request, RescanBlockchainResponse());
  $async.Future<AbortRescanResponse> abortRescan($pb.ClientContext? ctx, AbortRescanRequest request) =>
      _client.invoke<AbortRescanResponse>(ctx, 'BitcoinService', 'AbortRescan', request, AbortRescanResponse());

  /// Key/Address management
  $async.Future<KeyPoolRefillResponse> keyPoolRefill($pb.ClientContext? ctx, KeyPoolRefillRequest request) =>
      _client.invoke<KeyPoolRefillResponse>(ctx, 'BitcoinService', 'KeyPoolRefill', request, KeyPoolRefillResponse());

  /// Account operations
  $async.Future<GetAccountResponse> getAccount($pb.ClientContext? ctx, GetAccountRequest request) =>
      _client.invoke<GetAccountResponse>(ctx, 'BitcoinService', 'GetAccount', request, GetAccountResponse());
  $async.Future<SetAccountResponse> setAccount($pb.ClientContext? ctx, SetAccountRequest request) =>
      _client.invoke<SetAccountResponse>(ctx, 'BitcoinService', 'SetAccount', request, SetAccountResponse());
  $async.Future<GetAddressesByAccountResponse> getAddressesByAccount(
          $pb.ClientContext? ctx, GetAddressesByAccountRequest request) =>
      _client.invoke<GetAddressesByAccountResponse>(
          ctx, 'BitcoinService', 'GetAddressesByAccount', request, GetAddressesByAccountResponse());
  $async.Future<ListAccountsResponse> listAccounts($pb.ClientContext? ctx, ListAccountsRequest request) =>
      _client.invoke<ListAccountsResponse>(ctx, 'BitcoinService', 'ListAccounts', request, ListAccountsResponse());

  /// Multi-sig operations
  $async.Future<CreateMultisigResponse> createMultisig($pb.ClientContext? ctx, CreateMultisigRequest request) => _client
      .invoke<CreateMultisigResponse>(ctx, 'BitcoinService', 'CreateMultisig', request, CreateMultisigResponse());

  /// PSBT handling
  $async.Future<CreatePsbtResponse> createPsbt($pb.ClientContext? ctx, CreatePsbtRequest request) =>
      _client.invoke<CreatePsbtResponse>(ctx, 'BitcoinService', 'CreatePsbt', request, CreatePsbtResponse());
  $async.Future<DecodePsbtResponse> decodePsbt($pb.ClientContext? ctx, DecodePsbtRequest request) =>
      _client.invoke<DecodePsbtResponse>(ctx, 'BitcoinService', 'DecodePsbt', request, DecodePsbtResponse());
  $async.Future<AnalyzePsbtResponse> analyzePsbt($pb.ClientContext? ctx, AnalyzePsbtRequest request) =>
      _client.invoke<AnalyzePsbtResponse>(ctx, 'BitcoinService', 'AnalyzePsbt', request, AnalyzePsbtResponse());
  $async.Future<CombinePsbtResponse> combinePsbt($pb.ClientContext? ctx, CombinePsbtRequest request) =>
      _client.invoke<CombinePsbtResponse>(ctx, 'BitcoinService', 'CombinePsbt', request, CombinePsbtResponse());
  $async.Future<UtxoUpdatePsbtResponse> utxoUpdatePsbt($pb.ClientContext? ctx, UtxoUpdatePsbtRequest request) => _client
      .invoke<UtxoUpdatePsbtResponse>(ctx, 'BitcoinService', 'UtxoUpdatePsbt', request, UtxoUpdatePsbtResponse());
  $async.Future<JoinPsbtsResponse> joinPsbts($pb.ClientContext? ctx, JoinPsbtsRequest request) =>
      _client.invoke<JoinPsbtsResponse>(ctx, 'BitcoinService', 'JoinPsbts', request, JoinPsbtsResponse());

  /// Transaction misc
  $async.Future<TestMempoolAcceptResponse> testMempoolAccept(
          $pb.ClientContext? ctx, TestMempoolAcceptRequest request) =>
      _client.invoke<TestMempoolAcceptResponse>(
          ctx, 'BitcoinService', 'TestMempoolAccept', request, TestMempoolAcceptResponse());

  /// Returns information about the active ZeroMQ notifications.
  $async.Future<GetZmqNotificationsResponse> getZmqNotifications($pb.ClientContext? ctx, $3.Empty request) =>
      _client.invoke<GetZmqNotificationsResponse>(
          ctx, 'BitcoinService', 'GetZmqNotifications', request, GetZmqNotificationsResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
