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

import '../../../google/protobuf/empty.pb.dart' as $2;
import '../../../google/protobuf/timestamp.pb.dart' as $0;
import '../../../google/protobuf/wrappers.pb.dart' as $1;
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
    $core.int? syncedBlocks,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (addr != null) {
      $result.addr = addr;
    }
    if (syncedBlocks != null) {
      $result.syncedBlocks = syncedBlocks;
    }
    return $result;
  }
  Peer._() : super();
  factory Peer.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Peer.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Peer', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'addr')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'syncedBlocks', $pb.PbFieldType.O3)
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

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get addr => $_getSZ(1);
  @$pb.TagNumber(2)
  set addr($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddr() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddr() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get syncedBlocks => $_getIZ(2);
  @$pb.TagNumber(3)
  set syncedBlocks($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSyncedBlocks() => $_has(2);
  @$pb.TagNumber(3)
  void clearSyncedBlocks() => clearField(3);
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

class Input extends $pb.GeneratedMessage {
  factory Input({
    $core.String? txid,
    $core.int? vout,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    return $result;
  }
  Input._() : super();
  factory Input.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Input.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Input', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
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
}

class ScriptPubKey extends $pb.GeneratedMessage {
  factory ScriptPubKey({
    $core.String? type,
    $core.String? address,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  ScriptPubKey._() : super();
  factory ScriptPubKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ScriptPubKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScriptPubKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'address')
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
}

class Output extends $pb.GeneratedMessage {
  factory Output({
    $core.double? amount,
    $core.int? n,
    ScriptPubKey? scriptPubKey,
  }) {
    final $result = create();
    if (amount != null) {
      $result.amount = amount;
    }
    if (n != null) {
      $result.n = n;
    }
    if (scriptPubKey != null) {
      $result.scriptPubKey = scriptPubKey;
    }
    return $result;
  }
  Output._() : super();
  factory Output.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Output.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Output', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'n', $pb.PbFieldType.OU3)
    ..aOM<ScriptPubKey>(3, _omitFieldNames ? '' : 'scriptPubKey', subBuilder: ScriptPubKey.create)
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

  /// The output index
  @$pb.TagNumber(2)
  $core.int get n => $_getIZ(1);
  @$pb.TagNumber(2)
  set n($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasN() => $_has(1);
  @$pb.TagNumber(2)
  void clearN() => clearField(2);

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
}

class SendRequest extends $pb.GeneratedMessage {
  factory SendRequest({
    $core.Map<$core.String, $core.double>? destinations,
    $core.int? confTarget,
    $core.String? wallet,
    $core.bool? includeUnsafe,
    $core.Iterable<$core.String>? subtractFeeFromOutputs,
    $1.BoolValue? addToWallet,
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
    ..aOM<$1.BoolValue>(6, _omitFieldNames ? '' : 'addToWallet', subBuilder: $1.BoolValue.create)
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
  $1.BoolValue get addToWallet => $_getN(5);
  @$pb.TagNumber(6)
  set addToWallet($1.BoolValue v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasAddToWallet() => $_has(5);
  @$pb.TagNumber(6)
  void clearAddToWallet() => clearField(6);
  @$pb.TagNumber(6)
  $1.BoolValue ensureAddToWallet() => $_ensure(5);

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
  }) {
    final $result = create();
    if (hash != null) {
      $result.hash = hash;
    }
    if (verbosity != null) {
      $result.verbosity = verbosity;
    }
    return $result;
  }
  GetBlockRequest._() : super();
  factory GetBlockRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoin.bitcoind.v1alpha'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..e<GetBlockRequest_Verbosity>(2, _omitFieldNames ? '' : 'verbosity', $pb.PbFieldType.OE, defaultOrMaker: GetBlockRequest_Verbosity.VERBOSITY_UNSPECIFIED, valueOf: GetBlockRequest_Verbosity.valueOf, enumValues: GetBlockRequest_Verbosity.values)
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
  $async.Future<ListWalletsResponse> listWallets($pb.ClientContext? ctx, $2.Empty request) =>
    _client.invoke<ListWalletsResponse>(ctx, 'BitcoinService', 'ListWallets', request, ListWalletsResponse())
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
  $async.Future<GetBlockResponse> getBlock($pb.ClientContext? ctx, GetBlockRequest request) =>
    _client.invoke<GetBlockResponse>(ctx, 'BitcoinService', 'GetBlock', request, GetBlockResponse())
  ;
  $async.Future<GetBlockHashResponse> getBlockHash($pb.ClientContext? ctx, GetBlockHashRequest request) =>
    _client.invoke<GetBlockHashResponse>(ctx, 'BitcoinService', 'GetBlockHash', request, GetBlockHashResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
