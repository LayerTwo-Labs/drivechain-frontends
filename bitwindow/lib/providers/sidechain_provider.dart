import 'dart:async';

import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/drivechain/v1/drivechain.pb.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/providers/wallet_reader_provider.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';

class SidechainProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  BlockchainProvider get blockchainProvider => GetIt.I.get<BlockchainProvider>();
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();
  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();

  // This always has 256 slots. The fetch-method fills in the slots that
  // are actually in use.
  List<SidechainOverview?> sidechains = List.filled(256, null);

  List<SidechainProposal> sidechainProposals = [];

  bool _isFetching = false;

  String? error;

  SidechainProvider() {
    blockchainProvider.addListener(fetch);
    fetch();
  }

  // call this function from anywhere to refetch sidechain info
  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');

      final newSidechains = await bitwindowd.drivechain.listSidechains();
      final newSidechainProposals = await bitwindowd.drivechain.listSidechainProposals();

      // Create a new list with 256 slots
      List<SidechainOverview?> updatedSidechains = List.filled(256, null);

      // Fill in the slots with the data retrieved from the API
      for (var sidechain in newSidechains) {
        final deposits = await bitwindowd.wallet.listSidechainDeposits(walletId, sidechain.slot);
        final withdrawals = await bitwindowd.drivechain.listWithdrawals(sidechainId: sidechain.slot);
        if (sidechain.slot < 255) {
          updatedSidechains[sidechain.slot] = SidechainOverview(sidechain, deposits, withdrawals);
        }
      }

      if (_dataHasChanged(sidechains, updatedSidechains) ||
          _dataHasChanged(sidechainProposals, newSidechainProposals)) {
        sidechains = updatedSidechains;
        sidechainProposals = newSidechainProposals;
        error = null;
        notifyListeners();
      }
    } catch (e) {
      if (e.toString() != error) {
        error = e.toString();
        notifyListeners();
      }
    } finally {
      _isFetching = false;
    }
  }

  bool _dataHasChanged<T>(List<T> oldData, List<T> newData) {
    if (!listEquals(oldData, newData)) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    blockchainProvider.removeListener(fetch);
    super.dispose();
  }
}

class SidechainOverview {
  final ListSidechainsResponse_Sidechain info;
  final List<ListSidechainDepositsResponse_SidechainDeposit> deposits;
  final List<WithdrawalBundle> withdrawals;

  SidechainOverview(this.info, this.deposits, this.withdrawals);
}
