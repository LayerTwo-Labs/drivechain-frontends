import 'dart:async';

import 'package:bitwindow/gen/misc/v1/misc.pbgrpc.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/servers/api.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class NewsProvider extends ChangeNotifier {
  API get api => GetIt.I.get<API>();
  BlockchainProvider get blockchainProvider => GetIt.I.get<BlockchainProvider>();

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

      if (_dataHasChanged(newNews, newTopics)) {
        news = newNews;
        topics = newTopics;
        initialized = true;
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

  bool _dataHasChanged(
    List<CoinNews> newNews,
    List<Topic> newTopics,
  ) {
    return !listEquals(news, newNews) || !listEquals(topics, newTopics);
  }

  @override
  void dispose() {
    blockchainProvider.removeListener(fetch);
    super.dispose();
  }
}
