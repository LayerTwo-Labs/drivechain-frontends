//
//  Generated code. Do not modify.
//  source: bitdrive/v1/bitdrive.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bitdrive.pb.dart" as bitdrivev1bitdrive;
import "bitdrive.connect.spec.dart" as specs;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

extension type BitDriveServiceClient (connect.Transport _transport) {
  /// Store file/content to blockchain with optional encryption
  Future<bitdrivev1bitdrive.StoreFileResponse> storeFile(
    bitdrivev1bitdrive.StoreFileRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitDriveService.storeFile,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Retrieve content from blockchain by txid
  Future<bitdrivev1bitdrive.RetrieveContentResponse> retrieveContent(
    bitdrivev1bitdrive.RetrieveContentRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitDriveService.retrieveContent,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Scan for files in wallet transactions
  Future<bitdrivev1bitdrive.ScanForFilesResponse> scanForFiles(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitDriveService.scanForFiles,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Download/restore pending files
  Future<bitdrivev1bitdrive.DownloadPendingFilesResponse> downloadPendingFiles(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitDriveService.downloadPendingFiles,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List stored files from local storage
  Future<bitdrivev1bitdrive.ListFilesResponse> listFiles(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitDriveService.listFiles,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get file details
  Future<bitdrivev1bitdrive.GetFileResponse> getFile(
    bitdrivev1bitdrive.GetFileRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitDriveService.getFile,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Delete local file (does not affect blockchain)
  Future<googleprotobufempty.Empty> deleteFile(
    bitdrivev1bitdrive.DeleteFileRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitDriveService.deleteFile,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Store multisig group data on blockchain
  Future<bitdrivev1bitdrive.StoreMultisigDataResponse> storeMultisigData(
    bitdrivev1bitdrive.StoreMultisigDataRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitDriveService.storeMultisigData,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Wipe all local BitDrive data
  Future<googleprotobufempty.Empty> wipeData(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitDriveService.wipeData,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
