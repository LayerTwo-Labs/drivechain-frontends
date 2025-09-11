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
    Topic(id: Int64(1), topic: 'a1a1a1a1a1a1a1a1', name: 'US Weekly'),
    Topic(id: Int64(2), topic: 'a2a2a2a2a2a2a2a2', name: 'Japan Weekly'),
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

    try {
      final newNews = await api.misc.listCoinNews();
      final newTopics = await api.misc.listTopics();
      final newOPReturns = await api.misc.listOPReturns();

      if (_dataHasChanged(newNews, newTopics, newOPReturns)) {
        news = newNews;
        topics = newTopics;
        opReturns = newOPReturns;
        initialized = true;
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

  bool _dataHasChanged(
    List<CoinNews> newNews,
    List<Topic> newTopics,
    List<OPReturn> newOPReturns,
  ) {
    return !listEquals(news, newNews) || !listEquals(topics, newTopics) || !listEquals(opReturns, newOPReturns);
  }

  @override
  void dispose() {
    blockchainProvider.removeListener(fetch);
    super.dispose();
  }
}
