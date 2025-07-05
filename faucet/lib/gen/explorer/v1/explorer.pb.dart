//
//  Generated code. Do not modify.
//  source: explorer/v1/explorer.proto
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

import '../../google/protobuf/timestamp.pb.dart' as $0;

class GetChainTipsRequest extends $pb.GeneratedMessage {
  factory GetChainTipsRequest() => create();
  GetChainTipsRequest._() : super();
  factory GetChainTipsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetChainTipsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChainTipsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetChainTipsRequest clone() => GetChainTipsRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetChainTipsRequest copyWith(void Function(GetChainTipsRequest) updates) =>
      super.copyWith((message) => updates(message as GetChainTipsRequest)) as GetChainTipsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChainTipsRequest create() => GetChainTipsRequest._();
  GetChainTipsRequest createEmptyInstance() => create();
  static $pb.PbList<GetChainTipsRequest> createRepeated() => $pb.PbList<GetChainTipsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetChainTipsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChainTipsRequest>(create);
  static GetChainTipsRequest? _defaultInstance;
}

class ChainTip extends $pb.GeneratedMessage {
  factory ChainTip({
    $core.String? hash,
    $fixnum.Int64? height,
    $0.Timestamp? timestamp,
  }) {
    final $result = create();
    if (hash != null) {
      $result.hash = hash;
    }
    if (height != null) {
      $result.height = height;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  ChainTip._() : super();
  factory ChainTip.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ChainTip.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChainTip',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'timestamp', subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ChainTip clone() => ChainTip()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ChainTip copyWith(void Function(ChainTip) updates) =>
      super.copyWith((message) => updates(message as ChainTip)) as ChainTip;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChainTip create() => ChainTip._();
  ChainTip createEmptyInstance() => create();
  static $pb.PbList<ChainTip> createRepeated() => $pb.PbList<ChainTip>();
  @$core.pragma('dart2js:noInline')
  static ChainTip getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChainTip>(create);
  static ChainTip? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get height => $_getI64(1);
  @$pb.TagNumber(2)
  set height($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get timestamp => $_getN(2);
  @$pb.TagNumber(3)
  set timestamp($0.Timestamp v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureTimestamp() => $_ensure(2);
}

class GetChainTipsResponse extends $pb.GeneratedMessage {
  factory GetChainTipsResponse({
    ChainTip? mainchain,
    ChainTip? thunder,
    ChainTip? bitassets,
    ChainTip? bitnames,
    ChainTip? zside,
  }) {
    final $result = create();
    if (mainchain != null) {
      $result.mainchain = mainchain;
    }
    if (thunder != null) {
      $result.thunder = thunder;
    }
    if (bitassets != null) {
      $result.bitassets = bitassets;
    }
    if (bitnames != null) {
      $result.bitnames = bitnames;
    }
    if (zside != null) {
      $result.zside = zside;
    }
    return $result;
  }
  GetChainTipsResponse._() : super();
  factory GetChainTipsResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetChainTipsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChainTipsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'explorer.v1'), createEmptyInstance: create)
    ..aOM<ChainTip>(1, _omitFieldNames ? '' : 'mainchain', subBuilder: ChainTip.create)
    ..aOM<ChainTip>(2, _omitFieldNames ? '' : 'thunder', subBuilder: ChainTip.create)
    ..aOM<ChainTip>(3, _omitFieldNames ? '' : 'bitassets', subBuilder: ChainTip.create)
    ..aOM<ChainTip>(4, _omitFieldNames ? '' : 'bitnames', subBuilder: ChainTip.create)
    ..aOM<ChainTip>(5, _omitFieldNames ? '' : 'zside', subBuilder: ChainTip.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetChainTipsResponse clone() => GetChainTipsResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetChainTipsResponse copyWith(void Function(GetChainTipsResponse) updates) =>
      super.copyWith((message) => updates(message as GetChainTipsResponse)) as GetChainTipsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChainTipsResponse create() => GetChainTipsResponse._();
  GetChainTipsResponse createEmptyInstance() => create();
  static $pb.PbList<GetChainTipsResponse> createRepeated() => $pb.PbList<GetChainTipsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetChainTipsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChainTipsResponse>(create);
  static GetChainTipsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ChainTip get mainchain => $_getN(0);
  @$pb.TagNumber(1)
  set mainchain(ChainTip v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasMainchain() => $_has(0);
  @$pb.TagNumber(1)
  void clearMainchain() => clearField(1);
  @$pb.TagNumber(1)
  ChainTip ensureMainchain() => $_ensure(0);

  @$pb.TagNumber(2)
  ChainTip get thunder => $_getN(1);
  @$pb.TagNumber(2)
  set thunder(ChainTip v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasThunder() => $_has(1);
  @$pb.TagNumber(2)
  void clearThunder() => clearField(2);
  @$pb.TagNumber(2)
  ChainTip ensureThunder() => $_ensure(1);

  @$pb.TagNumber(3)
  ChainTip get bitassets => $_getN(2);
  @$pb.TagNumber(3)
  set bitassets(ChainTip v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasBitassets() => $_has(2);
  @$pb.TagNumber(3)
  void clearBitassets() => clearField(3);
  @$pb.TagNumber(3)
  ChainTip ensureBitassets() => $_ensure(2);

  @$pb.TagNumber(4)
  ChainTip get bitnames => $_getN(3);
  @$pb.TagNumber(4)
  set bitnames(ChainTip v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasBitnames() => $_has(3);
  @$pb.TagNumber(4)
  void clearBitnames() => clearField(4);
  @$pb.TagNumber(4)
  ChainTip ensureBitnames() => $_ensure(3);

  @$pb.TagNumber(5)
  ChainTip get zside => $_getN(4);
  @$pb.TagNumber(5)
  set zside(ChainTip v) {
    setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasZside() => $_has(4);
  @$pb.TagNumber(5)
  void clearZside() => clearField(5);
  @$pb.TagNumber(5)
  ChainTip ensureZside() => $_ensure(4);
}

class ExplorerServiceApi {
  $pb.RpcClient _client;
  ExplorerServiceApi(this._client);

  $async.Future<GetChainTipsResponse> getChainTips($pb.ClientContext? ctx, GetChainTipsRequest request) =>
      _client.invoke<GetChainTipsResponse>(ctx, 'ExplorerService', 'GetChainTips', request, GetChainTipsResponse());
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
