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

import 'package:protobuf/protobuf.dart' as $pb;

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
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
