//
//  Generated code. Do not modify.
//  source: orchestrator/v1/sidechain_conf.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class GetSidechainConfigRequest extends $pb.GeneratedMessage {
  factory GetSidechainConfigRequest({
    $core.String? sidechainName,
  }) {
    final $result = create();
    if (sidechainName != null) {
      $result.sidechainName = sidechainName;
    }
    return $result;
  }
  GetSidechainConfigRequest._() : super();
  factory GetSidechainConfigRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetSidechainConfigRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sidechainName')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetSidechainConfigRequest clone() => GetSidechainConfigRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetSidechainConfigRequest copyWith(void Function(GetSidechainConfigRequest) updates) =>
      super.copyWith((message) => updates(message as GetSidechainConfigRequest)) as GetSidechainConfigRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSidechainConfigRequest create() => GetSidechainConfigRequest._();
  GetSidechainConfigRequest createEmptyInstance() => create();
  static $pb.PbList<GetSidechainConfigRequest> createRepeated() => $pb.PbList<GetSidechainConfigRequest>();
  @$core.pragma('dart2js:noInline')
  static GetSidechainConfigRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSidechainConfigRequest>(create);
  static GetSidechainConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sidechainName => $_getSZ(0);
  @$pb.TagNumber(1)
  set sidechainName($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSidechainName() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainName() => clearField(1);
}

class GetSidechainConfigResponse extends $pb.GeneratedMessage {
  factory GetSidechainConfigResponse({
    $core.String? configContent,
    $core.String? configPath,
    $core.String? defaultConfig,
    $core.Iterable<$core.String>? cliArgs,
    $core.String? network,
  }) {
    final $result = create();
    if (configContent != null) {
      $result.configContent = configContent;
    }
    if (configPath != null) {
      $result.configPath = configPath;
    }
    if (defaultConfig != null) {
      $result.defaultConfig = defaultConfig;
    }
    if (cliArgs != null) {
      $result.cliArgs.addAll(cliArgs);
    }
    if (network != null) {
      $result.network = network;
    }
    return $result;
  }
  GetSidechainConfigResponse._() : super();
  factory GetSidechainConfigResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetSidechainConfigResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'configContent')
    ..aOS(2, _omitFieldNames ? '' : 'configPath')
    ..aOS(3, _omitFieldNames ? '' : 'defaultConfig')
    ..pPS(4, _omitFieldNames ? '' : 'cliArgs')
    ..aOS(5, _omitFieldNames ? '' : 'network')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetSidechainConfigResponse clone() => GetSidechainConfigResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetSidechainConfigResponse copyWith(void Function(GetSidechainConfigResponse) updates) =>
      super.copyWith((message) => updates(message as GetSidechainConfigResponse)) as GetSidechainConfigResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSidechainConfigResponse create() => GetSidechainConfigResponse._();
  GetSidechainConfigResponse createEmptyInstance() => create();
  static $pb.PbList<GetSidechainConfigResponse> createRepeated() => $pb.PbList<GetSidechainConfigResponse>();
  @$core.pragma('dart2js:noInline')
  static GetSidechainConfigResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSidechainConfigResponse>(create);
  static GetSidechainConfigResponse? _defaultInstance;

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

  @$pb.TagNumber(2)
  $core.String get configPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set configPath($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasConfigPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfigPath() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get defaultConfig => $_getSZ(2);
  @$pb.TagNumber(3)
  set defaultConfig($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasDefaultConfig() => $_has(2);
  @$pb.TagNumber(3)
  void clearDefaultConfig() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.String> get cliArgs => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get network => $_getSZ(4);
  @$pb.TagNumber(5)
  set network($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasNetwork() => $_has(4);
  @$pb.TagNumber(5)
  void clearNetwork() => clearField(5);
}

class WriteSidechainConfigRequest extends $pb.GeneratedMessage {
  factory WriteSidechainConfigRequest({
    $core.String? sidechainName,
    $core.String? configContent,
  }) {
    final $result = create();
    if (sidechainName != null) {
      $result.sidechainName = sidechainName;
    }
    if (configContent != null) {
      $result.configContent = configContent;
    }
    return $result;
  }
  WriteSidechainConfigRequest._() : super();
  factory WriteSidechainConfigRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory WriteSidechainConfigRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteSidechainConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sidechainName')
    ..aOS(2, _omitFieldNames ? '' : 'configContent')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  WriteSidechainConfigRequest clone() => WriteSidechainConfigRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  WriteSidechainConfigRequest copyWith(void Function(WriteSidechainConfigRequest) updates) =>
      super.copyWith((message) => updates(message as WriteSidechainConfigRequest)) as WriteSidechainConfigRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WriteSidechainConfigRequest create() => WriteSidechainConfigRequest._();
  WriteSidechainConfigRequest createEmptyInstance() => create();
  static $pb.PbList<WriteSidechainConfigRequest> createRepeated() => $pb.PbList<WriteSidechainConfigRequest>();
  @$core.pragma('dart2js:noInline')
  static WriteSidechainConfigRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WriteSidechainConfigRequest>(create);
  static WriteSidechainConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sidechainName => $_getSZ(0);
  @$pb.TagNumber(1)
  set sidechainName($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSidechainName() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get configContent => $_getSZ(1);
  @$pb.TagNumber(2)
  set configContent($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasConfigContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfigContent() => clearField(2);
}

class WriteSidechainConfigResponse extends $pb.GeneratedMessage {
  factory WriteSidechainConfigResponse() => create();
  WriteSidechainConfigResponse._() : super();
  factory WriteSidechainConfigResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory WriteSidechainConfigResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteSidechainConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  WriteSidechainConfigResponse clone() => WriteSidechainConfigResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  WriteSidechainConfigResponse copyWith(void Function(WriteSidechainConfigResponse) updates) =>
      super.copyWith((message) => updates(message as WriteSidechainConfigResponse)) as WriteSidechainConfigResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WriteSidechainConfigResponse create() => WriteSidechainConfigResponse._();
  WriteSidechainConfigResponse createEmptyInstance() => create();
  static $pb.PbList<WriteSidechainConfigResponse> createRepeated() => $pb.PbList<WriteSidechainConfigResponse>();
  @$core.pragma('dart2js:noInline')
  static WriteSidechainConfigResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WriteSidechainConfigResponse>(create);
  static WriteSidechainConfigResponse? _defaultInstance;
}

class SyncSidechainNetworkFromBitcoinConfRequest extends $pb.GeneratedMessage {
  factory SyncSidechainNetworkFromBitcoinConfRequest({
    $core.String? sidechainName,
  }) {
    final $result = create();
    if (sidechainName != null) {
      $result.sidechainName = sidechainName;
    }
    return $result;
  }
  SyncSidechainNetworkFromBitcoinConfRequest._() : super();
  factory SyncSidechainNetworkFromBitcoinConfRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SyncSidechainNetworkFromBitcoinConfRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncSidechainNetworkFromBitcoinConfRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sidechainName')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SyncSidechainNetworkFromBitcoinConfRequest clone() =>
      SyncSidechainNetworkFromBitcoinConfRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SyncSidechainNetworkFromBitcoinConfRequest copyWith(
          void Function(SyncSidechainNetworkFromBitcoinConfRequest) updates) =>
      super.copyWith((message) => updates(message as SyncSidechainNetworkFromBitcoinConfRequest))
          as SyncSidechainNetworkFromBitcoinConfRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncSidechainNetworkFromBitcoinConfRequest create() => SyncSidechainNetworkFromBitcoinConfRequest._();
  SyncSidechainNetworkFromBitcoinConfRequest createEmptyInstance() => create();
  static $pb.PbList<SyncSidechainNetworkFromBitcoinConfRequest> createRepeated() =>
      $pb.PbList<SyncSidechainNetworkFromBitcoinConfRequest>();
  @$core.pragma('dart2js:noInline')
  static SyncSidechainNetworkFromBitcoinConfRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncSidechainNetworkFromBitcoinConfRequest>(create);
  static SyncSidechainNetworkFromBitcoinConfRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sidechainName => $_getSZ(0);
  @$pb.TagNumber(1)
  set sidechainName($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSidechainName() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainName() => clearField(1);
}

class SyncSidechainNetworkFromBitcoinConfResponse extends $pb.GeneratedMessage {
  factory SyncSidechainNetworkFromBitcoinConfResponse() => create();
  SyncSidechainNetworkFromBitcoinConfResponse._() : super();
  factory SyncSidechainNetworkFromBitcoinConfResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SyncSidechainNetworkFromBitcoinConfResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncSidechainNetworkFromBitcoinConfResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SyncSidechainNetworkFromBitcoinConfResponse clone() =>
      SyncSidechainNetworkFromBitcoinConfResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SyncSidechainNetworkFromBitcoinConfResponse copyWith(
          void Function(SyncSidechainNetworkFromBitcoinConfResponse) updates) =>
      super.copyWith((message) => updates(message as SyncSidechainNetworkFromBitcoinConfResponse))
          as SyncSidechainNetworkFromBitcoinConfResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncSidechainNetworkFromBitcoinConfResponse create() => SyncSidechainNetworkFromBitcoinConfResponse._();
  SyncSidechainNetworkFromBitcoinConfResponse createEmptyInstance() => create();
  static $pb.PbList<SyncSidechainNetworkFromBitcoinConfResponse> createRepeated() =>
      $pb.PbList<SyncSidechainNetworkFromBitcoinConfResponse>();
  @$core.pragma('dart2js:noInline')
  static SyncSidechainNetworkFromBitcoinConfResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncSidechainNetworkFromBitcoinConfResponse>(create);
  static SyncSidechainNetworkFromBitcoinConfResponse? _defaultInstance;
}

class SidechainConfServiceApi {
  $pb.RpcClient _client;
  SidechainConfServiceApi(this._client);

  $async.Future<GetSidechainConfigResponse> getSidechainConfig(
          $pb.ClientContext? ctx, GetSidechainConfigRequest request) =>
      _client.invoke<GetSidechainConfigResponse>(
          ctx, 'SidechainConfService', 'GetSidechainConfig', request, GetSidechainConfigResponse());
  $async.Future<WriteSidechainConfigResponse> writeSidechainConfig(
          $pb.ClientContext? ctx, WriteSidechainConfigRequest request) =>
      _client.invoke<WriteSidechainConfigResponse>(
          ctx, 'SidechainConfService', 'WriteSidechainConfig', request, WriteSidechainConfigResponse());
  $async.Future<SyncSidechainNetworkFromBitcoinConfResponse> syncSidechainNetworkFromBitcoinConf(
          $pb.ClientContext? ctx, SyncSidechainNetworkFromBitcoinConfRequest request) =>
      _client.invoke<SyncSidechainNetworkFromBitcoinConfResponse>(ctx, 'SidechainConfService',
          'SyncSidechainNetworkFromBitcoinConf', request, SyncSidechainNetworkFromBitcoinConfResponse());
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
