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
  }) {
    final $result = create();
    if (txids != null) {
      $result.txids.addAll(txids);
    }
    return $result;
  }
  CalculateMerkleTreeRequest._() : super();
  factory CalculateMerkleTreeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CalculateMerkleTreeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CalculateMerkleTreeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'utils.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'txids')
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
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
