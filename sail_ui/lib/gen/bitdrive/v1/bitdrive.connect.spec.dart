//
//  Generated code. Do not modify.
//  source: bitdrive/v1/bitdrive.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bitdrive.pb.dart" as bitdrivev1bitdrive;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

abstract final class BitDriveService {
  /// Fully-qualified name of the BitDriveService service.
  static const name = 'bitdrive.v1.BitDriveService';

  /// Store file/content to blockchain with optional encryption
  static const storeFile = connect.Spec(
    '/$name/StoreFile',
    connect.StreamType.unary,
    bitdrivev1bitdrive.StoreFileRequest.new,
    bitdrivev1bitdrive.StoreFileResponse.new,
  );

  /// Retrieve content from blockchain by txid
  static const retrieveContent = connect.Spec(
    '/$name/RetrieveContent',
    connect.StreamType.unary,
    bitdrivev1bitdrive.RetrieveContentRequest.new,
    bitdrivev1bitdrive.RetrieveContentResponse.new,
  );

  /// Scan for files in wallet transactions
  static const scanForFiles = connect.Spec(
    '/$name/ScanForFiles',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    bitdrivev1bitdrive.ScanForFilesResponse.new,
  );

  /// Download/restore pending files
  static const downloadPendingFiles = connect.Spec(
    '/$name/DownloadPendingFiles',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    bitdrivev1bitdrive.DownloadPendingFilesResponse.new,
  );

  /// List stored files from local storage
  static const listFiles = connect.Spec(
    '/$name/ListFiles',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    bitdrivev1bitdrive.ListFilesResponse.new,
  );

  /// Get file details
  static const getFile = connect.Spec(
    '/$name/GetFile',
    connect.StreamType.unary,
    bitdrivev1bitdrive.GetFileRequest.new,
    bitdrivev1bitdrive.GetFileResponse.new,
  );

  /// Delete local file (does not affect blockchain)
  static const deleteFile = connect.Spec(
    '/$name/DeleteFile',
    connect.StreamType.unary,
    bitdrivev1bitdrive.DeleteFileRequest.new,
    googleprotobufempty.Empty.new,
  );

  /// Store multisig group data on blockchain
  static const storeMultisigData = connect.Spec(
    '/$name/StoreMultisigData',
    connect.StreamType.unary,
    bitdrivev1bitdrive.StoreMultisigDataRequest.new,
    bitdrivev1bitdrive.StoreMultisigDataResponse.new,
  );

  /// Wipe all local BitDrive data
  static const wipeData = connect.Spec(
    '/$name/WipeData',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    googleprotobufempty.Empty.new,
  );
}
