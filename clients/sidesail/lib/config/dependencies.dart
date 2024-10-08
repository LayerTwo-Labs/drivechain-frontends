import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/pages/tabs/settings/settings_tab.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/bmm_provider.dart';
import 'package:sidesail/providers/cast_provider.dart';
import 'package:sidesail/providers/notification_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/providers/zcash_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_config.dart';
import 'package:sidesail/rpc/rpc_ethereum.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/rpc/rpc_testchain.dart';
import 'package:sidesail/rpc/rpc_zcash.dart';

// This gets overwritten at a later point, just here to make the
// type system happy.
final _emptyNodeConf = SingleNodeConnectionSettings.empty();

// register all global dependencies, for use in views, or in view models
// each dependency can only be registered once
Future<void> initDependencies(Sidechain chain) async {
  final datadir = await RuntimeArgs.datadir();
  final log = await logger(RuntimeArgs.fileLog, RuntimeArgs.consoleLog, datadir);
  GetIt.I.registerLazySingleton<Logger>(() => log);
  final prefs = await SharedPreferences.getInstance();
  GetIt.I.registerLazySingleton<ClientSettings>(
    () => ClientSettings(
      store: Storage(
        preferences: prefs,
      ),
      log: log,
    ),
  );
  GetIt.I.registerLazySingleton<ProcessProvider>(() => ProcessProvider());

  GetIt.I.registerLazySingleton<NotificationProvider>(
    () => NotificationProvider(),
  );

  final sidechain = await findSubRPC(chain);
  final sidechainContainer = await SidechainContainer.create(sidechain);
  GetIt.I.registerLazySingleton<SidechainContainer>(
    () => sidechainContainer,
  );

  SingleNodeConnectionSettings mainchainConf = _emptyNodeConf;
  try {
    mainchainConf = await readRPCConfig(ParentChain().type.datadir(), 'drivechain.conf', ParentChain());
  } catch (error) {
    // do nothing
  }
  final mainchainRPC = await MainchainRPCLive.create(mainchainConf);
  GetIt.I.registerLazySingleton<MainchainRPC>(
    () => mainchainRPC,
  );

  GetIt.I.registerLazySingleton<AppRouter>(
    () => AppRouter(),
  );

  GetIt.I.registerLazySingleton<BalanceProvider>(
    // by registering an instance of the balance provider,
    // we start polling for balance updates
    () => BalanceProvider(),
  );

  GetIt.I.registerLazySingleton<TransactionsProvider>(
    () => TransactionsProvider(),
  );

  GetIt.I.registerLazySingleton<BMMProvider>(
    () => BMMProvider(),
  );

  GetIt.I.registerLazySingleton<ZCashProvider>(
    () => ZCashProvider(),
  );

  GetIt.I.registerLazySingleton<CastProvider>(
    () => CastProvider(),
  );
}

Future<SingleNodeConnectionSettings> findSidechainConf(Sidechain chain) async {
  SingleNodeConnectionSettings conf = _emptyNodeConf;
  switch (chain.type) {
    case ChainType.testchain:
      try {
        conf = await readRPCConfig(
          TestSidechain().type.datadir(),
          TestSidechain().type.confFile(),
          TestSidechain(),
        );
      } catch (error) {
        // do nothing, just don't exit
      }
      break;
    case ChainType.ethereum:
      try {
        conf = await readRPCConfig(
          EthereumSidechain().type.datadir(),
          EthereumSidechain().type.confFile(),
          EthereumSidechain(),
        );
      } catch (error) {
        // do nothing, just don't exit
      }
      break;
    case ChainType.zcash:
      try {
        conf = await readRPCConfig(
          ZCashSidechain().type.datadir(),
          ZCashSidechain().type.confFile(),
          ZCashSidechain(),
          overrideNetwork: 'regtest',
          useCookieAuth: false,
        );
      } catch (error) {
        // do nothing, just don't exit
      }
      break;

    case ChainType.parentchain:
      // do absolutely nothing, not a sidechain!
      break;
  }

  return conf;
}

// register all rpc connections. We attempt to create all
// rpcs in parallell, so they're ready instantly when swapping
// we can also query the balance
Future<SidechainRPC> findSubRPC(Sidechain chain) async {
  Logger log = GetIt.I.get<Logger>();
  final conf = await findSidechainConf(chain);

  SidechainRPC? sidechain;

  if (chain.type == ChainType.testchain) {
    log.i('starting init testchain RPC');

    final testchain = TestchainRPCLive(conf: conf);
    sidechain = testchain;

    if (!GetIt.I.isRegistered<TestchainRPC>()) {
      GetIt.I.registerLazySingleton<TestchainRPC>(
        () => testchain,
      );
    }
  }

  if (chain.type == ChainType.ethereum) {
    log.i('starting init ethereum RPC');

    final ethChain = EthereumRPCLive(
      conf: conf,
    );
    sidechain = ethChain;

    if (!GetIt.I.isRegistered<EthereumRPC>()) {
      GetIt.I.registerLazySingleton<EthereumRPC>(
        () => ethChain,
      );
    }
  }

  if (chain.type == ChainType.zcash) {
    log.i('starting init zcash RPC');

    final zChain = ZcashRPCLive(
      conf: conf,
    );
    sidechain = zChain;

    if (!GetIt.I.isRegistered<ZCashRPC>()) {
      GetIt.I.registerLazySingleton<ZCashRPC>(
        () => zChain,
      );
    }
  }

  return sidechain!;
}
