//
//  Generated code. Do not modify.
//  source: bitwindowd/v1/bitwindowd.proto
//

import "package:connectrpc/connect.dart" as connect;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;
import "bitwindowd.connect.spec.dart" as specs;
import "bitwindowd.pb.dart" as bitwindowdv1bitwindowd;

extension type BitwindowdServiceClient(connect.Transport _transport) {
  Future<googleprotobufempty.Empty> stop(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.stop,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Deniability operations
  Future<googleprotobufempty.Empty> createDenial(
    bitwindowdv1bitwindowd.CreateDenialRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.createDenial,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<googleprotobufempty.Empty> cancelDenial(
    bitwindowdv1bitwindowd.CancelDenialRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.cancelDenial,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Wallet operations
  Future<bitwindowdv1bitwindowd.CreateAddressBookEntryResponse> createAddressBookEntry(
    bitwindowdv1bitwindowd.CreateAddressBookEntryRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.createAddressBookEntry,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitwindowdv1bitwindowd.ListAddressBookResponse> listAddressBook(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.listAddressBook,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<googleprotobufempty.Empty> updateAddressBookEntry(
    bitwindowdv1bitwindowd.UpdateAddressBookEntryRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.updateAddressBookEntry,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<googleprotobufempty.Empty> deleteAddressBookEntry(
    bitwindowdv1bitwindowd.DeleteAddressBookEntryRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.deleteAddressBookEntry,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitwindowdv1bitwindowd.GetSyncInfoResponse> getSyncInfo(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.getSyncInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<googleprotobufempty.Empty> setTransactionNote(
    bitwindowdv1bitwindowd.SetTransactionNoteRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.setTransactionNote,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitwindowdv1bitwindowd.GetFireplaceStatsResponse> getFireplaceStats(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.getFireplaceStats,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Lists the most recent transactions, both confirmed and unconfirmed.
  Future<bitwindowdv1bitwindowd.ListRecentTransactionsResponse> listRecentTransactions(
    bitwindowdv1bitwindowd.ListRecentTransactionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.listRecentTransactions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Lists blocks with pagination support
  Future<bitwindowdv1bitwindowd.ListBlocksResponse> listBlocks(
    bitwindowdv1bitwindowd.ListBlocksRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.listBlocks,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
