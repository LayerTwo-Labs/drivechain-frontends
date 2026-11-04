// This is a generated file - do not edit.
//
// Generated from utils/v1/utils.proto.

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

import 'utils.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'utils.pbenum.dart';

/// Bitcoin URI (BIP-0021)
class ParseBitcoinURIRequest extends $pb.GeneratedMessage {
  factory ParseBitcoinURIRequest({
    $core.String? uri,
  }) {
    final result = ParseBitcoinURIRequest._();
    if (uri != null) result.uri = uri;
    return result;
  }

  ParseBitcoinURIRequest._();

  factory ParseBitcoinURIRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ParseBitcoinURIRequest()..mergeFromBuffer(data, registry);
  factory ParseBitcoinURIRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ParseBitcoinURIRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ParseBitcoinURIRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: ParseBitcoinURIRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'uri')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParseBitcoinURIRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParseBitcoinURIRequest copyWith(void Function(ParseBitcoinURIRequest) updates) =>
      super.copyWith((message) => updates(message as ParseBitcoinURIRequest)) as ParseBitcoinURIRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ParseBitcoinURIRequest() / ParseBitcoinURIRequest.new instead')
  static ParseBitcoinURIRequest create() => ParseBitcoinURIRequest._();
  static $pb.GeneratedMessage $_createMessage() => ParseBitcoinURIRequest._();
  @$core.override
  ParseBitcoinURIRequest createEmptyInstance() => ParseBitcoinURIRequest._();
  @$core.pragma('dart2js:noInline')
  static ParseBitcoinURIRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ParseBitcoinURIRequest>(ParseBitcoinURIRequest.$_createMessage);
  static ParseBitcoinURIRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get uri => $_getSZ(0);
  @$pb.TagNumber(1)
  set uri($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUri() => $_has(0);
  @$pb.TagNumber(1)
  void clearUri() => $_clearField(1);
}

class ParseBitcoinURIResponse extends $pb.GeneratedMessage {
  factory ParseBitcoinURIResponse({
    $core.String? address,
    $core.double? amount,
    $core.String? label,
    $core.String? message,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? extraParams,
  }) {
    final result = ParseBitcoinURIResponse._();
    if (address != null) result.address = address;
    if (amount != null) result.amount = amount;
    if (label != null) result.label = label;
    if (message != null) result.message = message;
    if (extraParams != null) result.extraParams.addEntries(extraParams);
    return result;
  }

  ParseBitcoinURIResponse._();

  factory ParseBitcoinURIResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ParseBitcoinURIResponse()..mergeFromBuffer(data, registry);
  factory ParseBitcoinURIResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ParseBitcoinURIResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ParseBitcoinURIResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: ParseBitcoinURIResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aD(2, _omitFieldNames ? '' : 'amount')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..aOS(4, _omitFieldNames ? '' : 'message')
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'extraParams',
        entryClassName: 'ParseBitcoinURIResponse.ExtraParamsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('utils.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParseBitcoinURIResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParseBitcoinURIResponse copyWith(void Function(ParseBitcoinURIResponse) updates) =>
      super.copyWith((message) => updates(message as ParseBitcoinURIResponse)) as ParseBitcoinURIResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ParseBitcoinURIResponse() / ParseBitcoinURIResponse.new instead')
  static ParseBitcoinURIResponse create() => ParseBitcoinURIResponse._();
  static $pb.GeneratedMessage $_createMessage() => ParseBitcoinURIResponse._();
  @$core.override
  ParseBitcoinURIResponse createEmptyInstance() => ParseBitcoinURIResponse._();
  @$core.pragma('dart2js:noInline')
  static ParseBitcoinURIResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ParseBitcoinURIResponse>(ParseBitcoinURIResponse.$_createMessage);
  static ParseBitcoinURIResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get extraParams => $_getMap(4);
}

class ValidateBitcoinURIRequest extends $pb.GeneratedMessage {
  factory ValidateBitcoinURIRequest({
    $core.String? uri,
  }) {
    final result = ValidateBitcoinURIRequest._();
    if (uri != null) result.uri = uri;
    return result;
  }

  ValidateBitcoinURIRequest._();

  factory ValidateBitcoinURIRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateBitcoinURIRequest()..mergeFromBuffer(data, registry);
  factory ValidateBitcoinURIRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateBitcoinURIRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateBitcoinURIRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: ValidateBitcoinURIRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'uri')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateBitcoinURIRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateBitcoinURIRequest copyWith(void Function(ValidateBitcoinURIRequest) updates) =>
      super.copyWith((message) => updates(message as ValidateBitcoinURIRequest)) as ValidateBitcoinURIRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidateBitcoinURIRequest() / ValidateBitcoinURIRequest.new instead')
  static ValidateBitcoinURIRequest create() => ValidateBitcoinURIRequest._();
  static $pb.GeneratedMessage $_createMessage() => ValidateBitcoinURIRequest._();
  @$core.override
  ValidateBitcoinURIRequest createEmptyInstance() => ValidateBitcoinURIRequest._();
  @$core.pragma('dart2js:noInline')
  static ValidateBitcoinURIRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateBitcoinURIRequest>(ValidateBitcoinURIRequest.$_createMessage);
  static ValidateBitcoinURIRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get uri => $_getSZ(0);
  @$pb.TagNumber(1)
  set uri($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUri() => $_has(0);
  @$pb.TagNumber(1)
  void clearUri() => $_clearField(1);
}

class ValidateBitcoinURIResponse extends $pb.GeneratedMessage {
  factory ValidateBitcoinURIResponse({
    $core.bool? valid,
    $core.String? error,
  }) {
    final result = ValidateBitcoinURIResponse._();
    if (valid != null) result.valid = valid;
    if (error != null) result.error = error;
    return result;
  }

  ValidateBitcoinURIResponse._();

  factory ValidateBitcoinURIResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateBitcoinURIResponse()..mergeFromBuffer(data, registry);
  factory ValidateBitcoinURIResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateBitcoinURIResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateBitcoinURIResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: ValidateBitcoinURIResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateBitcoinURIResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateBitcoinURIResponse copyWith(void Function(ValidateBitcoinURIResponse) updates) =>
      super.copyWith((message) => updates(message as ValidateBitcoinURIResponse)) as ValidateBitcoinURIResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidateBitcoinURIResponse() / ValidateBitcoinURIResponse.new instead')
  static ValidateBitcoinURIResponse create() => ValidateBitcoinURIResponse._();
  static $pb.GeneratedMessage $_createMessage() => ValidateBitcoinURIResponse._();
  @$core.override
  ValidateBitcoinURIResponse createEmptyInstance() => ValidateBitcoinURIResponse._();
  @$core.pragma('dart2js:noInline')
  static ValidateBitcoinURIResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateBitcoinURIResponse>(ValidateBitcoinURIResponse.$_createMessage);
  static ValidateBitcoinURIResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
}

/// Base58Check
class DecodeBase58CheckRequest extends $pb.GeneratedMessage {
  factory DecodeBase58CheckRequest({
    $core.String? input,
  }) {
    final result = DecodeBase58CheckRequest._();
    if (input != null) result.input = input;
    return result;
  }

  DecodeBase58CheckRequest._();

  factory DecodeBase58CheckRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodeBase58CheckRequest()..mergeFromBuffer(data, registry);
  factory DecodeBase58CheckRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodeBase58CheckRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodeBase58CheckRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: DecodeBase58CheckRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'input')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodeBase58CheckRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodeBase58CheckRequest copyWith(void Function(DecodeBase58CheckRequest) updates) =>
      super.copyWith((message) => updates(message as DecodeBase58CheckRequest)) as DecodeBase58CheckRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DecodeBase58CheckRequest() / DecodeBase58CheckRequest.new instead')
  static DecodeBase58CheckRequest create() => DecodeBase58CheckRequest._();
  static $pb.GeneratedMessage $_createMessage() => DecodeBase58CheckRequest._();
  @$core.override
  DecodeBase58CheckRequest createEmptyInstance() => DecodeBase58CheckRequest._();
  @$core.pragma('dart2js:noInline')
  static DecodeBase58CheckRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecodeBase58CheckRequest>(DecodeBase58CheckRequest.$_createMessage);
  static DecodeBase58CheckRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get input => $_getSZ(0);
  @$pb.TagNumber(1)
  set input($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInput() => $_has(0);
  @$pb.TagNumber(1)
  void clearInput() => $_clearField(1);
}

class DecodeBase58CheckResponse extends $pb.GeneratedMessage {
  factory DecodeBase58CheckResponse({
    $core.bool? valid,
    $core.int? versionByte,
    $core.List<$core.int>? payload,
    $core.List<$core.int>? checksum,
    $core.bool? checksumValid,
    $core.String? addressType,
    $core.String? error,
  }) {
    final result = DecodeBase58CheckResponse._();
    if (valid != null) result.valid = valid;
    if (versionByte != null) result.versionByte = versionByte;
    if (payload != null) result.payload = payload;
    if (checksum != null) result.checksum = checksum;
    if (checksumValid != null) result.checksumValid = checksumValid;
    if (addressType != null) result.addressType = addressType;
    if (error != null) result.error = error;
    return result;
  }

  DecodeBase58CheckResponse._();

  factory DecodeBase58CheckResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodeBase58CheckResponse()..mergeFromBuffer(data, registry);
  factory DecodeBase58CheckResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodeBase58CheckResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodeBase58CheckResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: DecodeBase58CheckResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..aI(2, _omitFieldNames ? '' : 'versionByte')
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'checksum', $pb.PbFieldType.OY)
    ..aOB(5, _omitFieldNames ? '' : 'checksumValid')
    ..aOS(6, _omitFieldNames ? '' : 'addressType')
    ..aOS(7, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodeBase58CheckResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodeBase58CheckResponse copyWith(void Function(DecodeBase58CheckResponse) updates) =>
      super.copyWith((message) => updates(message as DecodeBase58CheckResponse)) as DecodeBase58CheckResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DecodeBase58CheckResponse() / DecodeBase58CheckResponse.new instead')
  static DecodeBase58CheckResponse create() => DecodeBase58CheckResponse._();
  static $pb.GeneratedMessage $_createMessage() => DecodeBase58CheckResponse._();
  @$core.override
  DecodeBase58CheckResponse createEmptyInstance() => DecodeBase58CheckResponse._();
  @$core.pragma('dart2js:noInline')
  static DecodeBase58CheckResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecodeBase58CheckResponse>(DecodeBase58CheckResponse.$_createMessage);
  static DecodeBase58CheckResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get versionByte => $_getIZ(1);
  @$pb.TagNumber(2)
  set versionByte($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersionByte() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersionByte() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get payload => $_getN(2);
  @$pb.TagNumber(3)
  set payload($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPayload() => $_has(2);
  @$pb.TagNumber(3)
  void clearPayload() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get checksum => $_getN(3);
  @$pb.TagNumber(4)
  set checksum($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChecksum() => $_has(3);
  @$pb.TagNumber(4)
  void clearChecksum() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get checksumValid => $_getBF(4);
  @$pb.TagNumber(5)
  set checksumValid($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasChecksumValid() => $_has(4);
  @$pb.TagNumber(5)
  void clearChecksumValid() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get addressType => $_getSZ(5);
  @$pb.TagNumber(6)
  set addressType($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAddressType() => $_has(5);
  @$pb.TagNumber(6)
  void clearAddressType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get error => $_getSZ(6);
  @$pb.TagNumber(7)
  set error($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasError() => $_has(6);
  @$pb.TagNumber(7)
  void clearError() => $_clearField(7);
}

class EncodeBase58CheckRequest extends $pb.GeneratedMessage {
  factory EncodeBase58CheckRequest({
    $core.int? versionByte,
    $core.List<$core.int>? data,
  }) {
    final result = EncodeBase58CheckRequest._();
    if (versionByte != null) result.versionByte = versionByte;
    if (data != null) result.data = data;
    return result;
  }

  EncodeBase58CheckRequest._();

  factory EncodeBase58CheckRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EncodeBase58CheckRequest()..mergeFromBuffer(data, registry);
  factory EncodeBase58CheckRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EncodeBase58CheckRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncodeBase58CheckRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: EncodeBase58CheckRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'versionByte')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncodeBase58CheckRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncodeBase58CheckRequest copyWith(void Function(EncodeBase58CheckRequest) updates) =>
      super.copyWith((message) => updates(message as EncodeBase58CheckRequest)) as EncodeBase58CheckRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EncodeBase58CheckRequest() / EncodeBase58CheckRequest.new instead')
  static EncodeBase58CheckRequest create() => EncodeBase58CheckRequest._();
  static $pb.GeneratedMessage $_createMessage() => EncodeBase58CheckRequest._();
  @$core.override
  EncodeBase58CheckRequest createEmptyInstance() => EncodeBase58CheckRequest._();
  @$core.pragma('dart2js:noInline')
  static EncodeBase58CheckRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EncodeBase58CheckRequest>(EncodeBase58CheckRequest.$_createMessage);
  static EncodeBase58CheckRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get versionByte => $_getIZ(0);
  @$pb.TagNumber(1)
  set versionByte($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersionByte() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersionByte() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => $_clearField(2);
}

class EncodeBase58CheckResponse extends $pb.GeneratedMessage {
  factory EncodeBase58CheckResponse({
    $core.String? encoded,
    $core.String? error,
  }) {
    final result = EncodeBase58CheckResponse._();
    if (encoded != null) result.encoded = encoded;
    if (error != null) result.error = error;
    return result;
  }

  EncodeBase58CheckResponse._();

  factory EncodeBase58CheckResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EncodeBase58CheckResponse()..mergeFromBuffer(data, registry);
  factory EncodeBase58CheckResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EncodeBase58CheckResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncodeBase58CheckResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: EncodeBase58CheckResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'encoded')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncodeBase58CheckResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncodeBase58CheckResponse copyWith(void Function(EncodeBase58CheckResponse) updates) =>
      super.copyWith((message) => updates(message as EncodeBase58CheckResponse)) as EncodeBase58CheckResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EncodeBase58CheckResponse() / EncodeBase58CheckResponse.new instead')
  static EncodeBase58CheckResponse create() => EncodeBase58CheckResponse._();
  static $pb.GeneratedMessage $_createMessage() => EncodeBase58CheckResponse._();
  @$core.override
  EncodeBase58CheckResponse createEmptyInstance() => EncodeBase58CheckResponse._();
  @$core.pragma('dart2js:noInline')
  static EncodeBase58CheckResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EncodeBase58CheckResponse>(EncodeBase58CheckResponse.$_createMessage);
  static EncodeBase58CheckResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get encoded => $_getSZ(0);
  @$pb.TagNumber(1)
  set encoded($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEncoded() => $_has(0);
  @$pb.TagNumber(1)
  void clearEncoded() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
}

/// Merkle Tree
class CalculateMerkleTreeRequest extends $pb.GeneratedMessage {
  factory CalculateMerkleTreeRequest({
    $core.Iterable<$core.String>? txids,
    $core.bool? showRcb,
  }) {
    final result = CalculateMerkleTreeRequest._();
    if (txids != null) result.txids.addAll(txids);
    if (showRcb != null) result.showRcb = showRcb;
    return result;
  }

  CalculateMerkleTreeRequest._();

  factory CalculateMerkleTreeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculateMerkleTreeRequest()..mergeFromBuffer(data, registry);
  factory CalculateMerkleTreeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculateMerkleTreeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CalculateMerkleTreeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: CalculateMerkleTreeRequest.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'txids')
    ..aOB(2, _omitFieldNames ? '' : 'showRcb')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculateMerkleTreeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculateMerkleTreeRequest copyWith(void Function(CalculateMerkleTreeRequest) updates) =>
      super.copyWith((message) => updates(message as CalculateMerkleTreeRequest)) as CalculateMerkleTreeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CalculateMerkleTreeRequest() / CalculateMerkleTreeRequest.new instead')
  static CalculateMerkleTreeRequest create() => CalculateMerkleTreeRequest._();
  static $pb.GeneratedMessage $_createMessage() => CalculateMerkleTreeRequest._();
  @$core.override
  CalculateMerkleTreeRequest createEmptyInstance() => CalculateMerkleTreeRequest._();
  @$core.pragma('dart2js:noInline')
  static CalculateMerkleTreeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalculateMerkleTreeRequest>(CalculateMerkleTreeRequest.$_createMessage);
  static CalculateMerkleTreeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get txids => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get showRcb => $_getBF(1);
  @$pb.TagNumber(2)
  set showRcb($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasShowRcb() => $_has(1);
  @$pb.TagNumber(2)
  void clearShowRcb() => $_clearField(2);
}

class CalculateMerkleTreeResponse extends $pb.GeneratedMessage {
  factory CalculateMerkleTreeResponse({
    $core.String? merkleRoot,
    $core.Iterable<MerkleTreeLevel>? levels,
    $core.String? formattedText,
  }) {
    final result = CalculateMerkleTreeResponse._();
    if (merkleRoot != null) result.merkleRoot = merkleRoot;
    if (levels != null) result.levels.addAll(levels);
    if (formattedText != null) result.formattedText = formattedText;
    return result;
  }

  CalculateMerkleTreeResponse._();

  factory CalculateMerkleTreeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculateMerkleTreeResponse()..mergeFromBuffer(data, registry);
  factory CalculateMerkleTreeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculateMerkleTreeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CalculateMerkleTreeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: CalculateMerkleTreeResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'merkleRoot')
    ..pPM<MerkleTreeLevel>(2, _omitFieldNames ? '' : 'levels', subBuilder: MerkleTreeLevel.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'formattedText')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculateMerkleTreeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculateMerkleTreeResponse copyWith(void Function(CalculateMerkleTreeResponse) updates) =>
      super.copyWith((message) => updates(message as CalculateMerkleTreeResponse)) as CalculateMerkleTreeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CalculateMerkleTreeResponse() / CalculateMerkleTreeResponse.new instead')
  static CalculateMerkleTreeResponse create() => CalculateMerkleTreeResponse._();
  static $pb.GeneratedMessage $_createMessage() => CalculateMerkleTreeResponse._();
  @$core.override
  CalculateMerkleTreeResponse createEmptyInstance() => CalculateMerkleTreeResponse._();
  @$core.pragma('dart2js:noInline')
  static CalculateMerkleTreeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalculateMerkleTreeResponse>(CalculateMerkleTreeResponse.$_createMessage);
  static CalculateMerkleTreeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get merkleRoot => $_getSZ(0);
  @$pb.TagNumber(1)
  set merkleRoot($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMerkleRoot() => $_has(0);
  @$pb.TagNumber(1)
  void clearMerkleRoot() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<MerkleTreeLevel> get levels => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get formattedText => $_getSZ(2);
  @$pb.TagNumber(3)
  set formattedText($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFormattedText() => $_has(2);
  @$pb.TagNumber(3)
  void clearFormattedText() => $_clearField(3);
}

class MerkleTreeLevel extends $pb.GeneratedMessage {
  factory MerkleTreeLevel({
    $core.int? level,
    $core.Iterable<$core.String>? hashes,
    $core.Iterable<$core.String>? rcb,
  }) {
    final result = MerkleTreeLevel._();
    if (level != null) result.level = level;
    if (hashes != null) result.hashes.addAll(hashes);
    if (rcb != null) result.rcb.addAll(rcb);
    return result;
  }

  MerkleTreeLevel._();

  factory MerkleTreeLevel.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MerkleTreeLevel()..mergeFromBuffer(data, registry);
  factory MerkleTreeLevel.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MerkleTreeLevel()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MerkleTreeLevel',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: MerkleTreeLevel.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'level')
    ..pPS(2, _omitFieldNames ? '' : 'hashes')
    ..pPS(3, _omitFieldNames ? '' : 'rcb')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MerkleTreeLevel clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MerkleTreeLevel copyWith(void Function(MerkleTreeLevel) updates) =>
      super.copyWith((message) => updates(message as MerkleTreeLevel)) as MerkleTreeLevel;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MerkleTreeLevel() / MerkleTreeLevel.new instead')
  static MerkleTreeLevel create() => MerkleTreeLevel._();
  static $pb.GeneratedMessage $_createMessage() => MerkleTreeLevel._();
  @$core.override
  MerkleTreeLevel createEmptyInstance() => MerkleTreeLevel._();
  @$core.pragma('dart2js:noInline')
  static MerkleTreeLevel getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MerkleTreeLevel>(MerkleTreeLevel.$_createMessage);
  static MerkleTreeLevel? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get level => $_getIZ(0);
  @$pb.TagNumber(1)
  set level($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLevel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLevel() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get hashes => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get rcb => $_getList(2);
}

/// Paper Wallet
class GeneratePaperWalletResponse extends $pb.GeneratedMessage {
  factory GeneratePaperWalletResponse({
    $core.String? privateKeyWif,
    $core.String? publicAddress,
    $core.String? privateKeyHex,
  }) {
    final result = GeneratePaperWalletResponse._();
    if (privateKeyWif != null) result.privateKeyWif = privateKeyWif;
    if (publicAddress != null) result.publicAddress = publicAddress;
    if (privateKeyHex != null) result.privateKeyHex = privateKeyHex;
    return result;
  }

  GeneratePaperWalletResponse._();

  factory GeneratePaperWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GeneratePaperWalletResponse()..mergeFromBuffer(data, registry);
  factory GeneratePaperWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GeneratePaperWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GeneratePaperWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: GeneratePaperWalletResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'privateKeyWif')
    ..aOS(2, _omitFieldNames ? '' : 'publicAddress')
    ..aOS(3, _omitFieldNames ? '' : 'privateKeyHex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeneratePaperWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeneratePaperWalletResponse copyWith(void Function(GeneratePaperWalletResponse) updates) =>
      super.copyWith((message) => updates(message as GeneratePaperWalletResponse)) as GeneratePaperWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GeneratePaperWalletResponse() / GeneratePaperWalletResponse.new instead')
  static GeneratePaperWalletResponse create() => GeneratePaperWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => GeneratePaperWalletResponse._();
  @$core.override
  GeneratePaperWalletResponse createEmptyInstance() => GeneratePaperWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static GeneratePaperWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GeneratePaperWalletResponse>(GeneratePaperWalletResponse.$_createMessage);
  static GeneratePaperWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get privateKeyWif => $_getSZ(0);
  @$pb.TagNumber(1)
  set privateKeyWif($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPrivateKeyWif() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrivateKeyWif() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get publicAddress => $_getSZ(1);
  @$pb.TagNumber(2)
  set publicAddress($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPublicAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearPublicAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get privateKeyHex => $_getSZ(2);
  @$pb.TagNumber(3)
  set privateKeyHex($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrivateKeyHex() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrivateKeyHex() => $_clearField(3);
}

/// QrMatrix is the module grid of one QR code.
class QrMatrix extends $pb.GeneratedMessage {
  factory QrMatrix({
    $core.int? size,
    $core.List<$core.int>? modules,
  }) {
    final result = QrMatrix._();
    if (size != null) result.size = size;
    if (modules != null) result.modules = modules;
    return result;
  }

  QrMatrix._();

  factory QrMatrix.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QrMatrix()..mergeFromBuffer(data, registry);
  factory QrMatrix.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QrMatrix()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'QrMatrix',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: QrMatrix.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'size')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'modules', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QrMatrix clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QrMatrix copyWith(void Function(QrMatrix) updates) =>
      super.copyWith((message) => updates(message as QrMatrix)) as QrMatrix;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use QrMatrix() / QrMatrix.new instead')
  static QrMatrix create() => QrMatrix._();
  static $pb.GeneratedMessage $_createMessage() => QrMatrix._();
  @$core.override
  QrMatrix createEmptyInstance() => QrMatrix._();
  @$core.pragma('dart2js:noInline')
  static QrMatrix getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QrMatrix>(QrMatrix.$_createMessage);
  static QrMatrix? _defaultInstance;

  /// Count of modules per side.
  @$pb.TagNumber(1)
  $core.int get size => $_getIZ(0);
  @$pb.TagNumber(1)
  set size($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearSize() => $_clearField(1);

  /// One byte per module, row-major from the top-left module. 1 is dark, 0 is light.
  @$pb.TagNumber(2)
  $core.List<$core.int> get modules => $_getN(1);
  @$pb.TagNumber(2)
  set modules($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasModules() => $_has(1);
  @$pb.TagNumber(2)
  void clearModules() => $_clearField(2);
}

class CreatePaperWalletPdfRequest extends $pb.GeneratedMessage {
  factory CreatePaperWalletPdfRequest({
    $core.String? publicAddress,
    $core.String? privateKeyWif,
    QrMatrix? addressQr,
    QrMatrix? privateKeyQr,
  }) {
    final result = CreatePaperWalletPdfRequest._();
    if (publicAddress != null) result.publicAddress = publicAddress;
    if (privateKeyWif != null) result.privateKeyWif = privateKeyWif;
    if (addressQr != null) result.addressQr = addressQr;
    if (privateKeyQr != null) result.privateKeyQr = privateKeyQr;
    return result;
  }

  CreatePaperWalletPdfRequest._();

  factory CreatePaperWalletPdfRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePaperWalletPdfRequest()..mergeFromBuffer(data, registry);
  factory CreatePaperWalletPdfRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePaperWalletPdfRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePaperWalletPdfRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: CreatePaperWalletPdfRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'publicAddress')
    ..aOS(2, _omitFieldNames ? '' : 'privateKeyWif')
    ..aOM<QrMatrix>(3, _omitFieldNames ? '' : 'addressQr', subBuilder: QrMatrix.$_createMessage)
    ..aOM<QrMatrix>(4, _omitFieldNames ? '' : 'privateKeyQr', subBuilder: QrMatrix.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePaperWalletPdfRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePaperWalletPdfRequest copyWith(void Function(CreatePaperWalletPdfRequest) updates) =>
      super.copyWith((message) => updates(message as CreatePaperWalletPdfRequest)) as CreatePaperWalletPdfRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreatePaperWalletPdfRequest() / CreatePaperWalletPdfRequest.new instead')
  static CreatePaperWalletPdfRequest create() => CreatePaperWalletPdfRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreatePaperWalletPdfRequest._();
  @$core.override
  CreatePaperWalletPdfRequest createEmptyInstance() => CreatePaperWalletPdfRequest._();
  @$core.pragma('dart2js:noInline')
  static CreatePaperWalletPdfRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreatePaperWalletPdfRequest>(CreatePaperWalletPdfRequest.$_createMessage);
  static CreatePaperWalletPdfRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get publicAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set publicAddress($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPublicAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearPublicAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get privateKeyWif => $_getSZ(1);
  @$pb.TagNumber(2)
  set privateKeyWif($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPrivateKeyWif() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrivateKeyWif() => $_clearField(2);

  @$pb.TagNumber(3)
  QrMatrix get addressQr => $_getN(2);
  @$pb.TagNumber(3)
  set addressQr(QrMatrix value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasAddressQr() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddressQr() => $_clearField(3);
  @$pb.TagNumber(3)
  QrMatrix ensureAddressQr() => $_ensure(2);

  @$pb.TagNumber(4)
  QrMatrix get privateKeyQr => $_getN(3);
  @$pb.TagNumber(4)
  set privateKeyQr(QrMatrix value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPrivateKeyQr() => $_has(3);
  @$pb.TagNumber(4)
  void clearPrivateKeyQr() => $_clearField(4);
  @$pb.TagNumber(4)
  QrMatrix ensurePrivateKeyQr() => $_ensure(3);
}

class CreatePaperWalletPdfResponse extends $pb.GeneratedMessage {
  factory CreatePaperWalletPdfResponse({
    $core.List<$core.int>? pdf,
  }) {
    final result = CreatePaperWalletPdfResponse._();
    if (pdf != null) result.pdf = pdf;
    return result;
  }

  CreatePaperWalletPdfResponse._();

  factory CreatePaperWalletPdfResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePaperWalletPdfResponse()..mergeFromBuffer(data, registry);
  factory CreatePaperWalletPdfResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePaperWalletPdfResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePaperWalletPdfResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: CreatePaperWalletPdfResponse.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'pdf', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePaperWalletPdfResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePaperWalletPdfResponse copyWith(void Function(CreatePaperWalletPdfResponse) updates) =>
      super.copyWith((message) => updates(message as CreatePaperWalletPdfResponse)) as CreatePaperWalletPdfResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreatePaperWalletPdfResponse() / CreatePaperWalletPdfResponse.new instead')
  static CreatePaperWalletPdfResponse create() => CreatePaperWalletPdfResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreatePaperWalletPdfResponse._();
  @$core.override
  CreatePaperWalletPdfResponse createEmptyInstance() => CreatePaperWalletPdfResponse._();
  @$core.pragma('dart2js:noInline')
  static CreatePaperWalletPdfResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreatePaperWalletPdfResponse>(CreatePaperWalletPdfResponse.$_createMessage);
  static CreatePaperWalletPdfResponse? _defaultInstance;

  /// A4 landscape PDF file.
  @$pb.TagNumber(1)
  $core.List<$core.int> get pdf => $_getN(0);
  @$pb.TagNumber(1)
  set pdf($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPdf() => $_has(0);
  @$pb.TagNumber(1)
  void clearPdf() => $_clearField(1);
}

class CreatePaperCheckPdfRequest extends $pb.GeneratedMessage {
  factory CreatePaperCheckPdfRequest({
    $core.String? publicAddress,
    $core.String? privateKeyWif,
    $core.String? amount,
    $core.String? txid,
    QrMatrix? addressQr,
    QrMatrix? privateKeyQr,
  }) {
    final result = CreatePaperCheckPdfRequest._();
    if (publicAddress != null) result.publicAddress = publicAddress;
    if (privateKeyWif != null) result.privateKeyWif = privateKeyWif;
    if (amount != null) result.amount = amount;
    if (txid != null) result.txid = txid;
    if (addressQr != null) result.addressQr = addressQr;
    if (privateKeyQr != null) result.privateKeyQr = privateKeyQr;
    return result;
  }

  CreatePaperCheckPdfRequest._();

  factory CreatePaperCheckPdfRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePaperCheckPdfRequest()..mergeFromBuffer(data, registry);
  factory CreatePaperCheckPdfRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePaperCheckPdfRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePaperCheckPdfRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: CreatePaperCheckPdfRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'publicAddress')
    ..aOS(2, _omitFieldNames ? '' : 'privateKeyWif')
    ..aOS(3, _omitFieldNames ? '' : 'amount')
    ..aOS(4, _omitFieldNames ? '' : 'txid')
    ..aOM<QrMatrix>(5, _omitFieldNames ? '' : 'addressQr', subBuilder: QrMatrix.$_createMessage)
    ..aOM<QrMatrix>(6, _omitFieldNames ? '' : 'privateKeyQr', subBuilder: QrMatrix.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePaperCheckPdfRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePaperCheckPdfRequest copyWith(void Function(CreatePaperCheckPdfRequest) updates) =>
      super.copyWith((message) => updates(message as CreatePaperCheckPdfRequest)) as CreatePaperCheckPdfRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreatePaperCheckPdfRequest() / CreatePaperCheckPdfRequest.new instead')
  static CreatePaperCheckPdfRequest create() => CreatePaperCheckPdfRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreatePaperCheckPdfRequest._();
  @$core.override
  CreatePaperCheckPdfRequest createEmptyInstance() => CreatePaperCheckPdfRequest._();
  @$core.pragma('dart2js:noInline')
  static CreatePaperCheckPdfRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreatePaperCheckPdfRequest>(CreatePaperCheckPdfRequest.$_createMessage);
  static CreatePaperCheckPdfRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get publicAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set publicAddress($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPublicAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearPublicAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get privateKeyWif => $_getSZ(1);
  @$pb.TagNumber(2)
  set privateKeyWif($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPrivateKeyWif() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrivateKeyWif() => $_clearField(2);

  /// Amount with its unit, for example "0.001 BTC".
  @$pb.TagNumber(3)
  $core.String get amount => $_getSZ(2);
  @$pb.TagNumber(3)
  set amount($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get txid => $_getSZ(3);
  @$pb.TagNumber(4)
  set txid($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTxid() => $_has(3);
  @$pb.TagNumber(4)
  void clearTxid() => $_clearField(4);

  @$pb.TagNumber(5)
  QrMatrix get addressQr => $_getN(4);
  @$pb.TagNumber(5)
  set addressQr(QrMatrix value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasAddressQr() => $_has(4);
  @$pb.TagNumber(5)
  void clearAddressQr() => $_clearField(5);
  @$pb.TagNumber(5)
  QrMatrix ensureAddressQr() => $_ensure(4);

  @$pb.TagNumber(6)
  QrMatrix get privateKeyQr => $_getN(5);
  @$pb.TagNumber(6)
  set privateKeyQr(QrMatrix value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasPrivateKeyQr() => $_has(5);
  @$pb.TagNumber(6)
  void clearPrivateKeyQr() => $_clearField(6);
  @$pb.TagNumber(6)
  QrMatrix ensurePrivateKeyQr() => $_ensure(5);
}

class CreatePaperCheckPdfResponse extends $pb.GeneratedMessage {
  factory CreatePaperCheckPdfResponse({
    $core.List<$core.int>? pdf,
  }) {
    final result = CreatePaperCheckPdfResponse._();
    if (pdf != null) result.pdf = pdf;
    return result;
  }

  CreatePaperCheckPdfResponse._();

  factory CreatePaperCheckPdfResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePaperCheckPdfResponse()..mergeFromBuffer(data, registry);
  factory CreatePaperCheckPdfResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePaperCheckPdfResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePaperCheckPdfResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: CreatePaperCheckPdfResponse.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'pdf', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePaperCheckPdfResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePaperCheckPdfResponse copyWith(void Function(CreatePaperCheckPdfResponse) updates) =>
      super.copyWith((message) => updates(message as CreatePaperCheckPdfResponse)) as CreatePaperCheckPdfResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreatePaperCheckPdfResponse() / CreatePaperCheckPdfResponse.new instead')
  static CreatePaperCheckPdfResponse create() => CreatePaperCheckPdfResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreatePaperCheckPdfResponse._();
  @$core.override
  CreatePaperCheckPdfResponse createEmptyInstance() => CreatePaperCheckPdfResponse._();
  @$core.pragma('dart2js:noInline')
  static CreatePaperCheckPdfResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreatePaperCheckPdfResponse>(CreatePaperCheckPdfResponse.$_createMessage);
  static CreatePaperCheckPdfResponse? _defaultInstance;

  /// A4 landscape PDF file.
  @$pb.TagNumber(1)
  $core.List<$core.int> get pdf => $_getN(0);
  @$pb.TagNumber(1)
  set pdf($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPdf() => $_has(0);
  @$pb.TagNumber(1)
  void clearPdf() => $_clearField(1);
}

class ValidateWIFRequest extends $pb.GeneratedMessage {
  factory ValidateWIFRequest({
    $core.String? wif,
  }) {
    final result = ValidateWIFRequest._();
    if (wif != null) result.wif = wif;
    return result;
  }

  ValidateWIFRequest._();

  factory ValidateWIFRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateWIFRequest()..mergeFromBuffer(data, registry);
  factory ValidateWIFRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateWIFRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateWIFRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: ValidateWIFRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'wif')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateWIFRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateWIFRequest copyWith(void Function(ValidateWIFRequest) updates) =>
      super.copyWith((message) => updates(message as ValidateWIFRequest)) as ValidateWIFRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidateWIFRequest() / ValidateWIFRequest.new instead')
  static ValidateWIFRequest create() => ValidateWIFRequest._();
  static $pb.GeneratedMessage $_createMessage() => ValidateWIFRequest._();
  @$core.override
  ValidateWIFRequest createEmptyInstance() => ValidateWIFRequest._();
  @$core.pragma('dart2js:noInline')
  static ValidateWIFRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidateWIFRequest>(ValidateWIFRequest.$_createMessage);
  static ValidateWIFRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wif => $_getSZ(0);
  @$pb.TagNumber(1)
  set wif($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWif() => $_has(0);
  @$pb.TagNumber(1)
  void clearWif() => $_clearField(1);
}

class ValidateWIFResponse extends $pb.GeneratedMessage {
  factory ValidateWIFResponse({
    $core.bool? valid,
  }) {
    final result = ValidateWIFResponse._();
    if (valid != null) result.valid = valid;
    return result;
  }

  ValidateWIFResponse._();

  factory ValidateWIFResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateWIFResponse()..mergeFromBuffer(data, registry);
  factory ValidateWIFResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateWIFResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateWIFResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: ValidateWIFResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateWIFResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateWIFResponse copyWith(void Function(ValidateWIFResponse) updates) =>
      super.copyWith((message) => updates(message as ValidateWIFResponse)) as ValidateWIFResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidateWIFResponse() / ValidateWIFResponse.new instead')
  static ValidateWIFResponse create() => ValidateWIFResponse._();
  static $pb.GeneratedMessage $_createMessage() => ValidateWIFResponse._();
  @$core.override
  ValidateWIFResponse createEmptyInstance() => ValidateWIFResponse._();
  @$core.pragma('dart2js:noInline')
  static ValidateWIFResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidateWIFResponse>(ValidateWIFResponse.$_createMessage);
  static ValidateWIFResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => $_clearField(1);
}

class WIFToAddressRequest extends $pb.GeneratedMessage {
  factory WIFToAddressRequest({
    $core.String? wif,
  }) {
    final result = WIFToAddressRequest._();
    if (wif != null) result.wif = wif;
    return result;
  }

  WIFToAddressRequest._();

  factory WIFToAddressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WIFToAddressRequest()..mergeFromBuffer(data, registry);
  factory WIFToAddressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WIFToAddressRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WIFToAddressRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: WIFToAddressRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'wif')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WIFToAddressRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WIFToAddressRequest copyWith(void Function(WIFToAddressRequest) updates) =>
      super.copyWith((message) => updates(message as WIFToAddressRequest)) as WIFToAddressRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WIFToAddressRequest() / WIFToAddressRequest.new instead')
  static WIFToAddressRequest create() => WIFToAddressRequest._();
  static $pb.GeneratedMessage $_createMessage() => WIFToAddressRequest._();
  @$core.override
  WIFToAddressRequest createEmptyInstance() => WIFToAddressRequest._();
  @$core.pragma('dart2js:noInline')
  static WIFToAddressRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WIFToAddressRequest>(WIFToAddressRequest.$_createMessage);
  static WIFToAddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wif => $_getSZ(0);
  @$pb.TagNumber(1)
  set wif($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWif() => $_has(0);
  @$pb.TagNumber(1)
  void clearWif() => $_clearField(1);
}

class WIFToAddressResponse extends $pb.GeneratedMessage {
  factory WIFToAddressResponse({
    $core.String? address,
    $core.String? error,
  }) {
    final result = WIFToAddressResponse._();
    if (address != null) result.address = address;
    if (error != null) result.error = error;
    return result;
  }

  WIFToAddressResponse._();

  factory WIFToAddressResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WIFToAddressResponse()..mergeFromBuffer(data, registry);
  factory WIFToAddressResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WIFToAddressResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WIFToAddressResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: WIFToAddressResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WIFToAddressResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WIFToAddressResponse copyWith(void Function(WIFToAddressResponse) updates) =>
      super.copyWith((message) => updates(message as WIFToAddressResponse)) as WIFToAddressResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WIFToAddressResponse() / WIFToAddressResponse.new instead')
  static WIFToAddressResponse create() => WIFToAddressResponse._();
  static $pb.GeneratedMessage $_createMessage() => WIFToAddressResponse._();
  @$core.override
  WIFToAddressResponse createEmptyInstance() => WIFToAddressResponse._();
  @$core.pragma('dart2js:noInline')
  static WIFToAddressResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WIFToAddressResponse>(WIFToAddressResponse.$_createMessage);
  static WIFToAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
}

class ConvertRequest extends $pb.GeneratedMessage {
  factory ConvertRequest({
    $core.String? input,
    ConvertFormat? format,
  }) {
    final result = ConvertRequest._();
    if (input != null) result.input = input;
    if (format != null) result.format = format;
    return result;
  }

  ConvertRequest._();

  factory ConvertRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConvertRequest()..mergeFromBuffer(data, registry);
  factory ConvertRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConvertRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConvertRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: ConvertRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'input')
    ..aE<ConvertFormat>(2, _omitFieldNames ? '' : 'format', enumValues: ConvertFormat.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConvertRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConvertRequest copyWith(void Function(ConvertRequest) updates) =>
      super.copyWith((message) => updates(message as ConvertRequest)) as ConvertRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConvertRequest() / ConvertRequest.new instead')
  static ConvertRequest create() => ConvertRequest._();
  static $pb.GeneratedMessage $_createMessage() => ConvertRequest._();
  @$core.override
  ConvertRequest createEmptyInstance() => ConvertRequest._();
  @$core.pragma('dart2js:noInline')
  static ConvertRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConvertRequest>(ConvertRequest.$_createMessage);
  static ConvertRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get input => $_getSZ(0);
  @$pb.TagNumber(1)
  set input($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInput() => $_has(0);
  @$pb.TagNumber(1)
  void clearInput() => $_clearField(1);

  @$pb.TagNumber(2)
  ConvertFormat get format => $_getN(1);
  @$pb.TagNumber(2)
  set format(ConvertFormat value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFormat() => $_has(1);
  @$pb.TagNumber(2)
  void clearFormat() => $_clearField(2);
}

class ConvertRow extends $pb.GeneratedMessage {
  factory ConvertRow({
    $core.String? label,
    $core.String? value,
  }) {
    final result = ConvertRow._();
    if (label != null) result.label = label;
    if (value != null) result.value = value;
    return result;
  }

  ConvertRow._();

  factory ConvertRow.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConvertRow()..mergeFromBuffer(data, registry);
  factory ConvertRow.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConvertRow()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConvertRow',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: ConvertRow.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConvertRow clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConvertRow copyWith(void Function(ConvertRow) updates) =>
      super.copyWith((message) => updates(message as ConvertRow)) as ConvertRow;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConvertRow() / ConvertRow.new instead')
  static ConvertRow create() => ConvertRow._();
  static $pb.GeneratedMessage $_createMessage() => ConvertRow._();
  @$core.override
  ConvertRow createEmptyInstance() => ConvertRow._();
  @$core.pragma('dart2js:noInline')
  static ConvertRow getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConvertRow>(ConvertRow.$_createMessage);
  static ConvertRow? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

class ConvertResponse extends $pb.GeneratedMessage {
  factory ConvertResponse({
    ConvertFormat? detected,
    $core.String? error,
    $core.Iterable<ConvertRow>? encodings,
    $core.Iterable<ConvertRow>? hashes,
    $core.Iterable<ConvertRow>? keys,
  }) {
    final result = ConvertResponse._();
    if (detected != null) result.detected = detected;
    if (error != null) result.error = error;
    if (encodings != null) result.encodings.addAll(encodings);
    if (hashes != null) result.hashes.addAll(hashes);
    if (keys != null) result.keys.addAll(keys);
    return result;
  }

  ConvertResponse._();

  factory ConvertResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConvertResponse()..mergeFromBuffer(data, registry);
  factory ConvertResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConvertResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConvertResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'),
      createEmptyInstance: ConvertResponse.$_createMessage)
    ..aE<ConvertFormat>(1, _omitFieldNames ? '' : 'detected', enumValues: ConvertFormat.values)
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..pPM<ConvertRow>(3, _omitFieldNames ? '' : 'encodings', subBuilder: ConvertRow.$_createMessage)
    ..pPM<ConvertRow>(4, _omitFieldNames ? '' : 'hashes', subBuilder: ConvertRow.$_createMessage)
    ..pPM<ConvertRow>(5, _omitFieldNames ? '' : 'keys', subBuilder: ConvertRow.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConvertResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConvertResponse copyWith(void Function(ConvertResponse) updates) =>
      super.copyWith((message) => updates(message as ConvertResponse)) as ConvertResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConvertResponse() / ConvertResponse.new instead')
  static ConvertResponse create() => ConvertResponse._();
  static $pb.GeneratedMessage $_createMessage() => ConvertResponse._();
  @$core.override
  ConvertResponse createEmptyInstance() => ConvertResponse._();
  @$core.pragma('dart2js:noInline')
  static ConvertResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConvertResponse>(ConvertResponse.$_createMessage);
  static ConvertResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ConvertFormat get detected => $_getN(0);
  @$pb.TagNumber(1)
  set detected(ConvertFormat value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDetected() => $_has(0);
  @$pb.TagNumber(1)
  void clearDetected() => $_clearField(1);

  /// Why the input could not be read; empty on success.
  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<ConvertRow> get encodings => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<ConvertRow> get hashes => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<ConvertRow> get keys => $_getList(4);
}

class UtilsServiceApi {
  final $pb.RpcClient _client;

  UtilsServiceApi(this._client);

  /// Bitcoin URI parsing (BIP-0021)
  $async.Future<ParseBitcoinURIResponse> parseBitcoinURI($pb.ClientContext? ctx, ParseBitcoinURIRequest request) =>
      _client.invoke<ParseBitcoinURIResponse>(
          ctx, 'UtilsService', 'ParseBitcoinURI', request, ParseBitcoinURIResponse());
  $async.Future<ValidateBitcoinURIResponse> validateBitcoinURI(
          $pb.ClientContext? ctx, ValidateBitcoinURIRequest request) =>
      _client.invoke<ValidateBitcoinURIResponse>(
          ctx, 'UtilsService', 'ValidateBitcoinURI', request, ValidateBitcoinURIResponse());

  /// Base58Check encoding/decoding
  $async.Future<DecodeBase58CheckResponse> decodeBase58Check(
          $pb.ClientContext? ctx, DecodeBase58CheckRequest request) =>
      _client.invoke<DecodeBase58CheckResponse>(
          ctx, 'UtilsService', 'DecodeBase58Check', request, DecodeBase58CheckResponse());
  $async.Future<EncodeBase58CheckResponse> encodeBase58Check(
          $pb.ClientContext? ctx, EncodeBase58CheckRequest request) =>
      _client.invoke<EncodeBase58CheckResponse>(
          ctx, 'UtilsService', 'EncodeBase58Check', request, EncodeBase58CheckResponse());

  /// Merkle Tree calculation
  $async.Future<CalculateMerkleTreeResponse> calculateMerkleTree(
          $pb.ClientContext? ctx, CalculateMerkleTreeRequest request) =>
      _client.invoke<CalculateMerkleTreeResponse>(
          ctx, 'UtilsService', 'CalculateMerkleTree', request, CalculateMerkleTreeResponse());

  /// Paper Wallet generation
  $async.Future<GeneratePaperWalletResponse> generatePaperWallet($pb.ClientContext? ctx, $0.Empty request) =>
      _client.invoke<GeneratePaperWalletResponse>(
          ctx, 'UtilsService', 'GeneratePaperWallet', request, GeneratePaperWalletResponse());
  $async.Future<ValidateWIFResponse> validateWIF($pb.ClientContext? ctx, ValidateWIFRequest request) =>
      _client.invoke<ValidateWIFResponse>(ctx, 'UtilsService', 'ValidateWIF', request, ValidateWIFResponse());
  $async.Future<WIFToAddressResponse> wIFToAddress($pb.ClientContext? ctx, WIFToAddressRequest request) =>
      _client.invoke<WIFToAddressResponse>(ctx, 'UtilsService', 'WIFToAddress', request, WIFToAddressResponse());
  $async.Future<CreatePaperWalletPdfResponse> createPaperWalletPdf(
          $pb.ClientContext? ctx, CreatePaperWalletPdfRequest request) =>
      _client.invoke<CreatePaperWalletPdfResponse>(
          ctx, 'UtilsService', 'CreatePaperWalletPdf', request, CreatePaperWalletPdfResponse());
  $async.Future<CreatePaperCheckPdfResponse> createPaperCheckPdf(
          $pb.ClientContext? ctx, CreatePaperCheckPdfRequest request) =>
      _client.invoke<CreatePaperCheckPdfResponse>(
          ctx, 'UtilsService', 'CreatePaperCheckPdf', request, CreatePaperCheckPdfResponse());

  /// Convert shows the encodings, the hashes and, for a 32-byte secret, the keys of one input.
  $async.Future<ConvertResponse> convert($pb.ClientContext? ctx, ConvertRequest request) =>
      _client.invoke<ConvertResponse>(ctx, 'UtilsService', 'Convert', request, ConvertResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
