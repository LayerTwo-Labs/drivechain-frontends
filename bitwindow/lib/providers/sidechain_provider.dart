import 'dart:async';

import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/drivechain/v1/drivechain.pb.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';

class SidechainProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  BlockchainProvider get blockchainProvider => GetIt.I.get<BlockchainProvider>();
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();

  // This always has 255 slots. The fetch-method fills in the slots that
  // are actually in use.
  List<SidechainOverview?> sidechains = List.filled(255, null);

  List<SidechainProposal> sidechainProposals = [];

  bool _isFetching = false;

  String? error;

  SidechainProvider() {
    blockchainProvider.addListener(fetch);
  }

  // call this function from anywhere to refetch sidechain info
  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    try {
      final newSidechains = await bitwindowd.drivechain.listSidechains();
      final newSidechainProposals = await bitwindowd.drivechain.listSidechainProposals();

      // Create a new list with 255 slots
      List<SidechainOverview?> updatedSidechains = List.filled(255, null);

      // Fill in the slots with the data retrieved from the API
      for (var sidechain in newSidechains) {
        final deposits = await bitwindowd.wallet.listSidechainDeposits(sidechain.slot);
        if (sidechain.slot < 255) {
          updatedSidechains[sidechain.slot] = SidechainOverview(sidechain, deposits);
        }
      }

      if (_dataHasChanged(sidechains, updatedSidechains) ||
          _dataHasChanged(sidechainProposals, newSidechainProposals)) {
        sidechains = updatedSidechains;
        sidechainProposals = newSidechainProposals;
        error = null;
      }
    } catch (e) {
      log.e('could not fetch sidechains: $e');
      error = e.toString();
    } finally {
      _isFetching = false;
      notifyListeners();
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

  SidechainOverview(this.info, this.deposits);
}
