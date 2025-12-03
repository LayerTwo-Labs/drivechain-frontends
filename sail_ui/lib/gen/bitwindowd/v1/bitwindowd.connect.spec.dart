//
//  Generated code. Do not modify.
//  source: bitwindowd/v1/bitwindowd.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bitwindowd.pb.dart" as bitwindowdv1bitwindowd;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

abstract final class BitwindowdService {
  /// Fully-qualified name of the BitwindowdService service.
  static const name = 'bitwindowd.v1.BitwindowdService';

  static const stop = connect.Spec(
    '/$name/Stop',
    connect.StreamType.unary,
    bitwindowdv1bitwindowd.StopBitwindowRequest.new,
    googleprotobufempty.Empty.new,
  );

  static const mineBlocks = connect.Spec(
    '/$name/MineBlocks',
    connect.StreamType.server,
    googleprotobufempty.Empty.new,
    bitwindowdv1bitwindowd.MineBlocksResponse.new,
  );

  /// Deniability operations
  static const createDenial = connect.Spec(
    '/$name/CreateDenial',
    connect.StreamType.unary,
    bitwindowdv1bitwindowd.CreateDenialRequest.new,
    googleprotobufempty.Empty.new,
  );

  static const cancelDenial = connect.Spec(
    '/$name/CancelDenial',
    connect.StreamType.unary,
    bitwindowdv1bitwindowd.CancelDenialRequest.new,
    googleprotobufempty.Empty.new,
  );

  static const pauseDenial = connect.Spec(
    '/$name/PauseDenial',
    connect.StreamType.unary,
    bitwindowdv1bitwindowd.PauseDenialRequest.new,
    googleprotobufempty.Empty.new,
  );

  static const resumeDenial = connect.Spec(
    '/$name/ResumeDenial',
    connect.StreamType.unary,
    bitwindowdv1bitwindowd.ResumeDenialRequest.new,
    googleprotobufempty.Empty.new,
  );

  /// Wallet operations
  static const createAddressBookEntry = connect.Spec(
    '/$name/CreateAddressBookEntry',
    connect.StreamType.unary,
    bitwindowdv1bitwindowd.CreateAddressBookEntryRequest.new,
    bitwindowdv1bitwindowd.CreateAddressBookEntryResponse.new,
  );

  static const listAddressBook = connect.Spec(
    '/$name/ListAddressBook',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    bitwindowdv1bitwindowd.ListAddressBookResponse.new,
  );

  static const updateAddressBookEntry = connect.Spec(
    '/$name/UpdateAddressBookEntry',
    connect.StreamType.unary,
    bitwindowdv1bitwindowd.UpdateAddressBookEntryRequest.new,
    googleprotobufempty.Empty.new,
  );

  static const deleteAddressBookEntry = connect.Spec(
    '/$name/DeleteAddressBookEntry',
    connect.StreamType.unary,
    bitwindowdv1bitwindowd.DeleteAddressBookEntryRequest.new,
    googleprotobufempty.Empty.new,
  );

  static const getSyncInfo = connect.Spec(
    '/$name/GetSyncInfo',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    bitwindowdv1bitwindowd.GetSyncInfoResponse.new,
  );

  static const setTransactionNote = connect.Spec(
    '/$name/SetTransactionNote',
    connect.StreamType.unary,
    bitwindowdv1bitwindowd.SetTransactionNoteRequest.new,
    googleprotobufempty.Empty.new,
  );

  static const getFireplaceStats = connect.Spec(
    '/$name/GetFireplaceStats',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    bitwindowdv1bitwindowd.GetFireplaceStatsResponse.new,
  );

  /// Lists the most recent transactions, both confirmed and unconfirmed.
  static const listRecentTransactions = connect.Spec(
    '/$name/ListRecentTransactions',
    connect.StreamType.unary,
    bitwindowdv1bitwindowd.ListRecentTransactionsRequest.new,
    bitwindowdv1bitwindowd.ListRecentTransactionsResponse.new,
  );

  /// Lists blocks with pagination support
  static const listBlocks = connect.Spec(
    '/$name/ListBlocks',
    connect.StreamType.unary,
    bitwindowdv1bitwindowd.ListBlocksRequest.new,
    bitwindowdv1bitwindowd.ListBlocksResponse.new,
  );

  /// Get network statistics
  static const getNetworkStats = connect.Spec(
    '/$name/GetNetworkStats',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    bitwindowdv1bitwindowd.GetNetworkStatsResponse.new,
  );
}
