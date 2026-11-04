// This is a generated file - do not edit.
//
// Generated from orchestrator/v1/orchestrator.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'orchestrator.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'orchestrator.pbenum.dart';

class GetDatadirNetworkRequest extends $pb.GeneratedMessage {
  factory GetDatadirNetworkRequest() => GetDatadirNetworkRequest._();

  GetDatadirNetworkRequest._();

  factory GetDatadirNetworkRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDatadirNetworkRequest()..mergeFromBuffer(data, registry);
  factory GetDatadirNetworkRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDatadirNetworkRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDatadirNetworkRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetDatadirNetworkRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDatadirNetworkRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDatadirNetworkRequest copyWith(void Function(GetDatadirNetworkRequest) updates) =>
      super.copyWith((message) => updates(message as GetDatadirNetworkRequest)) as GetDatadirNetworkRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetDatadirNetworkRequest() / GetDatadirNetworkRequest.new instead')
  static GetDatadirNetworkRequest create() => GetDatadirNetworkRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetDatadirNetworkRequest._();
  @$core.override
  GetDatadirNetworkRequest createEmptyInstance() => GetDatadirNetworkRequest._();
  @$core.pragma('dart2js:noInline')
  static GetDatadirNetworkRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDatadirNetworkRequest>(GetDatadirNetworkRequest.$_createMessage);
  static GetDatadirNetworkRequest? _defaultInstance;
}

class GetDatadirNetworkResponse extends $pb.GeneratedMessage {
  factory GetDatadirNetworkResponse({
    $core.String? magic,
    $core.String? detectedId,
    $core.String? detectedName,
    $core.String? selectedId,
    $core.String? selectedName,
    $core.bool? mismatch,
    $core.bool? switchReadsBlocks,
    $core.String? firstMagic,
    $core.String? firstId,
    $core.String? firstName,
    $core.bool? mixed,
    $core.String? convertFromId,
    $core.String? convertFromName,
    $core.String? convertToId,
    $core.String? convertToName,
  }) {
    final result = GetDatadirNetworkResponse._();
    if (magic != null) result.magic = magic;
    if (detectedId != null) result.detectedId = detectedId;
    if (detectedName != null) result.detectedName = detectedName;
    if (selectedId != null) result.selectedId = selectedId;
    if (selectedName != null) result.selectedName = selectedName;
    if (mismatch != null) result.mismatch = mismatch;
    if (switchReadsBlocks != null) result.switchReadsBlocks = switchReadsBlocks;
    if (firstMagic != null) result.firstMagic = firstMagic;
    if (firstId != null) result.firstId = firstId;
    if (firstName != null) result.firstName = firstName;
    if (mixed != null) result.mixed = mixed;
    if (convertFromId != null) result.convertFromId = convertFromId;
    if (convertFromName != null) result.convertFromName = convertFromName;
    if (convertToId != null) result.convertToId = convertToId;
    if (convertToName != null) result.convertToName = convertToName;
    return result;
  }

  GetDatadirNetworkResponse._();

  factory GetDatadirNetworkResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDatadirNetworkResponse()..mergeFromBuffer(data, registry);
  factory GetDatadirNetworkResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDatadirNetworkResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDatadirNetworkResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetDatadirNetworkResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'magic')
    ..aOS(2, _omitFieldNames ? '' : 'detectedId')
    ..aOS(3, _omitFieldNames ? '' : 'detectedName')
    ..aOS(4, _omitFieldNames ? '' : 'selectedId')
    ..aOS(5, _omitFieldNames ? '' : 'selectedName')
    ..aOB(6, _omitFieldNames ? '' : 'mismatch')
    ..aOB(7, _omitFieldNames ? '' : 'switchReadsBlocks')
    ..aOS(8, _omitFieldNames ? '' : 'firstMagic')
    ..aOS(9, _omitFieldNames ? '' : 'firstId')
    ..aOS(10, _omitFieldNames ? '' : 'firstName')
    ..aOB(11, _omitFieldNames ? '' : 'mixed')
    ..aOS(12, _omitFieldNames ? '' : 'convertFromId')
    ..aOS(13, _omitFieldNames ? '' : 'convertFromName')
    ..aOS(14, _omitFieldNames ? '' : 'convertToId')
    ..aOS(15, _omitFieldNames ? '' : 'convertToName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDatadirNetworkResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDatadirNetworkResponse copyWith(void Function(GetDatadirNetworkResponse) updates) =>
      super.copyWith((message) => updates(message as GetDatadirNetworkResponse)) as GetDatadirNetworkResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetDatadirNetworkResponse() / GetDatadirNetworkResponse.new instead')
  static GetDatadirNetworkResponse create() => GetDatadirNetworkResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetDatadirNetworkResponse._();
  @$core.override
  GetDatadirNetworkResponse createEmptyInstance() => GetDatadirNetworkResponse._();
  @$core.pragma('dart2js:noInline')
  static GetDatadirNetworkResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDatadirNetworkResponse>(GetDatadirNetworkResponse.$_createMessage);
  static GetDatadirNetworkResponse? _defaultInstance;

  /// The network magic the newest block file carries, in hexadecimal.
  @$pb.TagNumber(1)
  $core.String get magic => $_getSZ(0);
  @$pb.TagNumber(1)
  set magic($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMagic() => $_has(0);
  @$pb.TagNumber(1)
  void clearMagic() => $_clearField(1);

  /// The network that writes that magic, empty when no published network does.
  @$pb.TagNumber(2)
  $core.String get detectedId => $_getSZ(1);
  @$pb.TagNumber(2)
  set detectedId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDetectedId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDetectedId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get detectedName => $_getSZ(2);
  @$pb.TagNumber(3)
  set detectedName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDetectedName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDetectedName() => $_clearField(3);

  /// The network the app runs.
  @$pb.TagNumber(4)
  $core.String get selectedId => $_getSZ(3);
  @$pb.TagNumber(4)
  set selectedId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSelectedId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSelectedId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get selectedName => $_getSZ(4);
  @$pb.TagNumber(5)
  set selectedName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSelectedName() => $_has(4);
  @$pb.TagNumber(5)
  void clearSelectedName() => $_clearField(5);

  /// True when the blocks do not belong to the network the app runs, either
  /// because they name another one or because two networks wrote them.
  @$pb.TagNumber(6)
  $core.bool get mismatch => $_getBF(5);
  @$pb.TagNumber(6)
  set mismatch($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMismatch() => $_has(5);
  @$pb.TagNumber(6)
  void clearMismatch() => $_clearField(6);

  /// True when a switch to the detected network reads this same directory.
  /// Core keeps one directory per chain and one per datadir group.
  @$pb.TagNumber(7)
  $core.bool get switchReadsBlocks => $_getBF(6);
  @$pb.TagNumber(7)
  set switchReadsBlocks($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSwitchReadsBlocks() => $_has(6);
  @$pb.TagNumber(7)
  void clearSwitchReadsBlocks() => $_clearField(7);

  /// The magic the first record of the oldest file carries, and the network that
  /// writes it. They differ from magic and detected_id when a conversion stopped
  /// part way.
  @$pb.TagNumber(8)
  $core.String get firstMagic => $_getSZ(7);
  @$pb.TagNumber(8)
  set firstMagic($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFirstMagic() => $_has(7);
  @$pb.TagNumber(8)
  void clearFirstMagic() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get firstId => $_getSZ(8);
  @$pb.TagNumber(9)
  set firstId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFirstId() => $_has(8);
  @$pb.TagNumber(9)
  void clearFirstId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get firstName => $_getSZ(9);
  @$pb.TagNumber(10)
  set firstName($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasFirstName() => $_has(9);
  @$pb.TagNumber(10)
  void clearFirstName() => $_clearField(10);

  /// True when the two ends of the directory carry different networks, so no
  /// node reads every block in it.
  @$pb.TagNumber(11)
  $core.bool get mixed => $_getBF(10);
  @$pb.TagNumber(11)
  set mixed($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasMixed() => $_has(10);
  @$pb.TagNumber(11)
  void clearMixed() => $_clearField(11);

  /// The conversion that leaves one network in this directory, empty when none
  /// can run. A saved migration names its own direction, which is not always the
  /// network the app runs: the job writes the pick after it moves the records.
  @$pb.TagNumber(12)
  $core.String get convertFromId => $_getSZ(11);
  @$pb.TagNumber(12)
  set convertFromId($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasConvertFromId() => $_has(11);
  @$pb.TagNumber(12)
  void clearConvertFromId() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get convertFromName => $_getSZ(12);
  @$pb.TagNumber(13)
  set convertFromName($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasConvertFromName() => $_has(12);
  @$pb.TagNumber(13)
  void clearConvertFromName() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get convertToId => $_getSZ(13);
  @$pb.TagNumber(14)
  set convertToId($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasConvertToId() => $_has(13);
  @$pb.TagNumber(14)
  void clearConvertToId() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get convertToName => $_getSZ(14);
  @$pb.TagNumber(15)
  set convertToName($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasConvertToName() => $_has(14);
  @$pb.TagNumber(15)
  void clearConvertToName() => $_clearField(15);
}

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
    $core.bool? updateAvailable,
    $fixnum.Int64? remoteTimestampUnix,
    $fixnum.Int64? downloadedTimestampUnix,
    $core.bool? windowOpen,
    $core.String? loadedWalletId,
    $core.bool? hasExternalWallet,
  }) {
    final result = BinaryStatusMsg._();
    if (name != null) result.name = name;
    if (displayName != null) result.displayName = displayName;
    if (running != null) result.running = running;
    if (healthy != null) result.healthy = healthy;
    if (pid != null) result.pid = pid;
    if (uptimeSeconds != null) result.uptimeSeconds = uptimeSeconds;
    if (chainLayer != null) result.chainLayer = chainLayer;
    if (port != null) result.port = port;
    if (error != null) result.error = error;
    if (connected != null) result.connected = connected;
    if (startupError != null) result.startupError = startupError;
    if (connectionError != null) result.connectionError = connectionError;
    if (stopping != null) result.stopping = stopping;
    if (initializing != null) result.initializing = initializing;
    if (connectModeOnly != null) result.connectModeOnly = connectModeOnly;
    if (downloadable != null) result.downloadable = downloadable;
    if (description != null) result.description = description;
    if (downloaded != null) result.downloaded = downloaded;
    if (portInUse != null) result.portInUse = portInUse;
    if (version != null) result.version = version;
    if (repoUrl != null) result.repoUrl = repoUrl;
    if (startupLogs != null) result.startupLogs.addAll(startupLogs);
    if (binaryPath != null) result.binaryPath = binaryPath;
    if (updateAvailable != null) result.updateAvailable = updateAvailable;
    if (remoteTimestampUnix != null) result.remoteTimestampUnix = remoteTimestampUnix;
    if (downloadedTimestampUnix != null) result.downloadedTimestampUnix = downloadedTimestampUnix;
    if (windowOpen != null) result.windowOpen = windowOpen;
    if (loadedWalletId != null) result.loadedWalletId = loadedWalletId;
    if (hasExternalWallet != null) result.hasExternalWallet = hasExternalWallet;
    return result;
  }

  BinaryStatusMsg._();

  factory BinaryStatusMsg.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BinaryStatusMsg()..mergeFromBuffer(data, registry);
  factory BinaryStatusMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BinaryStatusMsg()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BinaryStatusMsg',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: BinaryStatusMsg.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOB(3, _omitFieldNames ? '' : 'running')
    ..aOB(4, _omitFieldNames ? '' : 'healthy')
    ..aI(5, _omitFieldNames ? '' : 'pid')
    ..aInt64(6, _omitFieldNames ? '' : 'uptimeSeconds')
    ..aI(7, _omitFieldNames ? '' : 'chainLayer')
    ..aI(8, _omitFieldNames ? '' : 'port')
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
    ..pPM<StartupLogEntryMsg>(22, _omitFieldNames ? '' : 'startupLogs', subBuilder: StartupLogEntryMsg.$_createMessage)
    ..aOS(23, _omitFieldNames ? '' : 'binaryPath')
    ..aOB(24, _omitFieldNames ? '' : 'updateAvailable')
    ..aInt64(25, _omitFieldNames ? '' : 'remoteTimestampUnix')
    ..aInt64(26, _omitFieldNames ? '' : 'downloadedTimestampUnix')
    ..aOB(27, _omitFieldNames ? '' : 'windowOpen')
    ..aOS(29, _omitFieldNames ? '' : 'loadedWalletId')
    ..aOB(30, _omitFieldNames ? '' : 'hasExternalWallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BinaryStatusMsg clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BinaryStatusMsg copyWith(void Function(BinaryStatusMsg) updates) =>
      super.copyWith((message) => updates(message as BinaryStatusMsg)) as BinaryStatusMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BinaryStatusMsg() / BinaryStatusMsg.new instead')
  static BinaryStatusMsg create() => BinaryStatusMsg._();
  static $pb.GeneratedMessage $_createMessage() => BinaryStatusMsg._();
  @$core.override
  BinaryStatusMsg createEmptyInstance() => BinaryStatusMsg._();
  @$core.pragma('dart2js:noInline')
  static BinaryStatusMsg getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BinaryStatusMsg>(BinaryStatusMsg.$_createMessage);
  static BinaryStatusMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get running => $_getBF(2);
  @$pb.TagNumber(3)
  set running($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRunning() => $_has(2);
  @$pb.TagNumber(3)
  void clearRunning() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get healthy => $_getBF(3);
  @$pb.TagNumber(4)
  set healthy($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHealthy() => $_has(3);
  @$pb.TagNumber(4)
  void clearHealthy() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pid => $_getIZ(4);
  @$pb.TagNumber(5)
  set pid($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPid() => $_has(4);
  @$pb.TagNumber(5)
  void clearPid() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get uptimeSeconds => $_getI64(5);
  @$pb.TagNumber(6)
  set uptimeSeconds($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUptimeSeconds() => $_has(5);
  @$pb.TagNumber(6)
  void clearUptimeSeconds() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get chainLayer => $_getIZ(6);
  @$pb.TagNumber(7)
  set chainLayer($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasChainLayer() => $_has(6);
  @$pb.TagNumber(7)
  void clearChainLayer() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get port => $_getIZ(7);
  @$pb.TagNumber(8)
  set port($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPort() => $_has(7);
  @$pb.TagNumber(8)
  void clearPort() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get error => $_getSZ(8);
  @$pb.TagNumber(9)
  set error($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasError() => $_has(8);
  @$pb.TagNumber(9)
  void clearError() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get connected => $_getBF(9);
  @$pb.TagNumber(10)
  set connected($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasConnected() => $_has(9);
  @$pb.TagNumber(10)
  void clearConnected() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get startupError => $_getSZ(10);
  @$pb.TagNumber(11)
  set startupError($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasStartupError() => $_has(10);
  @$pb.TagNumber(11)
  void clearStartupError() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get connectionError => $_getSZ(11);
  @$pb.TagNumber(12)
  set connectionError($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasConnectionError() => $_has(11);
  @$pb.TagNumber(12)
  void clearConnectionError() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get stopping => $_getBF(12);
  @$pb.TagNumber(13)
  set stopping($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasStopping() => $_has(12);
  @$pb.TagNumber(13)
  void clearStopping() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get initializing => $_getBF(13);
  @$pb.TagNumber(14)
  set initializing($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasInitializing() => $_has(13);
  @$pb.TagNumber(14)
  void clearInitializing() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get connectModeOnly => $_getBF(14);
  @$pb.TagNumber(15)
  set connectModeOnly($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasConnectModeOnly() => $_has(14);
  @$pb.TagNumber(15)
  void clearConnectModeOnly() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.bool get downloadable => $_getBF(15);
  @$pb.TagNumber(16)
  set downloadable($core.bool value) => $_setBool(15, value);
  @$pb.TagNumber(16)
  $core.bool hasDownloadable() => $_has(15);
  @$pb.TagNumber(16)
  void clearDownloadable() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get description => $_getSZ(16);
  @$pb.TagNumber(17)
  set description($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasDescription() => $_has(16);
  @$pb.TagNumber(17)
  void clearDescription() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.bool get downloaded => $_getBF(17);
  @$pb.TagNumber(18)
  set downloaded($core.bool value) => $_setBool(17, value);
  @$pb.TagNumber(18)
  $core.bool hasDownloaded() => $_has(17);
  @$pb.TagNumber(18)
  void clearDownloaded() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.bool get portInUse => $_getBF(18);
  @$pb.TagNumber(19)
  set portInUse($core.bool value) => $_setBool(18, value);
  @$pb.TagNumber(19)
  $core.bool hasPortInUse() => $_has(18);
  @$pb.TagNumber(19)
  void clearPortInUse() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get version => $_getSZ(19);
  @$pb.TagNumber(20)
  set version($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasVersion() => $_has(19);
  @$pb.TagNumber(20)
  void clearVersion() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.String get repoUrl => $_getSZ(20);
  @$pb.TagNumber(21)
  set repoUrl($core.String value) => $_setString(20, value);
  @$pb.TagNumber(21)
  $core.bool hasRepoUrl() => $_has(20);
  @$pb.TagNumber(21)
  void clearRepoUrl() => $_clearField(21);

  @$pb.TagNumber(22)
  $pb.PbList<StartupLogEntryMsg> get startupLogs => $_getList(21);

  /// Absolute path to the download this request selects (variant-aware: returns
  /// bin/test/<binary>/... for a sidechain frontend, the resolved
  /// .app/Contents/MacOS path on macOS, etc.). force_backend picks the daemon
  /// instead. Empty when that download is not on disk.
  @$pb.TagNumber(23)
  $core.String get binaryPath => $_getSZ(22);
  @$pb.TagNumber(23)
  set binaryPath($core.String value) => $_setString(22, value);
  @$pb.TagNumber(23)
  $core.bool hasBinaryPath() => $_has(22);
  @$pb.TagNumber(23)
  void clearBinaryPath() => $_clearField(23);

  /// A newer build is published than the one on disk. False while either side
  /// is unknown, so a failed check never claims an update.
  @$pb.TagNumber(24)
  $core.bool get updateAvailable => $_getBF(23);
  @$pb.TagNumber(24)
  set updateAvailable($core.bool value) => $_setBool(23, value);
  @$pb.TagNumber(24)
  $core.bool hasUpdateAvailable() => $_has(23);
  @$pb.TagNumber(24)
  void clearUpdateAvailable() => $_clearField(24);

  /// Last-Modified of the published download, 0 when unknown.
  @$pb.TagNumber(25)
  $fixnum.Int64 get remoteTimestampUnix => $_getI64(24);
  @$pb.TagNumber(25)
  set remoteTimestampUnix($fixnum.Int64 value) => $_setInt64(24, value);
  @$pb.TagNumber(25)
  $core.bool hasRemoteTimestampUnix() => $_has(24);
  @$pb.TagNumber(25)
  void clearRemoteTimestampUnix() => $_clearField(25);

  /// Modification time of the binary on disk, 0 when not downloaded.
  @$pb.TagNumber(26)
  $fixnum.Int64 get downloadedTimestampUnix => $_getI64(25);
  @$pb.TagNumber(26)
  set downloadedTimestampUnix($fixnum.Int64 value) => $_setInt64(25, value);
  @$pb.TagNumber(26)
  $core.bool hasDownloadedTimestampUnix() => $_has(25);
  @$pb.TagNumber(26)
  void clearDownloadedTimestampUnix() => $_clearField(26);

  /// The chain's own app window is open. It runs under its own process slot, so
  /// a light install has a window with no daemon under it.
  @$pb.TagNumber(27)
  $core.bool get windowOpen => $_getBF(26);
  @$pb.TagNumber(27)
  set windowOpen($core.bool value) => $_setBool(26, value);
  @$pb.TagNumber(27)
  $core.bool hasWindowOpen() => $_has(26);
  @$pb.TagNumber(27)
  void clearWindowOpen() => $_clearField(27);

  /// ID of the wallet whose sidechain wallet this binary holds. Empty for a
  /// binary that keeps no wallet file, and before the first start.
  @$pb.TagNumber(29)
  $core.String get loadedWalletId => $_getSZ(27);
  @$pb.TagNumber(29)
  set loadedWalletId($core.String value) => $_setString(27, value);
  @$pb.TagNumber(29)
  $core.bool hasLoadedWalletId() => $_has(27);
  @$pb.TagNumber(29)
  void clearLoadedWalletId() => $_clearField(29);

  /// The sidechain keeps a wallet.mdb aside that holds a seed no wallet here
  /// made, because its node refused it.
  @$pb.TagNumber(30)
  $core.bool get hasExternalWallet => $_getBF(28);
  @$pb.TagNumber(30)
  set hasExternalWallet($core.bool value) => $_setBool(28, value);
  @$pb.TagNumber(30)
  $core.bool hasHasExternalWallet() => $_has(28);
  @$pb.TagNumber(30)
  void clearHasExternalWallet() => $_clearField(30);
}

class StartupLogEntryMsg extends $pb.GeneratedMessage {
  factory StartupLogEntryMsg({
    $fixnum.Int64? timestampUnix,
    $core.String? message,
  }) {
    final result = StartupLogEntryMsg._();
    if (timestampUnix != null) result.timestampUnix = timestampUnix;
    if (message != null) result.message = message;
    return result;
  }

  StartupLogEntryMsg._();

  factory StartupLogEntryMsg.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartupLogEntryMsg()..mergeFromBuffer(data, registry);
  factory StartupLogEntryMsg.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartupLogEntryMsg()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartupLogEntryMsg',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: StartupLogEntryMsg.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'timestampUnix')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartupLogEntryMsg clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartupLogEntryMsg copyWith(void Function(StartupLogEntryMsg) updates) =>
      super.copyWith((message) => updates(message as StartupLogEntryMsg)) as StartupLogEntryMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StartupLogEntryMsg() / StartupLogEntryMsg.new instead')
  static StartupLogEntryMsg create() => StartupLogEntryMsg._();
  static $pb.GeneratedMessage $_createMessage() => StartupLogEntryMsg._();
  @$core.override
  StartupLogEntryMsg createEmptyInstance() => StartupLogEntryMsg._();
  @$core.pragma('dart2js:noInline')
  static StartupLogEntryMsg getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartupLogEntryMsg>(StartupLogEntryMsg.$_createMessage);
  static StartupLogEntryMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get timestampUnix => $_getI64(0);
  @$pb.TagNumber(1)
  set timestampUnix($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestampUnix() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestampUnix() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class ListBinariesRequest extends $pb.GeneratedMessage {
  factory ListBinariesRequest({
    $core.bool? forceBackend,
  }) {
    final result = ListBinariesRequest._();
    if (forceBackend != null) result.forceBackend = forceBackend;
    return result;
  }

  ListBinariesRequest._();

  factory ListBinariesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBinariesRequest()..mergeFromBuffer(data, registry);
  factory ListBinariesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBinariesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBinariesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ListBinariesRequest.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'forceBackend')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBinariesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBinariesRequest copyWith(void Function(ListBinariesRequest) updates) =>
      super.copyWith((message) => updates(message as ListBinariesRequest)) as ListBinariesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListBinariesRequest() / ListBinariesRequest.new instead')
  static ListBinariesRequest create() => ListBinariesRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListBinariesRequest._();
  @$core.override
  ListBinariesRequest createEmptyInstance() => ListBinariesRequest._();
  @$core.pragma('dart2js:noInline')
  static ListBinariesRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBinariesRequest>(ListBinariesRequest.$_createMessage);
  static ListBinariesRequest? _defaultInstance;

  /// Same lever as launch: when true, skip the UseTestSidechains resolver and
  /// report the prod backend for every layer-2 binary.
  @$pb.TagNumber(1)
  $core.bool get forceBackend => $_getBF(0);
  @$pb.TagNumber(1)
  set forceBackend($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasForceBackend() => $_has(0);
  @$pb.TagNumber(1)
  void clearForceBackend() => $_clearField(1);
}

class ListBinariesResponse extends $pb.GeneratedMessage {
  factory ListBinariesResponse({
    $core.Iterable<BinaryStatusMsg>? binaries,
  }) {
    final result = ListBinariesResponse._();
    if (binaries != null) result.binaries.addAll(binaries);
    return result;
  }

  ListBinariesResponse._();

  factory ListBinariesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBinariesResponse()..mergeFromBuffer(data, registry);
  factory ListBinariesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBinariesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBinariesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ListBinariesResponse.$_createMessage)
    ..pPM<BinaryStatusMsg>(1, _omitFieldNames ? '' : 'binaries', subBuilder: BinaryStatusMsg.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBinariesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBinariesResponse copyWith(void Function(ListBinariesResponse) updates) =>
      super.copyWith((message) => updates(message as ListBinariesResponse)) as ListBinariesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListBinariesResponse() / ListBinariesResponse.new instead')
  static ListBinariesResponse create() => ListBinariesResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListBinariesResponse._();
  @$core.override
  ListBinariesResponse createEmptyInstance() => ListBinariesResponse._();
  @$core.pragma('dart2js:noInline')
  static ListBinariesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListBinariesResponse>(ListBinariesResponse.$_createMessage);
  static ListBinariesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<BinaryStatusMsg> get binaries => $_getList(0);
}

class GetBinaryStatusRequest extends $pb.GeneratedMessage {
  factory GetBinaryStatusRequest({
    $core.String? name,
    $core.bool? forceBackend,
  }) {
    final result = GetBinaryStatusRequest._();
    if (name != null) result.name = name;
    if (forceBackend != null) result.forceBackend = forceBackend;
    return result;
  }

  GetBinaryStatusRequest._();

  factory GetBinaryStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBinaryStatusRequest()..mergeFromBuffer(data, registry);
  factory GetBinaryStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBinaryStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBinaryStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetBinaryStatusRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOB(2, _omitFieldNames ? '' : 'forceBackend')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBinaryStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBinaryStatusRequest copyWith(void Function(GetBinaryStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetBinaryStatusRequest)) as GetBinaryStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBinaryStatusRequest() / GetBinaryStatusRequest.new instead')
  static GetBinaryStatusRequest create() => GetBinaryStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBinaryStatusRequest._();
  @$core.override
  GetBinaryStatusRequest createEmptyInstance() => GetBinaryStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBinaryStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBinaryStatusRequest>(GetBinaryStatusRequest.$_createMessage);
  static GetBinaryStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  /// Same lever as launch: when true, skip the UseTestSidechains resolver and
  /// report the prod backend.
  @$pb.TagNumber(2)
  $core.bool get forceBackend => $_getBF(1);
  @$pb.TagNumber(2)
  set forceBackend($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasForceBackend() => $_has(1);
  @$pb.TagNumber(2)
  void clearForceBackend() => $_clearField(2);
}

class GetBinaryStatusResponse extends $pb.GeneratedMessage {
  factory GetBinaryStatusResponse({
    BinaryStatusMsg? status,
  }) {
    final result = GetBinaryStatusResponse._();
    if (status != null) result.status = status;
    return result;
  }

  GetBinaryStatusResponse._();

  factory GetBinaryStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBinaryStatusResponse()..mergeFromBuffer(data, registry);
  factory GetBinaryStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBinaryStatusResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBinaryStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetBinaryStatusResponse.$_createMessage)
    ..aOM<BinaryStatusMsg>(1, _omitFieldNames ? '' : 'status', subBuilder: BinaryStatusMsg.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBinaryStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBinaryStatusResponse copyWith(void Function(GetBinaryStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetBinaryStatusResponse)) as GetBinaryStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBinaryStatusResponse() / GetBinaryStatusResponse.new instead')
  static GetBinaryStatusResponse create() => GetBinaryStatusResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBinaryStatusResponse._();
  @$core.override
  GetBinaryStatusResponse createEmptyInstance() => GetBinaryStatusResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBinaryStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBinaryStatusResponse>(GetBinaryStatusResponse.$_createMessage);
  static GetBinaryStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BinaryStatusMsg get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(BinaryStatusMsg value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);
  @$pb.TagNumber(1)
  BinaryStatusMsg ensureStatus() => $_ensure(0);
}

class GetBinaryVersionRequest extends $pb.GeneratedMessage {
  factory GetBinaryVersionRequest({
    $core.String? name,
    $core.bool? forceBackend,
  }) {
    final result = GetBinaryVersionRequest._();
    if (name != null) result.name = name;
    if (forceBackend != null) result.forceBackend = forceBackend;
    return result;
  }

  GetBinaryVersionRequest._();

  factory GetBinaryVersionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBinaryVersionRequest()..mergeFromBuffer(data, registry);
  factory GetBinaryVersionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBinaryVersionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBinaryVersionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetBinaryVersionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOB(2, _omitFieldNames ? '' : 'forceBackend')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBinaryVersionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBinaryVersionRequest copyWith(void Function(GetBinaryVersionRequest) updates) =>
      super.copyWith((message) => updates(message as GetBinaryVersionRequest)) as GetBinaryVersionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBinaryVersionRequest() / GetBinaryVersionRequest.new instead')
  static GetBinaryVersionRequest create() => GetBinaryVersionRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBinaryVersionRequest._();
  @$core.override
  GetBinaryVersionRequest createEmptyInstance() => GetBinaryVersionRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBinaryVersionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBinaryVersionRequest>(GetBinaryVersionRequest.$_createMessage);
  static GetBinaryVersionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  /// Same lever as launch: when true, skip the UseTestSidechains resolver and
  /// resolve the prod (Rust) backend. Sidechain callers pass true so the modal
  /// reports the real node version, not the Flutter test build (which has no
  /// --version).
  @$pb.TagNumber(2)
  $core.bool get forceBackend => $_getBF(1);
  @$pb.TagNumber(2)
  set forceBackend($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasForceBackend() => $_has(1);
  @$pb.TagNumber(2)
  void clearForceBackend() => $_clearField(2);
}

class GetBinaryVersionResponse extends $pb.GeneratedMessage {
  factory GetBinaryVersionResponse({
    $core.String? version,
    $core.String? binaryPath,
    $core.bool? isTestBuild,
  }) {
    final result = GetBinaryVersionResponse._();
    if (version != null) result.version = version;
    if (binaryPath != null) result.binaryPath = binaryPath;
    if (isTestBuild != null) result.isTestBuild = isTestBuild;
    return result;
  }

  GetBinaryVersionResponse._();

  factory GetBinaryVersionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBinaryVersionResponse()..mergeFromBuffer(data, registry);
  factory GetBinaryVersionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBinaryVersionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBinaryVersionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetBinaryVersionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'version')
    ..aOS(2, _omitFieldNames ? '' : 'binaryPath')
    ..aOB(3, _omitFieldNames ? '' : 'isTestBuild')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBinaryVersionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBinaryVersionResponse copyWith(void Function(GetBinaryVersionResponse) updates) =>
      super.copyWith((message) => updates(message as GetBinaryVersionResponse)) as GetBinaryVersionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBinaryVersionResponse() / GetBinaryVersionResponse.new instead')
  static GetBinaryVersionResponse create() => GetBinaryVersionResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBinaryVersionResponse._();
  @$core.override
  GetBinaryVersionResponse createEmptyInstance() => GetBinaryVersionResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBinaryVersionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBinaryVersionResponse>(GetBinaryVersionResponse.$_createMessage);
  static GetBinaryVersionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get version => $_getSZ(0);
  @$pb.TagNumber(1)
  set version($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get binaryPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set binaryPath($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBinaryPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearBinaryPath() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isTestBuild => $_getBF(2);
  @$pb.TagNumber(3)
  set isTestBuild($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsTestBuild() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsTestBuild() => $_clearField(3);
}

class DownloadBinaryRequest extends $pb.GeneratedMessage {
  factory DownloadBinaryRequest({
    $core.String? name,
    $core.bool? force,
    $core.bool? forceBackend,
  }) {
    final result = DownloadBinaryRequest._();
    if (name != null) result.name = name;
    if (force != null) result.force = force;
    if (forceBackend != null) result.forceBackend = forceBackend;
    return result;
  }

  DownloadBinaryRequest._();

  factory DownloadBinaryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DownloadBinaryRequest()..mergeFromBuffer(data, registry);
  factory DownloadBinaryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DownloadBinaryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadBinaryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: DownloadBinaryRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOB(2, _omitFieldNames ? '' : 'force')
    ..aOB(3, _omitFieldNames ? '' : 'forceBackend')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadBinaryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadBinaryRequest copyWith(void Function(DownloadBinaryRequest) updates) =>
      super.copyWith((message) => updates(message as DownloadBinaryRequest)) as DownloadBinaryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DownloadBinaryRequest() / DownloadBinaryRequest.new instead')
  static DownloadBinaryRequest create() => DownloadBinaryRequest._();
  static $pb.GeneratedMessage $_createMessage() => DownloadBinaryRequest._();
  @$core.override
  DownloadBinaryRequest createEmptyInstance() => DownloadBinaryRequest._();
  @$core.pragma('dart2js:noInline')
  static DownloadBinaryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DownloadBinaryRequest>(DownloadBinaryRequest.$_createMessage);
  static DownloadBinaryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get force => $_getBF(1);
  @$pb.TagNumber(2)
  set force($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasForce() => $_has(1);
  @$pb.TagNumber(2)
  void clearForce() => $_clearField(2);

  /// Download the daemon, never the sidechain's Flutter bundle. Sidechain apps
  /// set this so an update installs the backend they actually run.
  @$pb.TagNumber(3)
  $core.bool get forceBackend => $_getBF(2);
  @$pb.TagNumber(3)
  set forceBackend($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasForceBackend() => $_has(2);
  @$pb.TagNumber(3)
  void clearForceBackend() => $_clearField(3);
}

class DownloadBinaryResponse extends $pb.GeneratedMessage {
  factory DownloadBinaryResponse() => DownloadBinaryResponse._();

  DownloadBinaryResponse._();

  factory DownloadBinaryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DownloadBinaryResponse()..mergeFromBuffer(data, registry);
  factory DownloadBinaryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DownloadBinaryResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadBinaryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: DownloadBinaryResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadBinaryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadBinaryResponse copyWith(void Function(DownloadBinaryResponse) updates) =>
      super.copyWith((message) => updates(message as DownloadBinaryResponse)) as DownloadBinaryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DownloadBinaryResponse() / DownloadBinaryResponse.new instead')
  static DownloadBinaryResponse create() => DownloadBinaryResponse._();
  static $pb.GeneratedMessage $_createMessage() => DownloadBinaryResponse._();
  @$core.override
  DownloadBinaryResponse createEmptyInstance() => DownloadBinaryResponse._();
  @$core.pragma('dart2js:noInline')
  static DownloadBinaryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DownloadBinaryResponse>(DownloadBinaryResponse.$_createMessage);
  static DownloadBinaryResponse? _defaultInstance;
}

class StartBinaryRequest extends $pb.GeneratedMessage {
  factory StartBinaryRequest({
    $core.String? name,
    $core.Iterable<$core.String>? extraArgs,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? env,
  }) {
    final result = StartBinaryRequest._();
    if (name != null) result.name = name;
    if (extraArgs != null) result.extraArgs.addAll(extraArgs);
    if (env != null) result.env.addEntries(env);
    return result;
  }

  StartBinaryRequest._();

  factory StartBinaryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartBinaryRequest()..mergeFromBuffer(data, registry);
  factory StartBinaryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartBinaryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartBinaryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: StartBinaryRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..pPS(2, _omitFieldNames ? '' : 'extraArgs')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'env',
        entryClassName: 'StartBinaryRequest.EnvEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('orchestrator.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartBinaryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartBinaryRequest copyWith(void Function(StartBinaryRequest) updates) =>
      super.copyWith((message) => updates(message as StartBinaryRequest)) as StartBinaryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StartBinaryRequest() / StartBinaryRequest.new instead')
  static StartBinaryRequest create() => StartBinaryRequest._();
  static $pb.GeneratedMessage $_createMessage() => StartBinaryRequest._();
  @$core.override
  StartBinaryRequest createEmptyInstance() => StartBinaryRequest._();
  @$core.pragma('dart2js:noInline')
  static StartBinaryRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartBinaryRequest>(StartBinaryRequest.$_createMessage);
  static StartBinaryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get extraArgs => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.String> get env => $_getMap(2);
}

class StartBinaryResponse extends $pb.GeneratedMessage {
  factory StartBinaryResponse({
    $core.int? pid,
  }) {
    final result = StartBinaryResponse._();
    if (pid != null) result.pid = pid;
    return result;
  }

  StartBinaryResponse._();

  factory StartBinaryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartBinaryResponse()..mergeFromBuffer(data, registry);
  factory StartBinaryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartBinaryResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartBinaryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: StartBinaryResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'pid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartBinaryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartBinaryResponse copyWith(void Function(StartBinaryResponse) updates) =>
      super.copyWith((message) => updates(message as StartBinaryResponse)) as StartBinaryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StartBinaryResponse() / StartBinaryResponse.new instead')
  static StartBinaryResponse create() => StartBinaryResponse._();
  static $pb.GeneratedMessage $_createMessage() => StartBinaryResponse._();
  @$core.override
  StartBinaryResponse createEmptyInstance() => StartBinaryResponse._();
  @$core.pragma('dart2js:noInline')
  static StartBinaryResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartBinaryResponse>(StartBinaryResponse.$_createMessage);
  static StartBinaryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pid => $_getIZ(0);
  @$pb.TagNumber(1)
  set pid($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPid() => $_has(0);
  @$pb.TagNumber(1)
  void clearPid() => $_clearField(1);
}

class StopBinaryRequest extends $pb.GeneratedMessage {
  factory StopBinaryRequest({
    $core.String? name,
    $core.bool? force,
    $core.bool? forceBackend,
  }) {
    final result = StopBinaryRequest._();
    if (name != null) result.name = name;
    if (force != null) result.force = force;
    if (forceBackend != null) result.forceBackend = forceBackend;
    return result;
  }

  StopBinaryRequest._();

  factory StopBinaryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopBinaryRequest()..mergeFromBuffer(data, registry);
  factory StopBinaryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopBinaryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopBinaryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: StopBinaryRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOB(2, _omitFieldNames ? '' : 'force')
    ..aOB(3, _omitFieldNames ? '' : 'forceBackend')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopBinaryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopBinaryRequest copyWith(void Function(StopBinaryRequest) updates) =>
      super.copyWith((message) => updates(message as StopBinaryRequest)) as StopBinaryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StopBinaryRequest() / StopBinaryRequest.new instead')
  static StopBinaryRequest create() => StopBinaryRequest._();
  static $pb.GeneratedMessage $_createMessage() => StopBinaryRequest._();
  @$core.override
  StopBinaryRequest createEmptyInstance() => StopBinaryRequest._();
  @$core.pragma('dart2js:noInline')
  static StopBinaryRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopBinaryRequest>(StopBinaryRequest.$_createMessage);
  static StopBinaryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get force => $_getBF(1);
  @$pb.TagNumber(2)
  set force($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasForce() => $_has(1);
  @$pb.TagNumber(2)
  void clearForce() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get forceBackend => $_getBF(2);
  @$pb.TagNumber(3)
  set forceBackend($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasForceBackend() => $_has(2);
  @$pb.TagNumber(3)
  void clearForceBackend() => $_clearField(3);
}

class StopBinaryResponse extends $pb.GeneratedMessage {
  factory StopBinaryResponse() => StopBinaryResponse._();

  StopBinaryResponse._();

  factory StopBinaryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopBinaryResponse()..mergeFromBuffer(data, registry);
  factory StopBinaryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopBinaryResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopBinaryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: StopBinaryResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopBinaryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopBinaryResponse copyWith(void Function(StopBinaryResponse) updates) =>
      super.copyWith((message) => updates(message as StopBinaryResponse)) as StopBinaryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StopBinaryResponse() / StopBinaryResponse.new instead')
  static StopBinaryResponse create() => StopBinaryResponse._();
  static $pb.GeneratedMessage $_createMessage() => StopBinaryResponse._();
  @$core.override
  StopBinaryResponse createEmptyInstance() => StopBinaryResponse._();
  @$core.pragma('dart2js:noInline')
  static StopBinaryResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopBinaryResponse>(StopBinaryResponse.$_createMessage);
  static StopBinaryResponse? _defaultInstance;
}

class StreamLogsRequest extends $pb.GeneratedMessage {
  factory StreamLogsRequest({
    $core.String? name,
    $core.int? tail,
    $core.String? runId,
    $fixnum.Int64? afterSequence,
  }) {
    final result = StreamLogsRequest._();
    if (name != null) result.name = name;
    if (tail != null) result.tail = tail;
    if (runId != null) result.runId = runId;
    if (afterSequence != null) result.afterSequence = afterSequence;
    return result;
  }

  StreamLogsRequest._();

  factory StreamLogsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StreamLogsRequest()..mergeFromBuffer(data, registry);
  factory StreamLogsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StreamLogsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StreamLogsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: StreamLogsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aI(2, _omitFieldNames ? '' : 'tail')
    ..aOS(3, _omitFieldNames ? '' : 'runId')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'afterSequence', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamLogsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamLogsRequest copyWith(void Function(StreamLogsRequest) updates) =>
      super.copyWith((message) => updates(message as StreamLogsRequest)) as StreamLogsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StreamLogsRequest() / StreamLogsRequest.new instead')
  static StreamLogsRequest create() => StreamLogsRequest._();
  static $pb.GeneratedMessage $_createMessage() => StreamLogsRequest._();
  @$core.override
  StreamLogsRequest createEmptyInstance() => StreamLogsRequest._();
  @$core.pragma('dart2js:noInline')
  static StreamLogsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StreamLogsRequest>(StreamLogsRequest.$_createMessage);
  static StreamLogsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get tail => $_getIZ(1);
  @$pb.TagNumber(2)
  set tail($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTail() => $_has(1);
  @$pb.TagNumber(2)
  void clearTail() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get runId => $_getSZ(2);
  @$pb.TagNumber(3)
  set runId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRunId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRunId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get afterSequence => $_getI64(3);
  @$pb.TagNumber(4)
  set afterSequence($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAfterSequence() => $_has(3);
  @$pb.TagNumber(4)
  void clearAfterSequence() => $_clearField(4);
}

class StreamLogsResponse extends $pb.GeneratedMessage {
  factory StreamLogsResponse({
    $core.String? stream,
    $core.String? line,
    $fixnum.Int64? timestampUnix,
    $core.String? runId,
    $fixnum.Int64? sequence,
  }) {
    final result = StreamLogsResponse._();
    if (stream != null) result.stream = stream;
    if (line != null) result.line = line;
    if (timestampUnix != null) result.timestampUnix = timestampUnix;
    if (runId != null) result.runId = runId;
    if (sequence != null) result.sequence = sequence;
    return result;
  }

  StreamLogsResponse._();

  factory StreamLogsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StreamLogsResponse()..mergeFromBuffer(data, registry);
  factory StreamLogsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StreamLogsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StreamLogsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: StreamLogsResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'stream')
    ..aOS(2, _omitFieldNames ? '' : 'line')
    ..aInt64(3, _omitFieldNames ? '' : 'timestampUnix')
    ..aOS(4, _omitFieldNames ? '' : 'runId')
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'sequence', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamLogsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamLogsResponse copyWith(void Function(StreamLogsResponse) updates) =>
      super.copyWith((message) => updates(message as StreamLogsResponse)) as StreamLogsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StreamLogsResponse() / StreamLogsResponse.new instead')
  static StreamLogsResponse create() => StreamLogsResponse._();
  static $pb.GeneratedMessage $_createMessage() => StreamLogsResponse._();
  @$core.override
  StreamLogsResponse createEmptyInstance() => StreamLogsResponse._();
  @$core.pragma('dart2js:noInline')
  static StreamLogsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StreamLogsResponse>(StreamLogsResponse.$_createMessage);
  static StreamLogsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get stream => $_getSZ(0);
  @$pb.TagNumber(1)
  set stream($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStream() => $_has(0);
  @$pb.TagNumber(1)
  void clearStream() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get line => $_getSZ(1);
  @$pb.TagNumber(2)
  set line($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLine() => $_has(1);
  @$pb.TagNumber(2)
  void clearLine() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestampUnix => $_getI64(2);
  @$pb.TagNumber(3)
  set timestampUnix($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestampUnix() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestampUnix() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get runId => $_getSZ(3);
  @$pb.TagNumber(4)
  set runId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRunId() => $_has(3);
  @$pb.TagNumber(4)
  void clearRunId() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get sequence => $_getI64(4);
  @$pb.TagNumber(5)
  set sequence($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSequence() => $_has(4);
  @$pb.TagNumber(5)
  void clearSequence() => $_clearField(5);
}

class StartWithL1Request extends $pb.GeneratedMessage {
  factory StartWithL1Request({
    $core.String? target,
    $core.Iterable<$core.String>? targetArgs,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? targetEnv,
    $core.Iterable<$core.String>? coreArgs,
    $core.Iterable<$core.String>? enforcerArgs,
    $core.bool? immediate,
    $core.bool? forceBackend,
    $core.bool? wait,
  }) {
    final result = StartWithL1Request._();
    if (target != null) result.target = target;
    if (targetArgs != null) result.targetArgs.addAll(targetArgs);
    if (targetEnv != null) result.targetEnv.addEntries(targetEnv);
    if (coreArgs != null) result.coreArgs.addAll(coreArgs);
    if (enforcerArgs != null) result.enforcerArgs.addAll(enforcerArgs);
    if (immediate != null) result.immediate = immediate;
    if (forceBackend != null) result.forceBackend = forceBackend;
    if (wait != null) result.wait = wait;
    return result;
  }

  StartWithL1Request._();

  factory StartWithL1Request.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartWithL1Request()..mergeFromBuffer(data, registry);
  factory StartWithL1Request.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartWithL1Request()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartWithL1Request',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: StartWithL1Request.$_createMessage)
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
    ..aOB(7, _omitFieldNames ? '' : 'forceBackend')
    ..aOB(8, _omitFieldNames ? '' : 'wait')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartWithL1Request clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartWithL1Request copyWith(void Function(StartWithL1Request) updates) =>
      super.copyWith((message) => updates(message as StartWithL1Request)) as StartWithL1Request;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StartWithL1Request() / StartWithL1Request.new instead')
  static StartWithL1Request create() => StartWithL1Request._();
  static $pb.GeneratedMessage $_createMessage() => StartWithL1Request._();
  @$core.override
  StartWithL1Request createEmptyInstance() => StartWithL1Request._();
  @$core.pragma('dart2js:noInline')
  static StartWithL1Request getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartWithL1Request>(StartWithL1Request.$_createMessage);
  static StartWithL1Request? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get target => $_getSZ(0);
  @$pb.TagNumber(1)
  set target($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTarget() => $_has(0);
  @$pb.TagNumber(1)
  void clearTarget() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get targetArgs => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.String> get targetEnv => $_getMap(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get coreArgs => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get enforcerArgs => $_getList(4);

  @$pb.TagNumber(6)
  $core.bool get immediate => $_getBF(5);
  @$pb.TagNumber(6)
  set immediate($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasImmediate() => $_has(5);
  @$pb.TagNumber(6)
  void clearImmediate() => $_clearField(6);

  /// Bypass UseTestSidechains for this call: always launch the prod-download
  /// binary even if the user toggled "Use test sidechains" on. Sidechain
  /// Flutter apps set this when self-booting their backend so the toggle
  /// doesn't re-spawn another Flutter bundle inside them.
  @$pb.TagNumber(7)
  $core.bool get forceBackend => $_getBF(6);
  @$pb.TagNumber(7)
  set forceBackend($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasForceBackend() => $_has(6);
  @$pb.TagNumber(7)
  void clearForceBackend() => $_clearField(7);

  /// Wait for startup to complete. A canceled request stops startup.
  @$pb.TagNumber(8)
  $core.bool get wait => $_getBF(7);
  @$pb.TagNumber(8)
  set wait($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWait() => $_has(7);
  @$pb.TagNumber(8)
  void clearWait() => $_clearField(8);
}

class StartWithL1Response extends $pb.GeneratedMessage {
  factory StartWithL1Response() => StartWithL1Response._();

  StartWithL1Response._();

  factory StartWithL1Response.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartWithL1Response()..mergeFromBuffer(data, registry);
  factory StartWithL1Response.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartWithL1Response()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartWithL1Response',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: StartWithL1Response.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartWithL1Response clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartWithL1Response copyWith(void Function(StartWithL1Response) updates) =>
      super.copyWith((message) => updates(message as StartWithL1Response)) as StartWithL1Response;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StartWithL1Response() / StartWithL1Response.new instead')
  static StartWithL1Response create() => StartWithL1Response._();
  static $pb.GeneratedMessage $_createMessage() => StartWithL1Response._();
  @$core.override
  StartWithL1Response createEmptyInstance() => StartWithL1Response._();
  @$core.pragma('dart2js:noInline')
  static StartWithL1Response getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartWithL1Response>(StartWithL1Response.$_createMessage);
  static StartWithL1Response? _defaultInstance;
}

class RestartDaemonRequest extends $pb.GeneratedMessage {
  factory RestartDaemonRequest({
    $core.String? name,
    $core.bool? forceBackend,
  }) {
    final result = RestartDaemonRequest._();
    if (name != null) result.name = name;
    if (forceBackend != null) result.forceBackend = forceBackend;
    return result;
  }

  RestartDaemonRequest._();

  factory RestartDaemonRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestartDaemonRequest()..mergeFromBuffer(data, registry);
  factory RestartDaemonRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestartDaemonRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestartDaemonRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: RestartDaemonRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOB(2, _omitFieldNames ? '' : 'forceBackend')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestartDaemonRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestartDaemonRequest copyWith(void Function(RestartDaemonRequest) updates) =>
      super.copyWith((message) => updates(message as RestartDaemonRequest)) as RestartDaemonRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RestartDaemonRequest() / RestartDaemonRequest.new instead')
  static RestartDaemonRequest create() => RestartDaemonRequest._();
  static $pb.GeneratedMessage $_createMessage() => RestartDaemonRequest._();
  @$core.override
  RestartDaemonRequest createEmptyInstance() => RestartDaemonRequest._();
  @$core.pragma('dart2js:noInline')
  static RestartDaemonRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RestartDaemonRequest>(RestartDaemonRequest.$_createMessage);
  static RestartDaemonRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  /// Restart only the daemon, never the sidechain's Flutter bundle. A stopped
  /// daemon keeps no boot mode to recover, so the caller states it.
  @$pb.TagNumber(2)
  $core.bool get forceBackend => $_getBF(1);
  @$pb.TagNumber(2)
  set forceBackend($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasForceBackend() => $_has(1);
  @$pb.TagNumber(2)
  void clearForceBackend() => $_clearField(2);
}

class RestartDaemonResponse extends $pb.GeneratedMessage {
  factory RestartDaemonResponse() => RestartDaemonResponse._();

  RestartDaemonResponse._();

  factory RestartDaemonResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestartDaemonResponse()..mergeFromBuffer(data, registry);
  factory RestartDaemonResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestartDaemonResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestartDaemonResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: RestartDaemonResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestartDaemonResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestartDaemonResponse copyWith(void Function(RestartDaemonResponse) updates) =>
      super.copyWith((message) => updates(message as RestartDaemonResponse)) as RestartDaemonResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RestartDaemonResponse() / RestartDaemonResponse.new instead')
  static RestartDaemonResponse create() => RestartDaemonResponse._();
  static $pb.GeneratedMessage $_createMessage() => RestartDaemonResponse._();
  @$core.override
  RestartDaemonResponse createEmptyInstance() => RestartDaemonResponse._();
  @$core.pragma('dart2js:noInline')
  static RestartDaemonResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RestartDaemonResponse>(RestartDaemonResponse.$_createMessage);
  static RestartDaemonResponse? _defaultInstance;
}

class RestartL1Request extends $pb.GeneratedMessage {
  factory RestartL1Request() => RestartL1Request._();

  RestartL1Request._();

  factory RestartL1Request.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestartL1Request()..mergeFromBuffer(data, registry);
  factory RestartL1Request.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestartL1Request()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestartL1Request',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: RestartL1Request.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestartL1Request clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestartL1Request copyWith(void Function(RestartL1Request) updates) =>
      super.copyWith((message) => updates(message as RestartL1Request)) as RestartL1Request;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RestartL1Request() / RestartL1Request.new instead')
  static RestartL1Request create() => RestartL1Request._();
  static $pb.GeneratedMessage $_createMessage() => RestartL1Request._();
  @$core.override
  RestartL1Request createEmptyInstance() => RestartL1Request._();
  @$core.pragma('dart2js:noInline')
  static RestartL1Request getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RestartL1Request>(RestartL1Request.$_createMessage);
  static RestartL1Request? _defaultInstance;
}

class RestartL1Response extends $pb.GeneratedMessage {
  factory RestartL1Response() => RestartL1Response._();

  RestartL1Response._();

  factory RestartL1Response.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestartL1Response()..mergeFromBuffer(data, registry);
  factory RestartL1Response.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestartL1Response()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestartL1Response',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: RestartL1Response.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestartL1Response clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestartL1Response copyWith(void Function(RestartL1Response) updates) =>
      super.copyWith((message) => updates(message as RestartL1Response)) as RestartL1Response;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RestartL1Response() / RestartL1Response.new instead')
  static RestartL1Response create() => RestartL1Response._();
  static $pb.GeneratedMessage $_createMessage() => RestartL1Response._();
  @$core.override
  RestartL1Response createEmptyInstance() => RestartL1Response._();
  @$core.pragma('dart2js:noInline')
  static RestartL1Response getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RestartL1Response>(RestartL1Response.$_createMessage);
  static RestartL1Response? _defaultInstance;
}

class ApplyUTXOSnapshotRequest extends $pb.GeneratedMessage {
  factory ApplyUTXOSnapshotRequest({
    $core.String? url,
    $core.String? path,
    $core.String? sha256,
  }) {
    final result = ApplyUTXOSnapshotRequest._();
    if (url != null) result.url = url;
    if (path != null) result.path = path;
    if (sha256 != null) result.sha256 = sha256;
    return result;
  }

  ApplyUTXOSnapshotRequest._();

  factory ApplyUTXOSnapshotRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApplyUTXOSnapshotRequest()..mergeFromBuffer(data, registry);
  factory ApplyUTXOSnapshotRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApplyUTXOSnapshotRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ApplyUTXOSnapshotRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ApplyUTXOSnapshotRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'path')
    ..aOS(3, _omitFieldNames ? '' : 'sha256')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyUTXOSnapshotRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyUTXOSnapshotRequest copyWith(void Function(ApplyUTXOSnapshotRequest) updates) =>
      super.copyWith((message) => updates(message as ApplyUTXOSnapshotRequest)) as ApplyUTXOSnapshotRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ApplyUTXOSnapshotRequest() / ApplyUTXOSnapshotRequest.new instead')
  static ApplyUTXOSnapshotRequest create() => ApplyUTXOSnapshotRequest._();
  static $pb.GeneratedMessage $_createMessage() => ApplyUTXOSnapshotRequest._();
  @$core.override
  ApplyUTXOSnapshotRequest createEmptyInstance() => ApplyUTXOSnapshotRequest._();
  @$core.pragma('dart2js:noInline')
  static ApplyUTXOSnapshotRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApplyUTXOSnapshotRequest>(ApplyUTXOSnapshotRequest.$_createMessage);
  static ApplyUTXOSnapshotRequest? _defaultInstance;

  /// Exactly one of url or path. url is downloaded; path is a file the user
  /// already has on disk and is left in place afterwards.
  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get path => $_getSZ(1);
  @$pb.TagNumber(2)
  set path($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearPath() => $_clearField(2);

  /// Expected sha256 of the snapshot, lowercase hex. Optional — empty loads the
  /// snapshot unverified, which is the normal case for a user-supplied file.
  @$pb.TagNumber(3)
  $core.String get sha256 => $_getSZ(2);
  @$pb.TagNumber(3)
  set sha256($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSha256() => $_has(2);
  @$pb.TagNumber(3)
  void clearSha256() => $_clearField(3);
}

class ApplyUTXOSnapshotResponse extends $pb.GeneratedMessage {
  factory ApplyUTXOSnapshotResponse({
    $core.String? message,
    $core.int? downloadPercent,
    $core.bool? done,
  }) {
    final result = ApplyUTXOSnapshotResponse._();
    if (message != null) result.message = message;
    if (downloadPercent != null) result.downloadPercent = downloadPercent;
    if (done != null) result.done = done;
    return result;
  }

  ApplyUTXOSnapshotResponse._();

  factory ApplyUTXOSnapshotResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApplyUTXOSnapshotResponse()..mergeFromBuffer(data, registry);
  factory ApplyUTXOSnapshotResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApplyUTXOSnapshotResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ApplyUTXOSnapshotResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ApplyUTXOSnapshotResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..aI(2, _omitFieldNames ? '' : 'downloadPercent')
    ..aOB(3, _omitFieldNames ? '' : 'done')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyUTXOSnapshotResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyUTXOSnapshotResponse copyWith(void Function(ApplyUTXOSnapshotResponse) updates) =>
      super.copyWith((message) => updates(message as ApplyUTXOSnapshotResponse)) as ApplyUTXOSnapshotResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ApplyUTXOSnapshotResponse() / ApplyUTXOSnapshotResponse.new instead')
  static ApplyUTXOSnapshotResponse create() => ApplyUTXOSnapshotResponse._();
  static $pb.GeneratedMessage $_createMessage() => ApplyUTXOSnapshotResponse._();
  @$core.override
  ApplyUTXOSnapshotResponse createEmptyInstance() => ApplyUTXOSnapshotResponse._();
  @$core.pragma('dart2js:noInline')
  static ApplyUTXOSnapshotResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApplyUTXOSnapshotResponse>(ApplyUTXOSnapshotResponse.$_createMessage);
  static ApplyUTXOSnapshotResponse? _defaultInstance;

  /// Human-readable status, e.g. "downloading UTXO snapshot... 42%".
  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);

  /// Download completion, 0-100. Zero while no download is in flight — the
  /// load phase itself reports no percentage, because Core blocks until the
  /// whole snapshot is read and exposes no completion fraction.
  @$pb.TagNumber(2)
  $core.int get downloadPercent => $_getIZ(1);
  @$pb.TagNumber(2)
  set downloadPercent($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDownloadPercent() => $_has(1);
  @$pb.TagNumber(2)
  void clearDownloadPercent() => $_clearField(2);

  /// Set once Core has accepted and finished loading the snapshot.
  @$pb.TagNumber(3)
  $core.bool get done => $_getBF(2);
  @$pb.TagNumber(3)
  set done($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDone() => $_has(2);
  @$pb.TagNumber(3)
  void clearDone() => $_clearField(3);
}

class GetSnapshotStatusRequest extends $pb.GeneratedMessage {
  factory GetSnapshotStatusRequest() => GetSnapshotStatusRequest._();

  GetSnapshotStatusRequest._();

  factory GetSnapshotStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSnapshotStatusRequest()..mergeFromBuffer(data, registry);
  factory GetSnapshotStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSnapshotStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSnapshotStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetSnapshotStatusRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSnapshotStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSnapshotStatusRequest copyWith(void Function(GetSnapshotStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetSnapshotStatusRequest)) as GetSnapshotStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSnapshotStatusRequest() / GetSnapshotStatusRequest.new instead')
  static GetSnapshotStatusRequest create() => GetSnapshotStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetSnapshotStatusRequest._();
  @$core.override
  GetSnapshotStatusRequest createEmptyInstance() => GetSnapshotStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static GetSnapshotStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSnapshotStatusRequest>(GetSnapshotStatusRequest.$_createMessage);
  static GetSnapshotStatusRequest? _defaultInstance;
}

class GetSnapshotStatusResponse extends $pb.GeneratedMessage {
  factory GetSnapshotStatusResponse({
    $core.String? availableUrl,
    $fixnum.Int64? availableHeight,
    $core.String? availableSha256,
    $core.bool? hasActiveSnapshot,
    $core.String? activeBlockhash,
    $fixnum.Int64? activeHeight,
    $core.bool? activeValidated,
    $core.double? activeVerificationProgress,
  }) {
    final result = GetSnapshotStatusResponse._();
    if (availableUrl != null) result.availableUrl = availableUrl;
    if (availableHeight != null) result.availableHeight = availableHeight;
    if (availableSha256 != null) result.availableSha256 = availableSha256;
    if (hasActiveSnapshot != null) result.hasActiveSnapshot = hasActiveSnapshot;
    if (activeBlockhash != null) result.activeBlockhash = activeBlockhash;
    if (activeHeight != null) result.activeHeight = activeHeight;
    if (activeValidated != null) result.activeValidated = activeValidated;
    if (activeVerificationProgress != null) result.activeVerificationProgress = activeVerificationProgress;
    return result;
  }

  GetSnapshotStatusResponse._();

  factory GetSnapshotStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSnapshotStatusResponse()..mergeFromBuffer(data, registry);
  factory GetSnapshotStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSnapshotStatusResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSnapshotStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetSnapshotStatusResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'availableUrl')
    ..aInt64(2, _omitFieldNames ? '' : 'availableHeight')
    ..aOS(3, _omitFieldNames ? '' : 'availableSha256')
    ..aOB(4, _omitFieldNames ? '' : 'hasActiveSnapshot')
    ..aOS(5, _omitFieldNames ? '' : 'activeBlockhash')
    ..aInt64(6, _omitFieldNames ? '' : 'activeHeight')
    ..aOB(7, _omitFieldNames ? '' : 'activeValidated')
    ..aD(8, _omitFieldNames ? '' : 'activeVerificationProgress')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSnapshotStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSnapshotStatusResponse copyWith(void Function(GetSnapshotStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetSnapshotStatusResponse)) as GetSnapshotStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSnapshotStatusResponse() / GetSnapshotStatusResponse.new instead')
  static GetSnapshotStatusResponse create() => GetSnapshotStatusResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetSnapshotStatusResponse._();
  @$core.override
  GetSnapshotStatusResponse createEmptyInstance() => GetSnapshotStatusResponse._();
  @$core.pragma('dart2js:noInline')
  static GetSnapshotStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSnapshotStatusResponse>(GetSnapshotStatusResponse.$_createMessage);
  static GetSnapshotStatusResponse? _defaultInstance;

  /// The snapshot the active network publishes, empty url when none. Used to
  /// pre-fill the snapshot field in settings.
  @$pb.TagNumber(1)
  $core.String get availableUrl => $_getSZ(0);
  @$pb.TagNumber(1)
  set availableUrl($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAvailableUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearAvailableUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get availableHeight => $_getI64(1);
  @$pb.TagNumber(2)
  set availableHeight($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAvailableHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvailableHeight() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get availableSha256 => $_getSZ(2);
  @$pb.TagNumber(3)
  set availableSha256($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvailableSha256() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvailableSha256() => $_clearField(3);

  /// The snapshot currently loaded in Bitcoin Core, from getchainstates.
  @$pb.TagNumber(4)
  $core.bool get hasActiveSnapshot => $_getBF(3);
  @$pb.TagNumber(4)
  set hasActiveSnapshot($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHasActiveSnapshot() => $_has(3);
  @$pb.TagNumber(4)
  void clearHasActiveSnapshot() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get activeBlockhash => $_getSZ(4);
  @$pb.TagNumber(5)
  set activeBlockhash($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasActiveBlockhash() => $_has(4);
  @$pb.TagNumber(5)
  void clearActiveBlockhash() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get activeHeight => $_getI64(5);
  @$pb.TagNumber(6)
  set activeHeight($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasActiveHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearActiveHeight() => $_clearField(6);

  /// Set once Core has fully validated the snapshot chainstate from genesis.
  @$pb.TagNumber(7)
  $core.bool get activeValidated => $_getBF(6);
  @$pb.TagNumber(7)
  set activeValidated($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasActiveValidated() => $_has(6);
  @$pb.TagNumber(7)
  void clearActiveValidated() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get activeVerificationProgress => $_getN(7);
  @$pb.TagNumber(8)
  set activeVerificationProgress($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasActiveVerificationProgress() => $_has(7);
  @$pb.TagNumber(8)
  void clearActiveVerificationProgress() => $_clearField(8);
}

class GetPendingNetworkGenerationRequest extends $pb.GeneratedMessage {
  factory GetPendingNetworkGenerationRequest() => GetPendingNetworkGenerationRequest._();

  GetPendingNetworkGenerationRequest._();

  factory GetPendingNetworkGenerationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPendingNetworkGenerationRequest()..mergeFromBuffer(data, registry);
  factory GetPendingNetworkGenerationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPendingNetworkGenerationRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingNetworkGenerationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetPendingNetworkGenerationRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingNetworkGenerationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingNetworkGenerationRequest copyWith(void Function(GetPendingNetworkGenerationRequest) updates) =>
      super.copyWith((message) => updates(message as GetPendingNetworkGenerationRequest))
          as GetPendingNetworkGenerationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetPendingNetworkGenerationRequest() / GetPendingNetworkGenerationRequest.new instead')
  static GetPendingNetworkGenerationRequest create() => GetPendingNetworkGenerationRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetPendingNetworkGenerationRequest._();
  @$core.override
  GetPendingNetworkGenerationRequest createEmptyInstance() => GetPendingNetworkGenerationRequest._();
  @$core.pragma('dart2js:noInline')
  static GetPendingNetworkGenerationRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPendingNetworkGenerationRequest>(
          GetPendingNetworkGenerationRequest.$_createMessage);
  static GetPendingNetworkGenerationRequest? _defaultInstance;
}

class GetPendingNetworkGenerationResponse extends $pb.GeneratedMessage {
  factory GetPendingNetworkGenerationResponse({
    $core.String? currentNetworkId,
    $core.String? pendingNetworkId,
    $fixnum.Int64? snapshotHeight,
    $fixnum.Int64? snapshotSizeBytes,
    $core.String? pendingPeer,
    $core.bool? userManagedConf,
  }) {
    final result = GetPendingNetworkGenerationResponse._();
    if (currentNetworkId != null) result.currentNetworkId = currentNetworkId;
    if (pendingNetworkId != null) result.pendingNetworkId = pendingNetworkId;
    if (snapshotHeight != null) result.snapshotHeight = snapshotHeight;
    if (snapshotSizeBytes != null) result.snapshotSizeBytes = snapshotSizeBytes;
    if (pendingPeer != null) result.pendingPeer = pendingPeer;
    if (userManagedConf != null) result.userManagedConf = userManagedConf;
    return result;
  }

  GetPendingNetworkGenerationResponse._();

  factory GetPendingNetworkGenerationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPendingNetworkGenerationResponse()..mergeFromBuffer(data, registry);
  factory GetPendingNetworkGenerationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPendingNetworkGenerationResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPendingNetworkGenerationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetPendingNetworkGenerationResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'currentNetworkId')
    ..aOS(2, _omitFieldNames ? '' : 'pendingNetworkId')
    ..aInt64(3, _omitFieldNames ? '' : 'snapshotHeight')
    ..aInt64(4, _omitFieldNames ? '' : 'snapshotSizeBytes')
    ..aOS(5, _omitFieldNames ? '' : 'pendingPeer')
    ..aOB(6, _omitFieldNames ? '' : 'userManagedConf')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingNetworkGenerationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPendingNetworkGenerationResponse copyWith(void Function(GetPendingNetworkGenerationResponse) updates) =>
      super.copyWith((message) => updates(message as GetPendingNetworkGenerationResponse))
          as GetPendingNetworkGenerationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetPendingNetworkGenerationResponse() / GetPendingNetworkGenerationResponse.new instead')
  static GetPendingNetworkGenerationResponse create() => GetPendingNetworkGenerationResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetPendingNetworkGenerationResponse._();
  @$core.override
  GetPendingNetworkGenerationResponse createEmptyInstance() => GetPendingNetworkGenerationResponse._();
  @$core.pragma('dart2js:noInline')
  static GetPendingNetworkGenerationResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPendingNetworkGenerationResponse>(
          GetPendingNetworkGenerationResponse.$_createMessage);
  static GetPendingNetworkGenerationResponse? _defaultInstance;

  /// The eCash network this install runs now, and the newer one published,
  /// empty when already current.
  @$pb.TagNumber(1)
  $core.String get currentNetworkId => $_getSZ(0);
  @$pb.TagNumber(1)
  set currentNetworkId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCurrentNetworkId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCurrentNetworkId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pendingNetworkId => $_getSZ(1);
  @$pb.TagNumber(2)
  set pendingNetworkId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPendingNetworkId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPendingNetworkId() => $_clearField(2);

  /// The new network's UTXO snapshot, which the switch syncs from. Zero height
  /// means none is published.
  @$pb.TagNumber(3)
  $fixnum.Int64 get snapshotHeight => $_getI64(2);
  @$pb.TagNumber(3)
  set snapshotHeight($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSnapshotHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearSnapshotHeight() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get snapshotSizeBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set snapshotSizeBytes($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSnapshotSizeBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearSnapshotSizeBytes() => $_clearField(4);

  /// The new network's seed node, for the manual switch instructions.
  @$pb.TagNumber(5)
  $core.String get pendingPeer => $_getSZ(4);
  @$pb.TagNumber(5)
  set pendingPeer($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPendingPeer() => $_has(4);
  @$pb.TagNumber(5)
  void clearPendingPeer() => $_clearField(5);

  /// True when the user's own bitcoin.conf names the network. The switch cannot
  /// be made here — the prompt spells out what to change instead.
  @$pb.TagNumber(6)
  $core.bool get userManagedConf => $_getBF(5);
  @$pb.TagNumber(6)
  set userManagedConf($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUserManagedConf() => $_has(5);
  @$pb.TagNumber(6)
  void clearUserManagedConf() => $_clearField(6);
}

class ConfirmPendingNetworkGenerationRequest extends $pb.GeneratedMessage {
  factory ConfirmPendingNetworkGenerationRequest() => ConfirmPendingNetworkGenerationRequest._();

  ConfirmPendingNetworkGenerationRequest._();

  factory ConfirmPendingNetworkGenerationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConfirmPendingNetworkGenerationRequest()..mergeFromBuffer(data, registry);
  factory ConfirmPendingNetworkGenerationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConfirmPendingNetworkGenerationRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConfirmPendingNetworkGenerationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ConfirmPendingNetworkGenerationRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmPendingNetworkGenerationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmPendingNetworkGenerationRequest copyWith(void Function(ConfirmPendingNetworkGenerationRequest) updates) =>
      super.copyWith((message) => updates(message as ConfirmPendingNetworkGenerationRequest))
          as ConfirmPendingNetworkGenerationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConfirmPendingNetworkGenerationRequest() / ConfirmPendingNetworkGenerationRequest.new instead')
  static ConfirmPendingNetworkGenerationRequest create() => ConfirmPendingNetworkGenerationRequest._();
  static $pb.GeneratedMessage $_createMessage() => ConfirmPendingNetworkGenerationRequest._();
  @$core.override
  ConfirmPendingNetworkGenerationRequest createEmptyInstance() => ConfirmPendingNetworkGenerationRequest._();
  @$core.pragma('dart2js:noInline')
  static ConfirmPendingNetworkGenerationRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConfirmPendingNetworkGenerationRequest>(
          ConfirmPendingNetworkGenerationRequest.$_createMessage);
  static ConfirmPendingNetworkGenerationRequest? _defaultInstance;
}

class ConfirmPendingNetworkGenerationResponse extends $pb.GeneratedMessage {
  factory ConfirmPendingNetworkGenerationResponse() => ConfirmPendingNetworkGenerationResponse._();

  ConfirmPendingNetworkGenerationResponse._();

  factory ConfirmPendingNetworkGenerationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConfirmPendingNetworkGenerationResponse()..mergeFromBuffer(data, registry);
  factory ConfirmPendingNetworkGenerationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConfirmPendingNetworkGenerationResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConfirmPendingNetworkGenerationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ConfirmPendingNetworkGenerationResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmPendingNetworkGenerationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmPendingNetworkGenerationResponse copyWith(void Function(ConfirmPendingNetworkGenerationResponse) updates) =>
      super.copyWith((message) => updates(message as ConfirmPendingNetworkGenerationResponse))
          as ConfirmPendingNetworkGenerationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ConfirmPendingNetworkGenerationResponse() / ConfirmPendingNetworkGenerationResponse.new instead')
  static ConfirmPendingNetworkGenerationResponse create() => ConfirmPendingNetworkGenerationResponse._();
  static $pb.GeneratedMessage $_createMessage() => ConfirmPendingNetworkGenerationResponse._();
  @$core.override
  ConfirmPendingNetworkGenerationResponse createEmptyInstance() => ConfirmPendingNetworkGenerationResponse._();
  @$core.pragma('dart2js:noInline')
  static ConfirmPendingNetworkGenerationResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConfirmPendingNetworkGenerationResponse>(
          ConfirmPendingNetworkGenerationResponse.$_createMessage);
  static ConfirmPendingNetworkGenerationResponse? _defaultInstance;
}

class ShutdownAllRequest extends $pb.GeneratedMessage {
  factory ShutdownAllRequest({
    $core.bool? force,
  }) {
    final result = ShutdownAllRequest._();
    if (force != null) result.force = force;
    return result;
  }

  ShutdownAllRequest._();

  factory ShutdownAllRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShutdownAllRequest()..mergeFromBuffer(data, registry);
  factory ShutdownAllRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShutdownAllRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ShutdownAllRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ShutdownAllRequest.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'force')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShutdownAllRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShutdownAllRequest copyWith(void Function(ShutdownAllRequest) updates) =>
      super.copyWith((message) => updates(message as ShutdownAllRequest)) as ShutdownAllRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ShutdownAllRequest() / ShutdownAllRequest.new instead')
  static ShutdownAllRequest create() => ShutdownAllRequest._();
  static $pb.GeneratedMessage $_createMessage() => ShutdownAllRequest._();
  @$core.override
  ShutdownAllRequest createEmptyInstance() => ShutdownAllRequest._();
  @$core.pragma('dart2js:noInline')
  static ShutdownAllRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShutdownAllRequest>(ShutdownAllRequest.$_createMessage);
  static ShutdownAllRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get force => $_getBF(0);
  @$pb.TagNumber(1)
  set force($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasForce() => $_has(0);
  @$pb.TagNumber(1)
  void clearForce() => $_clearField(1);
}

class ShutdownAllResponse extends $pb.GeneratedMessage {
  factory ShutdownAllResponse({
    $core.int? totalCount,
    $core.int? completedCount,
    $core.String? currentBinary,
    $core.bool? done,
    $core.String? error,
  }) {
    final result = ShutdownAllResponse._();
    if (totalCount != null) result.totalCount = totalCount;
    if (completedCount != null) result.completedCount = completedCount;
    if (currentBinary != null) result.currentBinary = currentBinary;
    if (done != null) result.done = done;
    if (error != null) result.error = error;
    return result;
  }

  ShutdownAllResponse._();

  factory ShutdownAllResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShutdownAllResponse()..mergeFromBuffer(data, registry);
  factory ShutdownAllResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShutdownAllResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ShutdownAllResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ShutdownAllResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'totalCount')
    ..aI(2, _omitFieldNames ? '' : 'completedCount')
    ..aOS(3, _omitFieldNames ? '' : 'currentBinary')
    ..aOB(4, _omitFieldNames ? '' : 'done')
    ..aOS(5, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShutdownAllResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShutdownAllResponse copyWith(void Function(ShutdownAllResponse) updates) =>
      super.copyWith((message) => updates(message as ShutdownAllResponse)) as ShutdownAllResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ShutdownAllResponse() / ShutdownAllResponse.new instead')
  static ShutdownAllResponse create() => ShutdownAllResponse._();
  static $pb.GeneratedMessage $_createMessage() => ShutdownAllResponse._();
  @$core.override
  ShutdownAllResponse createEmptyInstance() => ShutdownAllResponse._();
  @$core.pragma('dart2js:noInline')
  static ShutdownAllResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShutdownAllResponse>(ShutdownAllResponse.$_createMessage);
  static ShutdownAllResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get totalCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set totalCount($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalCount() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get completedCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set completedCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCompletedCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCompletedCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get currentBinary => $_getSZ(2);
  @$pb.TagNumber(3)
  set currentBinary($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCurrentBinary() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrentBinary() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get done => $_getBF(3);
  @$pb.TagNumber(4)
  set done($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDone() => $_has(3);
  @$pb.TagNumber(4)
  void clearDone() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get error => $_getSZ(4);
  @$pb.TagNumber(5)
  set error($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasError() => $_has(4);
  @$pb.TagNumber(5)
  void clearError() => $_clearField(5);
}

class GetBTCPriceRequest extends $pb.GeneratedMessage {
  factory GetBTCPriceRequest() => GetBTCPriceRequest._();

  GetBTCPriceRequest._();

  factory GetBTCPriceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBTCPriceRequest()..mergeFromBuffer(data, registry);
  factory GetBTCPriceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBTCPriceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBTCPriceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetBTCPriceRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBTCPriceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBTCPriceRequest copyWith(void Function(GetBTCPriceRequest) updates) =>
      super.copyWith((message) => updates(message as GetBTCPriceRequest)) as GetBTCPriceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBTCPriceRequest() / GetBTCPriceRequest.new instead')
  static GetBTCPriceRequest create() => GetBTCPriceRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBTCPriceRequest._();
  @$core.override
  GetBTCPriceRequest createEmptyInstance() => GetBTCPriceRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBTCPriceRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBTCPriceRequest>(GetBTCPriceRequest.$_createMessage);
  static GetBTCPriceRequest? _defaultInstance;
}

class GetBTCPriceResponse extends $pb.GeneratedMessage {
  factory GetBTCPriceResponse({
    $core.double? btcusd,
    $fixnum.Int64? lastUpdatedUnix,
  }) {
    final result = GetBTCPriceResponse._();
    if (btcusd != null) result.btcusd = btcusd;
    if (lastUpdatedUnix != null) result.lastUpdatedUnix = lastUpdatedUnix;
    return result;
  }

  GetBTCPriceResponse._();

  factory GetBTCPriceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBTCPriceResponse()..mergeFromBuffer(data, registry);
  factory GetBTCPriceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBTCPriceResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBTCPriceResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetBTCPriceResponse.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'btcusd')
    ..aInt64(2, _omitFieldNames ? '' : 'lastUpdatedUnix')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBTCPriceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBTCPriceResponse copyWith(void Function(GetBTCPriceResponse) updates) =>
      super.copyWith((message) => updates(message as GetBTCPriceResponse)) as GetBTCPriceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBTCPriceResponse() / GetBTCPriceResponse.new instead')
  static GetBTCPriceResponse create() => GetBTCPriceResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBTCPriceResponse._();
  @$core.override
  GetBTCPriceResponse createEmptyInstance() => GetBTCPriceResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBTCPriceResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBTCPriceResponse>(GetBTCPriceResponse.$_createMessage);
  static GetBTCPriceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get btcusd => $_getN(0);
  @$pb.TagNumber(1)
  set btcusd($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBtcusd() => $_has(0);
  @$pb.TagNumber(1)
  void clearBtcusd() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get lastUpdatedUnix => $_getI64(1);
  @$pb.TagNumber(2)
  set lastUpdatedUnix($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLastUpdatedUnix() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastUpdatedUnix() => $_clearField(2);
}

class GetMainchainBlockchainInfoRequest extends $pb.GeneratedMessage {
  factory GetMainchainBlockchainInfoRequest() => GetMainchainBlockchainInfoRequest._();

  GetMainchainBlockchainInfoRequest._();

  factory GetMainchainBlockchainInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMainchainBlockchainInfoRequest()..mergeFromBuffer(data, registry);
  factory GetMainchainBlockchainInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMainchainBlockchainInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMainchainBlockchainInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetMainchainBlockchainInfoRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMainchainBlockchainInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMainchainBlockchainInfoRequest copyWith(void Function(GetMainchainBlockchainInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetMainchainBlockchainInfoRequest))
          as GetMainchainBlockchainInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetMainchainBlockchainInfoRequest() / GetMainchainBlockchainInfoRequest.new instead')
  static GetMainchainBlockchainInfoRequest create() => GetMainchainBlockchainInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetMainchainBlockchainInfoRequest._();
  @$core.override
  GetMainchainBlockchainInfoRequest createEmptyInstance() => GetMainchainBlockchainInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetMainchainBlockchainInfoRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMainchainBlockchainInfoRequest>(
          GetMainchainBlockchainInfoRequest.$_createMessage);
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
    final result = GetMainchainBlockchainInfoResponse._();
    if (chain != null) result.chain = chain;
    if (blocks != null) result.blocks = blocks;
    if (headers != null) result.headers = headers;
    if (bestBlockHash != null) result.bestBlockHash = bestBlockHash;
    if (difficulty != null) result.difficulty = difficulty;
    if (time != null) result.time = time;
    if (medianTime != null) result.medianTime = medianTime;
    if (verificationProgress != null) result.verificationProgress = verificationProgress;
    if (initialBlockDownload != null) result.initialBlockDownload = initialBlockDownload;
    if (chainWork != null) result.chainWork = chainWork;
    if (sizeOnDisk != null) result.sizeOnDisk = sizeOnDisk;
    if (pruned != null) result.pruned = pruned;
    return result;
  }

  GetMainchainBlockchainInfoResponse._();

  factory GetMainchainBlockchainInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMainchainBlockchainInfoResponse()..mergeFromBuffer(data, registry);
  factory GetMainchainBlockchainInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMainchainBlockchainInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMainchainBlockchainInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetMainchainBlockchainInfoResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..aI(2, _omitFieldNames ? '' : 'blocks')
    ..aI(3, _omitFieldNames ? '' : 'headers')
    ..aOS(4, _omitFieldNames ? '' : 'bestBlockHash')
    ..aD(5, _omitFieldNames ? '' : 'difficulty')
    ..aInt64(6, _omitFieldNames ? '' : 'time')
    ..aInt64(7, _omitFieldNames ? '' : 'medianTime')
    ..aD(8, _omitFieldNames ? '' : 'verificationProgress')
    ..aOB(9, _omitFieldNames ? '' : 'initialBlockDownload')
    ..aOS(10, _omitFieldNames ? '' : 'chainWork')
    ..aInt64(11, _omitFieldNames ? '' : 'sizeOnDisk')
    ..aOB(12, _omitFieldNames ? '' : 'pruned')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMainchainBlockchainInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMainchainBlockchainInfoResponse copyWith(void Function(GetMainchainBlockchainInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetMainchainBlockchainInfoResponse))
          as GetMainchainBlockchainInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetMainchainBlockchainInfoResponse() / GetMainchainBlockchainInfoResponse.new instead')
  static GetMainchainBlockchainInfoResponse create() => GetMainchainBlockchainInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetMainchainBlockchainInfoResponse._();
  @$core.override
  GetMainchainBlockchainInfoResponse createEmptyInstance() => GetMainchainBlockchainInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetMainchainBlockchainInfoResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMainchainBlockchainInfoResponse>(
          GetMainchainBlockchainInfoResponse.$_createMessage);
  static GetMainchainBlockchainInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get blocks => $_getIZ(1);
  @$pb.TagNumber(2)
  set blocks($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlocks() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlocks() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get headers => $_getIZ(2);
  @$pb.TagNumber(3)
  set headers($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeaders() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeaders() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get bestBlockHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set bestBlockHash($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBestBlockHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearBestBlockHash() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get difficulty => $_getN(4);
  @$pb.TagNumber(5)
  set difficulty($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDifficulty() => $_has(4);
  @$pb.TagNumber(5)
  void clearDifficulty() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get time => $_getI64(5);
  @$pb.TagNumber(6)
  set time($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearTime() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get medianTime => $_getI64(6);
  @$pb.TagNumber(7)
  set medianTime($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMedianTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearMedianTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get verificationProgress => $_getN(7);
  @$pb.TagNumber(8)
  set verificationProgress($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasVerificationProgress() => $_has(7);
  @$pb.TagNumber(8)
  void clearVerificationProgress() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get initialBlockDownload => $_getBF(8);
  @$pb.TagNumber(9)
  set initialBlockDownload($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasInitialBlockDownload() => $_has(8);
  @$pb.TagNumber(9)
  void clearInitialBlockDownload() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get chainWork => $_getSZ(9);
  @$pb.TagNumber(10)
  set chainWork($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasChainWork() => $_has(9);
  @$pb.TagNumber(10)
  void clearChainWork() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get sizeOnDisk => $_getI64(10);
  @$pb.TagNumber(11)
  set sizeOnDisk($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSizeOnDisk() => $_has(10);
  @$pb.TagNumber(11)
  void clearSizeOnDisk() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get pruned => $_getBF(11);
  @$pb.TagNumber(12)
  set pruned($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPruned() => $_has(11);
  @$pb.TagNumber(12)
  void clearPruned() => $_clearField(12);
}

class GetEnforcerBlockchainInfoRequest extends $pb.GeneratedMessage {
  factory GetEnforcerBlockchainInfoRequest() => GetEnforcerBlockchainInfoRequest._();

  GetEnforcerBlockchainInfoRequest._();

  factory GetEnforcerBlockchainInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetEnforcerBlockchainInfoRequest()..mergeFromBuffer(data, registry);
  factory GetEnforcerBlockchainInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetEnforcerBlockchainInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetEnforcerBlockchainInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetEnforcerBlockchainInfoRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEnforcerBlockchainInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEnforcerBlockchainInfoRequest copyWith(void Function(GetEnforcerBlockchainInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetEnforcerBlockchainInfoRequest))
          as GetEnforcerBlockchainInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetEnforcerBlockchainInfoRequest() / GetEnforcerBlockchainInfoRequest.new instead')
  static GetEnforcerBlockchainInfoRequest create() => GetEnforcerBlockchainInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetEnforcerBlockchainInfoRequest._();
  @$core.override
  GetEnforcerBlockchainInfoRequest createEmptyInstance() => GetEnforcerBlockchainInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetEnforcerBlockchainInfoRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetEnforcerBlockchainInfoRequest>(
          GetEnforcerBlockchainInfoRequest.$_createMessage);
  static GetEnforcerBlockchainInfoRequest? _defaultInstance;
}

class GetEnforcerBlockchainInfoResponse extends $pb.GeneratedMessage {
  factory GetEnforcerBlockchainInfoResponse({
    $core.int? blocks,
    $core.int? headers,
    $fixnum.Int64? time,
  }) {
    final result = GetEnforcerBlockchainInfoResponse._();
    if (blocks != null) result.blocks = blocks;
    if (headers != null) result.headers = headers;
    if (time != null) result.time = time;
    return result;
  }

  GetEnforcerBlockchainInfoResponse._();

  factory GetEnforcerBlockchainInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetEnforcerBlockchainInfoResponse()..mergeFromBuffer(data, registry);
  factory GetEnforcerBlockchainInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetEnforcerBlockchainInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetEnforcerBlockchainInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetEnforcerBlockchainInfoResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'blocks')
    ..aI(2, _omitFieldNames ? '' : 'headers')
    ..aInt64(3, _omitFieldNames ? '' : 'time')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEnforcerBlockchainInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEnforcerBlockchainInfoResponse copyWith(void Function(GetEnforcerBlockchainInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetEnforcerBlockchainInfoResponse))
          as GetEnforcerBlockchainInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetEnforcerBlockchainInfoResponse() / GetEnforcerBlockchainInfoResponse.new instead')
  static GetEnforcerBlockchainInfoResponse create() => GetEnforcerBlockchainInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetEnforcerBlockchainInfoResponse._();
  @$core.override
  GetEnforcerBlockchainInfoResponse createEmptyInstance() => GetEnforcerBlockchainInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetEnforcerBlockchainInfoResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetEnforcerBlockchainInfoResponse>(
          GetEnforcerBlockchainInfoResponse.$_createMessage);
  static GetEnforcerBlockchainInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get blocks => $_getIZ(0);
  @$pb.TagNumber(1)
  set blocks($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlocks() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlocks() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get headers => $_getIZ(1);
  @$pb.TagNumber(2)
  set headers($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeaders() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeaders() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get time => $_getI64(2);
  @$pb.TagNumber(3)
  set time($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearTime() => $_clearField(3);
}

class GetSyncStatusRequest extends $pb.GeneratedMessage {
  factory GetSyncStatusRequest() => GetSyncStatusRequest._();

  GetSyncStatusRequest._();

  factory GetSyncStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSyncStatusRequest()..mergeFromBuffer(data, registry);
  factory GetSyncStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSyncStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSyncStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetSyncStatusRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSyncStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSyncStatusRequest copyWith(void Function(GetSyncStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetSyncStatusRequest)) as GetSyncStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSyncStatusRequest() / GetSyncStatusRequest.new instead')
  static GetSyncStatusRequest create() => GetSyncStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetSyncStatusRequest._();
  @$core.override
  GetSyncStatusRequest createEmptyInstance() => GetSyncStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static GetSyncStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSyncStatusRequest>(GetSyncStatusRequest.$_createMessage);
  static GetSyncStatusRequest? _defaultInstance;
}

class GetSyncStatusResponse extends $pb.GeneratedMessage {
  factory GetSyncStatusResponse({
    ChainSync? mainchain,
    ChainSync? enforcer,
    $core.Iterable<SidechainStatus>? sidechains,
    $core.String? walletSyncStatus,
    ChainSync? chainSource,
  }) {
    final result = GetSyncStatusResponse._();
    if (mainchain != null) result.mainchain = mainchain;
    if (enforcer != null) result.enforcer = enforcer;
    if (sidechains != null) result.sidechains.addAll(sidechains);
    if (walletSyncStatus != null) result.walletSyncStatus = walletSyncStatus;
    if (chainSource != null) result.chainSource = chainSource;
    return result;
  }

  GetSyncStatusResponse._();

  factory GetSyncStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSyncStatusResponse()..mergeFromBuffer(data, registry);
  factory GetSyncStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSyncStatusResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSyncStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetSyncStatusResponse.$_createMessage)
    ..aOM<ChainSync>(1, _omitFieldNames ? '' : 'mainchain', subBuilder: ChainSync.$_createMessage)
    ..aOM<ChainSync>(2, _omitFieldNames ? '' : 'enforcer', subBuilder: ChainSync.$_createMessage)
    ..pPM<SidechainStatus>(3, _omitFieldNames ? '' : 'sidechains', subBuilder: SidechainStatus.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'walletSyncStatus')
    ..aOM<ChainSync>(6, _omitFieldNames ? '' : 'chainSource', subBuilder: ChainSync.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSyncStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSyncStatusResponse copyWith(void Function(GetSyncStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetSyncStatusResponse)) as GetSyncStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSyncStatusResponse() / GetSyncStatusResponse.new instead')
  static GetSyncStatusResponse create() => GetSyncStatusResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetSyncStatusResponse._();
  @$core.override
  GetSyncStatusResponse createEmptyInstance() => GetSyncStatusResponse._();
  @$core.pragma('dart2js:noInline')
  static GetSyncStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSyncStatusResponse>(GetSyncStatusResponse.$_createMessage);
  static GetSyncStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ChainSync get mainchain => $_getN(0);
  @$pb.TagNumber(1)
  set mainchain(ChainSync value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMainchain() => $_has(0);
  @$pb.TagNumber(1)
  void clearMainchain() => $_clearField(1);
  @$pb.TagNumber(1)
  ChainSync ensureMainchain() => $_ensure(0);

  @$pb.TagNumber(2)
  ChainSync get enforcer => $_getN(1);
  @$pb.TagNumber(2)
  set enforcer(ChainSync value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEnforcer() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnforcer() => $_clearField(2);
  @$pb.TagNumber(2)
  ChainSync ensureEnforcer() => $_ensure(1);

  /// All sidechains the orchestrator knows about. Always includes every
  /// configured sidechain — daemons that aren't running yet appear with
  /// their `sync.error` set so the UI can render a placeholder. While a
  /// sidechain is downloading, its sync.is_downloading is true and
  /// blocks/headers are MB downloaded / MB total.
  @$pb.TagNumber(3)
  $pb.PbList<SidechainStatus> get sidechains => $_getList(2);

  /// Non-empty while the active electrum wallet is scanning, e.g.
  /// "Scanning external addresses — 12 checked, 3 used". The bottom-nav sync
  /// display shows it alongside daemon sync status.
  @$pb.TagNumber(4)
  $core.String get walletSyncStatus => $_getSZ(3);
  @$pb.TagNumber(4)
  set walletSyncStatus($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWalletSyncStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearWalletSyncStatus() => $_clearField(4);

  /// Tip the wallet chain source reports (esplora or electrum). An electrum
  /// wallet runs no local node, so this is the only height it has.
  @$pb.TagNumber(6)
  ChainSync get chainSource => $_getN(4);
  @$pb.TagNumber(6)
  set chainSource(ChainSync value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasChainSource() => $_has(4);
  @$pb.TagNumber(6)
  void clearChainSource() => $_clearField(6);
  @$pb.TagNumber(6)
  ChainSync ensureChainSource() => $_ensure(4);
}

class SidechainStatus extends $pb.GeneratedMessage {
  factory SidechainStatus({
    SidechainType? type,
    ChainSync? sync,
  }) {
    final result = SidechainStatus._();
    if (type != null) result.type = type;
    if (sync != null) result.sync = sync;
    return result;
  }

  SidechainStatus._();

  factory SidechainStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SidechainStatus()..mergeFromBuffer(data, registry);
  factory SidechainStatus.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SidechainStatus()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SidechainStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: SidechainStatus.$_createMessage)
    ..aE<SidechainType>(1, _omitFieldNames ? '' : 'type', enumValues: SidechainType.values)
    ..aOM<ChainSync>(2, _omitFieldNames ? '' : 'sync', subBuilder: ChainSync.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SidechainStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SidechainStatus copyWith(void Function(SidechainStatus) updates) =>
      super.copyWith((message) => updates(message as SidechainStatus)) as SidechainStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SidechainStatus() / SidechainStatus.new instead')
  static SidechainStatus create() => SidechainStatus._();
  static $pb.GeneratedMessage $_createMessage() => SidechainStatus._();
  @$core.override
  SidechainStatus createEmptyInstance() => SidechainStatus._();
  @$core.pragma('dart2js:noInline')
  static SidechainStatus getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SidechainStatus>(SidechainStatus.$_createMessage);
  static SidechainStatus? _defaultInstance;

  @$pb.TagNumber(1)
  SidechainType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(SidechainType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  ChainSync get sync => $_getN(1);
  @$pb.TagNumber(2)
  set sync(ChainSync value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSync() => $_has(1);
  @$pb.TagNumber(2)
  void clearSync() => $_clearField(2);
  @$pb.TagNumber(2)
  ChainSync ensureSync() => $_ensure(1);
}

class ChainSync extends $pb.GeneratedMessage {
  factory ChainSync({
    $core.int? blocks,
    $core.int? headers,
    $fixnum.Int64? time,
    $core.String? error,
    $core.int? verifiedBlocks,
    $core.int? verifiedGoal,
    MainchainSyncPhase? mainchainSyncPhase,
    $core.int? mainchainTipHeight,
  }) {
    final result = ChainSync._();
    if (blocks != null) result.blocks = blocks;
    if (headers != null) result.headers = headers;
    if (time != null) result.time = time;
    if (error != null) result.error = error;
    if (verifiedBlocks != null) result.verifiedBlocks = verifiedBlocks;
    if (verifiedGoal != null) result.verifiedGoal = verifiedGoal;
    if (mainchainSyncPhase != null) result.mainchainSyncPhase = mainchainSyncPhase;
    if (mainchainTipHeight != null) result.mainchainTipHeight = mainchainTipHeight;
    return result;
  }

  ChainSync._();

  factory ChainSync.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChainSync()..mergeFromBuffer(data, registry);
  factory ChainSync.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChainSync()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChainSync',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ChainSync.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'blocks')
    ..aI(2, _omitFieldNames ? '' : 'headers')
    ..aInt64(3, _omitFieldNames ? '' : 'time')
    ..aOS(4, _omitFieldNames ? '' : 'error')
    ..aI(8, _omitFieldNames ? '' : 'verifiedBlocks')
    ..aI(9, _omitFieldNames ? '' : 'verifiedGoal')
    ..aE<MainchainSyncPhase>(10, _omitFieldNames ? '' : 'mainchainSyncPhase', enumValues: MainchainSyncPhase.values)
    ..aI(11, _omitFieldNames ? '' : 'mainchainTipHeight')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChainSync clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChainSync copyWith(void Function(ChainSync) updates) =>
      super.copyWith((message) => updates(message as ChainSync)) as ChainSync;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChainSync() / ChainSync.new instead')
  static ChainSync create() => ChainSync._();
  static $pb.GeneratedMessage $_createMessage() => ChainSync._();
  @$core.override
  ChainSync createEmptyInstance() => ChainSync._();
  @$core.pragma('dart2js:noInline')
  static ChainSync getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChainSync>(ChainSync.$_createMessage);
  static ChainSync? _defaultInstance;

  /// Current tip height for the chain.
  @$pb.TagNumber(1)
  $core.int get blocks => $_getIZ(0);
  @$pb.TagNumber(1)
  set blocks($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlocks() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlocks() => $_clearField(1);

  /// bitcoind's header count, or this daemon's own headers if mainchain is
  /// unavailable.
  @$pb.TagNumber(2)
  $core.int get headers => $_getIZ(1);
  @$pb.TagNumber(2)
  set headers($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeaders() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeaders() => $_clearField(2);

  /// Block tip timestamp (unix seconds), 0 if no tip yet.
  @$pb.TagNumber(3)
  $fixnum.Int64 get time => $_getI64(2);
  @$pb.TagNumber(3)
  set time($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearTime() => $_clearField(3);

  /// Empty on success; otherwise a short description of why this daemon's
  /// sync info isn't available (not running, RPC error, etc.).
  @$pb.TagNumber(4)
  $core.String get error => $_getSZ(3);
  @$pb.TagNumber(4)
  set error($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => $_clearField(4);

  /// Height Core verified from genesis, 0 when it loaded no UTXO snapshot.
  /// Behind a snapshot, blocks reaches the tip long before this does.
  /// Mainchain only.
  @$pb.TagNumber(8)
  $core.int get verifiedBlocks => $_getIZ(4);
  @$pb.TagNumber(8)
  set verifiedBlocks($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(8)
  $core.bool hasVerifiedBlocks() => $_has(4);
  @$pb.TagNumber(8)
  void clearVerifiedBlocks() => $_clearField(8);

  /// Height verified_blocks counts towards: the block the snapshot commits to,
  /// not the chain tip. 0 when no snapshot is loaded. Mainchain only.
  @$pb.TagNumber(9)
  $core.int get verifiedGoal => $_getIZ(5);
  @$pb.TagNumber(9)
  set verifiedGoal($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(9)
  $core.bool hasVerifiedGoal() => $_has(5);
  @$pb.TagNumber(9)
  void clearVerifiedGoal() => $_clearField(9);

  /// The mainchain step a sidechain node takes before it syncs its own
  /// blocks. While set, blocks and headers are that step's done and total.
  @$pb.TagNumber(10)
  MainchainSyncPhase get mainchainSyncPhase => $_getN(6);
  @$pb.TagNumber(10)
  set mainchainSyncPhase(MainchainSyncPhase value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasMainchainSyncPhase() => $_has(6);
  @$pb.TagNumber(10)
  void clearMainchainSyncPhase() => $_clearField(10);

  /// Mainchain tip height the mainchain_sync_phase moves to, 0 when unset.
  @$pb.TagNumber(11)
  $core.int get mainchainTipHeight => $_getIZ(7);
  @$pb.TagNumber(11)
  set mainchainTipHeight($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(11)
  $core.bool hasMainchainTipHeight() => $_has(7);
  @$pb.TagNumber(11)
  void clearMainchainTipHeight() => $_clearField(11);
}

class GetDownloadStatusRequest extends $pb.GeneratedMessage {
  factory GetDownloadStatusRequest() => GetDownloadStatusRequest._();

  GetDownloadStatusRequest._();

  factory GetDownloadStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDownloadStatusRequest()..mergeFromBuffer(data, registry);
  factory GetDownloadStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDownloadStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDownloadStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetDownloadStatusRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadStatusRequest copyWith(void Function(GetDownloadStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetDownloadStatusRequest)) as GetDownloadStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetDownloadStatusRequest() / GetDownloadStatusRequest.new instead')
  static GetDownloadStatusRequest create() => GetDownloadStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetDownloadStatusRequest._();
  @$core.override
  GetDownloadStatusRequest createEmptyInstance() => GetDownloadStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static GetDownloadStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDownloadStatusRequest>(GetDownloadStatusRequest.$_createMessage);
  static GetDownloadStatusRequest? _defaultInstance;
}

class GetDownloadStatusResponse extends $pb.GeneratedMessage {
  factory GetDownloadStatusResponse({
    $core.Iterable<DownloadStatus>? downloads,
  }) {
    final result = GetDownloadStatusResponse._();
    if (downloads != null) result.downloads.addAll(downloads);
    return result;
  }

  GetDownloadStatusResponse._();

  factory GetDownloadStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDownloadStatusResponse()..mergeFromBuffer(data, registry);
  factory GetDownloadStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDownloadStatusResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDownloadStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetDownloadStatusResponse.$_createMessage)
    ..pPM<DownloadStatus>(1, _omitFieldNames ? '' : 'downloads', subBuilder: DownloadStatus.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadStatusResponse copyWith(void Function(GetDownloadStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetDownloadStatusResponse)) as GetDownloadStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetDownloadStatusResponse() / GetDownloadStatusResponse.new instead')
  static GetDownloadStatusResponse create() => GetDownloadStatusResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetDownloadStatusResponse._();
  @$core.override
  GetDownloadStatusResponse createEmptyInstance() => GetDownloadStatusResponse._();
  @$core.pragma('dart2js:noInline')
  static GetDownloadStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDownloadStatusResponse>(GetDownloadStatusResponse.$_createMessage);
  static GetDownloadStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DownloadStatus> get downloads => $_getList(0);
}

class DownloadStatus extends $pb.GeneratedMessage {
  factory DownloadStatus({
    BinaryType? binary,
    $fixnum.Int64? mbDownloaded,
    $fixnum.Int64? mbTotal,
    $core.String? message,
  }) {
    final result = DownloadStatus._();
    if (binary != null) result.binary = binary;
    if (mbDownloaded != null) result.mbDownloaded = mbDownloaded;
    if (mbTotal != null) result.mbTotal = mbTotal;
    if (message != null) result.message = message;
    return result;
  }

  DownloadStatus._();

  factory DownloadStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DownloadStatus()..mergeFromBuffer(data, registry);
  factory DownloadStatus.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DownloadStatus()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: DownloadStatus.$_createMessage)
    ..aE<BinaryType>(1, _omitFieldNames ? '' : 'binary', enumValues: BinaryType.values)
    ..aInt64(2, _omitFieldNames ? '' : 'mbDownloaded')
    ..aInt64(3, _omitFieldNames ? '' : 'mbTotal')
    ..aOS(4, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadStatus copyWith(void Function(DownloadStatus) updates) =>
      super.copyWith((message) => updates(message as DownloadStatus)) as DownloadStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DownloadStatus() / DownloadStatus.new instead')
  static DownloadStatus create() => DownloadStatus._();
  static $pb.GeneratedMessage $_createMessage() => DownloadStatus._();
  @$core.override
  DownloadStatus createEmptyInstance() => DownloadStatus._();
  @$core.pragma('dart2js:noInline')
  static DownloadStatus getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadStatus>(DownloadStatus.$_createMessage);
  static DownloadStatus? _defaultInstance;

  /// Typed identifier for the binary being downloaded.
  @$pb.TagNumber(1)
  BinaryType get binary => $_getN(0);
  @$pb.TagNumber(1)
  set binary(BinaryType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBinary() => $_has(0);
  @$pb.TagNumber(1)
  void clearBinary() => $_clearField(1);

  /// Megabytes downloaded so far. Source of truth lives in DownloadManager.
  @$pb.TagNumber(2)
  $fixnum.Int64 get mbDownloaded => $_getI64(1);
  @$pb.TagNumber(2)
  set mbDownloaded($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMbDownloaded() => $_has(1);
  @$pb.TagNumber(2)
  void clearMbDownloaded() => $_clearField(2);

  /// Total size in megabytes, or -1 when the server hasn't reported a
  /// Content-Length yet.
  @$pb.TagNumber(3)
  $fixnum.Int64 get mbTotal => $_getI64(2);
  @$pb.TagNumber(3)
  set mbTotal($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMbTotal() => $_has(2);
  @$pb.TagNumber(3)
  void clearMbTotal() => $_clearField(3);

  /// Optional human-readable progress string ("verifying hash", ...).
  @$pb.TagNumber(4)
  $core.String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => $_clearField(4);
}

class GetMainchainBalanceRequest extends $pb.GeneratedMessage {
  factory GetMainchainBalanceRequest() => GetMainchainBalanceRequest._();

  GetMainchainBalanceRequest._();

  factory GetMainchainBalanceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMainchainBalanceRequest()..mergeFromBuffer(data, registry);
  factory GetMainchainBalanceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMainchainBalanceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMainchainBalanceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetMainchainBalanceRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMainchainBalanceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMainchainBalanceRequest copyWith(void Function(GetMainchainBalanceRequest) updates) =>
      super.copyWith((message) => updates(message as GetMainchainBalanceRequest)) as GetMainchainBalanceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetMainchainBalanceRequest() / GetMainchainBalanceRequest.new instead')
  static GetMainchainBalanceRequest create() => GetMainchainBalanceRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetMainchainBalanceRequest._();
  @$core.override
  GetMainchainBalanceRequest createEmptyInstance() => GetMainchainBalanceRequest._();
  @$core.pragma('dart2js:noInline')
  static GetMainchainBalanceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMainchainBalanceRequest>(GetMainchainBalanceRequest.$_createMessage);
  static GetMainchainBalanceRequest? _defaultInstance;
}

class GetMainchainBalanceResponse extends $pb.GeneratedMessage {
  factory GetMainchainBalanceResponse({
    $core.double? confirmed,
    $core.double? unconfirmed,
  }) {
    final result = GetMainchainBalanceResponse._();
    if (confirmed != null) result.confirmed = confirmed;
    if (unconfirmed != null) result.unconfirmed = unconfirmed;
    return result;
  }

  GetMainchainBalanceResponse._();

  factory GetMainchainBalanceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMainchainBalanceResponse()..mergeFromBuffer(data, registry);
  factory GetMainchainBalanceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMainchainBalanceResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMainchainBalanceResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetMainchainBalanceResponse.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'confirmed')
    ..aD(2, _omitFieldNames ? '' : 'unconfirmed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMainchainBalanceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMainchainBalanceResponse copyWith(void Function(GetMainchainBalanceResponse) updates) =>
      super.copyWith((message) => updates(message as GetMainchainBalanceResponse)) as GetMainchainBalanceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetMainchainBalanceResponse() / GetMainchainBalanceResponse.new instead')
  static GetMainchainBalanceResponse create() => GetMainchainBalanceResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetMainchainBalanceResponse._();
  @$core.override
  GetMainchainBalanceResponse createEmptyInstance() => GetMainchainBalanceResponse._();
  @$core.pragma('dart2js:noInline')
  static GetMainchainBalanceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMainchainBalanceResponse>(GetMainchainBalanceResponse.$_createMessage);
  static GetMainchainBalanceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get confirmed => $_getN(0);
  @$pb.TagNumber(1)
  set confirmed($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfirmed() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfirmed() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get unconfirmed => $_getN(1);
  @$pb.TagNumber(2)
  set unconfirmed($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUnconfirmed() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnconfirmed() => $_clearField(2);
}

class GetSidechainBalanceRequest extends $pb.GeneratedMessage {
  factory GetSidechainBalanceRequest({
    BinaryType? sidechain,
  }) {
    final result = GetSidechainBalanceRequest._();
    if (sidechain != null) result.sidechain = sidechain;
    return result;
  }

  GetSidechainBalanceRequest._();

  factory GetSidechainBalanceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainBalanceRequest()..mergeFromBuffer(data, registry);
  factory GetSidechainBalanceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainBalanceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainBalanceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetSidechainBalanceRequest.$_createMessage)
    ..aE<BinaryType>(1, _omitFieldNames ? '' : 'sidechain', enumValues: BinaryType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainBalanceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainBalanceRequest copyWith(void Function(GetSidechainBalanceRequest) updates) =>
      super.copyWith((message) => updates(message as GetSidechainBalanceRequest)) as GetSidechainBalanceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSidechainBalanceRequest() / GetSidechainBalanceRequest.new instead')
  static GetSidechainBalanceRequest create() => GetSidechainBalanceRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainBalanceRequest._();
  @$core.override
  GetSidechainBalanceRequest createEmptyInstance() => GetSidechainBalanceRequest._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainBalanceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSidechainBalanceRequest>(GetSidechainBalanceRequest.$_createMessage);
  static GetSidechainBalanceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain(BinaryType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => $_clearField(1);
}

class GetSidechainBalanceResponse extends $pb.GeneratedMessage {
  factory GetSidechainBalanceResponse({
    $fixnum.Int64? confirmedSats,
    $fixnum.Int64? pendingSats,
  }) {
    final result = GetSidechainBalanceResponse._();
    if (confirmedSats != null) result.confirmedSats = confirmedSats;
    if (pendingSats != null) result.pendingSats = pendingSats;
    return result;
  }

  GetSidechainBalanceResponse._();

  factory GetSidechainBalanceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainBalanceResponse()..mergeFromBuffer(data, registry);
  factory GetSidechainBalanceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainBalanceResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainBalanceResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetSidechainBalanceResponse.$_createMessage)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'confirmedSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'pendingSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainBalanceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainBalanceResponse copyWith(void Function(GetSidechainBalanceResponse) updates) =>
      super.copyWith((message) => updates(message as GetSidechainBalanceResponse)) as GetSidechainBalanceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSidechainBalanceResponse() / GetSidechainBalanceResponse.new instead')
  static GetSidechainBalanceResponse create() => GetSidechainBalanceResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainBalanceResponse._();
  @$core.override
  GetSidechainBalanceResponse createEmptyInstance() => GetSidechainBalanceResponse._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainBalanceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSidechainBalanceResponse>(GetSidechainBalanceResponse.$_createMessage);
  static GetSidechainBalanceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get confirmedSats => $_getI64(0);
  @$pb.TagNumber(1)
  set confirmedSats($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfirmedSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfirmedSats() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get pendingSats => $_getI64(1);
  @$pb.TagNumber(2)
  set pendingSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPendingSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearPendingSats() => $_clearField(2);
}

/// One binary plus the categories of its data to act on.
class SingleDeletion extends $pb.GeneratedMessage {
  factory SingleDeletion({
    BinaryType? binary,
    $core.Iterable<DeletionType>? deletions,
  }) {
    final result = SingleDeletion._();
    if (binary != null) result.binary = binary;
    if (deletions != null) result.deletions.addAll(deletions);
    return result;
  }

  SingleDeletion._();

  factory SingleDeletion.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SingleDeletion()..mergeFromBuffer(data, registry);
  factory SingleDeletion.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SingleDeletion()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SingleDeletion',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: SingleDeletion.$_createMessage)
    ..aE<BinaryType>(1, _omitFieldNames ? '' : 'binary', enumValues: BinaryType.values)
    ..pc<DeletionType>(2, _omitFieldNames ? '' : 'deletions', $pb.PbFieldType.KE,
        valueOf: DeletionType.valueOf,
        enumValues: DeletionType.values,
        defaultEnumValue: DeletionType.DELETION_TYPE_UNSPECIFIED)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SingleDeletion clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SingleDeletion copyWith(void Function(SingleDeletion) updates) =>
      super.copyWith((message) => updates(message as SingleDeletion)) as SingleDeletion;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SingleDeletion() / SingleDeletion.new instead')
  static SingleDeletion create() => SingleDeletion._();
  static $pb.GeneratedMessage $_createMessage() => SingleDeletion._();
  @$core.override
  SingleDeletion createEmptyInstance() => SingleDeletion._();
  @$core.pragma('dart2js:noInline')
  static SingleDeletion getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SingleDeletion>(SingleDeletion.$_createMessage);
  static SingleDeletion? _defaultInstance;

  @$pb.TagNumber(1)
  BinaryType get binary => $_getN(0);
  @$pb.TagNumber(1)
  set binary(BinaryType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBinary() => $_has(0);
  @$pb.TagNumber(1)
  void clearBinary() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<DeletionType> get deletions => $_getList(1);
}

class GatherFilesToDeleteRequest extends $pb.GeneratedMessage {
  factory GatherFilesToDeleteRequest({
    $core.Iterable<SingleDeletion>? items,
  }) {
    final result = GatherFilesToDeleteRequest._();
    if (items != null) result.items.addAll(items);
    return result;
  }

  GatherFilesToDeleteRequest._();

  factory GatherFilesToDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GatherFilesToDeleteRequest()..mergeFromBuffer(data, registry);
  factory GatherFilesToDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GatherFilesToDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GatherFilesToDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GatherFilesToDeleteRequest.$_createMessage)
    ..pPM<SingleDeletion>(1, _omitFieldNames ? '' : 'items', subBuilder: SingleDeletion.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GatherFilesToDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GatherFilesToDeleteRequest copyWith(void Function(GatherFilesToDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as GatherFilesToDeleteRequest)) as GatherFilesToDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GatherFilesToDeleteRequest() / GatherFilesToDeleteRequest.new instead')
  static GatherFilesToDeleteRequest create() => GatherFilesToDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => GatherFilesToDeleteRequest._();
  @$core.override
  GatherFilesToDeleteRequest createEmptyInstance() => GatherFilesToDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static GatherFilesToDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GatherFilesToDeleteRequest>(GatherFilesToDeleteRequest.$_createMessage);
  static GatherFilesToDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SingleDeletion> get items => $_getList(0);
}

class GatherFilesToDeleteResponse extends $pb.GeneratedMessage {
  factory GatherFilesToDeleteResponse({
    $core.Iterable<ResetFileInfo>? files,
  }) {
    final result = GatherFilesToDeleteResponse._();
    if (files != null) result.files.addAll(files);
    return result;
  }

  GatherFilesToDeleteResponse._();

  factory GatherFilesToDeleteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GatherFilesToDeleteResponse()..mergeFromBuffer(data, registry);
  factory GatherFilesToDeleteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GatherFilesToDeleteResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GatherFilesToDeleteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GatherFilesToDeleteResponse.$_createMessage)
    ..pPM<ResetFileInfo>(1, _omitFieldNames ? '' : 'files', subBuilder: ResetFileInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GatherFilesToDeleteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GatherFilesToDeleteResponse copyWith(void Function(GatherFilesToDeleteResponse) updates) =>
      super.copyWith((message) => updates(message as GatherFilesToDeleteResponse)) as GatherFilesToDeleteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GatherFilesToDeleteResponse() / GatherFilesToDeleteResponse.new instead')
  static GatherFilesToDeleteResponse create() => GatherFilesToDeleteResponse._();
  static $pb.GeneratedMessage $_createMessage() => GatherFilesToDeleteResponse._();
  @$core.override
  GatherFilesToDeleteResponse createEmptyInstance() => GatherFilesToDeleteResponse._();
  @$core.pragma('dart2js:noInline')
  static GatherFilesToDeleteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GatherFilesToDeleteResponse>(GatherFilesToDeleteResponse.$_createMessage);
  static GatherFilesToDeleteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ResetFileInfo> get files => $_getList(0);
}

class ResetFileInfo extends $pb.GeneratedMessage {
  factory ResetFileInfo({
    $core.String? path,
    DeletionType? deletionType,
    BinaryType? binary,
    $fixnum.Int64? sizeBytes,
    $core.bool? isDirectory,
  }) {
    final result = ResetFileInfo._();
    if (path != null) result.path = path;
    if (deletionType != null) result.deletionType = deletionType;
    if (binary != null) result.binary = binary;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (isDirectory != null) result.isDirectory = isDirectory;
    return result;
  }

  ResetFileInfo._();

  factory ResetFileInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResetFileInfo()..mergeFromBuffer(data, registry);
  factory ResetFileInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResetFileInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResetFileInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ResetFileInfo.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..aE<DeletionType>(2, _omitFieldNames ? '' : 'deletionType', enumValues: DeletionType.values)
    ..aE<BinaryType>(3, _omitFieldNames ? '' : 'binary', enumValues: BinaryType.values)
    ..aInt64(4, _omitFieldNames ? '' : 'sizeBytes')
    ..aOB(5, _omitFieldNames ? '' : 'isDirectory')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResetFileInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResetFileInfo copyWith(void Function(ResetFileInfo) updates) =>
      super.copyWith((message) => updates(message as ResetFileInfo)) as ResetFileInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ResetFileInfo() / ResetFileInfo.new instead')
  static ResetFileInfo create() => ResetFileInfo._();
  static $pb.GeneratedMessage $_createMessage() => ResetFileInfo._();
  @$core.override
  ResetFileInfo createEmptyInstance() => ResetFileInfo._();
  @$core.pragma('dart2js:noInline')
  static ResetFileInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ResetFileInfo>(ResetFileInfo.$_createMessage);
  static ResetFileInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);

  @$pb.TagNumber(2)
  DeletionType get deletionType => $_getN(1);
  @$pb.TagNumber(2)
  set deletionType(DeletionType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDeletionType() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeletionType() => $_clearField(2);

  @$pb.TagNumber(3)
  BinaryType get binary => $_getN(2);
  @$pb.TagNumber(3)
  set binary(BinaryType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBinary() => $_has(2);
  @$pb.TagNumber(3)
  void clearBinary() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sizeBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set sizeBytes($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSizeBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearSizeBytes() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isDirectory => $_getBF(4);
  @$pb.TagNumber(5)
  set isDirectory($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsDirectory() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsDirectory() => $_clearField(5);
}

class DeleteFilesRequest extends $pb.GeneratedMessage {
  factory DeleteFilesRequest({
    $core.Iterable<SingleDeletion>? items,
    $core.Iterable<$core.String>? except,
  }) {
    final result = DeleteFilesRequest._();
    if (items != null) result.items.addAll(items);
    if (except != null) result.except.addAll(except);
    return result;
  }

  DeleteFilesRequest._();

  factory DeleteFilesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteFilesRequest()..mergeFromBuffer(data, registry);
  factory DeleteFilesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteFilesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteFilesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: DeleteFilesRequest.$_createMessage)
    ..pPM<SingleDeletion>(1, _omitFieldNames ? '' : 'items', subBuilder: SingleDeletion.$_createMessage)
    ..pPS(2, _omitFieldNames ? '' : 'except')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFilesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFilesRequest copyWith(void Function(DeleteFilesRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteFilesRequest)) as DeleteFilesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeleteFilesRequest() / DeleteFilesRequest.new instead')
  static DeleteFilesRequest create() => DeleteFilesRequest._();
  static $pb.GeneratedMessage $_createMessage() => DeleteFilesRequest._();
  @$core.override
  DeleteFilesRequest createEmptyInstance() => DeleteFilesRequest._();
  @$core.pragma('dart2js:noInline')
  static DeleteFilesRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteFilesRequest>(DeleteFilesRequest.$_createMessage);
  static DeleteFilesRequest? _defaultInstance;

  /// What to delete: the same per-binary categories passed to GatherFilesToDelete.
  @$pb.TagNumber(1)
  $pb.PbList<SingleDeletion> get items => $_getList(0);

  /// Paths to omit from the deletion, e.g. files the user deselected.
  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get except => $_getList(1);
}

class DeleteFilesResponse extends $pb.GeneratedMessage {
  factory DeleteFilesResponse({
    $core.String? path,
    $core.String? error,
  }) {
    final result = DeleteFilesResponse._();
    if (path != null) result.path = path;
    if (error != null) result.error = error;
    return result;
  }

  DeleteFilesResponse._();

  factory DeleteFilesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteFilesResponse()..mergeFromBuffer(data, registry);
  factory DeleteFilesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteFilesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteFilesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: DeleteFilesResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFilesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFilesResponse copyWith(void Function(DeleteFilesResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteFilesResponse)) as DeleteFilesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeleteFilesResponse() / DeleteFilesResponse.new instead')
  static DeleteFilesResponse create() => DeleteFilesResponse._();
  static $pb.GeneratedMessage $_createMessage() => DeleteFilesResponse._();
  @$core.override
  DeleteFilesResponse createEmptyInstance() => DeleteFilesResponse._();
  @$core.pragma('dart2js:noInline')
  static DeleteFilesResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteFilesResponse>(DeleteFilesResponse.$_createMessage);
  static DeleteFilesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
}

class RejectBlockRequest extends $pb.GeneratedMessage {
  factory RejectBlockRequest({
    $core.String? blockHash,
    $core.int? enforcerWaitSeconds,
  }) {
    final result = RejectBlockRequest._();
    if (blockHash != null) result.blockHash = blockHash;
    if (enforcerWaitSeconds != null) result.enforcerWaitSeconds = enforcerWaitSeconds;
    return result;
  }

  RejectBlockRequest._();

  factory RejectBlockRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RejectBlockRequest()..mergeFromBuffer(data, registry);
  factory RejectBlockRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RejectBlockRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RejectBlockRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: RejectBlockRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'blockHash')
    ..aI(2, _omitFieldNames ? '' : 'enforcerWaitSeconds', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectBlockRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectBlockRequest copyWith(void Function(RejectBlockRequest) updates) =>
      super.copyWith((message) => updates(message as RejectBlockRequest)) as RejectBlockRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RejectBlockRequest() / RejectBlockRequest.new instead')
  static RejectBlockRequest create() => RejectBlockRequest._();
  static $pb.GeneratedMessage $_createMessage() => RejectBlockRequest._();
  @$core.override
  RejectBlockRequest createEmptyInstance() => RejectBlockRequest._();
  @$core.pragma('dart2js:noInline')
  static RejectBlockRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RejectBlockRequest>(RejectBlockRequest.$_createMessage);
  static RejectBlockRequest? _defaultInstance;

  /// Hash of the block Core must not follow. Core drops it and every block
  /// above it. A height names no block when two branches share it, so the
  /// hash is the only way to say which one.
  @$pb.TagNumber(1)
  $core.String get blockHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set blockHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => $_clearField(1);

  /// How long to wait for the enforcer to follow before its validator chain
  /// is deleted. Zero picks the default.
  @$pb.TagNumber(2)
  $core.int get enforcerWaitSeconds => $_getIZ(1);
  @$pb.TagNumber(2)
  set enforcerWaitSeconds($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnforcerWaitSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnforcerWaitSeconds() => $_clearField(2);
}

class RejectBlockResponse extends $pb.GeneratedMessage {
  factory RejectBlockResponse({
    $core.int? coreHeight,
    $core.String? coreTipHash,
    RejectOutcome? outcome,
    $core.int? enforcerHeight,
    $core.bool? enforcerRebuilt,
    $core.String? enforcerError,
    $core.bool? enforcerChecked,
  }) {
    final result = RejectBlockResponse._();
    if (coreHeight != null) result.coreHeight = coreHeight;
    if (coreTipHash != null) result.coreTipHash = coreTipHash;
    if (outcome != null) result.outcome = outcome;
    if (enforcerHeight != null) result.enforcerHeight = enforcerHeight;
    if (enforcerRebuilt != null) result.enforcerRebuilt = enforcerRebuilt;
    if (enforcerError != null) result.enforcerError = enforcerError;
    if (enforcerChecked != null) result.enforcerChecked = enforcerChecked;
    return result;
  }

  RejectBlockResponse._();

  factory RejectBlockResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RejectBlockResponse()..mergeFromBuffer(data, registry);
  factory RejectBlockResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RejectBlockResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RejectBlockResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: RejectBlockResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'coreHeight', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'coreTipHash')
    ..aE<RejectOutcome>(3, _omitFieldNames ? '' : 'outcome', enumValues: RejectOutcome.values)
    ..aI(4, _omitFieldNames ? '' : 'enforcerHeight', fieldType: $pb.PbFieldType.OU3)
    ..aOB(5, _omitFieldNames ? '' : 'enforcerRebuilt')
    ..aOS(6, _omitFieldNames ? '' : 'enforcerError')
    ..aOB(7, _omitFieldNames ? '' : 'enforcerChecked')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectBlockResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectBlockResponse copyWith(void Function(RejectBlockResponse) updates) =>
      super.copyWith((message) => updates(message as RejectBlockResponse)) as RejectBlockResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RejectBlockResponse() / RejectBlockResponse.new instead')
  static RejectBlockResponse create() => RejectBlockResponse._();
  static $pb.GeneratedMessage $_createMessage() => RejectBlockResponse._();
  @$core.override
  RejectBlockResponse createEmptyInstance() => RejectBlockResponse._();
  @$core.pragma('dart2js:noInline')
  static RejectBlockResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RejectBlockResponse>(RejectBlockResponse.$_createMessage);
  static RejectBlockResponse? _defaultInstance;

  /// Core's tip after the reject.
  @$pb.TagNumber(1)
  $core.int get coreHeight => $_getIZ(0);
  @$pb.TagNumber(1)
  set coreHeight($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCoreHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearCoreHeight() => $_clearField(1);

  /// Hash of that tip.
  @$pb.TagNumber(2)
  $core.String get coreTipHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set coreTipHash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCoreTipHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearCoreTipHash() => $_clearField(2);

  /// What the reject did to the chain Core follows.
  @$pb.TagNumber(3)
  RejectOutcome get outcome => $_getN(2);
  @$pb.TagNumber(3)
  set outcome(RejectOutcome value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOutcome() => $_has(2);
  @$pb.TagNumber(3)
  void clearOutcome() => $_clearField(3);

  /// The enforcer's tip afterwards. Zero when the enforcer is stopped.
  @$pb.TagNumber(4)
  $core.int get enforcerHeight => $_getIZ(3);
  @$pb.TagNumber(4)
  set enforcerHeight($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEnforcerHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearEnforcerHeight() => $_clearField(4);

  /// True when the enforcer did not follow, so its validator chain was deleted
  /// and it now rebuilds from the local Core.
  @$pb.TagNumber(5)
  $core.bool get enforcerRebuilt => $_getBF(4);
  @$pb.TagNumber(5)
  set enforcerRebuilt($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEnforcerRebuilt() => $_has(4);
  @$pb.TagNumber(5)
  void clearEnforcerRebuilt() => $_clearField(5);

  /// Empty on success; otherwise why the enforcer could not be brought back
  /// onto Core's chain. Core already moved, so the caller keeps its undo path.
  @$pb.TagNumber(6)
  $core.String get enforcerError => $_getSZ(5);
  @$pb.TagNumber(6)
  set enforcerError($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEnforcerError() => $_has(5);
  @$pb.TagNumber(6)
  void clearEnforcerError() => $_clearField(6);

  /// False when the enforcer was never asked, so enforcer_height carries no
  /// reading and must not be shown as one.
  @$pb.TagNumber(7)
  $core.bool get enforcerChecked => $_getBF(6);
  @$pb.TagNumber(7)
  set enforcerChecked($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEnforcerChecked() => $_has(6);
  @$pb.TagNumber(7)
  void clearEnforcerChecked() => $_clearField(7);
}

class AcceptBlockRequest extends $pb.GeneratedMessage {
  factory AcceptBlockRequest({
    $core.String? blockHash,
    $core.int? enforcerWaitSeconds,
  }) {
    final result = AcceptBlockRequest._();
    if (blockHash != null) result.blockHash = blockHash;
    if (enforcerWaitSeconds != null) result.enforcerWaitSeconds = enforcerWaitSeconds;
    return result;
  }

  AcceptBlockRequest._();

  factory AcceptBlockRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AcceptBlockRequest()..mergeFromBuffer(data, registry);
  factory AcceptBlockRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AcceptBlockRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AcceptBlockRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: AcceptBlockRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'blockHash')
    ..aI(2, _omitFieldNames ? '' : 'enforcerWaitSeconds', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptBlockRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptBlockRequest copyWith(void Function(AcceptBlockRequest) updates) =>
      super.copyWith((message) => updates(message as AcceptBlockRequest)) as AcceptBlockRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AcceptBlockRequest() / AcceptBlockRequest.new instead')
  static AcceptBlockRequest create() => AcceptBlockRequest._();
  static $pb.GeneratedMessage $_createMessage() => AcceptBlockRequest._();
  @$core.override
  AcceptBlockRequest createEmptyInstance() => AcceptBlockRequest._();
  @$core.pragma('dart2js:noInline')
  static AcceptBlockRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AcceptBlockRequest>(AcceptBlockRequest.$_createMessage);
  static AcceptBlockRequest? _defaultInstance;

  /// Hash of a block rejected earlier. Core clears the mark on it, on its
  /// ancestors, and on its descendants.
  @$pb.TagNumber(1)
  $core.String get blockHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set blockHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => $_clearField(1);

  /// How long to wait for the enforcer to follow before its validator chain
  /// is deleted. Zero picks the default.
  @$pb.TagNumber(2)
  $core.int get enforcerWaitSeconds => $_getIZ(1);
  @$pb.TagNumber(2)
  set enforcerWaitSeconds($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnforcerWaitSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnforcerWaitSeconds() => $_clearField(2);
}

class AcceptBlockResponse extends $pb.GeneratedMessage {
  factory AcceptBlockResponse({
    $core.int? coreHeight,
    $core.String? coreTipHash,
    $core.int? enforcerHeight,
    $core.bool? enforcerRebuilt,
    $core.String? enforcerError,
    $core.bool? enforcerChecked,
  }) {
    final result = AcceptBlockResponse._();
    if (coreHeight != null) result.coreHeight = coreHeight;
    if (coreTipHash != null) result.coreTipHash = coreTipHash;
    if (enforcerHeight != null) result.enforcerHeight = enforcerHeight;
    if (enforcerRebuilt != null) result.enforcerRebuilt = enforcerRebuilt;
    if (enforcerError != null) result.enforcerError = enforcerError;
    if (enforcerChecked != null) result.enforcerChecked = enforcerChecked;
    return result;
  }

  AcceptBlockResponse._();

  factory AcceptBlockResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AcceptBlockResponse()..mergeFromBuffer(data, registry);
  factory AcceptBlockResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AcceptBlockResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AcceptBlockResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: AcceptBlockResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'coreHeight', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'coreTipHash')
    ..aI(3, _omitFieldNames ? '' : 'enforcerHeight', fieldType: $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'enforcerRebuilt')
    ..aOS(5, _omitFieldNames ? '' : 'enforcerError')
    ..aOB(6, _omitFieldNames ? '' : 'enforcerChecked')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptBlockResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptBlockResponse copyWith(void Function(AcceptBlockResponse) updates) =>
      super.copyWith((message) => updates(message as AcceptBlockResponse)) as AcceptBlockResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AcceptBlockResponse() / AcceptBlockResponse.new instead')
  static AcceptBlockResponse create() => AcceptBlockResponse._();
  static $pb.GeneratedMessage $_createMessage() => AcceptBlockResponse._();
  @$core.override
  AcceptBlockResponse createEmptyInstance() => AcceptBlockResponse._();
  @$core.pragma('dart2js:noInline')
  static AcceptBlockResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AcceptBlockResponse>(AcceptBlockResponse.$_createMessage);
  static AcceptBlockResponse? _defaultInstance;

  /// Core's tip after the block is accepted again.
  @$pb.TagNumber(1)
  $core.int get coreHeight => $_getIZ(0);
  @$pb.TagNumber(1)
  set coreHeight($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCoreHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearCoreHeight() => $_clearField(1);

  /// Hash of that tip.
  @$pb.TagNumber(2)
  $core.String get coreTipHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set coreTipHash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCoreTipHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearCoreTipHash() => $_clearField(2);

  /// The enforcer's tip afterwards. Zero when the enforcer is stopped.
  @$pb.TagNumber(3)
  $core.int get enforcerHeight => $_getIZ(2);
  @$pb.TagNumber(3)
  set enforcerHeight($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEnforcerHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnforcerHeight() => $_clearField(3);

  /// True when the enforcer did not follow, so its validator chain was deleted
  /// and it now rebuilds from the local Core.
  @$pb.TagNumber(4)
  $core.bool get enforcerRebuilt => $_getBF(3);
  @$pb.TagNumber(4)
  set enforcerRebuilt($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEnforcerRebuilt() => $_has(3);
  @$pb.TagNumber(4)
  void clearEnforcerRebuilt() => $_clearField(4);

  /// Empty on success; otherwise why the enforcer could not be brought back
  /// onto Core's chain. Core already moved, so the caller keeps its undo path.
  @$pb.TagNumber(5)
  $core.String get enforcerError => $_getSZ(4);
  @$pb.TagNumber(5)
  set enforcerError($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEnforcerError() => $_has(4);
  @$pb.TagNumber(5)
  void clearEnforcerError() => $_clearField(5);

  /// False when the enforcer was never asked, so enforcer_height carries no
  /// reading and must not be shown as one.
  @$pb.TagNumber(6)
  $core.bool get enforcerChecked => $_getBF(5);
  @$pb.TagNumber(6)
  set enforcerChecked($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEnforcerChecked() => $_has(5);
  @$pb.TagNumber(6)
  void clearEnforcerChecked() => $_clearField(6);
}

class ResetToBlockRequest extends $pb.GeneratedMessage {
  factory ResetToBlockRequest({
    $core.String? target,
    $core.int? enforcerWaitSeconds,
  }) {
    final result = ResetToBlockRequest._();
    if (target != null) result.target = target;
    if (enforcerWaitSeconds != null) result.enforcerWaitSeconds = enforcerWaitSeconds;
    return result;
  }

  ResetToBlockRequest._();

  factory ResetToBlockRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResetToBlockRequest()..mergeFromBuffer(data, registry);
  factory ResetToBlockRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResetToBlockRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResetToBlockRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ResetToBlockRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'target')
    ..aI(2, _omitFieldNames ? '' : 'enforcerWaitSeconds', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResetToBlockRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResetToBlockRequest copyWith(void Function(ResetToBlockRequest) updates) =>
      super.copyWith((message) => updates(message as ResetToBlockRequest)) as ResetToBlockRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ResetToBlockRequest() / ResetToBlockRequest.new instead')
  static ResetToBlockRequest create() => ResetToBlockRequest._();
  static $pb.GeneratedMessage $_createMessage() => ResetToBlockRequest._();
  @$core.override
  ResetToBlockRequest createEmptyInstance() => ResetToBlockRequest._();
  @$core.pragma('dart2js:noInline')
  static ResetToBlockRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ResetToBlockRequest>(ResetToBlockRequest.$_createMessage);
  static ResetToBlockRequest? _defaultInstance;

  /// The block to move back to. A 64-character hash names one block. Anything
  /// else reads as a decimal height, and a height resolves against the chain
  /// this node follows today.
  @$pb.TagNumber(1)
  $core.String get target => $_getSZ(0);
  @$pb.TagNumber(1)
  set target($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTarget() => $_has(0);
  @$pb.TagNumber(1)
  void clearTarget() => $_clearField(1);

  /// How long to wait for the enforcer to follow before its validator chain is
  /// deleted. Zero picks the default.
  @$pb.TagNumber(2)
  $core.int get enforcerWaitSeconds => $_getIZ(1);
  @$pb.TagNumber(2)
  set enforcerWaitSeconds($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnforcerWaitSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnforcerWaitSeconds() => $_clearField(2);
}

class ResetToBlockResponse extends $pb.GeneratedMessage {
  factory ResetToBlockResponse({
    ResetPhase? phase,
    $core.String? message,
    $core.int? targetHeight,
    $core.String? targetHash,
    $core.int? coreHeight,
    $core.int? tipHeight,
    $core.int? blocksDone,
    $core.int? blocksTotal,
    $core.int? enforcerHeight,
    $core.bool? enforcerChecked,
    $core.bool? enforcerRebuilt,
    $core.String? enforcerError,
    $core.bool? done,
  }) {
    final result = ResetToBlockResponse._();
    if (phase != null) result.phase = phase;
    if (message != null) result.message = message;
    if (targetHeight != null) result.targetHeight = targetHeight;
    if (targetHash != null) result.targetHash = targetHash;
    if (coreHeight != null) result.coreHeight = coreHeight;
    if (tipHeight != null) result.tipHeight = tipHeight;
    if (blocksDone != null) result.blocksDone = blocksDone;
    if (blocksTotal != null) result.blocksTotal = blocksTotal;
    if (enforcerHeight != null) result.enforcerHeight = enforcerHeight;
    if (enforcerChecked != null) result.enforcerChecked = enforcerChecked;
    if (enforcerRebuilt != null) result.enforcerRebuilt = enforcerRebuilt;
    if (enforcerError != null) result.enforcerError = enforcerError;
    if (done != null) result.done = done;
    return result;
  }

  ResetToBlockResponse._();

  factory ResetToBlockResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResetToBlockResponse()..mergeFromBuffer(data, registry);
  factory ResetToBlockResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResetToBlockResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResetToBlockResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ResetToBlockResponse.$_createMessage)
    ..aE<ResetPhase>(1, _omitFieldNames ? '' : 'phase', enumValues: ResetPhase.values)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aI(3, _omitFieldNames ? '' : 'targetHeight', fieldType: $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'targetHash')
    ..aI(5, _omitFieldNames ? '' : 'coreHeight', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'tipHeight', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'blocksDone', fieldType: $pb.PbFieldType.OU3)
    ..aI(8, _omitFieldNames ? '' : 'blocksTotal', fieldType: $pb.PbFieldType.OU3)
    ..aI(9, _omitFieldNames ? '' : 'enforcerHeight', fieldType: $pb.PbFieldType.OU3)
    ..aOB(10, _omitFieldNames ? '' : 'enforcerChecked')
    ..aOB(11, _omitFieldNames ? '' : 'enforcerRebuilt')
    ..aOS(12, _omitFieldNames ? '' : 'enforcerError')
    ..aOB(13, _omitFieldNames ? '' : 'done')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResetToBlockResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResetToBlockResponse copyWith(void Function(ResetToBlockResponse) updates) =>
      super.copyWith((message) => updates(message as ResetToBlockResponse)) as ResetToBlockResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ResetToBlockResponse() / ResetToBlockResponse.new instead')
  static ResetToBlockResponse create() => ResetToBlockResponse._();
  static $pb.GeneratedMessage $_createMessage() => ResetToBlockResponse._();
  @$core.override
  ResetToBlockResponse createEmptyInstance() => ResetToBlockResponse._();
  @$core.pragma('dart2js:noInline')
  static ResetToBlockResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResetToBlockResponse>(ResetToBlockResponse.$_createMessage);
  static ResetToBlockResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResetPhase get phase => $_getN(0);
  @$pb.TagNumber(1)
  set phase(ResetPhase value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPhase() => $_has(0);
  @$pb.TagNumber(1)
  void clearPhase() => $_clearField(1);

  /// Human-readable status for the phase.
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// The block the reset moves back to.
  @$pb.TagNumber(3)
  $core.int get targetHeight => $_getIZ(2);
  @$pb.TagNumber(3)
  set targetHeight($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTargetHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetHeight() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get targetHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set targetHash($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTargetHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearTargetHash() => $_clearField(4);

  /// Core's tip as the phase reports it. It falls to target_height - 1 on the
  /// move back, then climbs again.
  @$pb.TagNumber(5)
  $core.int get coreHeight => $_getIZ(4);
  @$pb.TagNumber(5)
  set coreHeight($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCoreHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearCoreHeight() => $_clearField(5);

  /// Core's tip before the reset. The replay ends here.
  @$pb.TagNumber(6)
  $core.int get tipHeight => $_getIZ(5);
  @$pb.TagNumber(6)
  set tipHeight($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTipHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearTipHeight() => $_clearField(6);

  /// Blocks re-validated so far, out of the blocks the reset drops.
  @$pb.TagNumber(7)
  $core.int get blocksDone => $_getIZ(6);
  @$pb.TagNumber(7)
  set blocksDone($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBlocksDone() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlocksDone() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get blocksTotal => $_getIZ(7);
  @$pb.TagNumber(8)
  set blocksTotal($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBlocksTotal() => $_has(7);
  @$pb.TagNumber(8)
  void clearBlocksTotal() => $_clearField(8);

  /// The enforcer's tip afterwards. Zero when the enforcer is stopped.
  @$pb.TagNumber(9)
  $core.int get enforcerHeight => $_getIZ(8);
  @$pb.TagNumber(9)
  set enforcerHeight($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasEnforcerHeight() => $_has(8);
  @$pb.TagNumber(9)
  void clearEnforcerHeight() => $_clearField(9);

  /// False when the enforcer was never asked, so enforcer_height carries no
  /// reading and must not be shown as one.
  @$pb.TagNumber(10)
  $core.bool get enforcerChecked => $_getBF(9);
  @$pb.TagNumber(10)
  set enforcerChecked($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasEnforcerChecked() => $_has(9);
  @$pb.TagNumber(10)
  void clearEnforcerChecked() => $_clearField(10);

  /// True when the enforcer did not follow, so its validator chain was deleted
  /// and it rebuilds from the local Core.
  @$pb.TagNumber(11)
  $core.bool get enforcerRebuilt => $_getBF(10);
  @$pb.TagNumber(11)
  set enforcerRebuilt($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasEnforcerRebuilt() => $_has(10);
  @$pb.TagNumber(11)
  void clearEnforcerRebuilt() => $_clearField(11);

  /// Empty on success; otherwise why the enforcer could not be brought back
  /// onto Core's chain.
  @$pb.TagNumber(12)
  $core.String get enforcerError => $_getSZ(11);
  @$pb.TagNumber(12)
  set enforcerError($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasEnforcerError() => $_has(11);
  @$pb.TagNumber(12)
  void clearEnforcerError() => $_clearField(12);

  /// Set on the last message.
  @$pb.TagNumber(13)
  $core.bool get done => $_getBF(12);
  @$pb.TagNumber(13)
  set done($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasDone() => $_has(12);
  @$pb.TagNumber(13)
  void clearDone() => $_clearField(13);
}

class GetCoreMempoolInfoRequest extends $pb.GeneratedMessage {
  factory GetCoreMempoolInfoRequest() => GetCoreMempoolInfoRequest._();

  GetCoreMempoolInfoRequest._();

  factory GetCoreMempoolInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoreMempoolInfoRequest()..mergeFromBuffer(data, registry);
  factory GetCoreMempoolInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoreMempoolInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoreMempoolInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetCoreMempoolInfoRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoreMempoolInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoreMempoolInfoRequest copyWith(void Function(GetCoreMempoolInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetCoreMempoolInfoRequest)) as GetCoreMempoolInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCoreMempoolInfoRequest() / GetCoreMempoolInfoRequest.new instead')
  static GetCoreMempoolInfoRequest create() => GetCoreMempoolInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetCoreMempoolInfoRequest._();
  @$core.override
  GetCoreMempoolInfoRequest createEmptyInstance() => GetCoreMempoolInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetCoreMempoolInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCoreMempoolInfoRequest>(GetCoreMempoolInfoRequest.$_createMessage);
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
    final result = GetCoreMempoolInfoResponse._();
    if (loaded != null) result.loaded = loaded;
    if (size != null) result.size = size;
    if (bytes != null) result.bytes = bytes;
    if (usage != null) result.usage = usage;
    if (totalFee != null) result.totalFee = totalFee;
    if (maxMempool != null) result.maxMempool = maxMempool;
    if (mempoolMinFee != null) result.mempoolMinFee = mempoolMinFee;
    if (minRelayTxFee != null) result.minRelayTxFee = minRelayTxFee;
    if (incrementalRelayFee != null) result.incrementalRelayFee = incrementalRelayFee;
    if (unbroadcastCount != null) result.unbroadcastCount = unbroadcastCount;
    if (fullRbf != null) result.fullRbf = fullRbf;
    return result;
  }

  GetCoreMempoolInfoResponse._();

  factory GetCoreMempoolInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoreMempoolInfoResponse()..mergeFromBuffer(data, registry);
  factory GetCoreMempoolInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoreMempoolInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoreMempoolInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetCoreMempoolInfoResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'loaded')
    ..aInt64(2, _omitFieldNames ? '' : 'size')
    ..aInt64(3, _omitFieldNames ? '' : 'bytes')
    ..aInt64(4, _omitFieldNames ? '' : 'usage')
    ..aD(5, _omitFieldNames ? '' : 'totalFee')
    ..aInt64(6, _omitFieldNames ? '' : 'maxMempool')
    ..aD(7, _omitFieldNames ? '' : 'mempoolMinFee')
    ..aD(8, _omitFieldNames ? '' : 'minRelayTxFee')
    ..aD(9, _omitFieldNames ? '' : 'incrementalRelayFee')
    ..aInt64(10, _omitFieldNames ? '' : 'unbroadcastCount')
    ..aOB(11, _omitFieldNames ? '' : 'fullRbf')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoreMempoolInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoreMempoolInfoResponse copyWith(void Function(GetCoreMempoolInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetCoreMempoolInfoResponse)) as GetCoreMempoolInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCoreMempoolInfoResponse() / GetCoreMempoolInfoResponse.new instead')
  static GetCoreMempoolInfoResponse create() => GetCoreMempoolInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetCoreMempoolInfoResponse._();
  @$core.override
  GetCoreMempoolInfoResponse createEmptyInstance() => GetCoreMempoolInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetCoreMempoolInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCoreMempoolInfoResponse>(GetCoreMempoolInfoResponse.$_createMessage);
  static GetCoreMempoolInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get loaded => $_getBF(0);
  @$pb.TagNumber(1)
  set loaded($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoaded() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoaded() => $_clearField(1);

  /// Number of transactions in the mempool.
  @$pb.TagNumber(2)
  $fixnum.Int64 get size => $_getI64(1);
  @$pb.TagNumber(2)
  set size($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearSize() => $_clearField(2);

  /// Sum of serialized sizes (bytes).
  @$pb.TagNumber(3)
  $fixnum.Int64 get bytes => $_getI64(2);
  @$pb.TagNumber(3)
  set bytes($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearBytes() => $_clearField(3);

  /// Total memory usage (bytes).
  @$pb.TagNumber(4)
  $fixnum.Int64 get usage => $_getI64(3);
  @$pb.TagNumber(4)
  set usage($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUsage() => $_has(3);
  @$pb.TagNumber(4)
  void clearUsage() => $_clearField(4);

  /// Sum of all tx fees (BTC).
  @$pb.TagNumber(5)
  $core.double get totalFee => $_getN(4);
  @$pb.TagNumber(5)
  set totalFee($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalFee() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalFee() => $_clearField(5);

  /// Mempool size cap (bytes).
  @$pb.TagNumber(6)
  $fixnum.Int64 get maxMempool => $_getI64(5);
  @$pb.TagNumber(6)
  set maxMempool($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxMempool() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxMempool() => $_clearField(6);

  /// Lowest fee rate accepted into mempool (BTC/kvB).
  @$pb.TagNumber(7)
  $core.double get mempoolMinFee => $_getN(6);
  @$pb.TagNumber(7)
  set mempoolMinFee($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMempoolMinFee() => $_has(6);
  @$pb.TagNumber(7)
  void clearMempoolMinFee() => $_clearField(7);

  /// Lowest fee rate eligible for relay (BTC/kvB).
  @$pb.TagNumber(8)
  $core.double get minRelayTxFee => $_getN(7);
  @$pb.TagNumber(8)
  set minRelayTxFee($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMinRelayTxFee() => $_has(7);
  @$pb.TagNumber(8)
  void clearMinRelayTxFee() => $_clearField(8);

  /// Minimum bump-fee increment (BTC/kvB).
  @$pb.TagNumber(9)
  $core.double get incrementalRelayFee => $_getN(8);
  @$pb.TagNumber(9)
  set incrementalRelayFee($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIncrementalRelayFee() => $_has(8);
  @$pb.TagNumber(9)
  void clearIncrementalRelayFee() => $_clearField(9);

  /// Transactions in mempool not yet broadcast.
  @$pb.TagNumber(10)
  $fixnum.Int64 get unbroadcastCount => $_getI64(9);
  @$pb.TagNumber(10)
  set unbroadcastCount($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasUnbroadcastCount() => $_has(9);
  @$pb.TagNumber(10)
  void clearUnbroadcastCount() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get fullRbf => $_getBF(10);
  @$pb.TagNumber(11)
  set fullRbf($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasFullRbf() => $_has(10);
  @$pb.TagNumber(11)
  void clearFullRbf() => $_clearField(11);
}

class GetBmmContextRequest extends $pb.GeneratedMessage {
  factory GetBmmContextRequest() => GetBmmContextRequest._();

  GetBmmContextRequest._();

  factory GetBmmContextRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmContextRequest()..mergeFromBuffer(data, registry);
  factory GetBmmContextRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmContextRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmContextRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetBmmContextRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmContextRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmContextRequest copyWith(void Function(GetBmmContextRequest) updates) =>
      super.copyWith((message) => updates(message as GetBmmContextRequest)) as GetBmmContextRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBmmContextRequest() / GetBmmContextRequest.new instead')
  static GetBmmContextRequest create() => GetBmmContextRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBmmContextRequest._();
  @$core.override
  GetBmmContextRequest createEmptyInstance() => GetBmmContextRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBmmContextRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBmmContextRequest>(GetBmmContextRequest.$_createMessage);
  static GetBmmContextRequest? _defaultInstance;
}

/// Parent-chain state a BMM miner bids against. A sidechain block only
/// connects when a mainchain miner includes its commitment, so the tip is
/// the block the next request targets and the fee rate is what the bid
/// competes with. fee_rate_sat_vb is 0 when bitcoind cannot yet estimate.
class GetBmmContextResponse extends $pb.GeneratedMessage {
  factory GetBmmContextResponse({
    $core.int? mainchainHeight,
    $core.String? mainchainTip,
    $core.double? feeRateSatVb,
    $fixnum.Int64? mempoolTxns,
    $core.String? warnings,
  }) {
    final result = GetBmmContextResponse._();
    if (mainchainHeight != null) result.mainchainHeight = mainchainHeight;
    if (mainchainTip != null) result.mainchainTip = mainchainTip;
    if (feeRateSatVb != null) result.feeRateSatVb = feeRateSatVb;
    if (mempoolTxns != null) result.mempoolTxns = mempoolTxns;
    if (warnings != null) result.warnings = warnings;
    return result;
  }

  GetBmmContextResponse._();

  factory GetBmmContextResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmContextResponse()..mergeFromBuffer(data, registry);
  factory GetBmmContextResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmContextResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmContextResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetBmmContextResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'mainchainHeight')
    ..aOS(2, _omitFieldNames ? '' : 'mainchainTip')
    ..aD(3, _omitFieldNames ? '' : 'feeRateSatVb')
    ..aInt64(4, _omitFieldNames ? '' : 'mempoolTxns')
    ..aOS(5, _omitFieldNames ? '' : 'warnings')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmContextResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmContextResponse copyWith(void Function(GetBmmContextResponse) updates) =>
      super.copyWith((message) => updates(message as GetBmmContextResponse)) as GetBmmContextResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBmmContextResponse() / GetBmmContextResponse.new instead')
  static GetBmmContextResponse create() => GetBmmContextResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBmmContextResponse._();
  @$core.override
  GetBmmContextResponse createEmptyInstance() => GetBmmContextResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBmmContextResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBmmContextResponse>(GetBmmContextResponse.$_createMessage);
  static GetBmmContextResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get mainchainHeight => $_getIZ(0);
  @$pb.TagNumber(1)
  set mainchainHeight($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMainchainHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearMainchainHeight() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get mainchainTip => $_getSZ(1);
  @$pb.TagNumber(2)
  set mainchainTip($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMainchainTip() => $_has(1);
  @$pb.TagNumber(2)
  void clearMainchainTip() => $_clearField(2);

  /// Fee rate for confirmation in the next block, sat/vB.
  @$pb.TagNumber(3)
  $core.double get feeRateSatVb => $_getN(2);
  @$pb.TagNumber(3)
  set feeRateSatVb($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeRateSatVb() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeRateSatVb() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get mempoolTxns => $_getI64(3);
  @$pb.TagNumber(4)
  set mempoolTxns($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMempoolTxns() => $_has(3);
  @$pb.TagNumber(4)
  void clearMempoolTxns() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get warnings => $_getSZ(4);
  @$pb.TagNumber(5)
  set warnings($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWarnings() => $_has(4);
  @$pb.TagNumber(5)
  void clearWarnings() => $_clearField(5);
}

class CoreRawCallRequest extends $pb.GeneratedMessage {
  factory CoreRawCallRequest({
    $core.String? method,
    $core.String? paramsJson,
    $core.String? wallet,
  }) {
    final result = CoreRawCallRequest._();
    if (method != null) result.method = method;
    if (paramsJson != null) result.paramsJson = paramsJson;
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  CoreRawCallRequest._();

  factory CoreRawCallRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CoreRawCallRequest()..mergeFromBuffer(data, registry);
  factory CoreRawCallRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CoreRawCallRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CoreRawCallRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: CoreRawCallRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'method')
    ..aOS(2, _omitFieldNames ? '' : 'paramsJson')
    ..aOS(3, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CoreRawCallRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CoreRawCallRequest copyWith(void Function(CoreRawCallRequest) updates) =>
      super.copyWith((message) => updates(message as CoreRawCallRequest)) as CoreRawCallRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CoreRawCallRequest() / CoreRawCallRequest.new instead')
  static CoreRawCallRequest create() => CoreRawCallRequest._();
  static $pb.GeneratedMessage $_createMessage() => CoreRawCallRequest._();
  @$core.override
  CoreRawCallRequest createEmptyInstance() => CoreRawCallRequest._();
  @$core.pragma('dart2js:noInline')
  static CoreRawCallRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CoreRawCallRequest>(CoreRawCallRequest.$_createMessage);
  static CoreRawCallRequest? _defaultInstance;

  /// bitcoind RPC method name (e.g. "finalizepsbt").
  @$pb.TagNumber(1)
  $core.String get method => $_getSZ(0);
  @$pb.TagNumber(1)
  set method($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMethod() => $_has(0);
  @$pb.TagNumber(1)
  void clearMethod() => $_clearField(1);

  /// JSON-encoded positional params array (e.g. '["psbtBase64", false]').
  /// Empty string means no params.
  @$pb.TagNumber(2)
  $core.String get paramsJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set paramsJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasParamsJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearParamsJson() => $_clearField(2);

  /// Optional bitcoind wallet name to scope the call to. When set, the request
  /// is routed to /wallet/{wallet} on bitcoind so wallet-scoped RPCs like
  /// listtransactions / getbalance / getwalletinfo dispatch to the right
  /// wallet. Empty = node-level call.
  @$pb.TagNumber(3)
  $core.String get wallet => $_getSZ(2);
  @$pb.TagNumber(3)
  set wallet($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWallet() => $_has(2);
  @$pb.TagNumber(3)
  void clearWallet() => $_clearField(3);
}

class CoreRawCallResponse extends $pb.GeneratedMessage {
  factory CoreRawCallResponse({
    $core.String? resultJson,
  }) {
    final result = CoreRawCallResponse._();
    if (resultJson != null) result.resultJson = resultJson;
    return result;
  }

  CoreRawCallResponse._();

  factory CoreRawCallResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CoreRawCallResponse()..mergeFromBuffer(data, registry);
  factory CoreRawCallResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CoreRawCallResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CoreRawCallResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: CoreRawCallResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'resultJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CoreRawCallResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CoreRawCallResponse copyWith(void Function(CoreRawCallResponse) updates) =>
      super.copyWith((message) => updates(message as CoreRawCallResponse)) as CoreRawCallResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CoreRawCallResponse() / CoreRawCallResponse.new instead')
  static CoreRawCallResponse create() => CoreRawCallResponse._();
  static $pb.GeneratedMessage $_createMessage() => CoreRawCallResponse._();
  @$core.override
  CoreRawCallResponse createEmptyInstance() => CoreRawCallResponse._();
  @$core.pragma('dart2js:noInline')
  static CoreRawCallResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CoreRawCallResponse>(CoreRawCallResponse.$_createMessage);
  static CoreRawCallResponse? _defaultInstance;

  /// JSON-encoded result. Caller decodes to its expected shape.
  @$pb.TagNumber(1)
  $core.String get resultJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set resultJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasResultJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearResultJson() => $_clearField(1);
}

class GetForkStatusRequest extends $pb.GeneratedMessage {
  factory GetForkStatusRequest() => GetForkStatusRequest._();

  GetForkStatusRequest._();

  factory GetForkStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetForkStatusRequest()..mergeFromBuffer(data, registry);
  factory GetForkStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetForkStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetForkStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetForkStatusRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetForkStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetForkStatusRequest copyWith(void Function(GetForkStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetForkStatusRequest)) as GetForkStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetForkStatusRequest() / GetForkStatusRequest.new instead')
  static GetForkStatusRequest create() => GetForkStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetForkStatusRequest._();
  @$core.override
  GetForkStatusRequest createEmptyInstance() => GetForkStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static GetForkStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetForkStatusRequest>(GetForkStatusRequest.$_createMessage);
  static GetForkStatusRequest? _defaultInstance;
}

/// Canonical fork snapshot produced by the orchestrator's single ForkEngine.
/// The frontend renders this verbatim — it does no fork math of its own.
class GetForkStatusResponse extends $pb.GeneratedMessage {
  factory GetForkStatusResponse({
    $core.int? forkHeight,
    $core.int? currentHeight,
    $core.int? currentHeaders,
    $core.int? claimBoundary,
    $core.bool? simulated,
    $core.bool? hasFundsToClaim,
    $core.bool? showCountdown,
    $core.Iterable<ForkWalletClaim>? claims,
    $core.String? networkName,
    $core.int? replayLockTime,
  }) {
    final result = GetForkStatusResponse._();
    if (forkHeight != null) result.forkHeight = forkHeight;
    if (currentHeight != null) result.currentHeight = currentHeight;
    if (currentHeaders != null) result.currentHeaders = currentHeaders;
    if (claimBoundary != null) result.claimBoundary = claimBoundary;
    if (simulated != null) result.simulated = simulated;
    if (hasFundsToClaim != null) result.hasFundsToClaim = hasFundsToClaim;
    if (showCountdown != null) result.showCountdown = showCountdown;
    if (claims != null) result.claims.addAll(claims);
    if (networkName != null) result.networkName = networkName;
    if (replayLockTime != null) result.replayLockTime = replayLockTime;
    return result;
  }

  GetForkStatusResponse._();

  factory GetForkStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetForkStatusResponse()..mergeFromBuffer(data, registry);
  factory GetForkStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetForkStatusResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetForkStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetForkStatusResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'forkHeight')
    ..aI(2, _omitFieldNames ? '' : 'currentHeight')
    ..aI(4, _omitFieldNames ? '' : 'currentHeaders')
    ..aI(5, _omitFieldNames ? '' : 'claimBoundary')
    ..aOB(6, _omitFieldNames ? '' : 'simulated')
    ..aOB(7, _omitFieldNames ? '' : 'hasFundsToClaim')
    ..aOB(8, _omitFieldNames ? '' : 'showCountdown')
    ..pPM<ForkWalletClaim>(9, _omitFieldNames ? '' : 'claims', subBuilder: ForkWalletClaim.$_createMessage)
    ..aOS(10, _omitFieldNames ? '' : 'networkName')
    ..aI(11, _omitFieldNames ? '' : 'replayLockTime', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetForkStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetForkStatusResponse copyWith(void Function(GetForkStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetForkStatusResponse)) as GetForkStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetForkStatusResponse() / GetForkStatusResponse.new instead')
  static GetForkStatusResponse create() => GetForkStatusResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetForkStatusResponse._();
  @$core.override
  GetForkStatusResponse createEmptyInstance() => GetForkStatusResponse._();
  @$core.pragma('dart2js:noInline')
  static GetForkStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetForkStatusResponse>(GetForkStatusResponse.$_createMessage);
  static GetForkStatusResponse? _defaultInstance;

  /// Next fork height (countdown target). Fixed per network, or the next
  /// 144-block boundary on signet's simulated daily fork.
  @$pb.TagNumber(1)
  $core.int get forkHeight => $_getIZ(0);
  @$pb.TagNumber(1)
  set forkHeight($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasForkHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearForkHeight() => $_clearField(1);

  /// Current mainchain tip height.
  @$pb.TagNumber(2)
  $core.int get currentHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set currentHeight($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCurrentHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrentHeight() => $_clearField(2);

  /// Current mainchain header height. Runs ahead of `current_height` during
  /// sync; the time-to-fork countdown is driven off this.
  @$pb.TagNumber(4)
  $core.int get currentHeaders => $_getIZ(2);
  @$pb.TagNumber(4)
  set currentHeaders($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(4)
  $core.bool hasCurrentHeaders() => $_has(2);
  @$pb.TagNumber(4)
  void clearCurrentHeaders() => $_clearField(4);

  /// Coins confirmed at/before this height are claimable. Equals fork_height on
  /// fixed-height networks; the last 144-boundary on signet.
  @$pb.TagNumber(5)
  $core.int get claimBoundary => $_getIZ(3);
  @$pb.TagNumber(5)
  set claimBoundary($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(5)
  $core.bool hasClaimBoundary() => $_has(3);
  @$pb.TagNumber(5)
  void clearClaimBoundary() => $_clearField(5);

  /// True on signet, where the fork recurs every 144 blocks.
  @$pb.TagNumber(6)
  $core.bool get simulated => $_getBF(4);
  @$pb.TagNumber(6)
  set simulated($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(6)
  $core.bool hasSimulated() => $_has(4);
  @$pb.TagNumber(6)
  void clearSimulated() => $_clearField(6);

  /// Any wallet holds un-swept pre-fork coins.
  @$pb.TagNumber(7)
  $core.bool get hasFundsToClaim => $_getBF(5);
  @$pb.TagNumber(7)
  set hasFundsToClaim($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(7)
  $core.bool hasHasFundsToClaim() => $_has(5);
  @$pb.TagNumber(7)
  void clearHasFundsToClaim() => $_clearField(7);

  /// Whether to show the next-fork countdown. False while coins are unclaimed
  /// (claim-before-countdown).
  @$pb.TagNumber(8)
  $core.bool get showCountdown => $_getBF(6);
  @$pb.TagNumber(8)
  set showCountdown($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(8)
  $core.bool hasShowCountdown() => $_has(6);
  @$pb.TagNumber(8)
  void clearShowCountdown() => $_clearField(8);

  /// Per-wallet claimable coins, with the exact UTXOs the sweep spends.
  @$pb.TagNumber(9)
  $pb.PbList<ForkWalletClaim> get claims => $_getList(7);

  /// Name of the fork being counted down to ("Betanet"), from the published
  /// catalog. A rehearsal must never read as the real eCash fork.
  @$pb.TagNumber(10)
  $core.String get networkName => $_getSZ(8);
  @$pb.TagNumber(10)
  set networkName($core.String value) => $_setString(8, value);
  @$pb.TagNumber(10)
  $core.bool hasNetworkName() => $_has(8);
  @$pb.TagNumber(10)
  void clearNetworkName() => $_clearField(10);

  /// nLockTime the live eCash network's node treats as final. A transaction
  /// that carries it, with a non-final input, cannot replay onto Bitcoin.
  @$pb.TagNumber(11)
  $core.int get replayLockTime => $_getIZ(9);
  @$pb.TagNumber(11)
  set replayLockTime($core.int value) => $_setUnsignedInt32(9, value);
  @$pb.TagNumber(11)
  $core.bool hasReplayLockTime() => $_has(9);
  @$pb.TagNumber(11)
  void clearReplayLockTime() => $_clearField(11);
}

class ForkWalletClaim extends $pb.GeneratedMessage {
  factory ForkWalletClaim({
    $core.String? walletId,
    $core.String? walletName,
    $fixnum.Int64? claimableSats,
    $core.Iterable<ForkClaimUtxo>? utxos,
  }) {
    final result = ForkWalletClaim._();
    if (walletId != null) result.walletId = walletId;
    if (walletName != null) result.walletName = walletName;
    if (claimableSats != null) result.claimableSats = claimableSats;
    if (utxos != null) result.utxos.addAll(utxos);
    return result;
  }

  ForkWalletClaim._();

  factory ForkWalletClaim.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ForkWalletClaim()..mergeFromBuffer(data, registry);
  factory ForkWalletClaim.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ForkWalletClaim()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ForkWalletClaim',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ForkWalletClaim.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'walletName')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'claimableSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPM<ForkClaimUtxo>(4, _omitFieldNames ? '' : 'utxos', subBuilder: ForkClaimUtxo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForkWalletClaim clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForkWalletClaim copyWith(void Function(ForkWalletClaim) updates) =>
      super.copyWith((message) => updates(message as ForkWalletClaim)) as ForkWalletClaim;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ForkWalletClaim() / ForkWalletClaim.new instead')
  static ForkWalletClaim create() => ForkWalletClaim._();
  static $pb.GeneratedMessage $_createMessage() => ForkWalletClaim._();
  @$core.override
  ForkWalletClaim createEmptyInstance() => ForkWalletClaim._();
  @$core.pragma('dart2js:noInline')
  static ForkWalletClaim getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ForkWalletClaim>(ForkWalletClaim.$_createMessage);
  static ForkWalletClaim? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get walletName => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletName() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletName() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get claimableSats => $_getI64(2);
  @$pb.TagNumber(3)
  set claimableSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasClaimableSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearClaimableSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<ForkClaimUtxo> get utxos => $_getList(3);
}

class ForkClaimUtxo extends $pb.GeneratedMessage {
  factory ForkClaimUtxo({
    $core.String? outpoint,
    $core.String? address,
    $fixnum.Int64? sats,
    $core.String? label,
    $core.bool? splittable,
    $core.int? height,
  }) {
    final result = ForkClaimUtxo._();
    if (outpoint != null) result.outpoint = outpoint;
    if (address != null) result.address = address;
    if (sats != null) result.sats = sats;
    if (label != null) result.label = label;
    if (splittable != null) result.splittable = splittable;
    if (height != null) result.height = height;
    return result;
  }

  ForkClaimUtxo._();

  factory ForkClaimUtxo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ForkClaimUtxo()..mergeFromBuffer(data, registry);
  factory ForkClaimUtxo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ForkClaimUtxo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ForkClaimUtxo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ForkClaimUtxo.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'outpoint')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'sats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, _omitFieldNames ? '' : 'label')
    ..aOB(5, _omitFieldNames ? '' : 'splittable')
    ..aI(6, _omitFieldNames ? '' : 'height')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForkClaimUtxo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForkClaimUtxo copyWith(void Function(ForkClaimUtxo) updates) =>
      super.copyWith((message) => updates(message as ForkClaimUtxo)) as ForkClaimUtxo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ForkClaimUtxo() / ForkClaimUtxo.new instead')
  static ForkClaimUtxo create() => ForkClaimUtxo._();
  static $pb.GeneratedMessage $_createMessage() => ForkClaimUtxo._();
  @$core.override
  ForkClaimUtxo createEmptyInstance() => ForkClaimUtxo._();
  @$core.pragma('dart2js:noInline')
  static ForkClaimUtxo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ForkClaimUtxo>(ForkClaimUtxo.$_createMessage);
  static ForkClaimUtxo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get outpoint => $_getSZ(0);
  @$pb.TagNumber(1)
  set outpoint($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOutpoint() => $_has(0);
  @$pb.TagNumber(1)
  void clearOutpoint() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sats => $_getI64(2);
  @$pb.TagNumber(3)
  set sats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get label => $_getSZ(3);
  @$pb.TagNumber(4)
  set label($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLabel() => $_has(3);
  @$pb.TagNumber(4)
  void clearLabel() => $_clearField(4);

  /// True when the outpoint exists unspent on BTC mainnet. Unset until the
  /// split engine checked it.
  @$pb.TagNumber(5)
  $core.bool get splittable => $_getBF(4);
  @$pb.TagNumber(5)
  set splittable($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSplittable() => $_has(4);
  @$pb.TagNumber(5)
  void clearSplittable() => $_clearField(5);

  /// Confirmation block height.
  @$pb.TagNumber(6)
  $core.int get height => $_getIZ(5);
  @$pb.TagNumber(6)
  set height($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearHeight() => $_clearField(6);
}

class ShutdownRequest extends $pb.GeneratedMessage {
  factory ShutdownRequest({
    $core.bool? onlyIfLast,
    $core.bool? keepL1,
  }) {
    final result = ShutdownRequest._();
    if (onlyIfLast != null) result.onlyIfLast = onlyIfLast;
    if (keepL1 != null) result.keepL1 = keepL1;
    return result;
  }

  ShutdownRequest._();

  factory ShutdownRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShutdownRequest()..mergeFromBuffer(data, registry);
  factory ShutdownRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShutdownRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ShutdownRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ShutdownRequest.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'onlyIfLast')
    ..aOB(2, _omitFieldNames ? '' : 'keepL1')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShutdownRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShutdownRequest copyWith(void Function(ShutdownRequest) updates) =>
      super.copyWith((message) => updates(message as ShutdownRequest)) as ShutdownRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ShutdownRequest() / ShutdownRequest.new instead')
  static ShutdownRequest create() => ShutdownRequest._();
  static $pb.GeneratedMessage $_createMessage() => ShutdownRequest._();
  @$core.override
  ShutdownRequest createEmptyInstance() => ShutdownRequest._();
  @$core.pragma('dart2js:noInline')
  static ShutdownRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShutdownRequest>(ShutdownRequest.$_createMessage);
  static ShutdownRequest? _defaultInstance;

  /// Drain only once no client is connected and the owner process is gone.
  /// Unset means drain now, whoever else is attached.
  @$pb.TagNumber(1)
  $core.bool get onlyIfLast => $_getBF(0);
  @$pb.TagNumber(1)
  set onlyIfLast($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOnlyIfLast() => $_has(0);
  @$pb.TagNumber(1)
  void clearOnlyIfLast() => $_clearField(1);

  /// Exit and leave bitcoind, the enforcer and the sidechains running. The
  /// daemon that takes the port adopts them.
  @$pb.TagNumber(2)
  $core.bool get keepL1 => $_getBF(1);
  @$pb.TagNumber(2)
  set keepL1($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKeepL1() => $_has(1);
  @$pb.TagNumber(2)
  void clearKeepL1() => $_clearField(2);
}

class ShutdownResponse extends $pb.GeneratedMessage {
  factory ShutdownResponse() => ShutdownResponse._();

  ShutdownResponse._();

  factory ShutdownResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShutdownResponse()..mergeFromBuffer(data, registry);
  factory ShutdownResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShutdownResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ShutdownResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ShutdownResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShutdownResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShutdownResponse copyWith(void Function(ShutdownResponse) updates) =>
      super.copyWith((message) => updates(message as ShutdownResponse)) as ShutdownResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ShutdownResponse() / ShutdownResponse.new instead')
  static ShutdownResponse create() => ShutdownResponse._();
  static $pb.GeneratedMessage $_createMessage() => ShutdownResponse._();
  @$core.override
  ShutdownResponse createEmptyInstance() => ShutdownResponse._();
  @$core.pragma('dart2js:noInline')
  static ShutdownResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShutdownResponse>(ShutdownResponse.$_createMessage);
  static ShutdownResponse? _defaultInstance;
}

class AdoptOwnerRequest extends $pb.GeneratedMessage {
  factory AdoptOwnerRequest({
    $core.int? ownerPid,
  }) {
    final result = AdoptOwnerRequest._();
    if (ownerPid != null) result.ownerPid = ownerPid;
    return result;
  }

  AdoptOwnerRequest._();

  factory AdoptOwnerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AdoptOwnerRequest()..mergeFromBuffer(data, registry);
  factory AdoptOwnerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AdoptOwnerRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AdoptOwnerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: AdoptOwnerRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'ownerPid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdoptOwnerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdoptOwnerRequest copyWith(void Function(AdoptOwnerRequest) updates) =>
      super.copyWith((message) => updates(message as AdoptOwnerRequest)) as AdoptOwnerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AdoptOwnerRequest() / AdoptOwnerRequest.new instead')
  static AdoptOwnerRequest create() => AdoptOwnerRequest._();
  static $pb.GeneratedMessage $_createMessage() => AdoptOwnerRequest._();
  @$core.override
  AdoptOwnerRequest createEmptyInstance() => AdoptOwnerRequest._();
  @$core.pragma('dart2js:noInline')
  static AdoptOwnerRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AdoptOwnerRequest>(AdoptOwnerRequest.$_createMessage);
  static AdoptOwnerRequest? _defaultInstance;

  /// Process ID of the frontend that owns the daemon now.
  @$pb.TagNumber(1)
  $core.int get ownerPid => $_getIZ(0);
  @$pb.TagNumber(1)
  set ownerPid($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOwnerPid() => $_has(0);
  @$pb.TagNumber(1)
  void clearOwnerPid() => $_clearField(1);
}

class AdoptOwnerResponse extends $pb.GeneratedMessage {
  factory AdoptOwnerResponse({
    $core.bool? canceledExit,
  }) {
    final result = AdoptOwnerResponse._();
    if (canceledExit != null) result.canceledExit = canceledExit;
    return result;
  }

  AdoptOwnerResponse._();

  factory AdoptOwnerResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AdoptOwnerResponse()..mergeFromBuffer(data, registry);
  factory AdoptOwnerResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AdoptOwnerResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AdoptOwnerResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: AdoptOwnerResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'canceledExit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdoptOwnerResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdoptOwnerResponse copyWith(void Function(AdoptOwnerResponse) updates) =>
      super.copyWith((message) => updates(message as AdoptOwnerResponse)) as AdoptOwnerResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AdoptOwnerResponse() / AdoptOwnerResponse.new instead')
  static AdoptOwnerResponse create() => AdoptOwnerResponse._();
  static $pb.GeneratedMessage $_createMessage() => AdoptOwnerResponse._();
  @$core.override
  AdoptOwnerResponse createEmptyInstance() => AdoptOwnerResponse._();
  @$core.pragma('dart2js:noInline')
  static AdoptOwnerResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AdoptOwnerResponse>(AdoptOwnerResponse.$_createMessage);
  static AdoptOwnerResponse? _defaultInstance;

  /// True when the daemon was on its way out and this call stopped the exit.
  @$pb.TagNumber(1)
  $core.bool get canceledExit => $_getBF(0);
  @$pb.TagNumber(1)
  set canceledExit($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCanceledExit() => $_has(0);
  @$pb.TagNumber(1)
  void clearCanceledExit() => $_clearField(1);
}

class PreviewECashMigrationRequest extends $pb.GeneratedMessage {
  factory PreviewECashMigrationRequest({
    $core.String? fromId,
    $core.String? toId,
  }) {
    final result = PreviewECashMigrationRequest._();
    if (fromId != null) result.fromId = fromId;
    if (toId != null) result.toId = toId;
    return result;
  }

  PreviewECashMigrationRequest._();

  factory PreviewECashMigrationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewECashMigrationRequest()..mergeFromBuffer(data, registry);
  factory PreviewECashMigrationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewECashMigrationRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PreviewECashMigrationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: PreviewECashMigrationRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'fromId')
    ..aOS(2, _omitFieldNames ? '' : 'toId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewECashMigrationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewECashMigrationRequest copyWith(void Function(PreviewECashMigrationRequest) updates) =>
      super.copyWith((message) => updates(message as PreviewECashMigrationRequest)) as PreviewECashMigrationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PreviewECashMigrationRequest() / PreviewECashMigrationRequest.new instead')
  static PreviewECashMigrationRequest create() => PreviewECashMigrationRequest._();
  static $pb.GeneratedMessage $_createMessage() => PreviewECashMigrationRequest._();
  @$core.override
  PreviewECashMigrationRequest createEmptyInstance() => PreviewECashMigrationRequest._();
  @$core.pragma('dart2js:noInline')
  static PreviewECashMigrationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PreviewECashMigrationRequest>(PreviewECashMigrationRequest.$_createMessage);
  static PreviewECashMigrationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fromId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fromId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get toId => $_getSZ(1);
  @$pb.TagNumber(2)
  set toId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToId() => $_has(1);
  @$pb.TagNumber(2)
  void clearToId() => $_clearField(2);
}

class PreviewECashMigrationResponse extends $pb.GeneratedMessage {
  factory PreviewECashMigrationResponse({
    ECashMigrationStatus? status,
  }) {
    final result = PreviewECashMigrationResponse._();
    if (status != null) result.status = status;
    return result;
  }

  PreviewECashMigrationResponse._();

  factory PreviewECashMigrationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewECashMigrationResponse()..mergeFromBuffer(data, registry);
  factory PreviewECashMigrationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewECashMigrationResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PreviewECashMigrationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: PreviewECashMigrationResponse.$_createMessage)
    ..aOM<ECashMigrationStatus>(1, _omitFieldNames ? '' : 'status', subBuilder: ECashMigrationStatus.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewECashMigrationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewECashMigrationResponse copyWith(void Function(PreviewECashMigrationResponse) updates) =>
      super.copyWith((message) => updates(message as PreviewECashMigrationResponse)) as PreviewECashMigrationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PreviewECashMigrationResponse() / PreviewECashMigrationResponse.new instead')
  static PreviewECashMigrationResponse create() => PreviewECashMigrationResponse._();
  static $pb.GeneratedMessage $_createMessage() => PreviewECashMigrationResponse._();
  @$core.override
  PreviewECashMigrationResponse createEmptyInstance() => PreviewECashMigrationResponse._();
  @$core.pragma('dart2js:noInline')
  static PreviewECashMigrationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PreviewECashMigrationResponse>(PreviewECashMigrationResponse.$_createMessage);
  static PreviewECashMigrationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ECashMigrationStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ECashMigrationStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);
  @$pb.TagNumber(1)
  ECashMigrationStatus ensureStatus() => $_ensure(0);
}

class StartECashMigrationRequest extends $pb.GeneratedMessage {
  factory StartECashMigrationRequest({
    $core.String? fromId,
    $core.String? toId,
  }) {
    final result = StartECashMigrationRequest._();
    if (fromId != null) result.fromId = fromId;
    if (toId != null) result.toId = toId;
    return result;
  }

  StartECashMigrationRequest._();

  factory StartECashMigrationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartECashMigrationRequest()..mergeFromBuffer(data, registry);
  factory StartECashMigrationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartECashMigrationRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartECashMigrationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: StartECashMigrationRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'fromId')
    ..aOS(2, _omitFieldNames ? '' : 'toId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartECashMigrationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartECashMigrationRequest copyWith(void Function(StartECashMigrationRequest) updates) =>
      super.copyWith((message) => updates(message as StartECashMigrationRequest)) as StartECashMigrationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StartECashMigrationRequest() / StartECashMigrationRequest.new instead')
  static StartECashMigrationRequest create() => StartECashMigrationRequest._();
  static $pb.GeneratedMessage $_createMessage() => StartECashMigrationRequest._();
  @$core.override
  StartECashMigrationRequest createEmptyInstance() => StartECashMigrationRequest._();
  @$core.pragma('dart2js:noInline')
  static StartECashMigrationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StartECashMigrationRequest>(StartECashMigrationRequest.$_createMessage);
  static StartECashMigrationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fromId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fromId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get toId => $_getSZ(1);
  @$pb.TagNumber(2)
  set toId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToId() => $_has(1);
  @$pb.TagNumber(2)
  void clearToId() => $_clearField(2);
}

class StartECashMigrationResponse extends $pb.GeneratedMessage {
  factory StartECashMigrationResponse({
    ECashMigrationStatus? status,
  }) {
    final result = StartECashMigrationResponse._();
    if (status != null) result.status = status;
    return result;
  }

  StartECashMigrationResponse._();

  factory StartECashMigrationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartECashMigrationResponse()..mergeFromBuffer(data, registry);
  factory StartECashMigrationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartECashMigrationResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartECashMigrationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: StartECashMigrationResponse.$_createMessage)
    ..aOM<ECashMigrationStatus>(1, _omitFieldNames ? '' : 'status', subBuilder: ECashMigrationStatus.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartECashMigrationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartECashMigrationResponse copyWith(void Function(StartECashMigrationResponse) updates) =>
      super.copyWith((message) => updates(message as StartECashMigrationResponse)) as StartECashMigrationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StartECashMigrationResponse() / StartECashMigrationResponse.new instead')
  static StartECashMigrationResponse create() => StartECashMigrationResponse._();
  static $pb.GeneratedMessage $_createMessage() => StartECashMigrationResponse._();
  @$core.override
  StartECashMigrationResponse createEmptyInstance() => StartECashMigrationResponse._();
  @$core.pragma('dart2js:noInline')
  static StartECashMigrationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StartECashMigrationResponse>(StartECashMigrationResponse.$_createMessage);
  static StartECashMigrationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ECashMigrationStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ECashMigrationStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);
  @$pb.TagNumber(1)
  ECashMigrationStatus ensureStatus() => $_ensure(0);
}

class GetECashMigrationStatusRequest extends $pb.GeneratedMessage {
  factory GetECashMigrationStatusRequest() => GetECashMigrationStatusRequest._();

  GetECashMigrationStatusRequest._();

  factory GetECashMigrationStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetECashMigrationStatusRequest()..mergeFromBuffer(data, registry);
  factory GetECashMigrationStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetECashMigrationStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetECashMigrationStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetECashMigrationStatusRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetECashMigrationStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetECashMigrationStatusRequest copyWith(void Function(GetECashMigrationStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetECashMigrationStatusRequest)) as GetECashMigrationStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetECashMigrationStatusRequest() / GetECashMigrationStatusRequest.new instead')
  static GetECashMigrationStatusRequest create() => GetECashMigrationStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetECashMigrationStatusRequest._();
  @$core.override
  GetECashMigrationStatusRequest createEmptyInstance() => GetECashMigrationStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static GetECashMigrationStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetECashMigrationStatusRequest>(GetECashMigrationStatusRequest.$_createMessage);
  static GetECashMigrationStatusRequest? _defaultInstance;
}

class GetECashMigrationStatusResponse extends $pb.GeneratedMessage {
  factory GetECashMigrationStatusResponse({
    ECashMigrationStatus? status,
  }) {
    final result = GetECashMigrationStatusResponse._();
    if (status != null) result.status = status;
    return result;
  }

  GetECashMigrationStatusResponse._();

  factory GetECashMigrationStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetECashMigrationStatusResponse()..mergeFromBuffer(data, registry);
  factory GetECashMigrationStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetECashMigrationStatusResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetECashMigrationStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: GetECashMigrationStatusResponse.$_createMessage)
    ..aOM<ECashMigrationStatus>(1, _omitFieldNames ? '' : 'status', subBuilder: ECashMigrationStatus.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetECashMigrationStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetECashMigrationStatusResponse copyWith(void Function(GetECashMigrationStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetECashMigrationStatusResponse))
          as GetECashMigrationStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetECashMigrationStatusResponse() / GetECashMigrationStatusResponse.new instead')
  static GetECashMigrationStatusResponse create() => GetECashMigrationStatusResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetECashMigrationStatusResponse._();
  @$core.override
  GetECashMigrationStatusResponse createEmptyInstance() => GetECashMigrationStatusResponse._();
  @$core.pragma('dart2js:noInline')
  static GetECashMigrationStatusResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetECashMigrationStatusResponse>(
          GetECashMigrationStatusResponse.$_createMessage);
  static GetECashMigrationStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ECashMigrationStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ECashMigrationStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);
  @$pb.TagNumber(1)
  ECashMigrationStatus ensureStatus() => $_ensure(0);
}

class ECashMigrationStatus extends $pb.GeneratedMessage {
  factory ECashMigrationStatus({
    $core.String? jobId,
    $core.String? fromId,
    $core.String? toId,
    $core.String? phase,
    $core.String? dataDir,
    $fixnum.Int64? commonHeight,
    $core.String? commonHash,
    $core.String? sourceMagic,
    $core.String? targetMagic,
    $fixnum.Int64? blockFiles,
    $fixnum.Int64? undoFiles,
    $fixnum.Int64? recordsDone,
    $fixnum.Int64? recordsTotal,
    $core.bool? running,
    $core.bool? complete,
    $core.String? error,
    $core.String? syncState,
    $core.bool? pruned,
    $fixnum.Int64? pruneHeight,
    $core.bool? walletOnly,
    $fixnum.Int64? startedAtUnix,
    $core.String? recordStage,
    $fixnum.Int64? downloadMbDone,
    $fixnum.Int64? downloadMbTotal,
    $core.bool? belowFork,
  }) {
    final result = ECashMigrationStatus._();
    if (jobId != null) result.jobId = jobId;
    if (fromId != null) result.fromId = fromId;
    if (toId != null) result.toId = toId;
    if (phase != null) result.phase = phase;
    if (dataDir != null) result.dataDir = dataDir;
    if (commonHeight != null) result.commonHeight = commonHeight;
    if (commonHash != null) result.commonHash = commonHash;
    if (sourceMagic != null) result.sourceMagic = sourceMagic;
    if (targetMagic != null) result.targetMagic = targetMagic;
    if (blockFiles != null) result.blockFiles = blockFiles;
    if (undoFiles != null) result.undoFiles = undoFiles;
    if (recordsDone != null) result.recordsDone = recordsDone;
    if (recordsTotal != null) result.recordsTotal = recordsTotal;
    if (running != null) result.running = running;
    if (complete != null) result.complete = complete;
    if (error != null) result.error = error;
    if (syncState != null) result.syncState = syncState;
    if (pruned != null) result.pruned = pruned;
    if (pruneHeight != null) result.pruneHeight = pruneHeight;
    if (walletOnly != null) result.walletOnly = walletOnly;
    if (startedAtUnix != null) result.startedAtUnix = startedAtUnix;
    if (recordStage != null) result.recordStage = recordStage;
    if (downloadMbDone != null) result.downloadMbDone = downloadMbDone;
    if (downloadMbTotal != null) result.downloadMbTotal = downloadMbTotal;
    if (belowFork != null) result.belowFork = belowFork;
    return result;
  }

  ECashMigrationStatus._();

  factory ECashMigrationStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ECashMigrationStatus()..mergeFromBuffer(data, registry);
  factory ECashMigrationStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ECashMigrationStatus()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ECashMigrationStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'orchestrator.v1'),
      createEmptyInstance: ECashMigrationStatus.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'jobId')
    ..aOS(2, _omitFieldNames ? '' : 'fromId')
    ..aOS(3, _omitFieldNames ? '' : 'toId')
    ..aOS(4, _omitFieldNames ? '' : 'phase')
    ..aOS(5, _omitFieldNames ? '' : 'dataDir')
    ..aInt64(6, _omitFieldNames ? '' : 'commonHeight')
    ..aOS(7, _omitFieldNames ? '' : 'commonHash')
    ..aOS(8, _omitFieldNames ? '' : 'sourceMagic')
    ..aOS(9, _omitFieldNames ? '' : 'targetMagic')
    ..a<$fixnum.Int64>(10, _omitFieldNames ? '' : 'blockFiles', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(11, _omitFieldNames ? '' : 'undoFiles', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(12, _omitFieldNames ? '' : 'recordsDone', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(13, _omitFieldNames ? '' : 'recordsTotal', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(14, _omitFieldNames ? '' : 'running')
    ..aOB(15, _omitFieldNames ? '' : 'complete')
    ..aOS(16, _omitFieldNames ? '' : 'error')
    ..aOS(17, _omitFieldNames ? '' : 'syncState')
    ..aOB(18, _omitFieldNames ? '' : 'pruned')
    ..aInt64(19, _omitFieldNames ? '' : 'pruneHeight')
    ..aOB(20, _omitFieldNames ? '' : 'walletOnly')
    ..aInt64(21, _omitFieldNames ? '' : 'startedAtUnix')
    ..aOS(22, _omitFieldNames ? '' : 'recordStage')
    ..aInt64(23, _omitFieldNames ? '' : 'downloadMbDone')
    ..aInt64(24, _omitFieldNames ? '' : 'downloadMbTotal')
    ..aOB(25, _omitFieldNames ? '' : 'belowFork')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ECashMigrationStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ECashMigrationStatus copyWith(void Function(ECashMigrationStatus) updates) =>
      super.copyWith((message) => updates(message as ECashMigrationStatus)) as ECashMigrationStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ECashMigrationStatus() / ECashMigrationStatus.new instead')
  static ECashMigrationStatus create() => ECashMigrationStatus._();
  static $pb.GeneratedMessage $_createMessage() => ECashMigrationStatus._();
  @$core.override
  ECashMigrationStatus createEmptyInstance() => ECashMigrationStatus._();
  @$core.pragma('dart2js:noInline')
  static ECashMigrationStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ECashMigrationStatus>(ECashMigrationStatus.$_createMessage);
  static ECashMigrationStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get jobId => $_getSZ(0);
  @$pb.TagNumber(1)
  set jobId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasJobId() => $_has(0);
  @$pb.TagNumber(1)
  void clearJobId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fromId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fromId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFromId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get toId => $_getSZ(2);
  @$pb.TagNumber(3)
  set toId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToId() => $_has(2);
  @$pb.TagNumber(3)
  void clearToId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get phase => $_getSZ(3);
  @$pb.TagNumber(4)
  set phase($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPhase() => $_has(3);
  @$pb.TagNumber(4)
  void clearPhase() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get dataDir => $_getSZ(4);
  @$pb.TagNumber(5)
  set dataDir($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDataDir() => $_has(4);
  @$pb.TagNumber(5)
  void clearDataDir() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get commonHeight => $_getI64(5);
  @$pb.TagNumber(6)
  set commonHeight($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCommonHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearCommonHeight() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get commonHash => $_getSZ(6);
  @$pb.TagNumber(7)
  set commonHash($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCommonHash() => $_has(6);
  @$pb.TagNumber(7)
  void clearCommonHash() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get sourceMagic => $_getSZ(7);
  @$pb.TagNumber(8)
  set sourceMagic($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSourceMagic() => $_has(7);
  @$pb.TagNumber(8)
  void clearSourceMagic() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get targetMagic => $_getSZ(8);
  @$pb.TagNumber(9)
  set targetMagic($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTargetMagic() => $_has(8);
  @$pb.TagNumber(9)
  void clearTargetMagic() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get blockFiles => $_getI64(9);
  @$pb.TagNumber(10)
  set blockFiles($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasBlockFiles() => $_has(9);
  @$pb.TagNumber(10)
  void clearBlockFiles() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get undoFiles => $_getI64(10);
  @$pb.TagNumber(11)
  set undoFiles($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasUndoFiles() => $_has(10);
  @$pb.TagNumber(11)
  void clearUndoFiles() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get recordsDone => $_getI64(11);
  @$pb.TagNumber(12)
  set recordsDone($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasRecordsDone() => $_has(11);
  @$pb.TagNumber(12)
  void clearRecordsDone() => $_clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get recordsTotal => $_getI64(12);
  @$pb.TagNumber(13)
  set recordsTotal($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(13)
  $core.bool hasRecordsTotal() => $_has(12);
  @$pb.TagNumber(13)
  void clearRecordsTotal() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get running => $_getBF(13);
  @$pb.TagNumber(14)
  set running($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasRunning() => $_has(13);
  @$pb.TagNumber(14)
  void clearRunning() => $_clearField(14);

  /// Local target checks passed. Network sync can continue after this point.
  @$pb.TagNumber(15)
  $core.bool get complete => $_getBF(14);
  @$pb.TagNumber(15)
  set complete($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasComplete() => $_has(14);
  @$pb.TagNumber(15)
  void clearComplete() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get error => $_getSZ(15);
  @$pb.TagNumber(16)
  set error($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasError() => $_has(15);
  @$pb.TagNumber(16)
  void clearError() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get syncState => $_getSZ(16);
  @$pb.TagNumber(17)
  set syncState($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasSyncState() => $_has(16);
  @$pb.TagNumber(17)
  void clearSyncState() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.bool get pruned => $_getBF(17);
  @$pb.TagNumber(18)
  set pruned($core.bool value) => $_setBool(17, value);
  @$pb.TagNumber(18)
  $core.bool hasPruned() => $_has(17);
  @$pb.TagNumber(18)
  void clearPruned() => $_clearField(18);

  @$pb.TagNumber(19)
  $fixnum.Int64 get pruneHeight => $_getI64(18);
  @$pb.TagNumber(19)
  set pruneHeight($fixnum.Int64 value) => $_setInt64(18, value);
  @$pb.TagNumber(19)
  $core.bool hasPruneHeight() => $_has(18);
  @$pb.TagNumber(19)
  void clearPruneHeight() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.bool get walletOnly => $_getBF(19);
  @$pb.TagNumber(20)
  set walletOnly($core.bool value) => $_setBool(19, value);
  @$pb.TagNumber(20)
  $core.bool hasWalletOnly() => $_has(19);
  @$pb.TagNumber(20)
  void clearWalletOnly() => $_clearField(20);

  /// Unix seconds the job started, zero before a start.
  @$pb.TagNumber(21)
  $fixnum.Int64 get startedAtUnix => $_getI64(20);
  @$pb.TagNumber(21)
  set startedAtUnix($fixnum.Int64 value) => $_setInt64(20, value);
  @$pb.TagNumber(21)
  $core.bool hasStartedAtUnix() => $_has(20);
  @$pb.TagNumber(21)
  void clearStartedAtUnix() => $_clearField(21);

  /// Record conversion stage: "preflight" counts the records, "convert" writes
  /// them. Empty before the conversion starts.
  @$pb.TagNumber(22)
  $core.String get recordStage => $_getSZ(21);
  @$pb.TagNumber(22)
  set recordStage($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasRecordStage() => $_has(21);
  @$pb.TagNumber(22)
  void clearRecordStage() => $_clearField(22);

  /// Megabytes of the target Core build. Total is -1 when the server states no
  /// length, and both are zero when no download runs.
  @$pb.TagNumber(23)
  $fixnum.Int64 get downloadMbDone => $_getI64(22);
  @$pb.TagNumber(23)
  set downloadMbDone($fixnum.Int64 value) => $_setInt64(22, value);
  @$pb.TagNumber(23)
  $core.bool hasDownloadMbDone() => $_has(22);
  @$pb.TagNumber(23)
  void clearDownloadMbDone() => $_clearField(23);

  @$pb.TagNumber(24)
  $fixnum.Int64 get downloadMbTotal => $_getI64(23);
  @$pb.TagNumber(24)
  set downloadMbTotal($fixnum.Int64 value) => $_setInt64(23, value);
  @$pb.TagNumber(24)
  $core.bool hasDownloadMbTotal() => $_has(23);
  @$pb.TagNumber(24)
  void clearDownloadMbTotal() => $_clearField(24);

  /// The source tip is below the fork, so the migration skips the rollback.
  /// common_height is then the source tip.
  @$pb.TagNumber(25)
  $core.bool get belowFork => $_getBF(24);
  @$pb.TagNumber(25)
  set belowFork($core.bool value) => $_setBool(24, value);
  @$pb.TagNumber(25)
  $core.bool hasBelowFork() => $_has(24);
  @$pb.TagNumber(25)
  void clearBelowFork() => $_clearField(25);
}

class OrchestratorServiceApi {
  final $pb.RpcClient _client;

  OrchestratorServiceApi(this._client);

  /// List all configured binaries and their status.
  $async.Future<ListBinariesResponse> listBinaries($pb.ClientContext? ctx, ListBinariesRequest request) =>
      _client.invoke<ListBinariesResponse>(ctx, 'OrchestratorService', 'ListBinaries', request, ListBinariesResponse());

  /// Get the status of a single binary.
  $async.Future<GetBinaryStatusResponse> getBinaryStatus($pb.ClientContext? ctx, GetBinaryStatusRequest request) =>
      _client.invoke<GetBinaryStatusResponse>(
          ctx, 'OrchestratorService', 'GetBinaryStatus', request, GetBinaryStatusResponse());

  /// Resolve a binary's on-disk path the same way the launcher does (variant-
  /// and test-build aware, honoring force_backend) and return its --version
  /// output. The frontend must never re-derive the path or shell out itself;
  /// this RPC is the single source of truth for "which binary, what version".
  $async.Future<GetBinaryVersionResponse> getBinaryVersion($pb.ClientContext? ctx, GetBinaryVersionRequest request) =>
      _client.invoke<GetBinaryVersionResponse>(
          ctx, 'OrchestratorService', 'GetBinaryVersion', request, GetBinaryVersionResponse());

  /// Download a binary with streaming progress.
  /// Kicks off a download in a background goroutine and returns
  /// immediately. Progress (MB downloaded / total, is_downloading) is
  /// polled out of GetSyncStatus, never tied to this RPC's lifetime — so
  /// a transport blip can't cancel an in-flight download.
  $async.Future<DownloadBinaryResponse> downloadBinary($pb.ClientContext? ctx, DownloadBinaryRequest request) => _client
      .invoke<DownloadBinaryResponse>(ctx, 'OrchestratorService', 'DownloadBinary', request, DownloadBinaryResponse());

  /// Start a binary.
  $async.Future<StartBinaryResponse> startBinary($pb.ClientContext? ctx, StartBinaryRequest request) =>
      _client.invoke<StartBinaryResponse>(ctx, 'OrchestratorService', 'StartBinary', request, StartBinaryResponse());

  /// Stop a binary.
  $async.Future<StopBinaryResponse> stopBinary($pb.ClientContext? ctx, StopBinaryRequest request) =>
      _client.invoke<StopBinaryResponse>(ctx, 'OrchestratorService', 'StopBinary', request, StopBinaryResponse());

  /// Stream stdout/stderr from a binary.
  $async.Future<StreamLogsResponse> streamLogs($pb.ClientContext? ctx, StreamLogsRequest request) =>
      _client.invoke<StreamLogsResponse>(ctx, 'OrchestratorService', 'StreamLogs', request, StreamLogsResponse());

  /// Start a binary and its L1 dependencies. The call returns at once unless wait is true.
  $async.Future<StartWithL1Response> startWithL1($pb.ClientContext? ctx, StartWithL1Request request) =>
      _client.invoke<StartWithL1Response>(ctx, 'OrchestratorService', 'StartWithL1', request, StartWithL1Response());

  /// Stop the named binary and start it again, single-daemon scope. Never
  /// touches sibling daemons: restarting "enforcer" never spawns or adopts
  /// bitcoind. Use this for per-daemon "Restart" buttons on UI cards;
  /// StartWithL1 stays the entry point for full-chain bootstrap. Same
  /// fire-and-forget shape as StartWithL1.
  $async.Future<RestartDaemonResponse> restartDaemon($pb.ClientContext? ctx, RestartDaemonRequest request) => _client
      .invoke<RestartDaemonResponse>(ctx, 'OrchestratorService', 'RestartDaemon', request, RestartDaemonResponse());

  /// Restart the whole L1 stack (bitcoind + enforcer) on the current config.
  /// Stops both (a not-running daemon is skipped, never an error) then boots
  /// the L1 chain via the same path as StartWithL1. Running sidechains are left
  /// alone — they reconnect once the enforcer is back. Fire-and-forget: returns
  /// as soon as the boot goroutine is dispatched. Use this for the "Restart
  /// Bitcoin Core and Enforcer" UI flow instead of hand-sequencing stop/start.
  $async.Future<RestartL1Response> restartL1($pb.ClientContext? ctx, RestartL1Request request) =>
      _client.invoke<RestartL1Response>(ctx, 'OrchestratorService', 'RestartL1', request, RestartL1Response());

  /// Load a UTXO snapshot into the running Bitcoin Core. Streams download and
  /// load progress; a snapshot Core refuses (its base block already passed, or
  /// a snapshot already loaded in this datadir) comes back as an error carrying
  /// Core's own message. Nothing is stopped, restarted or deleted.
  $async.Future<ApplyUTXOSnapshotResponse> applyUTXOSnapshot(
          $pb.ClientContext? ctx, ApplyUTXOSnapshotRequest request) =>
      _client.invoke<ApplyUTXOSnapshotResponse>(
          ctx, 'OrchestratorService', 'ApplyUTXOSnapshot', request, ApplyUTXOSnapshotResponse());

  /// The UTXO snapshot published for the active network (from the network
  /// catalog) plus the one currently loaded in Bitcoin Core, if any. Feeds the
  /// settings UI: pre-fills the snapshot field and shows what is loaded.
  $async.Future<GetSnapshotStatusResponse> getSnapshotStatus(
          $pb.ClientContext? ctx, GetSnapshotStatusRequest request) =>
      _client.invoke<GetSnapshotStatusResponse>(
          ctx, 'OrchestratorService', 'GetSnapshotStatus', request, GetSnapshotStatusResponse());

  /// The eCash network published but not switched to yet. Feeds the upgrade
  /// prompt; pending_network_id is empty when already on the newest one.
  $async.Future<GetPendingNetworkGenerationResponse> getPendingNetworkGeneration(
          $pb.ClientContext? ctx, GetPendingNetworkGenerationRequest request) =>
      _client.invoke<GetPendingNetworkGenerationResponse>(
          ctx, 'OrchestratorService', 'GetPendingNetworkGeneration', request, GetPendingNetworkGenerationResponse());

  /// Record the user's go-ahead to switch to the published eCash network.
  /// Nothing is stopped or deleted here: the caller must restart the backends,
  /// and the switch runs on the next start. Wallets survive, chain history and
  /// its transactions do not — only call with the user's confirmation.
  $async.Future<ConfirmPendingNetworkGenerationResponse> confirmPendingNetworkGeneration(
          $pb.ClientContext? ctx, ConfirmPendingNetworkGenerationRequest request) =>
      _client.invoke<ConfirmPendingNetworkGenerationResponse>(ctx, 'OrchestratorService',
          'ConfirmPendingNetworkGeneration', request, ConfirmPendingNetworkGenerationResponse());

  /// Shutdown all running binaries.
  $async.Future<ShutdownAllResponse> shutdownAll($pb.ClientContext? ctx, ShutdownAllRequest request) =>
      _client.invoke<ShutdownAllResponse>(ctx, 'OrchestratorService', 'ShutdownAll', request, ShutdownAllResponse());

  /// Detached-daemon shutdown. bitwindowd calls this on window close;
  /// drivechaind acks immediately, drains its children (bitcoind, enforcer,
  /// sidechains) in a background goroutine, and os.Exit(0)s when done.
  /// Idempotent. If bitwindow is relaunched while the drain is still in
  /// flight, the next StartWithL1 transparently adopts it (flips the
  /// will-exit bit + awaits the in-flight stops) before booting a fresh
  /// stack — no separate cancel/await RPCs needed by callers.
  $async.Future<ShutdownResponse> shutdown($pb.ClientContext? ctx, ShutdownRequest request) =>
      _client.invoke<ShutdownResponse>(ctx, 'OrchestratorService', 'Shutdown', request, ShutdownResponse());

  /// Point the daemon at the frontend process that owns it now. An app update
  /// replaces the frontend with a new process, and the daemon drains itself a
  /// few seconds after the old one dies. bitwindowd calls this the moment it
  /// finds a live daemon, so the warm stack survives the swap.
  $async.Future<AdoptOwnerResponse> adoptOwner($pb.ClientContext? ctx, AdoptOwnerRequest request) =>
      _client.invoke<AdoptOwnerResponse>(ctx, 'OrchestratorService', 'AdoptOwner', request, AdoptOwnerResponse());

  /// Get the current BTC/USD exchange rate.
  $async.Future<GetBTCPriceResponse> getBTCPrice($pb.ClientContext? ctx, GetBTCPriceRequest request) =>
      _client.invoke<GetBTCPriceResponse>(ctx, 'OrchestratorService', 'GetBTCPrice', request, GetBTCPriceResponse());

  /// Get blockchain info from Bitcoin Core (proxied via orchestrator).
  $async.Future<GetMainchainBlockchainInfoResponse> getMainchainBlockchainInfo(
          $pb.ClientContext? ctx, GetMainchainBlockchainInfoRequest request) =>
      _client.invoke<GetMainchainBlockchainInfoResponse>(
          ctx, 'OrchestratorService', 'GetMainchainBlockchainInfo', request, GetMainchainBlockchainInfoResponse());

  /// Get blockchain info from the enforcer (proxied via orchestrator).
  $async.Future<GetEnforcerBlockchainInfoResponse> getEnforcerBlockchainInfo(
          $pb.ClientContext? ctx, GetEnforcerBlockchainInfoRequest request) =>
      _client.invoke<GetEnforcerBlockchainInfoResponse>(
          ctx, 'OrchestratorService', 'GetEnforcerBlockchainInfo', request, GetEnforcerBlockchainInfoResponse());

  /// One-shot snapshot of mainchain + enforcer + bitwindow daemon sync state.
  /// Backend fans out to all three in parallel so the three numbers are taken
  /// at the same wall-clock instant — no two cards in the UI can ever disagree.
  $async.Future<GetSyncStatusResponse> getSyncStatus($pb.ClientContext? ctx, GetSyncStatusRequest request) => _client
      .invoke<GetSyncStatusResponse>(ctx, 'OrchestratorService', 'GetSyncStatus', request, GetSyncStatusResponse());

  /// Snapshot of every binary the orchestrator is currently downloading.
  /// Reads from the in-memory DownloadManager state — light, polled by the
  /// frontend's DownloadProvider on a fast (100ms) cadence while a download
  /// is in flight, and dropping back to 2s when the response is empty.
  $async.Future<GetDownloadStatusResponse> getDownloadStatus(
          $pb.ClientContext? ctx, GetDownloadStatusRequest request) =>
      _client.invoke<GetDownloadStatusResponse>(
          ctx, 'OrchestratorService', 'GetDownloadStatus', request, GetDownloadStatusResponse());

  /// Get wallet balance from Bitcoin Core (proxied via orchestrator).
  $async.Future<GetMainchainBalanceResponse> getMainchainBalance(
          $pb.ClientContext? ctx, GetMainchainBalanceRequest request) =>
      _client.invoke<GetMainchainBalanceResponse>(
          ctx, 'OrchestratorService', 'GetMainchainBalance', request, GetMainchainBalanceResponse());

  /// Get wallet balance from a sidechain daemon (proxied via orchestrator).
  $async.Future<GetSidechainBalanceResponse> getSidechainBalance(
          $pb.ClientContext? ctx, GetSidechainBalanceRequest request) =>
      _client.invoke<GetSidechainBalanceResponse>(
          ctx, 'OrchestratorService', 'GetSidechainBalance', request, GetSidechainBalanceResponse());

  /// Gather the files/dirs that would be deleted for a per-binary deletion spec
  /// (no side effects). Shared by the single-binary wipe and the full reset page.
  $async.Future<GatherFilesToDeleteResponse> gatherFilesToDelete(
          $pb.ClientContext? ctx, GatherFilesToDeleteRequest request) =>
      _client.invoke<GatherFilesToDeleteResponse>(
          ctx, 'OrchestratorService', 'GatherFilesToDelete', request, GatherFilesToDeleteResponse());

  /// Delete the selected files. Stops binaries first; wallet paths are moved to
  /// wallet_backups/ instead of removed. Returns a gRPC error if it can't run.
  /// Streams one message per path; an unset error means that path succeeded.
  $async.Future<DeleteFilesResponse> deleteFiles($pb.ClientContext? ctx, DeleteFilesRequest request) =>
      _client.invoke<DeleteFilesResponse>(ctx, 'OrchestratorService', 'DeleteFiles', request, DeleteFilesResponse());

  /// Drop a block Core must not follow. Core rejects it and every block above
  /// it, then follows the best remaining valid branch.
  $async.Future<RejectBlockResponse> rejectBlock($pb.ClientContext? ctx, RejectBlockRequest request) =>
      _client.invoke<RejectBlockResponse>(ctx, 'OrchestratorService', 'RejectBlock', request, RejectBlockResponse());

  /// Undo RejectBlock. Core re-checks the block and its branch, and follows it
  /// again when it has the most work.
  $async.Future<AcceptBlockResponse> acceptBlock($pb.ClientContext? ctx, AcceptBlockRequest request) =>
      _client.invoke<AcceptBlockResponse>(ctx, 'OrchestratorService', 'AcceptBlock', request, AcceptBlockResponse());

  /// Move the chain back to a block, then sync forward to the tip again. Core
  /// drops the block and every block above it, then re-validates them from
  /// disk. Streams one message per phase.
  $async.Future<ResetToBlockResponse> resetToBlock($pb.ClientContext? ctx, ResetToBlockRequest request) =>
      _client.invoke<ResetToBlockResponse>(ctx, 'OrchestratorService', 'ResetToBlock', request, ResetToBlockResponse());

  /// Full bitcoind getmempoolinfo response. Distinct from getrawmempool.
  $async.Future<GetCoreMempoolInfoResponse> getCoreMempoolInfo(
          $pb.ClientContext? ctx, GetCoreMempoolInfoRequest request) =>
      _client.invoke<GetCoreMempoolInfoResponse>(
          ctx, 'OrchestratorService', 'GetCoreMempoolInfo', request, GetCoreMempoolInfoResponse());

  /// Parent-chain state the sidechain BMM tab bids against: the tip a request
  /// targets, the fee rate it competes with, mempool depth.
  $async.Future<GetBmmContextResponse> getBmmContext($pb.ClientContext? ctx, GetBmmContextRequest request) => _client
      .invoke<GetBmmContextResponse>(ctx, 'OrchestratorService', 'GetBmmContext', request, GetBmmContextResponse());

  /// Generic raw bitcoind RPC. Optional `wallet` field routes the call to
  /// /wallet/{name} on bitcoind for wallet-scoped RPCs.
  $async.Future<CoreRawCallResponse> coreRawCall($pb.ClientContext? ctx, CoreRawCallRequest request) =>
      _client.invoke<CoreRawCallResponse>(ctx, 'OrchestratorService', 'CoreRawCall', request, CoreRawCallResponse());

  /// ─── eCash fork ───────────────────────────────────────────────────────────
  /// Report where the mainchain tip sits relative to the eCash fork height.
  /// The orchestrator is the single source of truth for the fork height; the
  /// frontend renders "fork mode" (the claim card) off fork_active. Per-wallet
  /// pre-fork coin detection and the sweep itself stay in the frontend via the
  /// existing WalletManagerService (listUnspent / sendTransaction), one call
  /// per wallet — this RPC only supplies the height.
  $async.Future<GetForkStatusResponse> getForkStatus($pb.ClientContext? ctx, GetForkStatusRequest request) => _client
      .invoke<GetForkStatusResponse>(ctx, 'OrchestratorService', 'GetForkStatus', request, GetForkStatusResponse());

  /// Read the migration plan from the daemon without changes to node files.
  $async.Future<PreviewECashMigrationResponse> previewECashMigration(
          $pb.ClientContext? ctx, PreviewECashMigrationRequest request) =>
      _client.invoke<PreviewECashMigrationResponse>(
          ctx, 'OrchestratorService', 'PreviewECashMigration', request, PreviewECashMigrationResponse());

  /// Start or resume a migration that continues after the client disconnects.
  $async.Future<StartECashMigrationResponse> startECashMigration(
          $pb.ClientContext? ctx, StartECashMigrationRequest request) =>
      _client.invoke<StartECashMigrationResponse>(
          ctx, 'OrchestratorService', 'StartECashMigration', request, StartECashMigrationResponse());

  /// Read the saved migration state from the daemon.
  $async.Future<GetECashMigrationStatusResponse> getECashMigrationStatus(
          $pb.ClientContext? ctx, GetECashMigrationStatusRequest request) =>
      _client.invoke<GetECashMigrationStatusResponse>(
          ctx, 'OrchestratorService', 'GetECashMigrationStatus', request, GetECashMigrationStatusResponse());

  /// Read the network the blocks on disk belong to, next to the one the app
  /// runs. The blocks name the chain, so a datadir from another network says so
  /// before a rollback throws the balance away.
  $async.Future<GetDatadirNetworkResponse> getDatadirNetwork(
          $pb.ClientContext? ctx, GetDatadirNetworkRequest request) =>
      _client.invoke<GetDatadirNetworkResponse>(
          ctx, 'OrchestratorService', 'GetDatadirNetwork', request, GetDatadirNetworkResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
