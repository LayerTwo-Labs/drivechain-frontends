import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/console.dart';
import 'package:sidesail/routing/router.dart';

@RoutePage()
class EthereumRPCTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const EthereumRPCTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SailPage(
      scrollable: true,
      title: 'Ethereum RPC',
      subtitle:
          'Here you can call eth rpcs directly to the eth-sidechain. Try typing in "eth_blockNumber" in the input below.',
      body: Padding(
        padding: EdgeInsets.only(bottom: SailStyleValues.padding30),
        child: Column(
          children: [
            RPCWidget(),
          ],
        ),
      ),
    );
  }
}
