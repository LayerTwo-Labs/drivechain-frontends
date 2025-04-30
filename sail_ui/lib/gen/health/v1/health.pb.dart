//
//  Generated code. Do not modify.
//  source: health/v1/health.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../google/protobuf/empty.pb.dart' as $1;
import 'health.pbenum.dart';

export 'health.pbenum.dart';

/// Define a message to hold both service name and its status
class CheckResponse_ServiceStatus extends $pb.GeneratedMessage {
  factory CheckResponse_ServiceStatus({
    $core.String? serviceName,
    CheckResponse_Status? status,
  }) {
    final $result = create();
    if (serviceName != null) {
      $result.serviceName = serviceName;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  CheckResponse_ServiceStatus._() : super();
  factory CheckResponse_ServiceStatus.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CheckResponse_ServiceStatus.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckResponse.ServiceStatus', package: const $pb.PackageName(_omitMessageNames ? '' : 'health.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'serviceName')
    ..e<CheckResponse_Status>(2, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: CheckResponse_Status.STATUS_UNSPECIFIED, valueOf: CheckResponse_Status.valueOf, enumValues: CheckResponse_Status.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CheckResponse_ServiceStatus clone() => CheckResponse_ServiceStatus()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CheckResponse_ServiceStatus copyWith(void Function(CheckResponse_ServiceStatus) updates) => super.copyWith((message) => updates(message as CheckResponse_ServiceStatus)) as CheckResponse_ServiceStatus;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckResponse_ServiceStatus create() => CheckResponse_ServiceStatus._();
  CheckResponse_ServiceStatus createEmptyInstance() => create();
  static $pb.PbList<CheckResponse_ServiceStatus> createRepeated() => $pb.PbList<CheckResponse_ServiceStatus>();
  @$core.pragma('dart2js:noInline')
  static CheckResponse_ServiceStatus getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckResponse_ServiceStatus>(create);
  static CheckResponse_ServiceStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get serviceName => $_getSZ(0);
  @$pb.TagNumber(1)
  set serviceName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasServiceName() => $_has(0);
  @$pb.TagNumber(1)
  void clearServiceName() => clearField(1);

  @$pb.TagNumber(2)
  CheckResponse_Status get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(CheckResponse_Status v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => clearField(2);
}

class CheckResponse extends $pb.GeneratedMessage {
  factory CheckResponse({
    $core.Iterable<CheckResponse_ServiceStatus>? serviceStatuses,
  }) {
    final $result = create();
    if (serviceStatuses != null) {
      $result.serviceStatuses.addAll(serviceStatuses);
    }
    return $result;
  }
  CheckResponse._() : super();
  factory CheckResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CheckResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'health.v1'), createEmptyInstance: create)
    ..pc<CheckResponse_ServiceStatus>(1, _omitFieldNames ? '' : 'serviceStatuses', $pb.PbFieldType.PM, subBuilder: CheckResponse_ServiceStatus.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CheckResponse clone() => CheckResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CheckResponse copyWith(void Function(CheckResponse) updates) => super.copyWith((message) => updates(message as CheckResponse)) as CheckResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckResponse create() => CheckResponse._();
  CheckResponse createEmptyInstance() => create();
  static $pb.PbList<CheckResponse> createRepeated() => $pb.PbList<CheckResponse>();
  @$core.pragma('dart2js:noInline')
  static CheckResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckResponse>(create);
  static CheckResponse? _defaultInstance;

  /// Return a list of service statuses
  @$pb.TagNumber(1)
  $core.List<CheckResponse_ServiceStatus> get serviceStatuses => $_getList(0);
}

class HealthServiceApi {
  $pb.RpcClient _client;
  HealthServiceApi(this._client);

  $async.Future<CheckResponse> check_($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<CheckResponse>(ctx, 'HealthService', 'Check', request, CheckResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
