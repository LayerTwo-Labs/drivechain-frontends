import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';

const _viewScope = 'sidechain-view';

String sidechainSessionScope(SidechainModule module) => 'sidechain-${module.chain.registryKey}';

/// The providers of one chain that BitWindow hosts, in a GetIt scope of their own.
class SidechainSession {
  final SidechainModule module;
  final SidechainRPC rpc;
  final ChainNavigator navigator;
  final SidechainBalanceProvider balance;
  SidechainBMMProvider? _bmm;
  final AddressProvider addresses;
  final SidechainTransactionsProvider transactions;
  final GenericSidechainConfProvider conf;
  final SidechainHomepageProvider homepage;
  final VoidCallback _stopEvents;

  SidechainSession._(
    this._stopEvents, {
    required this.module,
    required this.rpc,
    required this.navigator,
    required this.balance,
    required this.addresses,
    required this.transactions,
    required this.conf,
    required this.homepage,
  });

  /// Builds the providers of [module]. The chain-only types go in a scope of their
  /// own; the types that every chain shares stay out of GetIt until a view shows them.
  static Future<SidechainSession> _open(
    SidechainModule module, {
    required ChainNavigator navigator,
    required Directory applicationDir,
    required Logger log,
  }) async {
    final conf = await SidechainConfProvider.backed(sidechainConfProvider(module));
    final scope = sidechainSessionScope(module);
    late final SidechainRPC rpc;
    try {
      await GetIt.I.pushNewScopeAsync(
        scopeName: scope,
        init: (getIt) async {
          rpc = module.registerRPC(getIt);
          await module.registerChainProviders(getIt, applicationDir, log);
        },
      );
    } catch (_) {
      conf.dispose();
      rethrow;
    }

    try {
      // A lazy provider built later would start its work only when a page reads it.
      GetIt.I.findAll<Object>(onlyInScope: scope, instantiateLazySingletons: true);
      final transactions = SidechainTransactionsProvider(rpc: rpc);
      final balance = SidechainBalanceProvider(sidechain: rpc);
      return SidechainSession._(
        _watch(module, navigator, transactions, balance),
        module: module,
        rpc: rpc,
        navigator: navigator,
        balance: balance,
        addresses: AddressProvider(rpc: rpc),
        transactions: transactions,
        conf: conf,
        homepage: SidechainHomepageProvider(module),
      );
    } catch (_) {
      conf.dispose();
      await GetIt.I.dropScope(scope);
      rethrow;
    }
  }

  /// Starts the chain notifications, and the refetch on each new block.
  static VoidCallback _watch(
    SidechainModule module,
    ChainNavigator navigator,
    SidechainTransactionsProvider transactions,
    SidechainBalanceProvider balance,
  ) {
    final stopEvents = GetIt.I.isRegistered<NotificationProvider>()
        ? startChainEvents(
            module: module,
            navigator: navigator,
            notifications: GetIt.I.get<NotificationProvider>(),
            transactions: transactions,
          )
        : () {};
    if (!GetIt.I.isRegistered<SyncProvider>()) {
      return stopEvents;
    }

    final sync = GetIt.I.get<SyncProvider>();
    var height = sync.sidechainSyncInfo(module.chain)?.progressCurrent;
    void refetch() {
      unawaited(transactions.fetch());
      unawaited(balance.fetch());
    }

    void onSync() {
      final next = sync.sidechainSyncInfo(module.chain)?.progressCurrent;
      if (next != height) {
        height = next;
        refetch();
      }
    }

    void onBlock(int _) => refetch();
    sync.addListener(onSync);
    sync.onNewBlock(onBlock);
    return () {
      stopEvents();
      sync.removeListener(onSync);
      sync.offNewBlock(onBlock);
    };
  }

  /// Built when a page first reads it, because it watches the bids from then on.
  SidechainBMMProvider get bmm => _bmm ??= SidechainBMMProvider(sidechainRPC: rpc);

  /// Registers the chain types that BitWindow also holds, so the view of this chain reads them.
  void _registerView(GetIt getIt) {
    getIt.registerSingleton<SidechainModule>(module);
    getIt.registerSingleton<SidechainRPC>(rpc);
    getIt.registerSingleton<ChainNavigator>(navigator);
    getIt.registerSingleton<SidechainBalanceProvider>(balance);
    getIt.registerLazySingleton<SidechainBMMProvider>(() => bmm);
    getIt.registerSingleton<AddressProvider>(addresses);
    getIt.registerSingleton<SidechainTransactionsProvider>(transactions);
    getIt.registerSingleton<GenericSidechainConfProvider>(conf);
    getIt.registerSingleton<SidechainHomepageProvider>(homepage);
  }

  Future<void> _close() async {
    _stopEvents();
    _bmm?.dispose();
    balance.dispose();
    addresses.dispose();
    transactions.dispose();
    conf.dispose();
    homepage.dispose();
    await GetIt.I.dropScope(sidechainSessionScope(module));
  }
}

/// Keeps one session per hosted chain while its node runs or a view shows it.
///
/// The session scopes hold the chain-only types. One view scope holds the
/// shared types of the chain on screen, so no two scopes hold one type.
class HostedChains extends ChangeNotifier {
  final BinaryProvider binaries;
  final List<SidechainModule> modules;
  final Directory applicationDir;
  final Logger log;
  final ChainNavigator Function(SidechainModule module) navigatorFor;

  final _ops = SerialQueue();
  final Map<String, SidechainSession> _sessions = {};
  final Map<String, int> _views = {};
  final Set<String> _pending = {};
  String? _viewed;
  bool _closed = false;

  HostedChains({
    required this.binaries,
    required this.modules,
    required this.applicationDir,
    required this.log,
    required this.navigatorFor,
  }) {
    binaries.addListener(_reconcile);
    _reconcile();
  }

  /// The session of [module], or null while none runs.
  SidechainSession? session(SidechainModule module) => _sessions[module.chain.registryKey];

  /// Opens the session of [module] if necessary, and puts its view scope on top.
  Future<void> openView(SidechainModule module) {
    final key = module.chain.registryKey;
    _views[key] = (_views[key] ?? 0) + 1;
    return _ops.add(() async {
      await _openSession(module);
      if (_viewed == key) {
        return;
      }
      if (_viewed != null) {
        await GetIt.I.dropScope(_viewScope);
        _viewed = null;
      }
      _pushView(_sessions[key]!);
    });
  }

  /// Drops the view scope of [module]. The session stays while the node runs.
  Future<void> closeView(SidechainModule module) {
    final key = module.chain.registryKey;
    _views[key] = (_views[key] ?? 1) - 1;
    return _ops.add(() async {
      if (_views[key] == 0 && _viewed == key) {
        await GetIt.I.dropScope(_viewScope);
        _viewed = null;
      }
      _reconcileOne(module);
    });
  }

  /// Completes when every queued session change ran.
  @visibleForTesting
  Future<void> settled() async {
    while (_pending.isNotEmpty) {
      await _ops.add(() async {});
      await Future<void>.delayed(Duration.zero);
    }
    await _ops.add(() async {});
  }

  /// Closes every session, at shutdown.
  Future<void> closeAll() {
    _closed = true;
    binaries.removeListener(_reconcile);
    return _ops.add(() async {
      if (_viewed != null) {
        await GetIt.I.dropScope(_viewScope);
        _viewed = null;
      }
      for (final session in _sessions.values.toList().reversed) {
        await session._close();
      }
      _sessions.clear();
      notifyListeners();
    });
  }

  bool _nodeUp(SidechainModule module) {
    final binary = binaries.binaries.firstWhere((b) => b.type == module.chain.type, orElse: () => module.chain);
    return binaries.isConnected(binary) || binaries.isInitializing(binary);
  }

  bool _wanted(SidechainModule module) => !_closed && ((_views[module.chain.registryKey] ?? 0) > 0 || _nodeUp(module));

  void _reconcile() {
    for (final module in modules) {
      _reconcileOne(module);
    }
  }

  void _reconcileOne(SidechainModule module) {
    final key = module.chain.registryKey;
    if (_pending.contains(key) || _wanted(module) == _sessions.containsKey(key)) {
      return;
    }
    _pending.add(key);
    unawaited(
      _ops
          .add(() async {
            if (_wanted(module)) {
              await _openSession(module);
            } else {
              await _closeSession(module);
            }
          })
          .catchError((Object error) => log.e('could not update the ${module.appName} session: $error'))
          .whenComplete(() {
            _pending.remove(key);
            _reconcileOne(module);
          }),
    );
  }

  /// Runs inside [_ops].
  Future<void> _openSession(SidechainModule module) async {
    final key = module.chain.registryKey;
    if (_sessions.containsKey(key)) {
      return;
    }
    final session = await SidechainSession._open(
      module,
      navigator: navigatorFor(module),
      applicationDir: applicationDir,
      log: log,
    );
    _sessions[key] = session;
    session.balance.addListener(notifyListeners);
    notifyListeners();
  }

  /// Runs inside [_ops].
  Future<void> _closeSession(SidechainModule module) async {
    final session = _sessions.remove(module.chain.registryKey);
    if (session == null) {
      return;
    }
    session.balance.removeListener(notifyListeners);
    await session._close();
    notifyListeners();
  }

  void _pushView(SidechainSession session) {
    GetIt.I.pushNewScope(scopeName: _viewScope, init: session._registerView);
    _viewed = session.module.chain.registryKey;
  }

  @override
  void dispose() {
    binaries.removeListener(_reconcile);
    super.dispose();
  }
}
