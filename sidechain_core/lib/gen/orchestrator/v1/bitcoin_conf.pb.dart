// This is a generated file - do not edit.
//
// Generated from orchestrator/v1/bitcoin_conf.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'bitcoin_conf.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'bitcoin_conf.pbenum.dart';

class GetBitcoinConfigRequest extends $pb.GeneratedMessage {
  factory GetBitcoinConfigRequest() => GetBitcoinConfigRequest._();

  GetBitcoinConfigRequest._();

  factory GetBitcoinConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitcoinConfigRequest()..mergeFromBuffer(data, registry);
  factory GetBitcoinConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitcoinConfigRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBitcoinConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetBitcoinConfigRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitcoinConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitcoinConfigRequest copyWith(void Function(GetBitcoinConfigRequest) updates) =>
      super.copyWith((message) => updates(message as GetBitcoinConfigRequest)) as GetBitcoinConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBitcoinConfigRequest() / GetBitcoinConfigRequest.new instead')
  static GetBitcoinConfigRequest create() => GetBitcoinConfigRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBitcoinConfigRequest._();
  @$core.override
  GetBitcoinConfigRequest createEmptyInstance() => GetBitcoinConfigRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBitcoinConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBitcoinConfigRequest>(GetBitcoinConfigRequest.$_createMessage);
  static GetBitcoinConfigRequest? _defaultInstance;
}

class GetBitcoinConfigResponse extends $pb.GeneratedMessage {
  factory GetBitcoinConfigResponse({
    $core.String? network,
    $core.int? rpcPort,
    $core.bool? hasPrivateConf,
    $core.String? configPath,
    $core.String? detectedDataDir,
    $core.String? configContent,
    $core.bool? networkSupportsSidechains,
    $core.bool? isDemoMode,
    $core.String? rpcUser,
    $core.String? rpcPassword,
    $core.String? defaultDatadir,
    $core.String? ecashDatadir,
    $core.String? ecashNetworkId,
    $core.bool? mustSelectDatadir,
    $core.String? ecashEsploraUrl,
    $core.String? ecashExplorerHost,
  }) {
    final result = GetBitcoinConfigResponse._();
    if (network != null) result.network = network;
    if (rpcPort != null) result.rpcPort = rpcPort;
    if (hasPrivateConf != null) result.hasPrivateConf = hasPrivateConf;
    if (configPath != null) result.configPath = configPath;
    if (detectedDataDir != null) result.detectedDataDir = detectedDataDir;
    if (configContent != null) result.configContent = configContent;
    if (networkSupportsSidechains != null) result.networkSupportsSidechains = networkSupportsSidechains;
    if (isDemoMode != null) result.isDemoMode = isDemoMode;
    if (rpcUser != null) result.rpcUser = rpcUser;
    if (rpcPassword != null) result.rpcPassword = rpcPassword;
    if (defaultDatadir != null) result.defaultDatadir = defaultDatadir;
    if (ecashDatadir != null) result.ecashDatadir = ecashDatadir;
    if (ecashNetworkId != null) result.ecashNetworkId = ecashNetworkId;
    if (mustSelectDatadir != null) result.mustSelectDatadir = mustSelectDatadir;
    if (ecashEsploraUrl != null) result.ecashEsploraUrl = ecashEsploraUrl;
    if (ecashExplorerHost != null) result.ecashExplorerHost = ecashExplorerHost;
    return result;
  }

  GetBitcoinConfigResponse._();

  factory GetBitcoinConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitcoinConfigResponse()..mergeFromBuffer(data, registry);
  factory GetBitcoinConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitcoinConfigResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBitcoinConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetBitcoinConfigResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'network')
    ..aI(2, _omitFieldNames ? '' : 'rpcPort')
    ..aOB(3, _omitFieldNames ? '' : 'hasPrivateConf')
    ..aOS(4, _omitFieldNames ? '' : 'configPath')
    ..aOS(5, _omitFieldNames ? '' : 'detectedDataDir')
    ..aOS(6, _omitFieldNames ? '' : 'configContent')
    ..aOB(7, _omitFieldNames ? '' : 'networkSupportsSidechains')
    ..aOB(8, _omitFieldNames ? '' : 'isDemoMode')
    ..aOS(9, _omitFieldNames ? '' : 'rpcUser')
    ..aOS(10, _omitFieldNames ? '' : 'rpcPassword')
    ..aOS(11, _omitFieldNames ? '' : 'defaultDatadir')
    ..aOS(13, _omitFieldNames ? '' : 'ecashDatadir')
    ..aOS(14, _omitFieldNames ? '' : 'ecashNetworkId')
    ..aOB(15, _omitFieldNames ? '' : 'mustSelectDatadir')
    ..aOS(16, _omitFieldNames ? '' : 'ecashEsploraUrl')
    ..aOS(17, _omitFieldNames ? '' : 'ecashExplorerHost')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitcoinConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitcoinConfigResponse copyWith(void Function(GetBitcoinConfigResponse) updates) =>
      super.copyWith((message) => updates(message as GetBitcoinConfigResponse)) as GetBitcoinConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBitcoinConfigResponse() / GetBitcoinConfigResponse.new instead')
  static GetBitcoinConfigResponse create() => GetBitcoinConfigResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBitcoinConfigResponse._();
  @$core.override
  GetBitcoinConfigResponse createEmptyInstance() => GetBitcoinConfigResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBitcoinConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBitcoinConfigResponse>(GetBitcoinConfigResponse.$_createMessage);
  static GetBitcoinConfigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get network => $_getSZ(0);
  @$pb.TagNumber(1)
  set network($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNetwork() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetwork() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get rpcPort => $_getIZ(1);
  @$pb.TagNumber(2)
  set rpcPort($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRpcPort() => $_has(1);
  @$pb.TagNumber(2)
  void clearRpcPort() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get hasPrivateConf => $_getBF(2);
  @$pb.TagNumber(3)
  set hasPrivateConf($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHasPrivateConf() => $_has(2);
  @$pb.TagNumber(3)
  void clearHasPrivateConf() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get configPath => $_getSZ(3);
  @$pb.TagNumber(4)
  set configPath($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfigPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfigPath() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get detectedDataDir => $_getSZ(4);
  @$pb.TagNumber(5)
  set detectedDataDir($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDetectedDataDir() => $_has(4);
  @$pb.TagNumber(5)
  void clearDetectedDataDir() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get configContent => $_getSZ(5);
  @$pb.TagNumber(6)
  set configContent($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasConfigContent() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfigContent() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get networkSupportsSidechains => $_getBF(6);
  @$pb.TagNumber(7)
  set networkSupportsSidechains($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNetworkSupportsSidechains() => $_has(6);
  @$pb.TagNumber(7)
  void clearNetworkSupportsSidechains() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isDemoMode => $_getBF(7);
  @$pb.TagNumber(8)
  set isDemoMode($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsDemoMode() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsDemoMode() => $_clearField(8);

  /// RPC creds — exposed so localhost callers (the btc-buf proxy, future tools) that
  /// need raw bitcoind JSON-RPC can dial it without re-parsing config_content.
  /// Prefer the hosted BitcoinService proxy when possible.
  @$pb.TagNumber(9)
  $core.String get rpcUser => $_getSZ(8);
  @$pb.TagNumber(9)
  set rpcUser($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRpcUser() => $_has(8);
  @$pb.TagNumber(9)
  void clearRpcUser() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get rpcPassword => $_getSZ(9);
  @$pb.TagNumber(10)
  set rpcPassword($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRpcPassword() => $_has(9);
  @$pb.TagNumber(10)
  void clearRpcPassword() => $_clearField(10);

  /// Per-group datadir snapshots. The active group's value mirrors
  /// detected_data_dir; the inactive group's value is the path that will be
  /// restored on the next swap into that group. Empty = no path stored.
  @$pb.TagNumber(11)
  $core.String get defaultDatadir => $_getSZ(10);
  @$pb.TagNumber(11)
  set defaultDatadir($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDefaultDatadir() => $_has(10);
  @$pb.TagNumber(11)
  void clearDefaultDatadir() => $_clearField(11);

  @$pb.TagNumber(13)
  $core.String get ecashDatadir => $_getSZ(11);
  @$pb.TagNumber(13)
  set ecashDatadir($core.String value) => $_setString(11, value);
  @$pb.TagNumber(13)
  $core.bool hasEcashDatadir() => $_has(11);
  @$pb.TagNumber(13)
  void clearEcashDatadir() => $_clearField(13);

  /// Live eCash network id ("betanet").
  @$pb.TagNumber(14)
  $core.String get ecashNetworkId => $_getSZ(12);
  @$pb.TagNumber(14)
  set ecashNetworkId($core.String value) => $_setString(12, value);
  @$pb.TagNumber(14)
  $core.bool hasEcashNetworkId() => $_has(12);
  @$pb.TagNumber(14)
  void clearEcashNetworkId() => $_clearField(14);

  /// True when the current network and wallet backend need a datadir the user
  /// has not chosen yet. Drives the boot-time prompt.
  @$pb.TagNumber(15)
  $core.bool get mustSelectDatadir => $_getBF(13);
  @$pb.TagNumber(15)
  set mustSelectDatadir($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(15)
  $core.bool hasMustSelectDatadir() => $_has(13);
  @$pb.TagNumber(15)
  void clearMustSelectDatadir() => $_clearField(15);

  /// Esplora base URL the catalog publishes for the live eCash network, empty
  /// when it publishes none.
  @$pb.TagNumber(16)
  $core.String get ecashEsploraUrl => $_getSZ(14);
  @$pb.TagNumber(16)
  set ecashEsploraUrl($core.String value) => $_setString(14, value);
  @$pb.TagNumber(16)
  $core.bool hasEcashEsploraUrl() => $_has(14);
  @$pb.TagNumber(16)
  void clearEcashEsploraUrl() => $_clearField(16);

  /// Explorer host the catalog publishes for the live eCash network, empty
  /// when it publishes none.
  @$pb.TagNumber(17)
  $core.String get ecashExplorerHost => $_getSZ(15);
  @$pb.TagNumber(17)
  set ecashExplorerHost($core.String value) => $_setString(15, value);
  @$pb.TagNumber(17)
  $core.bool hasEcashExplorerHost() => $_has(15);
  @$pb.TagNumber(17)
  void clearEcashExplorerHost() => $_clearField(17);
}

class ListNetworksRequest extends $pb.GeneratedMessage {
  factory ListNetworksRequest() => ListNetworksRequest._();

  ListNetworksRequest._();

  factory ListNetworksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListNetworksRequest()..mergeFromBuffer(data, registry);
  factory ListNetworksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListNetworksRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListNetworksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ListNetworksRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListNetworksRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListNetworksRequest copyWith(void Function(ListNetworksRequest) updates) =>
      super.copyWith((message) => updates(message as ListNetworksRequest)) as ListNetworksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListNetworksRequest() / ListNetworksRequest.new instead')
  static ListNetworksRequest create() => ListNetworksRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListNetworksRequest._();
  @$core.override
  ListNetworksRequest createEmptyInstance() => ListNetworksRequest._();
  @$core.pragma('dart2js:noInline')
  static ListNetworksRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListNetworksRequest>(ListNetworksRequest.$_createMessage);
  static ListNetworksRequest? _defaultInstance;
}

/// NetworkOption is one row of the network picker.
class NetworkOption extends $pb.GeneratedMessage {
  factory NetworkOption({
    $core.String? id,
    $core.String? displayName,
    $core.String? network,
    $core.bool? isCurrent,
  }) {
    final result = NetworkOption._();
    if (id != null) result.id = id;
    if (displayName != null) result.displayName = displayName;
    if (network != null) result.network = network;
    if (isCurrent != null) result.isCurrent = isCurrent;
    return result;
  }

  NetworkOption._();

  factory NetworkOption.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NetworkOption()..mergeFromBuffer(data, registry);
  factory NetworkOption.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NetworkOption()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NetworkOption',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: NetworkOption.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOS(3, _omitFieldNames ? '' : 'network')
    ..aOB(4, _omitFieldNames ? '' : 'isCurrent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkOption clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkOption copyWith(void Function(NetworkOption) updates) =>
      super.copyWith((message) => updates(message as NetworkOption)) as NetworkOption;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use NetworkOption() / NetworkOption.new instead')
  static NetworkOption create() => NetworkOption._();
  static $pb.GeneratedMessage $_createMessage() => NetworkOption._();
  @$core.override
  NetworkOption createEmptyInstance() => NetworkOption._();
  @$core.pragma('dart2js:noInline')
  static NetworkOption getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NetworkOption>(NetworkOption.$_createMessage);
  static NetworkOption? _defaultInstance;

  /// Catalog id ("betanet", "bitcoin"), or "regtest" for the local-only row.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// Name to show the user ("Betanet").
  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  /// Slot this row runs in: mainnet | signet | ecash | regtest.
  @$pb.TagNumber(3)
  $core.String get network => $_getSZ(2);
  @$pb.TagNumber(3)
  set network($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNetwork() => $_has(2);
  @$pb.TagNumber(3)
  void clearNetwork() => $_clearField(3);

  /// True for the network this install runs right now.
  @$pb.TagNumber(4)
  $core.bool get isCurrent => $_getBF(3);
  @$pb.TagNumber(4)
  set isCurrent($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsCurrent() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsCurrent() => $_clearField(4);
}

class ListNetworksResponse extends $pb.GeneratedMessage {
  factory ListNetworksResponse({
    $core.Iterable<NetworkOption>? networks,
  }) {
    final result = ListNetworksResponse._();
    if (networks != null) result.networks.addAll(networks);
    return result;
  }

  ListNetworksResponse._();

  factory ListNetworksResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListNetworksResponse()..mergeFromBuffer(data, registry);
  factory ListNetworksResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListNetworksResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListNetworksResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ListNetworksResponse.$_createMessage)
    ..pPM<NetworkOption>(1, _omitFieldNames ? '' : 'networks', subBuilder: NetworkOption.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListNetworksResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListNetworksResponse copyWith(void Function(ListNetworksResponse) updates) =>
      super.copyWith((message) => updates(message as ListNetworksResponse)) as ListNetworksResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListNetworksResponse() / ListNetworksResponse.new instead')
  static ListNetworksResponse create() => ListNetworksResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListNetworksResponse._();
  @$core.override
  ListNetworksResponse createEmptyInstance() => ListNetworksResponse._();
  @$core.pragma('dart2js:noInline')
  static ListNetworksResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListNetworksResponse>(ListNetworksResponse.$_createMessage);
  static ListNetworksResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<NetworkOption> get networks => $_getList(0);
}

class PlanECashSwitchRequest extends $pb.GeneratedMessage {
  factory PlanECashSwitchRequest({
    $core.String? networkId,
  }) {
    final result = PlanECashSwitchRequest._();
    if (networkId != null) result.networkId = networkId;
    return result;
  }

  PlanECashSwitchRequest._();

  factory PlanECashSwitchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PlanECashSwitchRequest()..mergeFromBuffer(data, registry);
  factory PlanECashSwitchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PlanECashSwitchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PlanECashSwitchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: PlanECashSwitchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'networkId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlanECashSwitchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlanECashSwitchRequest copyWith(void Function(PlanECashSwitchRequest) updates) =>
      super.copyWith((message) => updates(message as PlanECashSwitchRequest)) as PlanECashSwitchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PlanECashSwitchRequest() / PlanECashSwitchRequest.new instead')
  static PlanECashSwitchRequest create() => PlanECashSwitchRequest._();
  static $pb.GeneratedMessage $_createMessage() => PlanECashSwitchRequest._();
  @$core.override
  PlanECashSwitchRequest createEmptyInstance() => PlanECashSwitchRequest._();
  @$core.pragma('dart2js:noInline')
  static PlanECashSwitchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PlanECashSwitchRequest>(PlanECashSwitchRequest.$_createMessage);
  static PlanECashSwitchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get networkId => $_getSZ(0);
  @$pb.TagNumber(1)
  set networkId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNetworkId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetworkId() => $_clearField(1);
}

class PlanECashSwitchResponse extends $pb.GeneratedMessage {
  factory PlanECashSwitchResponse({
    $core.String? fromId,
    $core.String? toId,
    $core.int? rewindHeight,
    $core.bool? needsRollback,
    $core.bool? blocked,
    $core.bool? hasChainData,
    $core.String? chainId,
  }) {
    final result = PlanECashSwitchResponse._();
    if (fromId != null) result.fromId = fromId;
    if (toId != null) result.toId = toId;
    if (rewindHeight != null) result.rewindHeight = rewindHeight;
    if (needsRollback != null) result.needsRollback = needsRollback;
    if (blocked != null) result.blocked = blocked;
    if (hasChainData != null) result.hasChainData = hasChainData;
    if (chainId != null) result.chainId = chainId;
    return result;
  }

  PlanECashSwitchResponse._();

  factory PlanECashSwitchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PlanECashSwitchResponse()..mergeFromBuffer(data, registry);
  factory PlanECashSwitchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PlanECashSwitchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PlanECashSwitchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: PlanECashSwitchResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'fromId')
    ..aOS(2, _omitFieldNames ? '' : 'toId')
    ..aI(3, _omitFieldNames ? '' : 'rewindHeight', fieldType: $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'needsRollback')
    ..aOB(5, _omitFieldNames ? '' : 'blocked')
    ..aOB(6, _omitFieldNames ? '' : 'hasChainData')
    ..aOS(7, _omitFieldNames ? '' : 'chainId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlanECashSwitchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlanECashSwitchResponse copyWith(void Function(PlanECashSwitchResponse) updates) =>
      super.copyWith((message) => updates(message as PlanECashSwitchResponse)) as PlanECashSwitchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PlanECashSwitchResponse() / PlanECashSwitchResponse.new instead')
  static PlanECashSwitchResponse create() => PlanECashSwitchResponse._();
  static $pb.GeneratedMessage $_createMessage() => PlanECashSwitchResponse._();
  @$core.override
  PlanECashSwitchResponse createEmptyInstance() => PlanECashSwitchResponse._();
  @$core.pragma('dart2js:noInline')
  static PlanECashSwitchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PlanECashSwitchResponse>(PlanECashSwitchResponse.$_createMessage);
  static PlanECashSwitchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fromId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fromId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get toId => $_getSZ(1);
  @$pb.TagNumber(2)
  set toId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToId() => $_has(1);
  @$pb.TagNumber(2)
  void clearToId() => $_clearField(2);

  /// Block the switch drops, one below the lower fork height. Core parks under
  /// it and follows the new network from there. Zero when nothing is dropped.
  @$pb.TagNumber(3)
  $core.int get rewindHeight => $_getIZ(2);
  @$pb.TagNumber(3)
  set rewindHeight($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRewindHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearRewindHeight() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get needsRollback => $_getBF(3);
  @$pb.TagNumber(4)
  set needsRollback($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNeedsRollback() => $_has(3);
  @$pb.TagNumber(4)
  void clearNeedsRollback() => $_clearField(4);

  /// True when the switch cannot run: neither network publishes the fork height
  /// that says where the chains part, so no rewind reaches shared history.
  @$pb.TagNumber(5)
  $core.bool get blocked => $_getBF(4);
  @$pb.TagNumber(5)
  set blocked($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBlocked() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlocked() => $_clearField(5);

  /// True when the ECX data directory has chain files.
  @$pb.TagNumber(6)
  $core.bool get hasChainData => $_getBF(5);
  @$pb.TagNumber(6)
  set hasChainData($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHasChainData() => $_has(5);
  @$pb.TagNumber(6)
  void clearHasChainData() => $_clearField(6);

  /// The retained ECX chain ID. Empty when no chain files exist.
  @$pb.TagNumber(7)
  $core.String get chainId => $_getSZ(6);
  @$pb.TagNumber(7)
  set chainId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasChainId() => $_has(6);
  @$pb.TagNumber(7)
  void clearChainId() => $_clearField(7);
}

class TakeNewNetworksRequest extends $pb.GeneratedMessage {
  factory TakeNewNetworksRequest() => TakeNewNetworksRequest._();

  TakeNewNetworksRequest._();

  factory TakeNewNetworksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TakeNewNetworksRequest()..mergeFromBuffer(data, registry);
  factory TakeNewNetworksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TakeNewNetworksRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TakeNewNetworksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: TakeNewNetworksRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TakeNewNetworksRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TakeNewNetworksRequest copyWith(void Function(TakeNewNetworksRequest) updates) =>
      super.copyWith((message) => updates(message as TakeNewNetworksRequest)) as TakeNewNetworksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TakeNewNetworksRequest() / TakeNewNetworksRequest.new instead')
  static TakeNewNetworksRequest create() => TakeNewNetworksRequest._();
  static $pb.GeneratedMessage $_createMessage() => TakeNewNetworksRequest._();
  @$core.override
  TakeNewNetworksRequest createEmptyInstance() => TakeNewNetworksRequest._();
  @$core.pragma('dart2js:noInline')
  static TakeNewNetworksRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TakeNewNetworksRequest>(TakeNewNetworksRequest.$_createMessage);
  static TakeNewNetworksRequest? _defaultInstance;
}

class TakeNewNetworksResponse extends $pb.GeneratedMessage {
  factory TakeNewNetworksResponse({
    $core.Iterable<NetworkOption>? networks,
  }) {
    final result = TakeNewNetworksResponse._();
    if (networks != null) result.networks.addAll(networks);
    return result;
  }

  TakeNewNetworksResponse._();

  factory TakeNewNetworksResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TakeNewNetworksResponse()..mergeFromBuffer(data, registry);
  factory TakeNewNetworksResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TakeNewNetworksResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TakeNewNetworksResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: TakeNewNetworksResponse.$_createMessage)
    ..pPM<NetworkOption>(1, _omitFieldNames ? '' : 'networks', subBuilder: NetworkOption.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TakeNewNetworksResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TakeNewNetworksResponse copyWith(void Function(TakeNewNetworksResponse) updates) =>
      super.copyWith((message) => updates(message as TakeNewNetworksResponse)) as TakeNewNetworksResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TakeNewNetworksResponse() / TakeNewNetworksResponse.new instead')
  static TakeNewNetworksResponse create() => TakeNewNetworksResponse._();
  static $pb.GeneratedMessage $_createMessage() => TakeNewNetworksResponse._();
  @$core.override
  TakeNewNetworksResponse createEmptyInstance() => TakeNewNetworksResponse._();
  @$core.pragma('dart2js:noInline')
  static TakeNewNetworksResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TakeNewNetworksResponse>(TakeNewNetworksResponse.$_createMessage);
  static TakeNewNetworksResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<NetworkOption> get networks => $_getList(0);
}

class PrepareNetworkChangeRequest extends $pb.GeneratedMessage {
  factory PrepareNetworkChangeRequest({
    $core.String? network,
    WalletBackend? walletBackend,
    $core.String? walletId,
  }) {
    final result = PrepareNetworkChangeRequest._();
    if (network != null) result.network = network;
    if (walletBackend != null) result.walletBackend = walletBackend;
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  PrepareNetworkChangeRequest._();

  factory PrepareNetworkChangeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrepareNetworkChangeRequest()..mergeFromBuffer(data, registry);
  factory PrepareNetworkChangeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrepareNetworkChangeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PrepareNetworkChangeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: PrepareNetworkChangeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'network')
    ..aE<WalletBackend>(2, _omitFieldNames ? '' : 'walletBackend', enumValues: WalletBackend.values)
    ..aOS(3, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrepareNetworkChangeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrepareNetworkChangeRequest copyWith(void Function(PrepareNetworkChangeRequest) updates) =>
      super.copyWith((message) => updates(message as PrepareNetworkChangeRequest)) as PrepareNetworkChangeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PrepareNetworkChangeRequest() / PrepareNetworkChangeRequest.new instead')
  static PrepareNetworkChangeRequest create() => PrepareNetworkChangeRequest._();
  static $pb.GeneratedMessage $_createMessage() => PrepareNetworkChangeRequest._();
  @$core.override
  PrepareNetworkChangeRequest createEmptyInstance() => PrepareNetworkChangeRequest._();
  @$core.pragma('dart2js:noInline')
  static PrepareNetworkChangeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PrepareNetworkChangeRequest>(PrepareNetworkChangeRequest.$_createMessage);
  static PrepareNetworkChangeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get network => $_getSZ(0);
  @$pb.TagNumber(1)
  set network($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNetwork() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetwork() => $_clearField(1);

  @$pb.TagNumber(2)
  WalletBackend get walletBackend => $_getN(1);
  @$pb.TagNumber(2)
  set walletBackend(WalletBackend value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletBackend() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletBackend() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get walletId => $_getSZ(2);
  @$pb.TagNumber(3)
  set walletId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWalletId() => $_has(2);
  @$pb.TagNumber(3)
  void clearWalletId() => $_clearField(3);
}

/// NetworkChangePlan is what the change would require. Prepare returns it for
/// the frontend to resolve; apply re-runs it and refuses anything unresolved.
class NetworkChangePlan extends $pb.GeneratedMessage {
  factory NetworkChangePlan({
    $core.String? network,
    WalletBackend? walletBackend,
    $core.bool? mustSelectDatadir,
    $core.String? datadir,
    $core.String? datadirGroup,
    $core.bool? needsLocalBackends,
    $core.bool? impliesChainDownload,
    $core.Iterable<$core.String>? missingBinaries,
    $core.bool? needsBinaryDownload,
    $core.bool? noOp,
  }) {
    final result = NetworkChangePlan._();
    if (network != null) result.network = network;
    if (walletBackend != null) result.walletBackend = walletBackend;
    if (mustSelectDatadir != null) result.mustSelectDatadir = mustSelectDatadir;
    if (datadir != null) result.datadir = datadir;
    if (datadirGroup != null) result.datadirGroup = datadirGroup;
    if (needsLocalBackends != null) result.needsLocalBackends = needsLocalBackends;
    if (impliesChainDownload != null) result.impliesChainDownload = impliesChainDownload;
    if (missingBinaries != null) result.missingBinaries.addAll(missingBinaries);
    if (needsBinaryDownload != null) result.needsBinaryDownload = needsBinaryDownload;
    if (noOp != null) result.noOp = noOp;
    return result;
  }

  NetworkChangePlan._();

  factory NetworkChangePlan.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NetworkChangePlan()..mergeFromBuffer(data, registry);
  factory NetworkChangePlan.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NetworkChangePlan()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NetworkChangePlan',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: NetworkChangePlan.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'network')
    ..aE<WalletBackend>(2, _omitFieldNames ? '' : 'walletBackend', enumValues: WalletBackend.values)
    ..aOB(3, _omitFieldNames ? '' : 'mustSelectDatadir')
    ..aOS(4, _omitFieldNames ? '' : 'datadir')
    ..aOS(5, _omitFieldNames ? '' : 'datadirGroup')
    ..aOB(6, _omitFieldNames ? '' : 'needsLocalBackends')
    ..aOB(7, _omitFieldNames ? '' : 'impliesChainDownload')
    ..pPS(8, _omitFieldNames ? '' : 'missingBinaries')
    ..aOB(9, _omitFieldNames ? '' : 'needsBinaryDownload')
    ..aOB(10, _omitFieldNames ? '' : 'noOp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkChangePlan clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkChangePlan copyWith(void Function(NetworkChangePlan) updates) =>
      super.copyWith((message) => updates(message as NetworkChangePlan)) as NetworkChangePlan;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use NetworkChangePlan() / NetworkChangePlan.new instead')
  static NetworkChangePlan create() => NetworkChangePlan._();
  static $pb.GeneratedMessage $_createMessage() => NetworkChangePlan._();
  @$core.override
  NetworkChangePlan createEmptyInstance() => NetworkChangePlan._();
  @$core.pragma('dart2js:noInline')
  static NetworkChangePlan getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NetworkChangePlan>(NetworkChangePlan.$_createMessage);
  static NetworkChangePlan? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get network => $_getSZ(0);
  @$pb.TagNumber(1)
  set network($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNetwork() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetwork() => $_clearField(1);

  @$pb.TagNumber(2)
  WalletBackend get walletBackend => $_getN(1);
  @$pb.TagNumber(2)
  set walletBackend(WalletBackend value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletBackend() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletBackend() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get mustSelectDatadir => $_getBF(2);
  @$pb.TagNumber(3)
  set mustSelectDatadir($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMustSelectDatadir() => $_has(2);
  @$pb.TagNumber(3)
  void clearMustSelectDatadir() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get datadir => $_getSZ(3);
  @$pb.TagNumber(4)
  set datadir($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDatadir() => $_has(3);
  @$pb.TagNumber(4)
  void clearDatadir() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get datadirGroup => $_getSZ(4);
  @$pb.TagNumber(5)
  set datadirGroup($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDatadirGroup() => $_has(4);
  @$pb.TagNumber(5)
  void clearDatadirGroup() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get needsLocalBackends => $_getBF(5);
  @$pb.TagNumber(6)
  set needsLocalBackends($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNeedsLocalBackends() => $_has(5);
  @$pb.TagNumber(6)
  void clearNeedsLocalBackends() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get impliesChainDownload => $_getBF(6);
  @$pb.TagNumber(7)
  set impliesChainDownload($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasImpliesChainDownload() => $_has(6);
  @$pb.TagNumber(7)
  void clearImpliesChainDownload() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get missingBinaries => $_getList(7);

  @$pb.TagNumber(9)
  $core.bool get needsBinaryDownload => $_getBF(8);
  @$pb.TagNumber(9)
  set needsBinaryDownload($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasNeedsBinaryDownload() => $_has(8);
  @$pb.TagNumber(9)
  void clearNeedsBinaryDownload() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get noOp => $_getBF(9);
  @$pb.TagNumber(10)
  set noOp($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNoOp() => $_has(9);
  @$pb.TagNumber(10)
  void clearNoOp() => $_clearField(10);
}

class SetBitcoinConfigNetworkRequest extends $pb.GeneratedMessage {
  factory SetBitcoinConfigNetworkRequest({
    $core.String? network,
    $core.String? dataDir,
  }) {
    final result = SetBitcoinConfigNetworkRequest._();
    if (network != null) result.network = network;
    if (dataDir != null) result.dataDir = dataDir;
    return result;
  }

  SetBitcoinConfigNetworkRequest._();

  factory SetBitcoinConfigNetworkRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetBitcoinConfigNetworkRequest()..mergeFromBuffer(data, registry);
  factory SetBitcoinConfigNetworkRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetBitcoinConfigNetworkRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetBitcoinConfigNetworkRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: SetBitcoinConfigNetworkRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'network')
    ..aOS(2, _omitFieldNames ? '' : 'dataDir')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetBitcoinConfigNetworkRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetBitcoinConfigNetworkRequest copyWith(void Function(SetBitcoinConfigNetworkRequest) updates) =>
      super.copyWith((message) => updates(message as SetBitcoinConfigNetworkRequest)) as SetBitcoinConfigNetworkRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetBitcoinConfigNetworkRequest() / SetBitcoinConfigNetworkRequest.new instead')
  static SetBitcoinConfigNetworkRequest create() => SetBitcoinConfigNetworkRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetBitcoinConfigNetworkRequest._();
  @$core.override
  SetBitcoinConfigNetworkRequest createEmptyInstance() => SetBitcoinConfigNetworkRequest._();
  @$core.pragma('dart2js:noInline')
  static SetBitcoinConfigNetworkRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetBitcoinConfigNetworkRequest>(SetBitcoinConfigNetworkRequest.$_createMessage);
  static SetBitcoinConfigNetworkRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get network => $_getSZ(0);
  @$pb.TagNumber(1)
  set network($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNetwork() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetwork() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get dataDir => $_getSZ(1);
  @$pb.TagNumber(2)
  set dataDir($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDataDir() => $_has(1);
  @$pb.TagNumber(2)
  void clearDataDir() => $_clearField(2);
}

class SetBitcoinConfigNetworkResponse extends $pb.GeneratedMessage {
  factory SetBitcoinConfigNetworkResponse({
    NetworkChangePlan? applied,
  }) {
    final result = SetBitcoinConfigNetworkResponse._();
    if (applied != null) result.applied = applied;
    return result;
  }

  SetBitcoinConfigNetworkResponse._();

  factory SetBitcoinConfigNetworkResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetBitcoinConfigNetworkResponse()..mergeFromBuffer(data, registry);
  factory SetBitcoinConfigNetworkResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetBitcoinConfigNetworkResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetBitcoinConfigNetworkResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: SetBitcoinConfigNetworkResponse.$_createMessage)
    ..aOM<NetworkChangePlan>(1, _omitFieldNames ? '' : 'applied', subBuilder: NetworkChangePlan.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetBitcoinConfigNetworkResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetBitcoinConfigNetworkResponse copyWith(void Function(SetBitcoinConfigNetworkResponse) updates) =>
      super.copyWith((message) => updates(message as SetBitcoinConfigNetworkResponse))
          as SetBitcoinConfigNetworkResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetBitcoinConfigNetworkResponse() / SetBitcoinConfigNetworkResponse.new instead')
  static SetBitcoinConfigNetworkResponse create() => SetBitcoinConfigNetworkResponse._();
  static $pb.GeneratedMessage $_createMessage() => SetBitcoinConfigNetworkResponse._();
  @$core.override
  SetBitcoinConfigNetworkResponse createEmptyInstance() => SetBitcoinConfigNetworkResponse._();
  @$core.pragma('dart2js:noInline')
  static SetBitcoinConfigNetworkResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetBitcoinConfigNetworkResponse>(
          SetBitcoinConfigNetworkResponse.$_createMessage);
  static SetBitcoinConfigNetworkResponse? _defaultInstance;

  @$pb.TagNumber(1)
  NetworkChangePlan get applied => $_getN(0);
  @$pb.TagNumber(1)
  set applied(NetworkChangePlan value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasApplied() => $_has(0);
  @$pb.TagNumber(1)
  void clearApplied() => $_clearField(1);
  @$pb.TagNumber(1)
  NetworkChangePlan ensureApplied() => $_ensure(0);
}

class SetBitcoinConfigDataDirRequest extends $pb.GeneratedMessage {
  factory SetBitcoinConfigDataDirRequest({
    $core.String? dataDir,
    $core.String? network,
  }) {
    final result = SetBitcoinConfigDataDirRequest._();
    if (dataDir != null) result.dataDir = dataDir;
    if (network != null) result.network = network;
    return result;
  }

  SetBitcoinConfigDataDirRequest._();

  factory SetBitcoinConfigDataDirRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetBitcoinConfigDataDirRequest()..mergeFromBuffer(data, registry);
  factory SetBitcoinConfigDataDirRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetBitcoinConfigDataDirRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetBitcoinConfigDataDirRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: SetBitcoinConfigDataDirRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'dataDir')
    ..aOS(2, _omitFieldNames ? '' : 'network')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetBitcoinConfigDataDirRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetBitcoinConfigDataDirRequest copyWith(void Function(SetBitcoinConfigDataDirRequest) updates) =>
      super.copyWith((message) => updates(message as SetBitcoinConfigDataDirRequest)) as SetBitcoinConfigDataDirRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetBitcoinConfigDataDirRequest() / SetBitcoinConfigDataDirRequest.new instead')
  static SetBitcoinConfigDataDirRequest create() => SetBitcoinConfigDataDirRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetBitcoinConfigDataDirRequest._();
  @$core.override
  SetBitcoinConfigDataDirRequest createEmptyInstance() => SetBitcoinConfigDataDirRequest._();
  @$core.pragma('dart2js:noInline')
  static SetBitcoinConfigDataDirRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetBitcoinConfigDataDirRequest>(SetBitcoinConfigDataDirRequest.$_createMessage);
  static SetBitcoinConfigDataDirRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dataDir => $_getSZ(0);
  @$pb.TagNumber(1)
  set dataDir($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDataDir() => $_has(0);
  @$pb.TagNumber(1)
  void clearDataDir() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get network => $_getSZ(1);
  @$pb.TagNumber(2)
  set network($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNetwork() => $_has(1);
  @$pb.TagNumber(2)
  void clearNetwork() => $_clearField(2);
}

class SetBitcoinConfigDataDirResponse extends $pb.GeneratedMessage {
  factory SetBitcoinConfigDataDirResponse() => SetBitcoinConfigDataDirResponse._();

  SetBitcoinConfigDataDirResponse._();

  factory SetBitcoinConfigDataDirResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetBitcoinConfigDataDirResponse()..mergeFromBuffer(data, registry);
  factory SetBitcoinConfigDataDirResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetBitcoinConfigDataDirResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetBitcoinConfigDataDirResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: SetBitcoinConfigDataDirResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetBitcoinConfigDataDirResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetBitcoinConfigDataDirResponse copyWith(void Function(SetBitcoinConfigDataDirResponse) updates) =>
      super.copyWith((message) => updates(message as SetBitcoinConfigDataDirResponse))
          as SetBitcoinConfigDataDirResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetBitcoinConfigDataDirResponse() / SetBitcoinConfigDataDirResponse.new instead')
  static SetBitcoinConfigDataDirResponse create() => SetBitcoinConfigDataDirResponse._();
  static $pb.GeneratedMessage $_createMessage() => SetBitcoinConfigDataDirResponse._();
  @$core.override
  SetBitcoinConfigDataDirResponse createEmptyInstance() => SetBitcoinConfigDataDirResponse._();
  @$core.pragma('dart2js:noInline')
  static SetBitcoinConfigDataDirResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetBitcoinConfigDataDirResponse>(
          SetBitcoinConfigDataDirResponse.$_createMessage);
  static SetBitcoinConfigDataDirResponse? _defaultInstance;
}

class WriteBitcoinConfigRequest extends $pb.GeneratedMessage {
  factory WriteBitcoinConfigRequest({
    $core.String? configContent,
  }) {
    final result = WriteBitcoinConfigRequest._();
    if (configContent != null) result.configContent = configContent;
    return result;
  }

  WriteBitcoinConfigRequest._();

  factory WriteBitcoinConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteBitcoinConfigRequest()..mergeFromBuffer(data, registry);
  factory WriteBitcoinConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteBitcoinConfigRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteBitcoinConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: WriteBitcoinConfigRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'configContent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteBitcoinConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteBitcoinConfigRequest copyWith(void Function(WriteBitcoinConfigRequest) updates) =>
      super.copyWith((message) => updates(message as WriteBitcoinConfigRequest)) as WriteBitcoinConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WriteBitcoinConfigRequest() / WriteBitcoinConfigRequest.new instead')
  static WriteBitcoinConfigRequest create() => WriteBitcoinConfigRequest._();
  static $pb.GeneratedMessage $_createMessage() => WriteBitcoinConfigRequest._();
  @$core.override
  WriteBitcoinConfigRequest createEmptyInstance() => WriteBitcoinConfigRequest._();
  @$core.pragma('dart2js:noInline')
  static WriteBitcoinConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WriteBitcoinConfigRequest>(WriteBitcoinConfigRequest.$_createMessage);
  static WriteBitcoinConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get configContent => $_getSZ(0);
  @$pb.TagNumber(1)
  set configContent($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfigContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfigContent() => $_clearField(1);
}

class WriteBitcoinConfigResponse extends $pb.GeneratedMessage {
  factory WriteBitcoinConfigResponse() => WriteBitcoinConfigResponse._();

  WriteBitcoinConfigResponse._();

  factory WriteBitcoinConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteBitcoinConfigResponse()..mergeFromBuffer(data, registry);
  factory WriteBitcoinConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteBitcoinConfigResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteBitcoinConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: WriteBitcoinConfigResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteBitcoinConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteBitcoinConfigResponse copyWith(void Function(WriteBitcoinConfigResponse) updates) =>
      super.copyWith((message) => updates(message as WriteBitcoinConfigResponse)) as WriteBitcoinConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WriteBitcoinConfigResponse() / WriteBitcoinConfigResponse.new instead')
  static WriteBitcoinConfigResponse create() => WriteBitcoinConfigResponse._();
  static $pb.GeneratedMessage $_createMessage() => WriteBitcoinConfigResponse._();
  @$core.override
  WriteBitcoinConfigResponse createEmptyInstance() => WriteBitcoinConfigResponse._();
  @$core.pragma('dart2js:noInline')
  static WriteBitcoinConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WriteBitcoinConfigResponse>(WriteBitcoinConfigResponse.$_createMessage);
  static WriteBitcoinConfigResponse? _defaultInstance;
}

class BitcoinConfServiceApi {
  final $pb.RpcClient _client;

  BitcoinConfServiceApi(this._client);

  /// Get current Bitcoin Core configuration state.
  $async.Future<GetBitcoinConfigResponse> getBitcoinConfig($pb.ClientContext? ctx, GetBitcoinConfigRequest request) =>
      _client.invoke<GetBitcoinConfigResponse>(
          ctx, 'BitcoinConfService', 'GetBitcoinConfig', request, GetBitcoinConfigResponse());

  /// Report what the user must resolve before a network and/or wallet-backend
  /// change can be applied. Side-effect free.
  $async.Future<NetworkChangePlan> prepareNetworkChange($pb.ClientContext? ctx, PrepareNetworkChangeRequest request) =>
      _client.invoke<NetworkChangePlan>(
          ctx, 'BitcoinConfService', 'PrepareNetworkChange', request, NetworkChangePlan());

  /// The networks the user can pick, from the published catalog plus regtest.
  $async.Future<ListNetworksResponse> listNetworks($pb.ClientContext? ctx, ListNetworksRequest request) =>
      _client.invoke<ListNetworksResponse>(ctx, 'BitcoinConfService', 'ListNetworks', request, ListNetworksResponse());

  /// The networks that appeared in the catalog since the last call, so the app
  /// can name them in a notice. Reporting a network also marks it told: a
  /// second call returns it no more. A first run reports nothing.
  $async.Future<TakeNewNetworksResponse> takeNewNetworks($pb.ClientContext? ctx, TakeNewNetworksRequest request) =>
      _client.invoke<TakeNewNetworksResponse>(
          ctx, 'BitcoinConfService', 'TakeNewNetworks', request, TakeNewNetworksResponse());

  /// What a move to another eCash network costs. Both fork mainnet, so the
  /// blocks below the lower fork height are shared and the move is a reset
  /// rather than a resync. Side-effect free.
  $async.Future<PlanECashSwitchResponse> planECashSwitch($pb.ClientContext? ctx, PlanECashSwitchRequest request) =>
      _client.invoke<PlanECashSwitchResponse>(
          ctx, 'BitcoinConfService', 'PlanECashSwitch', request, PlanECashSwitchResponse());

  /// Set the Bitcoin Core network. Takes a catalog id ("betanet") or a slot
  /// name (signet, mainnet, ecash, regtest).
  $async.Future<SetBitcoinConfigNetworkResponse> setBitcoinConfigNetwork(
          $pb.ClientContext? ctx, SetBitcoinConfigNetworkRequest request) =>
      _client.invoke<SetBitcoinConfigNetworkResponse>(
          ctx, 'BitcoinConfService', 'SetBitcoinConfigNetwork', request, SetBitcoinConfigNetworkResponse());

  /// Set the Bitcoin Core datadir for a specific network.
  $async.Future<SetBitcoinConfigDataDirResponse> setBitcoinConfigDataDir(
          $pb.ClientContext? ctx, SetBitcoinConfigDataDirRequest request) =>
      _client.invoke<SetBitcoinConfigDataDirResponse>(
          ctx, 'BitcoinConfService', 'SetBitcoinConfigDataDir', request, SetBitcoinConfigDataDirResponse());

  /// Write raw Bitcoin Core configuration content.
  $async.Future<WriteBitcoinConfigResponse> writeBitcoinConfig(
          $pb.ClientContext? ctx, WriteBitcoinConfigRequest request) =>
      _client.invoke<WriteBitcoinConfigResponse>(
          ctx, 'BitcoinConfService', 'WriteBitcoinConfig', request, WriteBitcoinConfigResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
