// This is a generated file - do not edit.
//
// Generated from cusf/crypto/v1/crypto.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../common/v1/common.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class HmacSha512Request extends $pb.GeneratedMessage {
  factory HmacSha512Request({
    $0.Hex? key,
    $0.Hex? msg,
  }) {
    final result = HmacSha512Request._();
    if (key != null) result.key = key;
    if (msg != null) result.msg = msg;
    return result;
  }

  HmacSha512Request._();

  factory HmacSha512Request.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HmacSha512Request()..mergeFromBuffer(data, registry);
  factory HmacSha512Request.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HmacSha512Request()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HmacSha512Request',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'),
      createEmptyInstance: HmacSha512Request.$_createMessage)
    ..aOM<$0.Hex>(1, _omitFieldNames ? '' : 'key', subBuilder: $0.Hex.$_createMessage)
    ..aOM<$0.Hex>(2, _omitFieldNames ? '' : 'msg', subBuilder: $0.Hex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HmacSha512Request clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HmacSha512Request copyWith(void Function(HmacSha512Request) updates) =>
      super.copyWith((message) => updates(message as HmacSha512Request)) as HmacSha512Request;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HmacSha512Request() / HmacSha512Request.new instead')
  static HmacSha512Request create() => HmacSha512Request._();
  static $pb.GeneratedMessage $_createMessage() => HmacSha512Request._();
  @$core.override
  HmacSha512Request createEmptyInstance() => HmacSha512Request._();
  @$core.pragma('dart2js:noInline')
  static HmacSha512Request getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HmacSha512Request>(HmacSha512Request.$_createMessage);
  static HmacSha512Request? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Hex get key => $_getN(0);
  @$pb.TagNumber(1)
  set key($0.Hex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Hex ensureKey() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.Hex get msg => $_getN(1);
  @$pb.TagNumber(2)
  set msg($0.Hex value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Hex ensureMsg() => $_ensure(1);
}

class HmacSha512Response extends $pb.GeneratedMessage {
  factory HmacSha512Response({
    $0.Hex? hmac,
  }) {
    final result = HmacSha512Response._();
    if (hmac != null) result.hmac = hmac;
    return result;
  }

  HmacSha512Response._();

  factory HmacSha512Response.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HmacSha512Response()..mergeFromBuffer(data, registry);
  factory HmacSha512Response.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HmacSha512Response()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HmacSha512Response',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'),
      createEmptyInstance: HmacSha512Response.$_createMessage)
    ..aOM<$0.Hex>(1, _omitFieldNames ? '' : 'hmac', subBuilder: $0.Hex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HmacSha512Response clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HmacSha512Response copyWith(void Function(HmacSha512Response) updates) =>
      super.copyWith((message) => updates(message as HmacSha512Response)) as HmacSha512Response;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HmacSha512Response() / HmacSha512Response.new instead')
  static HmacSha512Response create() => HmacSha512Response._();
  static $pb.GeneratedMessage $_createMessage() => HmacSha512Response._();
  @$core.override
  HmacSha512Response createEmptyInstance() => HmacSha512Response._();
  @$core.pragma('dart2js:noInline')
  static HmacSha512Response getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HmacSha512Response>(HmacSha512Response.$_createMessage);
  static HmacSha512Response? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Hex get hmac => $_getN(0);
  @$pb.TagNumber(1)
  set hmac($0.Hex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHmac() => $_has(0);
  @$pb.TagNumber(1)
  void clearHmac() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Hex ensureHmac() => $_ensure(0);
}

class Ripemd160Request extends $pb.GeneratedMessage {
  factory Ripemd160Request({
    $0.Hex? msg,
  }) {
    final result = Ripemd160Request._();
    if (msg != null) result.msg = msg;
    return result;
  }

  Ripemd160Request._();

  factory Ripemd160Request.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Ripemd160Request()..mergeFromBuffer(data, registry);
  factory Ripemd160Request.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Ripemd160Request()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Ripemd160Request',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'),
      createEmptyInstance: Ripemd160Request.$_createMessage)
    ..aOM<$0.Hex>(1, _omitFieldNames ? '' : 'msg', subBuilder: $0.Hex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ripemd160Request clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ripemd160Request copyWith(void Function(Ripemd160Request) updates) =>
      super.copyWith((message) => updates(message as Ripemd160Request)) as Ripemd160Request;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Ripemd160Request() / Ripemd160Request.new instead')
  static Ripemd160Request create() => Ripemd160Request._();
  static $pb.GeneratedMessage $_createMessage() => Ripemd160Request._();
  @$core.override
  Ripemd160Request createEmptyInstance() => Ripemd160Request._();
  @$core.pragma('dart2js:noInline')
  static Ripemd160Request getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Ripemd160Request>(Ripemd160Request.$_createMessage);
  static Ripemd160Request? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Hex get msg => $_getN(0);
  @$pb.TagNumber(1)
  set msg($0.Hex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Hex ensureMsg() => $_ensure(0);
}

class Ripemd160Response extends $pb.GeneratedMessage {
  factory Ripemd160Response({
    $0.Hex? digest,
  }) {
    final result = Ripemd160Response._();
    if (digest != null) result.digest = digest;
    return result;
  }

  Ripemd160Response._();

  factory Ripemd160Response.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Ripemd160Response()..mergeFromBuffer(data, registry);
  factory Ripemd160Response.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Ripemd160Response()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Ripemd160Response',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'),
      createEmptyInstance: Ripemd160Response.$_createMessage)
    ..aOM<$0.Hex>(1, _omitFieldNames ? '' : 'digest', subBuilder: $0.Hex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ripemd160Response clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ripemd160Response copyWith(void Function(Ripemd160Response) updates) =>
      super.copyWith((message) => updates(message as Ripemd160Response)) as Ripemd160Response;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Ripemd160Response() / Ripemd160Response.new instead')
  static Ripemd160Response create() => Ripemd160Response._();
  static $pb.GeneratedMessage $_createMessage() => Ripemd160Response._();
  @$core.override
  Ripemd160Response createEmptyInstance() => Ripemd160Response._();
  @$core.pragma('dart2js:noInline')
  static Ripemd160Response getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Ripemd160Response>(Ripemd160Response.$_createMessage);
  static Ripemd160Response? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Hex get digest => $_getN(0);
  @$pb.TagNumber(1)
  set digest($0.Hex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDigest() => $_has(0);
  @$pb.TagNumber(1)
  void clearDigest() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Hex ensureDigest() => $_ensure(0);
}

class Secp256k1SecretKeyToPublicKeyRequest extends $pb.GeneratedMessage {
  factory Secp256k1SecretKeyToPublicKeyRequest({
    $0.ConsensusHex? secretKey,
  }) {
    final result = Secp256k1SecretKeyToPublicKeyRequest._();
    if (secretKey != null) result.secretKey = secretKey;
    return result;
  }

  Secp256k1SecretKeyToPublicKeyRequest._();

  factory Secp256k1SecretKeyToPublicKeyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Secp256k1SecretKeyToPublicKeyRequest()..mergeFromBuffer(data, registry);
  factory Secp256k1SecretKeyToPublicKeyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Secp256k1SecretKeyToPublicKeyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Secp256k1SecretKeyToPublicKeyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'),
      createEmptyInstance: Secp256k1SecretKeyToPublicKeyRequest.$_createMessage)
    ..aOM<$0.ConsensusHex>(1, _omitFieldNames ? '' : 'secretKey', subBuilder: $0.ConsensusHex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secp256k1SecretKeyToPublicKeyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secp256k1SecretKeyToPublicKeyRequest copyWith(void Function(Secp256k1SecretKeyToPublicKeyRequest) updates) =>
      super.copyWith((message) => updates(message as Secp256k1SecretKeyToPublicKeyRequest))
          as Secp256k1SecretKeyToPublicKeyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Secp256k1SecretKeyToPublicKeyRequest() / Secp256k1SecretKeyToPublicKeyRequest.new instead')
  static Secp256k1SecretKeyToPublicKeyRequest create() => Secp256k1SecretKeyToPublicKeyRequest._();
  static $pb.GeneratedMessage $_createMessage() => Secp256k1SecretKeyToPublicKeyRequest._();
  @$core.override
  Secp256k1SecretKeyToPublicKeyRequest createEmptyInstance() => Secp256k1SecretKeyToPublicKeyRequest._();
  @$core.pragma('dart2js:noInline')
  static Secp256k1SecretKeyToPublicKeyRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Secp256k1SecretKeyToPublicKeyRequest>(
          Secp256k1SecretKeyToPublicKeyRequest.$_createMessage);
  static Secp256k1SecretKeyToPublicKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.ConsensusHex get secretKey => $_getN(0);
  @$pb.TagNumber(1)
  set secretKey($0.ConsensusHex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSecretKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearSecretKey() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ConsensusHex ensureSecretKey() => $_ensure(0);
}

class Secp256k1SecretKeyToPublicKeyResponse extends $pb.GeneratedMessage {
  factory Secp256k1SecretKeyToPublicKeyResponse({
    $0.ConsensusHex? publicKey,
  }) {
    final result = Secp256k1SecretKeyToPublicKeyResponse._();
    if (publicKey != null) result.publicKey = publicKey;
    return result;
  }

  Secp256k1SecretKeyToPublicKeyResponse._();

  factory Secp256k1SecretKeyToPublicKeyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Secp256k1SecretKeyToPublicKeyResponse()..mergeFromBuffer(data, registry);
  factory Secp256k1SecretKeyToPublicKeyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Secp256k1SecretKeyToPublicKeyResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Secp256k1SecretKeyToPublicKeyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'),
      createEmptyInstance: Secp256k1SecretKeyToPublicKeyResponse.$_createMessage)
    ..aOM<$0.ConsensusHex>(1, _omitFieldNames ? '' : 'publicKey', subBuilder: $0.ConsensusHex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secp256k1SecretKeyToPublicKeyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secp256k1SecretKeyToPublicKeyResponse copyWith(void Function(Secp256k1SecretKeyToPublicKeyResponse) updates) =>
      super.copyWith((message) => updates(message as Secp256k1SecretKeyToPublicKeyResponse))
          as Secp256k1SecretKeyToPublicKeyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Secp256k1SecretKeyToPublicKeyResponse() / Secp256k1SecretKeyToPublicKeyResponse.new instead')
  static Secp256k1SecretKeyToPublicKeyResponse create() => Secp256k1SecretKeyToPublicKeyResponse._();
  static $pb.GeneratedMessage $_createMessage() => Secp256k1SecretKeyToPublicKeyResponse._();
  @$core.override
  Secp256k1SecretKeyToPublicKeyResponse createEmptyInstance() => Secp256k1SecretKeyToPublicKeyResponse._();
  @$core.pragma('dart2js:noInline')
  static Secp256k1SecretKeyToPublicKeyResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Secp256k1SecretKeyToPublicKeyResponse>(
          Secp256k1SecretKeyToPublicKeyResponse.$_createMessage);
  static Secp256k1SecretKeyToPublicKeyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.ConsensusHex get publicKey => $_getN(0);
  @$pb.TagNumber(1)
  set publicKey($0.ConsensusHex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPublicKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearPublicKey() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ConsensusHex ensurePublicKey() => $_ensure(0);
}

class Secp256k1SignRequest extends $pb.GeneratedMessage {
  factory Secp256k1SignRequest({
    $0.Hex? message,
    $0.ConsensusHex? secretKey,
  }) {
    final result = Secp256k1SignRequest._();
    if (message != null) result.message = message;
    if (secretKey != null) result.secretKey = secretKey;
    return result;
  }

  Secp256k1SignRequest._();

  factory Secp256k1SignRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Secp256k1SignRequest()..mergeFromBuffer(data, registry);
  factory Secp256k1SignRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Secp256k1SignRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Secp256k1SignRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'),
      createEmptyInstance: Secp256k1SignRequest.$_createMessage)
    ..aOM<$0.Hex>(1, _omitFieldNames ? '' : 'message', subBuilder: $0.Hex.$_createMessage)
    ..aOM<$0.ConsensusHex>(2, _omitFieldNames ? '' : 'secretKey', subBuilder: $0.ConsensusHex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secp256k1SignRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secp256k1SignRequest copyWith(void Function(Secp256k1SignRequest) updates) =>
      super.copyWith((message) => updates(message as Secp256k1SignRequest)) as Secp256k1SignRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Secp256k1SignRequest() / Secp256k1SignRequest.new instead')
  static Secp256k1SignRequest create() => Secp256k1SignRequest._();
  static $pb.GeneratedMessage $_createMessage() => Secp256k1SignRequest._();
  @$core.override
  Secp256k1SignRequest createEmptyInstance() => Secp256k1SignRequest._();
  @$core.pragma('dart2js:noInline')
  static Secp256k1SignRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Secp256k1SignRequest>(Secp256k1SignRequest.$_createMessage);
  static Secp256k1SignRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Hex get message => $_getN(0);
  @$pb.TagNumber(1)
  set message($0.Hex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Hex ensureMessage() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.ConsensusHex get secretKey => $_getN(1);
  @$pb.TagNumber(2)
  set secretKey($0.ConsensusHex value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSecretKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearSecretKey() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.ConsensusHex ensureSecretKey() => $_ensure(1);
}

class Secp256k1SignResponse extends $pb.GeneratedMessage {
  factory Secp256k1SignResponse({
    $0.Hex? signature,
  }) {
    final result = Secp256k1SignResponse._();
    if (signature != null) result.signature = signature;
    return result;
  }

  Secp256k1SignResponse._();

  factory Secp256k1SignResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Secp256k1SignResponse()..mergeFromBuffer(data, registry);
  factory Secp256k1SignResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Secp256k1SignResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Secp256k1SignResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'),
      createEmptyInstance: Secp256k1SignResponse.$_createMessage)
    ..aOM<$0.Hex>(1, _omitFieldNames ? '' : 'signature', subBuilder: $0.Hex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secp256k1SignResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secp256k1SignResponse copyWith(void Function(Secp256k1SignResponse) updates) =>
      super.copyWith((message) => updates(message as Secp256k1SignResponse)) as Secp256k1SignResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Secp256k1SignResponse() / Secp256k1SignResponse.new instead')
  static Secp256k1SignResponse create() => Secp256k1SignResponse._();
  static $pb.GeneratedMessage $_createMessage() => Secp256k1SignResponse._();
  @$core.override
  Secp256k1SignResponse createEmptyInstance() => Secp256k1SignResponse._();
  @$core.pragma('dart2js:noInline')
  static Secp256k1SignResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Secp256k1SignResponse>(Secp256k1SignResponse.$_createMessage);
  static Secp256k1SignResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Hex get signature => $_getN(0);
  @$pb.TagNumber(1)
  set signature($0.Hex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSignature() => $_has(0);
  @$pb.TagNumber(1)
  void clearSignature() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Hex ensureSignature() => $_ensure(0);
}

class Secp256k1VerifyRequest extends $pb.GeneratedMessage {
  factory Secp256k1VerifyRequest({
    $0.Hex? message,
    $0.Hex? signature,
    $0.ConsensusHex? publicKey,
  }) {
    final result = Secp256k1VerifyRequest._();
    if (message != null) result.message = message;
    if (signature != null) result.signature = signature;
    if (publicKey != null) result.publicKey = publicKey;
    return result;
  }

  Secp256k1VerifyRequest._();

  factory Secp256k1VerifyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Secp256k1VerifyRequest()..mergeFromBuffer(data, registry);
  factory Secp256k1VerifyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Secp256k1VerifyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Secp256k1VerifyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'),
      createEmptyInstance: Secp256k1VerifyRequest.$_createMessage)
    ..aOM<$0.Hex>(1, _omitFieldNames ? '' : 'message', subBuilder: $0.Hex.$_createMessage)
    ..aOM<$0.Hex>(2, _omitFieldNames ? '' : 'signature', subBuilder: $0.Hex.$_createMessage)
    ..aOM<$0.ConsensusHex>(3, _omitFieldNames ? '' : 'publicKey', subBuilder: $0.ConsensusHex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secp256k1VerifyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secp256k1VerifyRequest copyWith(void Function(Secp256k1VerifyRequest) updates) =>
      super.copyWith((message) => updates(message as Secp256k1VerifyRequest)) as Secp256k1VerifyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Secp256k1VerifyRequest() / Secp256k1VerifyRequest.new instead')
  static Secp256k1VerifyRequest create() => Secp256k1VerifyRequest._();
  static $pb.GeneratedMessage $_createMessage() => Secp256k1VerifyRequest._();
  @$core.override
  Secp256k1VerifyRequest createEmptyInstance() => Secp256k1VerifyRequest._();
  @$core.pragma('dart2js:noInline')
  static Secp256k1VerifyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Secp256k1VerifyRequest>(Secp256k1VerifyRequest.$_createMessage);
  static Secp256k1VerifyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Hex get message => $_getN(0);
  @$pb.TagNumber(1)
  set message($0.Hex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Hex ensureMessage() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.Hex get signature => $_getN(1);
  @$pb.TagNumber(2)
  set signature($0.Hex value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Hex ensureSignature() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.ConsensusHex get publicKey => $_getN(2);
  @$pb.TagNumber(3)
  set publicKey($0.ConsensusHex value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPublicKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearPublicKey() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.ConsensusHex ensurePublicKey() => $_ensure(2);
}

class Secp256k1VerifyResponse extends $pb.GeneratedMessage {
  factory Secp256k1VerifyResponse({
    $core.bool? valid,
  }) {
    final result = Secp256k1VerifyResponse._();
    if (valid != null) result.valid = valid;
    return result;
  }

  Secp256k1VerifyResponse._();

  factory Secp256k1VerifyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Secp256k1VerifyResponse()..mergeFromBuffer(data, registry);
  factory Secp256k1VerifyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Secp256k1VerifyResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Secp256k1VerifyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.crypto.v1'),
      createEmptyInstance: Secp256k1VerifyResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secp256k1VerifyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secp256k1VerifyResponse copyWith(void Function(Secp256k1VerifyResponse) updates) =>
      super.copyWith((message) => updates(message as Secp256k1VerifyResponse)) as Secp256k1VerifyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Secp256k1VerifyResponse() / Secp256k1VerifyResponse.new instead')
  static Secp256k1VerifyResponse create() => Secp256k1VerifyResponse._();
  static $pb.GeneratedMessage $_createMessage() => Secp256k1VerifyResponse._();
  @$core.override
  Secp256k1VerifyResponse createEmptyInstance() => Secp256k1VerifyResponse._();
  @$core.pragma('dart2js:noInline')
  static Secp256k1VerifyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Secp256k1VerifyResponse>(Secp256k1VerifyResponse.$_createMessage);
  static Secp256k1VerifyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => $_clearField(1);
}

class CryptoServiceApi {
  final $pb.RpcClient _client;

  CryptoServiceApi(this._client);

  $async.Future<HmacSha512Response> hmacSha512($pb.ClientContext? ctx, HmacSha512Request request) =>
      _client.invoke<HmacSha512Response>(ctx, 'CryptoService', 'HmacSha512', request, HmacSha512Response());
  $async.Future<Ripemd160Response> ripemd160($pb.ClientContext? ctx, Ripemd160Request request) =>
      _client.invoke<Ripemd160Response>(ctx, 'CryptoService', 'Ripemd160', request, Ripemd160Response());
  $async.Future<Secp256k1SecretKeyToPublicKeyResponse> secp256k1SecretKeyToPublicKey(
          $pb.ClientContext? ctx, Secp256k1SecretKeyToPublicKeyRequest request) =>
      _client.invoke<Secp256k1SecretKeyToPublicKeyResponse>(
          ctx, 'CryptoService', 'Secp256k1SecretKeyToPublicKey', request, Secp256k1SecretKeyToPublicKeyResponse());
  $async.Future<Secp256k1SignResponse> secp256k1Sign($pb.ClientContext? ctx, Secp256k1SignRequest request) =>
      _client.invoke<Secp256k1SignResponse>(ctx, 'CryptoService', 'Secp256k1Sign', request, Secp256k1SignResponse());
  $async.Future<Secp256k1VerifyResponse> secp256k1Verify($pb.ClientContext? ctx, Secp256k1VerifyRequest request) =>
      _client.invoke<Secp256k1VerifyResponse>(
          ctx, 'CryptoService', 'Secp256k1Verify', request, Secp256k1VerifyResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
