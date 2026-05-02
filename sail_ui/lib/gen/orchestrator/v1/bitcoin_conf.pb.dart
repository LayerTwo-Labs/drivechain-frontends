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
}

class SetBitcoinConfigNetworkRequest extends $pb.GeneratedMessage {
  factory SetBitcoinConfigNetworkRequest({
    $core.String? network,
  }) {
    final $result = create();
    if (network != null) {
      $result.network = network;
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
}

class SetBitcoinConfigNetworkResponse extends $pb.GeneratedMessage {
  factory SetBitcoinConfigNetworkResponse() => create();
  SetBitcoinConfigNetworkResponse._() : super();
  factory SetBitcoinConfigNetworkResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SetBitcoinConfigNetworkResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetBitcoinConfigNetworkResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
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
