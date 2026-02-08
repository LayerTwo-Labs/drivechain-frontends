//
//  Generated code. Do not modify.
//  source: bitdrive/v1/bitdrive.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../google/protobuf/empty.pb.dart' as $1;
import 'bitdrive.pb.dart' as $2;
import 'bitdrive.pbjson.dart';

export 'bitdrive.pb.dart';

abstract class BitDriveServiceBase extends $pb.GeneratedService {
  $async.Future<$2.StoreFileResponse> storeFile($pb.ServerContext ctx, $2.StoreFileRequest request);
  $async.Future<$2.RetrieveContentResponse> retrieveContent($pb.ServerContext ctx, $2.RetrieveContentRequest request);
  $async.Future<$2.ScanForFilesResponse> scanForFiles($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$2.DownloadPendingFilesResponse> downloadPendingFiles($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$2.ListFilesResponse> listFiles($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$2.GetFileResponse> getFile($pb.ServerContext ctx, $2.GetFileRequest request);
  $async.Future<$1.Empty> deleteFile($pb.ServerContext ctx, $2.DeleteFileRequest request);
  $async.Future<$2.StoreMultisigDataResponse> storeMultisigData($pb.ServerContext ctx, $2.StoreMultisigDataRequest request);
  $async.Future<$1.Empty> wipeData($pb.ServerContext ctx, $1.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'StoreFile': return $2.StoreFileRequest();
      case 'RetrieveContent': return $2.RetrieveContentRequest();
      case 'ScanForFiles': return $1.Empty();
      case 'DownloadPendingFiles': return $1.Empty();
      case 'ListFiles': return $1.Empty();
      case 'GetFile': return $2.GetFileRequest();
      case 'DeleteFile': return $2.DeleteFileRequest();
      case 'StoreMultisigData': return $2.StoreMultisigDataRequest();
      case 'WipeData': return $1.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'StoreFile': return this.storeFile(ctx, request as $2.StoreFileRequest);
      case 'RetrieveContent': return this.retrieveContent(ctx, request as $2.RetrieveContentRequest);
      case 'ScanForFiles': return this.scanForFiles(ctx, request as $1.Empty);
      case 'DownloadPendingFiles': return this.downloadPendingFiles(ctx, request as $1.Empty);
      case 'ListFiles': return this.listFiles(ctx, request as $1.Empty);
      case 'GetFile': return this.getFile(ctx, request as $2.GetFileRequest);
      case 'DeleteFile': return this.deleteFile(ctx, request as $2.DeleteFileRequest);
      case 'StoreMultisigData': return this.storeMultisigData(ctx, request as $2.StoreMultisigDataRequest);
      case 'WipeData': return this.wipeData(ctx, request as $1.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitDriveServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitDriveServiceBase$messageJson;
}

