import 'package:sidechain_core/providers/network_scoped.dart';
import 'dart:async';

import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/bitcoin.dart';
import 'package:sidechain_core/classes/rpc_connection.dart';
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/gen/google/protobuf/timestamp.pb.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/providers/balance_provider.dart';
import 'package:sidechain_core/providers/wallet_reader_provider.dart';
import 'package:sidechain_core/rpcs/bitwindow_api.dart';
import 'package:sidechain_core/rpcs/orchestrator_rpc.dart';
import 'package:sidechain_core/rpcs/orchestrator_wallet_rpc.dart';

// because the class extends ChangeNotifier, any subscribers
// to this class will be notified of changes to new transactions
class TransactionProvider extends ChangeNotifier implements NetworkScoped {
  @override
  Future<void> onNetworkChanged() async {
    clear();
  }

  final Logger _log = GetIt.I.get<Logger>();
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();
  OrchestratorWalletRPC get orchestratorWallet => GetIt.I.get<OrchestratorRPC>().wallet;
  BalanceProvider get balanceProvider => GetIt.I.get<BalanceProvider>();
  BlockchainProvider get blockchainProvider => GetIt.I.get<BlockchainProvider>();
  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();

  String address = '';
  String addressDerivationPath = '';

  /// The kind the user picked, or UNSPECIFIED to take the wallet's own. A
  /// wallet on an explicit path derives one kind only, and asking for another
  /// makes the backend refuse every poll.
  wmpb.AddressType _pickedAddressType = wmpb.AddressType.ADDRESS_TYPE_UNSPECIFIED;

  wmpb.AddressType get addressType => _pickedAddressType != wmpb.AddressType.ADDRESS_TYPE_UNSPECIFIED
      ? _pickedAddressType
      : _walletReader.activeWallet?.defaultAddressType ?? wmpb.AddressType.ADDRESS_TYPE_UNSPECIFIED;

  /// The kinds the Receive tab offers. One entry means no choice to make.
  List<wmpb.AddressType> get addressTypes => _walletReader.activeWallet?.receiveAddressTypes ?? const [];
  List<WalletTransaction> walletTransactions = [];
  List<UnspentOutput> utxos = [];
  List<ReceiveAddress> receiveAddresses = [];
  bool initialized = false;
  String? error;

  bool _isFetching = false;
  bool _refetchQueued = false;
  Timer? _fetchTimer; // Timer to periodically fetch transactions

  // A recreated transport abandons in-flight requests without ever completing
  // their futures, which would latch _isFetching for the rest of the session.
  static const _fetchTimeout = Duration(seconds: 30);

  String? _lastWalletId;

  TransactionProvider() {
    balanceProvider.addListener(fetch);
    blockchainProvider.addListener(fetch);
    _walletReader.addListener(_onWalletChanged);
    _startFetchingTimer();
  }

  // Another wallet's addresses must never linger while the new ones load.
  void _onWalletChanged() {
    final walletId = _walletReader.activeWalletId;
    if (walletId != _lastWalletId) {
      _lastWalletId = walletId;
      clear();
    }
    fetch();
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
    _pickedAddressType = type;
    address = '';
    addressDerivationPath = '';
    notifyListeners();
    await fetch();
  }

  void clear() {
    walletTransactions = [];
    utxos = [];
    receiveAddresses = [];
    address = '';
    addressDerivationPath = '';
    _pickedAddressType = wmpb.AddressType.ADDRESS_TYPE_UNSPECIFIED;
    initialized = false;
    error = null;
    notifyListeners();
  }

  // call this function from anywhere to refetch transaction list
  Future<void> fetch() async {
    // Queue rather than drop: a wallet swap during a poll would otherwise wait
    // for the next timer tick, leaving the new wallet's list empty meanwhile.
    if (_isFetching) {
      _refetchQueued = true;
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

      // The receive address is local derivation, so it must not wait on the
      // chain-data batch below, which stalls whenever the indexer is down.
      unawaited(_updateReceiveAddress(walletId));

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
                    derivationPath: utxo.derivationPath,
                    splittable: utxo.hasSplittable() ? utxo.splittable : null,
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
                    derivationPath: address.derivationPath,
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
      ]).timeout(_fetchTimeout);

      // The wallet changed while this was in flight, so these results are stale.
      if (_walletReader.activeWalletId != walletId) {
        clear();
        _refetchQueued = true;
        return;
      }

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
      if (_refetchQueued) {
        _refetchQueued = false;
        unawaited(fetch());
      }
    }
  }

  Future<void> _updateReceiveAddress(String walletId) async {
    final requestedType = addressType;
    try {
      await update<({String address, String path})>(
        (address: address, path: addressDerivationPath),
        () async {
          final next = await orchestratorWallet.getNewAddress(walletId, addressType: requestedType);
          return (address: next.address, path: next.derivationPath);
        },
        (v) {
          // A wallet swap or type change while this was in flight would show
          // the wrong address.
          if (_walletReader.activeWalletId != walletId || addressType != requestedType) {
            return;
          }
          address = v.address;
          addressDerivationPath = v.path;
        },
        // Always update - backend handles finding unused address
        equals: (a, b) => false,
      );
      notifyListeners();
    } catch (e) {
      if (!isExpectedBootError(e)) {
        _log.w('TransactionProvider: address fetch failed: $e');
      }
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
    _walletReader.removeListener(_onWalletChanged);
    _fetchTimer?.cancel();
    super.dispose();
  }
}
