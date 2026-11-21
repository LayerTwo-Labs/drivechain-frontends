import 'package:sidechain_core/providers/network_scoped.dart';

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/bitcoin.dart';
import 'package:sidechain_core/classes/rpc_connection.dart';
import 'package:sidechain_core/env.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/providers/balance_provider.dart';
import 'package:sidechain_core/providers/wallet_reader_provider.dart';
import 'package:sidechain_core/rpcs/bitwindow_api.dart';
import 'package:sidechain_core/rpcs/orchestrator_rpc.dart';
import 'package:sidechain_core/rpcs/orchestrator_wallet_rpc.dart';

BmmBid _bmmBid(wmpb.BmmBid bid) => BmmBid(
  slot: bid.slot,
  criticalHash: bid.criticalHash,
  prevMainHash: bid.prevMainHash,
  lost: bid.lost,
);

/// One row per txid, newest first. Core gives one entry per output, so the
/// entries of a txid add up to one transaction.
@visibleForTesting
List<WalletTransaction> walletTransactionsFromEntries(
  List<wmpb.TransactionEntry> entries,
  Map<String, String> notes,
) {
  final byTxid = <String, WalletTransaction>{};
  // A replaced or conflicted tx never confirms. Core gives a conflicted
  // tx a negative count, and the unsigned height field cannot hold it.
  for (final tx in entries.where((tx) => tx.confirmations >= 0 && !tx.replacedByTxid)) {
    final received = tx.amountSats > Int64.ZERO ? tx.amountSats : Int64.ZERO;
    final sent = tx.amountSats < Int64.ZERO ? -tx.amountSats : Int64.ZERO;
    final fee = Int64((tx.fee.abs() * 100000000).round());
    final merged = byTxid[tx.txid];
    if (merged != null) {
      merged
        ..receivedSatoshi += received
        ..sentSatoshi += sent
        ..feeSats = merged.feeSats > fee ? merged.feeSats : fee
        ..immature = merged.immature || tx.category == 'immature';
      if (merged.warningMessage.isEmpty) {
        merged.warningMessage = tx.warningMessage;
      }
      continue;
    }
    byTxid[tx.txid] = WalletTransaction(
      txid: tx.txid,
      feeSats: fee,
      receivedSatoshi: received,
      sentSatoshi: sent,
      address: tx.hasSidechainDeposit() ? tx.sidechainDeposit.destination : tx.address,
      addressLabel: tx.label,
      note: notes[tx.txid] ?? '',
      warningMessage: tx.warningMessage,
      immature: tx.category == 'immature',
      confirmationTime: Confirmation(
        height: tx.confirmations,
        // Unconfirmed txs have blockTime 0, which would sink them
        // to the bottom of the list (off-screen) until a block
        // lands. Fall back to the wallet tx time so pending txs
        // sort to the top and show immediately.
        timestamp: Timestamp(seconds: tx.blockTime != Int64.ZERO ? tx.blockTime : tx.time),
      ),
      bmmBid: tx.hasBmmBid() ? _bmmBid(tx.bmmBid) : null,
      depositRequest: tx.hasSidechainDeposit()
          ? DepositRequest(slot: tx.sidechainDeposit.slot, destination: tx.sidechainDeposit.destination)
          : null,
    );
  }
  return byTxid.values.toList()..sort(_newestFirst);
}

int _newestFirst(WalletTransaction a, WalletTransaction b) {
  final aTime = a.confirmationTime.timestamp.seconds;
  final bTime = b.confirmationTime.timestamp.seconds;
  if (aTime == bTime) {
    return b.txid.compareTo(a.txid);
  }
  return bTime.compareTo(aTime);
}

/// [current] with the rows of [fresh], all wallet entries of new txs. Returns
/// null when nothing changes.
@visibleForTesting
List<WalletTransaction>? mergeNewestTransactions(
  List<WalletTransaction> current,
  List<wmpb.TransactionEntry> fresh, {
  bool onlyMissing = false,
}) {
  if (fresh.isEmpty) {
    return null;
  }
  final notes = {for (final tx in current) tx.txid: tx.note};
  final rows = {for (final tx in walletTransactionsFromEntries(fresh, notes)) tx.txid: tx};
  final byTxid = {for (final tx in current) tx.txid: tx};
  var changed = false;
  for (final txid in fresh.map((e) => e.txid).toSet()) {
    if (onlyMissing && byTxid.containsKey(txid)) {
      continue;
    }
    final row = rows[txid];
    if (row == null) {
      changed |= byTxid.remove(txid) != null;
    } else if (byTxid[txid] != row) {
      byTxid[txid] = row;
      changed = true;
    }
  }
  if (!changed) {
    return null;
  }
  return byTxid.values.toList()..sort(_newestFirst);
}

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
  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();

  String address = '';
  String addressDerivationPath = '';

  /// Last address error printed. A failure that stands, such as a wallet the
  /// network serves no chain source for, prints one time.
  String? _loggedAddressError;

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

  /// Balance frames with new txs, so a full read can tell that one came during it.
  int _freshFrames = 0;
  bool _refetchQueued = false;
  Timer? _fetchTimer;

  /// A failed read tries again on each tick.
  static const _retryInterval = Duration(seconds: 5);

  /// Ticks with no fetch before a wallet that read cleanly reads again. A new
  /// block, a balance change, a wallet switch and each app action fetch at once.
  static const _fallbackTicks = 12;
  int _idleTicks = 0;
  bool _listsRead = false;
  bool _addressRead = false;

  // A recreated transport abandons in-flight requests without ever completing
  // their futures, which would latch _isFetching for the rest of the session.
  static const _fetchTimeout = Duration(seconds: 30);

  String? _lastWalletId;

  TransactionProvider() {
    balanceProvider.addListener(fetch);
    balanceProvider.newestTransactions.addListener(_onNewestTransactions);
    _walletReader.addListener(_onWalletChanged);
    _startFetchingTimer();
  }

  /// Shows the entries of a balance frame before the full read ends.
  void _onNewestTransactions() {
    final newest = balanceProvider.newestTransactions.value;
    if (newest == null || !initialized || error != null) {
      return;
    }
    _freshFrames++;
    final merged = mergeNewestTransactions(walletTransactions, newest);
    if (merged == null) {
      return;
    }
    walletTransactions = merged;
    notifyListeners();
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

  void _startFetchingTimer() {
    fetch();

    if (Environment.isInTest) {
      return;
    }

    _fetchTimer = Timer.periodic(_retryInterval, (_) => tick());
  }

  @visibleForTesting
  void tick() {
    if (_listsRead && _addressRead && ++_idleTicks < _fallbackTicks) {
      return;
    }
    unawaited(fetch());
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
    _listsRead = false;
    _addressRead = false;
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
    _idleTicks = 0;
    final framesAtStart = _freshFrames;

    try {
      // Prefer the streamed activeWalletId, but self-heal against a slow/broken
      // WatchWalletData stream by asking the backend directly.
      String? activeId = _walletReader.activeWalletId;
      if (activeId == null) {
        final status = await orchestratorWallet.getWalletStatus();
        if (status.state == wmpb.WalletState.WALLET_STATE_NO_WALLET || status.activeWalletId.isEmpty) {
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
            final (fetchedTransactions, notes) = await (
              orchestratorWallet.listTransactions(walletId: walletId),
              bitwindowd.bitwindowd.listTransactionNotes(walletId: walletId),
            ).wait;
            return walletTransactionsFromEntries(fetchedTransactions.transactions, notes);
          },
          // A read that started before a frame does not hold its tx.
          (v) => walletTransactions = _freshFrames == framesAtStart
              ? v
              : mergeNewestTransactions(v, balanceProvider.newestTransactions.value ?? [], onlyMissing: true) ?? v,
          equals: const DeepCollectionEquality().equals,
        ).then((changed) {
          // A new transaction must not wait for the UTXO and address reads.
          if (changed && initialized && error == null && _walletReader.activeWalletId == walletId) {
            notifyListeners();
            return false;
          }
          return changed;
        }),
        update<List<UnspentOutput>>(
          utxos,
          () async {
            final (fetchedUtxos, bitwindowdUtxos) = await (
              orchestratorWallet.listUnspent(walletId),
              bitwindowd.wallet.listUnspent(walletId),
            ).wait;
            final denials = {
              for (final utxo in bitwindowdUtxos)
                if (utxo.hasDenialInfo()) utxo.output: utxo.denialInfo,
            };
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
                    inputWeightUnits: utxo.inputWeightUnits,
                    confirmations: utxo.confirmations,
                    denialInfo: denials['${utxo.txid}:${utxo.vout}'],
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
                    lastUsedAt: address.lastUsedAt,
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
          if (balanceProvider.streams(bitwindowd)) {
            return false;
          }
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

      _listsRead = true;
      // If any update returned true, notify listeners
      if (results.any((changed) => changed) || error != null) {
        initialized = true;
        error = null;
        notifyListeners();
      }
    } catch (e) {
      _listsRead = false;
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
      final changed = await update<({String address, String path})>(
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
      );
      _loggedAddressError = null;
      _addressRead = true;
      if (changed) {
        notifyListeners();
      }
    } catch (e) {
      _addressRead = false;
      final text = e.toString();
      if (!isExpectedBootError(e) && _loggedAddressError != text) {
        _log.w('TransactionProvider: address fetch failed: $e');
        _loggedAddressError = text;
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
    balanceProvider.newestTransactions.removeListener(_onNewestTransactions);
    _walletReader.removeListener(_onWalletChanged);
    _fetchTimer?.cancel();
    super.dispose();
  }
}
