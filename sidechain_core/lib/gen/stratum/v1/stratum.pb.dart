// This is a generated file - do not edit.
//
// Generated from stratum/v1/stratum.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $0;

import 'stratum.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'stratum.pbenum.dart';

class StartStratumRequest extends $pb.GeneratedMessage {
  factory StartStratumRequest({
    $core.int? port,
  }) {
    final result = StartStratumRequest._();
    if (port != null) result.port = port;
    return result;
  }

  StartStratumRequest._();

  factory StartStratumRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartStratumRequest()..mergeFromBuffer(data, registry);
  factory StartStratumRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartStratumRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartStratumRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: StartStratumRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'port', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartStratumRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartStratumRequest copyWith(void Function(StartStratumRequest) updates) =>
      super.copyWith((message) => updates(message as StartStratumRequest)) as StartStratumRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StartStratumRequest() / StartStratumRequest.new instead')
  static StartStratumRequest create() => StartStratumRequest._();
  static $pb.GeneratedMessage $_createMessage() => StartStratumRequest._();
  @$core.override
  StartStratumRequest createEmptyInstance() => StartStratumRequest._();
  @$core.pragma('dart2js:noInline')
  static StartStratumRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartStratumRequest>(StartStratumRequest.$_createMessage);
  static StartStratumRequest? _defaultInstance;

  /// TCP port to listen on. Zero uses 3333.
  @$pb.TagNumber(1)
  $core.int get port => $_getIZ(0);
  @$pb.TagNumber(1)
  set port($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPort() => $_has(0);
  @$pb.TagNumber(1)
  void clearPort() => $_clearField(1);
}

class StartStratumResponse extends $pb.GeneratedMessage {
  factory StartStratumResponse() => StartStratumResponse._();

  StartStratumResponse._();

  factory StartStratumResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartStratumResponse()..mergeFromBuffer(data, registry);
  factory StartStratumResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartStratumResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartStratumResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: StartStratumResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartStratumResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartStratumResponse copyWith(void Function(StartStratumResponse) updates) =>
      super.copyWith((message) => updates(message as StartStratumResponse)) as StartStratumResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StartStratumResponse() / StartStratumResponse.new instead')
  static StartStratumResponse create() => StartStratumResponse._();
  static $pb.GeneratedMessage $_createMessage() => StartStratumResponse._();
  @$core.override
  StartStratumResponse createEmptyInstance() => StartStratumResponse._();
  @$core.pragma('dart2js:noInline')
  static StartStratumResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StartStratumResponse>(StartStratumResponse.$_createMessage);
  static StartStratumResponse? _defaultInstance;
}

class StopStratumRequest extends $pb.GeneratedMessage {
  factory StopStratumRequest() => StopStratumRequest._();

  StopStratumRequest._();

  factory StopStratumRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopStratumRequest()..mergeFromBuffer(data, registry);
  factory StopStratumRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopStratumRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopStratumRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: StopStratumRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopStratumRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopStratumRequest copyWith(void Function(StopStratumRequest) updates) =>
      super.copyWith((message) => updates(message as StopStratumRequest)) as StopStratumRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StopStratumRequest() / StopStratumRequest.new instead')
  static StopStratumRequest create() => StopStratumRequest._();
  static $pb.GeneratedMessage $_createMessage() => StopStratumRequest._();
  @$core.override
  StopStratumRequest createEmptyInstance() => StopStratumRequest._();
  @$core.pragma('dart2js:noInline')
  static StopStratumRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopStratumRequest>(StopStratumRequest.$_createMessage);
  static StopStratumRequest? _defaultInstance;
}

class StopStratumResponse extends $pb.GeneratedMessage {
  factory StopStratumResponse() => StopStratumResponse._();

  StopStratumResponse._();

  factory StopStratumResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopStratumResponse()..mergeFromBuffer(data, registry);
  factory StopStratumResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopStratumResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopStratumResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: StopStratumResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopStratumResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopStratumResponse copyWith(void Function(StopStratumResponse) updates) =>
      super.copyWith((message) => updates(message as StopStratumResponse)) as StopStratumResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StopStratumResponse() / StopStratumResponse.new instead')
  static StopStratumResponse create() => StopStratumResponse._();
  static $pb.GeneratedMessage $_createMessage() => StopStratumResponse._();
  @$core.override
  StopStratumResponse createEmptyInstance() => StopStratumResponse._();
  @$core.pragma('dart2js:noInline')
  static StopStratumResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopStratumResponse>(StopStratumResponse.$_createMessage);
  static StopStratumResponse? _defaultInstance;
}

class GetStratumStatusRequest extends $pb.GeneratedMessage {
  factory GetStratumStatusRequest() => GetStratumStatusRequest._();

  GetStratumStatusRequest._();

  factory GetStratumStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetStratumStatusRequest()..mergeFromBuffer(data, registry);
  factory GetStratumStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetStratumStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetStratumStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: GetStratumStatusRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStratumStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStratumStatusRequest copyWith(void Function(GetStratumStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetStratumStatusRequest)) as GetStratumStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetStratumStatusRequest() / GetStratumStatusRequest.new instead')
  static GetStratumStatusRequest create() => GetStratumStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetStratumStatusRequest._();
  @$core.override
  GetStratumStatusRequest createEmptyInstance() => GetStratumStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static GetStratumStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStratumStatusRequest>(GetStratumStatusRequest.$_createMessage);
  static GetStratumStatusRequest? _defaultInstance;
}

class Target extends $pb.GeneratedMessage {
  factory Target({
    TargetKind? kind,
    $core.String? poolId,
    $core.String? url,
    $core.String? worker,
    $core.String? password,
  }) {
    final result = Target._();
    if (kind != null) result.kind = kind;
    if (poolId != null) result.poolId = poolId;
    if (url != null) result.url = url;
    if (worker != null) result.worker = worker;
    if (password != null) result.password = password;
    return result;
  }

  Target._();

  factory Target.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Target()..mergeFromBuffer(data, registry);
  factory Target.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Target()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Target',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: Target.$_createMessage)
    ..aE<TargetKind>(1, _omitFieldNames ? '' : 'kind', enumValues: TargetKind.values)
    ..aOS(2, _omitFieldNames ? '' : 'poolId')
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..aOS(4, _omitFieldNames ? '' : 'worker')
    ..aOS(5, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Target clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Target copyWith(void Function(Target) updates) => super.copyWith((message) => updates(message as Target)) as Target;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Target() / Target.new instead')
  static Target create() => Target._();
  static $pb.GeneratedMessage $_createMessage() => Target._();
  @$core.override
  Target createEmptyInstance() => Target._();
  @$core.pragma('dart2js:noInline')
  static Target getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Target>(Target.$_createMessage);
  static Target? _defaultInstance;

  @$pb.TagNumber(1)
  TargetKind get kind => $_getN(0);
  @$pb.TagNumber(1)
  set kind(TargetKind value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => $_clearField(1);

  /// Catalog pool id when kind is TARGET_KIND_POOL.
  @$pb.TagNumber(2)
  $core.String get poolId => $_getSZ(1);
  @$pb.TagNumber(2)
  set poolId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPoolId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPoolId() => $_clearField(2);

  /// stratum+tcp URL, worker and password when kind is TARGET_KIND_CUSTOM.
  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get worker => $_getSZ(3);
  @$pb.TagNumber(4)
  set worker($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWorker() => $_has(3);
  @$pb.TagNumber(4)
  void clearWorker() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get password => $_getSZ(4);
  @$pb.TagNumber(5)
  set password($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPassword() => $_has(4);
  @$pb.TagNumber(5)
  void clearPassword() => $_clearField(5);
}

class MiningSettings extends $pb.GeneratedMessage {
  factory MiningSettings({
    $core.int? port,
    $core.bool? cpuMining,
    $core.int? cpuThreads,
    $core.bool? keepMiningOnClose,
    $core.double? minDifficulty,
  }) {
    final result = MiningSettings._();
    if (port != null) result.port = port;
    if (cpuMining != null) result.cpuMining = cpuMining;
    if (cpuThreads != null) result.cpuThreads = cpuThreads;
    if (keepMiningOnClose != null) result.keepMiningOnClose = keepMiningOnClose;
    if (minDifficulty != null) result.minDifficulty = minDifficulty;
    return result;
  }

  MiningSettings._();

  factory MiningSettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MiningSettings()..mergeFromBuffer(data, registry);
  factory MiningSettings.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MiningSettings()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MiningSettings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: MiningSettings.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'port', fieldType: $pb.PbFieldType.OU3)
    ..aOB(2, _omitFieldNames ? '' : 'cpuMining')
    ..aI(3, _omitFieldNames ? '' : 'cpuThreads', fieldType: $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'keepMiningOnClose')
    ..aD(5, _omitFieldNames ? '' : 'minDifficulty')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MiningSettings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MiningSettings copyWith(void Function(MiningSettings) updates) =>
      super.copyWith((message) => updates(message as MiningSettings)) as MiningSettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MiningSettings() / MiningSettings.new instead')
  static MiningSettings create() => MiningSettings._();
  static $pb.GeneratedMessage $_createMessage() => MiningSettings._();
  @$core.override
  MiningSettings createEmptyInstance() => MiningSettings._();
  @$core.pragma('dart2js:noInline')
  static MiningSettings getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MiningSettings>(MiningSettings.$_createMessage);
  static MiningSettings? _defaultInstance;

  /// TCP port the Stratum server listens on.
  @$pb.TagNumber(1)
  $core.int get port => $_getIZ(0);
  @$pb.TagNumber(1)
  set port($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPort() => $_has(0);
  @$pb.TagNumber(1)
  void clearPort() => $_clearField(1);

  /// Whether the hasher on this computer runs.
  @$pb.TagNumber(2)
  $core.bool get cpuMining => $_getBF(1);
  @$pb.TagNumber(2)
  set cpuMining($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCpuMining() => $_has(1);
  @$pb.TagNumber(2)
  void clearCpuMining() => $_clearField(2);

  /// Hash threads the hasher runs.
  @$pb.TagNumber(3)
  $core.int get cpuThreads => $_getIZ(2);
  @$pb.TagNumber(3)
  set cpuThreads($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCpuThreads() => $_has(2);
  @$pb.TagNumber(3)
  void clearCpuThreads() => $_clearField(3);

  /// Whether the miners keep going after the app window closes.
  @$pb.TagNumber(4)
  $core.bool get keepMiningOnClose => $_getBF(3);
  @$pb.TagNumber(4)
  set keepMiningOnClose($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasKeepMiningOnClose() => $_has(3);
  @$pb.TagNumber(4)
  void clearKeepMiningOnClose() => $_clearField(4);

  /// Lowest share difficulty of a network miner. Zero means no floor.
  @$pb.TagNumber(5)
  $core.double get minDifficulty => $_getN(4);
  @$pb.TagNumber(5)
  set minDifficulty($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMinDifficulty() => $_has(4);
  @$pb.TagNumber(5)
  void clearMinDifficulty() => $_clearField(5);
}

class SetMiningSettingsRequest extends $pb.GeneratedMessage {
  factory SetMiningSettingsRequest({
    $core.int? port,
    $core.bool? cpuMining,
    $core.int? cpuThreads,
    $core.bool? keepMiningOnClose,
    $core.double? minDifficulty,
  }) {
    final result = SetMiningSettingsRequest._();
    if (port != null) result.port = port;
    if (cpuMining != null) result.cpuMining = cpuMining;
    if (cpuThreads != null) result.cpuThreads = cpuThreads;
    if (keepMiningOnClose != null) result.keepMiningOnClose = keepMiningOnClose;
    if (minDifficulty != null) result.minDifficulty = minDifficulty;
    return result;
  }

  SetMiningSettingsRequest._();

  factory SetMiningSettingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetMiningSettingsRequest()..mergeFromBuffer(data, registry);
  factory SetMiningSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetMiningSettingsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetMiningSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: SetMiningSettingsRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'port', fieldType: $pb.PbFieldType.OU3)
    ..aOB(2, _omitFieldNames ? '' : 'cpuMining')
    ..aI(3, _omitFieldNames ? '' : 'cpuThreads', fieldType: $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'keepMiningOnClose')
    ..aD(5, _omitFieldNames ? '' : 'minDifficulty')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMiningSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMiningSettingsRequest copyWith(void Function(SetMiningSettingsRequest) updates) =>
      super.copyWith((message) => updates(message as SetMiningSettingsRequest)) as SetMiningSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetMiningSettingsRequest() / SetMiningSettingsRequest.new instead')
  static SetMiningSettingsRequest create() => SetMiningSettingsRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetMiningSettingsRequest._();
  @$core.override
  SetMiningSettingsRequest createEmptyInstance() => SetMiningSettingsRequest._();
  @$core.pragma('dart2js:noInline')
  static SetMiningSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetMiningSettingsRequest>(SetMiningSettingsRequest.$_createMessage);
  static SetMiningSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get port => $_getIZ(0);
  @$pb.TagNumber(1)
  set port($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPort() => $_has(0);
  @$pb.TagNumber(1)
  void clearPort() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get cpuMining => $_getBF(1);
  @$pb.TagNumber(2)
  set cpuMining($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCpuMining() => $_has(1);
  @$pb.TagNumber(2)
  void clearCpuMining() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get cpuThreads => $_getIZ(2);
  @$pb.TagNumber(3)
  set cpuThreads($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCpuThreads() => $_has(2);
  @$pb.TagNumber(3)
  void clearCpuThreads() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get keepMiningOnClose => $_getBF(3);
  @$pb.TagNumber(4)
  set keepMiningOnClose($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasKeepMiningOnClose() => $_has(3);
  @$pb.TagNumber(4)
  void clearKeepMiningOnClose() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get minDifficulty => $_getN(4);
  @$pb.TagNumber(5)
  set minDifficulty($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMinDifficulty() => $_has(4);
  @$pb.TagNumber(5)
  void clearMinDifficulty() => $_clearField(5);
}

class SetMiningSettingsResponse extends $pb.GeneratedMessage {
  factory SetMiningSettingsResponse() => SetMiningSettingsResponse._();

  SetMiningSettingsResponse._();

  factory SetMiningSettingsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetMiningSettingsResponse()..mergeFromBuffer(data, registry);
  factory SetMiningSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetMiningSettingsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetMiningSettingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: SetMiningSettingsResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMiningSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMiningSettingsResponse copyWith(void Function(SetMiningSettingsResponse) updates) =>
      super.copyWith((message) => updates(message as SetMiningSettingsResponse)) as SetMiningSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetMiningSettingsResponse() / SetMiningSettingsResponse.new instead')
  static SetMiningSettingsResponse create() => SetMiningSettingsResponse._();
  static $pb.GeneratedMessage $_createMessage() => SetMiningSettingsResponse._();
  @$core.override
  SetMiningSettingsResponse createEmptyInstance() => SetMiningSettingsResponse._();
  @$core.pragma('dart2js:noInline')
  static SetMiningSettingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetMiningSettingsResponse>(SetMiningSettingsResponse.$_createMessage);
  static SetMiningSettingsResponse? _defaultInstance;
}

class HashratePoint extends $pb.GeneratedMessage {
  factory HashratePoint({
    $0.Timestamp? time,
    $core.double? hashrate,
  }) {
    final result = HashratePoint._();
    if (time != null) result.time = time;
    if (hashrate != null) result.hashrate = hashrate;
    return result;
  }

  HashratePoint._();

  factory HashratePoint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HashratePoint()..mergeFromBuffer(data, registry);
  factory HashratePoint.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HashratePoint()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HashratePoint',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: HashratePoint.$_createMessage)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'time', subBuilder: $0.Timestamp.$_createMessage)
    ..aD(2, _omitFieldNames ? '' : 'hashrate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HashratePoint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HashratePoint copyWith(void Function(HashratePoint) updates) =>
      super.copyWith((message) => updates(message as HashratePoint)) as HashratePoint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HashratePoint() / HashratePoint.new instead')
  static HashratePoint create() => HashratePoint._();
  static $pb.GeneratedMessage $_createMessage() => HashratePoint._();
  @$core.override
  HashratePoint createEmptyInstance() => HashratePoint._();
  @$core.pragma('dart2js:noInline')
  static HashratePoint getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HashratePoint>(HashratePoint.$_createMessage);
  static HashratePoint? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Timestamp get time => $_getN(0);
  @$pb.TagNumber(1)
  set time($0.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearTime() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureTime() => $_ensure(0);

  /// Hashes per second of all miners together over the bucket.
  @$pb.TagNumber(2)
  $core.double get hashrate => $_getN(1);
  @$pb.TagNumber(2)
  set hashrate($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHashrate() => $_has(1);
  @$pb.TagNumber(2)
  void clearHashrate() => $_clearField(2);
}

class GetHashrateHistoryRequest extends $pb.GeneratedMessage {
  factory GetHashrateHistoryRequest({
    HashrateRange? range,
  }) {
    final result = GetHashrateHistoryRequest._();
    if (range != null) result.range = range;
    return result;
  }

  GetHashrateHistoryRequest._();

  factory GetHashrateHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetHashrateHistoryRequest()..mergeFromBuffer(data, registry);
  factory GetHashrateHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetHashrateHistoryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetHashrateHistoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: GetHashrateHistoryRequest.$_createMessage)
    ..aE<HashrateRange>(1, _omitFieldNames ? '' : 'range', enumValues: HashrateRange.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHashrateHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHashrateHistoryRequest copyWith(void Function(GetHashrateHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as GetHashrateHistoryRequest)) as GetHashrateHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetHashrateHistoryRequest() / GetHashrateHistoryRequest.new instead')
  static GetHashrateHistoryRequest create() => GetHashrateHistoryRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetHashrateHistoryRequest._();
  @$core.override
  GetHashrateHistoryRequest createEmptyInstance() => GetHashrateHistoryRequest._();
  @$core.pragma('dart2js:noInline')
  static GetHashrateHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHashrateHistoryRequest>(GetHashrateHistoryRequest.$_createMessage);
  static GetHashrateHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  HashrateRange get range => $_getN(0);
  @$pb.TagNumber(1)
  set range(HashrateRange value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRange() => $_has(0);
  @$pb.TagNumber(1)
  void clearRange() => $_clearField(1);
}

class GetHashrateHistoryResponse extends $pb.GeneratedMessage {
  factory GetHashrateHistoryResponse({
    $core.Iterable<HashratePoint>? points,
    $core.double? peak,
    $core.double? current,
  }) {
    final result = GetHashrateHistoryResponse._();
    if (points != null) result.points.addAll(points);
    if (peak != null) result.peak = peak;
    if (current != null) result.current = current;
    return result;
  }

  GetHashrateHistoryResponse._();

  factory GetHashrateHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetHashrateHistoryResponse()..mergeFromBuffer(data, registry);
  factory GetHashrateHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetHashrateHistoryResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetHashrateHistoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: GetHashrateHistoryResponse.$_createMessage)
    ..pPM<HashratePoint>(1, _omitFieldNames ? '' : 'points', subBuilder: HashratePoint.$_createMessage)
    ..aD(2, _omitFieldNames ? '' : 'peak')
    ..aD(3, _omitFieldNames ? '' : 'current')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHashrateHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHashrateHistoryResponse copyWith(void Function(GetHashrateHistoryResponse) updates) =>
      super.copyWith((message) => updates(message as GetHashrateHistoryResponse)) as GetHashrateHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetHashrateHistoryResponse() / GetHashrateHistoryResponse.new instead')
  static GetHashrateHistoryResponse create() => GetHashrateHistoryResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetHashrateHistoryResponse._();
  @$core.override
  GetHashrateHistoryResponse createEmptyInstance() => GetHashrateHistoryResponse._();
  @$core.pragma('dart2js:noInline')
  static GetHashrateHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHashrateHistoryResponse>(GetHashrateHistoryResponse.$_createMessage);
  static GetHashrateHistoryResponse? _defaultInstance;

  /// Oldest first. A bucket with no miner reads zero.
  @$pb.TagNumber(1)
  $pb.PbList<HashratePoint> get points => $_getList(0);

  /// Highest bucket of the range.
  @$pb.TagNumber(2)
  $core.double get peak => $_getN(1);
  @$pb.TagNumber(2)
  set peak($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeak() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeak() => $_clearField(2);

  /// Hashrate right now.
  @$pb.TagNumber(3)
  $core.double get current => $_getN(2);
  @$pb.TagNumber(3)
  set current($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCurrent() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrent() => $_clearField(3);
}

class PoolBlock extends $pb.GeneratedMessage {
  factory PoolBlock({
    $core.int? height,
    $core.String? hash,
    $fixnum.Int64? rewardSats,
    $fixnum.Int64? feeSats,
    $core.String? finder,
    $fixnum.Int64? myPayoutSats,
    $core.bool? mine,
    $core.int? confirmations,
    $0.Timestamp? foundTime,
  }) {
    final result = PoolBlock._();
    if (height != null) result.height = height;
    if (hash != null) result.hash = hash;
    if (rewardSats != null) result.rewardSats = rewardSats;
    if (feeSats != null) result.feeSats = feeSats;
    if (finder != null) result.finder = finder;
    if (myPayoutSats != null) result.myPayoutSats = myPayoutSats;
    if (mine != null) result.mine = mine;
    if (confirmations != null) result.confirmations = confirmations;
    if (foundTime != null) result.foundTime = foundTime;
    return result;
  }

  PoolBlock._();

  factory PoolBlock.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PoolBlock()..mergeFromBuffer(data, registry);
  factory PoolBlock.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PoolBlock()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PoolBlock',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: PoolBlock.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..aInt64(3, _omitFieldNames ? '' : 'rewardSats')
    ..aInt64(4, _omitFieldNames ? '' : 'feeSats')
    ..aOS(5, _omitFieldNames ? '' : 'finder')
    ..aInt64(6, _omitFieldNames ? '' : 'myPayoutSats')
    ..aOB(7, _omitFieldNames ? '' : 'mine')
    ..aI(8, _omitFieldNames ? '' : 'confirmations')
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'foundTime', subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PoolBlock clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PoolBlock copyWith(void Function(PoolBlock) updates) =>
      super.copyWith((message) => updates(message as PoolBlock)) as PoolBlock;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PoolBlock() / PoolBlock.new instead')
  static PoolBlock create() => PoolBlock._();
  static $pb.GeneratedMessage $_createMessage() => PoolBlock._();
  @$core.override
  PoolBlock createEmptyInstance() => PoolBlock._();
  @$core.pragma('dart2js:noInline')
  static PoolBlock getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PoolBlock>(PoolBlock.$_createMessage);
  static PoolBlock? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get height => $_getIZ(0);
  @$pb.TagNumber(1)
  set height($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => $_clearField(2);

  /// What the pool paid out for the block.
  @$pb.TagNumber(3)
  $fixnum.Int64 get rewardSats => $_getI64(2);
  @$pb.TagNumber(3)
  set rewardSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRewardSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearRewardSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSats() => $_clearField(4);

  /// Worker name the pool credits.
  @$pb.TagNumber(5)
  $core.String get finder => $_getSZ(4);
  @$pb.TagNumber(5)
  set finder($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFinder() => $_has(4);
  @$pb.TagNumber(5)
  void clearFinder() => $_clearField(5);

  /// Sats the coinbase of the block pays to the payout address. Unset when
  /// the local node does not give the block.
  @$pb.TagNumber(6)
  $fixnum.Int64 get myPayoutSats => $_getI64(5);
  @$pb.TagNumber(6)
  set myPayoutSats($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMyPayoutSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearMyPayoutSats() => $_clearField(6);

  /// Whether a miner on this computer found the block.
  @$pb.TagNumber(7)
  $core.bool get mine => $_getBF(6);
  @$pb.TagNumber(7)
  set mine($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMine() => $_has(6);
  @$pb.TagNumber(7)
  void clearMine() => $_clearField(7);

  /// Confirmations from the local node. Negative when the block left the main
  /// chain. Unset when the node does not answer.
  @$pb.TagNumber(8)
  $core.int get confirmations => $_getIZ(7);
  @$pb.TagNumber(8)
  set confirmations($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasConfirmations() => $_has(7);
  @$pb.TagNumber(8)
  void clearConfirmations() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get foundTime => $_getN(8);
  @$pb.TagNumber(9)
  set foundTime($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasFoundTime() => $_has(8);
  @$pb.TagNumber(9)
  void clearFoundTime() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureFoundTime() => $_ensure(8);
}

class ListPoolBlocksRequest extends $pb.GeneratedMessage {
  factory ListPoolBlocksRequest({
    $core.int? limit,
  }) {
    final result = ListPoolBlocksRequest._();
    if (limit != null) result.limit = limit;
    return result;
  }

  ListPoolBlocksRequest._();

  factory ListPoolBlocksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListPoolBlocksRequest()..mergeFromBuffer(data, registry);
  factory ListPoolBlocksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListPoolBlocksRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListPoolBlocksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: ListPoolBlocksRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'limit', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPoolBlocksRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPoolBlocksRequest copyWith(void Function(ListPoolBlocksRequest) updates) =>
      super.copyWith((message) => updates(message as ListPoolBlocksRequest)) as ListPoolBlocksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListPoolBlocksRequest() / ListPoolBlocksRequest.new instead')
  static ListPoolBlocksRequest create() => ListPoolBlocksRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListPoolBlocksRequest._();
  @$core.override
  ListPoolBlocksRequest createEmptyInstance() => ListPoolBlocksRequest._();
  @$core.pragma('dart2js:noInline')
  static ListPoolBlocksRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPoolBlocksRequest>(ListPoolBlocksRequest.$_createMessage);
  static ListPoolBlocksRequest? _defaultInstance;

  /// Blocks to return. Zero returns 20.
  @$pb.TagNumber(1)
  $core.int get limit => $_getIZ(0);
  @$pb.TagNumber(1)
  set limit($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLimit() => $_has(0);
  @$pb.TagNumber(1)
  void clearLimit() => $_clearField(1);
}

class ListPoolBlocksResponse extends $pb.GeneratedMessage {
  factory ListPoolBlocksResponse({
    $core.Iterable<PoolBlock>? blocks,
    $core.String? unavailable,
  }) {
    final result = ListPoolBlocksResponse._();
    if (blocks != null) result.blocks.addAll(blocks);
    if (unavailable != null) result.unavailable = unavailable;
    return result;
  }

  ListPoolBlocksResponse._();

  factory ListPoolBlocksResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListPoolBlocksResponse()..mergeFromBuffer(data, registry);
  factory ListPoolBlocksResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListPoolBlocksResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListPoolBlocksResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: ListPoolBlocksResponse.$_createMessage)
    ..pPM<PoolBlock>(1, _omitFieldNames ? '' : 'blocks', subBuilder: PoolBlock.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'unavailable')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPoolBlocksResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPoolBlocksResponse copyWith(void Function(ListPoolBlocksResponse) updates) =>
      super.copyWith((message) => updates(message as ListPoolBlocksResponse)) as ListPoolBlocksResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListPoolBlocksResponse() / ListPoolBlocksResponse.new instead')
  static ListPoolBlocksResponse create() => ListPoolBlocksResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListPoolBlocksResponse._();
  @$core.override
  ListPoolBlocksResponse createEmptyInstance() => ListPoolBlocksResponse._();
  @$core.pragma('dart2js:noInline')
  static ListPoolBlocksResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPoolBlocksResponse>(ListPoolBlocksResponse.$_createMessage);
  static ListPoolBlocksResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PoolBlock> get blocks => $_getList(0);

  /// Why the list is empty, such as a pool that publishes no blocks. Empty
  /// when the pool answered.
  @$pb.TagNumber(2)
  $core.String get unavailable => $_getSZ(1);
  @$pb.TagNumber(2)
  set unavailable($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUnavailable() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnavailable() => $_clearField(2);
}

class AcceptedShare extends $pb.GeneratedMessage {
  factory AcceptedShare({
    $0.Timestamp? time,
    $core.String? worker,
    $core.double? target,
    $core.double? actual,
    $core.String? hash,
    $core.bool? block,
  }) {
    final result = AcceptedShare._();
    if (time != null) result.time = time;
    if (worker != null) result.worker = worker;
    if (target != null) result.target = target;
    if (actual != null) result.actual = actual;
    if (hash != null) result.hash = hash;
    if (block != null) result.block = block;
    return result;
  }

  AcceptedShare._();

  factory AcceptedShare.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AcceptedShare()..mergeFromBuffer(data, registry);
  factory AcceptedShare.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AcceptedShare()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AcceptedShare',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: AcceptedShare.$_createMessage)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'time', subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'worker')
    ..aD(3, _omitFieldNames ? '' : 'target')
    ..aD(4, _omitFieldNames ? '' : 'actual')
    ..aOS(5, _omitFieldNames ? '' : 'hash')
    ..aOB(6, _omitFieldNames ? '' : 'block')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptedShare clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptedShare copyWith(void Function(AcceptedShare) updates) =>
      super.copyWith((message) => updates(message as AcceptedShare)) as AcceptedShare;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AcceptedShare() / AcceptedShare.new instead')
  static AcceptedShare create() => AcceptedShare._();
  static $pb.GeneratedMessage $_createMessage() => AcceptedShare._();
  @$core.override
  AcceptedShare createEmptyInstance() => AcceptedShare._();
  @$core.pragma('dart2js:noInline')
  static AcceptedShare getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AcceptedShare>(AcceptedShare.$_createMessage);
  static AcceptedShare? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Timestamp get time => $_getN(0);
  @$pb.TagNumber(1)
  set time($0.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearTime() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureTime() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get worker => $_getSZ(1);
  @$pb.TagNumber(2)
  set worker($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWorker() => $_has(1);
  @$pb.TagNumber(2)
  void clearWorker() => $_clearField(2);

  /// Difficulty the share had to reach.
  @$pb.TagNumber(3)
  $core.double get target => $_getN(2);
  @$pb.TagNumber(3)
  set target($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTarget() => $_has(2);
  @$pb.TagNumber(3)
  void clearTarget() => $_clearField(3);

  /// Difficulty the share reached.
  @$pb.TagNumber(4)
  $core.double get actual => $_getN(3);
  @$pb.TagNumber(4)
  set actual($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasActual() => $_has(3);
  @$pb.TagNumber(4)
  void clearActual() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get hash => $_getSZ(4);
  @$pb.TagNumber(5)
  set hash($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHash() => $_has(4);
  @$pb.TagNumber(5)
  void clearHash() => $_clearField(5);

  /// Whether the share completed a block.
  @$pb.TagNumber(6)
  $core.bool get block => $_getBF(5);
  @$pb.TagNumber(6)
  set block($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBlock() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlock() => $_clearField(6);
}

class ConnectedMiner extends $pb.GeneratedMessage {
  factory ConnectedMiner({
    $core.String? worker,
    $core.String? address,
    $core.double? hashrate,
    $core.double? bestShare,
    $fixnum.Int64? acceptedShares,
    $fixnum.Int64? rejectedShares,
    $0.Timestamp? lastShareTime,
    $core.double? temperatureCelsius,
    $core.double? fanPercent,
    $core.double? powerWatts,
    WorkMode? workMode,
  }) {
    final result = ConnectedMiner._();
    if (worker != null) result.worker = worker;
    if (address != null) result.address = address;
    if (hashrate != null) result.hashrate = hashrate;
    if (bestShare != null) result.bestShare = bestShare;
    if (acceptedShares != null) result.acceptedShares = acceptedShares;
    if (rejectedShares != null) result.rejectedShares = rejectedShares;
    if (lastShareTime != null) result.lastShareTime = lastShareTime;
    if (temperatureCelsius != null) result.temperatureCelsius = temperatureCelsius;
    if (fanPercent != null) result.fanPercent = fanPercent;
    if (powerWatts != null) result.powerWatts = powerWatts;
    if (workMode != null) result.workMode = workMode;
    return result;
  }

  ConnectedMiner._();

  factory ConnectedMiner.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectedMiner()..mergeFromBuffer(data, registry);
  factory ConnectedMiner.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectedMiner()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectedMiner',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: ConnectedMiner.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'worker')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aD(3, _omitFieldNames ? '' : 'hashrate')
    ..aD(4, _omitFieldNames ? '' : 'bestShare')
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'acceptedShares', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(6, _omitFieldNames ? '' : 'rejectedShares', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'lastShareTime', subBuilder: $0.Timestamp.$_createMessage)
    ..aD(8, _omitFieldNames ? '' : 'temperatureCelsius')
    ..aD(9, _omitFieldNames ? '' : 'fanPercent')
    ..aD(10, _omitFieldNames ? '' : 'powerWatts')
    ..aE<WorkMode>(11, _omitFieldNames ? '' : 'workMode', enumValues: WorkMode.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectedMiner clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectedMiner copyWith(void Function(ConnectedMiner) updates) =>
      super.copyWith((message) => updates(message as ConnectedMiner)) as ConnectedMiner;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConnectedMiner() / ConnectedMiner.new instead')
  static ConnectedMiner create() => ConnectedMiner._();
  static $pb.GeneratedMessage $_createMessage() => ConnectedMiner._();
  @$core.override
  ConnectedMiner createEmptyInstance() => ConnectedMiner._();
  @$core.pragma('dart2js:noInline')
  static ConnectedMiner getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConnectedMiner>(ConnectedMiner.$_createMessage);
  static ConnectedMiner? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get worker => $_getSZ(0);
  @$pb.TagNumber(1)
  set worker($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorker() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorker() => $_clearField(1);

  /// IP address the miner connects from. The hasher on this computer reads
  /// "this computer".
  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);

  /// Hashes per second over the last five minutes.
  @$pb.TagNumber(3)
  $core.double get hashrate => $_getN(2);
  @$pb.TagNumber(3)
  set hashrate($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHashrate() => $_has(2);
  @$pb.TagNumber(3)
  void clearHashrate() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get bestShare => $_getN(3);
  @$pb.TagNumber(4)
  set bestShare($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBestShare() => $_has(3);
  @$pb.TagNumber(4)
  void clearBestShare() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get acceptedShares => $_getI64(4);
  @$pb.TagNumber(5)
  set acceptedShares($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAcceptedShares() => $_has(4);
  @$pb.TagNumber(5)
  void clearAcceptedShares() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get rejectedShares => $_getI64(5);
  @$pb.TagNumber(6)
  set rejectedShares($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRejectedShares() => $_has(5);
  @$pb.TagNumber(6)
  void clearRejectedShares() => $_clearField(6);

  /// Unset until the miner sends a share.
  @$pb.TagNumber(7)
  $0.Timestamp get lastShareTime => $_getN(6);
  @$pb.TagNumber(7)
  set lastShareTime($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasLastShareTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearLastShareTime() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureLastShareTime() => $_ensure(6);

  /// Values from the miner's device API. Unset when the device does not answer.
  @$pb.TagNumber(8)
  $core.double get temperatureCelsius => $_getN(7);
  @$pb.TagNumber(8)
  set temperatureCelsius($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTemperatureCelsius() => $_has(7);
  @$pb.TagNumber(8)
  void clearTemperatureCelsius() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get fanPercent => $_getN(8);
  @$pb.TagNumber(9)
  set fanPercent($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFanPercent() => $_has(8);
  @$pb.TagNumber(9)
  void clearFanPercent() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get powerWatts => $_getN(9);
  @$pb.TagNumber(10)
  set powerWatts($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPowerWatts() => $_has(9);
  @$pb.TagNumber(10)
  void clearPowerWatts() => $_clearField(10);

  @$pb.TagNumber(11)
  WorkMode get workMode => $_getN(10);
  @$pb.TagNumber(11)
  set workMode(WorkMode value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasWorkMode() => $_has(10);
  @$pb.TagNumber(11)
  void clearWorkMode() => $_clearField(11);
}

class FoundBlock extends $pb.GeneratedMessage {
  factory FoundBlock({
    $core.int? height,
    $core.String? hash,
    $fixnum.Int64? rewardSats,
    $core.String? worker,
    $0.Timestamp? foundTime,
    $core.int? confirmations,
  }) {
    final result = FoundBlock._();
    if (height != null) result.height = height;
    if (hash != null) result.hash = hash;
    if (rewardSats != null) result.rewardSats = rewardSats;
    if (worker != null) result.worker = worker;
    if (foundTime != null) result.foundTime = foundTime;
    if (confirmations != null) result.confirmations = confirmations;
    return result;
  }

  FoundBlock._();

  factory FoundBlock.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FoundBlock()..mergeFromBuffer(data, registry);
  factory FoundBlock.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FoundBlock()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FoundBlock',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: FoundBlock.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..aInt64(3, _omitFieldNames ? '' : 'rewardSats')
    ..aOS(4, _omitFieldNames ? '' : 'worker')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'foundTime', subBuilder: $0.Timestamp.$_createMessage)
    ..aI(6, _omitFieldNames ? '' : 'confirmations')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FoundBlock clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FoundBlock copyWith(void Function(FoundBlock) updates) =>
      super.copyWith((message) => updates(message as FoundBlock)) as FoundBlock;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FoundBlock() / FoundBlock.new instead')
  static FoundBlock create() => FoundBlock._();
  static $pb.GeneratedMessage $_createMessage() => FoundBlock._();
  @$core.override
  FoundBlock createEmptyInstance() => FoundBlock._();
  @$core.pragma('dart2js:noInline')
  static FoundBlock getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FoundBlock>(FoundBlock.$_createMessage);
  static FoundBlock? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get height => $_getIZ(0);
  @$pb.TagNumber(1)
  set height($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get rewardSats => $_getI64(2);
  @$pb.TagNumber(3)
  set rewardSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRewardSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearRewardSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get worker => $_getSZ(3);
  @$pb.TagNumber(4)
  set worker($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWorker() => $_has(3);
  @$pb.TagNumber(4)
  void clearWorker() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get foundTime => $_getN(4);
  @$pb.TagNumber(5)
  set foundTime($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasFoundTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearFoundTime() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureFoundTime() => $_ensure(4);

  /// Confirmations from the local node. Negative when the block left the main
  /// chain. Unset when the node does not answer.
  @$pb.TagNumber(6)
  $core.int get confirmations => $_getIZ(5);
  @$pb.TagNumber(6)
  set confirmations($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasConfirmations() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfirmations() => $_clearField(6);
}

class GetStratumStatusResponse extends $pb.GeneratedMessage {
  factory GetStratumStatusResponse({
    $core.bool? running,
    $core.int? port,
    $core.String? poolUrl,
    $core.double? hashrate,
    $core.double? bestShare,
    $core.double? networkDifficulty,
    $core.Iterable<FoundBlock>? blocksFound,
    $core.Iterable<ConnectedMiner>? miners,
    $core.String? error,
    Target? target,
    $core.bool? poolConnected,
    $core.String? poolHost,
    $core.String? payoutAddress,
    $fixnum.Int64? acceptedShares,
    $fixnum.Int64? rejectedShares,
    MiningSettings? settings,
    $core.Iterable<AcceptedShare>? recentShares,
    $core.double? networkHashrate,
    $core.bool? bestShareWon,
  }) {
    final result = GetStratumStatusResponse._();
    if (running != null) result.running = running;
    if (port != null) result.port = port;
    if (poolUrl != null) result.poolUrl = poolUrl;
    if (hashrate != null) result.hashrate = hashrate;
    if (bestShare != null) result.bestShare = bestShare;
    if (networkDifficulty != null) result.networkDifficulty = networkDifficulty;
    if (blocksFound != null) result.blocksFound.addAll(blocksFound);
    if (miners != null) result.miners.addAll(miners);
    if (error != null) result.error = error;
    if (target != null) result.target = target;
    if (poolConnected != null) result.poolConnected = poolConnected;
    if (poolHost != null) result.poolHost = poolHost;
    if (payoutAddress != null) result.payoutAddress = payoutAddress;
    if (acceptedShares != null) result.acceptedShares = acceptedShares;
    if (rejectedShares != null) result.rejectedShares = rejectedShares;
    if (settings != null) result.settings = settings;
    if (recentShares != null) result.recentShares.addAll(recentShares);
    if (networkHashrate != null) result.networkHashrate = networkHashrate;
    if (bestShareWon != null) result.bestShareWon = bestShareWon;
    return result;
  }

  GetStratumStatusResponse._();

  factory GetStratumStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetStratumStatusResponse()..mergeFromBuffer(data, registry);
  factory GetStratumStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetStratumStatusResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetStratumStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: GetStratumStatusResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'running')
    ..aI(2, _omitFieldNames ? '' : 'port', fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'poolUrl')
    ..aD(4, _omitFieldNames ? '' : 'hashrate')
    ..aD(5, _omitFieldNames ? '' : 'bestShare')
    ..aD(6, _omitFieldNames ? '' : 'networkDifficulty')
    ..pPM<FoundBlock>(7, _omitFieldNames ? '' : 'blocksFound', subBuilder: FoundBlock.$_createMessage)
    ..pPM<ConnectedMiner>(8, _omitFieldNames ? '' : 'miners', subBuilder: ConnectedMiner.$_createMessage)
    ..aOS(9, _omitFieldNames ? '' : 'error')
    ..aOM<Target>(10, _omitFieldNames ? '' : 'target', subBuilder: Target.$_createMessage)
    ..aOB(11, _omitFieldNames ? '' : 'poolConnected')
    ..aOS(12, _omitFieldNames ? '' : 'poolHost')
    ..aOS(13, _omitFieldNames ? '' : 'payoutAddress')
    ..a<$fixnum.Int64>(14, _omitFieldNames ? '' : 'acceptedShares', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(15, _omitFieldNames ? '' : 'rejectedShares', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<MiningSettings>(16, _omitFieldNames ? '' : 'settings', subBuilder: MiningSettings.$_createMessage)
    ..pPM<AcceptedShare>(17, _omitFieldNames ? '' : 'recentShares', subBuilder: AcceptedShare.$_createMessage)
    ..aD(18, _omitFieldNames ? '' : 'networkHashrate')
    ..aOB(19, _omitFieldNames ? '' : 'bestShareWon')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStratumStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStratumStatusResponse copyWith(void Function(GetStratumStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetStratumStatusResponse)) as GetStratumStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetStratumStatusResponse() / GetStratumStatusResponse.new instead')
  static GetStratumStatusResponse create() => GetStratumStatusResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetStratumStatusResponse._();
  @$core.override
  GetStratumStatusResponse createEmptyInstance() => GetStratumStatusResponse._();
  @$core.pragma('dart2js:noInline')
  static GetStratumStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStratumStatusResponse>(GetStratumStatusResponse.$_createMessage);
  static GetStratumStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get running => $_getBF(0);
  @$pb.TagNumber(1)
  set running($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRunning() => $_has(0);
  @$pb.TagNumber(1)
  void clearRunning() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get port => $_getIZ(1);
  @$pb.TagNumber(2)
  set port($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPort() => $_has(1);
  @$pb.TagNumber(2)
  void clearPort() => $_clearField(2);

  /// stratum+tcp URL on the LAN IPv4 address of this machine. Empty when the
  /// machine has no LAN address.
  @$pb.TagNumber(3)
  $core.String get poolUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set poolUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPoolUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearPoolUrl() => $_clearField(3);

  /// Hashes per second of all miners together.
  @$pb.TagNumber(4)
  $core.double get hashrate => $_getN(3);
  @$pb.TagNumber(4)
  set hashrate($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHashrate() => $_has(3);
  @$pb.TagNumber(4)
  void clearHashrate() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get bestShare => $_getN(4);
  @$pb.TagNumber(5)
  set bestShare($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBestShare() => $_has(4);
  @$pb.TagNumber(5)
  void clearBestShare() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get networkDifficulty => $_getN(5);
  @$pb.TagNumber(6)
  set networkDifficulty($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNetworkDifficulty() => $_has(5);
  @$pb.TagNumber(6)
  void clearNetworkDifficulty() => $_clearField(6);

  /// Blocks found since the server started, newest first.
  @$pb.TagNumber(7)
  $pb.PbList<FoundBlock> get blocksFound => $_getList(6);

  @$pb.TagNumber(8)
  $pb.PbList<ConnectedMiner> get miners => $_getList(7);

  /// Why the server last stopped on its own. Empty after a clean stop.
  @$pb.TagNumber(9)
  $core.String get error => $_getSZ(8);
  @$pb.TagNumber(9)
  set error($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasError() => $_has(8);
  @$pb.TagNumber(9)
  void clearError() => $_clearField(9);

  @$pb.TagNumber(10)
  Target get target => $_getN(9);
  @$pb.TagNumber(10)
  set target(Target value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasTarget() => $_has(9);
  @$pb.TagNumber(10)
  void clearTarget() => $_clearField(10);
  @$pb.TagNumber(10)
  Target ensureTarget() => $_ensure(9);

  /// Upstream pool state. Both are empty for a solo target.
  @$pb.TagNumber(11)
  $core.bool get poolConnected => $_getBF(10);
  @$pb.TagNumber(11)
  set poolConnected($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPoolConnected() => $_has(10);
  @$pb.TagNumber(11)
  void clearPoolConnected() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get poolHost => $_getSZ(11);
  @$pb.TagNumber(12)
  set poolHost($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPoolHost() => $_has(11);
  @$pb.TagNumber(12)
  void clearPoolHost() => $_clearField(12);

  /// Wallet address that a mined block pays. The enforcer builds every
  /// coinbase to it, and a catalog pool pays out to it.
  @$pb.TagNumber(13)
  $core.String get payoutAddress => $_getSZ(12);
  @$pb.TagNumber(13)
  set payoutAddress($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasPayoutAddress() => $_has(12);
  @$pb.TagNumber(13)
  void clearPayoutAddress() => $_clearField(13);

  @$pb.TagNumber(14)
  $fixnum.Int64 get acceptedShares => $_getI64(13);
  @$pb.TagNumber(14)
  set acceptedShares($fixnum.Int64 value) => $_setInt64(13, value);
  @$pb.TagNumber(14)
  $core.bool hasAcceptedShares() => $_has(13);
  @$pb.TagNumber(14)
  void clearAcceptedShares() => $_clearField(14);

  @$pb.TagNumber(15)
  $fixnum.Int64 get rejectedShares => $_getI64(14);
  @$pb.TagNumber(15)
  set rejectedShares($fixnum.Int64 value) => $_setInt64(14, value);
  @$pb.TagNumber(15)
  $core.bool hasRejectedShares() => $_has(14);
  @$pb.TagNumber(15)
  void clearRejectedShares() => $_clearField(15);

  @$pb.TagNumber(16)
  MiningSettings get settings => $_getN(15);
  @$pb.TagNumber(16)
  set settings(MiningSettings value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasSettings() => $_has(15);
  @$pb.TagNumber(16)
  void clearSettings() => $_clearField(16);
  @$pb.TagNumber(16)
  MiningSettings ensureSettings() => $_ensure(15);

  /// The last shares the server took, newest first.
  @$pb.TagNumber(17)
  $pb.PbList<AcceptedShare> get recentShares => $_getList(16);

  /// Hashes per second of the whole network, from the local node. Zero when
  /// the node does not answer.
  @$pb.TagNumber(18)
  $core.double get networkHashrate => $_getN(17);
  @$pb.TagNumber(18)
  set networkHashrate($core.double value) => $_setDouble(17, value);
  @$pb.TagNumber(18)
  $core.bool hasNetworkHashrate() => $_has(17);
  @$pb.TagNumber(18)
  void clearNetworkHashrate() => $_clearField(18);

  /// True when the best share met the target of its own job.
  @$pb.TagNumber(19)
  $core.bool get bestShareWon => $_getBF(18);
  @$pb.TagNumber(19)
  set bestShareWon($core.bool value) => $_setBool(18, value);
  @$pb.TagNumber(19)
  $core.bool hasBestShareWon() => $_has(18);
  @$pb.TagNumber(19)
  void clearBestShareWon() => $_clearField(19);
}

class SetTargetRequest extends $pb.GeneratedMessage {
  factory SetTargetRequest({
    Target? target,
  }) {
    final result = SetTargetRequest._();
    if (target != null) result.target = target;
    return result;
  }

  SetTargetRequest._();

  factory SetTargetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetTargetRequest()..mergeFromBuffer(data, registry);
  factory SetTargetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetTargetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetTargetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: SetTargetRequest.$_createMessage)
    ..aOM<Target>(1, _omitFieldNames ? '' : 'target', subBuilder: Target.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTargetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTargetRequest copyWith(void Function(SetTargetRequest) updates) =>
      super.copyWith((message) => updates(message as SetTargetRequest)) as SetTargetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetTargetRequest() / SetTargetRequest.new instead')
  static SetTargetRequest create() => SetTargetRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetTargetRequest._();
  @$core.override
  SetTargetRequest createEmptyInstance() => SetTargetRequest._();
  @$core.pragma('dart2js:noInline')
  static SetTargetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetTargetRequest>(SetTargetRequest.$_createMessage);
  static SetTargetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Target get target => $_getN(0);
  @$pb.TagNumber(1)
  set target(Target value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTarget() => $_has(0);
  @$pb.TagNumber(1)
  void clearTarget() => $_clearField(1);
  @$pb.TagNumber(1)
  Target ensureTarget() => $_ensure(0);
}

class SetTargetResponse extends $pb.GeneratedMessage {
  factory SetTargetResponse() => SetTargetResponse._();

  SetTargetResponse._();

  factory SetTargetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetTargetResponse()..mergeFromBuffer(data, registry);
  factory SetTargetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetTargetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetTargetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: SetTargetResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTargetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTargetResponse copyWith(void Function(SetTargetResponse) updates) =>
      super.copyWith((message) => updates(message as SetTargetResponse)) as SetTargetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetTargetResponse() / SetTargetResponse.new instead')
  static SetTargetResponse create() => SetTargetResponse._();
  static $pb.GeneratedMessage $_createMessage() => SetTargetResponse._();
  @$core.override
  SetTargetResponse createEmptyInstance() => SetTargetResponse._();
  @$core.pragma('dart2js:noInline')
  static SetTargetResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetTargetResponse>(SetTargetResponse.$_createMessage);
  static SetTargetResponse? _defaultInstance;
}

class ListTargetsRequest extends $pb.GeneratedMessage {
  factory ListTargetsRequest() => ListTargetsRequest._();

  ListTargetsRequest._();

  factory ListTargetsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTargetsRequest()..mergeFromBuffer(data, registry);
  factory ListTargetsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTargetsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTargetsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: ListTargetsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTargetsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTargetsRequest copyWith(void Function(ListTargetsRequest) updates) =>
      super.copyWith((message) => updates(message as ListTargetsRequest)) as ListTargetsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListTargetsRequest() / ListTargetsRequest.new instead')
  static ListTargetsRequest create() => ListTargetsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListTargetsRequest._();
  @$core.override
  ListTargetsRequest createEmptyInstance() => ListTargetsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListTargetsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListTargetsRequest>(ListTargetsRequest.$_createMessage);
  static ListTargetsRequest? _defaultInstance;
}

class CatalogPool extends $pb.GeneratedMessage {
  factory CatalogPool({
    $core.String? id,
    $core.String? name,
    $core.String? url,
    $core.String? fee,
    $core.double? hashrate,
  }) {
    final result = CatalogPool._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (url != null) result.url = url;
    if (fee != null) result.fee = fee;
    if (hashrate != null) result.hashrate = hashrate;
    return result;
  }

  CatalogPool._();

  factory CatalogPool.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CatalogPool()..mergeFromBuffer(data, registry);
  factory CatalogPool.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CatalogPool()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CatalogPool',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: CatalogPool.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..aOS(4, _omitFieldNames ? '' : 'fee')
    ..aD(5, _omitFieldNames ? '' : 'hashrate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CatalogPool clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CatalogPool copyWith(void Function(CatalogPool) updates) =>
      super.copyWith((message) => updates(message as CatalogPool)) as CatalogPool;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CatalogPool() / CatalogPool.new instead')
  static CatalogPool create() => CatalogPool._();
  static $pb.GeneratedMessage $_createMessage() => CatalogPool._();
  @$core.override
  CatalogPool createEmptyInstance() => CatalogPool._();
  @$core.pragma('dart2js:noInline')
  static CatalogPool getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CatalogPool>(CatalogPool.$_createMessage);
  static CatalogPool? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// stratum+tcp URL of the pool.
  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => $_clearField(3);

  /// Fee as the catalog states it. Empty when the catalog states none.
  @$pb.TagNumber(4)
  $core.String get fee => $_getSZ(3);
  @$pb.TagNumber(4)
  set fee($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFee() => $_has(3);
  @$pb.TagNumber(4)
  void clearFee() => $_clearField(4);

  /// Hashes per second of the whole pool. Unset when the pool publishes none.
  @$pb.TagNumber(5)
  $core.double get hashrate => $_getN(4);
  @$pb.TagNumber(5)
  set hashrate($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHashrate() => $_has(4);
  @$pb.TagNumber(5)
  void clearHashrate() => $_clearField(5);
}

class ListTargetsResponse extends $pb.GeneratedMessage {
  factory ListTargetsResponse({
    $core.Iterable<CatalogPool>? pools,
  }) {
    final result = ListTargetsResponse._();
    if (pools != null) result.pools.addAll(pools);
    return result;
  }

  ListTargetsResponse._();

  factory ListTargetsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTargetsResponse()..mergeFromBuffer(data, registry);
  factory ListTargetsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTargetsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTargetsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: ListTargetsResponse.$_createMessage)
    ..pPM<CatalogPool>(1, _omitFieldNames ? '' : 'pools', subBuilder: CatalogPool.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTargetsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTargetsResponse copyWith(void Function(ListTargetsResponse) updates) =>
      super.copyWith((message) => updates(message as ListTargetsResponse)) as ListTargetsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListTargetsResponse() / ListTargetsResponse.new instead')
  static ListTargetsResponse create() => ListTargetsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListTargetsResponse._();
  @$core.override
  ListTargetsResponse createEmptyInstance() => ListTargetsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListTargetsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListTargetsResponse>(ListTargetsResponse.$_createMessage);
  static ListTargetsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CatalogPool> get pools => $_getList(0);
}

class SetWorkModeRequest extends $pb.GeneratedMessage {
  factory SetWorkModeRequest({
    $core.String? address,
    WorkMode? mode,
  }) {
    final result = SetWorkModeRequest._();
    if (address != null) result.address = address;
    if (mode != null) result.mode = mode;
    return result;
  }

  SetWorkModeRequest._();

  factory SetWorkModeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetWorkModeRequest()..mergeFromBuffer(data, registry);
  factory SetWorkModeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetWorkModeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetWorkModeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: SetWorkModeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aE<WorkMode>(2, _omitFieldNames ? '' : 'mode', enumValues: WorkMode.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetWorkModeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetWorkModeRequest copyWith(void Function(SetWorkModeRequest) updates) =>
      super.copyWith((message) => updates(message as SetWorkModeRequest)) as SetWorkModeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetWorkModeRequest() / SetWorkModeRequest.new instead')
  static SetWorkModeRequest create() => SetWorkModeRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetWorkModeRequest._();
  @$core.override
  SetWorkModeRequest createEmptyInstance() => SetWorkModeRequest._();
  @$core.pragma('dart2js:noInline')
  static SetWorkModeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetWorkModeRequest>(SetWorkModeRequest.$_createMessage);
  static SetWorkModeRequest? _defaultInstance;

  /// Address of a connected miner, as GetStratumStatus reports it.
  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  WorkMode get mode => $_getN(1);
  @$pb.TagNumber(2)
  set mode(WorkMode value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearMode() => $_clearField(2);
}

class SetWorkModeResponse extends $pb.GeneratedMessage {
  factory SetWorkModeResponse() => SetWorkModeResponse._();

  SetWorkModeResponse._();

  factory SetWorkModeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetWorkModeResponse()..mergeFromBuffer(data, registry);
  factory SetWorkModeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetWorkModeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetWorkModeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'),
      createEmptyInstance: SetWorkModeResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetWorkModeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetWorkModeResponse copyWith(void Function(SetWorkModeResponse) updates) =>
      super.copyWith((message) => updates(message as SetWorkModeResponse)) as SetWorkModeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetWorkModeResponse() / SetWorkModeResponse.new instead')
  static SetWorkModeResponse create() => SetWorkModeResponse._();
  static $pb.GeneratedMessage $_createMessage() => SetWorkModeResponse._();
  @$core.override
  SetWorkModeResponse createEmptyInstance() => SetWorkModeResponse._();
  @$core.pragma('dart2js:noInline')
  static SetWorkModeResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetWorkModeResponse>(SetWorkModeResponse.$_createMessage);
  static SetWorkModeResponse? _defaultInstance;
}

/// StratumService runs a Stratum v1 server for ASIC miners on the local
/// network. The server sends their work to this node or to a pool, and keeps
/// running with no client attached. eCash networks only.
class StratumServiceApi {
  final $pb.RpcClient _client;

  StratumServiceApi(this._client);

  $async.Future<StartStratumResponse> startStratum($pb.ClientContext? ctx, StartStratumRequest request) =>
      _client.invoke<StartStratumResponse>(ctx, 'StratumService', 'StartStratum', request, StartStratumResponse());
  $async.Future<StopStratumResponse> stopStratum($pb.ClientContext? ctx, StopStratumRequest request) =>
      _client.invoke<StopStratumResponse>(ctx, 'StratumService', 'StopStratum', request, StopStratumResponse());
  $async.Future<GetStratumStatusResponse> getStratumStatus($pb.ClientContext? ctx, GetStratumStatusRequest request) =>
      _client.invoke<GetStratumStatusResponse>(
          ctx, 'StratumService', 'GetStratumStatus', request, GetStratumStatusResponse());

  /// SetTarget selects where the miners' work goes. A running server switches
  /// at once and sends clean jobs.
  $async.Future<SetTargetResponse> setTarget($pb.ClientContext? ctx, SetTargetRequest request) =>
      _client.invoke<SetTargetResponse>(ctx, 'StratumService', 'SetTarget', request, SetTargetResponse());

  /// ListTargets returns the catalog pools of the running network.
  $async.Future<ListTargetsResponse> listTargets($pb.ClientContext? ctx, ListTargetsRequest request) =>
      _client.invoke<ListTargetsResponse>(ctx, 'StratumService', 'ListTargets', request, ListTargetsResponse());

  /// SetWorkMode changes the power mode of a connected miner over its device API.
  $async.Future<SetWorkModeResponse> setWorkMode($pb.ClientContext? ctx, SetWorkModeRequest request) =>
      _client.invoke<SetWorkModeResponse>(ctx, 'StratumService', 'SetWorkMode', request, SetWorkModeResponse());

  /// SetMiningSettings changes the fields it carries and leaves the rest. The
  /// hasher on this computer starts the server first when the server is stopped.
  $async.Future<SetMiningSettingsResponse> setMiningSettings(
          $pb.ClientContext? ctx, SetMiningSettingsRequest request) =>
      _client.invoke<SetMiningSettingsResponse>(
          ctx, 'StratumService', 'SetMiningSettings', request, SetMiningSettingsResponse());

  /// GetHashrateHistory returns the hashrate of all miners together over a range.
  $async.Future<GetHashrateHistoryResponse> getHashrateHistory(
          $pb.ClientContext? ctx, GetHashrateHistoryRequest request) =>
      _client.invoke<GetHashrateHistoryResponse>(
          ctx, 'StratumService', 'GetHashrateHistory', request, GetHashrateHistoryResponse());

  /// ListPoolBlocks returns the blocks the upstream pool found, newest first.
  $async.Future<ListPoolBlocksResponse> listPoolBlocks($pb.ClientContext? ctx, ListPoolBlocksRequest request) => _client
      .invoke<ListPoolBlocksResponse>(ctx, 'StratumService', 'ListPoolBlocks', request, ListPoolBlocksResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
