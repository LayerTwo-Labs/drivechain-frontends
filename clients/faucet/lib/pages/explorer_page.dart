import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:faucet/providers/explorer_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

// Define a Block model that matches the ChainTip from the proto
class Block {
  final String hash;
  final int blockHeight;
  final DateTime blockTime;

  Block({
    required this.hash,
    required this.blockHeight,
    required this.blockTime,
  });

  // Format the block time in a human-friendly way
  String get formattedTime {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(blockTime.toLocal());
  }

  // Calculate time since block was mined
  String timeSince() {
    final now = DateTime.now();
    final difference = now.difference(blockTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return '${difference.inSeconds} ${difference.inSeconds == 1 ? 'second' : 'seconds'} ago';
    }
  }
}

class ExplorerViewModel extends BaseViewModel {
  ExplorerProvider get explorerProvider => GetIt.I.get<ExplorerProvider>();
  Timer? _timeUpdateTimer;

  Block? get latestMainchainBlock => explorerProvider.mainchainTip != null
      ? Block(
          hash: explorerProvider.mainchainTip!.hash,
          blockHeight: explorerProvider.mainchainTip!.height.toInt(),
          blockTime: explorerProvider.mainchainTip!.timestamp.toDateTime(),
        )
      : null;

  Block? get latestThunderBlock => explorerProvider.thunderTip != null
      ? Block(
          hash: explorerProvider.thunderTip!.hash,
          blockHeight: explorerProvider.thunderTip!.height.toInt(),
          blockTime: explorerProvider.thunderTip!.timestamp.toDateTime(),
        )
      : null;

  ExplorerViewModel() {
    explorerProvider.addListener(notifyListeners);
    // Start timer for updating "time ago" text
    startTimeUpdateTimer();
  }

  void refreshData() {
    explorerProvider.fetch();
  }

  void startTimeUpdateTimer() {
    // Cancel any existing timer
    _timeUpdateTimer?.cancel();

    // Create a new timer that updates the UI every second
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Just notify listeners to update the UI
      notifyListeners();
    });
  }

  @override
  void dispose() {
    explorerProvider.removeListener(notifyListeners);
    _timeUpdateTimer?.cancel();
    super.dispose();
  }
}

@RoutePage()
class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => ExplorerViewModel(),
        builder: ((context, model, child) {
          return Padding(
            padding: const EdgeInsets.all(SailStyleValues.padding16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Horizontal layout for block cards
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mainchain block card
                    Expanded(
                      child: SailRawCard(
                        title: 'Latest Mainchain Block',
                        subtitle: 'Most recent block on the mainchain',
                        child: model.latestMainchainBlock != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Height: ${model.latestMainchainBlock!.blockHeight}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Hash: ${model.latestMainchainBlock!.hash}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Time: ${model.latestMainchainBlock!.formattedTime}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    model.latestMainchainBlock!.timeSince(),
                                    style: TextStyle(
                                      color: context.sailTheme.colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Unable to connect to Mainchain',
                                    style: TextStyle(
                                      color: context.sailTheme.colors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(width: SailStyleValues.padding16),
                    // Thunder block card
                    Expanded(
                      child: SailRawCard(
                        title: 'Latest Thunder Block',
                        subtitle: 'Most recent block on the Thunder sidechain (L2-S9)',
                        child: model.latestThunderBlock != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Height: ${model.latestThunderBlock!.blockHeight}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Hash: ${model.latestThunderBlock!.hash}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Time: ${model.latestThunderBlock!.formattedTime}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    model.latestThunderBlock!.timeSince(),
                                    style: TextStyle(
                                      color: context.sailTheme.colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Unable to connect to Thunder',
                                    style: TextStyle(
                                      color: context.sailTheme.colors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SailStyleValues.padding16),
                // Refresh button with auto-refresh indicator
                Row(
                  children: [
                    SailButton.primary(
                      'Refresh Now',
                      onPressed: () async => model.refreshData(),
                      size: ButtonSize.regular,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Auto-refreshes every 30 seconds',
                      style: TextStyle(
                        color: context.sailTheme.colors.textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
