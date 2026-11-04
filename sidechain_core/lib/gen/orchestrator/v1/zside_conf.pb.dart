// This is a generated file - do not edit.
//
// Generated from orchestrator/v1/zside_conf.proto.

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

class GetZSideConfigRequest extends $pb.GeneratedMessage {
  factory GetZSideConfigRequest() => GetZSideConfigRequest._();

  GetZSideConfigRequest._();

  factory GetZSideConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetZSideConfigRequest()..mergeFromBuffer(data, registry);
  factory GetZSideConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetZSideConfigRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetZSideConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetZSideConfigRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetZSideConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetZSideConfigRequest copyWith(void Function(GetZSideConfigRequest) updates) =>
      super.copyWith((message) => updates(message as GetZSideConfigRequest)) as GetZSideConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetZSideConfigRequest() / GetZSideConfigRequest.new instead')
  static GetZSideConfigRequest create() => GetZSideConfigRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetZSideConfigRequest._();
  @$core.override
  GetZSideConfigRequest createEmptyInstance() => GetZSideConfigRequest._();
  @$core.pragma('dart2js:noInline')
  static GetZSideConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetZSideConfigRequest>(GetZSideConfigRequest.$_createMessage);
  static GetZSideConfigRequest? _defaultInstance;
}

class GetZSideConfigResponse extends $pb.GeneratedMessage {
  factory GetZSideConfigResponse({
    $core.String? configContent,
    $core.String? configPath,
    $core.String? defaultConfig,
    $core.Iterable<$core.String>? cliArgs,
    $core.String? network,
  }) {
    final result = GetZSideConfigResponse._();
    if (configContent != null) result.configContent = configContent;
    if (configPath != null) result.configPath = configPath;
    if (defaultConfig != null) result.defaultConfig = defaultConfig;
    if (cliArgs != null) result.cliArgs.addAll(cliArgs);
    if (network != null) result.network = network;
    return result;
  }

  GetZSideConfigResponse._();

  factory GetZSideConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetZSideConfigResponse()..mergeFromBuffer(data, registry);
  factory GetZSideConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetZSideConfigResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetZSideConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetZSideConfigResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'configContent')
    ..aOS(2, _omitFieldNames ? '' : 'configPath')
    ..aOS(3, _omitFieldNames ? '' : 'defaultConfig')
    ..pPS(4, _omitFieldNames ? '' : 'cliArgs')
    ..aOS(5, _omitFieldNames ? '' : 'network')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetZSideConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetZSideConfigResponse copyWith(void Function(GetZSideConfigResponse) updates) =>
      super.copyWith((message) => updates(message as GetZSideConfigResponse)) as GetZSideConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetZSideConfigResponse() / GetZSideConfigResponse.new instead')
  static GetZSideConfigResponse create() => GetZSideConfigResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetZSideConfigResponse._();
  @$core.override
  GetZSideConfigResponse createEmptyInstance() => GetZSideConfigResponse._();
  @$core.pragma('dart2js:noInline')
  static GetZSideConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetZSideConfigResponse>(GetZSideConfigResponse.$_createMessage);
  static GetZSideConfigResponse? _defaultInstance;

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

class WriteZSideConfigRequest extends $pb.GeneratedMessage {
  factory WriteZSideConfigRequest({
    $core.String? configContent,
  }) {
    final result = WriteZSideConfigRequest._();
    if (configContent != null) result.configContent = configContent;
    return result;
  }

  WriteZSideConfigRequest._();

  factory WriteZSideConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteZSideConfigRequest()..mergeFromBuffer(data, registry);
  factory WriteZSideConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteZSideConfigRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteZSideConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: WriteZSideConfigRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'configContent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteZSideConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteZSideConfigRequest copyWith(void Function(WriteZSideConfigRequest) updates) =>
      super.copyWith((message) => updates(message as WriteZSideConfigRequest)) as WriteZSideConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WriteZSideConfigRequest() / WriteZSideConfigRequest.new instead')
  static WriteZSideConfigRequest create() => WriteZSideConfigRequest._();
  static $pb.GeneratedMessage $_createMessage() => WriteZSideConfigRequest._();
  @$core.override
  WriteZSideConfigRequest createEmptyInstance() => WriteZSideConfigRequest._();
  @$core.pragma('dart2js:noInline')
  static WriteZSideConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WriteZSideConfigRequest>(WriteZSideConfigRequest.$_createMessage);
  static WriteZSideConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get configContent => $_getSZ(0);
  @$pb.TagNumber(1)
  set configContent($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfigContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfigContent() => $_clearField(1);
}

class WriteZSideConfigResponse extends $pb.GeneratedMessage {
  factory WriteZSideConfigResponse() => WriteZSideConfigResponse._();

  WriteZSideConfigResponse._();

  factory WriteZSideConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteZSideConfigResponse()..mergeFromBuffer(data, registry);
  factory WriteZSideConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteZSideConfigResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteZSideConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: WriteZSideConfigResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteZSideConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteZSideConfigResponse copyWith(void Function(WriteZSideConfigResponse) updates) =>
      super.copyWith((message) => updates(message as WriteZSideConfigResponse)) as WriteZSideConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WriteZSideConfigResponse() / WriteZSideConfigResponse.new instead')
  static WriteZSideConfigResponse create() => WriteZSideConfigResponse._();
  static $pb.GeneratedMessage $_createMessage() => WriteZSideConfigResponse._();
  @$core.override
  WriteZSideConfigResponse createEmptyInstance() => WriteZSideConfigResponse._();
  @$core.pragma('dart2js:noInline')
  static WriteZSideConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WriteZSideConfigResponse>(WriteZSideConfigResponse.$_createMessage);
  static WriteZSideConfigResponse? _defaultInstance;
}

class ZSideSyncNetworkFromBitcoinConfRequest extends $pb.GeneratedMessage {
  factory ZSideSyncNetworkFromBitcoinConfRequest() => ZSideSyncNetworkFromBitcoinConfRequest._();

  ZSideSyncNetworkFromBitcoinConfRequest._();

  factory ZSideSyncNetworkFromBitcoinConfRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ZSideSyncNetworkFromBitcoinConfRequest()..mergeFromBuffer(data, registry);
  factory ZSideSyncNetworkFromBitcoinConfRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ZSideSyncNetworkFromBitcoinConfRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ZSideSyncNetworkFromBitcoinConfRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ZSideSyncNetworkFromBitcoinConfRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ZSideSyncNetworkFromBitcoinConfRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ZSideSyncNetworkFromBitcoinConfRequest copyWith(void Function(ZSideSyncNetworkFromBitcoinConfRequest) updates) =>
      super.copyWith((message) => updates(message as ZSideSyncNetworkFromBitcoinConfRequest))
          as ZSideSyncNetworkFromBitcoinConfRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ZSideSyncNetworkFromBitcoinConfRequest() / ZSideSyncNetworkFromBitcoinConfRequest.new instead')
  static ZSideSyncNetworkFromBitcoinConfRequest create() => ZSideSyncNetworkFromBitcoinConfRequest._();
  static $pb.GeneratedMessage $_createMessage() => ZSideSyncNetworkFromBitcoinConfRequest._();
  @$core.override
  ZSideSyncNetworkFromBitcoinConfRequest createEmptyInstance() => ZSideSyncNetworkFromBitcoinConfRequest._();
  @$core.pragma('dart2js:noInline')
  static ZSideSyncNetworkFromBitcoinConfRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ZSideSyncNetworkFromBitcoinConfRequest>(
          ZSideSyncNetworkFromBitcoinConfRequest.$_createMessage);
  static ZSideSyncNetworkFromBitcoinConfRequest? _defaultInstance;
}

class ZSideSyncNetworkFromBitcoinConfResponse extends $pb.GeneratedMessage {
  factory ZSideSyncNetworkFromBitcoinConfResponse() => ZSideSyncNetworkFromBitcoinConfResponse._();

  ZSideSyncNetworkFromBitcoinConfResponse._();

  factory ZSideSyncNetworkFromBitcoinConfResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ZSideSyncNetworkFromBitcoinConfResponse()..mergeFromBuffer(data, registry);
  factory ZSideSyncNetworkFromBitcoinConfResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ZSideSyncNetworkFromBitcoinConfResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ZSideSyncNetworkFromBitcoinConfResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ZSideSyncNetworkFromBitcoinConfResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ZSideSyncNetworkFromBitcoinConfResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ZSideSyncNetworkFromBitcoinConfResponse copyWith(void Function(ZSideSyncNetworkFromBitcoinConfResponse) updates) =>
      super.copyWith((message) => updates(message as ZSideSyncNetworkFromBitcoinConfResponse))
          as ZSideSyncNetworkFromBitcoinConfResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ZSideSyncNetworkFromBitcoinConfResponse() / ZSideSyncNetworkFromBitcoinConfResponse.new instead')
  static ZSideSyncNetworkFromBitcoinConfResponse create() => ZSideSyncNetworkFromBitcoinConfResponse._();
  static $pb.GeneratedMessage $_createMessage() => ZSideSyncNetworkFromBitcoinConfResponse._();
  @$core.override
  ZSideSyncNetworkFromBitcoinConfResponse createEmptyInstance() => ZSideSyncNetworkFromBitcoinConfResponse._();
  @$core.pragma('dart2js:noInline')
  static ZSideSyncNetworkFromBitcoinConfResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ZSideSyncNetworkFromBitcoinConfResponse>(
          ZSideSyncNetworkFromBitcoinConfResponse.$_createMessage);
  static ZSideSyncNetworkFromBitcoinConfResponse? _defaultInstance;
}

class ZSideConfServiceApi {
  final $pb.RpcClient _client;

  ZSideConfServiceApi(this._client);

  /// Get current ZSide sidechain configuration state.
  $async.Future<GetZSideConfigResponse> getZSideConfig($pb.ClientContext? ctx, GetZSideConfigRequest request) => _client
      .invoke<GetZSideConfigResponse>(ctx, 'ZSideConfService', 'GetZSideConfig', request, GetZSideConfigResponse());

  /// Write ZSide configuration content.
  $async.Future<WriteZSideConfigResponse> writeZSideConfig($pb.ClientContext? ctx, WriteZSideConfigRequest request) =>
      _client.invoke<WriteZSideConfigResponse>(
          ctx, 'ZSideConfService', 'WriteZSideConfig', request, WriteZSideConfigResponse());

  /// Sync network from Bitcoin Core config.
  $async.Future<ZSideSyncNetworkFromBitcoinConfResponse> syncNetworkFromBitcoinConf(
          $pb.ClientContext? ctx, ZSideSyncNetworkFromBitcoinConfRequest request) =>
      _client.invoke<ZSideSyncNetworkFromBitcoinConfResponse>(
          ctx, 'ZSideConfService', 'SyncNetworkFromBitcoinConf', request, ZSideSyncNetworkFromBitcoinConfResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
