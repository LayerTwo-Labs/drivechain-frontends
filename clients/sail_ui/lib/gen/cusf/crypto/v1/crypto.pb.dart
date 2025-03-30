//
//  Generated code. Do not modify.
//  source: cusf/crypto/v1/crypto.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../common/v1/common.pb.dart' as $1;

class HmacSha512Request extends $pb.GeneratedMessage {
  factory HmacSha512Request({
    $1.Hex? key,
    $1.Hex? msg,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    return $result;
  }
  HmacSha512Request._() : super();
  factory HmacSha512Request.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory HmacSha512Request.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HmacSha512Request', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'), createEmptyInstance: create)
    ..aOM<$1.Hex>(1, _omitFieldNames ? '' : 'key', subBuilder: $1.Hex.create)
    ..aOM<$1.Hex>(2, _omitFieldNames ? '' : 'msg', subBuilder: $1.Hex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  HmacSha512Request clone() => HmacSha512Request()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  HmacSha512Request copyWith(void Function(HmacSha512Request) updates) => super.copyWith((message) => updates(message as HmacSha512Request)) as HmacSha512Request;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HmacSha512Request create() => HmacSha512Request._();
  HmacSha512Request createEmptyInstance() => create();
  static $pb.PbList<HmacSha512Request> createRepeated() => $pb.PbList<HmacSha512Request>();
  @$core.pragma('dart2js:noInline')
  static HmacSha512Request getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HmacSha512Request>(create);
  static HmacSha512Request? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Hex get key => $_getN(0);
  @$pb.TagNumber(1)
  set key($1.Hex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);
  @$pb.TagNumber(1)
  $1.Hex ensureKey() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.Hex get msg => $_getN(1);
  @$pb.TagNumber(2)
  set msg($1.Hex v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
  @$pb.TagNumber(2)
  $1.Hex ensureMsg() => $_ensure(1);
}

class HmacSha512Response extends $pb.GeneratedMessage {
  factory HmacSha512Response({
    $1.Hex? hmac,
  }) {
    final $result = create();
    if (hmac != null) {
      $result.hmac = hmac;
    }
    return $result;
  }
  HmacSha512Response._() : super();
  factory HmacSha512Response.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory HmacSha512Response.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HmacSha512Response', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'), createEmptyInstance: create)
    ..aOM<$1.Hex>(1, _omitFieldNames ? '' : 'hmac', subBuilder: $1.Hex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  HmacSha512Response clone() => HmacSha512Response()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  HmacSha512Response copyWith(void Function(HmacSha512Response) updates) => super.copyWith((message) => updates(message as HmacSha512Response)) as HmacSha512Response;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HmacSha512Response create() => HmacSha512Response._();
  HmacSha512Response createEmptyInstance() => create();
  static $pb.PbList<HmacSha512Response> createRepeated() => $pb.PbList<HmacSha512Response>();
  @$core.pragma('dart2js:noInline')
  static HmacSha512Response getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HmacSha512Response>(create);
  static HmacSha512Response? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Hex get hmac => $_getN(0);
  @$pb.TagNumber(1)
  set hmac($1.Hex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasHmac() => $_has(0);
  @$pb.TagNumber(1)
  void clearHmac() => clearField(1);
  @$pb.TagNumber(1)
  $1.Hex ensureHmac() => $_ensure(0);
}

class Ripemd160Request extends $pb.GeneratedMessage {
  factory Ripemd160Request({
    $1.Hex? msg,
  }) {
    final $result = create();
    if (msg != null) {
      $result.msg = msg;
    }
    return $result;
  }
  Ripemd160Request._() : super();
  factory Ripemd160Request.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Ripemd160Request.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Ripemd160Request', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'), createEmptyInstance: create)
    ..aOM<$1.Hex>(1, _omitFieldNames ? '' : 'msg', subBuilder: $1.Hex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Ripemd160Request clone() => Ripemd160Request()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Ripemd160Request copyWith(void Function(Ripemd160Request) updates) => super.copyWith((message) => updates(message as Ripemd160Request)) as Ripemd160Request;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Ripemd160Request create() => Ripemd160Request._();
  Ripemd160Request createEmptyInstance() => create();
  static $pb.PbList<Ripemd160Request> createRepeated() => $pb.PbList<Ripemd160Request>();
  @$core.pragma('dart2js:noInline')
  static Ripemd160Request getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Ripemd160Request>(create);
  static Ripemd160Request? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Hex get msg => $_getN(0);
  @$pb.TagNumber(1)
  set msg($1.Hex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => clearField(1);
  @$pb.TagNumber(1)
  $1.Hex ensureMsg() => $_ensure(0);
}

class Ripemd160Response extends $pb.GeneratedMessage {
  factory Ripemd160Response({
    $1.Hex? digest,
  }) {
    final $result = create();
    if (digest != null) {
      $result.digest = digest;
    }
    return $result;
  }
  Ripemd160Response._() : super();
  factory Ripemd160Response.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Ripemd160Response.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Ripemd160Response', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'), createEmptyInstance: create)
    ..aOM<$1.Hex>(1, _omitFieldNames ? '' : 'digest', subBuilder: $1.Hex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Ripemd160Response clone() => Ripemd160Response()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Ripemd160Response copyWith(void Function(Ripemd160Response) updates) => super.copyWith((message) => updates(message as Ripemd160Response)) as Ripemd160Response;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Ripemd160Response create() => Ripemd160Response._();
  Ripemd160Response createEmptyInstance() => create();
  static $pb.PbList<Ripemd160Response> createRepeated() => $pb.PbList<Ripemd160Response>();
  @$core.pragma('dart2js:noInline')
  static Ripemd160Response getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Ripemd160Response>(create);
  static Ripemd160Response? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Hex get digest => $_getN(0);
  @$pb.TagNumber(1)
  set digest($1.Hex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDigest() => $_has(0);
  @$pb.TagNumber(1)
  void clearDigest() => clearField(1);
  @$pb.TagNumber(1)
  $1.Hex ensureDigest() => $_ensure(0);
}

class Secp256k1SecretKeyToPublicKeyRequest extends $pb.GeneratedMessage {
  factory Secp256k1SecretKeyToPublicKeyRequest({
    $1.ConsensusHex? secretKey,
  }) {
    final $result = create();
    if (secretKey != null) {
      $result.secretKey = secretKey;
    }
    return $result;
  }
  Secp256k1SecretKeyToPublicKeyRequest._() : super();
  factory Secp256k1SecretKeyToPublicKeyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Secp256k1SecretKeyToPublicKeyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Secp256k1SecretKeyToPublicKeyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'), createEmptyInstance: create)
    ..aOM<$1.ConsensusHex>(1, _omitFieldNames ? '' : 'secretKey', subBuilder: $1.ConsensusHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Secp256k1SecretKeyToPublicKeyRequest clone() => Secp256k1SecretKeyToPublicKeyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Secp256k1SecretKeyToPublicKeyRequest copyWith(void Function(Secp256k1SecretKeyToPublicKeyRequest) updates) => super.copyWith((message) => updates(message as Secp256k1SecretKeyToPublicKeyRequest)) as Secp256k1SecretKeyToPublicKeyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Secp256k1SecretKeyToPublicKeyRequest create() => Secp256k1SecretKeyToPublicKeyRequest._();
  Secp256k1SecretKeyToPublicKeyRequest createEmptyInstance() => create();
  static $pb.PbList<Secp256k1SecretKeyToPublicKeyRequest> createRepeated() => $pb.PbList<Secp256k1SecretKeyToPublicKeyRequest>();
  @$core.pragma('dart2js:noInline')
  static Secp256k1SecretKeyToPublicKeyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Secp256k1SecretKeyToPublicKeyRequest>(create);
  static Secp256k1SecretKeyToPublicKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ConsensusHex get secretKey => $_getN(0);
  @$pb.TagNumber(1)
  set secretKey($1.ConsensusHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSecretKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearSecretKey() => clearField(1);
  @$pb.TagNumber(1)
  $1.ConsensusHex ensureSecretKey() => $_ensure(0);
}

class Secp256k1SecretKeyToPublicKeyResponse extends $pb.GeneratedMessage {
  factory Secp256k1SecretKeyToPublicKeyResponse({
    $1.ConsensusHex? publicKey,
  }) {
    final $result = create();
    if (publicKey != null) {
      $result.publicKey = publicKey;
    }
    return $result;
  }
  Secp256k1SecretKeyToPublicKeyResponse._() : super();
  factory Secp256k1SecretKeyToPublicKeyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Secp256k1SecretKeyToPublicKeyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Secp256k1SecretKeyToPublicKeyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'), createEmptyInstance: create)
    ..aOM<$1.ConsensusHex>(1, _omitFieldNames ? '' : 'publicKey', subBuilder: $1.ConsensusHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Secp256k1SecretKeyToPublicKeyResponse clone() => Secp256k1SecretKeyToPublicKeyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Secp256k1SecretKeyToPublicKeyResponse copyWith(void Function(Secp256k1SecretKeyToPublicKeyResponse) updates) => super.copyWith((message) => updates(message as Secp256k1SecretKeyToPublicKeyResponse)) as Secp256k1SecretKeyToPublicKeyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Secp256k1SecretKeyToPublicKeyResponse create() => Secp256k1SecretKeyToPublicKeyResponse._();
  Secp256k1SecretKeyToPublicKeyResponse createEmptyInstance() => create();
  static $pb.PbList<Secp256k1SecretKeyToPublicKeyResponse> createRepeated() => $pb.PbList<Secp256k1SecretKeyToPublicKeyResponse>();
  @$core.pragma('dart2js:noInline')
  static Secp256k1SecretKeyToPublicKeyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Secp256k1SecretKeyToPublicKeyResponse>(create);
  static Secp256k1SecretKeyToPublicKeyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ConsensusHex get publicKey => $_getN(0);
  @$pb.TagNumber(1)
  set publicKey($1.ConsensusHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPublicKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearPublicKey() => clearField(1);
  @$pb.TagNumber(1)
  $1.ConsensusHex ensurePublicKey() => $_ensure(0);
}

class Secp256k1SignRequest extends $pb.GeneratedMessage {
  factory Secp256k1SignRequest({
    $1.Hex? message,
    $1.ConsensusHex? secretKey,
  }) {
    final $result = create();
    if (message != null) {
      $result.message = message;
    }
    if (secretKey != null) {
      $result.secretKey = secretKey;
    }
    return $result;
  }
  Secp256k1SignRequest._() : super();
  factory Secp256k1SignRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Secp256k1SignRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Secp256k1SignRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'), createEmptyInstance: create)
    ..aOM<$1.Hex>(1, _omitFieldNames ? '' : 'message', subBuilder: $1.Hex.create)
    ..aOM<$1.ConsensusHex>(2, _omitFieldNames ? '' : 'secretKey', subBuilder: $1.ConsensusHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Secp256k1SignRequest clone() => Secp256k1SignRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Secp256k1SignRequest copyWith(void Function(Secp256k1SignRequest) updates) => super.copyWith((message) => updates(message as Secp256k1SignRequest)) as Secp256k1SignRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Secp256k1SignRequest create() => Secp256k1SignRequest._();
  Secp256k1SignRequest createEmptyInstance() => create();
  static $pb.PbList<Secp256k1SignRequest> createRepeated() => $pb.PbList<Secp256k1SignRequest>();
  @$core.pragma('dart2js:noInline')
  static Secp256k1SignRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Secp256k1SignRequest>(create);
  static Secp256k1SignRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Hex get message => $_getN(0);
  @$pb.TagNumber(1)
  set message($1.Hex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);
  @$pb.TagNumber(1)
  $1.Hex ensureMessage() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ConsensusHex get secretKey => $_getN(1);
  @$pb.TagNumber(2)
  set secretKey($1.ConsensusHex v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSecretKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearSecretKey() => clearField(2);
  @$pb.TagNumber(2)
  $1.ConsensusHex ensureSecretKey() => $_ensure(1);
}

class Secp256k1SignResponse extends $pb.GeneratedMessage {
  factory Secp256k1SignResponse({
    $1.Hex? signature,
  }) {
    final $result = create();
    if (signature != null) {
      $result.signature = signature;
    }
    return $result;
  }
  Secp256k1SignResponse._() : super();
  factory Secp256k1SignResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Secp256k1SignResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Secp256k1SignResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'), createEmptyInstance: create)
    ..aOM<$1.Hex>(1, _omitFieldNames ? '' : 'signature', subBuilder: $1.Hex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Secp256k1SignResponse clone() => Secp256k1SignResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Secp256k1SignResponse copyWith(void Function(Secp256k1SignResponse) updates) => super.copyWith((message) => updates(message as Secp256k1SignResponse)) as Secp256k1SignResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Secp256k1SignResponse create() => Secp256k1SignResponse._();
  Secp256k1SignResponse createEmptyInstance() => create();
  static $pb.PbList<Secp256k1SignResponse> createRepeated() => $pb.PbList<Secp256k1SignResponse>();
  @$core.pragma('dart2js:noInline')
  static Secp256k1SignResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Secp256k1SignResponse>(create);
  static Secp256k1SignResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Hex get signature => $_getN(0);
  @$pb.TagNumber(1)
  set signature($1.Hex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSignature() => $_has(0);
  @$pb.TagNumber(1)
  void clearSignature() => clearField(1);
  @$pb.TagNumber(1)
  $1.Hex ensureSignature() => $_ensure(0);
}

class Secp256k1VerifyRequest extends $pb.GeneratedMessage {
  factory Secp256k1VerifyRequest({
    $1.Hex? message,
    $1.Hex? signature,
    $1.ConsensusHex? publicKey,
  }) {
    final $result = create();
    if (message != null) {
      $result.message = message;
    }
    if (signature != null) {
      $result.signature = signature;
    }
    if (publicKey != null) {
      $result.publicKey = publicKey;
    }
    return $result;
  }
  Secp256k1VerifyRequest._() : super();
  factory Secp256k1VerifyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Secp256k1VerifyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Secp256k1VerifyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'), createEmptyInstance: create)
    ..aOM<$1.Hex>(1, _omitFieldNames ? '' : 'message', subBuilder: $1.Hex.create)
    ..aOM<$1.Hex>(2, _omitFieldNames ? '' : 'signature', subBuilder: $1.Hex.create)
    ..aOM<$1.ConsensusHex>(3, _omitFieldNames ? '' : 'publicKey', subBuilder: $1.ConsensusHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Secp256k1VerifyRequest clone() => Secp256k1VerifyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Secp256k1VerifyRequest copyWith(void Function(Secp256k1VerifyRequest) updates) => super.copyWith((message) => updates(message as Secp256k1VerifyRequest)) as Secp256k1VerifyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Secp256k1VerifyRequest create() => Secp256k1VerifyRequest._();
  Secp256k1VerifyRequest createEmptyInstance() => create();
  static $pb.PbList<Secp256k1VerifyRequest> createRepeated() => $pb.PbList<Secp256k1VerifyRequest>();
  @$core.pragma('dart2js:noInline')
  static Secp256k1VerifyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Secp256k1VerifyRequest>(create);
  static Secp256k1VerifyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Hex get message => $_getN(0);
  @$pb.TagNumber(1)
  set message($1.Hex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);
  @$pb.TagNumber(1)
  $1.Hex ensureMessage() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.Hex get signature => $_getN(1);
  @$pb.TagNumber(2)
  set signature($1.Hex v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => clearField(2);
  @$pb.TagNumber(2)
  $1.Hex ensureSignature() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.ConsensusHex get publicKey => $_getN(2);
  @$pb.TagNumber(3)
  set publicKey($1.ConsensusHex v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasPublicKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearPublicKey() => clearField(3);
  @$pb.TagNumber(3)
  $1.ConsensusHex ensurePublicKey() => $_ensure(2);
}

class Secp256k1VerifyResponse extends $pb.GeneratedMessage {
  factory Secp256k1VerifyResponse({
    $core.bool? valid,
  }) {
    final $result = create();
    if (valid != null) {
      $result.valid = valid;
    }
    return $result;
  }
  Secp256k1VerifyResponse._() : super();
  factory Secp256k1VerifyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Secp256k1VerifyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Secp256k1VerifyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Secp256k1VerifyResponse clone() => Secp256k1VerifyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Secp256k1VerifyResponse copyWith(void Function(Secp256k1VerifyResponse) updates) => super.copyWith((message) => updates(message as Secp256k1VerifyResponse)) as Secp256k1VerifyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Secp256k1VerifyResponse create() => Secp256k1VerifyResponse._();
  Secp256k1VerifyResponse createEmptyInstance() => create();
  static $pb.PbList<Secp256k1VerifyResponse> createRepeated() => $pb.PbList<Secp256k1VerifyResponse>();
  @$core.pragma('dart2js:noInline')
  static Secp256k1VerifyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Secp256k1VerifyResponse>(create);
  static Secp256k1VerifyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => clearField(1);
}

class CryptoServiceApi {
  $pb.RpcClient _client;
  CryptoServiceApi(this._client);

  $async.Future<HmacSha512Response> hmacSha512($pb.ClientContext? ctx, HmacSha512Request request) =>
    _client.invoke<HmacSha512Response>(ctx, 'CryptoService', 'HmacSha512', request, HmacSha512Response())
  ;
  $async.Future<Ripemd160Response> ripemd160($pb.ClientContext? ctx, Ripemd160Request request) =>
    _client.invoke<Ripemd160Response>(ctx, 'CryptoService', 'Ripemd160', request, Ripemd160Response())
  ;
  $async.Future<Secp256k1SecretKeyToPublicKeyResponse> secp256k1SecretKeyToPublicKey($pb.ClientContext? ctx, Secp256k1SecretKeyToPublicKeyRequest request) =>
    _client.invoke<Secp256k1SecretKeyToPublicKeyResponse>(ctx, 'CryptoService', 'Secp256k1SecretKeyToPublicKey', request, Secp256k1SecretKeyToPublicKeyResponse())
  ;
  $async.Future<Secp256k1SignResponse> secp256k1Sign($pb.ClientContext? ctx, Secp256k1SignRequest request) =>
    _client.invoke<Secp256k1SignResponse>(ctx, 'CryptoService', 'Secp256k1Sign', request, Secp256k1SignResponse())
  ;
  $async.Future<Secp256k1VerifyResponse> secp256k1Verify($pb.ClientContext? ctx, Secp256k1VerifyRequest request) =>
    _client.invoke<Secp256k1VerifyResponse>(ctx, 'CryptoService', 'Secp256k1Verify', request, Secp256k1VerifyResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
