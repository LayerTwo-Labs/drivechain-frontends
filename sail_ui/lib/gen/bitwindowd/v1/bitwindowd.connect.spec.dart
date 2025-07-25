//
//  Generated code. Do not modify.
//  source: bitwindowd/v1/bitwindowd.proto
//

import "package:connectrpc/connect.dart" as connect;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;
import "bitwindowd.pb.dart" as bitwindowdv1bitwindowd;

abstract final class BitwindowdService {
  /// Fully-qualified name of the BitwindowdService service.
  static const name = 'bitwindowd.v1.BitwindowdService';

  static const stop = connect.Spec(
    '/$name/Stop',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    googleprotobufempty.Empty.new,
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
}
