//
//  Generated code. Do not modify.
//  source: orchestrator/v1/thunder_conf.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class GetThunderConfigRequest extends $pb.GeneratedMessage {
  factory GetThunderConfigRequest() => create();
  GetThunderConfigRequest._() : super();
  factory GetThunderConfigRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetThunderConfigRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetThunderConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetThunderConfigRequest clone() => GetThunderConfigRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetThunderConfigRequest copyWith(void Function(GetThunderConfigRequest) updates) =>
      super.copyWith((message) => updates(message as GetThunderConfigRequest)) as GetThunderConfigRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetThunderConfigRequest create() => GetThunderConfigRequest._();
  GetThunderConfigRequest createEmptyInstance() => create();
  static $pb.PbList<GetThunderConfigRequest> createRepeated() => $pb.PbList<GetThunderConfigRequest>();
  @$core.pragma('dart2js:noInline')
  static GetThunderConfigRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetThunderConfigRequest>(create);
  static GetThunderConfigRequest? _defaultInstance;
}

class GetThunderConfigResponse extends $pb.GeneratedMessage {
  factory GetThunderConfigResponse({
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
  GetThunderConfigResponse._() : super();
  factory GetThunderConfigResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetThunderConfigResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetThunderConfigResponse',
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
  GetThunderConfigResponse clone() => GetThunderConfigResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetThunderConfigResponse copyWith(void Function(GetThunderConfigResponse) updates) =>
      super.copyWith((message) => updates(message as GetThunderConfigResponse)) as GetThunderConfigResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetThunderConfigResponse create() => GetThunderConfigResponse._();
  GetThunderConfigResponse createEmptyInstance() => create();
  static $pb.PbList<GetThunderConfigResponse> createRepeated() => $pb.PbList<GetThunderConfigResponse>();
  @$core.pragma('dart2js:noInline')
  static GetThunderConfigResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetThunderConfigResponse>(create);
  static GetThunderConfigResponse? _defaultInstance;

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

class WriteThunderConfigRequest extends $pb.GeneratedMessage {
  factory WriteThunderConfigRequest({
    $core.String? configContent,
  }) {
    final $result = create();
    if (configContent != null) {
      $result.configContent = configContent;
    }
    return $result;
  }
  WriteThunderConfigRequest._() : super();
  factory WriteThunderConfigRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory WriteThunderConfigRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteThunderConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'configContent')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  WriteThunderConfigRequest clone() => WriteThunderConfigRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  WriteThunderConfigRequest copyWith(void Function(WriteThunderConfigRequest) updates) =>
      super.copyWith((message) => updates(message as WriteThunderConfigRequest)) as WriteThunderConfigRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WriteThunderConfigRequest create() => WriteThunderConfigRequest._();
  WriteThunderConfigRequest createEmptyInstance() => create();
  static $pb.PbList<WriteThunderConfigRequest> createRepeated() => $pb.PbList<WriteThunderConfigRequest>();
  @$core.pragma('dart2js:noInline')
  static WriteThunderConfigRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WriteThunderConfigRequest>(create);
  static WriteThunderConfigRequest? _defaultInstance;

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

class WriteThunderConfigResponse extends $pb.GeneratedMessage {
  factory WriteThunderConfigResponse() => create();
  WriteThunderConfigResponse._() : super();
  factory WriteThunderConfigResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory WriteThunderConfigResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteThunderConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  WriteThunderConfigResponse clone() => WriteThunderConfigResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  WriteThunderConfigResponse copyWith(void Function(WriteThunderConfigResponse) updates) =>
      super.copyWith((message) => updates(message as WriteThunderConfigResponse)) as WriteThunderConfigResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WriteThunderConfigResponse create() => WriteThunderConfigResponse._();
  WriteThunderConfigResponse createEmptyInstance() => create();
  static $pb.PbList<WriteThunderConfigResponse> createRepeated() => $pb.PbList<WriteThunderConfigResponse>();
  @$core.pragma('dart2js:noInline')
  static WriteThunderConfigResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WriteThunderConfigResponse>(create);
  static WriteThunderConfigResponse? _defaultInstance;
}

class SyncNetworkFromBitcoinConfRequest extends $pb.GeneratedMessage {
  factory SyncNetworkFromBitcoinConfRequest() => create();
  SyncNetworkFromBitcoinConfRequest._() : super();
  factory SyncNetworkFromBitcoinConfRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SyncNetworkFromBitcoinConfRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncNetworkFromBitcoinConfRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SyncNetworkFromBitcoinConfRequest clone() => SyncNetworkFromBitcoinConfRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SyncNetworkFromBitcoinConfRequest copyWith(void Function(SyncNetworkFromBitcoinConfRequest) updates) =>
      super.copyWith((message) => updates(message as SyncNetworkFromBitcoinConfRequest))
          as SyncNetworkFromBitcoinConfRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncNetworkFromBitcoinConfRequest create() => SyncNetworkFromBitcoinConfRequest._();
  SyncNetworkFromBitcoinConfRequest createEmptyInstance() => create();
  static $pb.PbList<SyncNetworkFromBitcoinConfRequest> createRepeated() =>
      $pb.PbList<SyncNetworkFromBitcoinConfRequest>();
  @$core.pragma('dart2js:noInline')
  static SyncNetworkFromBitcoinConfRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncNetworkFromBitcoinConfRequest>(create);
  static SyncNetworkFromBitcoinConfRequest? _defaultInstance;
}

class SyncNetworkFromBitcoinConfResponse extends $pb.GeneratedMessage {
  factory SyncNetworkFromBitcoinConfResponse() => create();
  SyncNetworkFromBitcoinConfResponse._() : super();
  factory SyncNetworkFromBitcoinConfResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SyncNetworkFromBitcoinConfResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncNetworkFromBitcoinConfResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SyncNetworkFromBitcoinConfResponse clone() => SyncNetworkFromBitcoinConfResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SyncNetworkFromBitcoinConfResponse copyWith(void Function(SyncNetworkFromBitcoinConfResponse) updates) =>
      super.copyWith((message) => updates(message as SyncNetworkFromBitcoinConfResponse))
          as SyncNetworkFromBitcoinConfResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncNetworkFromBitcoinConfResponse create() => SyncNetworkFromBitcoinConfResponse._();
  SyncNetworkFromBitcoinConfResponse createEmptyInstance() => create();
  static $pb.PbList<SyncNetworkFromBitcoinConfResponse> createRepeated() =>
      $pb.PbList<SyncNetworkFromBitcoinConfResponse>();
  @$core.pragma('dart2js:noInline')
  static SyncNetworkFromBitcoinConfResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncNetworkFromBitcoinConfResponse>(create);
  static SyncNetworkFromBitcoinConfResponse? _defaultInstance;
}

class ThunderConfServiceApi {
  $pb.RpcClient _client;
  ThunderConfServiceApi(this._client);

  $async.Future<GetThunderConfigResponse> getThunderConfig($pb.ClientContext? ctx, GetThunderConfigRequest request) =>
      _client.invoke<GetThunderConfigResponse>(
          ctx, 'ThunderConfService', 'GetThunderConfig', request, GetThunderConfigResponse());
  $async.Future<WriteThunderConfigResponse> writeThunderConfig(
          $pb.ClientContext? ctx, WriteThunderConfigRequest request) =>
      _client.invoke<WriteThunderConfigResponse>(
          ctx, 'ThunderConfService', 'WriteThunderConfig', request, WriteThunderConfigResponse());
  $async.Future<SyncNetworkFromBitcoinConfResponse> syncNetworkFromBitcoinConf(
          $pb.ClientContext? ctx, SyncNetworkFromBitcoinConfRequest request) =>
      _client.invoke<SyncNetworkFromBitcoinConfResponse>(
          ctx, 'ThunderConfService', 'SyncNetworkFromBitcoinConf', request, SyncNetworkFromBitcoinConfResponse());
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
