import 'dart:async';

import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/providers/wallet_reader_provider.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/orchestrator_rpc.dart';
import 'package:sail_ui/rpcs/orchestrator_wallet_rpc.dart';

// because the class extends ChangeNotifier, any subscribers
// to this class will be notified of changes to new transactions
class TransactionProvider extends ChangeNotifier {
  final Logger _log = GetIt.I.get<Logger>();
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();
  OrchestratorWalletRPC get orchestratorWallet => GetIt.I.get<OrchestratorRPC>().wallet;
  BalanceProvider get balanceProvider => GetIt.I.get<BalanceProvider>();
  BlockchainProvider get blockchainProvider => GetIt.I.get<BlockchainProvider>();
  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();

  String address = '';
  wmpb.AddressType addressType = wmpb.AddressType.ADDRESS_TYPE_SEGWIT;
  List<WalletTransaction> walletTransactions = [];
  List<UnspentOutput> utxos = [];
  List<ReceiveAddress> receiveAddresses = [];
  bool initialized = false;
  String? error;

  bool _isFetching = false;
  Timer? _fetchTimer; // Timer to periodically fetch transactions

  TransactionProvider() {
    balanceProvider.addListener(fetch);
    blockchainProvider.addListener(fetch);
    _walletReader.addListener(fetch);
    _startFetchingTimer();
  }

  // Fetch transactions every 5 seconds, just in case something happens
  // automatically behind the scenes
  void _startFetchingTimer() {
    fetch();

    if (Environment.isInTest) {
      return;
    }

    _fetchTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetch();
    });
  }

  Future<void> setAddressType(wmpb.AddressType type) async {
    if (addressType == type) {
      return;
    }
    addressType = type;
    address = '';
    notifyListeners();
    await fetch();
  }

  void clear() {
    walletTransactions = [];
    utxos = [];
    receiveAddresses = [];
    address = '';
    initialized = false;
    error = null;
    notifyListeners();
  }

  // call this function from anywhere to refetch transaction list
  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    try {
      // Prefer the streamed activeWalletId, but self-heal against a slow/broken
      // WatchWalletData stream by asking the backend directly.
      String? activeId = _walletReader.activeWalletId;
      if (activeId == null) {
        final status = await orchestratorWallet.getWalletStatus();
        if (!status.hasWallet || status.activeWalletId.isEmpty) {
          throw Exception('No active wallet');
        }
        activeId = status.activeWalletId;
        _log.i('TransactionProvider: recovered activeWalletId=$activeId via getWalletStatus');
      }
      final String walletId = activeId;

      // Run all updates in parallel
      final results = await Future.wait([
        update<List<WalletTransaction>>(
          walletTransactions,
          () async {
            final fetchedTransactions = await orchestratorWallet.listTransactions(
              walletId: walletId,
            );
            final transactions = fetchedTransactions.transactions
                .map(
                  (tx) => WalletTransaction(
                    txid: tx.txid,
                    feeSats: Int64((tx.fee.abs() * 100000000).round()),
                    receivedSatoshi: tx.amountSats > Int64.ZERO ? tx.amountSats : Int64.ZERO,
                    sentSatoshi: tx.amountSats < Int64.ZERO ? -tx.amountSats : Int64.ZERO,
                    address: tx.address,
                    addressLabel: tx.label,
                    note: '',
                    confirmationTime: Confirmation(
                      height: tx.confirmations,
                      // Unconfirmed txs have blockTime 0, which would sink them
                      // to the bottom of the list (off-screen) until a block
                      // lands. Fall back to the wallet tx time so pending txs
                      // sort to the top and show immediately.
                      timestamp: Timestamp(seconds: tx.blockTime != Int64.ZERO ? tx.blockTime : tx.time),
                    ),
                  ),
                )
                .toList();
            // Sort by confirmation time, newest first
            transactions.sort((a, b) {
              final aTime = a.confirmationTime.timestamp.seconds;
              final bTime = b.confirmationTime.timestamp.seconds;
              if (aTime == bTime) {
                return b.txid.compareTo(a.txid);
              }
              return bTime.compareTo(aTime);
            });
            return transactions;
          },
          (v) => walletTransactions = v,
          equals: const DeepCollectionEquality().equals,
        ),
        update<String>(
          address,
          () async => (await orchestratorWallet.getNewAddress(walletId, addressType: addressType)).address,
          (v) => address = v,
          // Always update - backend handles finding unused address
          equals: (a, b) => false,
        ),
        update<List<UnspentOutput>>(
          utxos,
          () async {
            final fetchedUtxos = await orchestratorWallet.listUnspent(walletId);
            final utxos = fetchedUtxos.utxos
                .map(
                  (utxo) => UnspentOutput(
                    output: '${utxo.txid}:${utxo.vout}',
                    address: utxo.address,
                    label: utxo.label,
                    valueSats: utxo.amountSats,
                    isChange: false,
                    receivedAt: utxo.hasReceivedAt() ? utxo.receivedAt : null,
                  ),
                )
                .toList();
            utxos.sort((a, b) {
              final aTime = a.receivedAt.seconds;
              final bTime = b.receivedAt.seconds;
              if (aTime == bTime) {
                return b.output.compareTo(a.output);
              }
              return bTime.compareTo(aTime);
            });
            return utxos;
          },
          (v) => utxos = v,
          equals: const DeepCollectionEquality().equals,
        ),
        update<List<ReceiveAddress>>(
          receiveAddresses,
          () async {
            final fetchedAddresses = await orchestratorWallet.listReceiveAddresses(walletId);
            final addresses = fetchedAddresses.addresses
                .map(
                  (address) => ReceiveAddress(
                    address: address.address,
                    label: address.label,
                    currentBalanceSat: address.amountSats,
                    isChange: address.isChange,
                    lastUsedAt: Timestamp(),
                  ),
                )
                .toList();
            addresses.sort((a, b) {
              return a.address.compareTo(b.address);
            });
            return addresses;
          },
          (v) => receiveAddresses = v,
          equals: const DeepCollectionEquality().equals,
        ),
        () async {
          final balance = await orchestratorWallet.getBalance(walletId);
          balanceProvider.setBalance(
            bitwindowd,
            satoshiToBTC(balance.confirmedSats.round()),
            satoshiToBTC(balance.unconfirmedSats.round()),
          );
          return false;
        }(),
      ]);

      // If any update returned true, notify listeners
      if (results.any((changed) => changed) || error != null) {
        initialized = true;
        error = null;
        notifyListeners();
      }
    } catch (e) {
      if (e.toString() != error) {
        if (!isExpectedBootError(e)) {
          _log.w('TransactionProvider: fetch failed: $e');
        }
        error = e.toString();
        notifyListeners();
      }
    } finally {
      _isFetching = false;
    }
  }

  Future<bool> update<T>(
    T currentValue,
    Future<T> Function() fetch,
    void Function(T) setValue, {
    bool Function(T a, T b)? equals,
  }) async {
    final newValue = await fetch();
    final isEqual = equals != null ? equals(currentValue, newValue) : currentValue == newValue;

    if (!isEqual) {
      setValue(newValue);
      return true;
    }
    return false;
  }

  Future<void> saveNote(String txid, String note) async {
    // Notes are stored per wallet, so write to the one being listed.
    await bitwindowd.bitwindowd.setTransactionNote(txid, note, walletId: _walletReader.activeWalletId ?? '');
    await fetch();
  }

  @override
  void dispose() {
    balanceProvider.removeListener(fetch);
    blockchainProvider.removeListener(fetch);
    _walletReader.removeListener(fetch);
    _fetchTimer?.cancel();
    super.dispose();
  }
}
