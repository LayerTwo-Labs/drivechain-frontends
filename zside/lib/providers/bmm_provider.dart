import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:zside/pages/tabs/testchain/mainchain/bmm_tab_page.dart';
import 'package:zside/rpc/models/bmm_result.dart';
import 'package:zside/rpc/rpc_testchain.dart';

class BMMProvider extends ChangeNotifier {
  TestchainRPC get _rpc => GetIt.I.get<TestchainRPC>();
  Logger get log => GetIt.I.get<Logger>();

  List<BmmAttempt> bmmAttempts = [];
  bool initialized = false;

  // Based off of RefreshBMM in testchain
  // https://github.com/LayerTwo-Labs/testchain/blob/c44e3a737d1780a1a07135657ac0fd7686251933/src/qt/sidechainpage.cpp#L767
  void handleBmmTick(int bidAmountSats) async {
    final res = await _rpc.refreshBMM(bidAmountSats);
    final currentBlockCount = await _rpc.ping();

    if (res.error != null) {
      log.d('was not able to advance BMM: ${res.error}');
    }

    var attempt = BmmAttempt(
      result: res,
      bidSatoshis: bidAmountSats,

      // BMM attempts are always for the /next/ block height
      sidechainBlockHeight: currentBlockCount + 1,

      mainchainBlockHeight: await _rpc.mainBlockCount(),
    );

    // Add the attempt!
    if (res.bmmBlockCreated != null) {
      log.d('adding attempt: ${res.bmmBlockCreated}');
      _addAttempt(attempt);
    }

    // We were able to advance the chain, and must update its descendants.
    // (Or something like that... Not completely sure, tbh)
    if (res.bmmBlockSubmitted != null) {
      log.d('updating connected: ${res.bmmBlockSubmitted}');
      _updateConnected(res);
    }

    notifyListeners();
  }

  // Ported from SidechainBMMTableModel::AddAttempt in the testchain codebase
  void _addAttempt(BmmAttempt attempt) {
    bmmAttempts.insert(
      0,
      attempt,
    );

    // Skip if there are less than 2 BMM requests
    if (bmmAttempts.length < 2) {
      log.d('less than twp BMM requests, skipping');
      return;
    }

    // Skip the first (newest) entry
    const start = 1;
    // When we add a new attempt, set the last 6 BMM requests to failed if
    // they weren't connected - they have expired.
    const attemptsToUpdate = 6;
    bmmAttempts.slice(start, min(start + attemptsToUpdate, bmmAttempts.length)).forEach((attempt) {
      if (attempt.connected) {
        return;
      }

      log.d('marking attempt as failed: ${attempt.result.txid}');

      // If the attempt wasn't connected, it per def failed.
      attempt.failed = true;
    });
  }

  // Ported from SidechainBMMTableModel::UpdateForConnected in the testchain codebase
  void _updateConnected(BmmResult current) {
    //  auto it = std::find_if(model.begin(), model.end(),
    //     [ hashMerkleRoot ](BMMTableObject a) { return a.hashMerkleRoot == hashMerkleRoot; });
    final toUpdate =
        bmmAttempts.firstWhereOrNull((prev) => prev.result.bmmBlockCreated == current.bmmBlockSubmittedBlind);

    if (toUpdate == null) {
      log.w('was not able to find bmmBlockSubmittedBlind: ${current.bmmBlockSubmittedBlind}');
      return;
    }

    log.d('updating connected block: ${toUpdate.result.txid}');

    //  it->fFailed = false;
    // it->fConnected = true;
    toUpdate.failed = false;
    toUpdate.connected = true;
  }
}
