import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class ConsoleWindow extends StatelessWidget {
  const ConsoleWindow({super.key});

  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();
  BitAssetsRPC get rpc => GetIt.I.get<BitAssetsRPC>();
  EnforcerRPC get enforcer => GetIt.I.get<EnforcerRPC>();

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'BitAssets Console',
      subtitle: 'Execute commands and view responses',
      child: ConsoleView(
        services: [
          ConsoleService(
            name: 'bitcoind',
            commands: mainchain.getMethods(),
            execute: (command, args) => mainchain.callRAW(command, args),
          ),
          ConsoleService(
            name: 'bitassets',
            commands: rpc.getMethods(),
            execute: (command, args) => rpc.callRAW(command, args),
          ),
        ],
      ),
    );
  }
}
