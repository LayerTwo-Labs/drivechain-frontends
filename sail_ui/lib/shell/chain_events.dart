import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/chain_navigator.dart';
import 'package:sail_ui/shell/sidechain_home_page.dart';
import 'package:sail_ui/shell/sidechain_module.dart';

/// The notification action that opens a tab of a sidechain.
const sidechainTabAction = 'sidechain-tab';

/// Something that happened on a sidechain, and the tab that shows it.
class ChainEvent {
  /// Stable for one event, so the notification shows one time.
  final String id;
  final String title;
  final String content;
  final PageRouteInfo tab;

  const ChainEvent({required this.id, required this.title, required this.content, required this.tab});
}

/// The tab route of [module] with the route name [name], or null.
PageRouteInfo? chainTabNamed(SidechainModule module, String name) {
  for (final tab in shellTabRoutes(module)) {
    if (tab.routeName == name) {
      return tab;
    }
  }
  return null;
}

/// Puts [event] in the notification history. A click opens its tab through [navigator].
void postChainEvent(
  NotificationProvider notifications,
  SidechainModule module,
  ChainNavigator navigator,
  ChainEvent event,
) {
  notifications.add(
    id: event.id,
    title: event.title,
    content: event.content,
    dialogType: DialogType.success,
    action: sidechainTabAction,
    data: {'chain': module.chain.registryKey, 'tab': event.tab.routeName},
    onPressed: () => navigator.openTab(event.tab),
  );
}

/// The handler of [sidechainTabAction]. It opens the tab that the notification names.
NotificationActionHandler sidechainTabHandler({
  required SidechainModule? Function(String registryKey) moduleFor,
  required ChainNavigator Function(SidechainModule module) navigatorFor,
}) {
  return (context, item) async {
    final module = moduleFor(item.data['chain'] ?? '');
    if (module == null) {
      return false;
    }
    final tab = chainTabNamed(module, item.data['tab'] ?? '');
    if (tab == null) {
      return false;
    }
    await navigatorFor(module).openTab(tab);
    return true;
  };
}

/// Reports each deposit that the wallet of a chain receives after the first UTXO list.
class DepositWatcher {
  final SidechainModule module;
  final SidechainTransactionsProvider transactions;
  final String Function(int sats) formatSats;
  final void Function(ChainEvent event) notify;

  Set<String>? _known;

  DepositWatcher({
    required this.module,
    required this.transactions,
    required this.formatSats,
    required this.notify,
  }) {
    transactions.addListener(_onUTXOs);
    _onUTXOs();
  }

  void _onUTXOs() {
    if (!transactions.utxosLoaded) {
      return;
    }
    final deposits = {
      for (final utxo in transactions.utxos)
        if (utxo.type == OutpointType.deposit && utxo.confirmed) utxo.outpoint: utxo,
    };
    final known = _known;
    _known = deposits.keys.toSet();
    if (known == null) {
      return;
    }
    for (final MapEntry(key: outpoint, value: utxo) in deposits.entries) {
      if (known.contains(outpoint)) {
        continue;
      }
      notify(
        ChainEvent(
          id: 'deposit-${module.chain.registryKey}-$outpoint',
          title: 'Deposit received on ${module.appName}',
          content: '${formatSats(utxo.valueSats)} is in your ${module.appName} wallet.',
          tab: const ParentChainRoute(),
        ),
      );
    }
  }

  void dispose() {
    transactions.removeListener(_onUTXOs);
  }
}

/// Starts the deposit watcher on [transactions] and the chain watchers of [module].
/// The returned function stops them.
VoidCallback startChainEvents({
  required SidechainModule module,
  required ChainNavigator navigator,
  required NotificationProvider notifications,
  required SidechainTransactionsProvider transactions,
}) {
  final getIt = GetIt.I;
  void notify(ChainEvent event) => postChainEvent(notifications, module, navigator, event);

  final deposits = DepositWatcher(
    module: module,
    transactions: transactions,
    formatSats: getIt.get<FormatterProvider>().formatSats,
    notify: notify,
  );
  final stopChain = module.watchChainEvents(getIt, notify);

  return () {
    deposits.dispose();
    stopChain();
  };
}
