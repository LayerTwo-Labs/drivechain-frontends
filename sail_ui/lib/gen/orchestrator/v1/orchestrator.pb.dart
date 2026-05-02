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
  factory BinaryStatusMsg.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory BinaryStatusMsg.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BinaryStatusMsg',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
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
    ..pc<StartupLogEntryMsg>(22, _omitFieldNames ? '' : 'startupLogs', $pb.PbFieldType.PM,
        subBuilder: StartupLogEntryMsg.create)
    ..aOS(23, _omitFieldNames ? '' : 'binaryPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  BinaryStatusMsg clone() => BinaryStatusMsg()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  BinaryStatusMsg copyWith(void Function(BinaryStatusMsg) updates) =>
      super.copyWith((message) => updates(message as BinaryStatusMsg)) as BinaryStatusMsg;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BinaryStatusMsg create() => BinaryStatusMsg._();
  BinaryStatusMsg createEmptyInstance() => create();
  static $pb.PbList<BinaryStatusMsg> createRepeated() => $pb.PbList<BinaryStatusMsg>();
  @$core.pragma('dart2js:noInline')
  static BinaryStatusMsg getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BinaryStatusMsg>(create);
  static BinaryStatusMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get running => $_getBF(2);
  @$pb.TagNumber(3)
  set running($core.bool v) {
    $_setBool(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasRunning() => $_has(2);
  @$pb.TagNumber(3)
  void clearRunning() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get healthy => $_getBF(3);
  @$pb.TagNumber(4)
  set healthy($core.bool v) {
    $_setBool(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasHealthy() => $_has(3);
  @$pb.TagNumber(4)
  void clearHealthy() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get pid => $_getIZ(4);
  @$pb.TagNumber(5)
  set pid($core.int v) {
    $_setSignedInt32(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasPid() => $_has(4);
  @$pb.TagNumber(5)
  void clearPid() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get uptimeSeconds => $_getI64(5);
  @$pb.TagNumber(6)
  set uptimeSeconds($fixnum.Int64 v) {
    $_setInt64(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasUptimeSeconds() => $_has(5);
  @$pb.TagNumber(6)
  void clearUptimeSeconds() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get chainLayer => $_getIZ(6);
  @$pb.TagNumber(7)
  set chainLayer($core.int v) {
    $_setSignedInt32(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasChainLayer() => $_has(6);
  @$pb.TagNumber(7)
  void clearChainLayer() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get port => $_getIZ(7);
  @$pb.TagNumber(8)
  set port($core.int v) {
    $_setSignedInt32(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasPort() => $_has(7);
  @$pb.TagNumber(8)
  void clearPort() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get error => $_getSZ(8);
  @$pb.TagNumber(9)
  set error($core.String v) {
    $_setString(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasError() => $_has(8);
  @$pb.TagNumber(9)
  void clearError() => clearField(9);

  @$pb.TagNumber(10)
  $core.bool get connected => $_getBF(9);
  @$pb.TagNumber(10)
  set connected($core.bool v) {
    $_setBool(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasConnected() => $_has(9);
  @$pb.TagNumber(10)
  void clearConnected() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get startupError => $_getSZ(10);
  @$pb.TagNumber(11)
  set startupError($core.String v) {
    $_setString(10, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasStartupError() => $_has(10);
  @$pb.TagNumber(11)
  void clearStartupError() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get connectionError => $_getSZ(11);
  @$pb.TagNumber(12)
  set connectionError($core.String v) {
    $_setString(11, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasConnectionError() => $_has(11);
  @$pb.TagNumber(12)
  void clearConnectionError() => clearField(12);

  @$pb.TagNumber(13)
  $core.bool get stopping => $_getBF(12);
  @$pb.TagNumber(13)
  set stopping($core.bool v) {
    $_setBool(12, v);
  }

  @$pb.TagNumber(13)
  $core.bool hasStopping() => $_has(12);
  @$pb.TagNumber(13)
  void clearStopping() => clearField(13);

  @$pb.TagNumber(14)
  $core.bool get initializing => $_getBF(13);
  @$pb.TagNumber(14)
  set initializing($core.bool v) {
    $_setBool(13, v);
  }

  @$pb.TagNumber(14)
  $core.bool hasInitializing() => $_has(13);
  @$pb.TagNumber(14)
  void clearInitializing() => clearField(14);

  @$pb.TagNumber(15)
  $core.bool get connectModeOnly => $_getBF(14);
  @$pb.TagNumber(15)
  set connectModeOnly($core.bool v) {
    $_setBool(14, v);
  }

  @$pb.TagNumber(15)
  $core.bool hasConnectModeOnly() => $_has(14);
  @$pb.TagNumber(15)
  void clearConnectModeOnly() => clearField(15);

  @$pb.TagNumber(16)
  $core.bool get downloadable => $_getBF(15);
  @$pb.TagNumber(16)
  set downloadable($core.bool v) {
    $_setBool(15, v);
  }

  @$pb.TagNumber(16)
  $core.bool hasDownloadable() => $_has(15);
  @$pb.TagNumber(16)
  void clearDownloadable() => clearField(16);

  @$pb.TagNumber(17)
  $core.String get description => $_getSZ(16);
  @$pb.TagNumber(17)
  set description($core.String v) {
    $_setString(16, v);
  }

  @$pb.TagNumber(17)
  $core.bool hasDescription() => $_has(16);
  @$pb.TagNumber(17)
  void clearDescription() => clearField(17);

  @$pb.TagNumber(18)
  $core.bool get downloaded => $_getBF(17);
  @$pb.TagNumber(18)
  set downloaded($core.bool v) {
    $_setBool(17, v);
  }

  @$pb.TagNumber(18)
  $core.bool hasDownloaded() => $_has(17);
  @$pb.TagNumber(18)
  void clearDownloaded() => clearField(18);

  @$pb.TagNumber(19)
  $core.bool get portInUse => $_getBF(18);
  @$pb.TagNumber(19)
  set portInUse($core.bool v) {
    $_setBool(18, v);
  }

  @$pb.TagNumber(19)
  $core.bool hasPortInUse() => $_has(18);
  @$pb.TagNumber(19)
  void clearPortInUse() => clearField(19);

  @$pb.TagNumber(20)
  $core.String get version => $_getSZ(19);
  @$pb.TagNumber(20)
  set version($core.String v) {
    $_setString(19, v);
  }

  @$pb.TagNumber(20)
  $core.bool hasVersion() => $_has(19);
  @$pb.TagNumber(20)
  void clearVersion() => clearField(20);

  @$pb.TagNumber(21)
  $core.String get repoUrl => $_getSZ(20);
  @$pb.TagNumber(21)
  set repoUrl($core.String v) {
    $_setString(20, v);
  }

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
  set binaryPath($core.String v) {
    $_setString(22, v);
  }

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
  factory StartupLogEntryMsg.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory StartupLogEntryMsg.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartupLogEntryMsg',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'timestampUnix')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  StartupLogEntryMsg clone() => StartupLogEntryMsg()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  StartupLogEntryMsg copyWith(void Function(StartupLogEntryMsg) updates) =>
      super.copyWith((message) => updates(message as StartupLogEntryMsg)) as StartupLogEntryMsg;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartupLogEntryMsg create() => StartupLogEntryMsg._();
  StartupLogEntryMsg createEmptyInstance() => create();
  static $pb.PbList<StartupLogEntryMsg> createRepeated() => $pb.PbList<StartupLogEntryMsg>();
  @$core.pragma('dart2js:noInline')
  static StartupLogEntryMsg getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartupLogEntryMsg>(create);
  static StartupLogEntryMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get timestampUnix => $_getI64(0);
  @$pb.TagNumber(1)
  set timestampUnix($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTimestampUnix() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestampUnix() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
}

class ListBinariesRequest extends $pb.GeneratedMessage {
  factory ListBinariesRequest() => create();
  ListBinariesRequest._() : super();
  factory ListBinariesRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListBinariesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBinariesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ListBinariesRequest clone() => ListBinariesRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ListBinariesRequest copyWith(void Function(ListBinariesRequest) updates) =>
      super.copyWith((message) => updates(message as ListBinariesRequest)) as ListBinariesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBinariesRequest create() => ListBinariesRequest._();
  ListBinariesRequest createEmptyInstance() => create();
  static $pb.PbList<ListBinariesRequest> createRepeated() => $pb.PbList<ListBinariesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListBinariesRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBinariesRequest>(create);
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
  factory ListBinariesResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListBinariesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBinariesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..pc<BinaryStatusMsg>(1, _omitFieldNames ? '' : 'binaries', $pb.PbFieldType.PM, subBuilder: BinaryStatusMsg.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ListBinariesResponse clone() => ListBinariesResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ListBinariesResponse copyWith(void Function(ListBinariesResponse) updates) =>
      super.copyWith((message) => updates(message as ListBinariesResponse)) as ListBinariesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBinariesResponse create() => ListBinariesResponse._();
  ListBinariesResponse createEmptyInstance() => create();
  static $pb.PbList<ListBinariesResponse> createRepeated() => $pb.PbList<ListBinariesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListBinariesResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBinariesResponse>(create);
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
  factory GetBinaryStatusRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetBinaryStatusRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBinaryStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetBinaryStatusRequest clone() => GetBinaryStatusRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetBinaryStatusRequest copyWith(void Function(GetBinaryStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetBinaryStatusRequest)) as GetBinaryStatusRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBinaryStatusRequest create() => GetBinaryStatusRequest._();
  GetBinaryStatusRequest createEmptyInstance() => create();
  static $pb.PbList<GetBinaryStatusRequest> createRepeated() => $pb.PbList<GetBinaryStatusRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBinaryStatusRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBinaryStatusRequest>(create);
  static GetBinaryStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

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
  factory GetBinaryStatusResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetBinaryStatusResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBinaryStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOM<BinaryStatusMsg>(1, _omitFieldNames ? '' : 'status', subBuilder: BinaryStatusMsg.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetBinaryStatusResponse clone() => GetBinaryStatusResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetBinaryStatusResponse copyWith(void Function(GetBinaryStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetBinaryStatusResponse)) as GetBinaryStatusResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBinaryStatusResponse create() => GetBinaryStatusResponse._();
  GetBinaryStatusResponse createEmptyInstance() => create();
  static $pb.PbList<GetBinaryStatusResponse> createRepeated() => $pb.PbList<GetBinaryStatusResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBinaryStatusResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBinaryStatusResponse>(create);
  static GetBinaryStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BinaryStatusMsg get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(BinaryStatusMsg v) {
    setField(1, v);
  }

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
  factory DownloadBinaryRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DownloadBinaryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadBinaryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOB(2, _omitFieldNames ? '' : 'force')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DownloadBinaryRequest clone() => DownloadBinaryRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DownloadBinaryRequest copyWith(void Function(DownloadBinaryRequest) updates) =>
      super.copyWith((message) => updates(message as DownloadBinaryRequest)) as DownloadBinaryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadBinaryRequest create() => DownloadBinaryRequest._();
  DownloadBinaryRequest createEmptyInstance() => create();
  static $pb.PbList<DownloadBinaryRequest> createRepeated() => $pb.PbList<DownloadBinaryRequest>();
  @$core.pragma('dart2js:noInline')
  static DownloadBinaryRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadBinaryRequest>(create);
  static DownloadBinaryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get force => $_getBF(1);
  @$pb.TagNumber(2)
  set force($core.bool v) {
    $_setBool(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasForce() => $_has(1);
  @$pb.TagNumber(2)
  void clearForce() => clearField(2);
}

class DownloadBinaryResponse extends $pb.GeneratedMessage {
  factory DownloadBinaryResponse() => create();
  DownloadBinaryResponse._() : super();
  factory DownloadBinaryResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DownloadBinaryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadBinaryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DownloadBinaryResponse clone() => DownloadBinaryResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DownloadBinaryResponse copyWith(void Function(DownloadBinaryResponse) updates) =>
      super.copyWith((message) => updates(message as DownloadBinaryResponse)) as DownloadBinaryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadBinaryResponse create() => DownloadBinaryResponse._();
  DownloadBinaryResponse createEmptyInstance() => create();
  static $pb.PbList<DownloadBinaryResponse> createRepeated() => $pb.PbList<DownloadBinaryResponse>();
  @$core.pragma('dart2js:noInline')
  static DownloadBinaryResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadBinaryResponse>(create);
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
  factory StartBinaryRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory StartBinaryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartBinaryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..pPS(2, _omitFieldNames ? '' : 'extraArgs')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'env',
        entryClassName: 'StartBinaryRequest.EnvEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('orchestrator.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  StartBinaryRequest clone() => StartBinaryRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  StartBinaryRequest copyWith(void Function(StartBinaryRequest) updates) =>
      super.copyWith((message) => updates(message as StartBinaryRequest)) as StartBinaryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartBinaryRequest create() => StartBinaryRequest._();
  StartBinaryRequest createEmptyInstance() => create();
  static $pb.PbList<StartBinaryRequest> createRepeated() => $pb.PbList<StartBinaryRequest>();
  @$core.pragma('dart2js:noInline')
  static StartBinaryRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartBinaryRequest>(create);
  static StartBinaryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

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
  factory StartBinaryResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory StartBinaryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartBinaryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'pid', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  StartBinaryResponse clone() => StartBinaryResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  StartBinaryResponse copyWith(void Function(StartBinaryResponse) updates) =>
      super.copyWith((message) => updates(message as StartBinaryResponse)) as StartBinaryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartBinaryResponse create() => StartBinaryResponse._();
  StartBinaryResponse createEmptyInstance() => create();
  static $pb.PbList<StartBinaryResponse> createRepeated() => $pb.PbList<StartBinaryResponse>();
  @$core.pragma('dart2js:noInline')
  static StartBinaryResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartBinaryResponse>(create);
  static StartBinaryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pid => $_getIZ(0);
  @$pb.TagNumber(1)
  set pid($core.int v) {
    $_setSignedInt32(0, v);
  }

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
  factory StopBinaryRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory StopBinaryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopBinaryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOB(2, _omitFieldNames ? '' : 'force')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  StopBinaryRequest clone() => StopBinaryRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  StopBinaryRequest copyWith(void Function(StopBinaryRequest) updates) =>
      super.copyWith((message) => updates(message as StopBinaryRequest)) as StopBinaryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopBinaryRequest create() => StopBinaryRequest._();
  StopBinaryRequest createEmptyInstance() => create();
  static $pb.PbList<StopBinaryRequest> createRepeated() => $pb.PbList<StopBinaryRequest>();
  @$core.pragma('dart2js:noInline')
  static StopBinaryRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopBinaryRequest>(create);
  static StopBinaryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get force => $_getBF(1);
  @$pb.TagNumber(2)
  set force($core.bool v) {
    $_setBool(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasForce() => $_has(1);
  @$pb.TagNumber(2)
  void clearForce() => clearField(2);
}

class StopBinaryResponse extends $pb.GeneratedMessage {
  factory StopBinaryResponse() => create();
  StopBinaryResponse._() : super();
  factory StopBinaryResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory StopBinaryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopBinaryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  StopBinaryResponse clone() => StopBinaryResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  StopBinaryResponse copyWith(void Function(StopBinaryResponse) updates) =>
      super.copyWith((message) => updates(message as StopBinaryResponse)) as StopBinaryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopBinaryResponse create() => StopBinaryResponse._();
  StopBinaryResponse createEmptyInstance() => create();
  static $pb.PbList<StopBinaryResponse> createRepeated() => $pb.PbList<StopBinaryResponse>();
  @$core.pragma('dart2js:noInline')
  static StopBinaryResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopBinaryResponse>(create);
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
  factory StreamLogsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory StreamLogsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StreamLogsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'tail', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  StreamLogsRequest clone() => StreamLogsRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  StreamLogsRequest copyWith(void Function(StreamLogsRequest) updates) =>
      super.copyWith((message) => updates(message as StreamLogsRequest)) as StreamLogsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamLogsRequest create() => StreamLogsRequest._();
  StreamLogsRequest createEmptyInstance() => create();
  static $pb.PbList<StreamLogsRequest> createRepeated() => $pb.PbList<StreamLogsRequest>();
  @$core.pragma('dart2js:noInline')
  static StreamLogsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StreamLogsRequest>(create);
  static StreamLogsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get tail => $_getIZ(1);
  @$pb.TagNumber(2)
  set tail($core.int v) {
    $_setSignedInt32(1, v);
  }

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
  factory StreamLogsResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory StreamLogsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StreamLogsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'stream')
    ..aOS(2, _omitFieldNames ? '' : 'line')
    ..aInt64(3, _omitFieldNames ? '' : 'timestampUnix')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  StreamLogsResponse clone() => StreamLogsResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  StreamLogsResponse copyWith(void Function(StreamLogsResponse) updates) =>
      super.copyWith((message) => updates(message as StreamLogsResponse)) as StreamLogsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamLogsResponse create() => StreamLogsResponse._();
  StreamLogsResponse createEmptyInstance() => create();
  static $pb.PbList<StreamLogsResponse> createRepeated() => $pb.PbList<StreamLogsResponse>();
  @$core.pragma('dart2js:noInline')
  static StreamLogsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StreamLogsResponse>(create);
  static StreamLogsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get stream => $_getSZ(0);
  @$pb.TagNumber(1)
  set stream($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasStream() => $_has(0);
  @$pb.TagNumber(1)
  void clearStream() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get line => $_getSZ(1);
  @$pb.TagNumber(2)
  set line($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasLine() => $_has(1);
  @$pb.TagNumber(2)
  void clearLine() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestampUnix => $_getI64(2);
  @$pb.TagNumber(3)
  set timestampUnix($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

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
    return $result;
  }
  StartWithL1Request._() : super();
  factory StartWithL1Request.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory StartWithL1Request.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartWithL1Request',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'target')
    ..pPS(2, _omitFieldNames ? '' : 'targetArgs')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'targetEnv',
        entryClassName: 'StartWithL1Request.TargetEnvEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('orchestrator.v1'))
    ..pPS(4, _omitFieldNames ? '' : 'coreArgs')
    ..pPS(5, _omitFieldNames ? '' : 'enforcerArgs')
    ..aOB(6, _omitFieldNames ? '' : 'immediate')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  StartWithL1Request clone() => StartWithL1Request()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  StartWithL1Request copyWith(void Function(StartWithL1Request) updates) =>
      super.copyWith((message) => updates(message as StartWithL1Request)) as StartWithL1Request;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartWithL1Request create() => StartWithL1Request._();
  StartWithL1Request createEmptyInstance() => create();
  static $pb.PbList<StartWithL1Request> createRepeated() => $pb.PbList<StartWithL1Request>();
  @$core.pragma('dart2js:noInline')
  static StartWithL1Request getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartWithL1Request>(create);
  static StartWithL1Request? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get target => $_getSZ(0);
  @$pb.TagNumber(1)
  set target($core.String v) {
    $_setString(0, v);
  }

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
  set immediate($core.bool v) {
    $_setBool(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasImmediate() => $_has(5);
  @$pb.TagNumber(6)
  void clearImmediate() => clearField(6);
}

class StartWithL1Response extends $pb.GeneratedMessage {
  factory StartWithL1Response() => create();
  StartWithL1Response._() : super();
  factory StartWithL1Response.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory StartWithL1Response.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartWithL1Response',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  StartWithL1Response clone() => StartWithL1Response()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  StartWithL1Response copyWith(void Function(StartWithL1Response) updates) =>
      super.copyWith((message) => updates(message as StartWithL1Response)) as StartWithL1Response;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartWithL1Response create() => StartWithL1Response._();
  StartWithL1Response createEmptyInstance() => create();
  static $pb.PbList<StartWithL1Response> createRepeated() => $pb.PbList<StartWithL1Response>();
  @$core.pragma('dart2js:noInline')
  static StartWithL1Response getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartWithL1Response>(create);
  static StartWithL1Response? _defaultInstance;
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
  factory ShutdownAllRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ShutdownAllRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ShutdownAllRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'force')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ShutdownAllRequest clone() => ShutdownAllRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ShutdownAllRequest copyWith(void Function(ShutdownAllRequest) updates) =>
      super.copyWith((message) => updates(message as ShutdownAllRequest)) as ShutdownAllRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ShutdownAllRequest create() => ShutdownAllRequest._();
  ShutdownAllRequest createEmptyInstance() => create();
  static $pb.PbList<ShutdownAllRequest> createRepeated() => $pb.PbList<ShutdownAllRequest>();
  @$core.pragma('dart2js:noInline')
  static ShutdownAllRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShutdownAllRequest>(create);
  static ShutdownAllRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get force => $_getBF(0);
  @$pb.TagNumber(1)
  set force($core.bool v) {
    $_setBool(0, v);
  }

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
  factory ShutdownAllResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ShutdownAllResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ShutdownAllResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'totalCount', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'completedCount', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'currentBinary')
    ..aOB(4, _omitFieldNames ? '' : 'done')
    ..aOS(5, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ShutdownAllResponse clone() => ShutdownAllResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ShutdownAllResponse copyWith(void Function(ShutdownAllResponse) updates) =>
      super.copyWith((message) => updates(message as ShutdownAllResponse)) as ShutdownAllResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ShutdownAllResponse create() => ShutdownAllResponse._();
  ShutdownAllResponse createEmptyInstance() => create();
  static $pb.PbList<ShutdownAllResponse> createRepeated() => $pb.PbList<ShutdownAllResponse>();
  @$core.pragma('dart2js:noInline')
  static ShutdownAllResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShutdownAllResponse>(create);
  static ShutdownAllResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get totalCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set totalCount($core.int v) {
    $_setSignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTotalCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalCount() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get completedCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set completedCount($core.int v) {
    $_setSignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasCompletedCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCompletedCount() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get currentBinary => $_getSZ(2);
  @$pb.TagNumber(3)
  set currentBinary($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasCurrentBinary() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrentBinary() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get done => $_getBF(3);
  @$pb.TagNumber(4)
  set done($core.bool v) {
    $_setBool(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasDone() => $_has(3);
  @$pb.TagNumber(4)
  void clearDone() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get error => $_getSZ(4);
  @$pb.TagNumber(5)
  set error($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasError() => $_has(4);
  @$pb.TagNumber(5)
  void clearError() => clearField(5);
}

class GetBTCPriceRequest extends $pb.GeneratedMessage {
  factory GetBTCPriceRequest() => create();
  GetBTCPriceRequest._() : super();
  factory GetBTCPriceRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetBTCPriceRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBTCPriceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetBTCPriceRequest clone() => GetBTCPriceRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetBTCPriceRequest copyWith(void Function(GetBTCPriceRequest) updates) =>
      super.copyWith((message) => updates(message as GetBTCPriceRequest)) as GetBTCPriceRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBTCPriceRequest create() => GetBTCPriceRequest._();
  GetBTCPriceRequest createEmptyInstance() => create();
  static $pb.PbList<GetBTCPriceRequest> createRepeated() => $pb.PbList<GetBTCPriceRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBTCPriceRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBTCPriceRequest>(create);
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
  factory GetBTCPriceResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetBTCPriceResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBTCPriceResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'btcusd', $pb.PbFieldType.OD)
    ..aInt64(2, _omitFieldNames ? '' : 'lastUpdatedUnix')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetBTCPriceResponse clone() => GetBTCPriceResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetBTCPriceResponse copyWith(void Function(GetBTCPriceResponse) updates) =>
      super.copyWith((message) => updates(message as GetBTCPriceResponse)) as GetBTCPriceResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBTCPriceResponse create() => GetBTCPriceResponse._();
  GetBTCPriceResponse createEmptyInstance() => create();
  static $pb.PbList<GetBTCPriceResponse> createRepeated() => $pb.PbList<GetBTCPriceResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBTCPriceResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBTCPriceResponse>(create);
  static GetBTCPriceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get btcusd => $_getN(0);
  @$pb.TagNumber(1)
  set btcusd($core.double v) {
    $_setDouble(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasBtcusd() => $_has(0);
  @$pb.TagNumber(1)
  void clearBtcusd() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get lastUpdatedUnix => $_getI64(1);
  @$pb.TagNumber(2)
  set lastUpdatedUnix($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasLastUpdatedUnix() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastUpdatedUnix() => clearField(2);
}

class GetMainchainBlockchainInfoRequest extends $pb.GeneratedMessage {
  factory GetMainchainBlockchainInfoRequest() => create();
  GetMainchainBlockchainInfoRequest._() : super();
  factory GetMainchainBlockchainInfoRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetMainchainBlockchainInfoRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMainchainBlockchainInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetMainchainBlockchainInfoRequest clone() => GetMainchainBlockchainInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetMainchainBlockchainInfoRequest copyWith(void Function(GetMainchainBlockchainInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetMainchainBlockchainInfoRequest))
          as GetMainchainBlockchainInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMainchainBlockchainInfoRequest create() => GetMainchainBlockchainInfoRequest._();
  GetMainchainBlockchainInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetMainchainBlockchainInfoRequest> createRepeated() =>
      $pb.PbList<GetMainchainBlockchainInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetMainchainBlockchainInfoRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMainchainBlockchainInfoRequest>(create);
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
  factory GetMainchainBlockchainInfoResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetMainchainBlockchainInfoResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMainchainBlockchainInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
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
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetMainchainBlockchainInfoResponse clone() => GetMainchainBlockchainInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetMainchainBlockchainInfoResponse copyWith(void Function(GetMainchainBlockchainInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetMainchainBlockchainInfoResponse))
          as GetMainchainBlockchainInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMainchainBlockchainInfoResponse create() => GetMainchainBlockchainInfoResponse._();
  GetMainchainBlockchainInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetMainchainBlockchainInfoResponse> createRepeated() =>
      $pb.PbList<GetMainchainBlockchainInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetMainchainBlockchainInfoResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMainchainBlockchainInfoResponse>(create);
  static GetMainchainBlockchainInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get blocks => $_getIZ(1);
  @$pb.TagNumber(2)
  set blocks($core.int v) {
    $_setSignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasBlocks() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlocks() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get headers => $_getIZ(2);
  @$pb.TagNumber(3)
  set headers($core.int v) {
    $_setSignedInt32(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasHeaders() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeaders() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get bestBlockHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set bestBlockHash($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasBestBlockHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearBestBlockHash() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get difficulty => $_getN(4);
  @$pb.TagNumber(5)
  set difficulty($core.double v) {
    $_setDouble(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasDifficulty() => $_has(4);
  @$pb.TagNumber(5)
  void clearDifficulty() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get time => $_getI64(5);
  @$pb.TagNumber(6)
  set time($fixnum.Int64 v) {
    $_setInt64(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearTime() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get medianTime => $_getI64(6);
  @$pb.TagNumber(7)
  set medianTime($fixnum.Int64 v) {
    $_setInt64(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasMedianTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearMedianTime() => clearField(7);

  @$pb.TagNumber(8)
  $core.double get verificationProgress => $_getN(7);
  @$pb.TagNumber(8)
  set verificationProgress($core.double v) {
    $_setDouble(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasVerificationProgress() => $_has(7);
  @$pb.TagNumber(8)
  void clearVerificationProgress() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get initialBlockDownload => $_getBF(8);
  @$pb.TagNumber(9)
  set initialBlockDownload($core.bool v) {
    $_setBool(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasInitialBlockDownload() => $_has(8);
  @$pb.TagNumber(9)
  void clearInitialBlockDownload() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get chainWork => $_getSZ(9);
  @$pb.TagNumber(10)
  set chainWork($core.String v) {
    $_setString(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasChainWork() => $_has(9);
  @$pb.TagNumber(10)
  void clearChainWork() => clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get sizeOnDisk => $_getI64(10);
  @$pb.TagNumber(11)
  set sizeOnDisk($fixnum.Int64 v) {
    $_setInt64(10, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasSizeOnDisk() => $_has(10);
  @$pb.TagNumber(11)
  void clearSizeOnDisk() => clearField(11);

  @$pb.TagNumber(12)
  $core.bool get pruned => $_getBF(11);
  @$pb.TagNumber(12)
  set pruned($core.bool v) {
    $_setBool(11, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasPruned() => $_has(11);
  @$pb.TagNumber(12)
  void clearPruned() => clearField(12);
}

class GetEnforcerBlockchainInfoRequest extends $pb.GeneratedMessage {
  factory GetEnforcerBlockchainInfoRequest() => create();
  GetEnforcerBlockchainInfoRequest._() : super();
  factory GetEnforcerBlockchainInfoRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetEnforcerBlockchainInfoRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetEnforcerBlockchainInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetEnforcerBlockchainInfoRequest clone() => GetEnforcerBlockchainInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetEnforcerBlockchainInfoRequest copyWith(void Function(GetEnforcerBlockchainInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetEnforcerBlockchainInfoRequest))
          as GetEnforcerBlockchainInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetEnforcerBlockchainInfoRequest create() => GetEnforcerBlockchainInfoRequest._();
  GetEnforcerBlockchainInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetEnforcerBlockchainInfoRequest> createRepeated() =>
      $pb.PbList<GetEnforcerBlockchainInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetEnforcerBlockchainInfoRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetEnforcerBlockchainInfoRequest>(create);
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
  factory GetEnforcerBlockchainInfoResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetEnforcerBlockchainInfoResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetEnforcerBlockchainInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'blocks', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'headers', $pb.PbFieldType.O3)
    ..aInt64(3, _omitFieldNames ? '' : 'time')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetEnforcerBlockchainInfoResponse clone() => GetEnforcerBlockchainInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetEnforcerBlockchainInfoResponse copyWith(void Function(GetEnforcerBlockchainInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetEnforcerBlockchainInfoResponse))
          as GetEnforcerBlockchainInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetEnforcerBlockchainInfoResponse create() => GetEnforcerBlockchainInfoResponse._();
  GetEnforcerBlockchainInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetEnforcerBlockchainInfoResponse> createRepeated() =>
      $pb.PbList<GetEnforcerBlockchainInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetEnforcerBlockchainInfoResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetEnforcerBlockchainInfoResponse>(create);
  static GetEnforcerBlockchainInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get blocks => $_getIZ(0);
  @$pb.TagNumber(1)
  set blocks($core.int v) {
    $_setSignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasBlocks() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlocks() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get headers => $_getIZ(1);
  @$pb.TagNumber(2)
  set headers($core.int v) {
    $_setSignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasHeaders() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeaders() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get time => $_getI64(2);
  @$pb.TagNumber(3)
  set time($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearTime() => clearField(3);
}

class GetSyncStatusRequest extends $pb.GeneratedMessage {
  factory GetSyncStatusRequest() => create();
  GetSyncStatusRequest._() : super();
  factory GetSyncStatusRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetSyncStatusRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSyncStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetSyncStatusRequest clone() => GetSyncStatusRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetSyncStatusRequest copyWith(void Function(GetSyncStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetSyncStatusRequest)) as GetSyncStatusRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSyncStatusRequest create() => GetSyncStatusRequest._();
  GetSyncStatusRequest createEmptyInstance() => create();
  static $pb.PbList<GetSyncStatusRequest> createRepeated() => $pb.PbList<GetSyncStatusRequest>();
  @$core.pragma('dart2js:noInline')
  static GetSyncStatusRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSyncStatusRequest>(create);
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
  factory GetSyncStatusResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetSyncStatusResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSyncStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOM<ChainSync>(1, _omitFieldNames ? '' : 'mainchain', subBuilder: ChainSync.create)
    ..aOM<ChainSync>(2, _omitFieldNames ? '' : 'enforcer', subBuilder: ChainSync.create)
    ..pc<SidechainStatus>(3, _omitFieldNames ? '' : 'sidechains', $pb.PbFieldType.PM,
        subBuilder: SidechainStatus.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetSyncStatusResponse clone() => GetSyncStatusResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetSyncStatusResponse copyWith(void Function(GetSyncStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetSyncStatusResponse)) as GetSyncStatusResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSyncStatusResponse create() => GetSyncStatusResponse._();
  GetSyncStatusResponse createEmptyInstance() => create();
  static $pb.PbList<GetSyncStatusResponse> createRepeated() => $pb.PbList<GetSyncStatusResponse>();
  @$core.pragma('dart2js:noInline')
  static GetSyncStatusResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSyncStatusResponse>(create);
  static GetSyncStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ChainSync get mainchain => $_getN(0);
  @$pb.TagNumber(1)
  set mainchain(ChainSync v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasMainchain() => $_has(0);
  @$pb.TagNumber(1)
  void clearMainchain() => clearField(1);
  @$pb.TagNumber(1)
  ChainSync ensureMainchain() => $_ensure(0);

  @$pb.TagNumber(2)
  ChainSync get enforcer => $_getN(1);
  @$pb.TagNumber(2)
  set enforcer(ChainSync v) {
    setField(2, v);
  }

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
  factory SidechainStatus.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SidechainStatus.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SidechainStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..e<SidechainType>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: SidechainType.SIDECHAIN_TYPE_UNSPECIFIED,
        valueOf: SidechainType.valueOf,
        enumValues: SidechainType.values)
    ..aOM<ChainSync>(2, _omitFieldNames ? '' : 'sync', subBuilder: ChainSync.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SidechainStatus clone() => SidechainStatus()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SidechainStatus copyWith(void Function(SidechainStatus) updates) =>
      super.copyWith((message) => updates(message as SidechainStatus)) as SidechainStatus;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SidechainStatus create() => SidechainStatus._();
  SidechainStatus createEmptyInstance() => create();
  static $pb.PbList<SidechainStatus> createRepeated() => $pb.PbList<SidechainStatus>();
  @$core.pragma('dart2js:noInline')
  static SidechainStatus getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SidechainStatus>(create);
  static SidechainStatus? _defaultInstance;

  @$pb.TagNumber(1)
  SidechainType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(SidechainType v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  ChainSync get sync => $_getN(1);
  @$pb.TagNumber(2)
  set sync(ChainSync v) {
    setField(2, v);
  }

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
    $core.bool? isDownloading,
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
    if (isDownloading != null) {
      $result.isDownloading = isDownloading;
    }
    return $result;
  }
  ChainSync._() : super();
  factory ChainSync.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ChainSync.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChainSync',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'blocks', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'headers', $pb.PbFieldType.O3)
    ..aInt64(3, _omitFieldNames ? '' : 'time')
    ..aOS(4, _omitFieldNames ? '' : 'error')
    ..aOB(5, _omitFieldNames ? '' : 'isDownloading')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ChainSync clone() => ChainSync()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ChainSync copyWith(void Function(ChainSync) updates) =>
      super.copyWith((message) => updates(message as ChainSync)) as ChainSync;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChainSync create() => ChainSync._();
  ChainSync createEmptyInstance() => create();
  static $pb.PbList<ChainSync> createRepeated() => $pb.PbList<ChainSync>();
  @$core.pragma('dart2js:noInline')
  static ChainSync getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChainSync>(create);
  static ChainSync? _defaultInstance;

  /// While is_downloading=true: blocks = MB downloaded, headers = MB total.
  /// Otherwise: blocks = current tip height, headers = bitcoind's header
  /// count (or this daemon's own headers if mainchain is unavailable).
  @$pb.TagNumber(1)
  $core.int get blocks => $_getIZ(0);
  @$pb.TagNumber(1)
  set blocks($core.int v) {
    $_setSignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasBlocks() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlocks() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get headers => $_getIZ(1);
  @$pb.TagNumber(2)
  set headers($core.int v) {
    $_setSignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasHeaders() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeaders() => clearField(2);

  /// Block tip timestamp (unix seconds), 0 if no tip yet.
  @$pb.TagNumber(3)
  $fixnum.Int64 get time => $_getI64(2);
  @$pb.TagNumber(3)
  set time($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearTime() => clearField(3);

  /// Empty on success; otherwise a short description of why this daemon's
  /// sync info isn't available (not running, RPC error, etc.).
  @$pb.TagNumber(4)
  $core.String get error => $_getSZ(3);
  @$pb.TagNumber(4)
  set error($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => clearField(4);

  /// When true, the orchestrator is currently downloading the binary for
  /// this slot — blocks/headers carry MB downloaded / MB total instead of
  /// chain heights. The UI uses this to format "X MB" vs "N blocks".
  @$pb.TagNumber(5)
  $core.bool get isDownloading => $_getBF(4);
  @$pb.TagNumber(5)
  set isDownloading($core.bool v) {
    $_setBool(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasIsDownloading() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsDownloading() => clearField(5);
}

class GetMainchainBalanceRequest extends $pb.GeneratedMessage {
  factory GetMainchainBalanceRequest() => create();
  GetMainchainBalanceRequest._() : super();
  factory GetMainchainBalanceRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetMainchainBalanceRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMainchainBalanceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetMainchainBalanceRequest clone() => GetMainchainBalanceRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetMainchainBalanceRequest copyWith(void Function(GetMainchainBalanceRequest) updates) =>
      super.copyWith((message) => updates(message as GetMainchainBalanceRequest)) as GetMainchainBalanceRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMainchainBalanceRequest create() => GetMainchainBalanceRequest._();
  GetMainchainBalanceRequest createEmptyInstance() => create();
  static $pb.PbList<GetMainchainBalanceRequest> createRepeated() => $pb.PbList<GetMainchainBalanceRequest>();
  @$core.pragma('dart2js:noInline')
  static GetMainchainBalanceRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMainchainBalanceRequest>(create);
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
  factory GetMainchainBalanceResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetMainchainBalanceResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMainchainBalanceResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'confirmed', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'unconfirmed', $pb.PbFieldType.OD)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetMainchainBalanceResponse clone() => GetMainchainBalanceResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetMainchainBalanceResponse copyWith(void Function(GetMainchainBalanceResponse) updates) =>
      super.copyWith((message) => updates(message as GetMainchainBalanceResponse)) as GetMainchainBalanceResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMainchainBalanceResponse create() => GetMainchainBalanceResponse._();
  GetMainchainBalanceResponse createEmptyInstance() => create();
  static $pb.PbList<GetMainchainBalanceResponse> createRepeated() => $pb.PbList<GetMainchainBalanceResponse>();
  @$core.pragma('dart2js:noInline')
  static GetMainchainBalanceResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMainchainBalanceResponse>(create);
  static GetMainchainBalanceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get confirmed => $_getN(0);
  @$pb.TagNumber(1)
  set confirmed($core.double v) {
    $_setDouble(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasConfirmed() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfirmed() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get unconfirmed => $_getN(1);
  @$pb.TagNumber(2)
  set unconfirmed($core.double v) {
    $_setDouble(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasUnconfirmed() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnconfirmed() => clearField(2);
}

class PreviewResetDataRequest extends $pb.GeneratedMessage {
  factory PreviewResetDataRequest({
    $core.bool? deleteBlockchainData,
    $core.bool? deleteNodeSoftware,
    $core.bool? deleteLogs,
    $core.bool? deleteSettings,
    $core.bool? deleteWalletFiles,
    $core.bool? alsoResetSidechains,
  }) {
    final $result = create();
    if (deleteBlockchainData != null) {
      $result.deleteBlockchainData = deleteBlockchainData;
    }
    if (deleteNodeSoftware != null) {
      $result.deleteNodeSoftware = deleteNodeSoftware;
    }
    if (deleteLogs != null) {
      $result.deleteLogs = deleteLogs;
    }
    if (deleteSettings != null) {
      $result.deleteSettings = deleteSettings;
    }
    if (deleteWalletFiles != null) {
      $result.deleteWalletFiles = deleteWalletFiles;
    }
    if (alsoResetSidechains != null) {
      $result.alsoResetSidechains = alsoResetSidechains;
    }
    return $result;
  }
  PreviewResetDataRequest._() : super();
  factory PreviewResetDataRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory PreviewResetDataRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PreviewResetDataRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'deleteBlockchainData')
    ..aOB(2, _omitFieldNames ? '' : 'deleteNodeSoftware')
    ..aOB(3, _omitFieldNames ? '' : 'deleteLogs')
    ..aOB(4, _omitFieldNames ? '' : 'deleteSettings')
    ..aOB(5, _omitFieldNames ? '' : 'deleteWalletFiles')
    ..aOB(6, _omitFieldNames ? '' : 'alsoResetSidechains')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  PreviewResetDataRequest clone() => PreviewResetDataRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  PreviewResetDataRequest copyWith(void Function(PreviewResetDataRequest) updates) =>
      super.copyWith((message) => updates(message as PreviewResetDataRequest)) as PreviewResetDataRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PreviewResetDataRequest create() => PreviewResetDataRequest._();
  PreviewResetDataRequest createEmptyInstance() => create();
  static $pb.PbList<PreviewResetDataRequest> createRepeated() => $pb.PbList<PreviewResetDataRequest>();
  @$core.pragma('dart2js:noInline')
  static PreviewResetDataRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PreviewResetDataRequest>(create);
  static PreviewResetDataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get deleteBlockchainData => $_getBF(0);
  @$pb.TagNumber(1)
  set deleteBlockchainData($core.bool v) {
    $_setBool(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasDeleteBlockchainData() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeleteBlockchainData() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get deleteNodeSoftware => $_getBF(1);
  @$pb.TagNumber(2)
  set deleteNodeSoftware($core.bool v) {
    $_setBool(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasDeleteNodeSoftware() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeleteNodeSoftware() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get deleteLogs => $_getBF(2);
  @$pb.TagNumber(3)
  set deleteLogs($core.bool v) {
    $_setBool(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasDeleteLogs() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeleteLogs() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get deleteSettings => $_getBF(3);
  @$pb.TagNumber(4)
  set deleteSettings($core.bool v) {
    $_setBool(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasDeleteSettings() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeleteSettings() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get deleteWalletFiles => $_getBF(4);
  @$pb.TagNumber(5)
  set deleteWalletFiles($core.bool v) {
    $_setBool(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasDeleteWalletFiles() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeleteWalletFiles() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get alsoResetSidechains => $_getBF(5);
  @$pb.TagNumber(6)
  set alsoResetSidechains($core.bool v) {
    $_setBool(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasAlsoResetSidechains() => $_has(5);
  @$pb.TagNumber(6)
  void clearAlsoResetSidechains() => clearField(6);
}

class PreviewResetDataResponse extends $pb.GeneratedMessage {
  factory PreviewResetDataResponse({
    $core.Iterable<ResetFileInfo>? files,
  }) {
    final $result = create();
    if (files != null) {
      $result.files.addAll(files);
    }
    return $result;
  }
  PreviewResetDataResponse._() : super();
  factory PreviewResetDataResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory PreviewResetDataResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PreviewResetDataResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..pc<ResetFileInfo>(1, _omitFieldNames ? '' : 'files', $pb.PbFieldType.PM, subBuilder: ResetFileInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  PreviewResetDataResponse clone() => PreviewResetDataResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  PreviewResetDataResponse copyWith(void Function(PreviewResetDataResponse) updates) =>
      super.copyWith((message) => updates(message as PreviewResetDataResponse)) as PreviewResetDataResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PreviewResetDataResponse create() => PreviewResetDataResponse._();
  PreviewResetDataResponse createEmptyInstance() => create();
  static $pb.PbList<PreviewResetDataResponse> createRepeated() => $pb.PbList<PreviewResetDataResponse>();
  @$core.pragma('dart2js:noInline')
  static PreviewResetDataResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PreviewResetDataResponse>(create);
  static PreviewResetDataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ResetFileInfo> get files => $_getList(0);
}

class ResetFileInfo extends $pb.GeneratedMessage {
  factory ResetFileInfo({
    $core.String? path,
    $core.String? category,
    $fixnum.Int64? sizeBytes,
    $core.bool? isDirectory,
  }) {
    final $result = create();
    if (path != null) {
      $result.path = path;
    }
    if (category != null) {
      $result.category = category;
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
  factory ResetFileInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ResetFileInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResetFileInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..aOS(2, _omitFieldNames ? '' : 'category')
    ..aInt64(3, _omitFieldNames ? '' : 'sizeBytes')
    ..aOB(4, _omitFieldNames ? '' : 'isDirectory')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ResetFileInfo clone() => ResetFileInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ResetFileInfo copyWith(void Function(ResetFileInfo) updates) =>
      super.copyWith((message) => updates(message as ResetFileInfo)) as ResetFileInfo;

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
  set path($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get category => $_getSZ(1);
  @$pb.TagNumber(2)
  set category($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasCategory() => $_has(1);
  @$pb.TagNumber(2)
  void clearCategory() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sizeBytes => $_getI64(2);
  @$pb.TagNumber(3)
  set sizeBytes($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasSizeBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearSizeBytes() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isDirectory => $_getBF(3);
  @$pb.TagNumber(4)
  set isDirectory($core.bool v) {
    $_setBool(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasIsDirectory() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsDirectory() => clearField(4);
}

class StreamResetDataRequest extends $pb.GeneratedMessage {
  factory StreamResetDataRequest({
    $core.bool? deleteBlockchainData,
    $core.bool? deleteNodeSoftware,
    $core.bool? deleteLogs,
    $core.bool? deleteSettings,
    $core.bool? deleteWalletFiles,
    $core.bool? alsoResetSidechains,
  }) {
    final $result = create();
    if (deleteBlockchainData != null) {
      $result.deleteBlockchainData = deleteBlockchainData;
    }
    if (deleteNodeSoftware != null) {
      $result.deleteNodeSoftware = deleteNodeSoftware;
    }
    if (deleteLogs != null) {
      $result.deleteLogs = deleteLogs;
    }
    if (deleteSettings != null) {
      $result.deleteSettings = deleteSettings;
    }
    if (deleteWalletFiles != null) {
      $result.deleteWalletFiles = deleteWalletFiles;
    }
    if (alsoResetSidechains != null) {
      $result.alsoResetSidechains = alsoResetSidechains;
    }
    return $result;
  }
  StreamResetDataRequest._() : super();
  factory StreamResetDataRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory StreamResetDataRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StreamResetDataRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'deleteBlockchainData')
    ..aOB(2, _omitFieldNames ? '' : 'deleteNodeSoftware')
    ..aOB(3, _omitFieldNames ? '' : 'deleteLogs')
    ..aOB(4, _omitFieldNames ? '' : 'deleteSettings')
    ..aOB(5, _omitFieldNames ? '' : 'deleteWalletFiles')
    ..aOB(6, _omitFieldNames ? '' : 'alsoResetSidechains')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  StreamResetDataRequest clone() => StreamResetDataRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  StreamResetDataRequest copyWith(void Function(StreamResetDataRequest) updates) =>
      super.copyWith((message) => updates(message as StreamResetDataRequest)) as StreamResetDataRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamResetDataRequest create() => StreamResetDataRequest._();
  StreamResetDataRequest createEmptyInstance() => create();
  static $pb.PbList<StreamResetDataRequest> createRepeated() => $pb.PbList<StreamResetDataRequest>();
  @$core.pragma('dart2js:noInline')
  static StreamResetDataRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StreamResetDataRequest>(create);
  static StreamResetDataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get deleteBlockchainData => $_getBF(0);
  @$pb.TagNumber(1)
  set deleteBlockchainData($core.bool v) {
    $_setBool(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasDeleteBlockchainData() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeleteBlockchainData() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get deleteNodeSoftware => $_getBF(1);
  @$pb.TagNumber(2)
  set deleteNodeSoftware($core.bool v) {
    $_setBool(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasDeleteNodeSoftware() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeleteNodeSoftware() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get deleteLogs => $_getBF(2);
  @$pb.TagNumber(3)
  set deleteLogs($core.bool v) {
    $_setBool(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasDeleteLogs() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeleteLogs() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get deleteSettings => $_getBF(3);
  @$pb.TagNumber(4)
  set deleteSettings($core.bool v) {
    $_setBool(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasDeleteSettings() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeleteSettings() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get deleteWalletFiles => $_getBF(4);
  @$pb.TagNumber(5)
  set deleteWalletFiles($core.bool v) {
    $_setBool(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasDeleteWalletFiles() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeleteWalletFiles() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get alsoResetSidechains => $_getBF(5);
  @$pb.TagNumber(6)
  set alsoResetSidechains($core.bool v) {
    $_setBool(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasAlsoResetSidechains() => $_has(5);
  @$pb.TagNumber(6)
  void clearAlsoResetSidechains() => clearField(6);
}

class StreamResetDataResponse extends $pb.GeneratedMessage {
  factory StreamResetDataResponse({
    $core.String? path,
    $core.String? category,
    $core.bool? success,
    $core.String? error,
    $core.bool? done,
    $core.int? deletedCount,
    $core.int? failedCount,
  }) {
    final $result = create();
    if (path != null) {
      $result.path = path;
    }
    if (category != null) {
      $result.category = category;
    }
    if (success != null) {
      $result.success = success;
    }
    if (error != null) {
      $result.error = error;
    }
    if (done != null) {
      $result.done = done;
    }
    if (deletedCount != null) {
      $result.deletedCount = deletedCount;
    }
    if (failedCount != null) {
      $result.failedCount = failedCount;
    }
    return $result;
  }
  StreamResetDataResponse._() : super();
  factory StreamResetDataResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory StreamResetDataResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StreamResetDataResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..aOS(2, _omitFieldNames ? '' : 'category')
    ..aOB(3, _omitFieldNames ? '' : 'success')
    ..aOS(4, _omitFieldNames ? '' : 'error')
    ..aOB(5, _omitFieldNames ? '' : 'done')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'deletedCount', $pb.PbFieldType.O3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'failedCount', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  StreamResetDataResponse clone() => StreamResetDataResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  StreamResetDataResponse copyWith(void Function(StreamResetDataResponse) updates) =>
      super.copyWith((message) => updates(message as StreamResetDataResponse)) as StreamResetDataResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamResetDataResponse create() => StreamResetDataResponse._();
  StreamResetDataResponse createEmptyInstance() => create();
  static $pb.PbList<StreamResetDataResponse> createRepeated() => $pb.PbList<StreamResetDataResponse>();
  @$core.pragma('dart2js:noInline')
  static StreamResetDataResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StreamResetDataResponse>(create);
  static StreamResetDataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get category => $_getSZ(1);
  @$pb.TagNumber(2)
  set category($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasCategory() => $_has(1);
  @$pb.TagNumber(2)
  void clearCategory() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get success => $_getBF(2);
  @$pb.TagNumber(3)
  set success($core.bool v) {
    $_setBool(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasSuccess() => $_has(2);
  @$pb.TagNumber(3)
  void clearSuccess() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get error => $_getSZ(3);
  @$pb.TagNumber(4)
  set error($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get done => $_getBF(4);
  @$pb.TagNumber(5)
  set done($core.bool v) {
    $_setBool(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasDone() => $_has(4);
  @$pb.TagNumber(5)
  void clearDone() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get deletedCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set deletedCount($core.int v) {
    $_setSignedInt32(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasDeletedCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearDeletedCount() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get failedCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set failedCount($core.int v) {
    $_setSignedInt32(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasFailedCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearFailedCount() => clearField(7);
}

class GetCoreMempoolInfoRequest extends $pb.GeneratedMessage {
  factory GetCoreMempoolInfoRequest() => create();
  GetCoreMempoolInfoRequest._() : super();
  factory GetCoreMempoolInfoRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetCoreMempoolInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoreMempoolInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetCoreMempoolInfoRequest clone() => GetCoreMempoolInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetCoreMempoolInfoRequest copyWith(void Function(GetCoreMempoolInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetCoreMempoolInfoRequest)) as GetCoreMempoolInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCoreMempoolInfoRequest create() => GetCoreMempoolInfoRequest._();
  GetCoreMempoolInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetCoreMempoolInfoRequest> createRepeated() => $pb.PbList<GetCoreMempoolInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetCoreMempoolInfoRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoreMempoolInfoRequest>(create);
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
  factory GetCoreMempoolInfoResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetCoreMempoolInfoResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoreMempoolInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
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
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetCoreMempoolInfoResponse clone() => GetCoreMempoolInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetCoreMempoolInfoResponse copyWith(void Function(GetCoreMempoolInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetCoreMempoolInfoResponse)) as GetCoreMempoolInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCoreMempoolInfoResponse create() => GetCoreMempoolInfoResponse._();
  GetCoreMempoolInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetCoreMempoolInfoResponse> createRepeated() => $pb.PbList<GetCoreMempoolInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetCoreMempoolInfoResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoreMempoolInfoResponse>(create);
  static GetCoreMempoolInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get loaded => $_getBF(0);
  @$pb.TagNumber(1)
  set loaded($core.bool v) {
    $_setBool(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasLoaded() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoaded() => clearField(1);

  /// Number of transactions in the mempool.
  @$pb.TagNumber(2)
  $fixnum.Int64 get size => $_getI64(1);
  @$pb.TagNumber(2)
  set size($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearSize() => clearField(2);

  /// Sum of serialized sizes (bytes).
  @$pb.TagNumber(3)
  $fixnum.Int64 get bytes => $_getI64(2);
  @$pb.TagNumber(3)
  set bytes($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearBytes() => clearField(3);

  /// Total memory usage (bytes).
  @$pb.TagNumber(4)
  $fixnum.Int64 get usage => $_getI64(3);
  @$pb.TagNumber(4)
  set usage($fixnum.Int64 v) {
    $_setInt64(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasUsage() => $_has(3);
  @$pb.TagNumber(4)
  void clearUsage() => clearField(4);

  /// Sum of all tx fees (BTC).
  @$pb.TagNumber(5)
  $core.double get totalFee => $_getN(4);
  @$pb.TagNumber(5)
  set totalFee($core.double v) {
    $_setDouble(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasTotalFee() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalFee() => clearField(5);

  /// Mempool size cap (bytes).
  @$pb.TagNumber(6)
  $fixnum.Int64 get maxMempool => $_getI64(5);
  @$pb.TagNumber(6)
  set maxMempool($fixnum.Int64 v) {
    $_setInt64(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasMaxMempool() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxMempool() => clearField(6);

  /// Lowest fee rate accepted into mempool (BTC/kvB).
  @$pb.TagNumber(7)
  $core.double get mempoolMinFee => $_getN(6);
  @$pb.TagNumber(7)
  set mempoolMinFee($core.double v) {
    $_setDouble(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasMempoolMinFee() => $_has(6);
  @$pb.TagNumber(7)
  void clearMempoolMinFee() => clearField(7);

  /// Lowest fee rate eligible for relay (BTC/kvB).
  @$pb.TagNumber(8)
  $core.double get minRelayTxFee => $_getN(7);
  @$pb.TagNumber(8)
  set minRelayTxFee($core.double v) {
    $_setDouble(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasMinRelayTxFee() => $_has(7);
  @$pb.TagNumber(8)
  void clearMinRelayTxFee() => clearField(8);

  /// Minimum bump-fee increment (BTC/kvB).
  @$pb.TagNumber(9)
  $core.double get incrementalRelayFee => $_getN(8);
  @$pb.TagNumber(9)
  set incrementalRelayFee($core.double v) {
    $_setDouble(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasIncrementalRelayFee() => $_has(8);
  @$pb.TagNumber(9)
  void clearIncrementalRelayFee() => clearField(9);

  /// Transactions in mempool not yet broadcast.
  @$pb.TagNumber(10)
  $fixnum.Int64 get unbroadcastCount => $_getI64(9);
  @$pb.TagNumber(10)
  set unbroadcastCount($fixnum.Int64 v) {
    $_setInt64(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasUnbroadcastCount() => $_has(9);
  @$pb.TagNumber(10)
  void clearUnbroadcastCount() => clearField(10);

  @$pb.TagNumber(11)
  $core.bool get fullRbf => $_getBF(10);
  @$pb.TagNumber(11)
  set fullRbf($core.bool v) {
    $_setBool(10, v);
  }

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
  factory CoreRawCallRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory CoreRawCallRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CoreRawCallRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'method')
    ..aOS(2, _omitFieldNames ? '' : 'paramsJson')
    ..aOS(3, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  CoreRawCallRequest clone() => CoreRawCallRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  CoreRawCallRequest copyWith(void Function(CoreRawCallRequest) updates) =>
      super.copyWith((message) => updates(message as CoreRawCallRequest)) as CoreRawCallRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CoreRawCallRequest create() => CoreRawCallRequest._();
  CoreRawCallRequest createEmptyInstance() => create();
  static $pb.PbList<CoreRawCallRequest> createRepeated() => $pb.PbList<CoreRawCallRequest>();
  @$core.pragma('dart2js:noInline')
  static CoreRawCallRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CoreRawCallRequest>(create);
  static CoreRawCallRequest? _defaultInstance;

  /// bitcoind RPC method name (e.g. "finalizepsbt").
  @$pb.TagNumber(1)
  $core.String get method => $_getSZ(0);
  @$pb.TagNumber(1)
  set method($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasMethod() => $_has(0);
  @$pb.TagNumber(1)
  void clearMethod() => clearField(1);

  /// JSON-encoded positional params array (e.g. '["psbtBase64", false]').
  /// Empty string means no params.
  @$pb.TagNumber(2)
  $core.String get paramsJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set paramsJson($core.String v) {
    $_setString(1, v);
  }

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
  set wallet($core.String v) {
    $_setString(2, v);
  }

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
  factory CoreRawCallResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory CoreRawCallResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CoreRawCallResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'resultJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  CoreRawCallResponse clone() => CoreRawCallResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  CoreRawCallResponse copyWith(void Function(CoreRawCallResponse) updates) =>
      super.copyWith((message) => updates(message as CoreRawCallResponse)) as CoreRawCallResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CoreRawCallResponse create() => CoreRawCallResponse._();
  CoreRawCallResponse createEmptyInstance() => create();
  static $pb.PbList<CoreRawCallResponse> createRepeated() => $pb.PbList<CoreRawCallResponse>();
  @$core.pragma('dart2js:noInline')
  static CoreRawCallResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CoreRawCallResponse>(create);
  static CoreRawCallResponse? _defaultInstance;

  /// JSON-encoded result. Caller decodes to its expected shape.
  @$pb.TagNumber(1)
  $core.String get resultJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set resultJson($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasResultJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearResultJson() => clearField(1);
}

class OrchestratorServiceApi {
  $pb.RpcClient _client;
  OrchestratorServiceApi(this._client);

  $async.Future<ListBinariesResponse> listBinaries($pb.ClientContext? ctx, ListBinariesRequest request) =>
      _client.invoke<ListBinariesResponse>(ctx, 'OrchestratorService', 'ListBinaries', request, ListBinariesResponse());
  $async.Future<GetBinaryStatusResponse> getBinaryStatus($pb.ClientContext? ctx, GetBinaryStatusRequest request) =>
      _client.invoke<GetBinaryStatusResponse>(
          ctx, 'OrchestratorService', 'GetBinaryStatus', request, GetBinaryStatusResponse());
  $async.Future<DownloadBinaryResponse> downloadBinary($pb.ClientContext? ctx, DownloadBinaryRequest request) => _client
      .invoke<DownloadBinaryResponse>(ctx, 'OrchestratorService', 'DownloadBinary', request, DownloadBinaryResponse());
  $async.Future<StartBinaryResponse> startBinary($pb.ClientContext? ctx, StartBinaryRequest request) =>
      _client.invoke<StartBinaryResponse>(ctx, 'OrchestratorService', 'StartBinary', request, StartBinaryResponse());
  $async.Future<StopBinaryResponse> stopBinary($pb.ClientContext? ctx, StopBinaryRequest request) =>
      _client.invoke<StopBinaryResponse>(ctx, 'OrchestratorService', 'StopBinary', request, StopBinaryResponse());
  $async.Future<StreamLogsResponse> streamLogs($pb.ClientContext? ctx, StreamLogsRequest request) =>
      _client.invoke<StreamLogsResponse>(ctx, 'OrchestratorService', 'StreamLogs', request, StreamLogsResponse());
  $async.Future<StartWithL1Response> startWithL1($pb.ClientContext? ctx, StartWithL1Request request) =>
      _client.invoke<StartWithL1Response>(ctx, 'OrchestratorService', 'StartWithL1', request, StartWithL1Response());
  $async.Future<ShutdownAllResponse> shutdownAll($pb.ClientContext? ctx, ShutdownAllRequest request) =>
      _client.invoke<ShutdownAllResponse>(ctx, 'OrchestratorService', 'ShutdownAll', request, ShutdownAllResponse());
  $async.Future<GetBTCPriceResponse> getBTCPrice($pb.ClientContext? ctx, GetBTCPriceRequest request) =>
      _client.invoke<GetBTCPriceResponse>(ctx, 'OrchestratorService', 'GetBTCPrice', request, GetBTCPriceResponse());
  $async.Future<GetMainchainBlockchainInfoResponse> getMainchainBlockchainInfo(
          $pb.ClientContext? ctx, GetMainchainBlockchainInfoRequest request) =>
      _client.invoke<GetMainchainBlockchainInfoResponse>(
          ctx, 'OrchestratorService', 'GetMainchainBlockchainInfo', request, GetMainchainBlockchainInfoResponse());
  $async.Future<GetEnforcerBlockchainInfoResponse> getEnforcerBlockchainInfo(
          $pb.ClientContext? ctx, GetEnforcerBlockchainInfoRequest request) =>
      _client.invoke<GetEnforcerBlockchainInfoResponse>(
          ctx, 'OrchestratorService', 'GetEnforcerBlockchainInfo', request, GetEnforcerBlockchainInfoResponse());
  $async.Future<GetSyncStatusResponse> getSyncStatus($pb.ClientContext? ctx, GetSyncStatusRequest request) => _client
      .invoke<GetSyncStatusResponse>(ctx, 'OrchestratorService', 'GetSyncStatus', request, GetSyncStatusResponse());
  $async.Future<GetMainchainBalanceResponse> getMainchainBalance(
          $pb.ClientContext? ctx, GetMainchainBalanceRequest request) =>
      _client.invoke<GetMainchainBalanceResponse>(
          ctx, 'OrchestratorService', 'GetMainchainBalance', request, GetMainchainBalanceResponse());
  $async.Future<PreviewResetDataResponse> previewResetData($pb.ClientContext? ctx, PreviewResetDataRequest request) =>
      _client.invoke<PreviewResetDataResponse>(
          ctx, 'OrchestratorService', 'PreviewResetData', request, PreviewResetDataResponse());
  $async.Future<StreamResetDataResponse> streamResetData($pb.ClientContext? ctx, StreamResetDataRequest request) =>
      _client.invoke<StreamResetDataResponse>(
          ctx, 'OrchestratorService', 'StreamResetData', request, StreamResetDataResponse());
  $async.Future<GetCoreMempoolInfoResponse> getCoreMempoolInfo(
          $pb.ClientContext? ctx, GetCoreMempoolInfoRequest request) =>
      _client.invoke<GetCoreMempoolInfoResponse>(
          ctx, 'OrchestratorService', 'GetCoreMempoolInfo', request, GetCoreMempoolInfoResponse());
  $async.Future<CoreRawCallResponse> coreRawCall($pb.ClientContext? ctx, CoreRawCallRequest request) =>
      _client.invoke<CoreRawCallResponse>(ctx, 'OrchestratorService', 'CoreRawCall', request, CoreRawCallResponse());
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
