//
//  Generated code. Do not modify.
//  source: utils/v1/utils.proto
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
import 'utils.pbenum.dart';

export 'utils.pbenum.dart';

/// Bitcoin URI (BIP-0021)
class ParseBitcoinURIRequest extends $pb.GeneratedMessage {
  factory ParseBitcoinURIRequest({
    $core.String? uri,
  }) {
    final $result = create();
    if (uri != null) {
      $result.uri = uri;
    }
    return $result;
  }
  ParseBitcoinURIRequest._() : super();
  factory ParseBitcoinURIRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ParseBitcoinURIRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ParseBitcoinURIRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'uri')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ParseBitcoinURIRequest clone() => ParseBitcoinURIRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ParseBitcoinURIRequest copyWith(void Function(ParseBitcoinURIRequest) updates) => super.copyWith((message) => updates(message as ParseBitcoinURIRequest)) as ParseBitcoinURIRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParseBitcoinURIRequest create() => ParseBitcoinURIRequest._();
  ParseBitcoinURIRequest createEmptyInstance() => create();
  static $pb.PbList<ParseBitcoinURIRequest> createRepeated() => $pb.PbList<ParseBitcoinURIRequest>();
  @$core.pragma('dart2js:noInline')
  static ParseBitcoinURIRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ParseBitcoinURIRequest>(create);
  static ParseBitcoinURIRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get uri => $_getSZ(0);
  @$pb.TagNumber(1)
  set uri($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUri() => $_has(0);
  @$pb.TagNumber(1)
  void clearUri() => clearField(1);
}

class ParseBitcoinURIResponse extends $pb.GeneratedMessage {
  factory ParseBitcoinURIResponse({
    $core.String? address,
    $core.double? amount,
    $core.String? label,
    $core.String? message,
    $core.Map<$core.String, $core.String>? extraParams,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (label != null) {
      $result.label = label;
    }
    if (message != null) {
      $result.message = message;
    }
    if (extraParams != null) {
      $result.extraParams.addAll(extraParams);
    }
    return $result;
  }
  ParseBitcoinURIResponse._() : super();
  factory ParseBitcoinURIResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ParseBitcoinURIResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ParseBitcoinURIResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..aOS(4, _omitFieldNames ? '' : 'message')
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'extraParams', entryClassName: 'ParseBitcoinURIResponse.ExtraParamsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('utils.v1'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ParseBitcoinURIResponse clone() => ParseBitcoinURIResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ParseBitcoinURIResponse copyWith(void Function(ParseBitcoinURIResponse) updates) => super.copyWith((message) => updates(message as ParseBitcoinURIResponse)) as ParseBitcoinURIResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParseBitcoinURIResponse create() => ParseBitcoinURIResponse._();
  ParseBitcoinURIResponse createEmptyInstance() => create();
  static $pb.PbList<ParseBitcoinURIResponse> createRepeated() => $pb.PbList<ParseBitcoinURIResponse>();
  @$core.pragma('dart2js:noInline')
  static ParseBitcoinURIResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ParseBitcoinURIResponse>(create);
  static ParseBitcoinURIResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => clearField(4);

  @$pb.TagNumber(5)
  $core.Map<$core.String, $core.String> get extraParams => $_getMap(4);
}

class ValidateBitcoinURIRequest extends $pb.GeneratedMessage {
  factory ValidateBitcoinURIRequest({
    $core.String? uri,
  }) {
    final $result = create();
    if (uri != null) {
      $result.uri = uri;
    }
    return $result;
  }
  ValidateBitcoinURIRequest._() : super();
  factory ValidateBitcoinURIRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ValidateBitcoinURIRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateBitcoinURIRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'uri')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ValidateBitcoinURIRequest clone() => ValidateBitcoinURIRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ValidateBitcoinURIRequest copyWith(void Function(ValidateBitcoinURIRequest) updates) => super.copyWith((message) => updates(message as ValidateBitcoinURIRequest)) as ValidateBitcoinURIRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateBitcoinURIRequest create() => ValidateBitcoinURIRequest._();
  ValidateBitcoinURIRequest createEmptyInstance() => create();
  static $pb.PbList<ValidateBitcoinURIRequest> createRepeated() => $pb.PbList<ValidateBitcoinURIRequest>();
  @$core.pragma('dart2js:noInline')
  static ValidateBitcoinURIRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidateBitcoinURIRequest>(create);
  static ValidateBitcoinURIRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get uri => $_getSZ(0);
  @$pb.TagNumber(1)
  set uri($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUri() => $_has(0);
  @$pb.TagNumber(1)
  void clearUri() => clearField(1);
}

class ValidateBitcoinURIResponse extends $pb.GeneratedMessage {
  factory ValidateBitcoinURIResponse({
    $core.bool? valid,
    $core.String? error,
  }) {
    final $result = create();
    if (valid != null) {
      $result.valid = valid;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  ValidateBitcoinURIResponse._() : super();
  factory ValidateBitcoinURIResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ValidateBitcoinURIResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateBitcoinURIResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ValidateBitcoinURIResponse clone() => ValidateBitcoinURIResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ValidateBitcoinURIResponse copyWith(void Function(ValidateBitcoinURIResponse) updates) => super.copyWith((message) => updates(message as ValidateBitcoinURIResponse)) as ValidateBitcoinURIResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateBitcoinURIResponse create() => ValidateBitcoinURIResponse._();
  ValidateBitcoinURIResponse createEmptyInstance() => create();
  static $pb.PbList<ValidateBitcoinURIResponse> createRepeated() => $pb.PbList<ValidateBitcoinURIResponse>();
  @$core.pragma('dart2js:noInline')
  static ValidateBitcoinURIResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidateBitcoinURIResponse>(create);
  static ValidateBitcoinURIResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => clearField(2);
}

/// Base58Check
class DecodeBase58CheckRequest extends $pb.GeneratedMessage {
  factory DecodeBase58CheckRequest({
    $core.String? input,
  }) {
    final $result = create();
    if (input != null) {
      $result.input = input;
    }
    return $result;
  }
  DecodeBase58CheckRequest._() : super();
  factory DecodeBase58CheckRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodeBase58CheckRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodeBase58CheckRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'input')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodeBase58CheckRequest clone() => DecodeBase58CheckRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodeBase58CheckRequest copyWith(void Function(DecodeBase58CheckRequest) updates) => super.copyWith((message) => updates(message as DecodeBase58CheckRequest)) as DecodeBase58CheckRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodeBase58CheckRequest create() => DecodeBase58CheckRequest._();
  DecodeBase58CheckRequest createEmptyInstance() => create();
  static $pb.PbList<DecodeBase58CheckRequest> createRepeated() => $pb.PbList<DecodeBase58CheckRequest>();
  @$core.pragma('dart2js:noInline')
  static DecodeBase58CheckRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodeBase58CheckRequest>(create);
  static DecodeBase58CheckRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get input => $_getSZ(0);
  @$pb.TagNumber(1)
  set input($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasInput() => $_has(0);
  @$pb.TagNumber(1)
  void clearInput() => clearField(1);
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
    final $result = create();
    if (valid != null) {
      $result.valid = valid;
    }
    if (versionByte != null) {
      $result.versionByte = versionByte;
    }
    if (payload != null) {
      $result.payload = payload;
    }
    if (checksum != null) {
      $result.checksum = checksum;
    }
    if (checksumValid != null) {
      $result.checksumValid = checksumValid;
    }
    if (addressType != null) {
      $result.addressType = addressType;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  DecodeBase58CheckResponse._() : super();
  factory DecodeBase58CheckResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodeBase58CheckResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodeBase58CheckResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'versionByte', $pb.PbFieldType.O3)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'checksum', $pb.PbFieldType.OY)
    ..aOB(5, _omitFieldNames ? '' : 'checksumValid')
    ..aOS(6, _omitFieldNames ? '' : 'addressType')
    ..aOS(7, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodeBase58CheckResponse clone() => DecodeBase58CheckResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodeBase58CheckResponse copyWith(void Function(DecodeBase58CheckResponse) updates) => super.copyWith((message) => updates(message as DecodeBase58CheckResponse)) as DecodeBase58CheckResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodeBase58CheckResponse create() => DecodeBase58CheckResponse._();
  DecodeBase58CheckResponse createEmptyInstance() => create();
  static $pb.PbList<DecodeBase58CheckResponse> createRepeated() => $pb.PbList<DecodeBase58CheckResponse>();
  @$core.pragma('dart2js:noInline')
  static DecodeBase58CheckResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodeBase58CheckResponse>(create);
  static DecodeBase58CheckResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get versionByte => $_getIZ(1);
  @$pb.TagNumber(2)
  set versionByte($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVersionByte() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersionByte() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get payload => $_getN(2);
  @$pb.TagNumber(3)
  set payload($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPayload() => $_has(2);
  @$pb.TagNumber(3)
  void clearPayload() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get checksum => $_getN(3);
  @$pb.TagNumber(4)
  set checksum($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasChecksum() => $_has(3);
  @$pb.TagNumber(4)
  void clearChecksum() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get checksumValid => $_getBF(4);
  @$pb.TagNumber(5)
  set checksumValid($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasChecksumValid() => $_has(4);
  @$pb.TagNumber(5)
  void clearChecksumValid() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get addressType => $_getSZ(5);
  @$pb.TagNumber(6)
  set addressType($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAddressType() => $_has(5);
  @$pb.TagNumber(6)
  void clearAddressType() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get error => $_getSZ(6);
  @$pb.TagNumber(7)
  set error($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasError() => $_has(6);
  @$pb.TagNumber(7)
  void clearError() => clearField(7);
}

class EncodeBase58CheckRequest extends $pb.GeneratedMessage {
  factory EncodeBase58CheckRequest({
    $core.int? versionByte,
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (versionByte != null) {
      $result.versionByte = versionByte;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  EncodeBase58CheckRequest._() : super();
  factory EncodeBase58CheckRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EncodeBase58CheckRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncodeBase58CheckRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'versionByte', $pb.PbFieldType.O3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EncodeBase58CheckRequest clone() => EncodeBase58CheckRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EncodeBase58CheckRequest copyWith(void Function(EncodeBase58CheckRequest) updates) => super.copyWith((message) => updates(message as EncodeBase58CheckRequest)) as EncodeBase58CheckRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncodeBase58CheckRequest create() => EncodeBase58CheckRequest._();
  EncodeBase58CheckRequest createEmptyInstance() => create();
  static $pb.PbList<EncodeBase58CheckRequest> createRepeated() => $pb.PbList<EncodeBase58CheckRequest>();
  @$core.pragma('dart2js:noInline')
  static EncodeBase58CheckRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EncodeBase58CheckRequest>(create);
  static EncodeBase58CheckRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get versionByte => $_getIZ(0);
  @$pb.TagNumber(1)
  set versionByte($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVersionByte() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersionByte() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

class EncodeBase58CheckResponse extends $pb.GeneratedMessage {
  factory EncodeBase58CheckResponse({
    $core.String? encoded,
    $core.String? error,
  }) {
    final $result = create();
    if (encoded != null) {
      $result.encoded = encoded;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  EncodeBase58CheckResponse._() : super();
  factory EncodeBase58CheckResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EncodeBase58CheckResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncodeBase58CheckResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'encoded')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EncodeBase58CheckResponse clone() => EncodeBase58CheckResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EncodeBase58CheckResponse copyWith(void Function(EncodeBase58CheckResponse) updates) => super.copyWith((message) => updates(message as EncodeBase58CheckResponse)) as EncodeBase58CheckResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncodeBase58CheckResponse create() => EncodeBase58CheckResponse._();
  EncodeBase58CheckResponse createEmptyInstance() => create();
  static $pb.PbList<EncodeBase58CheckResponse> createRepeated() => $pb.PbList<EncodeBase58CheckResponse>();
  @$core.pragma('dart2js:noInline')
  static EncodeBase58CheckResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EncodeBase58CheckResponse>(create);
  static EncodeBase58CheckResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get encoded => $_getSZ(0);
  @$pb.TagNumber(1)
  set encoded($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEncoded() => $_has(0);
  @$pb.TagNumber(1)
  void clearEncoded() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => clearField(2);
}

/// Merkle Tree
class CalculateMerkleTreeRequest extends $pb.GeneratedMessage {
  factory CalculateMerkleTreeRequest({
    $core.Iterable<$core.String>? txids,
    $core.bool? showRcb,
  }) {
    final $result = create();
    if (txids != null) {
      $result.txids.addAll(txids);
    }
    if (showRcb != null) {
      $result.showRcb = showRcb;
    }
    return $result;
  }
  CalculateMerkleTreeRequest._() : super();
  factory CalculateMerkleTreeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CalculateMerkleTreeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CalculateMerkleTreeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'txids')
    ..aOB(2, _omitFieldNames ? '' : 'showRcb')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CalculateMerkleTreeRequest clone() => CalculateMerkleTreeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CalculateMerkleTreeRequest copyWith(void Function(CalculateMerkleTreeRequest) updates) => super.copyWith((message) => updates(message as CalculateMerkleTreeRequest)) as CalculateMerkleTreeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalculateMerkleTreeRequest create() => CalculateMerkleTreeRequest._();
  CalculateMerkleTreeRequest createEmptyInstance() => create();
  static $pb.PbList<CalculateMerkleTreeRequest> createRepeated() => $pb.PbList<CalculateMerkleTreeRequest>();
  @$core.pragma('dart2js:noInline')
  static CalculateMerkleTreeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CalculateMerkleTreeRequest>(create);
  static CalculateMerkleTreeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get txids => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get showRcb => $_getBF(1);
  @$pb.TagNumber(2)
  set showRcb($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasShowRcb() => $_has(1);
  @$pb.TagNumber(2)
  void clearShowRcb() => clearField(2);
}

class CalculateMerkleTreeResponse extends $pb.GeneratedMessage {
  factory CalculateMerkleTreeResponse({
    $core.String? merkleRoot,
    $core.Iterable<MerkleTreeLevel>? levels,
    $core.String? formattedText,
  }) {
    final $result = create();
    if (merkleRoot != null) {
      $result.merkleRoot = merkleRoot;
    }
    if (levels != null) {
      $result.levels.addAll(levels);
    }
    if (formattedText != null) {
      $result.formattedText = formattedText;
    }
    return $result;
  }
  CalculateMerkleTreeResponse._() : super();
  factory CalculateMerkleTreeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CalculateMerkleTreeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CalculateMerkleTreeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'merkleRoot')
    ..pc<MerkleTreeLevel>(2, _omitFieldNames ? '' : 'levels', $pb.PbFieldType.PM, subBuilder: MerkleTreeLevel.create)
    ..aOS(3, _omitFieldNames ? '' : 'formattedText')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CalculateMerkleTreeResponse clone() => CalculateMerkleTreeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CalculateMerkleTreeResponse copyWith(void Function(CalculateMerkleTreeResponse) updates) => super.copyWith((message) => updates(message as CalculateMerkleTreeResponse)) as CalculateMerkleTreeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalculateMerkleTreeResponse create() => CalculateMerkleTreeResponse._();
  CalculateMerkleTreeResponse createEmptyInstance() => create();
  static $pb.PbList<CalculateMerkleTreeResponse> createRepeated() => $pb.PbList<CalculateMerkleTreeResponse>();
  @$core.pragma('dart2js:noInline')
  static CalculateMerkleTreeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CalculateMerkleTreeResponse>(create);
  static CalculateMerkleTreeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get merkleRoot => $_getSZ(0);
  @$pb.TagNumber(1)
  set merkleRoot($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMerkleRoot() => $_has(0);
  @$pb.TagNumber(1)
  void clearMerkleRoot() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<MerkleTreeLevel> get levels => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get formattedText => $_getSZ(2);
  @$pb.TagNumber(3)
  set formattedText($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFormattedText() => $_has(2);
  @$pb.TagNumber(3)
  void clearFormattedText() => clearField(3);
}

class MerkleTreeLevel extends $pb.GeneratedMessage {
  factory MerkleTreeLevel({
    $core.int? level,
    $core.Iterable<$core.String>? hashes,
    $core.Iterable<$core.String>? rcb,
  }) {
    final $result = create();
    if (level != null) {
      $result.level = level;
    }
    if (hashes != null) {
      $result.hashes.addAll(hashes);
    }
    if (rcb != null) {
      $result.rcb.addAll(rcb);
    }
    return $result;
  }
  MerkleTreeLevel._() : super();
  factory MerkleTreeLevel.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MerkleTreeLevel.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MerkleTreeLevel', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'level', $pb.PbFieldType.O3)
    ..pPS(2, _omitFieldNames ? '' : 'hashes')
    ..pPS(3, _omitFieldNames ? '' : 'rcb')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MerkleTreeLevel clone() => MerkleTreeLevel()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MerkleTreeLevel copyWith(void Function(MerkleTreeLevel) updates) => super.copyWith((message) => updates(message as MerkleTreeLevel)) as MerkleTreeLevel;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MerkleTreeLevel create() => MerkleTreeLevel._();
  MerkleTreeLevel createEmptyInstance() => create();
  static $pb.PbList<MerkleTreeLevel> createRepeated() => $pb.PbList<MerkleTreeLevel>();
  @$core.pragma('dart2js:noInline')
  static MerkleTreeLevel getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MerkleTreeLevel>(create);
  static MerkleTreeLevel? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get level => $_getIZ(0);
  @$pb.TagNumber(1)
  set level($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLevel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLevel() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get hashes => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<$core.String> get rcb => $_getList(2);
}

/// Paper Wallet
class GeneratePaperWalletResponse extends $pb.GeneratedMessage {
  factory GeneratePaperWalletResponse({
    $core.String? privateKeyWif,
    $core.String? publicAddress,
    $core.String? privateKeyHex,
  }) {
    final $result = create();
    if (privateKeyWif != null) {
      $result.privateKeyWif = privateKeyWif;
    }
    if (publicAddress != null) {
      $result.publicAddress = publicAddress;
    }
    if (privateKeyHex != null) {
      $result.privateKeyHex = privateKeyHex;
    }
    return $result;
  }
  GeneratePaperWalletResponse._() : super();
  factory GeneratePaperWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GeneratePaperWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GeneratePaperWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'privateKeyWif')
    ..aOS(2, _omitFieldNames ? '' : 'publicAddress')
    ..aOS(3, _omitFieldNames ? '' : 'privateKeyHex')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GeneratePaperWalletResponse clone() => GeneratePaperWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GeneratePaperWalletResponse copyWith(void Function(GeneratePaperWalletResponse) updates) => super.copyWith((message) => updates(message as GeneratePaperWalletResponse)) as GeneratePaperWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GeneratePaperWalletResponse create() => GeneratePaperWalletResponse._();
  GeneratePaperWalletResponse createEmptyInstance() => create();
  static $pb.PbList<GeneratePaperWalletResponse> createRepeated() => $pb.PbList<GeneratePaperWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static GeneratePaperWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GeneratePaperWalletResponse>(create);
  static GeneratePaperWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get privateKeyWif => $_getSZ(0);
  @$pb.TagNumber(1)
  set privateKeyWif($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPrivateKeyWif() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrivateKeyWif() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get publicAddress => $_getSZ(1);
  @$pb.TagNumber(2)
  set publicAddress($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPublicAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearPublicAddress() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get privateKeyHex => $_getSZ(2);
  @$pb.TagNumber(3)
  set privateKeyHex($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPrivateKeyHex() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrivateKeyHex() => clearField(3);
}

/// QrMatrix is the module grid of one QR code.
class QrMatrix extends $pb.GeneratedMessage {
  factory QrMatrix({
    $core.int? size,
    $core.List<$core.int>? modules,
  }) {
    final $result = create();
    if (size != null) {
      $result.size = size;
    }
    if (modules != null) {
      $result.modules = modules;
    }
    return $result;
  }
  QrMatrix._() : super();
  factory QrMatrix.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QrMatrix.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'QrMatrix', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'size', $pb.PbFieldType.O3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'modules', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QrMatrix clone() => QrMatrix()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QrMatrix copyWith(void Function(QrMatrix) updates) => super.copyWith((message) => updates(message as QrMatrix)) as QrMatrix;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QrMatrix create() => QrMatrix._();
  QrMatrix createEmptyInstance() => create();
  static $pb.PbList<QrMatrix> createRepeated() => $pb.PbList<QrMatrix>();
  @$core.pragma('dart2js:noInline')
  static QrMatrix getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QrMatrix>(create);
  static QrMatrix? _defaultInstance;

  /// Count of modules per side.
  @$pb.TagNumber(1)
  $core.int get size => $_getIZ(0);
  @$pb.TagNumber(1)
  set size($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearSize() => clearField(1);

  /// One byte per module, row-major from the top-left module. 1 is dark, 0 is light.
  @$pb.TagNumber(2)
  $core.List<$core.int> get modules => $_getN(1);
  @$pb.TagNumber(2)
  set modules($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasModules() => $_has(1);
  @$pb.TagNumber(2)
  void clearModules() => clearField(2);
}

class CreatePaperWalletPdfRequest extends $pb.GeneratedMessage {
  factory CreatePaperWalletPdfRequest({
    $core.String? publicAddress,
    $core.String? privateKeyWif,
    QrMatrix? addressQr,
    QrMatrix? privateKeyQr,
  }) {
    final $result = create();
    if (publicAddress != null) {
      $result.publicAddress = publicAddress;
    }
    if (privateKeyWif != null) {
      $result.privateKeyWif = privateKeyWif;
    }
    if (addressQr != null) {
      $result.addressQr = addressQr;
    }
    if (privateKeyQr != null) {
      $result.privateKeyQr = privateKeyQr;
    }
    return $result;
  }
  CreatePaperWalletPdfRequest._() : super();
  factory CreatePaperWalletPdfRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreatePaperWalletPdfRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePaperWalletPdfRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'publicAddress')
    ..aOS(2, _omitFieldNames ? '' : 'privateKeyWif')
    ..aOM<QrMatrix>(3, _omitFieldNames ? '' : 'addressQr', subBuilder: QrMatrix.create)
    ..aOM<QrMatrix>(4, _omitFieldNames ? '' : 'privateKeyQr', subBuilder: QrMatrix.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreatePaperWalletPdfRequest clone() => CreatePaperWalletPdfRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreatePaperWalletPdfRequest copyWith(void Function(CreatePaperWalletPdfRequest) updates) => super.copyWith((message) => updates(message as CreatePaperWalletPdfRequest)) as CreatePaperWalletPdfRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePaperWalletPdfRequest create() => CreatePaperWalletPdfRequest._();
  CreatePaperWalletPdfRequest createEmptyInstance() => create();
  static $pb.PbList<CreatePaperWalletPdfRequest> createRepeated() => $pb.PbList<CreatePaperWalletPdfRequest>();
  @$core.pragma('dart2js:noInline')
  static CreatePaperWalletPdfRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePaperWalletPdfRequest>(create);
  static CreatePaperWalletPdfRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get publicAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set publicAddress($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPublicAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearPublicAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get privateKeyWif => $_getSZ(1);
  @$pb.TagNumber(2)
  set privateKeyWif($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPrivateKeyWif() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrivateKeyWif() => clearField(2);

  @$pb.TagNumber(3)
  QrMatrix get addressQr => $_getN(2);
  @$pb.TagNumber(3)
  set addressQr(QrMatrix v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasAddressQr() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddressQr() => clearField(3);
  @$pb.TagNumber(3)
  QrMatrix ensureAddressQr() => $_ensure(2);

  @$pb.TagNumber(4)
  QrMatrix get privateKeyQr => $_getN(3);
  @$pb.TagNumber(4)
  set privateKeyQr(QrMatrix v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasPrivateKeyQr() => $_has(3);
  @$pb.TagNumber(4)
  void clearPrivateKeyQr() => clearField(4);
  @$pb.TagNumber(4)
  QrMatrix ensurePrivateKeyQr() => $_ensure(3);
}

class CreatePaperWalletPdfResponse extends $pb.GeneratedMessage {
  factory CreatePaperWalletPdfResponse({
    $core.List<$core.int>? pdf,
  }) {
    final $result = create();
    if (pdf != null) {
      $result.pdf = pdf;
    }
    return $result;
  }
  CreatePaperWalletPdfResponse._() : super();
  factory CreatePaperWalletPdfResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreatePaperWalletPdfResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePaperWalletPdfResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'pdf', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreatePaperWalletPdfResponse clone() => CreatePaperWalletPdfResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreatePaperWalletPdfResponse copyWith(void Function(CreatePaperWalletPdfResponse) updates) => super.copyWith((message) => updates(message as CreatePaperWalletPdfResponse)) as CreatePaperWalletPdfResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePaperWalletPdfResponse create() => CreatePaperWalletPdfResponse._();
  CreatePaperWalletPdfResponse createEmptyInstance() => create();
  static $pb.PbList<CreatePaperWalletPdfResponse> createRepeated() => $pb.PbList<CreatePaperWalletPdfResponse>();
  @$core.pragma('dart2js:noInline')
  static CreatePaperWalletPdfResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePaperWalletPdfResponse>(create);
  static CreatePaperWalletPdfResponse? _defaultInstance;

  /// A4 landscape PDF file.
  @$pb.TagNumber(1)
  $core.List<$core.int> get pdf => $_getN(0);
  @$pb.TagNumber(1)
  set pdf($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPdf() => $_has(0);
  @$pb.TagNumber(1)
  void clearPdf() => clearField(1);
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
    final $result = create();
    if (publicAddress != null) {
      $result.publicAddress = publicAddress;
    }
    if (privateKeyWif != null) {
      $result.privateKeyWif = privateKeyWif;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (addressQr != null) {
      $result.addressQr = addressQr;
    }
    if (privateKeyQr != null) {
      $result.privateKeyQr = privateKeyQr;
    }
    return $result;
  }
  CreatePaperCheckPdfRequest._() : super();
  factory CreatePaperCheckPdfRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreatePaperCheckPdfRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePaperCheckPdfRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'publicAddress')
    ..aOS(2, _omitFieldNames ? '' : 'privateKeyWif')
    ..aOS(3, _omitFieldNames ? '' : 'amount')
    ..aOS(4, _omitFieldNames ? '' : 'txid')
    ..aOM<QrMatrix>(5, _omitFieldNames ? '' : 'addressQr', subBuilder: QrMatrix.create)
    ..aOM<QrMatrix>(6, _omitFieldNames ? '' : 'privateKeyQr', subBuilder: QrMatrix.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreatePaperCheckPdfRequest clone() => CreatePaperCheckPdfRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreatePaperCheckPdfRequest copyWith(void Function(CreatePaperCheckPdfRequest) updates) => super.copyWith((message) => updates(message as CreatePaperCheckPdfRequest)) as CreatePaperCheckPdfRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePaperCheckPdfRequest create() => CreatePaperCheckPdfRequest._();
  CreatePaperCheckPdfRequest createEmptyInstance() => create();
  static $pb.PbList<CreatePaperCheckPdfRequest> createRepeated() => $pb.PbList<CreatePaperCheckPdfRequest>();
  @$core.pragma('dart2js:noInline')
  static CreatePaperCheckPdfRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePaperCheckPdfRequest>(create);
  static CreatePaperCheckPdfRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get publicAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set publicAddress($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPublicAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearPublicAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get privateKeyWif => $_getSZ(1);
  @$pb.TagNumber(2)
  set privateKeyWif($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPrivateKeyWif() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrivateKeyWif() => clearField(2);

  /// Amount with its unit, for example "0.001 BTC".
  @$pb.TagNumber(3)
  $core.String get amount => $_getSZ(2);
  @$pb.TagNumber(3)
  set amount($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get txid => $_getSZ(3);
  @$pb.TagNumber(4)
  set txid($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTxid() => $_has(3);
  @$pb.TagNumber(4)
  void clearTxid() => clearField(4);

  @$pb.TagNumber(5)
  QrMatrix get addressQr => $_getN(4);
  @$pb.TagNumber(5)
  set addressQr(QrMatrix v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasAddressQr() => $_has(4);
  @$pb.TagNumber(5)
  void clearAddressQr() => clearField(5);
  @$pb.TagNumber(5)
  QrMatrix ensureAddressQr() => $_ensure(4);

  @$pb.TagNumber(6)
  QrMatrix get privateKeyQr => $_getN(5);
  @$pb.TagNumber(6)
  set privateKeyQr(QrMatrix v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasPrivateKeyQr() => $_has(5);
  @$pb.TagNumber(6)
  void clearPrivateKeyQr() => clearField(6);
  @$pb.TagNumber(6)
  QrMatrix ensurePrivateKeyQr() => $_ensure(5);
}

class CreatePaperCheckPdfResponse extends $pb.GeneratedMessage {
  factory CreatePaperCheckPdfResponse({
    $core.List<$core.int>? pdf,
  }) {
    final $result = create();
    if (pdf != null) {
      $result.pdf = pdf;
    }
    return $result;
  }
  CreatePaperCheckPdfResponse._() : super();
  factory CreatePaperCheckPdfResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreatePaperCheckPdfResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePaperCheckPdfResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'pdf', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreatePaperCheckPdfResponse clone() => CreatePaperCheckPdfResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreatePaperCheckPdfResponse copyWith(void Function(CreatePaperCheckPdfResponse) updates) => super.copyWith((message) => updates(message as CreatePaperCheckPdfResponse)) as CreatePaperCheckPdfResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePaperCheckPdfResponse create() => CreatePaperCheckPdfResponse._();
  CreatePaperCheckPdfResponse createEmptyInstance() => create();
  static $pb.PbList<CreatePaperCheckPdfResponse> createRepeated() => $pb.PbList<CreatePaperCheckPdfResponse>();
  @$core.pragma('dart2js:noInline')
  static CreatePaperCheckPdfResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePaperCheckPdfResponse>(create);
  static CreatePaperCheckPdfResponse? _defaultInstance;

  /// A4 landscape PDF file.
  @$pb.TagNumber(1)
  $core.List<$core.int> get pdf => $_getN(0);
  @$pb.TagNumber(1)
  set pdf($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPdf() => $_has(0);
  @$pb.TagNumber(1)
  void clearPdf() => clearField(1);
}

class ValidateWIFRequest extends $pb.GeneratedMessage {
  factory ValidateWIFRequest({
    $core.String? wif,
  }) {
    final $result = create();
    if (wif != null) {
      $result.wif = wif;
    }
    return $result;
  }
  ValidateWIFRequest._() : super();
  factory ValidateWIFRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ValidateWIFRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateWIFRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'wif')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ValidateWIFRequest clone() => ValidateWIFRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ValidateWIFRequest copyWith(void Function(ValidateWIFRequest) updates) => super.copyWith((message) => updates(message as ValidateWIFRequest)) as ValidateWIFRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateWIFRequest create() => ValidateWIFRequest._();
  ValidateWIFRequest createEmptyInstance() => create();
  static $pb.PbList<ValidateWIFRequest> createRepeated() => $pb.PbList<ValidateWIFRequest>();
  @$core.pragma('dart2js:noInline')
  static ValidateWIFRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidateWIFRequest>(create);
  static ValidateWIFRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wif => $_getSZ(0);
  @$pb.TagNumber(1)
  set wif($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWif() => $_has(0);
  @$pb.TagNumber(1)
  void clearWif() => clearField(1);
}

class ValidateWIFResponse extends $pb.GeneratedMessage {
  factory ValidateWIFResponse({
    $core.bool? valid,
  }) {
    final $result = create();
    if (valid != null) {
      $result.valid = valid;
    }
    return $result;
  }
  ValidateWIFResponse._() : super();
  factory ValidateWIFResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ValidateWIFResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateWIFResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ValidateWIFResponse clone() => ValidateWIFResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ValidateWIFResponse copyWith(void Function(ValidateWIFResponse) updates) => super.copyWith((message) => updates(message as ValidateWIFResponse)) as ValidateWIFResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateWIFResponse create() => ValidateWIFResponse._();
  ValidateWIFResponse createEmptyInstance() => create();
  static $pb.PbList<ValidateWIFResponse> createRepeated() => $pb.PbList<ValidateWIFResponse>();
  @$core.pragma('dart2js:noInline')
  static ValidateWIFResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidateWIFResponse>(create);
  static ValidateWIFResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => clearField(1);
}

class WIFToAddressRequest extends $pb.GeneratedMessage {
  factory WIFToAddressRequest({
    $core.String? wif,
  }) {
    final $result = create();
    if (wif != null) {
      $result.wif = wif;
    }
    return $result;
  }
  WIFToAddressRequest._() : super();
  factory WIFToAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WIFToAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WIFToAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'wif')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WIFToAddressRequest clone() => WIFToAddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WIFToAddressRequest copyWith(void Function(WIFToAddressRequest) updates) => super.copyWith((message) => updates(message as WIFToAddressRequest)) as WIFToAddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WIFToAddressRequest create() => WIFToAddressRequest._();
  WIFToAddressRequest createEmptyInstance() => create();
  static $pb.PbList<WIFToAddressRequest> createRepeated() => $pb.PbList<WIFToAddressRequest>();
  @$core.pragma('dart2js:noInline')
  static WIFToAddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WIFToAddressRequest>(create);
  static WIFToAddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get wif => $_getSZ(0);
  @$pb.TagNumber(1)
  set wif($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWif() => $_has(0);
  @$pb.TagNumber(1)
  void clearWif() => clearField(1);
}

class WIFToAddressResponse extends $pb.GeneratedMessage {
  factory WIFToAddressResponse({
    $core.String? address,
    $core.String? error,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  WIFToAddressResponse._() : super();
  factory WIFToAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WIFToAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WIFToAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WIFToAddressResponse clone() => WIFToAddressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WIFToAddressResponse copyWith(void Function(WIFToAddressResponse) updates) => super.copyWith((message) => updates(message as WIFToAddressResponse)) as WIFToAddressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WIFToAddressResponse create() => WIFToAddressResponse._();
  WIFToAddressResponse createEmptyInstance() => create();
  static $pb.PbList<WIFToAddressResponse> createRepeated() => $pb.PbList<WIFToAddressResponse>();
  @$core.pragma('dart2js:noInline')
  static WIFToAddressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WIFToAddressResponse>(create);
  static WIFToAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => clearField(2);
}

class ConvertRequest extends $pb.GeneratedMessage {
  factory ConvertRequest({
    $core.String? input,
    ConvertFormat? format,
  }) {
    final $result = create();
    if (input != null) {
      $result.input = input;
    }
    if (format != null) {
      $result.format = format;
    }
    return $result;
  }
  ConvertRequest._() : super();
  factory ConvertRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConvertRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConvertRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'input')
    ..e<ConvertFormat>(2, _omitFieldNames ? '' : 'format', $pb.PbFieldType.OE, defaultOrMaker: ConvertFormat.CONVERT_FORMAT_AUTO, valueOf: ConvertFormat.valueOf, enumValues: ConvertFormat.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConvertRequest clone() => ConvertRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConvertRequest copyWith(void Function(ConvertRequest) updates) => super.copyWith((message) => updates(message as ConvertRequest)) as ConvertRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConvertRequest create() => ConvertRequest._();
  ConvertRequest createEmptyInstance() => create();
  static $pb.PbList<ConvertRequest> createRepeated() => $pb.PbList<ConvertRequest>();
  @$core.pragma('dart2js:noInline')
  static ConvertRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConvertRequest>(create);
  static ConvertRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get input => $_getSZ(0);
  @$pb.TagNumber(1)
  set input($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasInput() => $_has(0);
  @$pb.TagNumber(1)
  void clearInput() => clearField(1);

  @$pb.TagNumber(2)
  ConvertFormat get format => $_getN(1);
  @$pb.TagNumber(2)
  set format(ConvertFormat v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasFormat() => $_has(1);
  @$pb.TagNumber(2)
  void clearFormat() => clearField(2);
}

class ConvertRow extends $pb.GeneratedMessage {
  factory ConvertRow({
    $core.String? label,
    $core.String? value,
  }) {
    final $result = create();
    if (label != null) {
      $result.label = label;
    }
    if (value != null) {
      $result.value = value;
    }
    return $result;
  }
  ConvertRow._() : super();
  factory ConvertRow.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConvertRow.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConvertRow', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConvertRow clone() => ConvertRow()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConvertRow copyWith(void Function(ConvertRow) updates) => super.copyWith((message) => updates(message as ConvertRow)) as ConvertRow;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConvertRow create() => ConvertRow._();
  ConvertRow createEmptyInstance() => create();
  static $pb.PbList<ConvertRow> createRepeated() => $pb.PbList<ConvertRow>();
  @$core.pragma('dart2js:noInline')
  static ConvertRow getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConvertRow>(create);
  static ConvertRow? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => clearField(2);
}

class ConvertResponse extends $pb.GeneratedMessage {
  factory ConvertResponse({
    ConvertFormat? detected,
    $core.String? error,
    $core.Iterable<ConvertRow>? encodings,
    $core.Iterable<ConvertRow>? hashes,
    $core.Iterable<ConvertRow>? keys,
  }) {
    final $result = create();
    if (detected != null) {
      $result.detected = detected;
    }
    if (error != null) {
      $result.error = error;
    }
    if (encodings != null) {
      $result.encodings.addAll(encodings);
    }
    if (hashes != null) {
      $result.hashes.addAll(hashes);
    }
    if (keys != null) {
      $result.keys.addAll(keys);
    }
    return $result;
  }
  ConvertResponse._() : super();
  factory ConvertResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConvertResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConvertResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..e<ConvertFormat>(1, _omitFieldNames ? '' : 'detected', $pb.PbFieldType.OE, defaultOrMaker: ConvertFormat.CONVERT_FORMAT_AUTO, valueOf: ConvertFormat.valueOf, enumValues: ConvertFormat.values)
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..pc<ConvertRow>(3, _omitFieldNames ? '' : 'encodings', $pb.PbFieldType.PM, subBuilder: ConvertRow.create)
    ..pc<ConvertRow>(4, _omitFieldNames ? '' : 'hashes', $pb.PbFieldType.PM, subBuilder: ConvertRow.create)
    ..pc<ConvertRow>(5, _omitFieldNames ? '' : 'keys', $pb.PbFieldType.PM, subBuilder: ConvertRow.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConvertResponse clone() => ConvertResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConvertResponse copyWith(void Function(ConvertResponse) updates) => super.copyWith((message) => updates(message as ConvertResponse)) as ConvertResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConvertResponse create() => ConvertResponse._();
  ConvertResponse createEmptyInstance() => create();
  static $pb.PbList<ConvertResponse> createRepeated() => $pb.PbList<ConvertResponse>();
  @$core.pragma('dart2js:noInline')
  static ConvertResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConvertResponse>(create);
  static ConvertResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ConvertFormat get detected => $_getN(0);
  @$pb.TagNumber(1)
  set detected(ConvertFormat v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDetected() => $_has(0);
  @$pb.TagNumber(1)
  void clearDetected() => clearField(1);

  /// Why the input could not be read; empty on success.
  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<ConvertRow> get encodings => $_getList(2);

  @$pb.TagNumber(4)
  $core.List<ConvertRow> get hashes => $_getList(3);

  @$pb.TagNumber(5)
  $core.List<ConvertRow> get keys => $_getList(4);
}

class UtilsServiceApi {
  $pb.RpcClient _client;
  UtilsServiceApi(this._client);

  $async.Future<ParseBitcoinURIResponse> parseBitcoinURI($pb.ClientContext? ctx, ParseBitcoinURIRequest request) =>
    _client.invoke<ParseBitcoinURIResponse>(ctx, 'UtilsService', 'ParseBitcoinURI', request, ParseBitcoinURIResponse())
  ;
  $async.Future<ValidateBitcoinURIResponse> validateBitcoinURI($pb.ClientContext? ctx, ValidateBitcoinURIRequest request) =>
    _client.invoke<ValidateBitcoinURIResponse>(ctx, 'UtilsService', 'ValidateBitcoinURI', request, ValidateBitcoinURIResponse())
  ;
  $async.Future<DecodeBase58CheckResponse> decodeBase58Check($pb.ClientContext? ctx, DecodeBase58CheckRequest request) =>
    _client.invoke<DecodeBase58CheckResponse>(ctx, 'UtilsService', 'DecodeBase58Check', request, DecodeBase58CheckResponse())
  ;
  $async.Future<EncodeBase58CheckResponse> encodeBase58Check($pb.ClientContext? ctx, EncodeBase58CheckRequest request) =>
    _client.invoke<EncodeBase58CheckResponse>(ctx, 'UtilsService', 'EncodeBase58Check', request, EncodeBase58CheckResponse())
  ;
  $async.Future<CalculateMerkleTreeResponse> calculateMerkleTree($pb.ClientContext? ctx, CalculateMerkleTreeRequest request) =>
    _client.invoke<CalculateMerkleTreeResponse>(ctx, 'UtilsService', 'CalculateMerkleTree', request, CalculateMerkleTreeResponse())
  ;
  $async.Future<GeneratePaperWalletResponse> generatePaperWallet($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<GeneratePaperWalletResponse>(ctx, 'UtilsService', 'GeneratePaperWallet', request, GeneratePaperWalletResponse())
  ;
  $async.Future<ValidateWIFResponse> validateWIF($pb.ClientContext? ctx, ValidateWIFRequest request) =>
    _client.invoke<ValidateWIFResponse>(ctx, 'UtilsService', 'ValidateWIF', request, ValidateWIFResponse())
  ;
  $async.Future<WIFToAddressResponse> wIFToAddress($pb.ClientContext? ctx, WIFToAddressRequest request) =>
    _client.invoke<WIFToAddressResponse>(ctx, 'UtilsService', 'WIFToAddress', request, WIFToAddressResponse())
  ;
  $async.Future<CreatePaperWalletPdfResponse> createPaperWalletPdf($pb.ClientContext? ctx, CreatePaperWalletPdfRequest request) =>
    _client.invoke<CreatePaperWalletPdfResponse>(ctx, 'UtilsService', 'CreatePaperWalletPdf', request, CreatePaperWalletPdfResponse())
  ;
  $async.Future<CreatePaperCheckPdfResponse> createPaperCheckPdf($pb.ClientContext? ctx, CreatePaperCheckPdfRequest request) =>
    _client.invoke<CreatePaperCheckPdfResponse>(ctx, 'UtilsService', 'CreatePaperCheckPdf', request, CreatePaperCheckPdfResponse())
  ;
  $async.Future<ConvertResponse> convert($pb.ClientContext? ctx, ConvertRequest request) =>
    _client.invoke<ConvertResponse>(ctx, 'UtilsService', 'Convert', request, ConvertResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
