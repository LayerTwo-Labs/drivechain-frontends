// This is a generated file - do not edit.
//
// Generated from health/v1/health.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $0;

import 'health.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'health.pbenum.dart';

/// Define a message to hold both service name and its status
class CheckResponse_ServiceStatus extends $pb.GeneratedMessage {
  factory CheckResponse_ServiceStatus({
    $core.String? serviceName,
    CheckResponse_Status? status,
  }) {
    final result = CheckResponse_ServiceStatus._();
    if (serviceName != null) result.serviceName = serviceName;
    if (status != null) result.status = status;
    return result;
  }

  CheckResponse_ServiceStatus._();

  factory CheckResponse_ServiceStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckResponse_ServiceStatus()..mergeFromBuffer(data, registry);
  factory CheckResponse_ServiceStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckResponse_ServiceStatus()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckResponse.ServiceStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'health.v1'),
      createEmptyInstance: CheckResponse_ServiceStatus.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'serviceName')
    ..aE<CheckResponse_Status>(2, _omitFieldNames ? '' : 'status', enumValues: CheckResponse_Status.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckResponse_ServiceStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckResponse_ServiceStatus copyWith(void Function(CheckResponse_ServiceStatus) updates) =>
      super.copyWith((message) => updates(message as CheckResponse_ServiceStatus)) as CheckResponse_ServiceStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CheckResponse_ServiceStatus() / CheckResponse_ServiceStatus.new instead')
  static CheckResponse_ServiceStatus create() => CheckResponse_ServiceStatus._();
  static $pb.GeneratedMessage $_createMessage() => CheckResponse_ServiceStatus._();
  @$core.override
  CheckResponse_ServiceStatus createEmptyInstance() => CheckResponse_ServiceStatus._();
  @$core.pragma('dart2js:noInline')
  static CheckResponse_ServiceStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckResponse_ServiceStatus>(CheckResponse_ServiceStatus.$_createMessage);
  static CheckResponse_ServiceStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get serviceName => $_getSZ(0);
  @$pb.TagNumber(1)
  set serviceName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasServiceName() => $_has(0);
  @$pb.TagNumber(1)
  void clearServiceName() => $_clearField(1);

  @$pb.TagNumber(2)
  CheckResponse_Status get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(CheckResponse_Status value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);
}

class CheckResponse extends $pb.GeneratedMessage {
  factory CheckResponse({
    $core.Iterable<CheckResponse_ServiceStatus>? serviceStatuses,
  }) {
    final result = CheckResponse._();
    if (serviceStatuses != null) result.serviceStatuses.addAll(serviceStatuses);
    return result;
  }

  CheckResponse._();

  factory CheckResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckResponse()..mergeFromBuffer(data, registry);
  factory CheckResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'health.v1'),
      createEmptyInstance: CheckResponse.$_createMessage)
    ..pPM<CheckResponse_ServiceStatus>(1, _omitFieldNames ? '' : 'serviceStatuses',
        subBuilder: CheckResponse_ServiceStatus.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckResponse copyWith(void Function(CheckResponse) updates) =>
      super.copyWith((message) => updates(message as CheckResponse)) as CheckResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CheckResponse() / CheckResponse.new instead')
  static CheckResponse create() => CheckResponse._();
  static $pb.GeneratedMessage $_createMessage() => CheckResponse._();
  @$core.override
  CheckResponse createEmptyInstance() => CheckResponse._();
  @$core.pragma('dart2js:noInline')
  static CheckResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckResponse>(CheckResponse.$_createMessage);
  static CheckResponse? _defaultInstance;

  /// Return a list of service statuses
  @$pb.TagNumber(1)
  $pb.PbList<CheckResponse_ServiceStatus> get serviceStatuses => $_getList(0);
}

class HealthServiceApi {
  final $pb.RpcClient _client;

  HealthServiceApi(this._client);

  /// Check status of requested services
  /// buf:lint:ignore RPC_REQUEST_RESPONSE_UNIQUE
  $async.Future<CheckResponse> check_($pb.ClientContext? ctx, $0.Empty request) =>
      _client.invoke<CheckResponse>(ctx, 'HealthService', 'Check', request, CheckResponse());

  /// buf:lint:ignore RPC_REQUEST_RESPONSE_UNIQUE
  /// buf:lint:ignore RPC_RESPONSE_STANDARD_NAME
  $async.Future<CheckResponse> watch($pb.ClientContext? ctx, $0.Empty request) =>
      _client.invoke<CheckResponse>(ctx, 'HealthService', 'Watch', request, CheckResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
