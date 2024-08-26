import 'package:auto_route/auto_route.dart';
import 'package:drivechain_client/routing/router.dart';
import 'package:flutter/material.dart';

@RoutePage()
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.tabBar(
      routes: const [
        OverviewRoute(),
        SendRoute(),
        ReceiveRoute(),
        TransactionsRoute(),
        SidechainsRoute(),
      ],
      builder: (context, child, controller) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            bottom: TabBar(
              controller: controller,
              tabs: const [
                Tab(
                  icon: Icon(Icons.home),
                  text: 'Overview',
                ),
                Tab(
                  icon: Icon(Icons.send),
                  text: 'Send',
                ),
                Tab(
                  icon: Icon(Icons.qr_code),
                  text: 'Receive',
                ),
                Tab(
                  icon: Icon(Icons.list),
                  text: 'Transactions',
                ),
                Tab(
                  icon: Icon(Icons.link),
                  text: 'Sidechains',
                ),
              ],
            ),
          ),
          body: child,
        );
      },
    );
  }
}
