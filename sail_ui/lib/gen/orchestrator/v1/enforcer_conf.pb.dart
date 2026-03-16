//
//  Generated code. Do not modify.
//  source: orchestrator/v1/enforcer_conf.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class GetEnforcerConfigRequest extends $pb.GeneratedMessage {
  factory GetEnforcerConfigRequest() => create();
  GetEnforcerConfigRequest._() : super();
  factory GetEnforcerConfigRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetEnforcerConfigRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetEnforcerConfigRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetEnforcerConfigRequest clone() => GetEnforcerConfigRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetEnforcerConfigRequest copyWith(void Function(GetEnforcerConfigRequest) updates) => super.copyWith((message) => updates(message as GetEnforcerConfigRequest)) as GetEnforcerConfigRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetEnforcerConfigRequest create() => GetEnforcerConfigRequest._();
  GetEnforcerConfigRequest createEmptyInstance() => create();
  static $pb.PbList<GetEnforcerConfigRequest> createRepeated() => $pb.PbList<GetEnforcerConfigRequest>();
  @$core.pragma('dart2js:noInline')
  static GetEnforcerConfigRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetEnforcerConfigRequest>(create);
  static GetEnforcerConfigRequest? _defaultInstance;
}

class GetEnforcerConfigResponse extends $pb.GeneratedMessage {
  factory GetEnforcerConfigResponse({
    $core.String? configContent,
    $core.String? configPath,
    $core.bool? nodeRpcDiffers,
    $core.String? defaultConfig,
    $core.Iterable<$core.String>? cliArgs,
    $core.Map<$core.String, $core.String>? expectedNodeRpcSettings,
  }) {
    final $result = create();
    if (configContent != null) {
      $result.configContent = configContent;
    }
    if (configPath != null) {
      $result.configPath = configPath;
    }
    if (nodeRpcDiffers != null) {
      $result.nodeRpcDiffers = nodeRpcDiffers;
    }
    if (defaultConfig != null) {
      $result.defaultConfig = defaultConfig;
    }
    if (cliArgs != null) {
      $result.cliArgs.addAll(cliArgs);
    }
    if (expectedNodeRpcSettings != null) {
      $result.expectedNodeRpcSettings.addAll(expectedNodeRpcSettings);
    }
    return $result;
  }
  GetEnforcerConfigResponse._() : super();
  factory GetEnforcerConfigResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetEnforcerConfigResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetEnforcerConfigResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'configContent')
    ..aOS(2, _omitFieldNames ? '' : 'configPath')
    ..aOB(3, _omitFieldNames ? '' : 'nodeRpcDiffers')
    ..aOS(4, _omitFieldNames ? '' : 'defaultConfig')
    ..pPS(5, _omitFieldNames ? '' : 'cliArgs')
    ..m<$core.String, $core.String>(6, _omitFieldNames ? '' : 'expectedNodeRpcSettings', entryClassName: 'GetEnforcerConfigResponse.ExpectedNodeRpcSettingsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('orchestrator.v1'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetEnforcerConfigResponse clone() => GetEnforcerConfigResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetEnforcerConfigResponse copyWith(void Function(GetEnforcerConfigResponse) updates) => super.copyWith((message) => updates(message as GetEnforcerConfigResponse)) as GetEnforcerConfigResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetEnforcerConfigResponse create() => GetEnforcerConfigResponse._();
  GetEnforcerConfigResponse createEmptyInstance() => create();
  static $pb.PbList<GetEnforcerConfigResponse> createRepeated() => $pb.PbList<GetEnforcerConfigResponse>();
  @$core.pragma('dart2js:noInline')
  static GetEnforcerConfigResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetEnforcerConfigResponse>(create);
  static GetEnforcerConfigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get configContent => $_getSZ(0);
  @$pb.TagNumber(1)
  set configContent($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConfigContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfigContent() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get configPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set configPath($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasConfigPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfigPath() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get nodeRpcDiffers => $_getBF(2);
  @$pb.TagNumber(3)
  set nodeRpcDiffers($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNodeRpcDiffers() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeRpcDiffers() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get defaultConfig => $_getSZ(3);
  @$pb.TagNumber(4)
  set defaultConfig($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDefaultConfig() => $_has(3);
  @$pb.TagNumber(4)
  void clearDefaultConfig() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.String> get cliArgs => $_getList(4);

  @$pb.TagNumber(6)
  $core.Map<$core.String, $core.String> get expectedNodeRpcSettings => $_getMap(5);
}

class WriteEnforcerConfigRequest extends $pb.GeneratedMessage {
  factory WriteEnforcerConfigRequest({
    $core.String? configContent,
  }) {
    final $result = create();
    if (configContent != null) {
      $result.configContent = configContent;
    }
    return $result;
  }
  WriteEnforcerConfigRequest._() : super();
  factory WriteEnforcerConfigRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WriteEnforcerConfigRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteEnforcerConfigRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'configContent')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WriteEnforcerConfigRequest clone() => WriteEnforcerConfigRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WriteEnforcerConfigRequest copyWith(void Function(WriteEnforcerConfigRequest) updates) => super.copyWith((message) => updates(message as WriteEnforcerConfigRequest)) as WriteEnforcerConfigRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WriteEnforcerConfigRequest create() => WriteEnforcerConfigRequest._();
  WriteEnforcerConfigRequest createEmptyInstance() => create();
  static $pb.PbList<WriteEnforcerConfigRequest> createRepeated() => $pb.PbList<WriteEnforcerConfigRequest>();
  @$core.pragma('dart2js:noInline')
  static WriteEnforcerConfigRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WriteEnforcerConfigRequest>(create);
  static WriteEnforcerConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get configContent => $_getSZ(0);
  @$pb.TagNumber(1)
  set configContent($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConfigContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfigContent() => clearField(1);
}

class WriteEnforcerConfigResponse extends $pb.GeneratedMessage {
  factory WriteEnforcerConfigResponse() => create();
  WriteEnforcerConfigResponse._() : super();
  factory WriteEnforcerConfigResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WriteEnforcerConfigResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteEnforcerConfigResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WriteEnforcerConfigResponse clone() => WriteEnforcerConfigResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WriteEnforcerConfigResponse copyWith(void Function(WriteEnforcerConfigResponse) updates) => super.copyWith((message) => updates(message as WriteEnforcerConfigResponse)) as WriteEnforcerConfigResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WriteEnforcerConfigResponse create() => WriteEnforcerConfigResponse._();
  WriteEnforcerConfigResponse createEmptyInstance() => create();
  static $pb.PbList<WriteEnforcerConfigResponse> createRepeated() => $pb.PbList<WriteEnforcerConfigResponse>();
  @$core.pragma('dart2js:noInline')
  static WriteEnforcerConfigResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WriteEnforcerConfigResponse>(create);
  static WriteEnforcerConfigResponse? _defaultInstance;
}

class SyncNodeRpcFromBitcoinConfRequest extends $pb.GeneratedMessage {
  factory SyncNodeRpcFromBitcoinConfRequest() => create();
  SyncNodeRpcFromBitcoinConfRequest._() : super();
  factory SyncNodeRpcFromBitcoinConfRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncNodeRpcFromBitcoinConfRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncNodeRpcFromBitcoinConfRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncNodeRpcFromBitcoinConfRequest clone() => SyncNodeRpcFromBitcoinConfRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncNodeRpcFromBitcoinConfRequest copyWith(void Function(SyncNodeRpcFromBitcoinConfRequest) updates) => super.copyWith((message) => updates(message as SyncNodeRpcFromBitcoinConfRequest)) as SyncNodeRpcFromBitcoinConfRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncNodeRpcFromBitcoinConfRequest create() => SyncNodeRpcFromBitcoinConfRequest._();
  SyncNodeRpcFromBitcoinConfRequest createEmptyInstance() => create();
  static $pb.PbList<SyncNodeRpcFromBitcoinConfRequest> createRepeated() => $pb.PbList<SyncNodeRpcFromBitcoinConfRequest>();
  @$core.pragma('dart2js:noInline')
  static SyncNodeRpcFromBitcoinConfRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncNodeRpcFromBitcoinConfRequest>(create);
  static SyncNodeRpcFromBitcoinConfRequest? _defaultInstance;
}

class SyncNodeRpcFromBitcoinConfResponse extends $pb.GeneratedMessage {
  factory SyncNodeRpcFromBitcoinConfResponse() => create();
  SyncNodeRpcFromBitcoinConfResponse._() : super();
  factory SyncNodeRpcFromBitcoinConfResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncNodeRpcFromBitcoinConfResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncNodeRpcFromBitcoinConfResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncNodeRpcFromBitcoinConfResponse clone() => SyncNodeRpcFromBitcoinConfResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncNodeRpcFromBitcoinConfResponse copyWith(void Function(SyncNodeRpcFromBitcoinConfResponse) updates) => super.copyWith((message) => updates(message as SyncNodeRpcFromBitcoinConfResponse)) as SyncNodeRpcFromBitcoinConfResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncNodeRpcFromBitcoinConfResponse create() => SyncNodeRpcFromBitcoinConfResponse._();
  SyncNodeRpcFromBitcoinConfResponse createEmptyInstance() => create();
  static $pb.PbList<SyncNodeRpcFromBitcoinConfResponse> createRepeated() => $pb.PbList<SyncNodeRpcFromBitcoinConfResponse>();
  @$core.pragma('dart2js:noInline')
  static SyncNodeRpcFromBitcoinConfResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncNodeRpcFromBitcoinConfResponse>(create);
  static SyncNodeRpcFromBitcoinConfResponse? _defaultInstance;
}

class EnforcerConfServiceApi {
  $pb.RpcClient _client;
  EnforcerConfServiceApi(this._client);

  $async.Future<GetEnforcerConfigResponse> getEnforcerConfig($pb.ClientContext? ctx, GetEnforcerConfigRequest request) =>
    _client.invoke<GetEnforcerConfigResponse>(ctx, 'EnforcerConfService', 'GetEnforcerConfig', request, GetEnforcerConfigResponse())
  ;
  $async.Future<WriteEnforcerConfigResponse> writeEnforcerConfig($pb.ClientContext? ctx, WriteEnforcerConfigRequest request) =>
    _client.invoke<WriteEnforcerConfigResponse>(ctx, 'EnforcerConfService', 'WriteEnforcerConfig', request, WriteEnforcerConfigResponse())
  ;
  $async.Future<SyncNodeRpcFromBitcoinConfResponse> syncNodeRpcFromBitcoinConf($pb.ClientContext? ctx, SyncNodeRpcFromBitcoinConfRequest request) =>
    _client.invoke<SyncNodeRpcFromBitcoinConfResponse>(ctx, 'EnforcerConfService', 'SyncNodeRpcFromBitcoinConf', request, SyncNodeRpcFromBitcoinConfResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
