import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pb.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/nav/bottom_nav.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';

class StatusBar extends StatefulWidget {
  const StatusBar({super.key});

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  BlockchainProvider get blockchainProvider => GetIt.I.get<BlockchainProvider>();
  BalanceProvider get balanceProvider => GetIt.I.get<BalanceProvider>();
  SidechainContainer get sidechain => GetIt.I.get<SidechainContainer>();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    balanceProvider.addListener(setstate);
  }

  void setstate() {
    setState(() {});
  }

  String _getTimeSinceLastBlock() {
    if (blockchainProvider.lastBlockAt == null) {
      return 'Unknown';
    }

    final now = DateTime.now();
    final lastBlockTime = blockchainProvider.lastBlockAt!.toDateTime().toLocal();
    final difference = now.difference(lastBlockTime);

    if (difference.inDays > 0) {
      return '${formatTimeDifference(difference.inDays, 'day')} ago';
    } else if (difference.inHours > 0) {
      return '${formatTimeDifference(difference.inHours, 'hour')} ago';
    } else if (difference.inMinutes > 0) {
      return '${formatTimeDifference(difference.inMinutes, 'minute')} ago';
    } else {
      return '${formatTimeDifference(difference.inSeconds, 'second')} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNav(
      mainchainInfo: false,
      additionalConnection: ConnectionMonitor(
        rpc: sidechain.rpc,
        name: sidechain.rpc.chain.name,
      ),
      navigateToLogs: (title, logPath) {
        GetIt.I.get<AppRouter>().push(
              LogRoute(
                title: title,
                logPath: logPath,
              ),
            );
      },
      endWidgets: [
        Tooltip(
          message: blockchainProvider.recentBlocks.firstOrNull?.toPretty() ?? '',
          child: SailText.primary12('Last block: ${_getTimeSinceLastBlock()}'),
        ),
        const DividerDot(),
        if (blockchainProvider.blockchainInfo.initialBlockDownload &&
            blockchainProvider.blockchainInfo.blocks != blockchainProvider.blockchainInfo.headers)
          Tooltip(
            message:
                'Current height: ${blockchainProvider.blockchainInfo.blocks}\nHeader height: ${blockchainProvider.blockchainInfo.headers}',
            child: SailText.primary12(
              'Downloading blocks (${blockchainProvider.verificationProgress} %)',
            ),
          ),
        if (blockchainProvider.blockchainInfo.initialBlockDownload &&
            blockchainProvider.blockchainInfo.blocks != blockchainProvider.blockchainInfo.headers)
          const DividerDot(),
        SailText.primary12(
          '${formatWithThousandSpacers(blockchainProvider.blockchainInfo.blocks)} blocks',
        ),
        const DividerDot(),
        Tooltip(
          message: blockchainProvider.peers.map((e) => 'Peer id=${e.id} addr=${e.addr}').join('\n'),
          child: SailText.primary12(
            formatTimeDifference(blockchainProvider.peers.length, 'peer'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    balanceProvider.removeListener(setstate);
    super.dispose();
  }
}

String formatTimeDifference(int value, String unit) {
  return '$value $unit${value == 1 ? '' : 's'}';
}

extension on Block {
  String toPretty() {
    return 'Block $blockHeight\nBlockTime=${blockTime.toDateTime().format()}\nHash=$hash';
  }
}
