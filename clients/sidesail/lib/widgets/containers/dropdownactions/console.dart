import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/rpc/rpc_ethereum.dart';

class ConsoleWindow extends StatelessWidget {
  const ConsoleWindow({super.key});

  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();
  SidechainContainer get sidechain => GetIt.I.get<SidechainContainer>();
  EnforcerRPC get enforcer => GetIt.I.get<EnforcerRPC>();

  @override
  Widget build(BuildContext context) {
    return SailRawCard(
      title: 'Debug Console',
      subtitle: 'Execute commands and view responses',
      child: ConsoleView(
        services: [
          ConsoleService(
            name: 'bitcoind',
            commands: mainchain.getMethods(),
            execute: (command, args) => mainchain.callRAW(command, args),
          ),
          if (sidechain.rpc.chain.name == ZCash().name)
            ConsoleService(
              name: 'zcash',
              commands: GetIt.I.get<ZCashRPC>().getMethods(),
              execute: (command, args) => GetIt.I.get<ZCashRPC>().callRAW(command, args),
            ),
          if (sidechain.rpc.chain.name == Thunder().name)
            ConsoleService(
              name: 'thunder',
              commands: GetIt.I.get<ThunderRPC>().getMethods(),
              execute: (command, args) => GetIt.I.get<ThunderRPC>().callRAW(command, args),
            ),
          if (sidechain.rpc.chain.name == EthereumSidechain().name)
            ConsoleService(
              name: 'ethereum',
              commands: GetIt.I.get<EthereumRPC>().getMethods(),
              execute: (command, args) => GetIt.I.get<EthereumRPC>().callRAW(command, args),
            ),
          if (sidechain.rpc.chain.name == Bitnames().name)
            ConsoleService(
              name: 'bitnames',
              commands: GetIt.I.get<BitnamesRPC>().getMethods(),
              execute: (command, args) => GetIt.I.get<BitnamesRPC>().callRAW(command, args),
            ),
        ],
      ),
    );
  }
}
