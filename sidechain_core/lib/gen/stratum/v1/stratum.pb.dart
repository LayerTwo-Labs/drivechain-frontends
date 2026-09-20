//
//  Generated code. Do not modify.
//  source: stratum/v1/stratum.proto
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

import '../../google/protobuf/timestamp.pb.dart' as $14;
import 'stratum.pbenum.dart';

export 'stratum.pbenum.dart';

class StartStratumRequest extends $pb.GeneratedMessage {
  factory StartStratumRequest({
    $core.int? port,
  }) {
    final $result = create();
    if (port != null) {
      $result.port = port;
    }
    return $result;
  }
  StartStratumRequest._() : super();
  factory StartStratumRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StartStratumRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartStratumRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'port', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StartStratumRequest clone() => StartStratumRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StartStratumRequest copyWith(void Function(StartStratumRequest) updates) => super.copyWith((message) => updates(message as StartStratumRequest)) as StartStratumRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartStratumRequest create() => StartStratumRequest._();
  StartStratumRequest createEmptyInstance() => create();
  static $pb.PbList<StartStratumRequest> createRepeated() => $pb.PbList<StartStratumRequest>();
  @$core.pragma('dart2js:noInline')
  static StartStratumRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartStratumRequest>(create);
  static StartStratumRequest? _defaultInstance;

  /// TCP port to listen on. Zero uses 3333.
  @$pb.TagNumber(1)
  $core.int get port => $_getIZ(0);
  @$pb.TagNumber(1)
  set port($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPort() => $_has(0);
  @$pb.TagNumber(1)
  void clearPort() => clearField(1);
}

class StartStratumResponse extends $pb.GeneratedMessage {
  factory StartStratumResponse() => create();
  StartStratumResponse._() : super();
  factory StartStratumResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StartStratumResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartStratumResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StartStratumResponse clone() => StartStratumResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StartStratumResponse copyWith(void Function(StartStratumResponse) updates) => super.copyWith((message) => updates(message as StartStratumResponse)) as StartStratumResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartStratumResponse create() => StartStratumResponse._();
  StartStratumResponse createEmptyInstance() => create();
  static $pb.PbList<StartStratumResponse> createRepeated() => $pb.PbList<StartStratumResponse>();
  @$core.pragma('dart2js:noInline')
  static StartStratumResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartStratumResponse>(create);
  static StartStratumResponse? _defaultInstance;
}

class StopStratumRequest extends $pb.GeneratedMessage {
  factory StopStratumRequest() => create();
  StopStratumRequest._() : super();
  factory StopStratumRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StopStratumRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopStratumRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StopStratumRequest clone() => StopStratumRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StopStratumRequest copyWith(void Function(StopStratumRequest) updates) => super.copyWith((message) => updates(message as StopStratumRequest)) as StopStratumRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopStratumRequest create() => StopStratumRequest._();
  StopStratumRequest createEmptyInstance() => create();
  static $pb.PbList<StopStratumRequest> createRepeated() => $pb.PbList<StopStratumRequest>();
  @$core.pragma('dart2js:noInline')
  static StopStratumRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopStratumRequest>(create);
  static StopStratumRequest? _defaultInstance;
}

class StopStratumResponse extends $pb.GeneratedMessage {
  factory StopStratumResponse() => create();
  StopStratumResponse._() : super();
  factory StopStratumResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StopStratumResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopStratumResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StopStratumResponse clone() => StopStratumResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StopStratumResponse copyWith(void Function(StopStratumResponse) updates) => super.copyWith((message) => updates(message as StopStratumResponse)) as StopStratumResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopStratumResponse create() => StopStratumResponse._();
  StopStratumResponse createEmptyInstance() => create();
  static $pb.PbList<StopStratumResponse> createRepeated() => $pb.PbList<StopStratumResponse>();
  @$core.pragma('dart2js:noInline')
  static StopStratumResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopStratumResponse>(create);
  static StopStratumResponse? _defaultInstance;
}

class GetStratumStatusRequest extends $pb.GeneratedMessage {
  factory GetStratumStatusRequest() => create();
  GetStratumStatusRequest._() : super();
  factory GetStratumStatusRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetStratumStatusRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetStratumStatusRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetStratumStatusRequest clone() => GetStratumStatusRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetStratumStatusRequest copyWith(void Function(GetStratumStatusRequest) updates) => super.copyWith((message) => updates(message as GetStratumStatusRequest)) as GetStratumStatusRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStratumStatusRequest create() => GetStratumStatusRequest._();
  GetStratumStatusRequest createEmptyInstance() => create();
  static $pb.PbList<GetStratumStatusRequest> createRepeated() => $pb.PbList<GetStratumStatusRequest>();
  @$core.pragma('dart2js:noInline')
  static GetStratumStatusRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetStratumStatusRequest>(create);
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
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (poolId != null) {
      $result.poolId = poolId;
    }
    if (url != null) {
      $result.url = url;
    }
    if (worker != null) {
      $result.worker = worker;
    }
    if (password != null) {
      $result.password = password;
    }
    return $result;
  }
  Target._() : super();
  factory Target.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Target.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Target', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..e<TargetKind>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OE, defaultOrMaker: TargetKind.TARGET_KIND_UNSPECIFIED, valueOf: TargetKind.valueOf, enumValues: TargetKind.values)
    ..aOS(2, _omitFieldNames ? '' : 'poolId')
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..aOS(4, _omitFieldNames ? '' : 'worker')
    ..aOS(5, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Target clone() => Target()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Target copyWith(void Function(Target) updates) => super.copyWith((message) => updates(message as Target)) as Target;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Target create() => Target._();
  Target createEmptyInstance() => create();
  static $pb.PbList<Target> createRepeated() => $pb.PbList<Target>();
  @$core.pragma('dart2js:noInline')
  static Target getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Target>(create);
  static Target? _defaultInstance;

  @$pb.TagNumber(1)
  TargetKind get kind => $_getN(0);
  @$pb.TagNumber(1)
  set kind(TargetKind v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  /// Catalog pool id when kind is TARGET_KIND_POOL.
  @$pb.TagNumber(2)
  $core.String get poolId => $_getSZ(1);
  @$pb.TagNumber(2)
  set poolId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPoolId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPoolId() => clearField(2);

  /// stratum+tcp URL, worker and password when kind is TARGET_KIND_CUSTOM.
  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get worker => $_getSZ(3);
  @$pb.TagNumber(4)
  set worker($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWorker() => $_has(3);
  @$pb.TagNumber(4)
  void clearWorker() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get password => $_getSZ(4);
  @$pb.TagNumber(5)
  set password($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPassword() => $_has(4);
  @$pb.TagNumber(5)
  void clearPassword() => clearField(5);
}

class MiningSettings extends $pb.GeneratedMessage {
  factory MiningSettings({
    $core.int? port,
    $core.bool? cpuMining,
    $core.int? cpuThreads,
    $core.bool? keepMiningOnClose,
  }) {
    final $result = create();
    if (port != null) {
      $result.port = port;
    }
    if (cpuMining != null) {
      $result.cpuMining = cpuMining;
    }
    if (cpuThreads != null) {
      $result.cpuThreads = cpuThreads;
    }
    if (keepMiningOnClose != null) {
      $result.keepMiningOnClose = keepMiningOnClose;
    }
    return $result;
  }
  MiningSettings._() : super();
  factory MiningSettings.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MiningSettings.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MiningSettings', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'port', $pb.PbFieldType.OU3)
    ..aOB(2, _omitFieldNames ? '' : 'cpuMining')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'cpuThreads', $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'keepMiningOnClose')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MiningSettings clone() => MiningSettings()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MiningSettings copyWith(void Function(MiningSettings) updates) => super.copyWith((message) => updates(message as MiningSettings)) as MiningSettings;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MiningSettings create() => MiningSettings._();
  MiningSettings createEmptyInstance() => create();
  static $pb.PbList<MiningSettings> createRepeated() => $pb.PbList<MiningSettings>();
  @$core.pragma('dart2js:noInline')
  static MiningSettings getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MiningSettings>(create);
  static MiningSettings? _defaultInstance;

  /// TCP port the Stratum server listens on.
  @$pb.TagNumber(1)
  $core.int get port => $_getIZ(0);
  @$pb.TagNumber(1)
  set port($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPort() => $_has(0);
  @$pb.TagNumber(1)
  void clearPort() => clearField(1);

  /// Whether the hasher on this computer runs.
  @$pb.TagNumber(2)
  $core.bool get cpuMining => $_getBF(1);
  @$pb.TagNumber(2)
  set cpuMining($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCpuMining() => $_has(1);
  @$pb.TagNumber(2)
  void clearCpuMining() => clearField(2);

  /// Hash threads the hasher runs.
  @$pb.TagNumber(3)
  $core.int get cpuThreads => $_getIZ(2);
  @$pb.TagNumber(3)
  set cpuThreads($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCpuThreads() => $_has(2);
  @$pb.TagNumber(3)
  void clearCpuThreads() => clearField(3);

  /// Whether the miners keep going after the app window closes.
  @$pb.TagNumber(4)
  $core.bool get keepMiningOnClose => $_getBF(3);
  @$pb.TagNumber(4)
  set keepMiningOnClose($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasKeepMiningOnClose() => $_has(3);
  @$pb.TagNumber(4)
  void clearKeepMiningOnClose() => clearField(4);
}

class SetMiningSettingsRequest extends $pb.GeneratedMessage {
  factory SetMiningSettingsRequest({
    $core.int? port,
    $core.bool? cpuMining,
    $core.int? cpuThreads,
    $core.bool? keepMiningOnClose,
  }) {
    final $result = create();
    if (port != null) {
      $result.port = port;
    }
    if (cpuMining != null) {
      $result.cpuMining = cpuMining;
    }
    if (cpuThreads != null) {
      $result.cpuThreads = cpuThreads;
    }
    if (keepMiningOnClose != null) {
      $result.keepMiningOnClose = keepMiningOnClose;
    }
    return $result;
  }
  SetMiningSettingsRequest._() : super();
  factory SetMiningSettingsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetMiningSettingsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetMiningSettingsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'port', $pb.PbFieldType.OU3)
    ..aOB(2, _omitFieldNames ? '' : 'cpuMining')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'cpuThreads', $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'keepMiningOnClose')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetMiningSettingsRequest clone() => SetMiningSettingsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetMiningSettingsRequest copyWith(void Function(SetMiningSettingsRequest) updates) => super.copyWith((message) => updates(message as SetMiningSettingsRequest)) as SetMiningSettingsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetMiningSettingsRequest create() => SetMiningSettingsRequest._();
  SetMiningSettingsRequest createEmptyInstance() => create();
  static $pb.PbList<SetMiningSettingsRequest> createRepeated() => $pb.PbList<SetMiningSettingsRequest>();
  @$core.pragma('dart2js:noInline')
  static SetMiningSettingsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetMiningSettingsRequest>(create);
  static SetMiningSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get port => $_getIZ(0);
  @$pb.TagNumber(1)
  set port($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPort() => $_has(0);
  @$pb.TagNumber(1)
  void clearPort() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get cpuMining => $_getBF(1);
  @$pb.TagNumber(2)
  set cpuMining($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCpuMining() => $_has(1);
  @$pb.TagNumber(2)
  void clearCpuMining() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get cpuThreads => $_getIZ(2);
  @$pb.TagNumber(3)
  set cpuThreads($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCpuThreads() => $_has(2);
  @$pb.TagNumber(3)
  void clearCpuThreads() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get keepMiningOnClose => $_getBF(3);
  @$pb.TagNumber(4)
  set keepMiningOnClose($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasKeepMiningOnClose() => $_has(3);
  @$pb.TagNumber(4)
  void clearKeepMiningOnClose() => clearField(4);
}

class SetMiningSettingsResponse extends $pb.GeneratedMessage {
  factory SetMiningSettingsResponse() => create();
  SetMiningSettingsResponse._() : super();
  factory SetMiningSettingsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetMiningSettingsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetMiningSettingsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetMiningSettingsResponse clone() => SetMiningSettingsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetMiningSettingsResponse copyWith(void Function(SetMiningSettingsResponse) updates) => super.copyWith((message) => updates(message as SetMiningSettingsResponse)) as SetMiningSettingsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetMiningSettingsResponse create() => SetMiningSettingsResponse._();
  SetMiningSettingsResponse createEmptyInstance() => create();
  static $pb.PbList<SetMiningSettingsResponse> createRepeated() => $pb.PbList<SetMiningSettingsResponse>();
  @$core.pragma('dart2js:noInline')
  static SetMiningSettingsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetMiningSettingsResponse>(create);
  static SetMiningSettingsResponse? _defaultInstance;
}

class HashratePoint extends $pb.GeneratedMessage {
  factory HashratePoint({
    $14.Timestamp? time,
    $core.double? hashrate,
  }) {
    final $result = create();
    if (time != null) {
      $result.time = time;
    }
    if (hashrate != null) {
      $result.hashrate = hashrate;
    }
    return $result;
  }
  HashratePoint._() : super();
  factory HashratePoint.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory HashratePoint.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HashratePoint', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..aOM<$14.Timestamp>(1, _omitFieldNames ? '' : 'time', subBuilder: $14.Timestamp.create)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'hashrate', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  HashratePoint clone() => HashratePoint()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  HashratePoint copyWith(void Function(HashratePoint) updates) => super.copyWith((message) => updates(message as HashratePoint)) as HashratePoint;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HashratePoint create() => HashratePoint._();
  HashratePoint createEmptyInstance() => create();
  static $pb.PbList<HashratePoint> createRepeated() => $pb.PbList<HashratePoint>();
  @$core.pragma('dart2js:noInline')
  static HashratePoint getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HashratePoint>(create);
  static HashratePoint? _defaultInstance;

  @$pb.TagNumber(1)
  $14.Timestamp get time => $_getN(0);
  @$pb.TagNumber(1)
  set time($14.Timestamp v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearTime() => clearField(1);
  @$pb.TagNumber(1)
  $14.Timestamp ensureTime() => $_ensure(0);

  /// Hashes per second of all miners together over the bucket.
  @$pb.TagNumber(2)
  $core.double get hashrate => $_getN(1);
  @$pb.TagNumber(2)
  set hashrate($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHashrate() => $_has(1);
  @$pb.TagNumber(2)
  void clearHashrate() => clearField(2);
}

class GetHashrateHistoryRequest extends $pb.GeneratedMessage {
  factory GetHashrateHistoryRequest({
    HashrateRange? range,
  }) {
    final $result = create();
    if (range != null) {
      $result.range = range;
    }
    return $result;
  }
  GetHashrateHistoryRequest._() : super();
  factory GetHashrateHistoryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetHashrateHistoryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetHashrateHistoryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..e<HashrateRange>(1, _omitFieldNames ? '' : 'range', $pb.PbFieldType.OE, defaultOrMaker: HashrateRange.HASHRATE_RANGE_UNSPECIFIED, valueOf: HashrateRange.valueOf, enumValues: HashrateRange.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetHashrateHistoryRequest clone() => GetHashrateHistoryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetHashrateHistoryRequest copyWith(void Function(GetHashrateHistoryRequest) updates) => super.copyWith((message) => updates(message as GetHashrateHistoryRequest)) as GetHashrateHistoryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHashrateHistoryRequest create() => GetHashrateHistoryRequest._();
  GetHashrateHistoryRequest createEmptyInstance() => create();
  static $pb.PbList<GetHashrateHistoryRequest> createRepeated() => $pb.PbList<GetHashrateHistoryRequest>();
  @$core.pragma('dart2js:noInline')
  static GetHashrateHistoryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetHashrateHistoryRequest>(create);
  static GetHashrateHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  HashrateRange get range => $_getN(0);
  @$pb.TagNumber(1)
  set range(HashrateRange v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasRange() => $_has(0);
  @$pb.TagNumber(1)
  void clearRange() => clearField(1);
}

class GetHashrateHistoryResponse extends $pb.GeneratedMessage {
  factory GetHashrateHistoryResponse({
    $core.Iterable<HashratePoint>? points,
    $core.double? peak,
    $core.double? current,
  }) {
    final $result = create();
    if (points != null) {
      $result.points.addAll(points);
    }
    if (peak != null) {
      $result.peak = peak;
    }
    if (current != null) {
      $result.current = current;
    }
    return $result;
  }
  GetHashrateHistoryResponse._() : super();
  factory GetHashrateHistoryResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetHashrateHistoryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetHashrateHistoryResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..pc<HashratePoint>(1, _omitFieldNames ? '' : 'points', $pb.PbFieldType.PM, subBuilder: HashratePoint.create)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'peak', $pb.PbFieldType.OD)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'current', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetHashrateHistoryResponse clone() => GetHashrateHistoryResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetHashrateHistoryResponse copyWith(void Function(GetHashrateHistoryResponse) updates) => super.copyWith((message) => updates(message as GetHashrateHistoryResponse)) as GetHashrateHistoryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHashrateHistoryResponse create() => GetHashrateHistoryResponse._();
  GetHashrateHistoryResponse createEmptyInstance() => create();
  static $pb.PbList<GetHashrateHistoryResponse> createRepeated() => $pb.PbList<GetHashrateHistoryResponse>();
  @$core.pragma('dart2js:noInline')
  static GetHashrateHistoryResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetHashrateHistoryResponse>(create);
  static GetHashrateHistoryResponse? _defaultInstance;

  /// Oldest first. A bucket with no miner reads zero.
  @$pb.TagNumber(1)
  $core.List<HashratePoint> get points => $_getList(0);

  /// Highest bucket of the range.
  @$pb.TagNumber(2)
  $core.double get peak => $_getN(1);
  @$pb.TagNumber(2)
  set peak($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPeak() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeak() => clearField(2);

  /// Hashrate right now.
  @$pb.TagNumber(3)
  $core.double get current => $_getN(2);
  @$pb.TagNumber(3)
  set current($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCurrent() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrent() => clearField(3);
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
    $14.Timestamp? foundTime,
  }) {
    final $result = create();
    if (height != null) {
      $result.height = height;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    if (rewardSats != null) {
      $result.rewardSats = rewardSats;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (finder != null) {
      $result.finder = finder;
    }
    if (myPayoutSats != null) {
      $result.myPayoutSats = myPayoutSats;
    }
    if (mine != null) {
      $result.mine = mine;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (foundTime != null) {
      $result.foundTime = foundTime;
    }
    return $result;
  }
  PoolBlock._() : super();
  factory PoolBlock.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PoolBlock.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PoolBlock', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..aInt64(3, _omitFieldNames ? '' : 'rewardSats')
    ..aInt64(4, _omitFieldNames ? '' : 'feeSats')
    ..aOS(5, _omitFieldNames ? '' : 'finder')
    ..aInt64(6, _omitFieldNames ? '' : 'myPayoutSats')
    ..aOB(7, _omitFieldNames ? '' : 'mine')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..aOM<$14.Timestamp>(9, _omitFieldNames ? '' : 'foundTime', subBuilder: $14.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PoolBlock clone() => PoolBlock()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PoolBlock copyWith(void Function(PoolBlock) updates) => super.copyWith((message) => updates(message as PoolBlock)) as PoolBlock;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PoolBlock create() => PoolBlock._();
  PoolBlock createEmptyInstance() => create();
  static $pb.PbList<PoolBlock> createRepeated() => $pb.PbList<PoolBlock>();
  @$core.pragma('dart2js:noInline')
  static PoolBlock getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PoolBlock>(create);
  static PoolBlock? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get height => $_getIZ(0);
  @$pb.TagNumber(1)
  set height($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => clearField(2);

  /// What the pool paid out for the block.
  @$pb.TagNumber(3)
  $fixnum.Int64 get rewardSats => $_getI64(2);
  @$pb.TagNumber(3)
  set rewardSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRewardSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearRewardSats() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSats() => clearField(4);

  /// Worker name the pool credits.
  @$pb.TagNumber(5)
  $core.String get finder => $_getSZ(4);
  @$pb.TagNumber(5)
  set finder($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFinder() => $_has(4);
  @$pb.TagNumber(5)
  void clearFinder() => clearField(5);

  /// Sats the coinbase of the block pays to the payout address. Unset when
  /// the local node does not give the block.
  @$pb.TagNumber(6)
  $fixnum.Int64 get myPayoutSats => $_getI64(5);
  @$pb.TagNumber(6)
  set myPayoutSats($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMyPayoutSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearMyPayoutSats() => clearField(6);

  /// Whether a miner on this computer found the block.
  @$pb.TagNumber(7)
  $core.bool get mine => $_getBF(6);
  @$pb.TagNumber(7)
  set mine($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMine() => $_has(6);
  @$pb.TagNumber(7)
  void clearMine() => clearField(7);

  /// Confirmations from the local node. Negative when the block left the main
  /// chain. Unset when the node does not answer.
  @$pb.TagNumber(8)
  $core.int get confirmations => $_getIZ(7);
  @$pb.TagNumber(8)
  set confirmations($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasConfirmations() => $_has(7);
  @$pb.TagNumber(8)
  void clearConfirmations() => clearField(8);

  @$pb.TagNumber(9)
  $14.Timestamp get foundTime => $_getN(8);
  @$pb.TagNumber(9)
  set foundTime($14.Timestamp v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasFoundTime() => $_has(8);
  @$pb.TagNumber(9)
  void clearFoundTime() => clearField(9);
  @$pb.TagNumber(9)
  $14.Timestamp ensureFoundTime() => $_ensure(8);
}

class ListPoolBlocksRequest extends $pb.GeneratedMessage {
  factory ListPoolBlocksRequest({
    $core.int? limit,
  }) {
    final $result = create();
    if (limit != null) {
      $result.limit = limit;
    }
    return $result;
  }
  ListPoolBlocksRequest._() : super();
  factory ListPoolBlocksRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListPoolBlocksRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListPoolBlocksRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListPoolBlocksRequest clone() => ListPoolBlocksRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListPoolBlocksRequest copyWith(void Function(ListPoolBlocksRequest) updates) => super.copyWith((message) => updates(message as ListPoolBlocksRequest)) as ListPoolBlocksRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPoolBlocksRequest create() => ListPoolBlocksRequest._();
  ListPoolBlocksRequest createEmptyInstance() => create();
  static $pb.PbList<ListPoolBlocksRequest> createRepeated() => $pb.PbList<ListPoolBlocksRequest>();
  @$core.pragma('dart2js:noInline')
  static ListPoolBlocksRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListPoolBlocksRequest>(create);
  static ListPoolBlocksRequest? _defaultInstance;

  /// Blocks to return. Zero returns 20.
  @$pb.TagNumber(1)
  $core.int get limit => $_getIZ(0);
  @$pb.TagNumber(1)
  set limit($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLimit() => $_has(0);
  @$pb.TagNumber(1)
  void clearLimit() => clearField(1);
}

class ListPoolBlocksResponse extends $pb.GeneratedMessage {
  factory ListPoolBlocksResponse({
    $core.Iterable<PoolBlock>? blocks,
    $core.String? unavailable,
  }) {
    final $result = create();
    if (blocks != null) {
      $result.blocks.addAll(blocks);
    }
    if (unavailable != null) {
      $result.unavailable = unavailable;
    }
    return $result;
  }
  ListPoolBlocksResponse._() : super();
  factory ListPoolBlocksResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListPoolBlocksResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListPoolBlocksResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..pc<PoolBlock>(1, _omitFieldNames ? '' : 'blocks', $pb.PbFieldType.PM, subBuilder: PoolBlock.create)
    ..aOS(2, _omitFieldNames ? '' : 'unavailable')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListPoolBlocksResponse clone() => ListPoolBlocksResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListPoolBlocksResponse copyWith(void Function(ListPoolBlocksResponse) updates) => super.copyWith((message) => updates(message as ListPoolBlocksResponse)) as ListPoolBlocksResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPoolBlocksResponse create() => ListPoolBlocksResponse._();
  ListPoolBlocksResponse createEmptyInstance() => create();
  static $pb.PbList<ListPoolBlocksResponse> createRepeated() => $pb.PbList<ListPoolBlocksResponse>();
  @$core.pragma('dart2js:noInline')
  static ListPoolBlocksResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListPoolBlocksResponse>(create);
  static ListPoolBlocksResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<PoolBlock> get blocks => $_getList(0);

  /// Why the list is empty, such as a pool that publishes no blocks. Empty
  /// when the pool answered.
  @$pb.TagNumber(2)
  $core.String get unavailable => $_getSZ(1);
  @$pb.TagNumber(2)
  set unavailable($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUnavailable() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnavailable() => clearField(2);
}

class AcceptedShare extends $pb.GeneratedMessage {
  factory AcceptedShare({
    $14.Timestamp? time,
    $core.String? worker,
    $core.double? target,
    $core.double? actual,
    $core.String? hash,
    $core.bool? block,
  }) {
    final $result = create();
    if (time != null) {
      $result.time = time;
    }
    if (worker != null) {
      $result.worker = worker;
    }
    if (target != null) {
      $result.target = target;
    }
    if (actual != null) {
      $result.actual = actual;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    if (block != null) {
      $result.block = block;
    }
    return $result;
  }
  AcceptedShare._() : super();
  factory AcceptedShare.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AcceptedShare.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AcceptedShare', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..aOM<$14.Timestamp>(1, _omitFieldNames ? '' : 'time', subBuilder: $14.Timestamp.create)
    ..aOS(2, _omitFieldNames ? '' : 'worker')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'target', $pb.PbFieldType.OD)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'actual', $pb.PbFieldType.OD)
    ..aOS(5, _omitFieldNames ? '' : 'hash')
    ..aOB(6, _omitFieldNames ? '' : 'block')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AcceptedShare clone() => AcceptedShare()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AcceptedShare copyWith(void Function(AcceptedShare) updates) => super.copyWith((message) => updates(message as AcceptedShare)) as AcceptedShare;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AcceptedShare create() => AcceptedShare._();
  AcceptedShare createEmptyInstance() => create();
  static $pb.PbList<AcceptedShare> createRepeated() => $pb.PbList<AcceptedShare>();
  @$core.pragma('dart2js:noInline')
  static AcceptedShare getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AcceptedShare>(create);
  static AcceptedShare? _defaultInstance;

  @$pb.TagNumber(1)
  $14.Timestamp get time => $_getN(0);
  @$pb.TagNumber(1)
  set time($14.Timestamp v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearTime() => clearField(1);
  @$pb.TagNumber(1)
  $14.Timestamp ensureTime() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get worker => $_getSZ(1);
  @$pb.TagNumber(2)
  set worker($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWorker() => $_has(1);
  @$pb.TagNumber(2)
  void clearWorker() => clearField(2);

  /// Difficulty the share had to reach.
  @$pb.TagNumber(3)
  $core.double get target => $_getN(2);
  @$pb.TagNumber(3)
  set target($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTarget() => $_has(2);
  @$pb.TagNumber(3)
  void clearTarget() => clearField(3);

  /// Difficulty the share reached.
  @$pb.TagNumber(4)
  $core.double get actual => $_getN(3);
  @$pb.TagNumber(4)
  set actual($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasActual() => $_has(3);
  @$pb.TagNumber(4)
  void clearActual() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get hash => $_getSZ(4);
  @$pb.TagNumber(5)
  set hash($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHash() => $_has(4);
  @$pb.TagNumber(5)
  void clearHash() => clearField(5);

  /// Whether the share completed a block.
  @$pb.TagNumber(6)
  $core.bool get block => $_getBF(5);
  @$pb.TagNumber(6)
  set block($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasBlock() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlock() => clearField(6);
}

class ConnectedMiner extends $pb.GeneratedMessage {
  factory ConnectedMiner({
    $core.String? worker,
    $core.String? address,
    $core.double? hashrate,
    $core.double? bestShare,
    $fixnum.Int64? acceptedShares,
    $fixnum.Int64? rejectedShares,
    $14.Timestamp? lastShareTime,
    $core.double? temperatureCelsius,
    $core.double? fanPercent,
    $core.double? powerWatts,
    WorkMode? workMode,
  }) {
    final $result = create();
    if (worker != null) {
      $result.worker = worker;
    }
    if (address != null) {
      $result.address = address;
    }
    if (hashrate != null) {
      $result.hashrate = hashrate;
    }
    if (bestShare != null) {
      $result.bestShare = bestShare;
    }
    if (acceptedShares != null) {
      $result.acceptedShares = acceptedShares;
    }
    if (rejectedShares != null) {
      $result.rejectedShares = rejectedShares;
    }
    if (lastShareTime != null) {
      $result.lastShareTime = lastShareTime;
    }
    if (temperatureCelsius != null) {
      $result.temperatureCelsius = temperatureCelsius;
    }
    if (fanPercent != null) {
      $result.fanPercent = fanPercent;
    }
    if (powerWatts != null) {
      $result.powerWatts = powerWatts;
    }
    if (workMode != null) {
      $result.workMode = workMode;
    }
    return $result;
  }
  ConnectedMiner._() : super();
  factory ConnectedMiner.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConnectedMiner.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectedMiner', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'worker')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'hashrate', $pb.PbFieldType.OD)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'bestShare', $pb.PbFieldType.OD)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'acceptedShares', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(6, _omitFieldNames ? '' : 'rejectedShares', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<$14.Timestamp>(7, _omitFieldNames ? '' : 'lastShareTime', subBuilder: $14.Timestamp.create)
    ..a<$core.double>(8, _omitFieldNames ? '' : 'temperatureCelsius', $pb.PbFieldType.OD)
    ..a<$core.double>(9, _omitFieldNames ? '' : 'fanPercent', $pb.PbFieldType.OD)
    ..a<$core.double>(10, _omitFieldNames ? '' : 'powerWatts', $pb.PbFieldType.OD)
    ..e<WorkMode>(11, _omitFieldNames ? '' : 'workMode', $pb.PbFieldType.OE, defaultOrMaker: WorkMode.WORK_MODE_UNSPECIFIED, valueOf: WorkMode.valueOf, enumValues: WorkMode.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConnectedMiner clone() => ConnectedMiner()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConnectedMiner copyWith(void Function(ConnectedMiner) updates) => super.copyWith((message) => updates(message as ConnectedMiner)) as ConnectedMiner;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnectedMiner create() => ConnectedMiner._();
  ConnectedMiner createEmptyInstance() => create();
  static $pb.PbList<ConnectedMiner> createRepeated() => $pb.PbList<ConnectedMiner>();
  @$core.pragma('dart2js:noInline')
  static ConnectedMiner getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConnectedMiner>(create);
  static ConnectedMiner? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get worker => $_getSZ(0);
  @$pb.TagNumber(1)
  set worker($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWorker() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorker() => clearField(1);

  /// IP address the miner connects from. The hasher on this computer reads
  /// "this computer".
  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);

  /// Hashes per second over the last five minutes.
  @$pb.TagNumber(3)
  $core.double get hashrate => $_getN(2);
  @$pb.TagNumber(3)
  set hashrate($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHashrate() => $_has(2);
  @$pb.TagNumber(3)
  void clearHashrate() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get bestShare => $_getN(3);
  @$pb.TagNumber(4)
  set bestShare($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBestShare() => $_has(3);
  @$pb.TagNumber(4)
  void clearBestShare() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get acceptedShares => $_getI64(4);
  @$pb.TagNumber(5)
  set acceptedShares($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAcceptedShares() => $_has(4);
  @$pb.TagNumber(5)
  void clearAcceptedShares() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get rejectedShares => $_getI64(5);
  @$pb.TagNumber(6)
  set rejectedShares($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasRejectedShares() => $_has(5);
  @$pb.TagNumber(6)
  void clearRejectedShares() => clearField(6);

  /// Unset until the miner sends a share.
  @$pb.TagNumber(7)
  $14.Timestamp get lastShareTime => $_getN(6);
  @$pb.TagNumber(7)
  set lastShareTime($14.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasLastShareTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearLastShareTime() => clearField(7);
  @$pb.TagNumber(7)
  $14.Timestamp ensureLastShareTime() => $_ensure(6);

  /// Values from the miner's device API. Unset when the device does not answer.
  @$pb.TagNumber(8)
  $core.double get temperatureCelsius => $_getN(7);
  @$pb.TagNumber(8)
  set temperatureCelsius($core.double v) { $_setDouble(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasTemperatureCelsius() => $_has(7);
  @$pb.TagNumber(8)
  void clearTemperatureCelsius() => clearField(8);

  @$pb.TagNumber(9)
  $core.double get fanPercent => $_getN(8);
  @$pb.TagNumber(9)
  set fanPercent($core.double v) { $_setDouble(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasFanPercent() => $_has(8);
  @$pb.TagNumber(9)
  void clearFanPercent() => clearField(9);

  @$pb.TagNumber(10)
  $core.double get powerWatts => $_getN(9);
  @$pb.TagNumber(10)
  set powerWatts($core.double v) { $_setDouble(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasPowerWatts() => $_has(9);
  @$pb.TagNumber(10)
  void clearPowerWatts() => clearField(10);

  @$pb.TagNumber(11)
  WorkMode get workMode => $_getN(10);
  @$pb.TagNumber(11)
  set workMode(WorkMode v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasWorkMode() => $_has(10);
  @$pb.TagNumber(11)
  void clearWorkMode() => clearField(11);
}

class FoundBlock extends $pb.GeneratedMessage {
  factory FoundBlock({
    $core.int? height,
    $core.String? hash,
    $fixnum.Int64? rewardSats,
    $core.String? worker,
    $14.Timestamp? foundTime,
    $core.int? confirmations,
  }) {
    final $result = create();
    if (height != null) {
      $result.height = height;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    if (rewardSats != null) {
      $result.rewardSats = rewardSats;
    }
    if (worker != null) {
      $result.worker = worker;
    }
    if (foundTime != null) {
      $result.foundTime = foundTime;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    return $result;
  }
  FoundBlock._() : super();
  factory FoundBlock.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FoundBlock.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FoundBlock', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..aInt64(3, _omitFieldNames ? '' : 'rewardSats')
    ..aOS(4, _omitFieldNames ? '' : 'worker')
    ..aOM<$14.Timestamp>(5, _omitFieldNames ? '' : 'foundTime', subBuilder: $14.Timestamp.create)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FoundBlock clone() => FoundBlock()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FoundBlock copyWith(void Function(FoundBlock) updates) => super.copyWith((message) => updates(message as FoundBlock)) as FoundBlock;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FoundBlock create() => FoundBlock._();
  FoundBlock createEmptyInstance() => create();
  static $pb.PbList<FoundBlock> createRepeated() => $pb.PbList<FoundBlock>();
  @$core.pragma('dart2js:noInline')
  static FoundBlock getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FoundBlock>(create);
  static FoundBlock? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get height => $_getIZ(0);
  @$pb.TagNumber(1)
  set height($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get rewardSats => $_getI64(2);
  @$pb.TagNumber(3)
  set rewardSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRewardSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearRewardSats() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get worker => $_getSZ(3);
  @$pb.TagNumber(4)
  set worker($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWorker() => $_has(3);
  @$pb.TagNumber(4)
  void clearWorker() => clearField(4);

  @$pb.TagNumber(5)
  $14.Timestamp get foundTime => $_getN(4);
  @$pb.TagNumber(5)
  set foundTime($14.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasFoundTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearFoundTime() => clearField(5);
  @$pb.TagNumber(5)
  $14.Timestamp ensureFoundTime() => $_ensure(4);

  /// Confirmations from the local node. Negative when the block left the main
  /// chain. Unset when the node does not answer.
  @$pb.TagNumber(6)
  $core.int get confirmations => $_getIZ(5);
  @$pb.TagNumber(6)
  set confirmations($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasConfirmations() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfirmations() => clearField(6);
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
  }) {
    final $result = create();
    if (running != null) {
      $result.running = running;
    }
    if (port != null) {
      $result.port = port;
    }
    if (poolUrl != null) {
      $result.poolUrl = poolUrl;
    }
    if (hashrate != null) {
      $result.hashrate = hashrate;
    }
    if (bestShare != null) {
      $result.bestShare = bestShare;
    }
    if (networkDifficulty != null) {
      $result.networkDifficulty = networkDifficulty;
    }
    if (blocksFound != null) {
      $result.blocksFound.addAll(blocksFound);
    }
    if (miners != null) {
      $result.miners.addAll(miners);
    }
    if (error != null) {
      $result.error = error;
    }
    if (target != null) {
      $result.target = target;
    }
    if (poolConnected != null) {
      $result.poolConnected = poolConnected;
    }
    if (poolHost != null) {
      $result.poolHost = poolHost;
    }
    if (payoutAddress != null) {
      $result.payoutAddress = payoutAddress;
    }
    if (acceptedShares != null) {
      $result.acceptedShares = acceptedShares;
    }
    if (rejectedShares != null) {
      $result.rejectedShares = rejectedShares;
    }
    if (settings != null) {
      $result.settings = settings;
    }
    if (recentShares != null) {
      $result.recentShares.addAll(recentShares);
    }
    if (networkHashrate != null) {
      $result.networkHashrate = networkHashrate;
    }
    return $result;
  }
  GetStratumStatusResponse._() : super();
  factory GetStratumStatusResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetStratumStatusResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetStratumStatusResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'running')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'port', $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'poolUrl')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'hashrate', $pb.PbFieldType.OD)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'bestShare', $pb.PbFieldType.OD)
    ..a<$core.double>(6, _omitFieldNames ? '' : 'networkDifficulty', $pb.PbFieldType.OD)
    ..pc<FoundBlock>(7, _omitFieldNames ? '' : 'blocksFound', $pb.PbFieldType.PM, subBuilder: FoundBlock.create)
    ..pc<ConnectedMiner>(8, _omitFieldNames ? '' : 'miners', $pb.PbFieldType.PM, subBuilder: ConnectedMiner.create)
    ..aOS(9, _omitFieldNames ? '' : 'error')
    ..aOM<Target>(10, _omitFieldNames ? '' : 'target', subBuilder: Target.create)
    ..aOB(11, _omitFieldNames ? '' : 'poolConnected')
    ..aOS(12, _omitFieldNames ? '' : 'poolHost')
    ..aOS(13, _omitFieldNames ? '' : 'payoutAddress')
    ..a<$fixnum.Int64>(14, _omitFieldNames ? '' : 'acceptedShares', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(15, _omitFieldNames ? '' : 'rejectedShares', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<MiningSettings>(16, _omitFieldNames ? '' : 'settings', subBuilder: MiningSettings.create)
    ..pc<AcceptedShare>(17, _omitFieldNames ? '' : 'recentShares', $pb.PbFieldType.PM, subBuilder: AcceptedShare.create)
    ..a<$core.double>(18, _omitFieldNames ? '' : 'networkHashrate', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetStratumStatusResponse clone() => GetStratumStatusResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetStratumStatusResponse copyWith(void Function(GetStratumStatusResponse) updates) => super.copyWith((message) => updates(message as GetStratumStatusResponse)) as GetStratumStatusResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStratumStatusResponse create() => GetStratumStatusResponse._();
  GetStratumStatusResponse createEmptyInstance() => create();
  static $pb.PbList<GetStratumStatusResponse> createRepeated() => $pb.PbList<GetStratumStatusResponse>();
  @$core.pragma('dart2js:noInline')
  static GetStratumStatusResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetStratumStatusResponse>(create);
  static GetStratumStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get running => $_getBF(0);
  @$pb.TagNumber(1)
  set running($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRunning() => $_has(0);
  @$pb.TagNumber(1)
  void clearRunning() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get port => $_getIZ(1);
  @$pb.TagNumber(2)
  set port($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPort() => $_has(1);
  @$pb.TagNumber(2)
  void clearPort() => clearField(2);

  /// stratum+tcp URL on the LAN IPv4 address of this machine. Empty when the
  /// machine has no LAN address.
  @$pb.TagNumber(3)
  $core.String get poolUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set poolUrl($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPoolUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearPoolUrl() => clearField(3);

  /// Hashes per second of all miners together.
  @$pb.TagNumber(4)
  $core.double get hashrate => $_getN(3);
  @$pb.TagNumber(4)
  set hashrate($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHashrate() => $_has(3);
  @$pb.TagNumber(4)
  void clearHashrate() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get bestShare => $_getN(4);
  @$pb.TagNumber(5)
  set bestShare($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasBestShare() => $_has(4);
  @$pb.TagNumber(5)
  void clearBestShare() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get networkDifficulty => $_getN(5);
  @$pb.TagNumber(6)
  set networkDifficulty($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasNetworkDifficulty() => $_has(5);
  @$pb.TagNumber(6)
  void clearNetworkDifficulty() => clearField(6);

  /// Blocks found since the server started, newest first.
  @$pb.TagNumber(7)
  $core.List<FoundBlock> get blocksFound => $_getList(6);

  @$pb.TagNumber(8)
  $core.List<ConnectedMiner> get miners => $_getList(7);

  /// Why the server last stopped on its own. Empty after a clean stop.
  @$pb.TagNumber(9)
  $core.String get error => $_getSZ(8);
  @$pb.TagNumber(9)
  set error($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasError() => $_has(8);
  @$pb.TagNumber(9)
  void clearError() => clearField(9);

  @$pb.TagNumber(10)
  Target get target => $_getN(9);
  @$pb.TagNumber(10)
  set target(Target v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasTarget() => $_has(9);
  @$pb.TagNumber(10)
  void clearTarget() => clearField(10);
  @$pb.TagNumber(10)
  Target ensureTarget() => $_ensure(9);

  /// Upstream pool state. Both are empty for a solo target.
  @$pb.TagNumber(11)
  $core.bool get poolConnected => $_getBF(10);
  @$pb.TagNumber(11)
  set poolConnected($core.bool v) { $_setBool(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasPoolConnected() => $_has(10);
  @$pb.TagNumber(11)
  void clearPoolConnected() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get poolHost => $_getSZ(11);
  @$pb.TagNumber(12)
  set poolHost($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasPoolHost() => $_has(11);
  @$pb.TagNumber(12)
  void clearPoolHost() => clearField(12);

  /// Wallet address that a mined block pays. The enforcer builds every
  /// coinbase to it, and a catalog pool pays out to it.
  @$pb.TagNumber(13)
  $core.String get payoutAddress => $_getSZ(12);
  @$pb.TagNumber(13)
  set payoutAddress($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasPayoutAddress() => $_has(12);
  @$pb.TagNumber(13)
  void clearPayoutAddress() => clearField(13);

  @$pb.TagNumber(14)
  $fixnum.Int64 get acceptedShares => $_getI64(13);
  @$pb.TagNumber(14)
  set acceptedShares($fixnum.Int64 v) { $_setInt64(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasAcceptedShares() => $_has(13);
  @$pb.TagNumber(14)
  void clearAcceptedShares() => clearField(14);

  @$pb.TagNumber(15)
  $fixnum.Int64 get rejectedShares => $_getI64(14);
  @$pb.TagNumber(15)
  set rejectedShares($fixnum.Int64 v) { $_setInt64(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasRejectedShares() => $_has(14);
  @$pb.TagNumber(15)
  void clearRejectedShares() => clearField(15);

  @$pb.TagNumber(16)
  MiningSettings get settings => $_getN(15);
  @$pb.TagNumber(16)
  set settings(MiningSettings v) { setField(16, v); }
  @$pb.TagNumber(16)
  $core.bool hasSettings() => $_has(15);
  @$pb.TagNumber(16)
  void clearSettings() => clearField(16);
  @$pb.TagNumber(16)
  MiningSettings ensureSettings() => $_ensure(15);

  /// The last shares the server took, newest first.
  @$pb.TagNumber(17)
  $core.List<AcceptedShare> get recentShares => $_getList(16);

  /// Hashes per second of the whole network, from the local node. Zero when
  /// the node does not answer.
  @$pb.TagNumber(18)
  $core.double get networkHashrate => $_getN(17);
  @$pb.TagNumber(18)
  set networkHashrate($core.double v) { $_setDouble(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasNetworkHashrate() => $_has(17);
  @$pb.TagNumber(18)
  void clearNetworkHashrate() => clearField(18);
}

class SetTargetRequest extends $pb.GeneratedMessage {
  factory SetTargetRequest({
    Target? target,
  }) {
    final $result = create();
    if (target != null) {
      $result.target = target;
    }
    return $result;
  }
  SetTargetRequest._() : super();
  factory SetTargetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetTargetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetTargetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..aOM<Target>(1, _omitFieldNames ? '' : 'target', subBuilder: Target.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetTargetRequest clone() => SetTargetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetTargetRequest copyWith(void Function(SetTargetRequest) updates) => super.copyWith((message) => updates(message as SetTargetRequest)) as SetTargetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetTargetRequest create() => SetTargetRequest._();
  SetTargetRequest createEmptyInstance() => create();
  static $pb.PbList<SetTargetRequest> createRepeated() => $pb.PbList<SetTargetRequest>();
  @$core.pragma('dart2js:noInline')
  static SetTargetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetTargetRequest>(create);
  static SetTargetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Target get target => $_getN(0);
  @$pb.TagNumber(1)
  set target(Target v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTarget() => $_has(0);
  @$pb.TagNumber(1)
  void clearTarget() => clearField(1);
  @$pb.TagNumber(1)
  Target ensureTarget() => $_ensure(0);
}

class SetTargetResponse extends $pb.GeneratedMessage {
  factory SetTargetResponse() => create();
  SetTargetResponse._() : super();
  factory SetTargetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetTargetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetTargetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetTargetResponse clone() => SetTargetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetTargetResponse copyWith(void Function(SetTargetResponse) updates) => super.copyWith((message) => updates(message as SetTargetResponse)) as SetTargetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetTargetResponse create() => SetTargetResponse._();
  SetTargetResponse createEmptyInstance() => create();
  static $pb.PbList<SetTargetResponse> createRepeated() => $pb.PbList<SetTargetResponse>();
  @$core.pragma('dart2js:noInline')
  static SetTargetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetTargetResponse>(create);
  static SetTargetResponse? _defaultInstance;
}

class ListTargetsRequest extends $pb.GeneratedMessage {
  factory ListTargetsRequest() => create();
  ListTargetsRequest._() : super();
  factory ListTargetsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListTargetsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTargetsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListTargetsRequest clone() => ListTargetsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListTargetsRequest copyWith(void Function(ListTargetsRequest) updates) => super.copyWith((message) => updates(message as ListTargetsRequest)) as ListTargetsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTargetsRequest create() => ListTargetsRequest._();
  ListTargetsRequest createEmptyInstance() => create();
  static $pb.PbList<ListTargetsRequest> createRepeated() => $pb.PbList<ListTargetsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListTargetsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListTargetsRequest>(create);
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
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (url != null) {
      $result.url = url;
    }
    if (fee != null) {
      $result.fee = fee;
    }
    if (hashrate != null) {
      $result.hashrate = hashrate;
    }
    return $result;
  }
  CatalogPool._() : super();
  factory CatalogPool.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CatalogPool.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CatalogPool', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..aOS(4, _omitFieldNames ? '' : 'fee')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'hashrate', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CatalogPool clone() => CatalogPool()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CatalogPool copyWith(void Function(CatalogPool) updates) => super.copyWith((message) => updates(message as CatalogPool)) as CatalogPool;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CatalogPool create() => CatalogPool._();
  CatalogPool createEmptyInstance() => create();
  static $pb.PbList<CatalogPool> createRepeated() => $pb.PbList<CatalogPool>();
  @$core.pragma('dart2js:noInline')
  static CatalogPool getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CatalogPool>(create);
  static CatalogPool? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  /// stratum+tcp URL of the pool.
  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => clearField(3);

  /// Fee as the catalog states it. Empty when the catalog states none.
  @$pb.TagNumber(4)
  $core.String get fee => $_getSZ(3);
  @$pb.TagNumber(4)
  set fee($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFee() => $_has(3);
  @$pb.TagNumber(4)
  void clearFee() => clearField(4);

  /// Hashes per second of the whole pool. Unset when the pool publishes none.
  @$pb.TagNumber(5)
  $core.double get hashrate => $_getN(4);
  @$pb.TagNumber(5)
  set hashrate($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHashrate() => $_has(4);
  @$pb.TagNumber(5)
  void clearHashrate() => clearField(5);
}

class ListTargetsResponse extends $pb.GeneratedMessage {
  factory ListTargetsResponse({
    $core.Iterable<CatalogPool>? pools,
  }) {
    final $result = create();
    if (pools != null) {
      $result.pools.addAll(pools);
    }
    return $result;
  }
  ListTargetsResponse._() : super();
  factory ListTargetsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListTargetsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTargetsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..pc<CatalogPool>(1, _omitFieldNames ? '' : 'pools', $pb.PbFieldType.PM, subBuilder: CatalogPool.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListTargetsResponse clone() => ListTargetsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListTargetsResponse copyWith(void Function(ListTargetsResponse) updates) => super.copyWith((message) => updates(message as ListTargetsResponse)) as ListTargetsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTargetsResponse create() => ListTargetsResponse._();
  ListTargetsResponse createEmptyInstance() => create();
  static $pb.PbList<ListTargetsResponse> createRepeated() => $pb.PbList<ListTargetsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListTargetsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListTargetsResponse>(create);
  static ListTargetsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<CatalogPool> get pools => $_getList(0);
}

class SetWorkModeRequest extends $pb.GeneratedMessage {
  factory SetWorkModeRequest({
    $core.String? address,
    WorkMode? mode,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (mode != null) {
      $result.mode = mode;
    }
    return $result;
  }
  SetWorkModeRequest._() : super();
  factory SetWorkModeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetWorkModeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetWorkModeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..e<WorkMode>(2, _omitFieldNames ? '' : 'mode', $pb.PbFieldType.OE, defaultOrMaker: WorkMode.WORK_MODE_UNSPECIFIED, valueOf: WorkMode.valueOf, enumValues: WorkMode.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetWorkModeRequest clone() => SetWorkModeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetWorkModeRequest copyWith(void Function(SetWorkModeRequest) updates) => super.copyWith((message) => updates(message as SetWorkModeRequest)) as SetWorkModeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetWorkModeRequest create() => SetWorkModeRequest._();
  SetWorkModeRequest createEmptyInstance() => create();
  static $pb.PbList<SetWorkModeRequest> createRepeated() => $pb.PbList<SetWorkModeRequest>();
  @$core.pragma('dart2js:noInline')
  static SetWorkModeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetWorkModeRequest>(create);
  static SetWorkModeRequest? _defaultInstance;

  /// Address of a connected miner, as GetStratumStatus reports it.
  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  WorkMode get mode => $_getN(1);
  @$pb.TagNumber(2)
  set mode(WorkMode v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearMode() => clearField(2);
}

class SetWorkModeResponse extends $pb.GeneratedMessage {
  factory SetWorkModeResponse() => create();
  SetWorkModeResponse._() : super();
  factory SetWorkModeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetWorkModeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetWorkModeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'stratum.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetWorkModeResponse clone() => SetWorkModeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetWorkModeResponse copyWith(void Function(SetWorkModeResponse) updates) => super.copyWith((message) => updates(message as SetWorkModeResponse)) as SetWorkModeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetWorkModeResponse create() => SetWorkModeResponse._();
  SetWorkModeResponse createEmptyInstance() => create();
  static $pb.PbList<SetWorkModeResponse> createRepeated() => $pb.PbList<SetWorkModeResponse>();
  @$core.pragma('dart2js:noInline')
  static SetWorkModeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetWorkModeResponse>(create);
  static SetWorkModeResponse? _defaultInstance;
}

class StratumServiceApi {
  $pb.RpcClient _client;
  StratumServiceApi(this._client);

  $async.Future<StartStratumResponse> startStratum($pb.ClientContext? ctx, StartStratumRequest request) =>
    _client.invoke<StartStratumResponse>(ctx, 'StratumService', 'StartStratum', request, StartStratumResponse())
  ;
  $async.Future<StopStratumResponse> stopStratum($pb.ClientContext? ctx, StopStratumRequest request) =>
    _client.invoke<StopStratumResponse>(ctx, 'StratumService', 'StopStratum', request, StopStratumResponse())
  ;
  $async.Future<GetStratumStatusResponse> getStratumStatus($pb.ClientContext? ctx, GetStratumStatusRequest request) =>
    _client.invoke<GetStratumStatusResponse>(ctx, 'StratumService', 'GetStratumStatus', request, GetStratumStatusResponse())
  ;
  $async.Future<SetTargetResponse> setTarget($pb.ClientContext? ctx, SetTargetRequest request) =>
    _client.invoke<SetTargetResponse>(ctx, 'StratumService', 'SetTarget', request, SetTargetResponse())
  ;
  $async.Future<ListTargetsResponse> listTargets($pb.ClientContext? ctx, ListTargetsRequest request) =>
    _client.invoke<ListTargetsResponse>(ctx, 'StratumService', 'ListTargets', request, ListTargetsResponse())
  ;
  $async.Future<SetWorkModeResponse> setWorkMode($pb.ClientContext? ctx, SetWorkModeRequest request) =>
    _client.invoke<SetWorkModeResponse>(ctx, 'StratumService', 'SetWorkMode', request, SetWorkModeResponse())
  ;
  $async.Future<SetMiningSettingsResponse> setMiningSettings($pb.ClientContext? ctx, SetMiningSettingsRequest request) =>
    _client.invoke<SetMiningSettingsResponse>(ctx, 'StratumService', 'SetMiningSettings', request, SetMiningSettingsResponse())
  ;
  $async.Future<GetHashrateHistoryResponse> getHashrateHistory($pb.ClientContext? ctx, GetHashrateHistoryRequest request) =>
    _client.invoke<GetHashrateHistoryResponse>(ctx, 'StratumService', 'GetHashrateHistory', request, GetHashrateHistoryResponse())
  ;
  $async.Future<ListPoolBlocksResponse> listPoolBlocks($pb.ClientContext? ctx, ListPoolBlocksRequest request) =>
    _client.invoke<ListPoolBlocksResponse>(ctx, 'StratumService', 'ListPoolBlocks', request, ListPoolBlocksResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
