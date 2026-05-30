//
//  Generated code. Do not modify.
//  source: orchestrator/v1/orchestrator.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'orchestrator.pbenum.dart';

export 'orchestrator.pbenum.dart';

class BinaryStatusMsg extends $pb.GeneratedMessage {
  factory BinaryStatusMsg({
    $core.String? name,
    $core.String? displayName,
    $core.bool? running,
    $core.bool? healthy,
    $core.int? pid,
    $fixnum.Int64? uptimeSeconds,
    $core.int? chainLayer,
    $core.int? port,
    $core.String? error,
    $core.bool? connected,
    $core.String? startupError,
    $core.String? connectionError,
    $core.bool? stopping,
    $core.bool? initializing,
    $core.bool? connectModeOnly,
    $core.bool? downloadable,
    $core.String? description,
    $core.bool? downloaded,
    $core.bool? portInUse,
    $core.String? version,
    $core.String? repoUrl,
    $core.Iterable<StartupLogEntryMsg>? startupLogs,
    $core.String? binaryPath,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (displayName != null) {
      $result.displayName = displayName;
    }
    if (running != null) {
      $result.running = running;
    }
    if (healthy != null) {
      $result.healthy = healthy;
    }
    if (pid != null) {
      $result.pid = pid;
    }
    if (uptimeSeconds != null) {
      $result.uptimeSeconds = uptimeSeconds;
    }
    if (chainLayer != null) {
      $result.chainLayer = chainLayer;
    }
    if (port != null) {
      $result.port = port;
    }
    if (error != null) {
      $result.error = error;
    }
    if (connected != null) {
      $result.connected = connected;
    }
    if (startupError != null) {
      $result.startupError = startupError;
    }
    if (connectionError != null) {
      $result.connectionError = connectionError;
    }
    if (stopping != null) {
      $result.stopping = stopping;
    }
    if (initializing != null) {
      $result.initializing = initializing;
    }
    if (connectModeOnly != null) {
      $result.connectModeOnly = connectModeOnly;
    }
    if (downloadable != null) {
      $result.downloadable = downloadable;
    }
    if (description != null) {
      $result.description = description;
    }
    if (downloaded != null) {
      $result.downloaded = downloaded;
    }
    if (portInUse != null) {
      $result.portInUse = portInUse;
    }
    if (version != null) {
      $result.version = version;
    }
    if (repoUrl != null) {
      $result.repoUrl = repoUrl;
    }
    if (startupLogs != null) {
      $result.startupLogs.addAll(startupLogs);
    }
    if (binaryPath != null) {
      $result.binaryPath = binaryPath;
    }
    return $result;
  }
  BinaryStatusMsg._() : super();
  factory BinaryStatusMsg.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BinaryStatusMsg.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BinaryStatusMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOB(3, _omitFieldNames ? '' : 'running')
    ..aOB(4, _omitFieldNames ? '' : 'healthy')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'pid', $pb.PbFieldType.O3)
    ..aInt64(6, _omitFieldNames ? '' : 'uptimeSeconds')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'chainLayer', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'port', $pb.PbFieldType.O3)
    ..aOS(9, _omitFieldNames ? '' : 'error')
    ..aOB(10, _omitFieldNames ? '' : 'connected')
    ..aOS(11, _omitFieldNames ? '' : 'startupError')
    ..aOS(12, _omitFieldNames ? '' : 'connectionError')
    ..aOB(13, _omitFieldNames ? '' : 'stopping')
    ..aOB(14, _omitFieldNames ? '' : 'initializing')
    ..aOB(15, _omitFieldNames ? '' : 'connectModeOnly')
    ..aOB(16, _omitFieldNames ? '' : 'downloadable')
    ..aOS(17, _omitFieldNames ? '' : 'description')
    ..aOB(18, _omitFieldNames ? '' : 'downloaded')
    ..aOB(19, _omitFieldNames ? '' : 'portInUse')
    ..aOS(20, _omitFieldNames ? '' : 'version')
    ..aOS(21, _omitFieldNames ? '' : 'repoUrl')
    ..pc<StartupLogEntryMsg>(22, _omitFieldNames ? '' : 'startupLogs', $pb.PbFieldType.PM, subBuilder: StartupLogEntryMsg.create)
    ..aOS(23, _omitFieldNames ? '' : 'binaryPath')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BinaryStatusMsg clone() => BinaryStatusMsg()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BinaryStatusMsg copyWith(void Function(BinaryStatusMsg) updates) => super.copyWith((message) => updates(message as BinaryStatusMsg)) as BinaryStatusMsg;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BinaryStatusMsg create() => BinaryStatusMsg._();
  BinaryStatusMsg createEmptyInstance() => create();
  static $pb.PbList<BinaryStatusMsg> createRepeated() => $pb.PbList<BinaryStatusMsg>();
  @$core.pragma('dart2js:noInline')
  static BinaryStatusMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BinaryStatusMsg>(create);
  static BinaryStatusMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get running => $_getBF(2);
  @$pb.TagNumber(3)
  set running($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRunning() => $_has(2);
  @$pb.TagNumber(3)
  void clearRunning() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get healthy => $_getBF(3);
  @$pb.TagNumber(4)
  set healthy($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHealthy() => $_has(3);
  @$pb.TagNumber(4)
  void clearHealthy() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get pid => $_getIZ(4);
  @$pb.TagNumber(5)
  set pid($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPid() => $_has(4);
  @$pb.TagNumber(5)
  void clearPid() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get uptimeSeconds => $_getI64(5);
  @$pb.TagNumber(6)
  set uptimeSeconds($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasUptimeSeconds() => $_has(5);
  @$pb.TagNumber(6)
  void clearUptimeSeconds() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get chainLayer => $_getIZ(6);
  @$pb.TagNumber(7)
  set chainLayer($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasChainLayer() => $_has(6);
  @$pb.TagNumber(7)
  void clearChainLayer() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get port => $_getIZ(7);
  @$pb.TagNumber(8)
  set port($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasPort() => $_has(7);
  @$pb.TagNumber(8)
  void clearPort() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get error => $_getSZ(8);
  @$pb.TagNumber(9)
  set error($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasError() => $_has(8);
  @$pb.TagNumber(9)
  void clearError() => clearField(9);

  @$pb.TagNumber(10)
  $core.bool get connected => $_getBF(9);
  @$pb.TagNumber(10)
  set connected($core.bool v) { $_setBool(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasConnected() => $_has(9);
  @$pb.TagNumber(10)
  void clearConnected() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get startupError => $_getSZ(10);
  @$pb.TagNumber(11)
  set startupError($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasStartupError() => $_has(10);
  @$pb.TagNumber(11)
  void clearStartupError() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get connectionError => $_getSZ(11);
  @$pb.TagNumber(12)
  set connectionError($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasConnectionError() => $_has(11);
  @$pb.TagNumber(12)
  void clearConnectionError() => clearField(12);

  @$pb.TagNumber(13)
  $core.bool get stopping => $_getBF(12);
  @$pb.TagNumber(13)
  set stopping($core.bool v) { $_setBool(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasStopping() => $_has(12);
  @$pb.TagNumber(13)
  void clearStopping() => clearField(13);

  @$pb.TagNumber(14)
  $core.bool get initializing => $_getBF(13);
  @$pb.TagNumber(14)
  set initializing($core.bool v) { $_setBool(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasInitializing() => $_has(13);
  @$pb.TagNumber(14)
  void clearInitializing() => clearField(14);

  @$pb.TagNumber(15)
  $core.bool get connectModeOnly => $_getBF(14);
  @$pb.TagNumber(15)
  set connectModeOnly($core.bool v) { $_setBool(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasConnectModeOnly() => $_has(14);
  @$pb.TagNumber(15)
  void clearConnectModeOnly() => clearField(15);

  @$pb.TagNumber(16)
  $core.bool get downloadable => $_getBF(15);
  @$pb.TagNumber(16)
  set downloadable($core.bool v) { $_setBool(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasDownloadable() => $_has(15);
  @$pb.TagNumber(16)
  void clearDownloadable() => clearField(16);

  @$pb.TagNumber(17)
  $core.String get description => $_getSZ(16);
  @$pb.TagNumber(17)
  set description($core.String v) { $_setString(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasDescription() => $_has(16);
  @$pb.TagNumber(17)
  void clearDescription() => clearField(17);

  @$pb.TagNumber(18)
  $core.bool get downloaded => $_getBF(17);
  @$pb.TagNumber(18)
  set downloaded($core.bool v) { $_setBool(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasDownloaded() => $_has(17);
  @$pb.TagNumber(18)
  void clearDownloaded() => clearField(18);

  @$pb.TagNumber(19)
  $core.bool get portInUse => $_getBF(18);
  @$pb.TagNumber(19)
  set portInUse($core.bool v) { $_setBool(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasPortInUse() => $_has(18);
  @$pb.TagNumber(19)
  void clearPortInUse() => clearField(19);

  @$pb.TagNumber(20)
  $core.String get version => $_getSZ(19);
  @$pb.TagNumber(20)
  set version($core.String v) { $_setString(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasVersion() => $_has(19);
  @$pb.TagNumber(20)
  void clearVersion() => clearField(20);

  @$pb.TagNumber(21)
  $core.String get repoUrl => $_getSZ(20);
  @$pb.TagNumber(21)
  set repoUrl($core.String v) { $_setString(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasRepoUrl() => $_has(20);
  @$pb.TagNumber(21)
  void clearRepoUrl() => clearField(21);

  @$pb.TagNumber(22)
  $core.List<StartupLogEntryMsg> get startupLogs => $_getList(21);

  /// Absolute path to the launchable binary on disk (variant-aware: returns
  /// bin/test/<binary>/... for active sidechain alt-builds, the resolved
  /// .app/Contents/MacOS path on macOS, etc.). Empty when not downloaded.
  @$pb.TagNumber(23)
  $core.String get binaryPath => $_getSZ(22);
  @$pb.TagNumber(23)
  set binaryPath($core.String v) { $_setString(22, v); }
  @$pb.TagNumber(23)
  $core.bool hasBinaryPath() => $_has(22);
  @$pb.TagNumber(23)
  void clearBinaryPath() => clearField(23);
}

class StartupLogEntryMsg extends $pb.GeneratedMessage {
  factory StartupLogEntryMsg({
    $fixnum.Int64? timestampUnix,
    $core.String? message,
  }) {
    final $result = create();
    if (timestampUnix != null) {
      $result.timestampUnix = timestampUnix;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  StartupLogEntryMsg._() : super();
  factory StartupLogEntryMsg.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StartupLogEntryMsg.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartupLogEntryMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'timestampUnix')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StartupLogEntryMsg clone() => StartupLogEntryMsg()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StartupLogEntryMsg copyWith(void Function(StartupLogEntryMsg) updates) => super.copyWith((message) => updates(message as StartupLogEntryMsg)) as StartupLogEntryMsg;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartupLogEntryMsg create() => StartupLogEntryMsg._();
  StartupLogEntryMsg createEmptyInstance() => create();
  static $pb.PbList<StartupLogEntryMsg> createRepeated() => $pb.PbList<StartupLogEntryMsg>();
  @$core.pragma('dart2js:noInline')
  static StartupLogEntryMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartupLogEntryMsg>(create);
  static StartupLogEntryMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get timestampUnix => $_getI64(0);
  @$pb.TagNumber(1)
  set timestampUnix($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTimestampUnix() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestampUnix() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
}

class ListBinariesRequest extends $pb.GeneratedMessage {
  factory ListBinariesRequest() => create();
  ListBinariesRequest._() : super();
  factory ListBinariesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListBinariesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBinariesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListBinariesRequest clone() => ListBinariesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListBinariesRequest copyWith(void Function(ListBinariesRequest) updates) => super.copyWith((message) => updates(message as ListBinariesRequest)) as ListBinariesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBinariesRequest create() => ListBinariesRequest._();
  ListBinariesRequest createEmptyInstance() => create();
  static $pb.PbList<ListBinariesRequest> createRepeated() => $pb.PbList<ListBinariesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListBinariesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBinariesRequest>(create);
  static ListBinariesRequest? _defaultInstance;
}

class ListBinariesResponse extends $pb.GeneratedMessage {
  factory ListBinariesResponse({
    $core.Iterable<BinaryStatusMsg>? binaries,
  }) {
    final $result = create();
    if (binaries != null) {
      $result.binaries.addAll(binaries);
    }
    return $result;
  }
  ListBinariesResponse._() : super();
  factory ListBinariesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListBinariesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBinariesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..pc<BinaryStatusMsg>(1, _omitFieldNames ? '' : 'binaries', $pb.PbFieldType.PM, subBuilder: BinaryStatusMsg.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListBinariesResponse clone() => ListBinariesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListBinariesResponse copyWith(void Function(ListBinariesResponse) updates) => super.copyWith((message) => updates(message as ListBinariesResponse)) as ListBinariesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBinariesResponse create() => ListBinariesResponse._();
  ListBinariesResponse createEmptyInstance() => create();
  static $pb.PbList<ListBinariesResponse> createRepeated() => $pb.PbList<ListBinariesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListBinariesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBinariesResponse>(create);
  static ListBinariesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<BinaryStatusMsg> get binaries => $_getList(0);
}

class GetBinaryStatusRequest extends $pb.GeneratedMessage {
  factory GetBinaryStatusRequest({
    $core.String? name,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    return $result;
  }
  GetBinaryStatusRequest._() : super();
  factory GetBinaryStatusRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBinaryStatusRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBinaryStatusRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBinaryStatusRequest clone() => GetBinaryStatusRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBinaryStatusRequest copyWith(void Function(GetBinaryStatusRequest) updates) => super.copyWith((message) => updates(message as GetBinaryStatusRequest)) as GetBinaryStatusRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBinaryStatusRequest create() => GetBinaryStatusRequest._();
  GetBinaryStatusRequest createEmptyInstance() => create();
  static $pb.PbList<GetBinaryStatusRequest> createRepeated() => $pb.PbList<GetBinaryStatusRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBinaryStatusRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBinaryStatusRequest>(create);
  static GetBinaryStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);
}

class GetBinaryStatusResponse extends $pb.GeneratedMessage {
  factory GetBinaryStatusResponse({
    BinaryStatusMsg? status,
  }) {
    final $result = create();
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  GetBinaryStatusResponse._() : super();
  factory GetBinaryStatusResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBinaryStatusResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBinaryStatusResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOM<BinaryStatusMsg>(1, _omitFieldNames ? '' : 'status', subBuilder: BinaryStatusMsg.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBinaryStatusResponse clone() => GetBinaryStatusResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBinaryStatusResponse copyWith(void Function(GetBinaryStatusResponse) updates) => super.copyWith((message) => updates(message as GetBinaryStatusResponse)) as GetBinaryStatusResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBinaryStatusResponse create() => GetBinaryStatusResponse._();
  GetBinaryStatusResponse createEmptyInstance() => create();
  static $pb.PbList<GetBinaryStatusResponse> createRepeated() => $pb.PbList<GetBinaryStatusResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBinaryStatusResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBinaryStatusResponse>(create);
  static GetBinaryStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BinaryStatusMsg get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(BinaryStatusMsg v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => clearField(1);
  @$pb.TagNumber(1)
  BinaryStatusMsg ensureStatus() => $_ensure(0);
}

class DownloadBinaryRequest extends $pb.GeneratedMessage {
  factory DownloadBinaryRequest({
    $core.String? name,
    $core.bool? force,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (force != null) {
      $result.force = force;
    }
    return $result;
  }
  DownloadBinaryRequest._() : super();
  factory DownloadBinaryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DownloadBinaryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadBinaryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOB(2, _omitFieldNames ? '' : 'force')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DownloadBinaryRequest clone() => DownloadBinaryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DownloadBinaryRequest copyWith(void Function(DownloadBinaryRequest) updates) => super.copyWith((message) => updates(message as DownloadBinaryRequest)) as DownloadBinaryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadBinaryRequest create() => DownloadBinaryRequest._();
  DownloadBinaryRequest createEmptyInstance() => create();
  static $pb.PbList<DownloadBinaryRequest> createRepeated() => $pb.PbList<DownloadBinaryRequest>();
  @$core.pragma('dart2js:noInline')
  static DownloadBinaryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadBinaryRequest>(create);
  static DownloadBinaryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get force => $_getBF(1);
  @$pb.TagNumber(2)
  set force($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasForce() => $_has(1);
  @$pb.TagNumber(2)
  void clearForce() => clearField(2);
}

class DownloadBinaryResponse extends $pb.GeneratedMessage {
  factory DownloadBinaryResponse() => create();
  DownloadBinaryResponse._() : super();
  factory DownloadBinaryResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DownloadBinaryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadBinaryResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DownloadBinaryResponse clone() => DownloadBinaryResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DownloadBinaryResponse copyWith(void Function(DownloadBinaryResponse) updates) => super.copyWith((message) => updates(message as DownloadBinaryResponse)) as DownloadBinaryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadBinaryResponse create() => DownloadBinaryResponse._();
  DownloadBinaryResponse createEmptyInstance() => create();
  static $pb.PbList<DownloadBinaryResponse> createRepeated() => $pb.PbList<DownloadBinaryResponse>();
  @$core.pragma('dart2js:noInline')
  static DownloadBinaryResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadBinaryResponse>(create);
  static DownloadBinaryResponse? _defaultInstance;
}

class StartBinaryRequest extends $pb.GeneratedMessage {
  factory StartBinaryRequest({
    $core.String? name,
    $core.Iterable<$core.String>? extraArgs,
    $core.Map<$core.String, $core.String>? env,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (extraArgs != null) {
      $result.extraArgs.addAll(extraArgs);
    }
    if (env != null) {
      $result.env.addAll(env);
    }
    return $result;
  }
  StartBinaryRequest._() : super();
  factory StartBinaryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StartBinaryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartBinaryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..pPS(2, _omitFieldNames ? '' : 'extraArgs')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'env', entryClassName: 'StartBinaryRequest.EnvEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('orchestrator.v1'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StartBinaryRequest clone() => StartBinaryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StartBinaryRequest copyWith(void Function(StartBinaryRequest) updates) => super.copyWith((message) => updates(message as StartBinaryRequest)) as StartBinaryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartBinaryRequest create() => StartBinaryRequest._();
  StartBinaryRequest createEmptyInstance() => create();
  static $pb.PbList<StartBinaryRequest> createRepeated() => $pb.PbList<StartBinaryRequest>();
  @$core.pragma('dart2js:noInline')
  static StartBinaryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartBinaryRequest>(create);
  static StartBinaryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get extraArgs => $_getList(1);

  @$pb.TagNumber(3)
  $core.Map<$core.String, $core.String> get env => $_getMap(2);
}

class StartBinaryResponse extends $pb.GeneratedMessage {
  factory StartBinaryResponse({
    $core.int? pid,
  }) {
    final $result = create();
    if (pid != null) {
      $result.pid = pid;
    }
    return $result;
  }
  StartBinaryResponse._() : super();
  factory StartBinaryResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StartBinaryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartBinaryResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'pid', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StartBinaryResponse clone() => StartBinaryResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StartBinaryResponse copyWith(void Function(StartBinaryResponse) updates) => super.copyWith((message) => updates(message as StartBinaryResponse)) as StartBinaryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartBinaryResponse create() => StartBinaryResponse._();
  StartBinaryResponse createEmptyInstance() => create();
  static $pb.PbList<StartBinaryResponse> createRepeated() => $pb.PbList<StartBinaryResponse>();
  @$core.pragma('dart2js:noInline')
  static StartBinaryResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartBinaryResponse>(create);
  static StartBinaryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pid => $_getIZ(0);
  @$pb.TagNumber(1)
  set pid($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPid() => $_has(0);
  @$pb.TagNumber(1)
  void clearPid() => clearField(1);
}

class StopBinaryRequest extends $pb.GeneratedMessage {
  factory StopBinaryRequest({
    $core.String? name,
    $core.bool? force,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (force != null) {
      $result.force = force;
    }
    return $result;
  }
  StopBinaryRequest._() : super();
  factory StopBinaryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StopBinaryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopBinaryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOB(2, _omitFieldNames ? '' : 'force')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StopBinaryRequest clone() => StopBinaryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StopBinaryRequest copyWith(void Function(StopBinaryRequest) updates) => super.copyWith((message) => updates(message as StopBinaryRequest)) as StopBinaryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopBinaryRequest create() => StopBinaryRequest._();
  StopBinaryRequest createEmptyInstance() => create();
  static $pb.PbList<StopBinaryRequest> createRepeated() => $pb.PbList<StopBinaryRequest>();
  @$core.pragma('dart2js:noInline')
  static StopBinaryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopBinaryRequest>(create);
  static StopBinaryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get force => $_getBF(1);
  @$pb.TagNumber(2)
  set force($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasForce() => $_has(1);
  @$pb.TagNumber(2)
  void clearForce() => clearField(2);
}

class StopBinaryResponse extends $pb.GeneratedMessage {
  factory StopBinaryResponse() => create();
  StopBinaryResponse._() : super();
  factory StopBinaryResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StopBinaryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopBinaryResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StopBinaryResponse clone() => StopBinaryResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StopBinaryResponse copyWith(void Function(StopBinaryResponse) updates) => super.copyWith((message) => updates(message as StopBinaryResponse)) as StopBinaryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopBinaryResponse create() => StopBinaryResponse._();
  StopBinaryResponse createEmptyInstance() => create();
  static $pb.PbList<StopBinaryResponse> createRepeated() => $pb.PbList<StopBinaryResponse>();
  @$core.pragma('dart2js:noInline')
  static StopBinaryResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopBinaryResponse>(create);
  static StopBinaryResponse? _defaultInstance;
}

class StreamLogsRequest extends $pb.GeneratedMessage {
  factory StreamLogsRequest({
    $core.String? name,
    $core.int? tail,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (tail != null) {
      $result.tail = tail;
    }
    return $result;
  }
  StreamLogsRequest._() : super();
  factory StreamLogsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StreamLogsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StreamLogsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'tail', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StreamLogsRequest clone() => StreamLogsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StreamLogsRequest copyWith(void Function(StreamLogsRequest) updates) => super.copyWith((message) => updates(message as StreamLogsRequest)) as StreamLogsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamLogsRequest create() => StreamLogsRequest._();
  StreamLogsRequest createEmptyInstance() => create();
  static $pb.PbList<StreamLogsRequest> createRepeated() => $pb.PbList<StreamLogsRequest>();
  @$core.pragma('dart2js:noInline')
  static StreamLogsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StreamLogsRequest>(create);
  static StreamLogsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get tail => $_getIZ(1);
  @$pb.TagNumber(2)
  set tail($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTail() => $_has(1);
  @$pb.TagNumber(2)
  void clearTail() => clearField(2);
}

class StreamLogsResponse extends $pb.GeneratedMessage {
  factory StreamLogsResponse({
    $core.String? stream,
    $core.String? line,
    $fixnum.Int64? timestampUnix,
  }) {
    final $result = create();
    if (stream != null) {
      $result.stream = stream;
    }
    if (line != null) {
      $result.line = line;
    }
    if (timestampUnix != null) {
      $result.timestampUnix = timestampUnix;
    }
    return $result;
  }
  StreamLogsResponse._() : super();
  factory StreamLogsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StreamLogsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StreamLogsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'stream')
    ..aOS(2, _omitFieldNames ? '' : 'line')
    ..aInt64(3, _omitFieldNames ? '' : 'timestampUnix')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StreamLogsResponse clone() => StreamLogsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StreamLogsResponse copyWith(void Function(StreamLogsResponse) updates) => super.copyWith((message) => updates(message as StreamLogsResponse)) as StreamLogsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamLogsResponse create() => StreamLogsResponse._();
  StreamLogsResponse createEmptyInstance() => create();
  static $pb.PbList<StreamLogsResponse> createRepeated() => $pb.PbList<StreamLogsResponse>();
  @$core.pragma('dart2js:noInline')
  static StreamLogsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StreamLogsResponse>(create);
  static StreamLogsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get stream => $_getSZ(0);
  @$pb.TagNumber(1)
  set stream($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStream() => $_has(0);
  @$pb.TagNumber(1)
  void clearStream() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get line => $_getSZ(1);
  @$pb.TagNumber(2)
  set line($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLine() => $_has(1);
  @$pb.TagNumber(2)
  void clearLine() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestampUnix => $_getI64(2);
  @$pb.TagNumber(3)
  set timestampUnix($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTimestampUnix() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestampUnix() => clearField(3);
}

class StartWithL1Request extends $pb.GeneratedMessage {
  factory StartWithL1Request({
    $core.String? target,
    $core.Iterable<$core.String>? targetArgs,
    $core.Map<$core.String, $core.String>? targetEnv,
    $core.Iterable<$core.String>? coreArgs,
    $core.Iterable<$core.String>? enforcerArgs,
    $core.bool? immediate,
    $core.bool? forceBackend,
  }) {
    final $result = create();
    if (target != null) {
      $result.target = target;
    }
    if (targetArgs != null) {
      $result.targetArgs.addAll(targetArgs);
    }
    if (targetEnv != null) {
      $result.targetEnv.addAll(targetEnv);
    }
    if (coreArgs != null) {
      $result.coreArgs.addAll(coreArgs);
    }
    if (enforcerArgs != null) {
      $result.enforcerArgs.addAll(enforcerArgs);
    }
    if (immediate != null) {
      $result.immediate = immediate;
    }
    if (forceBackend != null) {
      $result.forceBackend = forceBackend;
    }
    return $result;
  }
  StartWithL1Request._() : super();
  factory StartWithL1Request.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StartWithL1Request.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartWithL1Request', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'target')
    ..pPS(2, _omitFieldNames ? '' : 'targetArgs')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'targetEnv', entryClassName: 'StartWithL1Request.TargetEnvEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('orchestrator.v1'))
    ..pPS(4, _omitFieldNames ? '' : 'coreArgs')
    ..pPS(5, _omitFieldNames ? '' : 'enforcerArgs')
    ..aOB(6, _omitFieldNames ? '' : 'immediate')
    ..aOB(7, _omitFieldNames ? '' : 'forceBackend')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StartWithL1Request clone() => StartWithL1Request()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StartWithL1Request copyWith(void Function(StartWithL1Request) updates) => super.copyWith((message) => updates(message as StartWithL1Request)) as StartWithL1Request;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartWithL1Request create() => StartWithL1Request._();
  StartWithL1Request createEmptyInstance() => create();
  static $pb.PbList<StartWithL1Request> createRepeated() => $pb.PbList<StartWithL1Request>();
  @$core.pragma('dart2js:noInline')
  static StartWithL1Request getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartWithL1Request>(create);
  static StartWithL1Request? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get target => $_getSZ(0);
  @$pb.TagNumber(1)
  set target($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTarget() => $_has(0);
  @$pb.TagNumber(1)
  void clearTarget() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get targetArgs => $_getList(1);

  @$pb.TagNumber(3)
  $core.Map<$core.String, $core.String> get targetEnv => $_getMap(2);

  @$pb.TagNumber(4)
  $core.List<$core.String> get coreArgs => $_getList(3);

  @$pb.TagNumber(5)
  $core.List<$core.String> get enforcerArgs => $_getList(4);

  @$pb.TagNumber(6)
  $core.bool get immediate => $_getBF(5);
  @$pb.TagNumber(6)
  set immediate($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasImmediate() => $_has(5);
  @$pb.TagNumber(6)
  void clearImmediate() => clearField(6);

  /// Bypass UseTestSidechains for this call: always launch the prod-download
  /// binary even if the user toggled "Use test sidechains" on. Sidechain
  /// Flutter apps set this when self-booting their backend so the toggle
  /// doesn't re-spawn another Flutter bundle inside them.
  @$pb.TagNumber(7)
  $core.bool get forceBackend => $_getBF(6);
  @$pb.TagNumber(7)
  set forceBackend($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasForceBackend() => $_has(6);
  @$pb.TagNumber(7)
  void clearForceBackend() => clearField(7);
}

class StartWithL1Response extends $pb.GeneratedMessage {
  factory StartWithL1Response() => create();
  StartWithL1Response._() : super();
  factory StartWithL1Response.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StartWithL1Response.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartWithL1Response', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StartWithL1Response clone() => StartWithL1Response()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StartWithL1Response copyWith(void Function(StartWithL1Response) updates) => super.copyWith((message) => updates(message as StartWithL1Response)) as StartWithL1Response;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartWithL1Response create() => StartWithL1Response._();
  StartWithL1Response createEmptyInstance() => create();
  static $pb.PbList<StartWithL1Response> createRepeated() => $pb.PbList<StartWithL1Response>();
  @$core.pragma('dart2js:noInline')
  static StartWithL1Response getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartWithL1Response>(create);
  static StartWithL1Response? _defaultInstance;
}

class RestartDaemonRequest extends $pb.GeneratedMessage {
  factory RestartDaemonRequest({
    $core.String? name,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    return $result;
  }
  RestartDaemonRequest._() : super();
  factory RestartDaemonRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RestartDaemonRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestartDaemonRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RestartDaemonRequest clone() => RestartDaemonRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RestartDaemonRequest copyWith(void Function(RestartDaemonRequest) updates) => super.copyWith((message) => updates(message as RestartDaemonRequest)) as RestartDaemonRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RestartDaemonRequest create() => RestartDaemonRequest._();
  RestartDaemonRequest createEmptyInstance() => create();
  static $pb.PbList<RestartDaemonRequest> createRepeated() => $pb.PbList<RestartDaemonRequest>();
  @$core.pragma('dart2js:noInline')
  static RestartDaemonRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RestartDaemonRequest>(create);
  static RestartDaemonRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);
}

class RestartDaemonResponse extends $pb.GeneratedMessage {
  factory RestartDaemonResponse() => create();
  RestartDaemonResponse._() : super();
  factory RestartDaemonResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RestartDaemonResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestartDaemonResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RestartDaemonResponse clone() => RestartDaemonResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RestartDaemonResponse copyWith(void Function(RestartDaemonResponse) updates) => super.copyWith((message) => updates(message as RestartDaemonResponse)) as RestartDaemonResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RestartDaemonResponse create() => RestartDaemonResponse._();
  RestartDaemonResponse createEmptyInstance() => create();
  static $pb.PbList<RestartDaemonResponse> createRepeated() => $pb.PbList<RestartDaemonResponse>();
  @$core.pragma('dart2js:noInline')
  static RestartDaemonResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RestartDaemonResponse>(create);
  static RestartDaemonResponse? _defaultInstance;
}

class RestartL1Request extends $pb.GeneratedMessage {
  factory RestartL1Request() => create();
  RestartL1Request._() : super();
  factory RestartL1Request.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RestartL1Request.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestartL1Request', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RestartL1Request clone() => RestartL1Request()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RestartL1Request copyWith(void Function(RestartL1Request) updates) => super.copyWith((message) => updates(message as RestartL1Request)) as RestartL1Request;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RestartL1Request create() => RestartL1Request._();
  RestartL1Request createEmptyInstance() => create();
  static $pb.PbList<RestartL1Request> createRepeated() => $pb.PbList<RestartL1Request>();
  @$core.pragma('dart2js:noInline')
  static RestartL1Request getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RestartL1Request>(create);
  static RestartL1Request? _defaultInstance;
}

class RestartL1Response extends $pb.GeneratedMessage {
  factory RestartL1Response() => create();
  RestartL1Response._() : super();
  factory RestartL1Response.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RestartL1Response.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestartL1Response', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RestartL1Response clone() => RestartL1Response()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RestartL1Response copyWith(void Function(RestartL1Response) updates) => super.copyWith((message) => updates(message as RestartL1Response)) as RestartL1Response;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RestartL1Response create() => RestartL1Response._();
  RestartL1Response createEmptyInstance() => create();
  static $pb.PbList<RestartL1Response> createRepeated() => $pb.PbList<RestartL1Response>();
  @$core.pragma('dart2js:noInline')
  static RestartL1Response getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RestartL1Response>(create);
  static RestartL1Response? _defaultInstance;
}

class ShutdownAllRequest extends $pb.GeneratedMessage {
  factory ShutdownAllRequest({
    $core.bool? force,
  }) {
    final $result = create();
    if (force != null) {
      $result.force = force;
    }
    return $result;
  }
  ShutdownAllRequest._() : super();
  factory ShutdownAllRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ShutdownAllRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ShutdownAllRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'force')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ShutdownAllRequest clone() => ShutdownAllRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ShutdownAllRequest copyWith(void Function(ShutdownAllRequest) updates) => super.copyWith((message) => updates(message as ShutdownAllRequest)) as ShutdownAllRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ShutdownAllRequest create() => ShutdownAllRequest._();
  ShutdownAllRequest createEmptyInstance() => create();
  static $pb.PbList<ShutdownAllRequest> createRepeated() => $pb.PbList<ShutdownAllRequest>();
  @$core.pragma('dart2js:noInline')
  static ShutdownAllRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShutdownAllRequest>(create);
  static ShutdownAllRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get force => $_getBF(0);
  @$pb.TagNumber(1)
  set force($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasForce() => $_has(0);
  @$pb.TagNumber(1)
  void clearForce() => clearField(1);
}

class ShutdownAllResponse extends $pb.GeneratedMessage {
  factory ShutdownAllResponse({
    $core.int? totalCount,
    $core.int? completedCount,
    $core.String? currentBinary,
    $core.bool? done,
    $core.String? error,
  }) {
    final $result = create();
    if (totalCount != null) {
      $result.totalCount = totalCount;
    }
    if (completedCount != null) {
      $result.completedCount = completedCount;
    }
    if (currentBinary != null) {
      $result.currentBinary = currentBinary;
    }
    if (done != null) {
      $result.done = done;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  ShutdownAllResponse._() : super();
  factory ShutdownAllResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ShutdownAllResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ShutdownAllResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'totalCount', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'completedCount', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'currentBinary')
    ..aOB(4, _omitFieldNames ? '' : 'done')
    ..aOS(5, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ShutdownAllResponse clone() => ShutdownAllResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ShutdownAllResponse copyWith(void Function(ShutdownAllResponse) updates) => super.copyWith((message) => updates(message as ShutdownAllResponse)) as ShutdownAllResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ShutdownAllResponse create() => ShutdownAllResponse._();
  ShutdownAllResponse createEmptyInstance() => create();
  static $pb.PbList<ShutdownAllResponse> createRepeated() => $pb.PbList<ShutdownAllResponse>();
  @$core.pragma('dart2js:noInline')
  static ShutdownAllResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShutdownAllResponse>(create);
  static ShutdownAllResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get totalCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set totalCount($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTotalCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalCount() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get completedCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set completedCount($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCompletedCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCompletedCount() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get currentBinary => $_getSZ(2);
  @$pb.TagNumber(3)
  set currentBinary($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCurrentBinary() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrentBinary() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get done => $_getBF(3);
  @$pb.TagNumber(4)
  set done($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDone() => $_has(3);
  @$pb.TagNumber(4)
  void clearDone() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get error => $_getSZ(4);
  @$pb.TagNumber(5)
  set error($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasError() => $_has(4);
  @$pb.TagNumber(5)
  void clearError() => clearField(5);
}

class GetBTCPriceRequest extends $pb.GeneratedMessage {
  factory GetBTCPriceRequest() => create();
  GetBTCPriceRequest._() : super();
  factory GetBTCPriceRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBTCPriceRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBTCPriceRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBTCPriceRequest clone() => GetBTCPriceRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBTCPriceRequest copyWith(void Function(GetBTCPriceRequest) updates) => super.copyWith((message) => updates(message as GetBTCPriceRequest)) as GetBTCPriceRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBTCPriceRequest create() => GetBTCPriceRequest._();
  GetBTCPriceRequest createEmptyInstance() => create();
  static $pb.PbList<GetBTCPriceRequest> createRepeated() => $pb.PbList<GetBTCPriceRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBTCPriceRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBTCPriceRequest>(create);
  static GetBTCPriceRequest? _defaultInstance;
}

class GetBTCPriceResponse extends $pb.GeneratedMessage {
  factory GetBTCPriceResponse({
    $core.double? btcusd,
    $fixnum.Int64? lastUpdatedUnix,
  }) {
    final $result = create();
    if (btcusd != null) {
      $result.btcusd = btcusd;
    }
    if (lastUpdatedUnix != null) {
      $result.lastUpdatedUnix = lastUpdatedUnix;
    }
    return $result;
  }
  GetBTCPriceResponse._() : super();
  factory GetBTCPriceResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBTCPriceResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBTCPriceResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'btcusd', $pb.PbFieldType.OD)
    ..aInt64(2, _omitFieldNames ? '' : 'lastUpdatedUnix')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBTCPriceResponse clone() => GetBTCPriceResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBTCPriceResponse copyWith(void Function(GetBTCPriceResponse) updates) => super.copyWith((message) => updates(message as GetBTCPriceResponse)) as GetBTCPriceResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBTCPriceResponse create() => GetBTCPriceResponse._();
  GetBTCPriceResponse createEmptyInstance() => create();
  static $pb.PbList<GetBTCPriceResponse> createRepeated() => $pb.PbList<GetBTCPriceResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBTCPriceResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBTCPriceResponse>(create);
  static GetBTCPriceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get btcusd => $_getN(0);
  @$pb.TagNumber(1)
  set btcusd($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBtcusd() => $_has(0);
  @$pb.TagNumber(1)
  void clearBtcusd() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get lastUpdatedUnix => $_getI64(1);
  @$pb.TagNumber(2)
  set lastUpdatedUnix($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLastUpdatedUnix() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastUpdatedUnix() => clearField(2);
}

class GetMainchainBlockchainInfoRequest extends $pb.GeneratedMessage {
  factory GetMainchainBlockchainInfoRequest() => create();
  GetMainchainBlockchainInfoRequest._() : super();
  factory GetMainchainBlockchainInfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetMainchainBlockchainInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMainchainBlockchainInfoRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetMainchainBlockchainInfoRequest clone() => GetMainchainBlockchainInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetMainchainBlockchainInfoRequest copyWith(void Function(GetMainchainBlockchainInfoRequest) updates) => super.copyWith((message) => updates(message as GetMainchainBlockchainInfoRequest)) as GetMainchainBlockchainInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMainchainBlockchainInfoRequest create() => GetMainchainBlockchainInfoRequest._();
  GetMainchainBlockchainInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetMainchainBlockchainInfoRequest> createRepeated() => $pb.PbList<GetMainchainBlockchainInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetMainchainBlockchainInfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMainchainBlockchainInfoRequest>(create);
  static GetMainchainBlockchainInfoRequest? _defaultInstance;
}

class GetMainchainBlockchainInfoResponse extends $pb.GeneratedMessage {
  factory GetMainchainBlockchainInfoResponse({
    $core.String? chain,
    $core.int? blocks,
    $core.int? headers,
    $core.String? bestBlockHash,
    $core.double? difficulty,
    $fixnum.Int64? time,
    $fixnum.Int64? medianTime,
    $core.double? verificationProgress,
    $core.bool? initialBlockDownload,
    $core.String? chainWork,
    $fixnum.Int64? sizeOnDisk,
    $core.bool? pruned,
  }) {
    final $result = create();
    if (chain != null) {
      $result.chain = chain;
    }
    if (blocks != null) {
      $result.blocks = blocks;
    }
    if (headers != null) {
      $result.headers = headers;
    }
    if (bestBlockHash != null) {
      $result.bestBlockHash = bestBlockHash;
    }
    if (difficulty != null) {
      $result.difficulty = difficulty;
    }
    if (time != null) {
      $result.time = time;
    }
    if (medianTime != null) {
      $result.medianTime = medianTime;
    }
    if (verificationProgress != null) {
      $result.verificationProgress = verificationProgress;
    }
    if (initialBlockDownload != null) {
      $result.initialBlockDownload = initialBlockDownload;
    }
    if (chainWork != null) {
      $result.chainWork = chainWork;
    }
    if (sizeOnDisk != null) {
      $result.sizeOnDisk = sizeOnDisk;
    }
    if (pruned != null) {
      $result.pruned = pruned;
    }
    return $result;
  }
  GetMainchainBlockchainInfoResponse._() : super();
  factory GetMainchainBlockchainInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetMainchainBlockchainInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMainchainBlockchainInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'blocks', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'headers', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'bestBlockHash')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'difficulty', $pb.PbFieldType.OD)
    ..aInt64(6, _omitFieldNames ? '' : 'time')
    ..aInt64(7, _omitFieldNames ? '' : 'medianTime')
    ..a<$core.double>(8, _omitFieldNames ? '' : 'verificationProgress', $pb.PbFieldType.OD)
    ..aOB(9, _omitFieldNames ? '' : 'initialBlockDownload')
    ..aOS(10, _omitFieldNames ? '' : 'chainWork')
    ..aInt64(11, _omitFieldNames ? '' : 'sizeOnDisk')
    ..aOB(12, _omitFieldNames ? '' : 'pruned')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetMainchainBlockchainInfoResponse clone() => GetMainchainBlockchainInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetMainchainBlockchainInfoResponse copyWith(void Function(GetMainchainBlockchainInfoResponse) updates) => super.copyWith((message) => updates(message as GetMainchainBlockchainInfoResponse)) as GetMainchainBlockchainInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMainchainBlockchainInfoResponse create() => GetMainchainBlockchainInfoResponse._();
  GetMainchainBlockchainInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetMainchainBlockchainInfoResponse> createRepeated() => $pb.PbList<GetMainchainBlockchainInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetMainchainBlockchainInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMainchainBlockchainInfoResponse>(create);
  static GetMainchainBlockchainInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get blocks => $_getIZ(1);
  @$pb.TagNumber(2)
  set blocks($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBlocks() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlocks() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get headers => $_getIZ(2);
  @$pb.TagNumber(3)
  set headers($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHeaders() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeaders() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get bestBlockHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set bestBlockHash($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBestBlockHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearBestBlockHash() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get difficulty => $_getN(4);
  @$pb.TagNumber(5)
  set difficulty($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDifficulty() => $_has(4);
  @$pb.TagNumber(5)
  void clearDifficulty() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get time => $_getI64(5);
  @$pb.TagNumber(6)
  set time($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearTime() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get medianTime => $_getI64(6);
  @$pb.TagNumber(7)
  set medianTime($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMedianTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearMedianTime() => clearField(7);

  @$pb.TagNumber(8)
  $core.double get verificationProgress => $_getN(7);
  @$pb.TagNumber(8)
  set verificationProgress($core.double v) { $_setDouble(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasVerificationProgress() => $_has(7);
  @$pb.TagNumber(8)
  void clearVerificationProgress() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get initialBlockDownload => $_getBF(8);
  @$pb.TagNumber(9)
  set initialBlockDownload($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasInitialBlockDownload() => $_has(8);
  @$pb.TagNumber(9)
  void clearInitialBlockDownload() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get chainWork => $_getSZ(9);
  @$pb.TagNumber(10)
  set chainWork($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasChainWork() => $_has(9);
  @$pb.TagNumber(10)
  void clearChainWork() => clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get sizeOnDisk => $_getI64(10);
  @$pb.TagNumber(11)
  set sizeOnDisk($fixnum.Int64 v) { $_setInt64(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasSizeOnDisk() => $_has(10);
  @$pb.TagNumber(11)
  void clearSizeOnDisk() => clearField(11);

  @$pb.TagNumber(12)
  $core.bool get pruned => $_getBF(11);
  @$pb.TagNumber(12)
  set pruned($core.bool v) { $_setBool(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasPruned() => $_has(11);
  @$pb.TagNumber(12)
  void clearPruned() => clearField(12);
}

class GetEnforcerBlockchainInfoRequest extends $pb.GeneratedMessage {
  factory GetEnforcerBlockchainInfoRequest() => create();
  GetEnforcerBlockchainInfoRequest._() : super();
  factory GetEnforcerBlockchainInfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetEnforcerBlockchainInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetEnforcerBlockchainInfoRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetEnforcerBlockchainInfoRequest clone() => GetEnforcerBlockchainInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetEnforcerBlockchainInfoRequest copyWith(void Function(GetEnforcerBlockchainInfoRequest) updates) => super.copyWith((message) => updates(message as GetEnforcerBlockchainInfoRequest)) as GetEnforcerBlockchainInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetEnforcerBlockchainInfoRequest create() => GetEnforcerBlockchainInfoRequest._();
  GetEnforcerBlockchainInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetEnforcerBlockchainInfoRequest> createRepeated() => $pb.PbList<GetEnforcerBlockchainInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetEnforcerBlockchainInfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetEnforcerBlockchainInfoRequest>(create);
  static GetEnforcerBlockchainInfoRequest? _defaultInstance;
}

class GetEnforcerBlockchainInfoResponse extends $pb.GeneratedMessage {
  factory GetEnforcerBlockchainInfoResponse({
    $core.int? blocks,
    $core.int? headers,
    $fixnum.Int64? time,
  }) {
    final $result = create();
    if (blocks != null) {
      $result.blocks = blocks;
    }
    if (headers != null) {
      $result.headers = headers;
    }
    if (time != null) {
      $result.time = time;
    }
    return $result;
  }
  GetEnforcerBlockchainInfoResponse._() : super();
  factory GetEnforcerBlockchainInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetEnforcerBlockchainInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetEnforcerBlockchainInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'blocks', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'headers', $pb.PbFieldType.O3)
    ..aInt64(3, _omitFieldNames ? '' : 'time')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetEnforcerBlockchainInfoResponse clone() => GetEnforcerBlockchainInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetEnforcerBlockchainInfoResponse copyWith(void Function(GetEnforcerBlockchainInfoResponse) updates) => super.copyWith((message) => updates(message as GetEnforcerBlockchainInfoResponse)) as GetEnforcerBlockchainInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetEnforcerBlockchainInfoResponse create() => GetEnforcerBlockchainInfoResponse._();
  GetEnforcerBlockchainInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetEnforcerBlockchainInfoResponse> createRepeated() => $pb.PbList<GetEnforcerBlockchainInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetEnforcerBlockchainInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetEnforcerBlockchainInfoResponse>(create);
  static GetEnforcerBlockchainInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get blocks => $_getIZ(0);
  @$pb.TagNumber(1)
  set blocks($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlocks() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlocks() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get headers => $_getIZ(1);
  @$pb.TagNumber(2)
  set headers($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeaders() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeaders() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get time => $_getI64(2);
  @$pb.TagNumber(3)
  set time($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearTime() => clearField(3);
}

class GetSyncStatusRequest extends $pb.GeneratedMessage {
  factory GetSyncStatusRequest() => create();
  GetSyncStatusRequest._() : super();
  factory GetSyncStatusRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSyncStatusRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSyncStatusRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetSyncStatusRequest clone() => GetSyncStatusRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetSyncStatusRequest copyWith(void Function(GetSyncStatusRequest) updates) => super.copyWith((message) => updates(message as GetSyncStatusRequest)) as GetSyncStatusRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSyncStatusRequest create() => GetSyncStatusRequest._();
  GetSyncStatusRequest createEmptyInstance() => create();
  static $pb.PbList<GetSyncStatusRequest> createRepeated() => $pb.PbList<GetSyncStatusRequest>();
  @$core.pragma('dart2js:noInline')
  static GetSyncStatusRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSyncStatusRequest>(create);
  static GetSyncStatusRequest? _defaultInstance;
}

class GetSyncStatusResponse extends $pb.GeneratedMessage {
  factory GetSyncStatusResponse({
    ChainSync? mainchain,
    ChainSync? enforcer,
    $core.Iterable<SidechainStatus>? sidechains,
  }) {
    final $result = create();
    if (mainchain != null) {
      $result.mainchain = mainchain;
    }
    if (enforcer != null) {
      $result.enforcer = enforcer;
    }
    if (sidechains != null) {
      $result.sidechains.addAll(sidechains);
    }
    return $result;
  }
  GetSyncStatusResponse._() : super();
  factory GetSyncStatusResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSyncStatusResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSyncStatusResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOM<ChainSync>(1, _omitFieldNames ? '' : 'mainchain', subBuilder: ChainSync.create)
    ..aOM<ChainSync>(2, _omitFieldNames ? '' : 'enforcer', subBuilder: ChainSync.create)
    ..pc<SidechainStatus>(3, _omitFieldNames ? '' : 'sidechains', $pb.PbFieldType.PM, subBuilder: SidechainStatus.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetSyncStatusResponse clone() => GetSyncStatusResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetSyncStatusResponse copyWith(void Function(GetSyncStatusResponse) updates) => super.copyWith((message) => updates(message as GetSyncStatusResponse)) as GetSyncStatusResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSyncStatusResponse create() => GetSyncStatusResponse._();
  GetSyncStatusResponse createEmptyInstance() => create();
  static $pb.PbList<GetSyncStatusResponse> createRepeated() => $pb.PbList<GetSyncStatusResponse>();
  @$core.pragma('dart2js:noInline')
  static GetSyncStatusResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSyncStatusResponse>(create);
  static GetSyncStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ChainSync get mainchain => $_getN(0);
  @$pb.TagNumber(1)
  set mainchain(ChainSync v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasMainchain() => $_has(0);
  @$pb.TagNumber(1)
  void clearMainchain() => clearField(1);
  @$pb.TagNumber(1)
  ChainSync ensureMainchain() => $_ensure(0);

  @$pb.TagNumber(2)
  ChainSync get enforcer => $_getN(1);
  @$pb.TagNumber(2)
  set enforcer(ChainSync v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasEnforcer() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnforcer() => clearField(2);
  @$pb.TagNumber(2)
  ChainSync ensureEnforcer() => $_ensure(1);

  /// All sidechains the orchestrator knows about. Always includes every
  /// configured sidechain — daemons that aren't running yet appear with
  /// their `sync.error` set so the UI can render a placeholder. While a
  /// sidechain is downloading, its sync.is_downloading is true and
  /// blocks/headers are MB downloaded / MB total.
  @$pb.TagNumber(3)
  $core.List<SidechainStatus> get sidechains => $_getList(2);
}

class SidechainStatus extends $pb.GeneratedMessage {
  factory SidechainStatus({
    SidechainType? type,
    ChainSync? sync,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (sync != null) {
      $result.sync = sync;
    }
    return $result;
  }
  SidechainStatus._() : super();
  factory SidechainStatus.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SidechainStatus.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SidechainStatus', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..e<SidechainType>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: SidechainType.SIDECHAIN_TYPE_UNSPECIFIED, valueOf: SidechainType.valueOf, enumValues: SidechainType.values)
    ..aOM<ChainSync>(2, _omitFieldNames ? '' : 'sync', subBuilder: ChainSync.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SidechainStatus clone() => SidechainStatus()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SidechainStatus copyWith(void Function(SidechainStatus) updates) => super.copyWith((message) => updates(message as SidechainStatus)) as SidechainStatus;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SidechainStatus create() => SidechainStatus._();
  SidechainStatus createEmptyInstance() => create();
  static $pb.PbList<SidechainStatus> createRepeated() => $pb.PbList<SidechainStatus>();
  @$core.pragma('dart2js:noInline')
  static SidechainStatus getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SidechainStatus>(create);
  static SidechainStatus? _defaultInstance;

  @$pb.TagNumber(1)
  SidechainType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(SidechainType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  ChainSync get sync => $_getN(1);
  @$pb.TagNumber(2)
  set sync(ChainSync v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSync() => $_has(1);
  @$pb.TagNumber(2)
  void clearSync() => clearField(2);
  @$pb.TagNumber(2)
  ChainSync ensureSync() => $_ensure(1);
}

class ChainSync extends $pb.GeneratedMessage {
  factory ChainSync({
    $core.int? blocks,
    $core.int? headers,
    $fixnum.Int64? time,
    $core.String? error,
  }) {
    final $result = create();
    if (blocks != null) {
      $result.blocks = blocks;
    }
    if (headers != null) {
      $result.headers = headers;
    }
    if (time != null) {
      $result.time = time;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  ChainSync._() : super();
  factory ChainSync.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChainSync.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChainSync', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'blocks', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'headers', $pb.PbFieldType.O3)
    ..aInt64(3, _omitFieldNames ? '' : 'time')
    ..aOS(4, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChainSync clone() => ChainSync()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChainSync copyWith(void Function(ChainSync) updates) => super.copyWith((message) => updates(message as ChainSync)) as ChainSync;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChainSync create() => ChainSync._();
  ChainSync createEmptyInstance() => create();
  static $pb.PbList<ChainSync> createRepeated() => $pb.PbList<ChainSync>();
  @$core.pragma('dart2js:noInline')
  static ChainSync getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChainSync>(create);
  static ChainSync? _defaultInstance;

  /// Current tip height for the chain.
  @$pb.TagNumber(1)
  $core.int get blocks => $_getIZ(0);
  @$pb.TagNumber(1)
  set blocks($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlocks() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlocks() => clearField(1);

  /// bitcoind's header count, or this daemon's own headers if mainchain is
  /// unavailable.
  @$pb.TagNumber(2)
  $core.int get headers => $_getIZ(1);
  @$pb.TagNumber(2)
  set headers($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeaders() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeaders() => clearField(2);

  /// Block tip timestamp (unix seconds), 0 if no tip yet.
  @$pb.TagNumber(3)
  $fixnum.Int64 get time => $_getI64(2);
  @$pb.TagNumber(3)
  set time($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearTime() => clearField(3);

  /// Empty on success; otherwise a short description of why this daemon's
  /// sync info isn't available (not running, RPC error, etc.).
  @$pb.TagNumber(4)
  $core.String get error => $_getSZ(3);
  @$pb.TagNumber(4)
  set error($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => clearField(4);
}

class GetDownloadStatusRequest extends $pb.GeneratedMessage {
  factory GetDownloadStatusRequest() => create();
  GetDownloadStatusRequest._() : super();
  factory GetDownloadStatusRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetDownloadStatusRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDownloadStatusRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetDownloadStatusRequest clone() => GetDownloadStatusRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetDownloadStatusRequest copyWith(void Function(GetDownloadStatusRequest) updates) => super.copyWith((message) => updates(message as GetDownloadStatusRequest)) as GetDownloadStatusRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDownloadStatusRequest create() => GetDownloadStatusRequest._();
  GetDownloadStatusRequest createEmptyInstance() => create();
  static $pb.PbList<GetDownloadStatusRequest> createRepeated() => $pb.PbList<GetDownloadStatusRequest>();
  @$core.pragma('dart2js:noInline')
  static GetDownloadStatusRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetDownloadStatusRequest>(create);
  static GetDownloadStatusRequest? _defaultInstance;
}

class GetDownloadStatusResponse extends $pb.GeneratedMessage {
  factory GetDownloadStatusResponse({
    $core.Iterable<DownloadStatus>? downloads,
  }) {
    final $result = create();
    if (downloads != null) {
      $result.downloads.addAll(downloads);
    }
    return $result;
  }
  GetDownloadStatusResponse._() : super();
  factory GetDownloadStatusResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetDownloadStatusResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDownloadStatusResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..pc<DownloadStatus>(1, _omitFieldNames ? '' : 'downloads', $pb.PbFieldType.PM, subBuilder: DownloadStatus.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetDownloadStatusResponse clone() => GetDownloadStatusResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetDownloadStatusResponse copyWith(void Function(GetDownloadStatusResponse) updates) => super.copyWith((message) => updates(message as GetDownloadStatusResponse)) as GetDownloadStatusResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDownloadStatusResponse create() => GetDownloadStatusResponse._();
  GetDownloadStatusResponse createEmptyInstance() => create();
  static $pb.PbList<GetDownloadStatusResponse> createRepeated() => $pb.PbList<GetDownloadStatusResponse>();
  @$core.pragma('dart2js:noInline')
  static GetDownloadStatusResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetDownloadStatusResponse>(create);
  static GetDownloadStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<DownloadStatus> get downloads => $_getList(0);
}

class DownloadStatus extends $pb.GeneratedMessage {
  factory DownloadStatus({
    BinaryType? binary,
    $fixnum.Int64? mbDownloaded,
    $fixnum.Int64? mbTotal,
    $core.String? message,
  }) {
    final $result = create();
    if (binary != null) {
      $result.binary = binary;
    }
    if (mbDownloaded != null) {
      $result.mbDownloaded = mbDownloaded;
    }
    if (mbTotal != null) {
      $result.mbTotal = mbTotal;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  DownloadStatus._() : super();
  factory DownloadStatus.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DownloadStatus.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadStatus', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..e<BinaryType>(1, _omitFieldNames ? '' : 'binary', $pb.PbFieldType.OE, defaultOrMaker: BinaryType.BINARY_TYPE_UNSPECIFIED, valueOf: BinaryType.valueOf, enumValues: BinaryType.values)
    ..aInt64(2, _omitFieldNames ? '' : 'mbDownloaded')
    ..aInt64(3, _omitFieldNames ? '' : 'mbTotal')
    ..aOS(4, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DownloadStatus clone() => DownloadStatus()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DownloadStatus copyWith(void Function(DownloadStatus) updates) => super.copyWith((message) => updates(message as DownloadStatus)) as DownloadStatus;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadStatus create() => DownloadStatus._();
  DownloadStatus createEmptyInstance() => create();
  static $pb.PbList<DownloadStatus> createRepeated() => $pb.PbList<DownloadStatus>();
  @$core.pragma('dart2js:noInline')
  static DownloadStatus getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadStatus>(create);
  static DownloadStatus? _defaultInstance;

  /// Typed identifier for the binary being downloaded.
  @$pb.TagNumber(1)
  BinaryType get binary => $_getN(0);
  @$pb.TagNumber(1)
  set binary(BinaryType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBinary() => $_has(0);
  @$pb.TagNumber(1)
  void clearBinary() => clearField(1);

  /// Megabytes downloaded so far. Source of truth lives in DownloadManager.
  @$pb.TagNumber(2)
  $fixnum.Int64 get mbDownloaded => $_getI64(1);
  @$pb.TagNumber(2)
  set mbDownloaded($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMbDownloaded() => $_has(1);
  @$pb.TagNumber(2)
  void clearMbDownloaded() => clearField(2);

  /// Total size in megabytes, or -1 when the server hasn't reported a
  /// Content-Length yet.
  @$pb.TagNumber(3)
  $fixnum.Int64 get mbTotal => $_getI64(2);
  @$pb.TagNumber(3)
  set mbTotal($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMbTotal() => $_has(2);
  @$pb.TagNumber(3)
  void clearMbTotal() => clearField(3);

  /// Optional human-readable progress string ("verifying hash", ...).
  @$pb.TagNumber(4)
  $core.String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => clearField(4);
}

class GetMainchainBalanceRequest extends $pb.GeneratedMessage {
  factory GetMainchainBalanceRequest() => create();
  GetMainchainBalanceRequest._() : super();
  factory GetMainchainBalanceRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetMainchainBalanceRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMainchainBalanceRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetMainchainBalanceRequest clone() => GetMainchainBalanceRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetMainchainBalanceRequest copyWith(void Function(GetMainchainBalanceRequest) updates) => super.copyWith((message) => updates(message as GetMainchainBalanceRequest)) as GetMainchainBalanceRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMainchainBalanceRequest create() => GetMainchainBalanceRequest._();
  GetMainchainBalanceRequest createEmptyInstance() => create();
  static $pb.PbList<GetMainchainBalanceRequest> createRepeated() => $pb.PbList<GetMainchainBalanceRequest>();
  @$core.pragma('dart2js:noInline')
  static GetMainchainBalanceRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMainchainBalanceRequest>(create);
  static GetMainchainBalanceRequest? _defaultInstance;
}

class GetMainchainBalanceResponse extends $pb.GeneratedMessage {
  factory GetMainchainBalanceResponse({
    $core.double? confirmed,
    $core.double? unconfirmed,
  }) {
    final $result = create();
    if (confirmed != null) {
      $result.confirmed = confirmed;
    }
    if (unconfirmed != null) {
      $result.unconfirmed = unconfirmed;
    }
    return $result;
  }
  GetMainchainBalanceResponse._() : super();
  factory GetMainchainBalanceResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetMainchainBalanceResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMainchainBalanceResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'confirmed', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'unconfirmed', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetMainchainBalanceResponse clone() => GetMainchainBalanceResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetMainchainBalanceResponse copyWith(void Function(GetMainchainBalanceResponse) updates) => super.copyWith((message) => updates(message as GetMainchainBalanceResponse)) as GetMainchainBalanceResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMainchainBalanceResponse create() => GetMainchainBalanceResponse._();
  GetMainchainBalanceResponse createEmptyInstance() => create();
  static $pb.PbList<GetMainchainBalanceResponse> createRepeated() => $pb.PbList<GetMainchainBalanceResponse>();
  @$core.pragma('dart2js:noInline')
  static GetMainchainBalanceResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMainchainBalanceResponse>(create);
  static GetMainchainBalanceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get confirmed => $_getN(0);
  @$pb.TagNumber(1)
  set confirmed($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConfirmed() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfirmed() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get unconfirmed => $_getN(1);
  @$pb.TagNumber(2)
  set unconfirmed($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUnconfirmed() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnconfirmed() => clearField(2);
}

/// One binary plus the categories of its data to act on.
class SingleDeletion extends $pb.GeneratedMessage {
  factory SingleDeletion({
    BinaryType? binary,
    $core.Iterable<DeletionType>? deletions,
  }) {
    final $result = create();
    if (binary != null) {
      $result.binary = binary;
    }
    if (deletions != null) {
      $result.deletions.addAll(deletions);
    }
    return $result;
  }
  SingleDeletion._() : super();
  factory SingleDeletion.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SingleDeletion.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SingleDeletion', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..e<BinaryType>(1, _omitFieldNames ? '' : 'binary', $pb.PbFieldType.OE, defaultOrMaker: BinaryType.BINARY_TYPE_UNSPECIFIED, valueOf: BinaryType.valueOf, enumValues: BinaryType.values)
    ..pc<DeletionType>(2, _omitFieldNames ? '' : 'deletions', $pb.PbFieldType.KE, valueOf: DeletionType.valueOf, enumValues: DeletionType.values, defaultEnumValue: DeletionType.DELETION_TYPE_UNSPECIFIED)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SingleDeletion clone() => SingleDeletion()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SingleDeletion copyWith(void Function(SingleDeletion) updates) => super.copyWith((message) => updates(message as SingleDeletion)) as SingleDeletion;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SingleDeletion create() => SingleDeletion._();
  SingleDeletion createEmptyInstance() => create();
  static $pb.PbList<SingleDeletion> createRepeated() => $pb.PbList<SingleDeletion>();
  @$core.pragma('dart2js:noInline')
  static SingleDeletion getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SingleDeletion>(create);
  static SingleDeletion? _defaultInstance;

  @$pb.TagNumber(1)
  BinaryType get binary => $_getN(0);
  @$pb.TagNumber(1)
  set binary(BinaryType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBinary() => $_has(0);
  @$pb.TagNumber(1)
  void clearBinary() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<DeletionType> get deletions => $_getList(1);
}

class GatherFilesToDeleteRequest extends $pb.GeneratedMessage {
  factory GatherFilesToDeleteRequest({
    $core.Iterable<SingleDeletion>? items,
  }) {
    final $result = create();
    if (items != null) {
      $result.items.addAll(items);
    }
    return $result;
  }
  GatherFilesToDeleteRequest._() : super();
  factory GatherFilesToDeleteRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GatherFilesToDeleteRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GatherFilesToDeleteRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..pc<SingleDeletion>(1, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: SingleDeletion.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GatherFilesToDeleteRequest clone() => GatherFilesToDeleteRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GatherFilesToDeleteRequest copyWith(void Function(GatherFilesToDeleteRequest) updates) => super.copyWith((message) => updates(message as GatherFilesToDeleteRequest)) as GatherFilesToDeleteRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GatherFilesToDeleteRequest create() => GatherFilesToDeleteRequest._();
  GatherFilesToDeleteRequest createEmptyInstance() => create();
  static $pb.PbList<GatherFilesToDeleteRequest> createRepeated() => $pb.PbList<GatherFilesToDeleteRequest>();
  @$core.pragma('dart2js:noInline')
  static GatherFilesToDeleteRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GatherFilesToDeleteRequest>(create);
  static GatherFilesToDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<SingleDeletion> get items => $_getList(0);
}

class GatherFilesToDeleteResponse extends $pb.GeneratedMessage {
  factory GatherFilesToDeleteResponse({
    $core.Iterable<ResetFileInfo>? files,
  }) {
    final $result = create();
    if (files != null) {
      $result.files.addAll(files);
    }
    return $result;
  }
  GatherFilesToDeleteResponse._() : super();
  factory GatherFilesToDeleteResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GatherFilesToDeleteResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GatherFilesToDeleteResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..pc<ResetFileInfo>(1, _omitFieldNames ? '' : 'files', $pb.PbFieldType.PM, subBuilder: ResetFileInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GatherFilesToDeleteResponse clone() => GatherFilesToDeleteResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GatherFilesToDeleteResponse copyWith(void Function(GatherFilesToDeleteResponse) updates) => super.copyWith((message) => updates(message as GatherFilesToDeleteResponse)) as GatherFilesToDeleteResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GatherFilesToDeleteResponse create() => GatherFilesToDeleteResponse._();
  GatherFilesToDeleteResponse createEmptyInstance() => create();
  static $pb.PbList<GatherFilesToDeleteResponse> createRepeated() => $pb.PbList<GatherFilesToDeleteResponse>();
  @$core.pragma('dart2js:noInline')
  static GatherFilesToDeleteResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GatherFilesToDeleteResponse>(create);
  static GatherFilesToDeleteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ResetFileInfo> get files => $_getList(0);
}

class ResetFileInfo extends $pb.GeneratedMessage {
  factory ResetFileInfo({
    $core.String? path,
    DeletionType? deletionType,
    BinaryType? binary,
    $fixnum.Int64? sizeBytes,
    $core.bool? isDirectory,
  }) {
    final $result = create();
    if (path != null) {
      $result.path = path;
    }
    if (deletionType != null) {
      $result.deletionType = deletionType;
    }
    if (binary != null) {
      $result.binary = binary;
    }
    if (sizeBytes != null) {
      $result.sizeBytes = sizeBytes;
    }
    if (isDirectory != null) {
      $result.isDirectory = isDirectory;
    }
    return $result;
  }
  ResetFileInfo._() : super();
  factory ResetFileInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ResetFileInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResetFileInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..e<DeletionType>(2, _omitFieldNames ? '' : 'deletionType', $pb.PbFieldType.OE, defaultOrMaker: DeletionType.DELETION_TYPE_UNSPECIFIED, valueOf: DeletionType.valueOf, enumValues: DeletionType.values)
    ..e<BinaryType>(3, _omitFieldNames ? '' : 'binary', $pb.PbFieldType.OE, defaultOrMaker: BinaryType.BINARY_TYPE_UNSPECIFIED, valueOf: BinaryType.valueOf, enumValues: BinaryType.values)
    ..aInt64(4, _omitFieldNames ? '' : 'sizeBytes')
    ..aOB(5, _omitFieldNames ? '' : 'isDirectory')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ResetFileInfo clone() => ResetFileInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ResetFileInfo copyWith(void Function(ResetFileInfo) updates) => super.copyWith((message) => updates(message as ResetFileInfo)) as ResetFileInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResetFileInfo create() => ResetFileInfo._();
  ResetFileInfo createEmptyInstance() => create();
  static $pb.PbList<ResetFileInfo> createRepeated() => $pb.PbList<ResetFileInfo>();
  @$core.pragma('dart2js:noInline')
  static ResetFileInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ResetFileInfo>(create);
  static ResetFileInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => clearField(1);

  @$pb.TagNumber(2)
  DeletionType get deletionType => $_getN(1);
  @$pb.TagNumber(2)
  set deletionType(DeletionType v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeletionType() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeletionType() => clearField(2);

  @$pb.TagNumber(3)
  BinaryType get binary => $_getN(2);
  @$pb.TagNumber(3)
  set binary(BinaryType v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasBinary() => $_has(2);
  @$pb.TagNumber(3)
  void clearBinary() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sizeBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set sizeBytes($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSizeBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearSizeBytes() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isDirectory => $_getBF(4);
  @$pb.TagNumber(5)
  set isDirectory($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsDirectory() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsDirectory() => clearField(5);
}

class DeleteFilesRequest extends $pb.GeneratedMessage {
  factory DeleteFilesRequest({
    $core.Iterable<$core.String>? paths,
  }) {
    final $result = create();
    if (paths != null) {
      $result.paths.addAll(paths);
    }
    return $result;
  }
  DeleteFilesRequest._() : super();
  factory DeleteFilesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteFilesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteFilesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'paths')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteFilesRequest clone() => DeleteFilesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteFilesRequest copyWith(void Function(DeleteFilesRequest) updates) => super.copyWith((message) => updates(message as DeleteFilesRequest)) as DeleteFilesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteFilesRequest create() => DeleteFilesRequest._();
  DeleteFilesRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteFilesRequest> createRepeated() => $pb.PbList<DeleteFilesRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteFilesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteFilesRequest>(create);
  static DeleteFilesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get paths => $_getList(0);
}

class DeleteFilesResponse extends $pb.GeneratedMessage {
  factory DeleteFilesResponse({
    $core.String? path,
    $core.String? error,
  }) {
    final $result = create();
    if (path != null) {
      $result.path = path;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  DeleteFilesResponse._() : super();
  factory DeleteFilesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteFilesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteFilesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteFilesResponse clone() => DeleteFilesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteFilesResponse copyWith(void Function(DeleteFilesResponse) updates) => super.copyWith((message) => updates(message as DeleteFilesResponse)) as DeleteFilesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteFilesResponse create() => DeleteFilesResponse._();
  DeleteFilesResponse createEmptyInstance() => create();
  static $pb.PbList<DeleteFilesResponse> createRepeated() => $pb.PbList<DeleteFilesResponse>();
  @$core.pragma('dart2js:noInline')
  static DeleteFilesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteFilesResponse>(create);
  static DeleteFilesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => clearField(2);
}

class GetCoreMempoolInfoRequest extends $pb.GeneratedMessage {
  factory GetCoreMempoolInfoRequest() => create();
  GetCoreMempoolInfoRequest._() : super();
  factory GetCoreMempoolInfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCoreMempoolInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoreMempoolInfoRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCoreMempoolInfoRequest clone() => GetCoreMempoolInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCoreMempoolInfoRequest copyWith(void Function(GetCoreMempoolInfoRequest) updates) => super.copyWith((message) => updates(message as GetCoreMempoolInfoRequest)) as GetCoreMempoolInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCoreMempoolInfoRequest create() => GetCoreMempoolInfoRequest._();
  GetCoreMempoolInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetCoreMempoolInfoRequest> createRepeated() => $pb.PbList<GetCoreMempoolInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetCoreMempoolInfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoreMempoolInfoRequest>(create);
  static GetCoreMempoolInfoRequest? _defaultInstance;
}

/// Mirrors bitcoind's getmempoolinfo. Aggregate stats — distinct from
/// getrawmempool which lists individual mempool txids.
class GetCoreMempoolInfoResponse extends $pb.GeneratedMessage {
  factory GetCoreMempoolInfoResponse({
    $core.bool? loaded,
    $fixnum.Int64? size,
    $fixnum.Int64? bytes,
    $fixnum.Int64? usage,
    $core.double? totalFee,
    $fixnum.Int64? maxMempool,
    $core.double? mempoolMinFee,
    $core.double? minRelayTxFee,
    $core.double? incrementalRelayFee,
    $fixnum.Int64? unbroadcastCount,
    $core.bool? fullRbf,
  }) {
    final $result = create();
    if (loaded != null) {
      $result.loaded = loaded;
    }
    if (size != null) {
      $result.size = size;
    }
    if (bytes != null) {
      $result.bytes = bytes;
    }
    if (usage != null) {
      $result.usage = usage;
    }
    if (totalFee != null) {
      $result.totalFee = totalFee;
    }
    if (maxMempool != null) {
      $result.maxMempool = maxMempool;
    }
    if (mempoolMinFee != null) {
      $result.mempoolMinFee = mempoolMinFee;
    }
    if (minRelayTxFee != null) {
      $result.minRelayTxFee = minRelayTxFee;
    }
    if (incrementalRelayFee != null) {
      $result.incrementalRelayFee = incrementalRelayFee;
    }
    if (unbroadcastCount != null) {
      $result.unbroadcastCount = unbroadcastCount;
    }
    if (fullRbf != null) {
      $result.fullRbf = fullRbf;
    }
    return $result;
  }
  GetCoreMempoolInfoResponse._() : super();
  factory GetCoreMempoolInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCoreMempoolInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoreMempoolInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'loaded')
    ..aInt64(2, _omitFieldNames ? '' : 'size')
    ..aInt64(3, _omitFieldNames ? '' : 'bytes')
    ..aInt64(4, _omitFieldNames ? '' : 'usage')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'totalFee', $pb.PbFieldType.OD)
    ..aInt64(6, _omitFieldNames ? '' : 'maxMempool')
    ..a<$core.double>(7, _omitFieldNames ? '' : 'mempoolMinFee', $pb.PbFieldType.OD)
    ..a<$core.double>(8, _omitFieldNames ? '' : 'minRelayTxFee', $pb.PbFieldType.OD)
    ..a<$core.double>(9, _omitFieldNames ? '' : 'incrementalRelayFee', $pb.PbFieldType.OD)
    ..aInt64(10, _omitFieldNames ? '' : 'unbroadcastCount')
    ..aOB(11, _omitFieldNames ? '' : 'fullRbf')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCoreMempoolInfoResponse clone() => GetCoreMempoolInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCoreMempoolInfoResponse copyWith(void Function(GetCoreMempoolInfoResponse) updates) => super.copyWith((message) => updates(message as GetCoreMempoolInfoResponse)) as GetCoreMempoolInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCoreMempoolInfoResponse create() => GetCoreMempoolInfoResponse._();
  GetCoreMempoolInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetCoreMempoolInfoResponse> createRepeated() => $pb.PbList<GetCoreMempoolInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetCoreMempoolInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoreMempoolInfoResponse>(create);
  static GetCoreMempoolInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get loaded => $_getBF(0);
  @$pb.TagNumber(1)
  set loaded($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoaded() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoaded() => clearField(1);

  /// Number of transactions in the mempool.
  @$pb.TagNumber(2)
  $fixnum.Int64 get size => $_getI64(1);
  @$pb.TagNumber(2)
  set size($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearSize() => clearField(2);

  /// Sum of serialized sizes (bytes).
  @$pb.TagNumber(3)
  $fixnum.Int64 get bytes => $_getI64(2);
  @$pb.TagNumber(3)
  set bytes($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearBytes() => clearField(3);

  /// Total memory usage (bytes).
  @$pb.TagNumber(4)
  $fixnum.Int64 get usage => $_getI64(3);
  @$pb.TagNumber(4)
  set usage($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUsage() => $_has(3);
  @$pb.TagNumber(4)
  void clearUsage() => clearField(4);

  /// Sum of all tx fees (BTC).
  @$pb.TagNumber(5)
  $core.double get totalFee => $_getN(4);
  @$pb.TagNumber(5)
  set totalFee($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTotalFee() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalFee() => clearField(5);

  /// Mempool size cap (bytes).
  @$pb.TagNumber(6)
  $fixnum.Int64 get maxMempool => $_getI64(5);
  @$pb.TagNumber(6)
  set maxMempool($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMaxMempool() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxMempool() => clearField(6);

  /// Lowest fee rate accepted into mempool (BTC/kvB).
  @$pb.TagNumber(7)
  $core.double get mempoolMinFee => $_getN(6);
  @$pb.TagNumber(7)
  set mempoolMinFee($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMempoolMinFee() => $_has(6);
  @$pb.TagNumber(7)
  void clearMempoolMinFee() => clearField(7);

  /// Lowest fee rate eligible for relay (BTC/kvB).
  @$pb.TagNumber(8)
  $core.double get minRelayTxFee => $_getN(7);
  @$pb.TagNumber(8)
  set minRelayTxFee($core.double v) { $_setDouble(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasMinRelayTxFee() => $_has(7);
  @$pb.TagNumber(8)
  void clearMinRelayTxFee() => clearField(8);

  /// Minimum bump-fee increment (BTC/kvB).
  @$pb.TagNumber(9)
  $core.double get incrementalRelayFee => $_getN(8);
  @$pb.TagNumber(9)
  set incrementalRelayFee($core.double v) { $_setDouble(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasIncrementalRelayFee() => $_has(8);
  @$pb.TagNumber(9)
  void clearIncrementalRelayFee() => clearField(9);

  /// Transactions in mempool not yet broadcast.
  @$pb.TagNumber(10)
  $fixnum.Int64 get unbroadcastCount => $_getI64(9);
  @$pb.TagNumber(10)
  set unbroadcastCount($fixnum.Int64 v) { $_setInt64(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasUnbroadcastCount() => $_has(9);
  @$pb.TagNumber(10)
  void clearUnbroadcastCount() => clearField(10);

  @$pb.TagNumber(11)
  $core.bool get fullRbf => $_getBF(10);
  @$pb.TagNumber(11)
  set fullRbf($core.bool v) { $_setBool(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasFullRbf() => $_has(10);
  @$pb.TagNumber(11)
  void clearFullRbf() => clearField(11);
}

class CoreRawCallRequest extends $pb.GeneratedMessage {
  factory CoreRawCallRequest({
    $core.String? method,
    $core.String? paramsJson,
    $core.String? wallet,
  }) {
    final $result = create();
    if (method != null) {
      $result.method = method;
    }
    if (paramsJson != null) {
      $result.paramsJson = paramsJson;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  CoreRawCallRequest._() : super();
  factory CoreRawCallRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CoreRawCallRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CoreRawCallRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'method')
    ..aOS(2, _omitFieldNames ? '' : 'paramsJson')
    ..aOS(3, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CoreRawCallRequest clone() => CoreRawCallRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CoreRawCallRequest copyWith(void Function(CoreRawCallRequest) updates) => super.copyWith((message) => updates(message as CoreRawCallRequest)) as CoreRawCallRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CoreRawCallRequest create() => CoreRawCallRequest._();
  CoreRawCallRequest createEmptyInstance() => create();
  static $pb.PbList<CoreRawCallRequest> createRepeated() => $pb.PbList<CoreRawCallRequest>();
  @$core.pragma('dart2js:noInline')
  static CoreRawCallRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CoreRawCallRequest>(create);
  static CoreRawCallRequest? _defaultInstance;

  /// bitcoind RPC method name (e.g. "finalizepsbt").
  @$pb.TagNumber(1)
  $core.String get method => $_getSZ(0);
  @$pb.TagNumber(1)
  set method($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMethod() => $_has(0);
  @$pb.TagNumber(1)
  void clearMethod() => clearField(1);

  /// JSON-encoded positional params array (e.g. '["psbtBase64", false]').
  /// Empty string means no params.
  @$pb.TagNumber(2)
  $core.String get paramsJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set paramsJson($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasParamsJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearParamsJson() => clearField(2);

  /// Optional bitcoind wallet name to scope the call to. When set, the request
  /// is routed to /wallet/{wallet} on bitcoind so wallet-scoped RPCs like
  /// listtransactions / getbalance / getwalletinfo dispatch to the right
  /// wallet. Empty = node-level call.
  @$pb.TagNumber(3)
  $core.String get wallet => $_getSZ(2);
  @$pb.TagNumber(3)
  set wallet($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWallet() => $_has(2);
  @$pb.TagNumber(3)
  void clearWallet() => clearField(3);
}

class CoreRawCallResponse extends $pb.GeneratedMessage {
  factory CoreRawCallResponse({
    $core.String? resultJson,
  }) {
    final $result = create();
    if (resultJson != null) {
      $result.resultJson = resultJson;
    }
    return $result;
  }
  CoreRawCallResponse._() : super();
  factory CoreRawCallResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CoreRawCallResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CoreRawCallResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'resultJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CoreRawCallResponse clone() => CoreRawCallResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CoreRawCallResponse copyWith(void Function(CoreRawCallResponse) updates) => super.copyWith((message) => updates(message as CoreRawCallResponse)) as CoreRawCallResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CoreRawCallResponse create() => CoreRawCallResponse._();
  CoreRawCallResponse createEmptyInstance() => create();
  static $pb.PbList<CoreRawCallResponse> createRepeated() => $pb.PbList<CoreRawCallResponse>();
  @$core.pragma('dart2js:noInline')
  static CoreRawCallResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CoreRawCallResponse>(create);
  static CoreRawCallResponse? _defaultInstance;

  /// JSON-encoded result. Caller decodes to its expected shape.
  @$pb.TagNumber(1)
  $core.String get resultJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set resultJson($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasResultJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearResultJson() => clearField(1);
}

class ShutdownRequest extends $pb.GeneratedMessage {
  factory ShutdownRequest() => create();
  ShutdownRequest._() : super();
  factory ShutdownRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ShutdownRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ShutdownRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ShutdownRequest clone() => ShutdownRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ShutdownRequest copyWith(void Function(ShutdownRequest) updates) => super.copyWith((message) => updates(message as ShutdownRequest)) as ShutdownRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ShutdownRequest create() => ShutdownRequest._();
  ShutdownRequest createEmptyInstance() => create();
  static $pb.PbList<ShutdownRequest> createRepeated() => $pb.PbList<ShutdownRequest>();
  @$core.pragma('dart2js:noInline')
  static ShutdownRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShutdownRequest>(create);
  static ShutdownRequest? _defaultInstance;
}

class ShutdownResponse extends $pb.GeneratedMessage {
  factory ShutdownResponse() => create();
  ShutdownResponse._() : super();
  factory ShutdownResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ShutdownResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ShutdownResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ShutdownResponse clone() => ShutdownResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ShutdownResponse copyWith(void Function(ShutdownResponse) updates) => super.copyWith((message) => updates(message as ShutdownResponse)) as ShutdownResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ShutdownResponse create() => ShutdownResponse._();
  ShutdownResponse createEmptyInstance() => create();
  static $pb.PbList<ShutdownResponse> createRepeated() => $pb.PbList<ShutdownResponse>();
  @$core.pragma('dart2js:noInline')
  static ShutdownResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShutdownResponse>(create);
  static ShutdownResponse? _defaultInstance;
}

class OrchestratorServiceApi {
  $pb.RpcClient _client;
  OrchestratorServiceApi(this._client);

  $async.Future<ListBinariesResponse> listBinaries($pb.ClientContext? ctx, ListBinariesRequest request) =>
    _client.invoke<ListBinariesResponse>(ctx, 'OrchestratorService', 'ListBinaries', request, ListBinariesResponse())
  ;
  $async.Future<GetBinaryStatusResponse> getBinaryStatus($pb.ClientContext? ctx, GetBinaryStatusRequest request) =>
    _client.invoke<GetBinaryStatusResponse>(ctx, 'OrchestratorService', 'GetBinaryStatus', request, GetBinaryStatusResponse())
  ;
  $async.Future<DownloadBinaryResponse> downloadBinary($pb.ClientContext? ctx, DownloadBinaryRequest request) =>
    _client.invoke<DownloadBinaryResponse>(ctx, 'OrchestratorService', 'DownloadBinary', request, DownloadBinaryResponse())
  ;
  $async.Future<StartBinaryResponse> startBinary($pb.ClientContext? ctx, StartBinaryRequest request) =>
    _client.invoke<StartBinaryResponse>(ctx, 'OrchestratorService', 'StartBinary', request, StartBinaryResponse())
  ;
  $async.Future<StopBinaryResponse> stopBinary($pb.ClientContext? ctx, StopBinaryRequest request) =>
    _client.invoke<StopBinaryResponse>(ctx, 'OrchestratorService', 'StopBinary', request, StopBinaryResponse())
  ;
  $async.Future<StreamLogsResponse> streamLogs($pb.ClientContext? ctx, StreamLogsRequest request) =>
    _client.invoke<StreamLogsResponse>(ctx, 'OrchestratorService', 'StreamLogs', request, StreamLogsResponse())
  ;
  $async.Future<StartWithL1Response> startWithL1($pb.ClientContext? ctx, StartWithL1Request request) =>
    _client.invoke<StartWithL1Response>(ctx, 'OrchestratorService', 'StartWithL1', request, StartWithL1Response())
  ;
  $async.Future<RestartDaemonResponse> restartDaemon($pb.ClientContext? ctx, RestartDaemonRequest request) =>
    _client.invoke<RestartDaemonResponse>(ctx, 'OrchestratorService', 'RestartDaemon', request, RestartDaemonResponse())
  ;
  $async.Future<RestartL1Response> restartL1($pb.ClientContext? ctx, RestartL1Request request) =>
    _client.invoke<RestartL1Response>(ctx, 'OrchestratorService', 'RestartL1', request, RestartL1Response())
  ;
  $async.Future<ShutdownAllResponse> shutdownAll($pb.ClientContext? ctx, ShutdownAllRequest request) =>
    _client.invoke<ShutdownAllResponse>(ctx, 'OrchestratorService', 'ShutdownAll', request, ShutdownAllResponse())
  ;
  $async.Future<ShutdownResponse> shutdown($pb.ClientContext? ctx, ShutdownRequest request) =>
    _client.invoke<ShutdownResponse>(ctx, 'OrchestratorService', 'Shutdown', request, ShutdownResponse())
  ;
  $async.Future<GetBTCPriceResponse> getBTCPrice($pb.ClientContext? ctx, GetBTCPriceRequest request) =>
    _client.invoke<GetBTCPriceResponse>(ctx, 'OrchestratorService', 'GetBTCPrice', request, GetBTCPriceResponse())
  ;
  $async.Future<GetMainchainBlockchainInfoResponse> getMainchainBlockchainInfo($pb.ClientContext? ctx, GetMainchainBlockchainInfoRequest request) =>
    _client.invoke<GetMainchainBlockchainInfoResponse>(ctx, 'OrchestratorService', 'GetMainchainBlockchainInfo', request, GetMainchainBlockchainInfoResponse())
  ;
  $async.Future<GetEnforcerBlockchainInfoResponse> getEnforcerBlockchainInfo($pb.ClientContext? ctx, GetEnforcerBlockchainInfoRequest request) =>
    _client.invoke<GetEnforcerBlockchainInfoResponse>(ctx, 'OrchestratorService', 'GetEnforcerBlockchainInfo', request, GetEnforcerBlockchainInfoResponse())
  ;
  $async.Future<GetSyncStatusResponse> getSyncStatus($pb.ClientContext? ctx, GetSyncStatusRequest request) =>
    _client.invoke<GetSyncStatusResponse>(ctx, 'OrchestratorService', 'GetSyncStatus', request, GetSyncStatusResponse())
  ;
  $async.Future<GetDownloadStatusResponse> getDownloadStatus($pb.ClientContext? ctx, GetDownloadStatusRequest request) =>
    _client.invoke<GetDownloadStatusResponse>(ctx, 'OrchestratorService', 'GetDownloadStatus', request, GetDownloadStatusResponse())
  ;
  $async.Future<GetMainchainBalanceResponse> getMainchainBalance($pb.ClientContext? ctx, GetMainchainBalanceRequest request) =>
    _client.invoke<GetMainchainBalanceResponse>(ctx, 'OrchestratorService', 'GetMainchainBalance', request, GetMainchainBalanceResponse())
  ;
  $async.Future<GatherFilesToDeleteResponse> gatherFilesToDelete($pb.ClientContext? ctx, GatherFilesToDeleteRequest request) =>
    _client.invoke<GatherFilesToDeleteResponse>(ctx, 'OrchestratorService', 'GatherFilesToDelete', request, GatherFilesToDeleteResponse())
  ;
  $async.Future<DeleteFilesResponse> deleteFiles($pb.ClientContext? ctx, DeleteFilesRequest request) =>
    _client.invoke<DeleteFilesResponse>(ctx, 'OrchestratorService', 'DeleteFiles', request, DeleteFilesResponse())
  ;
  $async.Future<GetCoreMempoolInfoResponse> getCoreMempoolInfo($pb.ClientContext? ctx, GetCoreMempoolInfoRequest request) =>
    _client.invoke<GetCoreMempoolInfoResponse>(ctx, 'OrchestratorService', 'GetCoreMempoolInfo', request, GetCoreMempoolInfoResponse())
  ;
  $async.Future<CoreRawCallResponse> coreRawCall($pb.ClientContext? ctx, CoreRawCallRequest request) =>
    _client.invoke<CoreRawCallResponse>(ctx, 'OrchestratorService', 'CoreRawCall', request, CoreRawCallResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
