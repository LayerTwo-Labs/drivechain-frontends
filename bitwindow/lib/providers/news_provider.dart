import 'dart:async';

import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/misc/v1/misc.pb.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';

class NewsProvider extends ChangeNotifier {
  BitwindowRPC get api => GetIt.I.get<BitwindowRPC>();
  BlockchainProvider get blockchainProvider => GetIt.I.get<BlockchainProvider>();

  List<OPReturn> opReturns = [];
  List<CoinNews> news = [];
  List<Topic> topics = [
    Topic(id: Int64(1), topic: 'a1a1a1a1', name: 'US Weekly'),
    Topic(id: Int64(2), topic: 'a2a2a2a2', name: 'Japan Weekly'),
  ];
  bool initialized = false;
  String? error;

  bool _isFetching = false;

  NewsProvider() {
    blockchainProvider.addListener(fetch);
    fetch();
  }

  // call this function from anywhere to refetch news and topics
  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;
    error = null;

    List<String> errors = [];
    bool dataChanged = false;

    // Fetch news independently
    try {
      final newNews = await api.misc.listCoinNews();
      if (!listEquals(news, newNews)) {
        news = newNews;
        dataChanged = true;
      }
    } catch (e) {
      errors.add('News: ${e.toString()}');
    }

    // Fetch topics independently
    try {
      final newTopics = await api.misc.listTopics();
      if (!listEquals(topics, newTopics)) {
        topics = newTopics;
        dataChanged = true;
      }
    } catch (e) {
      errors.add('Topics: ${e.toString()}');
    }

    // Fetch OP_RETURNs independently
    try {
      final newOPReturns = await api.misc.listOPReturns();
      if (!listEquals(opReturns, newOPReturns)) {
        opReturns = newOPReturns;
        dataChanged = true;
      }
    } catch (e) {
      errors.add('OP_RETURNs: ${e.toString()}');
    }

    if (dataChanged || errors.isNotEmpty) {
      if (dataChanged) {
        initialized = true;
      }

      if (errors.isNotEmpty) {
        final newError = errors.join('; ');
        if (newError != error) {
          error = newError;
        }
      } else {
        error = null;
      }

      notifyListeners();
    }

    _isFetching = false;
  }

  @override
  void dispose() {
    blockchainProvider.removeListener(fetch);
    super.dispose();
  }
}
