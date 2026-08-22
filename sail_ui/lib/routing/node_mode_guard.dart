import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/providers/node_mode_provider.dart';

typedef NodeModeRoute = PageRouteInfo Function(VoidCallback onModePicked);

/// Guard that makes the user pick a node mode before anything else.
///
/// It runs ahead of [WalletGuard] on purpose: the mode decides whether
/// BitWindow starts a local node, so a wallet created before the choice would
/// pick a backend the mode cannot serve.
class NodeModeGuard extends AutoRouteGuard {
  final NodeModeRoute nodeModeRoute;

  NodeModeGuard({required this.nodeModeRoute});

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final nodeMode = GetIt.I.get<NodeModeProvider>();
    await nodeMode.load();

    if (!nodeMode.needsChoice) {
      resolver.next(true);
      return;
    }

    void resumeAfterChoice() {
      if (resolver.isResolved) {
        return;
      }
      unawaited(() async {
        await nodeMode.load();
        if (!resolver.isResolved) {
          resolver.next(!nodeMode.needsChoice);
        }
      }());
    }

    resolver.redirectUntil(nodeModeRoute(resumeAfterChoice));
  }
}
