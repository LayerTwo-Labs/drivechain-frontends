// This is a generated file - do not edit.
//
// Generated from orchestrator/v1/sidechain_conf.proto.

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

class GetSidechainConfigRequest extends $pb.GeneratedMessage {
  factory GetSidechainConfigRequest({
    $core.String? sidechainName,
  }) {
    final result = GetSidechainConfigRequest._();
    if (sidechainName != null) result.sidechainName = sidechainName;
    return result;
  }

  GetSidechainConfigRequest._();

  factory GetSidechainConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainConfigRequest()..mergeFromBuffer(data, registry);
  factory GetSidechainConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainConfigRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetSidechainConfigRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sidechainName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainConfigRequest copyWith(void Function(GetSidechainConfigRequest) updates) =>
      super.copyWith((message) => updates(message as GetSidechainConfigRequest)) as GetSidechainConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSidechainConfigRequest() / GetSidechainConfigRequest.new instead')
  static GetSidechainConfigRequest create() => GetSidechainConfigRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainConfigRequest._();
  @$core.override
  GetSidechainConfigRequest createEmptyInstance() => GetSidechainConfigRequest._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSidechainConfigRequest>(GetSidechainConfigRequest.$_createMessage);
  static GetSidechainConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sidechainName => $_getSZ(0);
  @$pb.TagNumber(1)
  set sidechainName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechainName() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainName() => $_clearField(1);
}

class GetSidechainConfigResponse extends $pb.GeneratedMessage {
  factory GetSidechainConfigResponse({
    $core.String? configContent,
    $core.String? configPath,
    $core.String? defaultConfig,
    $core.Iterable<$core.String>? cliArgs,
    $core.String? network,
  }) {
    final result = GetSidechainConfigResponse._();
    if (configContent != null) result.configContent = configContent;
    if (configPath != null) result.configPath = configPath;
    if (defaultConfig != null) result.defaultConfig = defaultConfig;
    if (cliArgs != null) result.cliArgs.addAll(cliArgs);
    if (network != null) result.network = network;
    return result;
  }

  GetSidechainConfigResponse._();

  factory GetSidechainConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainConfigResponse()..mergeFromBuffer(data, registry);
  factory GetSidechainConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainConfigResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetSidechainConfigResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'configContent')
    ..aOS(2, _omitFieldNames ? '' : 'configPath')
    ..aOS(3, _omitFieldNames ? '' : 'defaultConfig')
    ..pPS(4, _omitFieldNames ? '' : 'cliArgs')
    ..aOS(5, _omitFieldNames ? '' : 'network')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainConfigResponse copyWith(void Function(GetSidechainConfigResponse) updates) =>
      super.copyWith((message) => updates(message as GetSidechainConfigResponse)) as GetSidechainConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSidechainConfigResponse() / GetSidechainConfigResponse.new instead')
  static GetSidechainConfigResponse create() => GetSidechainConfigResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainConfigResponse._();
  @$core.override
  GetSidechainConfigResponse createEmptyInstance() => GetSidechainConfigResponse._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSidechainConfigResponse>(GetSidechainConfigResponse.$_createMessage);
  static GetSidechainConfigResponse? _defaultInstance;

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

class WriteSidechainConfigRequest extends $pb.GeneratedMessage {
  factory WriteSidechainConfigRequest({
    $core.String? sidechainName,
    $core.String? configContent,
  }) {
    final result = WriteSidechainConfigRequest._();
    if (sidechainName != null) result.sidechainName = sidechainName;
    if (configContent != null) result.configContent = configContent;
    return result;
  }

  WriteSidechainConfigRequest._();

  factory WriteSidechainConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteSidechainConfigRequest()..mergeFromBuffer(data, registry);
  factory WriteSidechainConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteSidechainConfigRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteSidechainConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: WriteSidechainConfigRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sidechainName')
    ..aOS(2, _omitFieldNames ? '' : 'configContent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteSidechainConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteSidechainConfigRequest copyWith(void Function(WriteSidechainConfigRequest) updates) =>
      super.copyWith((message) => updates(message as WriteSidechainConfigRequest)) as WriteSidechainConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WriteSidechainConfigRequest() / WriteSidechainConfigRequest.new instead')
  static WriteSidechainConfigRequest create() => WriteSidechainConfigRequest._();
  static $pb.GeneratedMessage $_createMessage() => WriteSidechainConfigRequest._();
  @$core.override
  WriteSidechainConfigRequest createEmptyInstance() => WriteSidechainConfigRequest._();
  @$core.pragma('dart2js:noInline')
  static WriteSidechainConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WriteSidechainConfigRequest>(WriteSidechainConfigRequest.$_createMessage);
  static WriteSidechainConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sidechainName => $_getSZ(0);
  @$pb.TagNumber(1)
  set sidechainName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechainName() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get configContent => $_getSZ(1);
  @$pb.TagNumber(2)
  set configContent($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConfigContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfigContent() => $_clearField(2);
}

class WriteSidechainConfigResponse extends $pb.GeneratedMessage {
  factory WriteSidechainConfigResponse() => WriteSidechainConfigResponse._();

  WriteSidechainConfigResponse._();

  factory WriteSidechainConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteSidechainConfigResponse()..mergeFromBuffer(data, registry);
  factory WriteSidechainConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WriteSidechainConfigResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteSidechainConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: WriteSidechainConfigResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteSidechainConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteSidechainConfigResponse copyWith(void Function(WriteSidechainConfigResponse) updates) =>
      super.copyWith((message) => updates(message as WriteSidechainConfigResponse)) as WriteSidechainConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WriteSidechainConfigResponse() / WriteSidechainConfigResponse.new instead')
  static WriteSidechainConfigResponse create() => WriteSidechainConfigResponse._();
  static $pb.GeneratedMessage $_createMessage() => WriteSidechainConfigResponse._();
  @$core.override
  WriteSidechainConfigResponse createEmptyInstance() => WriteSidechainConfigResponse._();
  @$core.pragma('dart2js:noInline')
  static WriteSidechainConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WriteSidechainConfigResponse>(WriteSidechainConfigResponse.$_createMessage);
  static WriteSidechainConfigResponse? _defaultInstance;
}

class SyncSidechainNetworkFromBitcoinConfRequest extends $pb.GeneratedMessage {
  factory SyncSidechainNetworkFromBitcoinConfRequest({
    $core.String? sidechainName,
  }) {
    final result = SyncSidechainNetworkFromBitcoinConfRequest._();
    if (sidechainName != null) result.sidechainName = sidechainName;
    return result;
  }

  SyncSidechainNetworkFromBitcoinConfRequest._();

  factory SyncSidechainNetworkFromBitcoinConfRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncSidechainNetworkFromBitcoinConfRequest()..mergeFromBuffer(data, registry);
  factory SyncSidechainNetworkFromBitcoinConfRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncSidechainNetworkFromBitcoinConfRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncSidechainNetworkFromBitcoinConfRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: SyncSidechainNetworkFromBitcoinConfRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sidechainName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncSidechainNetworkFromBitcoinConfRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncSidechainNetworkFromBitcoinConfRequest copyWith(
          void Function(SyncSidechainNetworkFromBitcoinConfRequest) updates) =>
      super.copyWith((message) => updates(message as SyncSidechainNetworkFromBitcoinConfRequest))
          as SyncSidechainNetworkFromBitcoinConfRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SyncSidechainNetworkFromBitcoinConfRequest() / SyncSidechainNetworkFromBitcoinConfRequest.new instead')
  static SyncSidechainNetworkFromBitcoinConfRequest create() => SyncSidechainNetworkFromBitcoinConfRequest._();
  static $pb.GeneratedMessage $_createMessage() => SyncSidechainNetworkFromBitcoinConfRequest._();
  @$core.override
  SyncSidechainNetworkFromBitcoinConfRequest createEmptyInstance() => SyncSidechainNetworkFromBitcoinConfRequest._();
  @$core.pragma('dart2js:noInline')
  static SyncSidechainNetworkFromBitcoinConfRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncSidechainNetworkFromBitcoinConfRequest>(
          SyncSidechainNetworkFromBitcoinConfRequest.$_createMessage);
  static SyncSidechainNetworkFromBitcoinConfRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sidechainName => $_getSZ(0);
  @$pb.TagNumber(1)
  set sidechainName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechainName() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainName() => $_clearField(1);
}

class SyncSidechainNetworkFromBitcoinConfResponse extends $pb.GeneratedMessage {
  factory SyncSidechainNetworkFromBitcoinConfResponse() => SyncSidechainNetworkFromBitcoinConfResponse._();

  SyncSidechainNetworkFromBitcoinConfResponse._();

  factory SyncSidechainNetworkFromBitcoinConfResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncSidechainNetworkFromBitcoinConfResponse()..mergeFromBuffer(data, registry);
  factory SyncSidechainNetworkFromBitcoinConfResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncSidechainNetworkFromBitcoinConfResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncSidechainNetworkFromBitcoinConfResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: SyncSidechainNetworkFromBitcoinConfResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncSidechainNetworkFromBitcoinConfResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncSidechainNetworkFromBitcoinConfResponse copyWith(
          void Function(SyncSidechainNetworkFromBitcoinConfResponse) updates) =>
      super.copyWith((message) => updates(message as SyncSidechainNetworkFromBitcoinConfResponse))
          as SyncSidechainNetworkFromBitcoinConfResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SyncSidechainNetworkFromBitcoinConfResponse() / SyncSidechainNetworkFromBitcoinConfResponse.new instead')
  static SyncSidechainNetworkFromBitcoinConfResponse create() => SyncSidechainNetworkFromBitcoinConfResponse._();
  static $pb.GeneratedMessage $_createMessage() => SyncSidechainNetworkFromBitcoinConfResponse._();
  @$core.override
  SyncSidechainNetworkFromBitcoinConfResponse createEmptyInstance() => SyncSidechainNetworkFromBitcoinConfResponse._();
  @$core.pragma('dart2js:noInline')
  static SyncSidechainNetworkFromBitcoinConfResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncSidechainNetworkFromBitcoinConfResponse>(
          SyncSidechainNetworkFromBitcoinConfResponse.$_createMessage);
  static SyncSidechainNetworkFromBitcoinConfResponse? _defaultInstance;
}

class SidechainConfServiceApi {
  final $pb.RpcClient _client;

  SidechainConfServiceApi(this._client);

  /// Get current sidechain configuration state.
  $async.Future<GetSidechainConfigResponse> getSidechainConfig(
          $pb.ClientContext? ctx, GetSidechainConfigRequest request) =>
      _client.invoke<GetSidechainConfigResponse>(
          ctx, 'SidechainConfService', 'GetSidechainConfig', request, GetSidechainConfigResponse());

  /// Write sidechain configuration content.
  $async.Future<WriteSidechainConfigResponse> writeSidechainConfig(
          $pb.ClientContext? ctx, WriteSidechainConfigRequest request) =>
      _client.invoke<WriteSidechainConfigResponse>(
          ctx, 'SidechainConfService', 'WriteSidechainConfig', request, WriteSidechainConfigResponse());

  /// Sync network from Bitcoin Core config.
  $async.Future<SyncSidechainNetworkFromBitcoinConfResponse> syncSidechainNetworkFromBitcoinConf(
          $pb.ClientContext? ctx, SyncSidechainNetworkFromBitcoinConfRequest request) =>
      _client.invoke<SyncSidechainNetworkFromBitcoinConfResponse>(ctx, 'SidechainConfService',
          'SyncSidechainNetworkFromBitcoinConf', request, SyncSidechainNetworkFromBitcoinConfResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
