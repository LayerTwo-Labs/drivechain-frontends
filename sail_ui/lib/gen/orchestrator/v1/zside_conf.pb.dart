//
//  Generated code. Do not modify.
//  source: orchestrator/v1/zside_conf.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class GetZSideConfigRequest extends $pb.GeneratedMessage {
  factory GetZSideConfigRequest() => create();
  GetZSideConfigRequest._() : super();
  factory GetZSideConfigRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetZSideConfigRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetZSideConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetZSideConfigRequest clone() => GetZSideConfigRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetZSideConfigRequest copyWith(void Function(GetZSideConfigRequest) updates) =>
      super.copyWith((message) => updates(message as GetZSideConfigRequest)) as GetZSideConfigRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetZSideConfigRequest create() => GetZSideConfigRequest._();
  GetZSideConfigRequest createEmptyInstance() => create();
  static $pb.PbList<GetZSideConfigRequest> createRepeated() => $pb.PbList<GetZSideConfigRequest>();
  @$core.pragma('dart2js:noInline')
  static GetZSideConfigRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetZSideConfigRequest>(create);
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
  GetZSideConfigResponse._() : super();
  factory GetZSideConfigResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetZSideConfigResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetZSideConfigResponse',
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
  GetZSideConfigResponse clone() => GetZSideConfigResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetZSideConfigResponse copyWith(void Function(GetZSideConfigResponse) updates) =>
      super.copyWith((message) => updates(message as GetZSideConfigResponse)) as GetZSideConfigResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetZSideConfigResponse create() => GetZSideConfigResponse._();
  GetZSideConfigResponse createEmptyInstance() => create();
  static $pb.PbList<GetZSideConfigResponse> createRepeated() => $pb.PbList<GetZSideConfigResponse>();
  @$core.pragma('dart2js:noInline')
  static GetZSideConfigResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetZSideConfigResponse>(create);
  static GetZSideConfigResponse? _defaultInstance;

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

class WriteZSideConfigRequest extends $pb.GeneratedMessage {
  factory WriteZSideConfigRequest({
    $core.String? configContent,
  }) {
    final $result = create();
    if (configContent != null) {
      $result.configContent = configContent;
    }
    return $result;
  }
  WriteZSideConfigRequest._() : super();
  factory WriteZSideConfigRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory WriteZSideConfigRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteZSideConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'configContent')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  WriteZSideConfigRequest clone() => WriteZSideConfigRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  WriteZSideConfigRequest copyWith(void Function(WriteZSideConfigRequest) updates) =>
      super.copyWith((message) => updates(message as WriteZSideConfigRequest)) as WriteZSideConfigRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WriteZSideConfigRequest create() => WriteZSideConfigRequest._();
  WriteZSideConfigRequest createEmptyInstance() => create();
  static $pb.PbList<WriteZSideConfigRequest> createRepeated() => $pb.PbList<WriteZSideConfigRequest>();
  @$core.pragma('dart2js:noInline')
  static WriteZSideConfigRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WriteZSideConfigRequest>(create);
  static WriteZSideConfigRequest? _defaultInstance;

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

class WriteZSideConfigResponse extends $pb.GeneratedMessage {
  factory WriteZSideConfigResponse() => create();
  WriteZSideConfigResponse._() : super();
  factory WriteZSideConfigResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory WriteZSideConfigResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WriteZSideConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  WriteZSideConfigResponse clone() => WriteZSideConfigResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  WriteZSideConfigResponse copyWith(void Function(WriteZSideConfigResponse) updates) =>
      super.copyWith((message) => updates(message as WriteZSideConfigResponse)) as WriteZSideConfigResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WriteZSideConfigResponse create() => WriteZSideConfigResponse._();
  WriteZSideConfigResponse createEmptyInstance() => create();
  static $pb.PbList<WriteZSideConfigResponse> createRepeated() => $pb.PbList<WriteZSideConfigResponse>();
  @$core.pragma('dart2js:noInline')
  static WriteZSideConfigResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WriteZSideConfigResponse>(create);
  static WriteZSideConfigResponse? _defaultInstance;
}

class ZSideSyncNetworkFromBitcoinConfRequest extends $pb.GeneratedMessage {
  factory ZSideSyncNetworkFromBitcoinConfRequest() => create();
  ZSideSyncNetworkFromBitcoinConfRequest._() : super();
  factory ZSideSyncNetworkFromBitcoinConfRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ZSideSyncNetworkFromBitcoinConfRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ZSideSyncNetworkFromBitcoinConfRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ZSideSyncNetworkFromBitcoinConfRequest clone() => ZSideSyncNetworkFromBitcoinConfRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ZSideSyncNetworkFromBitcoinConfRequest copyWith(void Function(ZSideSyncNetworkFromBitcoinConfRequest) updates) =>
      super.copyWith((message) => updates(message as ZSideSyncNetworkFromBitcoinConfRequest))
          as ZSideSyncNetworkFromBitcoinConfRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ZSideSyncNetworkFromBitcoinConfRequest create() => ZSideSyncNetworkFromBitcoinConfRequest._();
  ZSideSyncNetworkFromBitcoinConfRequest createEmptyInstance() => create();
  static $pb.PbList<ZSideSyncNetworkFromBitcoinConfRequest> createRepeated() =>
      $pb.PbList<ZSideSyncNetworkFromBitcoinConfRequest>();
  @$core.pragma('dart2js:noInline')
  static ZSideSyncNetworkFromBitcoinConfRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ZSideSyncNetworkFromBitcoinConfRequest>(create);
  static ZSideSyncNetworkFromBitcoinConfRequest? _defaultInstance;
}

class ZSideSyncNetworkFromBitcoinConfResponse extends $pb.GeneratedMessage {
  factory ZSideSyncNetworkFromBitcoinConfResponse() => create();
  ZSideSyncNetworkFromBitcoinConfResponse._() : super();
  factory ZSideSyncNetworkFromBitcoinConfResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ZSideSyncNetworkFromBitcoinConfResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ZSideSyncNetworkFromBitcoinConfResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ZSideSyncNetworkFromBitcoinConfResponse clone() => ZSideSyncNetworkFromBitcoinConfResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ZSideSyncNetworkFromBitcoinConfResponse copyWith(void Function(ZSideSyncNetworkFromBitcoinConfResponse) updates) =>
      super.copyWith((message) => updates(message as ZSideSyncNetworkFromBitcoinConfResponse))
          as ZSideSyncNetworkFromBitcoinConfResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ZSideSyncNetworkFromBitcoinConfResponse create() => ZSideSyncNetworkFromBitcoinConfResponse._();
  ZSideSyncNetworkFromBitcoinConfResponse createEmptyInstance() => create();
  static $pb.PbList<ZSideSyncNetworkFromBitcoinConfResponse> createRepeated() =>
      $pb.PbList<ZSideSyncNetworkFromBitcoinConfResponse>();
  @$core.pragma('dart2js:noInline')
  static ZSideSyncNetworkFromBitcoinConfResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ZSideSyncNetworkFromBitcoinConfResponse>(create);
  static ZSideSyncNetworkFromBitcoinConfResponse? _defaultInstance;
}

class ZSideConfServiceApi {
  $pb.RpcClient _client;
  ZSideConfServiceApi(this._client);

  $async.Future<GetZSideConfigResponse> getZSideConfig($pb.ClientContext? ctx, GetZSideConfigRequest request) => _client
      .invoke<GetZSideConfigResponse>(ctx, 'ZSideConfService', 'GetZSideConfig', request, GetZSideConfigResponse());
  $async.Future<WriteZSideConfigResponse> writeZSideConfig($pb.ClientContext? ctx, WriteZSideConfigRequest request) =>
      _client.invoke<WriteZSideConfigResponse>(
          ctx, 'ZSideConfService', 'WriteZSideConfig', request, WriteZSideConfigResponse());
  $async.Future<ZSideSyncNetworkFromBitcoinConfResponse> syncNetworkFromBitcoinConf(
          $pb.ClientContext? ctx, ZSideSyncNetworkFromBitcoinConfRequest request) =>
      _client.invoke<ZSideSyncNetworkFromBitcoinConfResponse>(
          ctx, 'ZSideConfService', 'SyncNetworkFromBitcoinConf', request, ZSideSyncNetworkFromBitcoinConfResponse());
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
