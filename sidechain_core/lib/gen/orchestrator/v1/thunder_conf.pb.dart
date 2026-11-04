// This is a generated file - do not edit.
//
// Generated from orchestrator/v1/thunder_conf.proto.

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

class GetThunderConfigRequest extends $pb.GeneratedMessage {
  factory GetThunderConfigRequest() => GetThunderConfigRequest._();

  GetThunderConfigRequest._();

  factory GetThunderConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetThunderConfigRequest()..mergeFromBuffer(data, registry);
  factory GetThunderConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetThunderConfigRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetThunderConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetThunderConfigRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetThunderConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetThunderConfigRequest copyWith(void Function(GetThunderConfigRequest) updates) =>
      super.copyWith((message) => updates(message as GetThunderConfigRequest)) as GetThunderConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetThunderConfigRequest() / GetThunderConfigRequest.new instead')
  static GetThunderConfigRequest create() => GetThunderConfigRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetThunderConfigRequest._();
  @$core.override
  GetThunderConfigRequest createEmptyInstance() => GetThunderConfigRequest._();
  @$core.pragma('dart2js:noInline')
  static GetThunderConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetThunderConfigRequest>(GetThunderConfigRequest.$_createMessage);
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
    final result = GetThunderConfigResponse._();
    if (configContent != null) result.configContent = configContent;
    if (configPath != null) result.configPath = configPath;
    if (defaultConfig != null) result.defaultConfig = defaultConfig;
    if (cliArgs != null) result.cliArgs.addAll(cliArgs);
    if (network != null) result.network = network;
    return result;
  }

  GetThunderConfigResponse._();

  factory GetThunderConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetThunderConfigResponse()..mergeFromBuffer(data, registry);
  factory GetThunderConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetThunderConfigResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetThunderConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetThunderConfigResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'configContent')
    ..aOS(2, _omitFieldNames ? '' : 'configPath')
    ..aOS(3, _omitFieldNames ? '' : 'defaultConfig')
    ..pPS(4, _omitFieldNames ? '' : 'cliArgs')
    ..aOS(5, _omitFieldNames ? '' : 'network')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetThunderConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetThunderConfigResponse copyWith(void Function(GetThunderConfigResponse) updates) =>
      super.copyWith((message) => updates(message as GetThunderConfigResponse)) as GetThunderConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetThunderConfigResponse() / GetThunderConfigResponse.new instead')
  static GetThunderConfigResponse create() => GetThunderConfigResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetThunderConfigResponse._();
  @$core.override
  GetThunderConfigResponse createEmptyInstance() => GetThunderConfigResponse._();
  @$core.pragma('dart2js:noInline')
  static GetThunderConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetThunderConfigResponse>(GetThunderConfigResponse.$_createMessage);
  static GetThunderConfigResponse? _defaultInstance;

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
  $core.String get defaultConfig => $_getSZ(2);
  @$pb.TagNumber(3)
  set defaultConfig($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDefaultConfig() => $_has(2);
  @$pb.TagNumber(3)
  void clearDefaultConfig() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get cliArgs => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get network => $_getSZ(4);
  @$pb.TagNumber(5)
  set network($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNetwork() => $_has(4);
  @$pb.TagNumber(5)
  void clearNetwork() => $_clearField(5);
}

class WriteThunderConfigRequest extends $pb.GeneratedMessage {
  factory WriteThunderConfigRequest({
    $core.String? configContent,
  }) {
    final result = WriteThunderConfigRequest._();
    if (configContent != null) result.configContent = configContent;
    return result;
  }

  WriteThunderConfigRequest._();

  factory WriteThunderConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteThunderConfigRequest()..mergeFromBuffer(data, registry);
  factory WriteThunderConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteThunderConfigRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteThunderConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: WriteThunderConfigRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'configContent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteThunderConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteThunderConfigRequest copyWith(void Function(WriteThunderConfigRequest) updates) =>
      super.copyWith((message) => updates(message as WriteThunderConfigRequest)) as WriteThunderConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WriteThunderConfigRequest() / WriteThunderConfigRequest.new instead')
  static WriteThunderConfigRequest create() => WriteThunderConfigRequest._();
  static $pb.GeneratedMessage $_createMessage() => WriteThunderConfigRequest._();
  @$core.override
  WriteThunderConfigRequest createEmptyInstance() => WriteThunderConfigRequest._();
  @$core.pragma('dart2js:noInline')
  static WriteThunderConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WriteThunderConfigRequest>(WriteThunderConfigRequest.$_createMessage);
  static WriteThunderConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get configContent => $_getSZ(0);
  @$pb.TagNumber(1)
  set configContent($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfigContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfigContent() => $_clearField(1);
}

class WriteThunderConfigResponse extends $pb.GeneratedMessage {
  factory WriteThunderConfigResponse() => WriteThunderConfigResponse._();

  WriteThunderConfigResponse._();

  factory WriteThunderConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteThunderConfigResponse()..mergeFromBuffer(data, registry);
  factory WriteThunderConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteThunderConfigResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteThunderConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: WriteThunderConfigResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteThunderConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteThunderConfigResponse copyWith(void Function(WriteThunderConfigResponse) updates) =>
      super.copyWith((message) => updates(message as WriteThunderConfigResponse)) as WriteThunderConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WriteThunderConfigResponse() / WriteThunderConfigResponse.new instead')
  static WriteThunderConfigResponse create() => WriteThunderConfigResponse._();
  static $pb.GeneratedMessage $_createMessage() => WriteThunderConfigResponse._();
  @$core.override
  WriteThunderConfigResponse createEmptyInstance() => WriteThunderConfigResponse._();
  @$core.pragma('dart2js:noInline')
  static WriteThunderConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WriteThunderConfigResponse>(WriteThunderConfigResponse.$_createMessage);
  static WriteThunderConfigResponse? _defaultInstance;
}

class SyncNetworkFromBitcoinConfRequest extends $pb.GeneratedMessage {
  factory SyncNetworkFromBitcoinConfRequest() => SyncNetworkFromBitcoinConfRequest._();

  SyncNetworkFromBitcoinConfRequest._();

  factory SyncNetworkFromBitcoinConfRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncNetworkFromBitcoinConfRequest()..mergeFromBuffer(data, registry);
  factory SyncNetworkFromBitcoinConfRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncNetworkFromBitcoinConfRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncNetworkFromBitcoinConfRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: SyncNetworkFromBitcoinConfRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncNetworkFromBitcoinConfRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncNetworkFromBitcoinConfRequest copyWith(void Function(SyncNetworkFromBitcoinConfRequest) updates) =>
      super.copyWith((message) => updates(message as SyncNetworkFromBitcoinConfRequest))
          as SyncNetworkFromBitcoinConfRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SyncNetworkFromBitcoinConfRequest() / SyncNetworkFromBitcoinConfRequest.new instead')
  static SyncNetworkFromBitcoinConfRequest create() => SyncNetworkFromBitcoinConfRequest._();
  static $pb.GeneratedMessage $_createMessage() => SyncNetworkFromBitcoinConfRequest._();
  @$core.override
  SyncNetworkFromBitcoinConfRequest createEmptyInstance() => SyncNetworkFromBitcoinConfRequest._();
  @$core.pragma('dart2js:noInline')
  static SyncNetworkFromBitcoinConfRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncNetworkFromBitcoinConfRequest>(
          SyncNetworkFromBitcoinConfRequest.$_createMessage);
  static SyncNetworkFromBitcoinConfRequest? _defaultInstance;
}

class SyncNetworkFromBitcoinConfResponse extends $pb.GeneratedMessage {
  factory SyncNetworkFromBitcoinConfResponse() => SyncNetworkFromBitcoinConfResponse._();

  SyncNetworkFromBitcoinConfResponse._();

  factory SyncNetworkFromBitcoinConfResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncNetworkFromBitcoinConfResponse()..mergeFromBuffer(data, registry);
  factory SyncNetworkFromBitcoinConfResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncNetworkFromBitcoinConfResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncNetworkFromBitcoinConfResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: SyncNetworkFromBitcoinConfResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncNetworkFromBitcoinConfResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncNetworkFromBitcoinConfResponse copyWith(void Function(SyncNetworkFromBitcoinConfResponse) updates) =>
      super.copyWith((message) => updates(message as SyncNetworkFromBitcoinConfResponse))
          as SyncNetworkFromBitcoinConfResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SyncNetworkFromBitcoinConfResponse() / SyncNetworkFromBitcoinConfResponse.new instead')
  static SyncNetworkFromBitcoinConfResponse create() => SyncNetworkFromBitcoinConfResponse._();
  static $pb.GeneratedMessage $_createMessage() => SyncNetworkFromBitcoinConfResponse._();
  @$core.override
  SyncNetworkFromBitcoinConfResponse createEmptyInstance() => SyncNetworkFromBitcoinConfResponse._();
  @$core.pragma('dart2js:noInline')
  static SyncNetworkFromBitcoinConfResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncNetworkFromBitcoinConfResponse>(
          SyncNetworkFromBitcoinConfResponse.$_createMessage);
  static SyncNetworkFromBitcoinConfResponse? _defaultInstance;
}

class ThunderConfServiceApi {
  final $pb.RpcClient _client;

  ThunderConfServiceApi(this._client);

  /// Get current Thunder sidechain configuration state.
  $async.Future<GetThunderConfigResponse> getThunderConfig($pb.ClientContext? ctx, GetThunderConfigRequest request) =>
      _client.invoke<GetThunderConfigResponse>(
          ctx, 'ThunderConfService', 'GetThunderConfig', request, GetThunderConfigResponse());

  /// Write Thunder configuration content.
  $async.Future<WriteThunderConfigResponse> writeThunderConfig(
          $pb.ClientContext? ctx, WriteThunderConfigRequest request) =>
      _client.invoke<WriteThunderConfigResponse>(
          ctx, 'ThunderConfService', 'WriteThunderConfig', request, WriteThunderConfigResponse());

  /// Sync network from Bitcoin Core config.
  $async.Future<SyncNetworkFromBitcoinConfResponse> syncNetworkFromBitcoinConf(
          $pb.ClientContext? ctx, SyncNetworkFromBitcoinConfRequest request) =>
      _client.invoke<SyncNetworkFromBitcoinConfResponse>(
          ctx, 'ThunderConfService', 'SyncNetworkFromBitcoinConf', request, SyncNetworkFromBitcoinConfResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
