//
//  Generated code. Do not modify.
//  source: walletmanager/v1/walletmanager.proto
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

import '../../google/protobuf/empty.pb.dart' as $12;

class GetWalletStatusRequest extends $pb.GeneratedMessage {
  factory GetWalletStatusRequest() => create();
  GetWalletStatusRequest._() : super();
  factory GetWalletStatusRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWalletStatusRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletStatusRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWalletStatusRequest clone() => GetWalletStatusRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWalletStatusRequest copyWith(void Function(GetWalletStatusRequest) updates) => super.copyWith((message) => updates(message as GetWalletStatusRequest)) as GetWalletStatusRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWalletStatusRequest create() => GetWalletStatusRequest._();
  GetWalletStatusRequest createEmptyInstance() => create();
  static $pb.PbList<GetWalletStatusRequest> createRepeated() => $pb.PbList<GetWalletStatusRequest>();
  @$core.pragma('dart2js:noInline')
  static GetWalletStatusRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWalletStatusRequest>(create);
  static GetWalletStatusRequest? _defaultInstance;
}

class GetWalletStatusResponse extends $pb.GeneratedMessage {
  factory GetWalletStatusResponse({
    $core.bool? hasWallet,
    $core.bool? encrypted,
    $core.bool? unlocked,
    $core.String? activeWalletId,
    $core.String? activeWalletName,
  }) {
    final $result = create();
    if (hasWallet != null) {
      $result.hasWallet = hasWallet;
    }
    if (encrypted != null) {
      $result.encrypted = encrypted;
    }
    if (unlocked != null) {
      $result.unlocked = unlocked;
    }
    if (activeWalletId != null) {
      $result.activeWalletId = activeWalletId;
    }
    if (activeWalletName != null) {
      $result.activeWalletName = activeWalletName;
    }
    return $result;
  }
  GetWalletStatusResponse._() : super();
  factory GetWalletStatusResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWalletStatusResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletStatusResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'hasWallet')
    ..aOB(2, _omitFieldNames ? '' : 'encrypted')
    ..aOB(3, _omitFieldNames ? '' : 'unlocked')
    ..aOS(4, _omitFieldNames ? '' : 'activeWalletId')
    ..aOS(5, _omitFieldNames ? '' : 'activeWalletName')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWalletStatusResponse clone() => GetWalletStatusResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWalletStatusResponse copyWith(void Function(GetWalletStatusResponse) updates) => super.copyWith((message) => updates(message as GetWalletStatusResponse)) as GetWalletStatusResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWalletStatusResponse create() => GetWalletStatusResponse._();
  GetWalletStatusResponse createEmptyInstance() => create();
  static $pb.PbList<GetWalletStatusResponse> createRepeated() => $pb.PbList<GetWalletStatusResponse>();
  @$core.pragma('dart2js:noInline')
  static GetWalletStatusResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWalletStatusResponse>(create);
  static GetWalletStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get hasWallet => $_getBF(0);
  @$pb.TagNumber(1)
  set hasWallet($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearHasWallet() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get encrypted => $_getBF(1);
  @$pb.TagNumber(2)
  set encrypted($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEncrypted() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncrypted() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get unlocked => $_getBF(2);
  @$pb.TagNumber(3)
  set unlocked($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUnlocked() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnlocked() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get activeWalletId => $_getSZ(3);
  @$pb.TagNumber(4)
  set activeWalletId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasActiveWalletId() => $_has(3);
  @$pb.TagNumber(4)
  void clearActiveWalletId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get activeWalletName => $_getSZ(4);
  @$pb.TagNumber(5)
  set activeWalletName($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasActiveWalletName() => $_has(4);
  @$pb.TagNumber(5)
  void clearActiveWalletName() => clearField(5);
}

class GenerateWalletRequest extends $pb.GeneratedMessage {
  factory GenerateWalletRequest({
    $core.String? name,
    $core.String? customMnemonic,
    $core.String? passphrase,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (customMnemonic != null) {
      $result.customMnemonic = customMnemonic;
    }
    if (passphrase != null) {
      $result.passphrase = passphrase;
    }
    return $result;
  }
  GenerateWalletRequest._() : super();
  factory GenerateWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GenerateWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'customMnemonic')
    ..aOS(3, _omitFieldNames ? '' : 'passphrase')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GenerateWalletRequest clone() => GenerateWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GenerateWalletRequest copyWith(void Function(GenerateWalletRequest) updates) => super.copyWith((message) => updates(message as GenerateWalletRequest)) as GenerateWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateWalletRequest create() => GenerateWalletRequest._();
  GenerateWalletRequest createEmptyInstance() => create();
  static $pb.PbList<GenerateWalletRequest> createRepeated() => $pb.PbList<GenerateWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static GenerateWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GenerateWalletRequest>(create);
  static GenerateWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get customMnemonic => $_getSZ(1);
  @$pb.TagNumber(2)
  set customMnemonic($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCustomMnemonic() => $_has(1);
  @$pb.TagNumber(2)
  void clearCustomMnemonic() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get passphrase => $_getSZ(2);
  @$pb.TagNumber(3)
  set passphrase($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPassphrase() => $_has(2);
  @$pb.TagNumber(3)
  void clearPassphrase() => clearField(3);
}

class GenerateWalletResponse extends $pb.GeneratedMessage {
  factory GenerateWalletResponse({
    $core.String? walletId,
    $core.String? mnemonic,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (mnemonic != null) {
      $result.mnemonic = mnemonic;
    }
    return $result;
  }
  GenerateWalletResponse._() : super();
  factory GenerateWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GenerateWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'mnemonic')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GenerateWalletResponse clone() => GenerateWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GenerateWalletResponse copyWith(void Function(GenerateWalletResponse) updates) => super.copyWith((message) => updates(message as GenerateWalletResponse)) as GenerateWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateWalletResponse create() => GenerateWalletResponse._();
  GenerateWalletResponse createEmptyInstance() => create();
  static $pb.PbList<GenerateWalletResponse> createRepeated() => $pb.PbList<GenerateWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static GenerateWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GenerateWalletResponse>(create);
  static GenerateWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get mnemonic => $_getSZ(1);
  @$pb.TagNumber(2)
  set mnemonic($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMnemonic() => $_has(1);
  @$pb.TagNumber(2)
  void clearMnemonic() => clearField(2);
}

class UnlockWalletRequest extends $pb.GeneratedMessage {
  factory UnlockWalletRequest({
    $core.String? password,
  }) {
    final $result = create();
    if (password != null) {
      $result.password = password;
    }
    return $result;
  }
  UnlockWalletRequest._() : super();
  factory UnlockWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnlockWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnlockWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnlockWalletRequest clone() => UnlockWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnlockWalletRequest copyWith(void Function(UnlockWalletRequest) updates) => super.copyWith((message) => updates(message as UnlockWalletRequest)) as UnlockWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnlockWalletRequest create() => UnlockWalletRequest._();
  UnlockWalletRequest createEmptyInstance() => create();
  static $pb.PbList<UnlockWalletRequest> createRepeated() => $pb.PbList<UnlockWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static UnlockWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnlockWalletRequest>(create);
  static UnlockWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get password => $_getSZ(0);
  @$pb.TagNumber(1)
  set password($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPassword() => $_has(0);
  @$pb.TagNumber(1)
  void clearPassword() => clearField(1);
}

class UnlockWalletResponse extends $pb.GeneratedMessage {
  factory UnlockWalletResponse() => create();
  UnlockWalletResponse._() : super();
  factory UnlockWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnlockWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnlockWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnlockWalletResponse clone() => UnlockWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnlockWalletResponse copyWith(void Function(UnlockWalletResponse) updates) => super.copyWith((message) => updates(message as UnlockWalletResponse)) as UnlockWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnlockWalletResponse create() => UnlockWalletResponse._();
  UnlockWalletResponse createEmptyInstance() => create();
  static $pb.PbList<UnlockWalletResponse> createRepeated() => $pb.PbList<UnlockWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static UnlockWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnlockWalletResponse>(create);
  static UnlockWalletResponse? _defaultInstance;
}

class LockWalletRequest extends $pb.GeneratedMessage {
  factory LockWalletRequest() => create();
  LockWalletRequest._() : super();
  factory LockWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LockWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LockWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LockWalletRequest clone() => LockWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LockWalletRequest copyWith(void Function(LockWalletRequest) updates) => super.copyWith((message) => updates(message as LockWalletRequest)) as LockWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LockWalletRequest create() => LockWalletRequest._();
  LockWalletRequest createEmptyInstance() => create();
  static $pb.PbList<LockWalletRequest> createRepeated() => $pb.PbList<LockWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static LockWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LockWalletRequest>(create);
  static LockWalletRequest? _defaultInstance;
}

class LockWalletResponse extends $pb.GeneratedMessage {
  factory LockWalletResponse() => create();
  LockWalletResponse._() : super();
  factory LockWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LockWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LockWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LockWalletResponse clone() => LockWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LockWalletResponse copyWith(void Function(LockWalletResponse) updates) => super.copyWith((message) => updates(message as LockWalletResponse)) as LockWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LockWalletResponse create() => LockWalletResponse._();
  LockWalletResponse createEmptyInstance() => create();
  static $pb.PbList<LockWalletResponse> createRepeated() => $pb.PbList<LockWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static LockWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LockWalletResponse>(create);
  static LockWalletResponse? _defaultInstance;
}

class EncryptWalletRequest extends $pb.GeneratedMessage {
  factory EncryptWalletRequest({
    $core.String? password,
  }) {
    final $result = create();
    if (password != null) {
      $result.password = password;
    }
    return $result;
  }
  EncryptWalletRequest._() : super();
  factory EncryptWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EncryptWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncryptWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EncryptWalletRequest clone() => EncryptWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EncryptWalletRequest copyWith(void Function(EncryptWalletRequest) updates) => super.copyWith((message) => updates(message as EncryptWalletRequest)) as EncryptWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncryptWalletRequest create() => EncryptWalletRequest._();
  EncryptWalletRequest createEmptyInstance() => create();
  static $pb.PbList<EncryptWalletRequest> createRepeated() => $pb.PbList<EncryptWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static EncryptWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EncryptWalletRequest>(create);
  static EncryptWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get password => $_getSZ(0);
  @$pb.TagNumber(1)
  set password($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPassword() => $_has(0);
  @$pb.TagNumber(1)
  void clearPassword() => clearField(1);
}

class EncryptWalletResponse extends $pb.GeneratedMessage {
  factory EncryptWalletResponse() => create();
  EncryptWalletResponse._() : super();
  factory EncryptWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EncryptWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncryptWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EncryptWalletResponse clone() => EncryptWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EncryptWalletResponse copyWith(void Function(EncryptWalletResponse) updates) => super.copyWith((message) => updates(message as EncryptWalletResponse)) as EncryptWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncryptWalletResponse create() => EncryptWalletResponse._();
  EncryptWalletResponse createEmptyInstance() => create();
  static $pb.PbList<EncryptWalletResponse> createRepeated() => $pb.PbList<EncryptWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static EncryptWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EncryptWalletResponse>(create);
  static EncryptWalletResponse? _defaultInstance;
}

class ChangePasswordRequest extends $pb.GeneratedMessage {
  factory ChangePasswordRequest({
    $core.String? oldPassword,
    $core.String? newPassword,
  }) {
    final $result = create();
    if (oldPassword != null) {
      $result.oldPassword = oldPassword;
    }
    if (newPassword != null) {
      $result.newPassword = newPassword;
    }
    return $result;
  }
  ChangePasswordRequest._() : super();
  factory ChangePasswordRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChangePasswordRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangePasswordRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'oldPassword')
    ..aOS(2, _omitFieldNames ? '' : 'newPassword')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChangePasswordRequest clone() => ChangePasswordRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChangePasswordRequest copyWith(void Function(ChangePasswordRequest) updates) => super.copyWith((message) => updates(message as ChangePasswordRequest)) as ChangePasswordRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangePasswordRequest create() => ChangePasswordRequest._();
  ChangePasswordRequest createEmptyInstance() => create();
  static $pb.PbList<ChangePasswordRequest> createRepeated() => $pb.PbList<ChangePasswordRequest>();
  @$core.pragma('dart2js:noInline')
  static ChangePasswordRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangePasswordRequest>(create);
  static ChangePasswordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get oldPassword => $_getSZ(0);
  @$pb.TagNumber(1)
  set oldPassword($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOldPassword() => $_has(0);
  @$pb.TagNumber(1)
  void clearOldPassword() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get newPassword => $_getSZ(1);
  @$pb.TagNumber(2)
  set newPassword($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNewPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewPassword() => clearField(2);
}

class ChangePasswordResponse extends $pb.GeneratedMessage {
  factory ChangePasswordResponse() => create();
  ChangePasswordResponse._() : super();
  factory ChangePasswordResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChangePasswordResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangePasswordResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChangePasswordResponse clone() => ChangePasswordResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChangePasswordResponse copyWith(void Function(ChangePasswordResponse) updates) => super.copyWith((message) => updates(message as ChangePasswordResponse)) as ChangePasswordResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangePasswordResponse create() => ChangePasswordResponse._();
  ChangePasswordResponse createEmptyInstance() => create();
  static $pb.PbList<ChangePasswordResponse> createRepeated() => $pb.PbList<ChangePasswordResponse>();
  @$core.pragma('dart2js:noInline')
  static ChangePasswordResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangePasswordResponse>(create);
  static ChangePasswordResponse? _defaultInstance;
}

class RemoveEncryptionRequest extends $pb.GeneratedMessage {
  factory RemoveEncryptionRequest({
    $core.String? password,
  }) {
    final $result = create();
    if (password != null) {
      $result.password = password;
    }
    return $result;
  }
  RemoveEncryptionRequest._() : super();
  factory RemoveEncryptionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RemoveEncryptionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveEncryptionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RemoveEncryptionRequest clone() => RemoveEncryptionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RemoveEncryptionRequest copyWith(void Function(RemoveEncryptionRequest) updates) => super.copyWith((message) => updates(message as RemoveEncryptionRequest)) as RemoveEncryptionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveEncryptionRequest create() => RemoveEncryptionRequest._();
  RemoveEncryptionRequest createEmptyInstance() => create();
  static $pb.PbList<RemoveEncryptionRequest> createRepeated() => $pb.PbList<RemoveEncryptionRequest>();
  @$core.pragma('dart2js:noInline')
  static RemoveEncryptionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RemoveEncryptionRequest>(create);
  static RemoveEncryptionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get password => $_getSZ(0);
  @$pb.TagNumber(1)
  set password($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPassword() => $_has(0);
  @$pb.TagNumber(1)
  void clearPassword() => clearField(1);
}

class RemoveEncryptionResponse extends $pb.GeneratedMessage {
  factory RemoveEncryptionResponse() => create();
  RemoveEncryptionResponse._() : super();
  factory RemoveEncryptionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RemoveEncryptionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveEncryptionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RemoveEncryptionResponse clone() => RemoveEncryptionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RemoveEncryptionResponse copyWith(void Function(RemoveEncryptionResponse) updates) => super.copyWith((message) => updates(message as RemoveEncryptionResponse)) as RemoveEncryptionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveEncryptionResponse create() => RemoveEncryptionResponse._();
  RemoveEncryptionResponse createEmptyInstance() => create();
  static $pb.PbList<RemoveEncryptionResponse> createRepeated() => $pb.PbList<RemoveEncryptionResponse>();
  @$core.pragma('dart2js:noInline')
  static RemoveEncryptionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RemoveEncryptionResponse>(create);
  static RemoveEncryptionResponse? _defaultInstance;
}

class WalletMetadata extends $pb.GeneratedMessage {
  factory WalletMetadata({
    $core.String? id,
    $core.String? name,
    $core.String? walletType,
    $core.String? gradientJson,
    $core.String? createdAt,
    $core.String? bip47PaymentCode,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (walletType != null) {
      $result.walletType = walletType;
    }
    if (gradientJson != null) {
      $result.gradientJson = gradientJson;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (bip47PaymentCode != null) {
      $result.bip47PaymentCode = bip47PaymentCode;
    }
    return $result;
  }
  WalletMetadata._() : super();
  factory WalletMetadata.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WalletMetadata.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WalletMetadata', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'walletType')
    ..aOS(4, _omitFieldNames ? '' : 'gradientJson')
    ..aOS(5, _omitFieldNames ? '' : 'createdAt')
    ..aOS(6, _omitFieldNames ? '' : 'bip47PaymentCode')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WalletMetadata clone() => WalletMetadata()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WalletMetadata copyWith(void Function(WalletMetadata) updates) => super.copyWith((message) => updates(message as WalletMetadata)) as WalletMetadata;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WalletMetadata create() => WalletMetadata._();
  WalletMetadata createEmptyInstance() => create();
  static $pb.PbList<WalletMetadata> createRepeated() => $pb.PbList<WalletMetadata>();
  @$core.pragma('dart2js:noInline')
  static WalletMetadata getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WalletMetadata>(create);
  static WalletMetadata? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get walletType => $_getSZ(2);
  @$pb.TagNumber(3)
  set walletType($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWalletType() => $_has(2);
  @$pb.TagNumber(3)
  void clearWalletType() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get gradientJson => $_getSZ(3);
  @$pb.TagNumber(4)
  set gradientJson($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasGradientJson() => $_has(3);
  @$pb.TagNumber(4)
  void clearGradientJson() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get createdAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set createdAt($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => clearField(5);

  /// BIP47 v3 payment code derived from the wallet's master pubkey.
  /// Deterministic per wallet, never changes. Empty for watch-only wallets.
  @$pb.TagNumber(6)
  $core.String get bip47PaymentCode => $_getSZ(5);
  @$pb.TagNumber(6)
  set bip47PaymentCode($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasBip47PaymentCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearBip47PaymentCode() => clearField(6);
}

class ListWalletsRequest extends $pb.GeneratedMessage {
  factory ListWalletsRequest() => create();
  ListWalletsRequest._() : super();
  factory ListWalletsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListWalletsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListWalletsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListWalletsRequest clone() => ListWalletsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListWalletsRequest copyWith(void Function(ListWalletsRequest) updates) => super.copyWith((message) => updates(message as ListWalletsRequest)) as ListWalletsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListWalletsRequest create() => ListWalletsRequest._();
  ListWalletsRequest createEmptyInstance() => create();
  static $pb.PbList<ListWalletsRequest> createRepeated() => $pb.PbList<ListWalletsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListWalletsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListWalletsRequest>(create);
  static ListWalletsRequest? _defaultInstance;
}

class ListWalletsResponse extends $pb.GeneratedMessage {
  factory ListWalletsResponse({
    $core.Iterable<WalletMetadata>? wallets,
    $core.String? activeWalletId,
  }) {
    final $result = create();
    if (wallets != null) {
      $result.wallets.addAll(wallets);
    }
    if (activeWalletId != null) {
      $result.activeWalletId = activeWalletId;
    }
    return $result;
  }
  ListWalletsResponse._() : super();
  factory ListWalletsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListWalletsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListWalletsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..pc<WalletMetadata>(1, _omitFieldNames ? '' : 'wallets', $pb.PbFieldType.PM, subBuilder: WalletMetadata.create)
    ..aOS(2, _omitFieldNames ? '' : 'activeWalletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListWalletsResponse clone() => ListWalletsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListWalletsResponse copyWith(void Function(ListWalletsResponse) updates) => super.copyWith((message) => updates(message as ListWalletsResponse)) as ListWalletsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListWalletsResponse create() => ListWalletsResponse._();
  ListWalletsResponse createEmptyInstance() => create();
  static $pb.PbList<ListWalletsResponse> createRepeated() => $pb.PbList<ListWalletsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListWalletsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListWalletsResponse>(create);
  static ListWalletsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<WalletMetadata> get wallets => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get activeWalletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set activeWalletId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasActiveWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearActiveWalletId() => clearField(2);
}

class SwitchWalletRequest extends $pb.GeneratedMessage {
  factory SwitchWalletRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  SwitchWalletRequest._() : super();
  factory SwitchWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SwitchWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SwitchWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SwitchWalletRequest clone() => SwitchWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SwitchWalletRequest copyWith(void Function(SwitchWalletRequest) updates) => super.copyWith((message) => updates(message as SwitchWalletRequest)) as SwitchWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SwitchWalletRequest create() => SwitchWalletRequest._();
  SwitchWalletRequest createEmptyInstance() => create();
  static $pb.PbList<SwitchWalletRequest> createRepeated() => $pb.PbList<SwitchWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static SwitchWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SwitchWalletRequest>(create);
  static SwitchWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class SwitchWalletResponse extends $pb.GeneratedMessage {
  factory SwitchWalletResponse() => create();
  SwitchWalletResponse._() : super();
  factory SwitchWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SwitchWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SwitchWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SwitchWalletResponse clone() => SwitchWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SwitchWalletResponse copyWith(void Function(SwitchWalletResponse) updates) => super.copyWith((message) => updates(message as SwitchWalletResponse)) as SwitchWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SwitchWalletResponse create() => SwitchWalletResponse._();
  SwitchWalletResponse createEmptyInstance() => create();
  static $pb.PbList<SwitchWalletResponse> createRepeated() => $pb.PbList<SwitchWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static SwitchWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SwitchWalletResponse>(create);
  static SwitchWalletResponse? _defaultInstance;
}

class UpdateWalletMetadataRequest extends $pb.GeneratedMessage {
  factory UpdateWalletMetadataRequest({
    $core.String? walletId,
    $core.String? name,
    $core.String? gradientJson,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (gradientJson != null) {
      $result.gradientJson = gradientJson;
    }
    return $result;
  }
  UpdateWalletMetadataRequest._() : super();
  factory UpdateWalletMetadataRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateWalletMetadataRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateWalletMetadataRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'gradientJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateWalletMetadataRequest clone() => UpdateWalletMetadataRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateWalletMetadataRequest copyWith(void Function(UpdateWalletMetadataRequest) updates) => super.copyWith((message) => updates(message as UpdateWalletMetadataRequest)) as UpdateWalletMetadataRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateWalletMetadataRequest create() => UpdateWalletMetadataRequest._();
  UpdateWalletMetadataRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateWalletMetadataRequest> createRepeated() => $pb.PbList<UpdateWalletMetadataRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateWalletMetadataRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateWalletMetadataRequest>(create);
  static UpdateWalletMetadataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get gradientJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set gradientJson($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasGradientJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearGradientJson() => clearField(3);
}

class UpdateWalletMetadataResponse extends $pb.GeneratedMessage {
  factory UpdateWalletMetadataResponse() => create();
  UpdateWalletMetadataResponse._() : super();
  factory UpdateWalletMetadataResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateWalletMetadataResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateWalletMetadataResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateWalletMetadataResponse clone() => UpdateWalletMetadataResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateWalletMetadataResponse copyWith(void Function(UpdateWalletMetadataResponse) updates) => super.copyWith((message) => updates(message as UpdateWalletMetadataResponse)) as UpdateWalletMetadataResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateWalletMetadataResponse create() => UpdateWalletMetadataResponse._();
  UpdateWalletMetadataResponse createEmptyInstance() => create();
  static $pb.PbList<UpdateWalletMetadataResponse> createRepeated() => $pb.PbList<UpdateWalletMetadataResponse>();
  @$core.pragma('dart2js:noInline')
  static UpdateWalletMetadataResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateWalletMetadataResponse>(create);
  static UpdateWalletMetadataResponse? _defaultInstance;
}

class DeleteWalletRequest extends $pb.GeneratedMessage {
  factory DeleteWalletRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  DeleteWalletRequest._() : super();
  factory DeleteWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteWalletRequest clone() => DeleteWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteWalletRequest copyWith(void Function(DeleteWalletRequest) updates) => super.copyWith((message) => updates(message as DeleteWalletRequest)) as DeleteWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteWalletRequest create() => DeleteWalletRequest._();
  DeleteWalletRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteWalletRequest> createRepeated() => $pb.PbList<DeleteWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteWalletRequest>(create);
  static DeleteWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class DeleteWalletResponse extends $pb.GeneratedMessage {
  factory DeleteWalletResponse() => create();
  DeleteWalletResponse._() : super();
  factory DeleteWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteWalletResponse clone() => DeleteWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteWalletResponse copyWith(void Function(DeleteWalletResponse) updates) => super.copyWith((message) => updates(message as DeleteWalletResponse)) as DeleteWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteWalletResponse create() => DeleteWalletResponse._();
  DeleteWalletResponse createEmptyInstance() => create();
  static $pb.PbList<DeleteWalletResponse> createRepeated() => $pb.PbList<DeleteWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static DeleteWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteWalletResponse>(create);
  static DeleteWalletResponse? _defaultInstance;
}

class DeleteAllWalletsRequest extends $pb.GeneratedMessage {
  factory DeleteAllWalletsRequest() => create();
  DeleteAllWalletsRequest._() : super();
  factory DeleteAllWalletsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteAllWalletsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteAllWalletsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteAllWalletsRequest clone() => DeleteAllWalletsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteAllWalletsRequest copyWith(void Function(DeleteAllWalletsRequest) updates) => super.copyWith((message) => updates(message as DeleteAllWalletsRequest)) as DeleteAllWalletsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteAllWalletsRequest create() => DeleteAllWalletsRequest._();
  DeleteAllWalletsRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteAllWalletsRequest> createRepeated() => $pb.PbList<DeleteAllWalletsRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteAllWalletsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteAllWalletsRequest>(create);
  static DeleteAllWalletsRequest? _defaultInstance;
}

class DeleteAllWalletsResponse extends $pb.GeneratedMessage {
  factory DeleteAllWalletsResponse() => create();
  DeleteAllWalletsResponse._() : super();
  factory DeleteAllWalletsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteAllWalletsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteAllWalletsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteAllWalletsResponse clone() => DeleteAllWalletsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteAllWalletsResponse copyWith(void Function(DeleteAllWalletsResponse) updates) => super.copyWith((message) => updates(message as DeleteAllWalletsResponse)) as DeleteAllWalletsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteAllWalletsResponse create() => DeleteAllWalletsResponse._();
  DeleteAllWalletsResponse createEmptyInstance() => create();
  static $pb.PbList<DeleteAllWalletsResponse> createRepeated() => $pb.PbList<DeleteAllWalletsResponse>();
  @$core.pragma('dart2js:noInline')
  static DeleteAllWalletsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteAllWalletsResponse>(create);
  static DeleteAllWalletsResponse? _defaultInstance;
}

class CreateWatchOnlyWalletRequest extends $pb.GeneratedMessage {
  factory CreateWatchOnlyWalletRequest({
    $core.String? name,
    $core.String? xpubOrDescriptor,
    $core.String? gradientJson,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (xpubOrDescriptor != null) {
      $result.xpubOrDescriptor = xpubOrDescriptor;
    }
    if (gradientJson != null) {
      $result.gradientJson = gradientJson;
    }
    return $result;
  }
  CreateWatchOnlyWalletRequest._() : super();
  factory CreateWatchOnlyWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateWatchOnlyWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateWatchOnlyWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'xpubOrDescriptor')
    ..aOS(3, _omitFieldNames ? '' : 'gradientJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateWatchOnlyWalletRequest clone() => CreateWatchOnlyWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateWatchOnlyWalletRequest copyWith(void Function(CreateWatchOnlyWalletRequest) updates) => super.copyWith((message) => updates(message as CreateWatchOnlyWalletRequest)) as CreateWatchOnlyWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateWatchOnlyWalletRequest create() => CreateWatchOnlyWalletRequest._();
  CreateWatchOnlyWalletRequest createEmptyInstance() => create();
  static $pb.PbList<CreateWatchOnlyWalletRequest> createRepeated() => $pb.PbList<CreateWatchOnlyWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateWatchOnlyWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateWatchOnlyWalletRequest>(create);
  static CreateWatchOnlyWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get xpubOrDescriptor => $_getSZ(1);
  @$pb.TagNumber(2)
  set xpubOrDescriptor($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasXpubOrDescriptor() => $_has(1);
  @$pb.TagNumber(2)
  void clearXpubOrDescriptor() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get gradientJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set gradientJson($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasGradientJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearGradientJson() => clearField(3);
}

class CreateWatchOnlyWalletResponse extends $pb.GeneratedMessage {
  factory CreateWatchOnlyWalletResponse({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  CreateWatchOnlyWalletResponse._() : super();
  factory CreateWatchOnlyWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateWatchOnlyWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateWatchOnlyWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateWatchOnlyWalletResponse clone() => CreateWatchOnlyWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateWatchOnlyWalletResponse copyWith(void Function(CreateWatchOnlyWalletResponse) updates) => super.copyWith((message) => updates(message as CreateWatchOnlyWalletResponse)) as CreateWatchOnlyWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateWatchOnlyWalletResponse create() => CreateWatchOnlyWalletResponse._();
  CreateWatchOnlyWalletResponse createEmptyInstance() => create();
  static $pb.PbList<CreateWatchOnlyWalletResponse> createRepeated() => $pb.PbList<CreateWatchOnlyWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateWatchOnlyWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateWatchOnlyWalletResponse>(create);
  static CreateWatchOnlyWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class CreateBitcoinCoreWalletRequest extends $pb.GeneratedMessage {
  factory CreateBitcoinCoreWalletRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  CreateBitcoinCoreWalletRequest._() : super();
  factory CreateBitcoinCoreWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateBitcoinCoreWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateBitcoinCoreWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateBitcoinCoreWalletRequest clone() => CreateBitcoinCoreWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateBitcoinCoreWalletRequest copyWith(void Function(CreateBitcoinCoreWalletRequest) updates) => super.copyWith((message) => updates(message as CreateBitcoinCoreWalletRequest)) as CreateBitcoinCoreWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateBitcoinCoreWalletRequest create() => CreateBitcoinCoreWalletRequest._();
  CreateBitcoinCoreWalletRequest createEmptyInstance() => create();
  static $pb.PbList<CreateBitcoinCoreWalletRequest> createRepeated() => $pb.PbList<CreateBitcoinCoreWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateBitcoinCoreWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateBitcoinCoreWalletRequest>(create);
  static CreateBitcoinCoreWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class CreateBitcoinCoreWalletResponse extends $pb.GeneratedMessage {
  factory CreateBitcoinCoreWalletResponse({
    $core.String? coreWalletName,
  }) {
    final $result = create();
    if (coreWalletName != null) {
      $result.coreWalletName = coreWalletName;
    }
    return $result;
  }
  CreateBitcoinCoreWalletResponse._() : super();
  factory CreateBitcoinCoreWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateBitcoinCoreWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateBitcoinCoreWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'coreWalletName')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateBitcoinCoreWalletResponse clone() => CreateBitcoinCoreWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateBitcoinCoreWalletResponse copyWith(void Function(CreateBitcoinCoreWalletResponse) updates) => super.copyWith((message) => updates(message as CreateBitcoinCoreWalletResponse)) as CreateBitcoinCoreWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateBitcoinCoreWalletResponse create() => CreateBitcoinCoreWalletResponse._();
  CreateBitcoinCoreWalletResponse createEmptyInstance() => create();
  static $pb.PbList<CreateBitcoinCoreWalletResponse> createRepeated() => $pb.PbList<CreateBitcoinCoreWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateBitcoinCoreWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateBitcoinCoreWalletResponse>(create);
  static CreateBitcoinCoreWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get coreWalletName => $_getSZ(0);
  @$pb.TagNumber(1)
  set coreWalletName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCoreWalletName() => $_has(0);
  @$pb.TagNumber(1)
  void clearCoreWalletName() => clearField(1);
}

class EnsureCoreWalletsRequest extends $pb.GeneratedMessage {
  factory EnsureCoreWalletsRequest() => create();
  EnsureCoreWalletsRequest._() : super();
  factory EnsureCoreWalletsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EnsureCoreWalletsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EnsureCoreWalletsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EnsureCoreWalletsRequest clone() => EnsureCoreWalletsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EnsureCoreWalletsRequest copyWith(void Function(EnsureCoreWalletsRequest) updates) => super.copyWith((message) => updates(message as EnsureCoreWalletsRequest)) as EnsureCoreWalletsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EnsureCoreWalletsRequest create() => EnsureCoreWalletsRequest._();
  EnsureCoreWalletsRequest createEmptyInstance() => create();
  static $pb.PbList<EnsureCoreWalletsRequest> createRepeated() => $pb.PbList<EnsureCoreWalletsRequest>();
  @$core.pragma('dart2js:noInline')
  static EnsureCoreWalletsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EnsureCoreWalletsRequest>(create);
  static EnsureCoreWalletsRequest? _defaultInstance;
}

class EnsureCoreWalletsResponse extends $pb.GeneratedMessage {
  factory EnsureCoreWalletsResponse({
    $core.int? syncedCount,
  }) {
    final $result = create();
    if (syncedCount != null) {
      $result.syncedCount = syncedCount;
    }
    return $result;
  }
  EnsureCoreWalletsResponse._() : super();
  factory EnsureCoreWalletsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EnsureCoreWalletsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EnsureCoreWalletsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'syncedCount', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EnsureCoreWalletsResponse clone() => EnsureCoreWalletsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EnsureCoreWalletsResponse copyWith(void Function(EnsureCoreWalletsResponse) updates) => super.copyWith((message) => updates(message as EnsureCoreWalletsResponse)) as EnsureCoreWalletsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EnsureCoreWalletsResponse create() => EnsureCoreWalletsResponse._();
  EnsureCoreWalletsResponse createEmptyInstance() => create();
  static $pb.PbList<EnsureCoreWalletsResponse> createRepeated() => $pb.PbList<EnsureCoreWalletsResponse>();
  @$core.pragma('dart2js:noInline')
  static EnsureCoreWalletsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EnsureCoreWalletsResponse>(create);
  static EnsureCoreWalletsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get syncedCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set syncedCount($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSyncedCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearSyncedCount() => clearField(1);
}

class GetBalanceRequest extends $pb.GeneratedMessage {
  factory GetBalanceRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  GetBalanceRequest._() : super();
  factory GetBalanceRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBalanceRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBalanceRequest clone() => GetBalanceRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBalanceRequest copyWith(void Function(GetBalanceRequest) updates) => super.copyWith((message) => updates(message as GetBalanceRequest)) as GetBalanceRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBalanceRequest create() => GetBalanceRequest._();
  GetBalanceRequest createEmptyInstance() => create();
  static $pb.PbList<GetBalanceRequest> createRepeated() => $pb.PbList<GetBalanceRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBalanceRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalanceRequest>(create);
  static GetBalanceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class GetBalanceResponse extends $pb.GeneratedMessage {
  factory GetBalanceResponse({
    $core.double? confirmedSats,
    $core.double? unconfirmedSats,
  }) {
    final $result = create();
    if (confirmedSats != null) {
      $result.confirmedSats = confirmedSats;
    }
    if (unconfirmedSats != null) {
      $result.unconfirmedSats = unconfirmedSats;
    }
    return $result;
  }
  GetBalanceResponse._() : super();
  factory GetBalanceResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBalanceResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'confirmedSats', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'unconfirmedSats', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBalanceResponse clone() => GetBalanceResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBalanceResponse copyWith(void Function(GetBalanceResponse) updates) => super.copyWith((message) => updates(message as GetBalanceResponse)) as GetBalanceResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBalanceResponse create() => GetBalanceResponse._();
  GetBalanceResponse createEmptyInstance() => create();
  static $pb.PbList<GetBalanceResponse> createRepeated() => $pb.PbList<GetBalanceResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBalanceResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalanceResponse>(create);
  static GetBalanceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get confirmedSats => $_getN(0);
  @$pb.TagNumber(1)
  set confirmedSats($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConfirmedSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfirmedSats() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get unconfirmedSats => $_getN(1);
  @$pb.TagNumber(2)
  set unconfirmedSats($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUnconfirmedSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnconfirmedSats() => clearField(2);
}

class GetNewAddressRequest extends $pb.GeneratedMessage {
  factory GetNewAddressRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  GetNewAddressRequest._() : super();
  factory GetNewAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNewAddressRequest clone() => GetNewAddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNewAddressRequest copyWith(void Function(GetNewAddressRequest) updates) => super.copyWith((message) => updates(message as GetNewAddressRequest)) as GetNewAddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewAddressRequest create() => GetNewAddressRequest._();
  GetNewAddressRequest createEmptyInstance() => create();
  static $pb.PbList<GetNewAddressRequest> createRepeated() => $pb.PbList<GetNewAddressRequest>();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNewAddressRequest>(create);
  static GetNewAddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class GetNewAddressResponse extends $pb.GeneratedMessage {
  factory GetNewAddressResponse({
    $core.String? address,
    $core.int? index,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (index != null) {
      $result.index = index;
    }
    return $result;
  }
  GetNewAddressResponse._() : super();
  factory GetNewAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNewAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'index', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNewAddressResponse clone() => GetNewAddressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNewAddressResponse copyWith(void Function(GetNewAddressResponse) updates) => super.copyWith((message) => updates(message as GetNewAddressResponse)) as GetNewAddressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNewAddressResponse create() => GetNewAddressResponse._();
  GetNewAddressResponse createEmptyInstance() => create();
  static $pb.PbList<GetNewAddressResponse> createRepeated() => $pb.PbList<GetNewAddressResponse>();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNewAddressResponse>(create);
  static GetNewAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get index => $_getIZ(1);
  @$pb.TagNumber(2)
  set index($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearIndex() => clearField(2);
}

class SendTransactionRequest extends $pb.GeneratedMessage {
  factory SendTransactionRequest({
    $core.String? walletId,
    $core.Map<$core.String, $fixnum.Int64>? destinations,
    $fixnum.Int64? feeRateSatPerVbyte,
    $core.bool? subtractFeeFromAmount,
    $core.String? opReturnHex,
    $fixnum.Int64? fixedFeeSats,
    $core.Iterable<UnspentOutput>? requiredInputs,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (destinations != null) {
      $result.destinations.addAll(destinations);
    }
    if (feeRateSatPerVbyte != null) {
      $result.feeRateSatPerVbyte = feeRateSatPerVbyte;
    }
    if (subtractFeeFromAmount != null) {
      $result.subtractFeeFromAmount = subtractFeeFromAmount;
    }
    if (opReturnHex != null) {
      $result.opReturnHex = opReturnHex;
    }
    if (fixedFeeSats != null) {
      $result.fixedFeeSats = fixedFeeSats;
    }
    if (requiredInputs != null) {
      $result.requiredInputs.addAll(requiredInputs);
    }
    return $result;
  }
  SendTransactionRequest._() : super();
  factory SendTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..m<$core.String, $fixnum.Int64>(2, _omitFieldNames ? '' : 'destinations', entryClassName: 'SendTransactionRequest.DestinationsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.O6, packageName: const $pb.PackageName('walletmanager.v1'))
    ..aInt64(3, _omitFieldNames ? '' : 'feeRateSatPerVbyte')
    ..aOB(4, _omitFieldNames ? '' : 'subtractFeeFromAmount')
    ..aOS(5, _omitFieldNames ? '' : 'opReturnHex')
    ..aInt64(6, _omitFieldNames ? '' : 'fixedFeeSats')
    ..pc<UnspentOutput>(7, _omitFieldNames ? '' : 'requiredInputs', $pb.PbFieldType.PM, subBuilder: UnspentOutput.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendTransactionRequest clone() => SendTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendTransactionRequest copyWith(void Function(SendTransactionRequest) updates) => super.copyWith((message) => updates(message as SendTransactionRequest)) as SendTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendTransactionRequest create() => SendTransactionRequest._();
  SendTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<SendTransactionRequest> createRepeated() => $pb.PbList<SendTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static SendTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendTransactionRequest>(create);
  static SendTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $core.Map<$core.String, $fixnum.Int64> get destinations => $_getMap(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeRateSatPerVbyte => $_getI64(2);
  @$pb.TagNumber(3)
  set feeRateSatPerVbyte($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFeeRateSatPerVbyte() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeRateSatPerVbyte() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get subtractFeeFromAmount => $_getBF(3);
  @$pb.TagNumber(4)
  set subtractFeeFromAmount($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSubtractFeeFromAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubtractFeeFromAmount() => clearField(4);

  /// Raw OP_RETURN payload hex.
  @$pb.TagNumber(5)
  $core.String get opReturnHex => $_getSZ(4);
  @$pb.TagNumber(5)
  set opReturnHex($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOpReturnHex() => $_has(4);
  @$pb.TagNumber(5)
  void clearOpReturnHex() => clearField(5);

  /// Exact fee in sats when caller wants deterministic fee selection.
  @$pb.TagNumber(6)
  $fixnum.Int64 get fixedFeeSats => $_getI64(5);
  @$pb.TagNumber(6)
  set fixedFeeSats($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasFixedFeeSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearFixedFeeSats() => clearField(6);

  /// Explicit wallet inputs to spend.
  @$pb.TagNumber(7)
  $core.List<UnspentOutput> get requiredInputs => $_getList(6);
}

class SendTransactionResponse extends $pb.GeneratedMessage {
  factory SendTransactionResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  SendTransactionResponse._() : super();
  factory SendTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendTransactionResponse clone() => SendTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendTransactionResponse copyWith(void Function(SendTransactionResponse) updates) => super.copyWith((message) => updates(message as SendTransactionResponse)) as SendTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendTransactionResponse create() => SendTransactionResponse._();
  SendTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<SendTransactionResponse> createRepeated() => $pb.PbList<SendTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static SendTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendTransactionResponse>(create);
  static SendTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class ListTransactionsRequest extends $pb.GeneratedMessage {
  factory ListTransactionsRequest({
    $core.String? walletId,
    $core.int? count,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (count != null) {
      $result.count = count;
    }
    return $result;
  }
  ListTransactionsRequest._() : super();
  factory ListTransactionsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListTransactionsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'count', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListTransactionsRequest clone() => ListTransactionsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListTransactionsRequest copyWith(void Function(ListTransactionsRequest) updates) => super.copyWith((message) => updates(message as ListTransactionsRequest)) as ListTransactionsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTransactionsRequest create() => ListTransactionsRequest._();
  ListTransactionsRequest createEmptyInstance() => create();
  static $pb.PbList<ListTransactionsRequest> createRepeated() => $pb.PbList<ListTransactionsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListTransactionsRequest>(create);
  static ListTransactionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get count => $_getIZ(1);
  @$pb.TagNumber(2)
  set count($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => clearField(2);
}

class TransactionEntry extends $pb.GeneratedMessage {
  factory TransactionEntry({
    $core.String? txid,
    $core.int? vout,
    $core.String? address,
    $core.String? category,
    $core.double? amount,
    $fixnum.Int64? amountSats,
    $core.int? confirmations,
    $fixnum.Int64? blockTime,
    $fixnum.Int64? time,
    $core.String? label,
    $core.double? fee,
    $core.bool? replacedByTxid,
    $core.String? walletId,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (address != null) {
      $result.address = address;
    }
    if (category != null) {
      $result.category = category;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (amountSats != null) {
      $result.amountSats = amountSats;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (blockTime != null) {
      $result.blockTime = blockTime;
    }
    if (time != null) {
      $result.time = time;
    }
    if (label != null) {
      $result.label = label;
    }
    if (fee != null) {
      $result.fee = fee;
    }
    if (replacedByTxid != null) {
      $result.replacedByTxid = replacedByTxid;
    }
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  TransactionEntry._() : super();
  factory TransactionEntry.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransactionEntry.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransactionEntry', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aOS(4, _omitFieldNames ? '' : 'category')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..aInt64(6, _omitFieldNames ? '' : 'amountSats')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..aInt64(8, _omitFieldNames ? '' : 'blockTime')
    ..aInt64(9, _omitFieldNames ? '' : 'time')
    ..aOS(10, _omitFieldNames ? '' : 'label')
    ..a<$core.double>(11, _omitFieldNames ? '' : 'fee', $pb.PbFieldType.OD)
    ..aOB(12, _omitFieldNames ? '' : 'replacedByTxid')
    ..aOS(13, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransactionEntry clone() => TransactionEntry()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransactionEntry copyWith(void Function(TransactionEntry) updates) => super.copyWith((message) => updates(message as TransactionEntry)) as TransactionEntry;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransactionEntry create() => TransactionEntry._();
  TransactionEntry createEmptyInstance() => create();
  static $pb.PbList<TransactionEntry> createRepeated() => $pb.PbList<TransactionEntry>();
  @$core.pragma('dart2js:noInline')
  static TransactionEntry getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransactionEntry>(create);
  static TransactionEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get category => $_getSZ(3);
  @$pb.TagNumber(4)
  set category($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCategory() => $_has(3);
  @$pb.TagNumber(4)
  void clearCategory() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get amount => $_getN(4);
  @$pb.TagNumber(5)
  set amount($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAmount() => $_has(4);
  @$pb.TagNumber(5)
  void clearAmount() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get amountSats => $_getI64(5);
  @$pb.TagNumber(6)
  set amountSats($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAmountSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearAmountSats() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get confirmations => $_getIZ(6);
  @$pb.TagNumber(7)
  set confirmations($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasConfirmations() => $_has(6);
  @$pb.TagNumber(7)
  void clearConfirmations() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get blockTime => $_getI64(7);
  @$pb.TagNumber(8)
  set blockTime($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasBlockTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearBlockTime() => clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get time => $_getI64(8);
  @$pb.TagNumber(9)
  set time($fixnum.Int64 v) { $_setInt64(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasTime() => $_has(8);
  @$pb.TagNumber(9)
  void clearTime() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get label => $_getSZ(9);
  @$pb.TagNumber(10)
  set label($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasLabel() => $_has(9);
  @$pb.TagNumber(10)
  void clearLabel() => clearField(10);

  @$pb.TagNumber(11)
  $core.double get fee => $_getN(10);
  @$pb.TagNumber(11)
  set fee($core.double v) { $_setDouble(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasFee() => $_has(10);
  @$pb.TagNumber(11)
  void clearFee() => clearField(11);

  @$pb.TagNumber(12)
  $core.bool get replacedByTxid => $_getBF(11);
  @$pb.TagNumber(12)
  set replacedByTxid($core.bool v) { $_setBool(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasReplacedByTxid() => $_has(11);
  @$pb.TagNumber(12)
  void clearReplacedByTxid() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get walletId => $_getSZ(12);
  @$pb.TagNumber(13)
  set walletId($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasWalletId() => $_has(12);
  @$pb.TagNumber(13)
  void clearWalletId() => clearField(13);
}

class ListTransactionsResponse extends $pb.GeneratedMessage {
  factory ListTransactionsResponse({
    $core.Iterable<TransactionEntry>? transactions,
  }) {
    final $result = create();
    if (transactions != null) {
      $result.transactions.addAll(transactions);
    }
    return $result;
  }
  ListTransactionsResponse._() : super();
  factory ListTransactionsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListTransactionsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..pc<TransactionEntry>(1, _omitFieldNames ? '' : 'transactions', $pb.PbFieldType.PM, subBuilder: TransactionEntry.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListTransactionsResponse clone() => ListTransactionsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListTransactionsResponse copyWith(void Function(ListTransactionsResponse) updates) => super.copyWith((message) => updates(message as ListTransactionsResponse)) as ListTransactionsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTransactionsResponse create() => ListTransactionsResponse._();
  ListTransactionsResponse createEmptyInstance() => create();
  static $pb.PbList<ListTransactionsResponse> createRepeated() => $pb.PbList<ListTransactionsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListTransactionsResponse>(create);
  static ListTransactionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<TransactionEntry> get transactions => $_getList(0);
}

class ListUnspentRequest extends $pb.GeneratedMessage {
  factory ListUnspentRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  ListUnspentRequest._() : super();
  factory ListUnspentRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListUnspentRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUnspentRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListUnspentRequest clone() => ListUnspentRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListUnspentRequest copyWith(void Function(ListUnspentRequest) updates) => super.copyWith((message) => updates(message as ListUnspentRequest)) as ListUnspentRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUnspentRequest create() => ListUnspentRequest._();
  ListUnspentRequest createEmptyInstance() => create();
  static $pb.PbList<ListUnspentRequest> createRepeated() => $pb.PbList<ListUnspentRequest>();
  @$core.pragma('dart2js:noInline')
  static ListUnspentRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUnspentRequest>(create);
  static ListUnspentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class UnspentOutput extends $pb.GeneratedMessage {
  factory UnspentOutput({
    $core.String? txid,
    $core.int? vout,
    $core.String? address,
    $core.double? amount,
    $fixnum.Int64? amountSats,
    $core.int? confirmations,
    $core.String? label,
    $core.bool? spendable,
    $core.bool? solvable,
    $core.String? walletId,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (address != null) {
      $result.address = address;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (amountSats != null) {
      $result.amountSats = amountSats;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (label != null) {
      $result.label = label;
    }
    if (spendable != null) {
      $result.spendable = spendable;
    }
    if (solvable != null) {
      $result.solvable = solvable;
    }
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  UnspentOutput._() : super();
  factory UnspentOutput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnspentOutput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnspentOutput', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..aInt64(5, _omitFieldNames ? '' : 'amountSats')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..aOS(7, _omitFieldNames ? '' : 'label')
    ..aOB(8, _omitFieldNames ? '' : 'spendable')
    ..aOB(9, _omitFieldNames ? '' : 'solvable')
    ..aOS(10, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnspentOutput clone() => UnspentOutput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnspentOutput copyWith(void Function(UnspentOutput) updates) => super.copyWith((message) => updates(message as UnspentOutput)) as UnspentOutput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnspentOutput create() => UnspentOutput._();
  UnspentOutput createEmptyInstance() => create();
  static $pb.PbList<UnspentOutput> createRepeated() => $pb.PbList<UnspentOutput>();
  @$core.pragma('dart2js:noInline')
  static UnspentOutput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnspentOutput>(create);
  static UnspentOutput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get amount => $_getN(3);
  @$pb.TagNumber(4)
  set amount($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get amountSats => $_getI64(4);
  @$pb.TagNumber(5)
  set amountSats($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAmountSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearAmountSats() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get confirmations => $_getIZ(5);
  @$pb.TagNumber(6)
  set confirmations($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasConfirmations() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfirmations() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get label => $_getSZ(6);
  @$pb.TagNumber(7)
  set label($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasLabel() => $_has(6);
  @$pb.TagNumber(7)
  void clearLabel() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get spendable => $_getBF(7);
  @$pb.TagNumber(8)
  set spendable($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasSpendable() => $_has(7);
  @$pb.TagNumber(8)
  void clearSpendable() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get solvable => $_getBF(8);
  @$pb.TagNumber(9)
  set solvable($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasSolvable() => $_has(8);
  @$pb.TagNumber(9)
  void clearSolvable() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get walletId => $_getSZ(9);
  @$pb.TagNumber(10)
  set walletId($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasWalletId() => $_has(9);
  @$pb.TagNumber(10)
  void clearWalletId() => clearField(10);
}

class ListUnspentResponse extends $pb.GeneratedMessage {
  factory ListUnspentResponse({
    $core.Iterable<UnspentOutput>? utxos,
  }) {
    final $result = create();
    if (utxos != null) {
      $result.utxos.addAll(utxos);
    }
    return $result;
  }
  ListUnspentResponse._() : super();
  factory ListUnspentResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListUnspentResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUnspentResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..pc<UnspentOutput>(1, _omitFieldNames ? '' : 'utxos', $pb.PbFieldType.PM, subBuilder: UnspentOutput.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListUnspentResponse clone() => ListUnspentResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListUnspentResponse copyWith(void Function(ListUnspentResponse) updates) => super.copyWith((message) => updates(message as ListUnspentResponse)) as ListUnspentResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUnspentResponse create() => ListUnspentResponse._();
  ListUnspentResponse createEmptyInstance() => create();
  static $pb.PbList<ListUnspentResponse> createRepeated() => $pb.PbList<ListUnspentResponse>();
  @$core.pragma('dart2js:noInline')
  static ListUnspentResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUnspentResponse>(create);
  static ListUnspentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<UnspentOutput> get utxos => $_getList(0);
}

class ListReceiveAddressesRequest extends $pb.GeneratedMessage {
  factory ListReceiveAddressesRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  ListReceiveAddressesRequest._() : super();
  factory ListReceiveAddressesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListReceiveAddressesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListReceiveAddressesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListReceiveAddressesRequest clone() => ListReceiveAddressesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListReceiveAddressesRequest copyWith(void Function(ListReceiveAddressesRequest) updates) => super.copyWith((message) => updates(message as ListReceiveAddressesRequest)) as ListReceiveAddressesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesRequest create() => ListReceiveAddressesRequest._();
  ListReceiveAddressesRequest createEmptyInstance() => create();
  static $pb.PbList<ListReceiveAddressesRequest> createRepeated() => $pb.PbList<ListReceiveAddressesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListReceiveAddressesRequest>(create);
  static ListReceiveAddressesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class ReceiveAddress extends $pb.GeneratedMessage {
  factory ReceiveAddress({
    $core.String? address,
    $core.double? amount,
    $fixnum.Int64? amountSats,
    $core.String? label,
    $core.int? txCount,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (amountSats != null) {
      $result.amountSats = amountSats;
    }
    if (label != null) {
      $result.label = label;
    }
    if (txCount != null) {
      $result.txCount = txCount;
    }
    return $result;
  }
  ReceiveAddress._() : super();
  factory ReceiveAddress.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReceiveAddress.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReceiveAddress', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..aInt64(3, _omitFieldNames ? '' : 'amountSats')
    ..aOS(4, _omitFieldNames ? '' : 'label')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'txCount', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReceiveAddress clone() => ReceiveAddress()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReceiveAddress copyWith(void Function(ReceiveAddress) updates) => super.copyWith((message) => updates(message as ReceiveAddress)) as ReceiveAddress;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReceiveAddress create() => ReceiveAddress._();
  ReceiveAddress createEmptyInstance() => create();
  static $pb.PbList<ReceiveAddress> createRepeated() => $pb.PbList<ReceiveAddress>();
  @$core.pragma('dart2js:noInline')
  static ReceiveAddress getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReceiveAddress>(create);
  static ReceiveAddress? _defaultInstance;

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
  $fixnum.Int64 get amountSats => $_getI64(2);
  @$pb.TagNumber(3)
  set amountSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAmountSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmountSats() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get label => $_getSZ(3);
  @$pb.TagNumber(4)
  set label($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLabel() => $_has(3);
  @$pb.TagNumber(4)
  void clearLabel() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get txCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set txCount($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTxCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearTxCount() => clearField(5);
}

class ListReceiveAddressesResponse extends $pb.GeneratedMessage {
  factory ListReceiveAddressesResponse({
    $core.Iterable<ReceiveAddress>? addresses,
  }) {
    final $result = create();
    if (addresses != null) {
      $result.addresses.addAll(addresses);
    }
    return $result;
  }
  ListReceiveAddressesResponse._() : super();
  factory ListReceiveAddressesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListReceiveAddressesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListReceiveAddressesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..pc<ReceiveAddress>(1, _omitFieldNames ? '' : 'addresses', $pb.PbFieldType.PM, subBuilder: ReceiveAddress.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListReceiveAddressesResponse clone() => ListReceiveAddressesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListReceiveAddressesResponse copyWith(void Function(ListReceiveAddressesResponse) updates) => super.copyWith((message) => updates(message as ListReceiveAddressesResponse)) as ListReceiveAddressesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesResponse create() => ListReceiveAddressesResponse._();
  ListReceiveAddressesResponse createEmptyInstance() => create();
  static $pb.PbList<ListReceiveAddressesResponse> createRepeated() => $pb.PbList<ListReceiveAddressesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListReceiveAddressesResponse>(create);
  static ListReceiveAddressesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ReceiveAddress> get addresses => $_getList(0);
}

class GetTransactionDetailsRequest extends $pb.GeneratedMessage {
  factory GetTransactionDetailsRequest({
    $core.String? walletId,
    $core.String? txid,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  GetTransactionDetailsRequest._() : super();
  factory GetTransactionDetailsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionDetailsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionDetailsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransactionDetailsRequest clone() => GetTransactionDetailsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransactionDetailsRequest copyWith(void Function(GetTransactionDetailsRequest) updates) => super.copyWith((message) => updates(message as GetTransactionDetailsRequest)) as GetTransactionDetailsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsRequest create() => GetTransactionDetailsRequest._();
  GetTransactionDetailsRequest createEmptyInstance() => create();
  static $pb.PbList<GetTransactionDetailsRequest> createRepeated() => $pb.PbList<GetTransactionDetailsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransactionDetailsRequest>(create);
  static GetTransactionDetailsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => clearField(2);
}

class GetTransactionDetailsResponse extends $pb.GeneratedMessage {
  factory GetTransactionDetailsResponse({
    TransactionEntry? transaction,
    $core.String? rawHex,
    $core.String? blockhash,
    $core.int? confirmations,
    $fixnum.Int64? blockTime,
    $core.int? version,
    $core.int? locktime,
    $core.int? sizeBytes,
    $core.int? vsizeVbytes,
    $core.int? weightWu,
    $fixnum.Int64? feeSats,
    $core.double? feeRateSatVb,
    $core.Iterable<TransactionInput>? inputs,
    $fixnum.Int64? totalInputSats,
    $core.Iterable<TransactionOutput>? outputs,
    $fixnum.Int64? totalOutputSats,
  }) {
    final $result = create();
    if (transaction != null) {
      $result.transaction = transaction;
    }
    if (rawHex != null) {
      $result.rawHex = rawHex;
    }
    if (blockhash != null) {
      $result.blockhash = blockhash;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (blockTime != null) {
      $result.blockTime = blockTime;
    }
    if (version != null) {
      $result.version = version;
    }
    if (locktime != null) {
      $result.locktime = locktime;
    }
    if (sizeBytes != null) {
      $result.sizeBytes = sizeBytes;
    }
    if (vsizeVbytes != null) {
      $result.vsizeVbytes = vsizeVbytes;
    }
    if (weightWu != null) {
      $result.weightWu = weightWu;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (feeRateSatVb != null) {
      $result.feeRateSatVb = feeRateSatVb;
    }
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (totalInputSats != null) {
      $result.totalInputSats = totalInputSats;
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    if (totalOutputSats != null) {
      $result.totalOutputSats = totalOutputSats;
    }
    return $result;
  }
  GetTransactionDetailsResponse._() : super();
  factory GetTransactionDetailsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTransactionDetailsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionDetailsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOM<TransactionEntry>(1, _omitFieldNames ? '' : 'transaction', subBuilder: TransactionEntry.create)
    ..aOS(2, _omitFieldNames ? '' : 'rawHex')
    ..aOS(3, _omitFieldNames ? '' : 'blockhash')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..aInt64(5, _omitFieldNames ? '' : 'blockTime')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'version', $pb.PbFieldType.O3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'locktime', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'sizeBytes', $pb.PbFieldType.O3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'vsizeVbytes', $pb.PbFieldType.O3)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'weightWu', $pb.PbFieldType.O3)
    ..aInt64(11, _omitFieldNames ? '' : 'feeSats')
    ..a<$core.double>(12, _omitFieldNames ? '' : 'feeRateSatVb', $pb.PbFieldType.OD)
    ..pc<TransactionInput>(13, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: TransactionInput.create)
    ..aInt64(14, _omitFieldNames ? '' : 'totalInputSats')
    ..pc<TransactionOutput>(15, _omitFieldNames ? '' : 'outputs', $pb.PbFieldType.PM, subBuilder: TransactionOutput.create)
    ..aInt64(16, _omitFieldNames ? '' : 'totalOutputSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTransactionDetailsResponse clone() => GetTransactionDetailsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTransactionDetailsResponse copyWith(void Function(GetTransactionDetailsResponse) updates) => super.copyWith((message) => updates(message as GetTransactionDetailsResponse)) as GetTransactionDetailsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsResponse create() => GetTransactionDetailsResponse._();
  GetTransactionDetailsResponse createEmptyInstance() => create();
  static $pb.PbList<GetTransactionDetailsResponse> createRepeated() => $pb.PbList<GetTransactionDetailsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTransactionDetailsResponse>(create);
  static GetTransactionDetailsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TransactionEntry get transaction => $_getN(0);
  @$pb.TagNumber(1)
  set transaction(TransactionEntry v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTransaction() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransaction() => clearField(1);
  @$pb.TagNumber(1)
  TransactionEntry ensureTransaction() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get rawHex => $_getSZ(1);
  @$pb.TagNumber(2)
  set rawHex($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRawHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearRawHex() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get blockhash => $_getSZ(2);
  @$pb.TagNumber(3)
  set blockhash($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBlockhash() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockhash() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get confirmations => $_getIZ(3);
  @$pb.TagNumber(4)
  set confirmations($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasConfirmations() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfirmations() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get blockTime => $_getI64(4);
  @$pb.TagNumber(5)
  set blockTime($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasBlockTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlockTime() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get version => $_getIZ(5);
  @$pb.TagNumber(6)
  set version($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersion() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get locktime => $_getIZ(6);
  @$pb.TagNumber(7)
  set locktime($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasLocktime() => $_has(6);
  @$pb.TagNumber(7)
  void clearLocktime() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get sizeBytes => $_getIZ(7);
  @$pb.TagNumber(8)
  set sizeBytes($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasSizeBytes() => $_has(7);
  @$pb.TagNumber(8)
  void clearSizeBytes() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get vsizeVbytes => $_getIZ(8);
  @$pb.TagNumber(9)
  set vsizeVbytes($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasVsizeVbytes() => $_has(8);
  @$pb.TagNumber(9)
  void clearVsizeVbytes() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get weightWu => $_getIZ(9);
  @$pb.TagNumber(10)
  set weightWu($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasWeightWu() => $_has(9);
  @$pb.TagNumber(10)
  void clearWeightWu() => clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get feeSats => $_getI64(10);
  @$pb.TagNumber(11)
  set feeSats($fixnum.Int64 v) { $_setInt64(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasFeeSats() => $_has(10);
  @$pb.TagNumber(11)
  void clearFeeSats() => clearField(11);

  @$pb.TagNumber(12)
  $core.double get feeRateSatVb => $_getN(11);
  @$pb.TagNumber(12)
  set feeRateSatVb($core.double v) { $_setDouble(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasFeeRateSatVb() => $_has(11);
  @$pb.TagNumber(12)
  void clearFeeRateSatVb() => clearField(12);

  @$pb.TagNumber(13)
  $core.List<TransactionInput> get inputs => $_getList(12);

  @$pb.TagNumber(14)
  $fixnum.Int64 get totalInputSats => $_getI64(13);
  @$pb.TagNumber(14)
  set totalInputSats($fixnum.Int64 v) { $_setInt64(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasTotalInputSats() => $_has(13);
  @$pb.TagNumber(14)
  void clearTotalInputSats() => clearField(14);

  @$pb.TagNumber(15)
  $core.List<TransactionOutput> get outputs => $_getList(14);

  @$pb.TagNumber(16)
  $fixnum.Int64 get totalOutputSats => $_getI64(15);
  @$pb.TagNumber(16)
  set totalOutputSats($fixnum.Int64 v) { $_setInt64(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasTotalOutputSats() => $_has(15);
  @$pb.TagNumber(16)
  void clearTotalOutputSats() => clearField(16);
}

class TransactionInput extends $pb.GeneratedMessage {
  factory TransactionInput({
    $core.int? index,
    $core.String? prevTxid,
    $core.int? prevVout,
    $core.String? address,
    $fixnum.Int64? valueSats,
    $core.String? scriptSigAsm,
    $core.String? scriptSigHex,
    $core.Iterable<$core.String>? witness,
    $fixnum.Int64? sequence,
    $core.bool? isCoinbase,
  }) {
    final $result = create();
    if (index != null) {
      $result.index = index;
    }
    if (prevTxid != null) {
      $result.prevTxid = prevTxid;
    }
    if (prevVout != null) {
      $result.prevVout = prevVout;
    }
    if (address != null) {
      $result.address = address;
    }
    if (valueSats != null) {
      $result.valueSats = valueSats;
    }
    if (scriptSigAsm != null) {
      $result.scriptSigAsm = scriptSigAsm;
    }
    if (scriptSigHex != null) {
      $result.scriptSigHex = scriptSigHex;
    }
    if (witness != null) {
      $result.witness.addAll(witness);
    }
    if (sequence != null) {
      $result.sequence = sequence;
    }
    if (isCoinbase != null) {
      $result.isCoinbase = isCoinbase;
    }
    return $result;
  }
  TransactionInput._() : super();
  factory TransactionInput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransactionInput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransactionInput', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'index', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'prevTxid')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'prevVout', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'address')
    ..aInt64(5, _omitFieldNames ? '' : 'valueSats')
    ..aOS(6, _omitFieldNames ? '' : 'scriptSigAsm')
    ..aOS(7, _omitFieldNames ? '' : 'scriptSigHex')
    ..pPS(8, _omitFieldNames ? '' : 'witness')
    ..aInt64(9, _omitFieldNames ? '' : 'sequence')
    ..aOB(10, _omitFieldNames ? '' : 'isCoinbase')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransactionInput clone() => TransactionInput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransactionInput copyWith(void Function(TransactionInput) updates) => super.copyWith((message) => updates(message as TransactionInput)) as TransactionInput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransactionInput create() => TransactionInput._();
  TransactionInput createEmptyInstance() => create();
  static $pb.PbList<TransactionInput> createRepeated() => $pb.PbList<TransactionInput>();
  @$core.pragma('dart2js:noInline')
  static TransactionInput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransactionInput>(create);
  static TransactionInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(1)
  set index($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndex() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get prevTxid => $_getSZ(1);
  @$pb.TagNumber(2)
  set prevTxid($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPrevTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrevTxid() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get prevVout => $_getIZ(2);
  @$pb.TagNumber(3)
  set prevVout($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPrevVout() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevVout() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get address => $_getSZ(3);
  @$pb.TagNumber(4)
  set address($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAddress() => $_has(3);
  @$pb.TagNumber(4)
  void clearAddress() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get valueSats => $_getI64(4);
  @$pb.TagNumber(5)
  set valueSats($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasValueSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearValueSats() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get scriptSigAsm => $_getSZ(5);
  @$pb.TagNumber(6)
  set scriptSigAsm($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasScriptSigAsm() => $_has(5);
  @$pb.TagNumber(6)
  void clearScriptSigAsm() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get scriptSigHex => $_getSZ(6);
  @$pb.TagNumber(7)
  set scriptSigHex($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasScriptSigHex() => $_has(6);
  @$pb.TagNumber(7)
  void clearScriptSigHex() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.String> get witness => $_getList(7);

  @$pb.TagNumber(9)
  $fixnum.Int64 get sequence => $_getI64(8);
  @$pb.TagNumber(9)
  set sequence($fixnum.Int64 v) { $_setInt64(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasSequence() => $_has(8);
  @$pb.TagNumber(9)
  void clearSequence() => clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isCoinbase => $_getBF(9);
  @$pb.TagNumber(10)
  set isCoinbase($core.bool v) { $_setBool(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasIsCoinbase() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsCoinbase() => clearField(10);
}

class TransactionOutput extends $pb.GeneratedMessage {
  factory TransactionOutput({
    $core.int? index,
    $fixnum.Int64? valueSats,
    $core.String? address,
    $core.String? scriptType,
    $core.String? scriptPubkeyAsm,
    $core.String? scriptPubkeyHex,
  }) {
    final $result = create();
    if (index != null) {
      $result.index = index;
    }
    if (valueSats != null) {
      $result.valueSats = valueSats;
    }
    if (address != null) {
      $result.address = address;
    }
    if (scriptType != null) {
      $result.scriptType = scriptType;
    }
    if (scriptPubkeyAsm != null) {
      $result.scriptPubkeyAsm = scriptPubkeyAsm;
    }
    if (scriptPubkeyHex != null) {
      $result.scriptPubkeyHex = scriptPubkeyHex;
    }
    return $result;
  }
  TransactionOutput._() : super();
  factory TransactionOutput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransactionOutput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransactionOutput', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'index', $pb.PbFieldType.O3)
    ..aInt64(2, _omitFieldNames ? '' : 'valueSats')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aOS(4, _omitFieldNames ? '' : 'scriptType')
    ..aOS(5, _omitFieldNames ? '' : 'scriptPubkeyAsm')
    ..aOS(6, _omitFieldNames ? '' : 'scriptPubkeyHex')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransactionOutput clone() => TransactionOutput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransactionOutput copyWith(void Function(TransactionOutput) updates) => super.copyWith((message) => updates(message as TransactionOutput)) as TransactionOutput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransactionOutput create() => TransactionOutput._();
  TransactionOutput createEmptyInstance() => create();
  static $pb.PbList<TransactionOutput> createRepeated() => $pb.PbList<TransactionOutput>();
  @$core.pragma('dart2js:noInline')
  static TransactionOutput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransactionOutput>(create);
  static TransactionOutput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(1)
  set index($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndex() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get valueSats => $_getI64(1);
  @$pb.TagNumber(2)
  set valueSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearValueSats() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get scriptType => $_getSZ(3);
  @$pb.TagNumber(4)
  set scriptType($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasScriptType() => $_has(3);
  @$pb.TagNumber(4)
  void clearScriptType() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get scriptPubkeyAsm => $_getSZ(4);
  @$pb.TagNumber(5)
  set scriptPubkeyAsm($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasScriptPubkeyAsm() => $_has(4);
  @$pb.TagNumber(5)
  void clearScriptPubkeyAsm() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get scriptPubkeyHex => $_getSZ(5);
  @$pb.TagNumber(6)
  set scriptPubkeyHex($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasScriptPubkeyHex() => $_has(5);
  @$pb.TagNumber(6)
  void clearScriptPubkeyHex() => clearField(6);
}

class BumpFeeRequest extends $pb.GeneratedMessage {
  factory BumpFeeRequest({
    $core.String? walletId,
    $core.String? txid,
    $fixnum.Int64? newFeeRate,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (newFeeRate != null) {
      $result.newFeeRate = newFeeRate;
    }
    return $result;
  }
  BumpFeeRequest._() : super();
  factory BumpFeeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BumpFeeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BumpFeeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..aInt64(3, _omitFieldNames ? '' : 'newFeeRate')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BumpFeeRequest clone() => BumpFeeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BumpFeeRequest copyWith(void Function(BumpFeeRequest) updates) => super.copyWith((message) => updates(message as BumpFeeRequest)) as BumpFeeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BumpFeeRequest create() => BumpFeeRequest._();
  BumpFeeRequest createEmptyInstance() => create();
  static $pb.PbList<BumpFeeRequest> createRepeated() => $pb.PbList<BumpFeeRequest>();
  @$core.pragma('dart2js:noInline')
  static BumpFeeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BumpFeeRequest>(create);
  static BumpFeeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get newFeeRate => $_getI64(2);
  @$pb.TagNumber(3)
  set newFeeRate($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNewFeeRate() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewFeeRate() => clearField(3);
}

class BumpFeeResponse extends $pb.GeneratedMessage {
  factory BumpFeeResponse({
    $core.String? newTxid,
  }) {
    final $result = create();
    if (newTxid != null) {
      $result.newTxid = newTxid;
    }
    return $result;
  }
  BumpFeeResponse._() : super();
  factory BumpFeeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BumpFeeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BumpFeeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'newTxid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BumpFeeResponse clone() => BumpFeeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BumpFeeResponse copyWith(void Function(BumpFeeResponse) updates) => super.copyWith((message) => updates(message as BumpFeeResponse)) as BumpFeeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BumpFeeResponse create() => BumpFeeResponse._();
  BumpFeeResponse createEmptyInstance() => create();
  static $pb.PbList<BumpFeeResponse> createRepeated() => $pb.PbList<BumpFeeResponse>();
  @$core.pragma('dart2js:noInline')
  static BumpFeeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BumpFeeResponse>(create);
  static BumpFeeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get newTxid => $_getSZ(0);
  @$pb.TagNumber(1)
  set newTxid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasNewTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearNewTxid() => clearField(1);
}

class DeriveAddressesRequest extends $pb.GeneratedMessage {
  factory DeriveAddressesRequest({
    $core.String? walletId,
    $core.int? startIndex,
    $core.int? count,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (startIndex != null) {
      $result.startIndex = startIndex;
    }
    if (count != null) {
      $result.count = count;
    }
    return $result;
  }
  DeriveAddressesRequest._() : super();
  factory DeriveAddressesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeriveAddressesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeriveAddressesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'startIndex', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'count', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeriveAddressesRequest clone() => DeriveAddressesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeriveAddressesRequest copyWith(void Function(DeriveAddressesRequest) updates) => super.copyWith((message) => updates(message as DeriveAddressesRequest)) as DeriveAddressesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeriveAddressesRequest create() => DeriveAddressesRequest._();
  DeriveAddressesRequest createEmptyInstance() => create();
  static $pb.PbList<DeriveAddressesRequest> createRepeated() => $pb.PbList<DeriveAddressesRequest>();
  @$core.pragma('dart2js:noInline')
  static DeriveAddressesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeriveAddressesRequest>(create);
  static DeriveAddressesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get startIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set startIndex($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStartIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartIndex() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get count => $_getIZ(2);
  @$pb.TagNumber(3)
  set count($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearCount() => clearField(3);
}

class DeriveAddressesResponse extends $pb.GeneratedMessage {
  factory DeriveAddressesResponse({
    $core.Iterable<$core.String>? addresses,
  }) {
    final $result = create();
    if (addresses != null) {
      $result.addresses.addAll(addresses);
    }
    return $result;
  }
  DeriveAddressesResponse._() : super();
  factory DeriveAddressesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeriveAddressesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeriveAddressesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'addresses')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeriveAddressesResponse clone() => DeriveAddressesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeriveAddressesResponse copyWith(void Function(DeriveAddressesResponse) updates) => super.copyWith((message) => updates(message as DeriveAddressesResponse)) as DeriveAddressesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeriveAddressesResponse create() => DeriveAddressesResponse._();
  DeriveAddressesResponse createEmptyInstance() => create();
  static $pb.PbList<DeriveAddressesResponse> createRepeated() => $pb.PbList<DeriveAddressesResponse>();
  @$core.pragma('dart2js:noInline')
  static DeriveAddressesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeriveAddressesResponse>(create);
  static DeriveAddressesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get addresses => $_getList(0);
}

class GetWalletSeedRequest extends $pb.GeneratedMessage {
  factory GetWalletSeedRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  GetWalletSeedRequest._() : super();
  factory GetWalletSeedRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWalletSeedRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletSeedRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWalletSeedRequest clone() => GetWalletSeedRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWalletSeedRequest copyWith(void Function(GetWalletSeedRequest) updates) => super.copyWith((message) => updates(message as GetWalletSeedRequest)) as GetWalletSeedRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWalletSeedRequest create() => GetWalletSeedRequest._();
  GetWalletSeedRequest createEmptyInstance() => create();
  static $pb.PbList<GetWalletSeedRequest> createRepeated() => $pb.PbList<GetWalletSeedRequest>();
  @$core.pragma('dart2js:noInline')
  static GetWalletSeedRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWalletSeedRequest>(create);
  static GetWalletSeedRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class GetWalletSeedResponse extends $pb.GeneratedMessage {
  factory GetWalletSeedResponse({
    $core.String? seedHex,
    $core.String? mnemonic,
  }) {
    final $result = create();
    if (seedHex != null) {
      $result.seedHex = seedHex;
    }
    if (mnemonic != null) {
      $result.mnemonic = mnemonic;
    }
    return $result;
  }
  GetWalletSeedResponse._() : super();
  factory GetWalletSeedResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWalletSeedResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletSeedResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'seedHex')
    ..aOS(2, _omitFieldNames ? '' : 'mnemonic')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWalletSeedResponse clone() => GetWalletSeedResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWalletSeedResponse copyWith(void Function(GetWalletSeedResponse) updates) => super.copyWith((message) => updates(message as GetWalletSeedResponse)) as GetWalletSeedResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWalletSeedResponse create() => GetWalletSeedResponse._();
  GetWalletSeedResponse createEmptyInstance() => create();
  static $pb.PbList<GetWalletSeedResponse> createRepeated() => $pb.PbList<GetWalletSeedResponse>();
  @$core.pragma('dart2js:noInline')
  static GetWalletSeedResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWalletSeedResponse>(create);
  static GetWalletSeedResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get seedHex => $_getSZ(0);
  @$pb.TagNumber(1)
  set seedHex($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSeedHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeedHex() => clearField(1);

  /// BIP39 mnemonic words for the wallet. Sensitive — treat like seed_hex.
  @$pb.TagNumber(2)
  $core.String get mnemonic => $_getSZ(1);
  @$pb.TagNumber(2)
  set mnemonic($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMnemonic() => $_has(1);
  @$pb.TagNumber(2)
  void clearMnemonic() => clearField(2);
}

class WatchWalletDataResponse extends $pb.GeneratedMessage {
  factory WatchWalletDataResponse({
    $core.bool? hasWallet,
    $core.bool? encrypted,
    $core.bool? unlocked,
    $core.String? activeWalletId,
    $core.Iterable<WalletMetadata>? wallets,
    $core.double? confirmedSats,
    $core.double? unconfirmedSats,
  }) {
    final $result = create();
    if (hasWallet != null) {
      $result.hasWallet = hasWallet;
    }
    if (encrypted != null) {
      $result.encrypted = encrypted;
    }
    if (unlocked != null) {
      $result.unlocked = unlocked;
    }
    if (activeWalletId != null) {
      $result.activeWalletId = activeWalletId;
    }
    if (wallets != null) {
      $result.wallets.addAll(wallets);
    }
    if (confirmedSats != null) {
      $result.confirmedSats = confirmedSats;
    }
    if (unconfirmedSats != null) {
      $result.unconfirmedSats = unconfirmedSats;
    }
    return $result;
  }
  WatchWalletDataResponse._() : super();
  factory WatchWalletDataResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WatchWalletDataResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WatchWalletDataResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'hasWallet')
    ..aOB(2, _omitFieldNames ? '' : 'encrypted')
    ..aOB(3, _omitFieldNames ? '' : 'unlocked')
    ..aOS(4, _omitFieldNames ? '' : 'activeWalletId')
    ..pc<WalletMetadata>(5, _omitFieldNames ? '' : 'wallets', $pb.PbFieldType.PM, subBuilder: WalletMetadata.create)
    ..a<$core.double>(6, _omitFieldNames ? '' : 'confirmedSats', $pb.PbFieldType.OD)
    ..a<$core.double>(7, _omitFieldNames ? '' : 'unconfirmedSats', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WatchWalletDataResponse clone() => WatchWalletDataResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WatchWalletDataResponse copyWith(void Function(WatchWalletDataResponse) updates) => super.copyWith((message) => updates(message as WatchWalletDataResponse)) as WatchWalletDataResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WatchWalletDataResponse create() => WatchWalletDataResponse._();
  WatchWalletDataResponse createEmptyInstance() => create();
  static $pb.PbList<WatchWalletDataResponse> createRepeated() => $pb.PbList<WatchWalletDataResponse>();
  @$core.pragma('dart2js:noInline')
  static WatchWalletDataResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WatchWalletDataResponse>(create);
  static WatchWalletDataResponse? _defaultInstance;

  /// Wallet status
  @$pb.TagNumber(1)
  $core.bool get hasWallet => $_getBF(0);
  @$pb.TagNumber(1)
  set hasWallet($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearHasWallet() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get encrypted => $_getBF(1);
  @$pb.TagNumber(2)
  set encrypted($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEncrypted() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncrypted() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get unlocked => $_getBF(2);
  @$pb.TagNumber(3)
  set unlocked($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUnlocked() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnlocked() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get activeWalletId => $_getSZ(3);
  @$pb.TagNumber(4)
  set activeWalletId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasActiveWalletId() => $_has(3);
  @$pb.TagNumber(4)
  void clearActiveWalletId() => clearField(4);

  /// All wallets
  @$pb.TagNumber(5)
  $core.List<WalletMetadata> get wallets => $_getList(4);

  /// Active wallet balance (zero if no active wallet)
  @$pb.TagNumber(6)
  $core.double get confirmedSats => $_getN(5);
  @$pb.TagNumber(6)
  set confirmedSats($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasConfirmedSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfirmedSats() => clearField(6);

  @$pb.TagNumber(7)
  $core.double get unconfirmedSats => $_getN(6);
  @$pb.TagNumber(7)
  set unconfirmedSats($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasUnconfirmedSats() => $_has(6);
  @$pb.TagNumber(7)
  void clearUnconfirmedSats() => clearField(7);
}

class WalletManagerServiceApi {
  $pb.RpcClient _client;
  WalletManagerServiceApi(this._client);

  $async.Future<GetWalletStatusResponse> getWalletStatus($pb.ClientContext? ctx, GetWalletStatusRequest request) =>
    _client.invoke<GetWalletStatusResponse>(ctx, 'WalletManagerService', 'GetWalletStatus', request, GetWalletStatusResponse())
  ;
  $async.Future<GenerateWalletResponse> generateWallet($pb.ClientContext? ctx, GenerateWalletRequest request) =>
    _client.invoke<GenerateWalletResponse>(ctx, 'WalletManagerService', 'GenerateWallet', request, GenerateWalletResponse())
  ;
  $async.Future<UnlockWalletResponse> unlockWallet($pb.ClientContext? ctx, UnlockWalletRequest request) =>
    _client.invoke<UnlockWalletResponse>(ctx, 'WalletManagerService', 'UnlockWallet', request, UnlockWalletResponse())
  ;
  $async.Future<LockWalletResponse> lockWallet($pb.ClientContext? ctx, LockWalletRequest request) =>
    _client.invoke<LockWalletResponse>(ctx, 'WalletManagerService', 'LockWallet', request, LockWalletResponse())
  ;
  $async.Future<EncryptWalletResponse> encryptWallet($pb.ClientContext? ctx, EncryptWalletRequest request) =>
    _client.invoke<EncryptWalletResponse>(ctx, 'WalletManagerService', 'EncryptWallet', request, EncryptWalletResponse())
  ;
  $async.Future<ChangePasswordResponse> changePassword($pb.ClientContext? ctx, ChangePasswordRequest request) =>
    _client.invoke<ChangePasswordResponse>(ctx, 'WalletManagerService', 'ChangePassword', request, ChangePasswordResponse())
  ;
  $async.Future<RemoveEncryptionResponse> removeEncryption($pb.ClientContext? ctx, RemoveEncryptionRequest request) =>
    _client.invoke<RemoveEncryptionResponse>(ctx, 'WalletManagerService', 'RemoveEncryption', request, RemoveEncryptionResponse())
  ;
  $async.Future<ListWalletsResponse> listWallets($pb.ClientContext? ctx, ListWalletsRequest request) =>
    _client.invoke<ListWalletsResponse>(ctx, 'WalletManagerService', 'ListWallets', request, ListWalletsResponse())
  ;
  $async.Future<SwitchWalletResponse> switchWallet($pb.ClientContext? ctx, SwitchWalletRequest request) =>
    _client.invoke<SwitchWalletResponse>(ctx, 'WalletManagerService', 'SwitchWallet', request, SwitchWalletResponse())
  ;
  $async.Future<UpdateWalletMetadataResponse> updateWalletMetadata($pb.ClientContext? ctx, UpdateWalletMetadataRequest request) =>
    _client.invoke<UpdateWalletMetadataResponse>(ctx, 'WalletManagerService', 'UpdateWalletMetadata', request, UpdateWalletMetadataResponse())
  ;
  $async.Future<DeleteWalletResponse> deleteWallet($pb.ClientContext? ctx, DeleteWalletRequest request) =>
    _client.invoke<DeleteWalletResponse>(ctx, 'WalletManagerService', 'DeleteWallet', request, DeleteWalletResponse())
  ;
  $async.Future<DeleteAllWalletsResponse> deleteAllWallets($pb.ClientContext? ctx, DeleteAllWalletsRequest request) =>
    _client.invoke<DeleteAllWalletsResponse>(ctx, 'WalletManagerService', 'DeleteAllWallets', request, DeleteAllWalletsResponse())
  ;
  $async.Future<CreateWatchOnlyWalletResponse> createWatchOnlyWallet($pb.ClientContext? ctx, CreateWatchOnlyWalletRequest request) =>
    _client.invoke<CreateWatchOnlyWalletResponse>(ctx, 'WalletManagerService', 'CreateWatchOnlyWallet', request, CreateWatchOnlyWalletResponse())
  ;
  $async.Future<CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ClientContext? ctx, CreateBitcoinCoreWalletRequest request) =>
    _client.invoke<CreateBitcoinCoreWalletResponse>(ctx, 'WalletManagerService', 'CreateBitcoinCoreWallet', request, CreateBitcoinCoreWalletResponse())
  ;
  $async.Future<EnsureCoreWalletsResponse> ensureCoreWallets($pb.ClientContext? ctx, EnsureCoreWalletsRequest request) =>
    _client.invoke<EnsureCoreWalletsResponse>(ctx, 'WalletManagerService', 'EnsureCoreWallets', request, EnsureCoreWalletsResponse())
  ;
  $async.Future<GetBalanceResponse> getBalance($pb.ClientContext? ctx, GetBalanceRequest request) =>
    _client.invoke<GetBalanceResponse>(ctx, 'WalletManagerService', 'GetBalance', request, GetBalanceResponse())
  ;
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, GetNewAddressRequest request) =>
    _client.invoke<GetNewAddressResponse>(ctx, 'WalletManagerService', 'GetNewAddress', request, GetNewAddressResponse())
  ;
  $async.Future<SendTransactionResponse> sendTransaction($pb.ClientContext? ctx, SendTransactionRequest request) =>
    _client.invoke<SendTransactionResponse>(ctx, 'WalletManagerService', 'SendTransaction', request, SendTransactionResponse())
  ;
  $async.Future<ListTransactionsResponse> listTransactions($pb.ClientContext? ctx, ListTransactionsRequest request) =>
    _client.invoke<ListTransactionsResponse>(ctx, 'WalletManagerService', 'ListTransactions', request, ListTransactionsResponse())
  ;
  $async.Future<ListUnspentResponse> listUnspent($pb.ClientContext? ctx, ListUnspentRequest request) =>
    _client.invoke<ListUnspentResponse>(ctx, 'WalletManagerService', 'ListUnspent', request, ListUnspentResponse())
  ;
  $async.Future<ListReceiveAddressesResponse> listReceiveAddresses($pb.ClientContext? ctx, ListReceiveAddressesRequest request) =>
    _client.invoke<ListReceiveAddressesResponse>(ctx, 'WalletManagerService', 'ListReceiveAddresses', request, ListReceiveAddressesResponse())
  ;
  $async.Future<GetTransactionDetailsResponse> getTransactionDetails($pb.ClientContext? ctx, GetTransactionDetailsRequest request) =>
    _client.invoke<GetTransactionDetailsResponse>(ctx, 'WalletManagerService', 'GetTransactionDetails', request, GetTransactionDetailsResponse())
  ;
  $async.Future<BumpFeeResponse> bumpFee($pb.ClientContext? ctx, BumpFeeRequest request) =>
    _client.invoke<BumpFeeResponse>(ctx, 'WalletManagerService', 'BumpFee', request, BumpFeeResponse())
  ;
  $async.Future<DeriveAddressesResponse> deriveAddresses($pb.ClientContext? ctx, DeriveAddressesRequest request) =>
    _client.invoke<DeriveAddressesResponse>(ctx, 'WalletManagerService', 'DeriveAddresses', request, DeriveAddressesResponse())
  ;
  $async.Future<GetWalletSeedResponse> getWalletSeed($pb.ClientContext? ctx, GetWalletSeedRequest request) =>
    _client.invoke<GetWalletSeedResponse>(ctx, 'WalletManagerService', 'GetWalletSeed', request, GetWalletSeedResponse())
  ;
  $async.Future<WatchWalletDataResponse> watchWalletData($pb.ClientContext? ctx, $12.Empty request) =>
    _client.invoke<WatchWalletDataResponse>(ctx, 'WalletManagerService', 'WatchWalletData', request, WatchWalletDataResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
