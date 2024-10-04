import 'dart:async';

import 'package:bitwindow/api.dart';
import 'package:bitwindow/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:bitwindow/gen/wallet/v1/wallet.pbgrpc.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class SidechainProvider extends ChangeNotifier {
  BlockchainProvider get blockchainProvider => GetIt.I.get<BlockchainProvider>();
  API get api => GetIt.I.get<API>();

  // This always has 255 slots. The fetch-method fills in the slots that
  // are actually in use.
  List<Sidechain?> sidechains = List.filled(255, null);

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
      final newSidechains = await api.drivechain.listSidechains();
      final newSidechainProposals = await api.drivechain.listSidechainProposals();

      // Create a new list with 255 slots
      List<Sidechain?> updatedSidechains = List.filled(255, null);

      // Fill in the slots with the data retrieved from the API
      for (var sidechain in newSidechains) {
        final deposits = await api.wallet.listSidechainDeposits(sidechain.slot);
        if (sidechain.slot < 255) {
          updatedSidechains[sidechain.slot] = Sidechain(sidechain, deposits);
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
      error = e.toString();
      notifyListeners();
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

class Sidechain {
  final ListSidechainsResponse_Sidechain info;
  final List<ListSidechainDepositsResponse_SidechainDeposit> deposits;

  Sidechain(this.info, this.deposits);
}
