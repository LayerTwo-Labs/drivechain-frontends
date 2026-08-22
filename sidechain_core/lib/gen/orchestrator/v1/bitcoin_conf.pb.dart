//
//  Generated code. Do not modify.
//  source: orchestrator/v1/bitcoin_conf.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'bitcoin_conf.pbenum.dart';

export 'bitcoin_conf.pbenum.dart';

class GetBitcoinConfigRequest extends $pb.GeneratedMessage {
  factory GetBitcoinConfigRequest() => create();
  GetBitcoinConfigRequest._() : super();
  factory GetBitcoinConfigRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetBitcoinConfigRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBitcoinConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetBitcoinConfigRequest clone() => GetBitcoinConfigRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetBitcoinConfigRequest copyWith(void Function(GetBitcoinConfigRequest) updates) =>
      super.copyWith((message) => updates(message as GetBitcoinConfigRequest)) as GetBitcoinConfigRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBitcoinConfigRequest create() => GetBitcoinConfigRequest._();
  GetBitcoinConfigRequest createEmptyInstance() => create();
  static $pb.PbList<GetBitcoinConfigRequest> createRepeated() => $pb.PbList<GetBitcoinConfigRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBitcoinConfigRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBitcoinConfigRequest>(create);
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
    $core.String? forknetDatadir,
    $core.String? ecashDatadir,
    $core.String? ecashNetworkId,
    $core.bool? mustSelectDatadir,
    $core.String? ecashEsploraUrl,
    $core.String? ecashExplorerHost,
  }) {
    final $result = create();
    if (network != null) {
      $result.network = network;
    }
    if (rpcPort != null) {
      $result.rpcPort = rpcPort;
    }
    if (hasPrivateConf != null) {
      $result.hasPrivateConf = hasPrivateConf;
    }
    if (configPath != null) {
      $result.configPath = configPath;
    }
    if (detectedDataDir != null) {
      $result.detectedDataDir = detectedDataDir;
    }
    if (configContent != null) {
      $result.configContent = configContent;
    }
    if (networkSupportsSidechains != null) {
      $result.networkSupportsSidechains = networkSupportsSidechains;
    }
    if (isDemoMode != null) {
      $result.isDemoMode = isDemoMode;
    }
    if (rpcUser != null) {
      $result.rpcUser = rpcUser;
    }
    if (rpcPassword != null) {
      $result.rpcPassword = rpcPassword;
    }
    if (defaultDatadir != null) {
      $result.defaultDatadir = defaultDatadir;
    }
    if (forknetDatadir != null) {
      $result.forknetDatadir = forknetDatadir;
    }
    if (ecashDatadir != null) {
      $result.ecashDatadir = ecashDatadir;
    }
    if (ecashNetworkId != null) {
      $result.ecashNetworkId = ecashNetworkId;
    }
    if (mustSelectDatadir != null) {
      $result.mustSelectDatadir = mustSelectDatadir;
    }
    if (ecashEsploraUrl != null) {
      $result.ecashEsploraUrl = ecashEsploraUrl;
    }
    if (ecashExplorerHost != null) {
      $result.ecashExplorerHost = ecashExplorerHost;
    }
    return $result;
  }
  GetBitcoinConfigResponse._() : super();
  factory GetBitcoinConfigResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetBitcoinConfigResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBitcoinConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'network')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'rpcPort', $pb.PbFieldType.O3)
    ..aOB(3, _omitFieldNames ? '' : 'hasPrivateConf')
    ..aOS(4, _omitFieldNames ? '' : 'configPath')
    ..aOS(5, _omitFieldNames ? '' : 'detectedDataDir')
    ..aOS(6, _omitFieldNames ? '' : 'configContent')
    ..aOB(7, _omitFieldNames ? '' : 'networkSupportsSidechains')
    ..aOB(8, _omitFieldNames ? '' : 'isDemoMode')
    ..aOS(9, _omitFieldNames ? '' : 'rpcUser')
    ..aOS(10, _omitFieldNames ? '' : 'rpcPassword')
    ..aOS(11, _omitFieldNames ? '' : 'defaultDatadir')
    ..aOS(12, _omitFieldNames ? '' : 'forknetDatadir')
    ..aOS(13, _omitFieldNames ? '' : 'ecashDatadir')
    ..aOS(14, _omitFieldNames ? '' : 'ecashNetworkId')
    ..aOB(15, _omitFieldNames ? '' : 'mustSelectDatadir')
    ..aOS(16, _omitFieldNames ? '' : 'ecashEsploraUrl')
    ..aOS(17, _omitFieldNames ? '' : 'ecashExplorerHost')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetBitcoinConfigResponse clone() => GetBitcoinConfigResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetBitcoinConfigResponse copyWith(void Function(GetBitcoinConfigResponse) updates) =>
      super.copyWith((message) => updates(message as GetBitcoinConfigResponse)) as GetBitcoinConfigResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBitcoinConfigResponse create() => GetBitcoinConfigResponse._();
  GetBitcoinConfigResponse createEmptyInstance() => create();
  static $pb.PbList<GetBitcoinConfigResponse> createRepeated() => $pb.PbList<GetBitcoinConfigResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBitcoinConfigResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBitcoinConfigResponse>(create);
  static GetBitcoinConfigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get network => $_getSZ(0);
  @$pb.TagNumber(1)
  set network($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasNetwork() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetwork() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get rpcPort => $_getIZ(1);
  @$pb.TagNumber(2)
  set rpcPort($core.int v) {
    $_setSignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasRpcPort() => $_has(1);
  @$pb.TagNumber(2)
  void clearRpcPort() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get hasPrivateConf => $_getBF(2);
  @$pb.TagNumber(3)
  set hasPrivateConf($core.bool v) {
    $_setBool(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasHasPrivateConf() => $_has(2);
  @$pb.TagNumber(3)
  void clearHasPrivateConf() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get configPath => $_getSZ(3);
  @$pb.TagNumber(4)
  set configPath($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasConfigPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfigPath() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get detectedDataDir => $_getSZ(4);
  @$pb.TagNumber(5)
  set detectedDataDir($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasDetectedDataDir() => $_has(4);
  @$pb.TagNumber(5)
  void clearDetectedDataDir() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get configContent => $_getSZ(5);
  @$pb.TagNumber(6)
  set configContent($core.String v) {
    $_setString(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasConfigContent() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfigContent() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get networkSupportsSidechains => $_getBF(6);
  @$pb.TagNumber(7)
  set networkSupportsSidechains($core.bool v) {
    $_setBool(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasNetworkSupportsSidechains() => $_has(6);
  @$pb.TagNumber(7)
  void clearNetworkSupportsSidechains() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isDemoMode => $_getBF(7);
  @$pb.TagNumber(8)
  set isDemoMode($core.bool v) {
    $_setBool(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasIsDemoMode() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsDemoMode() => clearField(8);

  /// RPC creds — exposed so localhost callers (cpuminer, future tools) that
  /// need raw bitcoind JSON-RPC can dial it without re-parsing config_content.
  /// Prefer the hosted BitcoinService proxy when possible.
  @$pb.TagNumber(9)
  $core.String get rpcUser => $_getSZ(8);
  @$pb.TagNumber(9)
  set rpcUser($core.String v) {
    $_setString(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasRpcUser() => $_has(8);
  @$pb.TagNumber(9)
  void clearRpcUser() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get rpcPassword => $_getSZ(9);
  @$pb.TagNumber(10)
  set rpcPassword($core.String v) {
    $_setString(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasRpcPassword() => $_has(9);
  @$pb.TagNumber(10)
  void clearRpcPassword() => clearField(10);

  /// Per-group datadir snapshots. The active group's value mirrors
  /// detected_data_dir; the inactive group's value is the path that will be
  /// restored on the next swap into that group. Empty = no path stored.
  @$pb.TagNumber(11)
  $core.String get defaultDatadir => $_getSZ(10);
  @$pb.TagNumber(11)
  set defaultDatadir($core.String v) {
    $_setString(10, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasDefaultDatadir() => $_has(10);
  @$pb.TagNumber(11)
  void clearDefaultDatadir() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get forknetDatadir => $_getSZ(11);
  @$pb.TagNumber(12)
  set forknetDatadir($core.String v) {
    $_setString(11, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasForknetDatadir() => $_has(11);
  @$pb.TagNumber(12)
  void clearForknetDatadir() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get ecashDatadir => $_getSZ(12);
  @$pb.TagNumber(13)
  set ecashDatadir($core.String v) {
    $_setString(12, v);
  }

  @$pb.TagNumber(13)
  $core.bool hasEcashDatadir() => $_has(12);
  @$pb.TagNumber(13)
  void clearEcashDatadir() => clearField(13);

  /// Live eCash network id ("alphanet").
  @$pb.TagNumber(14)
  $core.String get ecashNetworkId => $_getSZ(13);
  @$pb.TagNumber(14)
  set ecashNetworkId($core.String v) {
    $_setString(13, v);
  }

  @$pb.TagNumber(14)
  $core.bool hasEcashNetworkId() => $_has(13);
  @$pb.TagNumber(14)
  void clearEcashNetworkId() => clearField(14);

  /// True when the current network and wallet backend need a datadir the user
  /// has not chosen yet. Drives the boot-time prompt.
  @$pb.TagNumber(15)
  $core.bool get mustSelectDatadir => $_getBF(14);
  @$pb.TagNumber(15)
  set mustSelectDatadir($core.bool v) {
    $_setBool(14, v);
  }

  @$pb.TagNumber(15)
  $core.bool hasMustSelectDatadir() => $_has(14);
  @$pb.TagNumber(15)
  void clearMustSelectDatadir() => clearField(15);

  /// Esplora base URL the catalog publishes for the live eCash network, empty
  /// when it publishes none.
  @$pb.TagNumber(16)
  $core.String get ecashEsploraUrl => $_getSZ(15);
  @$pb.TagNumber(16)
  set ecashEsploraUrl($core.String v) {
    $_setString(15, v);
  }

  @$pb.TagNumber(16)
  $core.bool hasEcashEsploraUrl() => $_has(15);
  @$pb.TagNumber(16)
  void clearEcashEsploraUrl() => clearField(16);

  /// Explorer host the catalog publishes for the live eCash network, empty
  /// when it publishes none.
  @$pb.TagNumber(17)
  $core.String get ecashExplorerHost => $_getSZ(16);
  @$pb.TagNumber(17)
  set ecashExplorerHost($core.String v) {
    $_setString(16, v);
  }

  @$pb.TagNumber(17)
  $core.bool hasEcashExplorerHost() => $_has(16);
  @$pb.TagNumber(17)
  void clearEcashExplorerHost() => clearField(17);
}

class ListNetworksRequest extends $pb.GeneratedMessage {
  factory ListNetworksRequest() => create();
  ListNetworksRequest._() : super();
  factory ListNetworksRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListNetworksRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListNetworksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ListNetworksRequest clone() => ListNetworksRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ListNetworksRequest copyWith(void Function(ListNetworksRequest) updates) =>
      super.copyWith((message) => updates(message as ListNetworksRequest)) as ListNetworksRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListNetworksRequest create() => ListNetworksRequest._();
  ListNetworksRequest createEmptyInstance() => create();
  static $pb.PbList<ListNetworksRequest> createRepeated() => $pb.PbList<ListNetworksRequest>();
  @$core.pragma('dart2js:noInline')
  static ListNetworksRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListNetworksRequest>(create);
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
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (displayName != null) {
      $result.displayName = displayName;
    }
    if (network != null) {
      $result.network = network;
    }
    if (isCurrent != null) {
      $result.isCurrent = isCurrent;
    }
    return $result;
  }
  NetworkOption._() : super();
  factory NetworkOption.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory NetworkOption.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NetworkOption',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOS(3, _omitFieldNames ? '' : 'network')
    ..aOB(4, _omitFieldNames ? '' : 'isCurrent')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  NetworkOption clone() => NetworkOption()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  NetworkOption copyWith(void Function(NetworkOption) updates) =>
      super.copyWith((message) => updates(message as NetworkOption)) as NetworkOption;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NetworkOption create() => NetworkOption._();
  NetworkOption createEmptyInstance() => create();
  static $pb.PbList<NetworkOption> createRepeated() => $pb.PbList<NetworkOption>();
  @$core.pragma('dart2js:noInline')
  static NetworkOption getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NetworkOption>(create);
  static NetworkOption? _defaultInstance;

  /// Catalog id ("alphanet", "bitcoin"), or "regtest" for the local-only row.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  /// Name to show the user ("Alphanet").
  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => clearField(2);

  /// Slot this row runs in: mainnet | signet | forknet | ecash | regtest.
  @$pb.TagNumber(3)
  $core.String get network => $_getSZ(2);
  @$pb.TagNumber(3)
  set network($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasNetwork() => $_has(2);
  @$pb.TagNumber(3)
  void clearNetwork() => clearField(3);

  /// True for the network this install runs right now.
  @$pb.TagNumber(4)
  $core.bool get isCurrent => $_getBF(3);
  @$pb.TagNumber(4)
  set isCurrent($core.bool v) {
    $_setBool(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasIsCurrent() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsCurrent() => clearField(4);
}

class ListNetworksResponse extends $pb.GeneratedMessage {
  factory ListNetworksResponse({
    $core.Iterable<NetworkOption>? networks,
  }) {
    final $result = create();
    if (networks != null) {
      $result.networks.addAll(networks);
    }
    return $result;
  }
  ListNetworksResponse._() : super();
  factory ListNetworksResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListNetworksResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListNetworksResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..pc<NetworkOption>(1, _omitFieldNames ? '' : 'networks', $pb.PbFieldType.PM, subBuilder: NetworkOption.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ListNetworksResponse clone() => ListNetworksResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ListNetworksResponse copyWith(void Function(ListNetworksResponse) updates) =>
      super.copyWith((message) => updates(message as ListNetworksResponse)) as ListNetworksResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListNetworksResponse create() => ListNetworksResponse._();
  ListNetworksResponse createEmptyInstance() => create();
  static $pb.PbList<ListNetworksResponse> createRepeated() => $pb.PbList<ListNetworksResponse>();
  @$core.pragma('dart2js:noInline')
  static ListNetworksResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListNetworksResponse>(create);
  static ListNetworksResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<NetworkOption> get networks => $_getList(0);
}

class PlanECashSwitchRequest extends $pb.GeneratedMessage {
  factory PlanECashSwitchRequest({
    $core.String? networkId,
  }) {
    final $result = create();
    if (networkId != null) {
      $result.networkId = networkId;
    }
    return $result;
  }
  PlanECashSwitchRequest._() : super();
  factory PlanECashSwitchRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory PlanECashSwitchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PlanECashSwitchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'networkId')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  PlanECashSwitchRequest clone() => PlanECashSwitchRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  PlanECashSwitchRequest copyWith(void Function(PlanECashSwitchRequest) updates) =>
      super.copyWith((message) => updates(message as PlanECashSwitchRequest)) as PlanECashSwitchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlanECashSwitchRequest create() => PlanECashSwitchRequest._();
  PlanECashSwitchRequest createEmptyInstance() => create();
  static $pb.PbList<PlanECashSwitchRequest> createRepeated() => $pb.PbList<PlanECashSwitchRequest>();
  @$core.pragma('dart2js:noInline')
  static PlanECashSwitchRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PlanECashSwitchRequest>(create);
  static PlanECashSwitchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get networkId => $_getSZ(0);
  @$pb.TagNumber(1)
  set networkId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasNetworkId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetworkId() => clearField(1);
}

class PlanECashSwitchResponse extends $pb.GeneratedMessage {
  factory PlanECashSwitchResponse({
    $core.String? fromId,
    $core.String? toId,
    $core.int? rewindHeight,
    $core.bool? needsRollback,
    $core.bool? mustWipe,
  }) {
    final $result = create();
    if (fromId != null) {
      $result.fromId = fromId;
    }
    if (toId != null) {
      $result.toId = toId;
    }
    if (rewindHeight != null) {
      $result.rewindHeight = rewindHeight;
    }
    if (needsRollback != null) {
      $result.needsRollback = needsRollback;
    }
    if (mustWipe != null) {
      $result.mustWipe = mustWipe;
    }
    return $result;
  }
  PlanECashSwitchResponse._() : super();
  factory PlanECashSwitchResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory PlanECashSwitchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PlanECashSwitchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fromId')
    ..aOS(2, _omitFieldNames ? '' : 'toId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'rewindHeight', $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'needsRollback')
    ..aOB(5, _omitFieldNames ? '' : 'mustWipe')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  PlanECashSwitchResponse clone() => PlanECashSwitchResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  PlanECashSwitchResponse copyWith(void Function(PlanECashSwitchResponse) updates) =>
      super.copyWith((message) => updates(message as PlanECashSwitchResponse)) as PlanECashSwitchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlanECashSwitchResponse create() => PlanECashSwitchResponse._();
  PlanECashSwitchResponse createEmptyInstance() => create();
  static $pb.PbList<PlanECashSwitchResponse> createRepeated() => $pb.PbList<PlanECashSwitchResponse>();
  @$core.pragma('dart2js:noInline')
  static PlanECashSwitchResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PlanECashSwitchResponse>(create);
  static PlanECashSwitchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fromId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fromId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasFromId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get toId => $_getSZ(1);
  @$pb.TagNumber(2)
  set toId($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasToId() => $_has(1);
  @$pb.TagNumber(2)
  void clearToId() => clearField(2);

  /// Block the switch drops, one below the lower fork height. Core parks under
  /// it and follows the new network from there. Zero when nothing is dropped.
  @$pb.TagNumber(3)
  $core.int get rewindHeight => $_getIZ(2);
  @$pb.TagNumber(3)
  set rewindHeight($core.int v) {
    $_setUnsignedInt32(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasRewindHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearRewindHeight() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get needsRollback => $_getBF(3);
  @$pb.TagNumber(4)
  set needsRollback($core.bool v) {
    $_setBool(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasNeedsRollback() => $_has(3);
  @$pb.TagNumber(4)
  void clearNeedsRollback() => clearField(4);

  /// True when the old blocks cannot stay and the switch resyncs the chain.
  @$pb.TagNumber(5)
  $core.bool get mustWipe => $_getBF(4);
  @$pb.TagNumber(5)
  set mustWipe($core.bool v) {
    $_setBool(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasMustWipe() => $_has(4);
  @$pb.TagNumber(5)
  void clearMustWipe() => clearField(5);
}

class TakeNewNetworksRequest extends $pb.GeneratedMessage {
  factory TakeNewNetworksRequest() => create();
  TakeNewNetworksRequest._() : super();
  factory TakeNewNetworksRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TakeNewNetworksRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TakeNewNetworksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  TakeNewNetworksRequest clone() => TakeNewNetworksRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  TakeNewNetworksRequest copyWith(void Function(TakeNewNetworksRequest) updates) =>
      super.copyWith((message) => updates(message as TakeNewNetworksRequest)) as TakeNewNetworksRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TakeNewNetworksRequest create() => TakeNewNetworksRequest._();
  TakeNewNetworksRequest createEmptyInstance() => create();
  static $pb.PbList<TakeNewNetworksRequest> createRepeated() => $pb.PbList<TakeNewNetworksRequest>();
  @$core.pragma('dart2js:noInline')
  static TakeNewNetworksRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TakeNewNetworksRequest>(create);
  static TakeNewNetworksRequest? _defaultInstance;
}

class TakeNewNetworksResponse extends $pb.GeneratedMessage {
  factory TakeNewNetworksResponse({
    $core.Iterable<NetworkOption>? networks,
  }) {
    final $result = create();
    if (networks != null) {
      $result.networks.addAll(networks);
    }
    return $result;
  }
  TakeNewNetworksResponse._() : super();
  factory TakeNewNetworksResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TakeNewNetworksResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TakeNewNetworksResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..pc<NetworkOption>(1, _omitFieldNames ? '' : 'networks', $pb.PbFieldType.PM, subBuilder: NetworkOption.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  TakeNewNetworksResponse clone() => TakeNewNetworksResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  TakeNewNetworksResponse copyWith(void Function(TakeNewNetworksResponse) updates) =>
      super.copyWith((message) => updates(message as TakeNewNetworksResponse)) as TakeNewNetworksResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TakeNewNetworksResponse create() => TakeNewNetworksResponse._();
  TakeNewNetworksResponse createEmptyInstance() => create();
  static $pb.PbList<TakeNewNetworksResponse> createRepeated() => $pb.PbList<TakeNewNetworksResponse>();
  @$core.pragma('dart2js:noInline')
  static TakeNewNetworksResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TakeNewNetworksResponse>(create);
  static TakeNewNetworksResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<NetworkOption> get networks => $_getList(0);
}

class PrepareNetworkChangeRequest extends $pb.GeneratedMessage {
  factory PrepareNetworkChangeRequest({
    $core.String? network,
    WalletBackend? walletBackend,
    $core.String? walletId,
  }) {
    final $result = create();
    if (network != null) {
      $result.network = network;
    }
    if (walletBackend != null) {
      $result.walletBackend = walletBackend;
    }
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  PrepareNetworkChangeRequest._() : super();
  factory PrepareNetworkChangeRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory PrepareNetworkChangeRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PrepareNetworkChangeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'network')
    ..e<WalletBackend>(2, _omitFieldNames ? '' : 'walletBackend', $pb.PbFieldType.OE,
        defaultOrMaker: WalletBackend.WALLET_BACKEND_UNSPECIFIED,
        valueOf: WalletBackend.valueOf,
        enumValues: WalletBackend.values)
    ..aOS(3, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  PrepareNetworkChangeRequest clone() => PrepareNetworkChangeRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  PrepareNetworkChangeRequest copyWith(void Function(PrepareNetworkChangeRequest) updates) =>
      super.copyWith((message) => updates(message as PrepareNetworkChangeRequest)) as PrepareNetworkChangeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PrepareNetworkChangeRequest create() => PrepareNetworkChangeRequest._();
  PrepareNetworkChangeRequest createEmptyInstance() => create();
  static $pb.PbList<PrepareNetworkChangeRequest> createRepeated() => $pb.PbList<PrepareNetworkChangeRequest>();
  @$core.pragma('dart2js:noInline')
  static PrepareNetworkChangeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PrepareNetworkChangeRequest>(create);
  static PrepareNetworkChangeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get network => $_getSZ(0);
  @$pb.TagNumber(1)
  set network($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasNetwork() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetwork() => clearField(1);

  @$pb.TagNumber(2)
  WalletBackend get walletBackend => $_getN(1);
  @$pb.TagNumber(2)
  set walletBackend(WalletBackend v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasWalletBackend() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletBackend() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get walletId => $_getSZ(2);
  @$pb.TagNumber(3)
  set walletId($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasWalletId() => $_has(2);
  @$pb.TagNumber(3)
  void clearWalletId() => clearField(3);
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
    final $result = create();
    if (network != null) {
      $result.network = network;
    }
    if (walletBackend != null) {
      $result.walletBackend = walletBackend;
    }
    if (mustSelectDatadir != null) {
      $result.mustSelectDatadir = mustSelectDatadir;
    }
    if (datadir != null) {
      $result.datadir = datadir;
    }
    if (datadirGroup != null) {
      $result.datadirGroup = datadirGroup;
    }
    if (needsLocalBackends != null) {
      $result.needsLocalBackends = needsLocalBackends;
    }
    if (impliesChainDownload != null) {
      $result.impliesChainDownload = impliesChainDownload;
    }
    if (missingBinaries != null) {
      $result.missingBinaries.addAll(missingBinaries);
    }
    if (needsBinaryDownload != null) {
      $result.needsBinaryDownload = needsBinaryDownload;
    }
    if (noOp != null) {
      $result.noOp = noOp;
    }
    return $result;
  }
  NetworkChangePlan._() : super();
  factory NetworkChangePlan.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory NetworkChangePlan.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NetworkChangePlan',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'network')
    ..e<WalletBackend>(2, _omitFieldNames ? '' : 'walletBackend', $pb.PbFieldType.OE,
        defaultOrMaker: WalletBackend.WALLET_BACKEND_UNSPECIFIED,
        valueOf: WalletBackend.valueOf,
        enumValues: WalletBackend.values)
    ..aOB(3, _omitFieldNames ? '' : 'mustSelectDatadir')
    ..aOS(4, _omitFieldNames ? '' : 'datadir')
    ..aOS(5, _omitFieldNames ? '' : 'datadirGroup')
    ..aOB(6, _omitFieldNames ? '' : 'needsLocalBackends')
    ..aOB(7, _omitFieldNames ? '' : 'impliesChainDownload')
    ..pPS(8, _omitFieldNames ? '' : 'missingBinaries')
    ..aOB(9, _omitFieldNames ? '' : 'needsBinaryDownload')
    ..aOB(10, _omitFieldNames ? '' : 'noOp')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  NetworkChangePlan clone() => NetworkChangePlan()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  NetworkChangePlan copyWith(void Function(NetworkChangePlan) updates) =>
      super.copyWith((message) => updates(message as NetworkChangePlan)) as NetworkChangePlan;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NetworkChangePlan create() => NetworkChangePlan._();
  NetworkChangePlan createEmptyInstance() => create();
  static $pb.PbList<NetworkChangePlan> createRepeated() => $pb.PbList<NetworkChangePlan>();
  @$core.pragma('dart2js:noInline')
  static NetworkChangePlan getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NetworkChangePlan>(create);
  static NetworkChangePlan? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get network => $_getSZ(0);
  @$pb.TagNumber(1)
  set network($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasNetwork() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetwork() => clearField(1);

  @$pb.TagNumber(2)
  WalletBackend get walletBackend => $_getN(1);
  @$pb.TagNumber(2)
  set walletBackend(WalletBackend v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasWalletBackend() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletBackend() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get mustSelectDatadir => $_getBF(2);
  @$pb.TagNumber(3)
  set mustSelectDatadir($core.bool v) {
    $_setBool(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasMustSelectDatadir() => $_has(2);
  @$pb.TagNumber(3)
  void clearMustSelectDatadir() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get datadir => $_getSZ(3);
  @$pb.TagNumber(4)
  set datadir($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasDatadir() => $_has(3);
  @$pb.TagNumber(4)
  void clearDatadir() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get datadirGroup => $_getSZ(4);
  @$pb.TagNumber(5)
  set datadirGroup($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasDatadirGroup() => $_has(4);
  @$pb.TagNumber(5)
  void clearDatadirGroup() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get needsLocalBackends => $_getBF(5);
  @$pb.TagNumber(6)
  set needsLocalBackends($core.bool v) {
    $_setBool(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasNeedsLocalBackends() => $_has(5);
  @$pb.TagNumber(6)
  void clearNeedsLocalBackends() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get impliesChainDownload => $_getBF(6);
  @$pb.TagNumber(7)
  set impliesChainDownload($core.bool v) {
    $_setBool(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasImpliesChainDownload() => $_has(6);
  @$pb.TagNumber(7)
  void clearImpliesChainDownload() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.String> get missingBinaries => $_getList(7);

  @$pb.TagNumber(9)
  $core.bool get needsBinaryDownload => $_getBF(8);
  @$pb.TagNumber(9)
  set needsBinaryDownload($core.bool v) {
    $_setBool(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasNeedsBinaryDownload() => $_has(8);
  @$pb.TagNumber(9)
  void clearNeedsBinaryDownload() => clearField(9);

  @$pb.TagNumber(10)
  $core.bool get noOp => $_getBF(9);
  @$pb.TagNumber(10)
  set noOp($core.bool v) {
    $_setBool(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasNoOp() => $_has(9);
  @$pb.TagNumber(10)
  void clearNoOp() => clearField(10);
}

class SetBitcoinConfigNetworkRequest extends $pb.GeneratedMessage {
  factory SetBitcoinConfigNetworkRequest({
    $core.String? network,
    $core.String? dataDir,
  }) {
    final $result = create();
    if (network != null) {
      $result.network = network;
    }
    if (dataDir != null) {
      $result.dataDir = dataDir;
    }
    return $result;
  }
  SetBitcoinConfigNetworkRequest._() : super();
  factory SetBitcoinConfigNetworkRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SetBitcoinConfigNetworkRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetBitcoinConfigNetworkRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'network')
    ..aOS(2, _omitFieldNames ? '' : 'dataDir')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SetBitcoinConfigNetworkRequest clone() => SetBitcoinConfigNetworkRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SetBitcoinConfigNetworkRequest copyWith(void Function(SetBitcoinConfigNetworkRequest) updates) =>
      super.copyWith((message) => updates(message as SetBitcoinConfigNetworkRequest)) as SetBitcoinConfigNetworkRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetBitcoinConfigNetworkRequest create() => SetBitcoinConfigNetworkRequest._();
  SetBitcoinConfigNetworkRequest createEmptyInstance() => create();
  static $pb.PbList<SetBitcoinConfigNetworkRequest> createRepeated() => $pb.PbList<SetBitcoinConfigNetworkRequest>();
  @$core.pragma('dart2js:noInline')
  static SetBitcoinConfigNetworkRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetBitcoinConfigNetworkRequest>(create);
  static SetBitcoinConfigNetworkRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get network => $_getSZ(0);
  @$pb.TagNumber(1)
  set network($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasNetwork() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetwork() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get dataDir => $_getSZ(1);
  @$pb.TagNumber(2)
  set dataDir($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasDataDir() => $_has(1);
  @$pb.TagNumber(2)
  void clearDataDir() => clearField(2);
}

class SetBitcoinConfigNetworkResponse extends $pb.GeneratedMessage {
  factory SetBitcoinConfigNetworkResponse({
    NetworkChangePlan? applied,
  }) {
    final $result = create();
    if (applied != null) {
      $result.applied = applied;
    }
    return $result;
  }
  SetBitcoinConfigNetworkResponse._() : super();
  factory SetBitcoinConfigNetworkResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SetBitcoinConfigNetworkResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetBitcoinConfigNetworkResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOM<NetworkChangePlan>(1, _omitFieldNames ? '' : 'applied', subBuilder: NetworkChangePlan.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SetBitcoinConfigNetworkResponse clone() => SetBitcoinConfigNetworkResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SetBitcoinConfigNetworkResponse copyWith(void Function(SetBitcoinConfigNetworkResponse) updates) =>
      super.copyWith((message) => updates(message as SetBitcoinConfigNetworkResponse))
          as SetBitcoinConfigNetworkResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetBitcoinConfigNetworkResponse create() => SetBitcoinConfigNetworkResponse._();
  SetBitcoinConfigNetworkResponse createEmptyInstance() => create();
  static $pb.PbList<SetBitcoinConfigNetworkResponse> createRepeated() => $pb.PbList<SetBitcoinConfigNetworkResponse>();
  @$core.pragma('dart2js:noInline')
  static SetBitcoinConfigNetworkResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetBitcoinConfigNetworkResponse>(create);
  static SetBitcoinConfigNetworkResponse? _defaultInstance;

  @$pb.TagNumber(1)
  NetworkChangePlan get applied => $_getN(0);
  @$pb.TagNumber(1)
  set applied(NetworkChangePlan v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasApplied() => $_has(0);
  @$pb.TagNumber(1)
  void clearApplied() => clearField(1);
  @$pb.TagNumber(1)
  NetworkChangePlan ensureApplied() => $_ensure(0);
}

class SetBitcoinConfigDataDirRequest extends $pb.GeneratedMessage {
  factory SetBitcoinConfigDataDirRequest({
    $core.String? dataDir,
    $core.String? network,
  }) {
    final $result = create();
    if (dataDir != null) {
      $result.dataDir = dataDir;
    }
    if (network != null) {
      $result.network = network;
    }
    return $result;
  }
  SetBitcoinConfigDataDirRequest._() : super();
  factory SetBitcoinConfigDataDirRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SetBitcoinConfigDataDirRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetBitcoinConfigDataDirRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'dataDir')
    ..aOS(2, _omitFieldNames ? '' : 'network')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SetBitcoinConfigDataDirRequest clone() => SetBitcoinConfigDataDirRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SetBitcoinConfigDataDirRequest copyWith(void Function(SetBitcoinConfigDataDirRequest) updates) =>
      super.copyWith((message) => updates(message as SetBitcoinConfigDataDirRequest)) as SetBitcoinConfigDataDirRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetBitcoinConfigDataDirRequest create() => SetBitcoinConfigDataDirRequest._();
  SetBitcoinConfigDataDirRequest createEmptyInstance() => create();
  static $pb.PbList<SetBitcoinConfigDataDirRequest> createRepeated() => $pb.PbList<SetBitcoinConfigDataDirRequest>();
  @$core.pragma('dart2js:noInline')
  static SetBitcoinConfigDataDirRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetBitcoinConfigDataDirRequest>(create);
  static SetBitcoinConfigDataDirRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dataDir => $_getSZ(0);
  @$pb.TagNumber(1)
  set dataDir($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasDataDir() => $_has(0);
  @$pb.TagNumber(1)
  void clearDataDir() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get network => $_getSZ(1);
  @$pb.TagNumber(2)
  set network($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasNetwork() => $_has(1);
  @$pb.TagNumber(2)
  void clearNetwork() => clearField(2);
}

class SetBitcoinConfigDataDirResponse extends $pb.GeneratedMessage {
  factory SetBitcoinConfigDataDirResponse() => create();
  SetBitcoinConfigDataDirResponse._() : super();
  factory SetBitcoinConfigDataDirResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SetBitcoinConfigDataDirResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetBitcoinConfigDataDirResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SetBitcoinConfigDataDirResponse clone() => SetBitcoinConfigDataDirResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SetBitcoinConfigDataDirResponse copyWith(void Function(SetBitcoinConfigDataDirResponse) updates) =>
      super.copyWith((message) => updates(message as SetBitcoinConfigDataDirResponse))
          as SetBitcoinConfigDataDirResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetBitcoinConfigDataDirResponse create() => SetBitcoinConfigDataDirResponse._();
  SetBitcoinConfigDataDirResponse createEmptyInstance() => create();
  static $pb.PbList<SetBitcoinConfigDataDirResponse> createRepeated() => $pb.PbList<SetBitcoinConfigDataDirResponse>();
  @$core.pragma('dart2js:noInline')
  static SetBitcoinConfigDataDirResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetBitcoinConfigDataDirResponse>(create);
  static SetBitcoinConfigDataDirResponse? _defaultInstance;
}

class WriteBitcoinConfigRequest extends $pb.GeneratedMessage {
  factory WriteBitcoinConfigRequest({
    $core.String? configContent,
  }) {
    final $result = create();
    if (configContent != null) {
      $result.configContent = configContent;
    }
    return $result;
  }
  WriteBitcoinConfigRequest._() : super();
  factory WriteBitcoinConfigRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory WriteBitcoinConfigRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteBitcoinConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'configContent')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  WriteBitcoinConfigRequest clone() => WriteBitcoinConfigRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  WriteBitcoinConfigRequest copyWith(void Function(WriteBitcoinConfigRequest) updates) =>
      super.copyWith((message) => updates(message as WriteBitcoinConfigRequest)) as WriteBitcoinConfigRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WriteBitcoinConfigRequest create() => WriteBitcoinConfigRequest._();
  WriteBitcoinConfigRequest createEmptyInstance() => create();
  static $pb.PbList<WriteBitcoinConfigRequest> createRepeated() => $pb.PbList<WriteBitcoinConfigRequest>();
  @$core.pragma('dart2js:noInline')
  static WriteBitcoinConfigRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WriteBitcoinConfigRequest>(create);
  static WriteBitcoinConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get configContent => $_getSZ(0);
  @$pb.TagNumber(1)
  set configContent($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasConfigContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfigContent() => clearField(1);
}

class WriteBitcoinConfigResponse extends $pb.GeneratedMessage {
  factory WriteBitcoinConfigResponse() => create();
  WriteBitcoinConfigResponse._() : super();
  factory WriteBitcoinConfigResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory WriteBitcoinConfigResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteBitcoinConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  WriteBitcoinConfigResponse clone() => WriteBitcoinConfigResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  WriteBitcoinConfigResponse copyWith(void Function(WriteBitcoinConfigResponse) updates) =>
      super.copyWith((message) => updates(message as WriteBitcoinConfigResponse)) as WriteBitcoinConfigResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WriteBitcoinConfigResponse create() => WriteBitcoinConfigResponse._();
  WriteBitcoinConfigResponse createEmptyInstance() => create();
  static $pb.PbList<WriteBitcoinConfigResponse> createRepeated() => $pb.PbList<WriteBitcoinConfigResponse>();
  @$core.pragma('dart2js:noInline')
  static WriteBitcoinConfigResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WriteBitcoinConfigResponse>(create);
  static WriteBitcoinConfigResponse? _defaultInstance;
}

class BitcoinConfServiceApi {
  $pb.RpcClient _client;
  BitcoinConfServiceApi(this._client);

  $async.Future<GetBitcoinConfigResponse> getBitcoinConfig($pb.ClientContext? ctx, GetBitcoinConfigRequest request) =>
      _client.invoke<GetBitcoinConfigResponse>(
          ctx, 'BitcoinConfService', 'GetBitcoinConfig', request, GetBitcoinConfigResponse());
  $async.Future<NetworkChangePlan> prepareNetworkChange($pb.ClientContext? ctx, PrepareNetworkChangeRequest request) =>
      _client.invoke<NetworkChangePlan>(
          ctx, 'BitcoinConfService', 'PrepareNetworkChange', request, NetworkChangePlan());
  $async.Future<ListNetworksResponse> listNetworks($pb.ClientContext? ctx, ListNetworksRequest request) =>
      _client.invoke<ListNetworksResponse>(ctx, 'BitcoinConfService', 'ListNetworks', request, ListNetworksResponse());
  $async.Future<TakeNewNetworksResponse> takeNewNetworks($pb.ClientContext? ctx, TakeNewNetworksRequest request) =>
      _client.invoke<TakeNewNetworksResponse>(
          ctx, 'BitcoinConfService', 'TakeNewNetworks', request, TakeNewNetworksResponse());
  $async.Future<PlanECashSwitchResponse> planECashSwitch($pb.ClientContext? ctx, PlanECashSwitchRequest request) =>
      _client.invoke<PlanECashSwitchResponse>(
          ctx, 'BitcoinConfService', 'PlanECashSwitch', request, PlanECashSwitchResponse());
  $async.Future<SetBitcoinConfigNetworkResponse> setBitcoinConfigNetwork(
          $pb.ClientContext? ctx, SetBitcoinConfigNetworkRequest request) =>
      _client.invoke<SetBitcoinConfigNetworkResponse>(
          ctx, 'BitcoinConfService', 'SetBitcoinConfigNetwork', request, SetBitcoinConfigNetworkResponse());
  $async.Future<SetBitcoinConfigDataDirResponse> setBitcoinConfigDataDir(
          $pb.ClientContext? ctx, SetBitcoinConfigDataDirRequest request) =>
      _client.invoke<SetBitcoinConfigDataDirResponse>(
          ctx, 'BitcoinConfService', 'SetBitcoinConfigDataDir', request, SetBitcoinConfigDataDirResponse());
  $async.Future<WriteBitcoinConfigResponse> writeBitcoinConfig(
          $pb.ClientContext? ctx, WriteBitcoinConfigRequest request) =>
      _client.invoke<WriteBitcoinConfigResponse>(
          ctx, 'BitcoinConfService', 'WriteBitcoinConfig', request, WriteBitcoinConfigResponse());
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
