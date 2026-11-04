// This is a generated file - do not edit.
//
// Generated from orchestrator/v1/enforcer_conf.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class GetEnforcerConfigRequest extends $pb.GeneratedMessage {
  factory GetEnforcerConfigRequest() => GetEnforcerConfigRequest._();

  GetEnforcerConfigRequest._();

  factory GetEnforcerConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetEnforcerConfigRequest()..mergeFromBuffer(data, registry);
  factory GetEnforcerConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetEnforcerConfigRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetEnforcerConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetEnforcerConfigRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEnforcerConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEnforcerConfigRequest copyWith(void Function(GetEnforcerConfigRequest) updates) =>
      super.copyWith((message) => updates(message as GetEnforcerConfigRequest)) as GetEnforcerConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetEnforcerConfigRequest() / GetEnforcerConfigRequest.new instead')
  static GetEnforcerConfigRequest create() => GetEnforcerConfigRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetEnforcerConfigRequest._();
  @$core.override
  GetEnforcerConfigRequest createEmptyInstance() => GetEnforcerConfigRequest._();
  @$core.pragma('dart2js:noInline')
  static GetEnforcerConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetEnforcerConfigRequest>(GetEnforcerConfigRequest.$_createMessage);
  static GetEnforcerConfigRequest? _defaultInstance;
}

class GetEnforcerConfigResponse extends $pb.GeneratedMessage {
  factory GetEnforcerConfigResponse({
    $core.String? configContent,
    $core.String? configPath,
    $core.bool? nodeRpcDiffers,
    $core.String? defaultConfig,
    $core.Iterable<$core.String>? cliArgs,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? expectedNodeRpcSettings,
  }) {
    final result = GetEnforcerConfigResponse._();
    if (configContent != null) result.configContent = configContent;
    if (configPath != null) result.configPath = configPath;
    if (nodeRpcDiffers != null) result.nodeRpcDiffers = nodeRpcDiffers;
    if (defaultConfig != null) result.defaultConfig = defaultConfig;
    if (cliArgs != null) result.cliArgs.addAll(cliArgs);
    if (expectedNodeRpcSettings != null) result.expectedNodeRpcSettings.addEntries(expectedNodeRpcSettings);
    return result;
  }

  GetEnforcerConfigResponse._();

  factory GetEnforcerConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetEnforcerConfigResponse()..mergeFromBuffer(data, registry);
  factory GetEnforcerConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetEnforcerConfigResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetEnforcerConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetEnforcerConfigResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'configContent')
    ..aOS(2, _omitFieldNames ? '' : 'configPath')
    ..aOB(3, _omitFieldNames ? '' : 'nodeRpcDiffers')
    ..aOS(4, _omitFieldNames ? '' : 'defaultConfig')
    ..pPS(5, _omitFieldNames ? '' : 'cliArgs')
    ..m<$core.String, $core.String>(6, _omitFieldNames ? '' : 'expectedNodeRpcSettings',
        entryClassName: 'GetEnforcerConfigResponse.ExpectedNodeRpcSettingsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('orchestrator.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEnforcerConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEnforcerConfigResponse copyWith(void Function(GetEnforcerConfigResponse) updates) =>
      super.copyWith((message) => updates(message as GetEnforcerConfigResponse)) as GetEnforcerConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetEnforcerConfigResponse() / GetEnforcerConfigResponse.new instead')
  static GetEnforcerConfigResponse create() => GetEnforcerConfigResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetEnforcerConfigResponse._();
  @$core.override
  GetEnforcerConfigResponse createEmptyInstance() => GetEnforcerConfigResponse._();
  @$core.pragma('dart2js:noInline')
  static GetEnforcerConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetEnforcerConfigResponse>(GetEnforcerConfigResponse.$_createMessage);
  static GetEnforcerConfigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get configContent => $_getSZ(0);
  @$pb.TagNumber(1)
  set configContent($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfigContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfigContent() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get configPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set configPath($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConfigPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfigPath() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get nodeRpcDiffers => $_getBF(2);
  @$pb.TagNumber(3)
  set nodeRpcDiffers($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeRpcDiffers() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeRpcDiffers() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get defaultConfig => $_getSZ(3);
  @$pb.TagNumber(4)
  set defaultConfig($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDefaultConfig() => $_has(3);
  @$pb.TagNumber(4)
  void clearDefaultConfig() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get cliArgs => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbMap<$core.String, $core.String> get expectedNodeRpcSettings => $_getMap(5);
}

class WriteEnforcerConfigRequest extends $pb.GeneratedMessage {
  factory WriteEnforcerConfigRequest({
    $core.String? configContent,
  }) {
    final result = WriteEnforcerConfigRequest._();
    if (configContent != null) result.configContent = configContent;
    return result;
  }

  WriteEnforcerConfigRequest._();

  factory WriteEnforcerConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteEnforcerConfigRequest()..mergeFromBuffer(data, registry);
  factory WriteEnforcerConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteEnforcerConfigRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteEnforcerConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: WriteEnforcerConfigRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'configContent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteEnforcerConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteEnforcerConfigRequest copyWith(void Function(WriteEnforcerConfigRequest) updates) =>
      super.copyWith((message) => updates(message as WriteEnforcerConfigRequest)) as WriteEnforcerConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WriteEnforcerConfigRequest() / WriteEnforcerConfigRequest.new instead')
  static WriteEnforcerConfigRequest create() => WriteEnforcerConfigRequest._();
  static $pb.GeneratedMessage $_createMessage() => WriteEnforcerConfigRequest._();
  @$core.override
  WriteEnforcerConfigRequest createEmptyInstance() => WriteEnforcerConfigRequest._();
  @$core.pragma('dart2js:noInline')
  static WriteEnforcerConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WriteEnforcerConfigRequest>(WriteEnforcerConfigRequest.$_createMessage);
  static WriteEnforcerConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get configContent => $_getSZ(0);
  @$pb.TagNumber(1)
  set configContent($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfigContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfigContent() => $_clearField(1);
}

class WriteEnforcerConfigResponse extends $pb.GeneratedMessage {
  factory WriteEnforcerConfigResponse() => WriteEnforcerConfigResponse._();

  WriteEnforcerConfigResponse._();

  factory WriteEnforcerConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteEnforcerConfigResponse()..mergeFromBuffer(data, registry);
  factory WriteEnforcerConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteEnforcerConfigResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteEnforcerConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: WriteEnforcerConfigResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteEnforcerConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteEnforcerConfigResponse copyWith(void Function(WriteEnforcerConfigResponse) updates) =>
      super.copyWith((message) => updates(message as WriteEnforcerConfigResponse)) as WriteEnforcerConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WriteEnforcerConfigResponse() / WriteEnforcerConfigResponse.new instead')
  static WriteEnforcerConfigResponse create() => WriteEnforcerConfigResponse._();
  static $pb.GeneratedMessage $_createMessage() => WriteEnforcerConfigResponse._();
  @$core.override
  WriteEnforcerConfigResponse createEmptyInstance() => WriteEnforcerConfigResponse._();
  @$core.pragma('dart2js:noInline')
  static WriteEnforcerConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WriteEnforcerConfigResponse>(WriteEnforcerConfigResponse.$_createMessage);
  static WriteEnforcerConfigResponse? _defaultInstance;
}

class SyncNodeRpcFromBitcoinConfRequest extends $pb.GeneratedMessage {
  factory SyncNodeRpcFromBitcoinConfRequest() => SyncNodeRpcFromBitcoinConfRequest._();

  SyncNodeRpcFromBitcoinConfRequest._();

  factory SyncNodeRpcFromBitcoinConfRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncNodeRpcFromBitcoinConfRequest()..mergeFromBuffer(data, registry);
  factory SyncNodeRpcFromBitcoinConfRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncNodeRpcFromBitcoinConfRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncNodeRpcFromBitcoinConfRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: SyncNodeRpcFromBitcoinConfRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncNodeRpcFromBitcoinConfRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncNodeRpcFromBitcoinConfRequest copyWith(void Function(SyncNodeRpcFromBitcoinConfRequest) updates) =>
      super.copyWith((message) => updates(message as SyncNodeRpcFromBitcoinConfRequest))
          as SyncNodeRpcFromBitcoinConfRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SyncNodeRpcFromBitcoinConfRequest() / SyncNodeRpcFromBitcoinConfRequest.new instead')
  static SyncNodeRpcFromBitcoinConfRequest create() => SyncNodeRpcFromBitcoinConfRequest._();
  static $pb.GeneratedMessage $_createMessage() => SyncNodeRpcFromBitcoinConfRequest._();
  @$core.override
  SyncNodeRpcFromBitcoinConfRequest createEmptyInstance() => SyncNodeRpcFromBitcoinConfRequest._();
  @$core.pragma('dart2js:noInline')
  static SyncNodeRpcFromBitcoinConfRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncNodeRpcFromBitcoinConfRequest>(
          SyncNodeRpcFromBitcoinConfRequest.$_createMessage);
  static SyncNodeRpcFromBitcoinConfRequest? _defaultInstance;
}

class SyncNodeRpcFromBitcoinConfResponse extends $pb.GeneratedMessage {
  factory SyncNodeRpcFromBitcoinConfResponse() => SyncNodeRpcFromBitcoinConfResponse._();

  SyncNodeRpcFromBitcoinConfResponse._();

  factory SyncNodeRpcFromBitcoinConfResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncNodeRpcFromBitcoinConfResponse()..mergeFromBuffer(data, registry);
  factory SyncNodeRpcFromBitcoinConfResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncNodeRpcFromBitcoinConfResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncNodeRpcFromBitcoinConfResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: SyncNodeRpcFromBitcoinConfResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncNodeRpcFromBitcoinConfResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncNodeRpcFromBitcoinConfResponse copyWith(void Function(SyncNodeRpcFromBitcoinConfResponse) updates) =>
      super.copyWith((message) => updates(message as SyncNodeRpcFromBitcoinConfResponse))
          as SyncNodeRpcFromBitcoinConfResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SyncNodeRpcFromBitcoinConfResponse() / SyncNodeRpcFromBitcoinConfResponse.new instead')
  static SyncNodeRpcFromBitcoinConfResponse create() => SyncNodeRpcFromBitcoinConfResponse._();
  static $pb.GeneratedMessage $_createMessage() => SyncNodeRpcFromBitcoinConfResponse._();
  @$core.override
  SyncNodeRpcFromBitcoinConfResponse createEmptyInstance() => SyncNodeRpcFromBitcoinConfResponse._();
  @$core.pragma('dart2js:noInline')
  static SyncNodeRpcFromBitcoinConfResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncNodeRpcFromBitcoinConfResponse>(
          SyncNodeRpcFromBitcoinConfResponse.$_createMessage);
  static SyncNodeRpcFromBitcoinConfResponse? _defaultInstance;
}

class EnforcerConfServiceApi {
  final $pb.RpcClient _client;

  EnforcerConfServiceApi(this._client);

  /// Get current Enforcer configuration state.
  $async.Future<GetEnforcerConfigResponse> getEnforcerConfig(
          $pb.ClientContext? ctx, GetEnforcerConfigRequest request) =>
      _client.invoke<GetEnforcerConfigResponse>(
          ctx, 'EnforcerConfService', 'GetEnforcerConfig', request, GetEnforcerConfigResponse());

  /// Write Enforcer configuration content.
  $async.Future<WriteEnforcerConfigResponse> writeEnforcerConfig(
          $pb.ClientContext? ctx, WriteEnforcerConfigRequest request) =>
      _client.invoke<WriteEnforcerConfigResponse>(
          ctx, 'EnforcerConfService', 'WriteEnforcerConfig', request, WriteEnforcerConfigResponse());

  /// Sync node-rpc settings from Bitcoin Core config.
  $async.Future<SyncNodeRpcFromBitcoinConfResponse> syncNodeRpcFromBitcoinConf(
          $pb.ClientContext? ctx, SyncNodeRpcFromBitcoinConfRequest request) =>
      _client.invoke<SyncNodeRpcFromBitcoinConfResponse>(
          ctx, 'EnforcerConfService', 'SyncNodeRpcFromBitcoinConf', request, SyncNodeRpcFromBitcoinConfResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
