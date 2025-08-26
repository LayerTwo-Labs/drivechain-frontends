import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:faucet/api/api_base.dart';
import 'package:faucet/env.dart';
import 'package:faucet/providers/explorer_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

// Define a Block model that matches the ChainTip from the proto
class Block {
  final String hash;
  final int blockHeight;
  final DateTime blockTime;

  Block({required this.hash, required this.blockHeight, required this.blockTime});

  // Format the block time in a human-friendly way
  String get formattedTime {
    return formatDate(blockTime.toLocal());
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
  Timer? _countdownTimer;
  int _currentTick = 0;

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

  Block? get latestBitassetsBlock => explorerProvider.bitassetsTip != null
      ? Block(
          hash: explorerProvider.bitassetsTip!.hash,
          blockHeight: explorerProvider.bitassetsTip!.height.toInt(),
          blockTime: explorerProvider.bitassetsTip!.timestamp.toDateTime(),
        )
      : null;

  Block? get latestBitnamesBlock => explorerProvider.bitnamesTip != null
      ? Block(
          hash: explorerProvider.bitnamesTip!.hash,
          blockHeight: explorerProvider.bitnamesTip!.height.toInt(),
          blockTime: explorerProvider.bitnamesTip!.timestamp.toDateTime(),
        )
      : null;

  Block? get latestZsideBlock => explorerProvider.zsideTip != null
      ? Block(
          hash: explorerProvider.zsideTip!.hash,
          blockHeight: explorerProvider.zsideTip!.height.toInt(),
          blockTime: explorerProvider.zsideTip!.timestamp.toDateTime(),
        )
      : null;

  // Getter for the countdown seconds
  int get secondsTillNextRefresh => min(30 - _currentTick, 0);

  ExplorerViewModel() {
    explorerProvider.addListener(notifyListeners);
    // Start timer for updating "time ago" text and countdown
    startTimers();
  }

  void refreshData() {
    explorerProvider.fetch();
  }

  void startTimers() {
    if (Environment.isInTest) {
      return;
    }

    // Cancel any existing timers
    _timeUpdateTimer?.cancel();
    _countdownTimer?.cancel();

    // Create a new timer that updates the UI every second for "time ago" text
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Reset countdown when manually refreshing
      _currentTick = 0;
      notifyListeners();
    });

    // Create countdown timer that tracks seconds until next auto-refresh
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentTick = timer.tick;
      notifyListeners(); // Trigger UI update for countdown
    });
  }

  @override
  void dispose() {
    explorerProvider.removeListener(notifyListeners);
    _timeUpdateTimer?.cancel();
    _countdownTimer?.cancel();
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
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(SailStyleValues.padding16),
              child: SailColumn(
                spacing: SailStyleValues.padding16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Refresh button with auto-refresh indicator
                  Row(
                    children: [
                      SailButton(
                        label: 'Refresh Now',
                        onPressed: () async => model.refreshData(),
                        variant: ButtonVariant.primary,
                        loading: model.explorerProvider.isFetching,
                      ),
                      const SizedBox(width: 16),
                      SailText.secondary12(
                        model.secondsTillNextRefresh > 0
                            ? 'Auto-refreshing in ${model.secondsTillNextRefresh} seconds'
                            : 'Refreshing, please wait...',
                        italic: true,
                      ),
                    ],
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardList = [
                        // Mainchain block card
                        SailCard(
                          title: 'Latest Mainchain Block',
                          subtitle: 'Most recent block on the mainchain',
                          child: (model.latestMainchainBlock != null)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SailText.primary13('Height: ${model.latestMainchainBlock?.blockHeight}'),
                                    const SizedBox(height: 4),
                                    SailText.primary13(
                                      'Hash: ${model.latestMainchainBlock?.hash}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    SailText.primary13('Time: ${model.latestMainchainBlock?.formattedTime}'),
                                    const SizedBox(height: 4),
                                    SailText.primary13(
                                      model.latestMainchainBlock?.timeSince() ?? '',
                                      color: context.sailTheme.colors.orange,
                                      bold: true,
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SailText.primary13(
                                      'Unable to connect to Mainchain',
                                      color: context.sailTheme.colors.error,
                                      bold: true,
                                    ),
                                  ],
                                ),
                        ),
                        SailCard(
                          title: 'Latest Thunder Block',
                          subtitle: 'Most recent block on the Thunder sidechain (L2-S9)',
                          child: ((model.latestThunderBlock?.blockHeight ?? 0) > 0)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SailText.primary13('Height: ${model.latestThunderBlock?.blockHeight}'),
                                    const SizedBox(height: 4),
                                    SailText.primary13(
                                      'Hash: ${model.latestThunderBlock?.hash}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    SailText.primary13('Time: ${model.latestThunderBlock?.formattedTime}'),
                                    const SizedBox(height: 4),
                                    SailText.primary13(
                                      model.latestThunderBlock?.timeSince() ?? '',
                                      color: context.sailTheme.colors.orange,
                                      bold: true,
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SailText.primary13(
                                      'Unable to connect to Thunder',
                                      color: context.sailTheme.colors.error,
                                      bold: true,
                                    ),
                                  ],
                                ),
                        ),
                        SailCard(
                          title: 'Latest BitAssets Block',
                          subtitle: 'Most recent block on the BitAssets sidechain (L2-S4)',
                          child: ((model.latestBitassetsBlock?.blockHeight ?? 0) > 0)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SailText.primary13('Height: ${model.latestBitassetsBlock?.blockHeight}'),
                                    const SizedBox(height: 4),
                                    SailText.primary13(
                                      'Hash: ${model.latestBitassetsBlock?.hash}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    SailText.primary13('Time: ${model.latestBitassetsBlock?.formattedTime}'),
                                    const SizedBox(height: 4),
                                    SailText.primary13(
                                      model.latestBitassetsBlock?.timeSince() ?? '',
                                      color: context.sailTheme.colors.orange,
                                      bold: true,
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SailText.primary13(
                                      'Unable to connect to BitAssets',
                                      color: context.sailTheme.colors.error,
                                      bold: true,
                                    ),
                                  ],
                                ),
                        ),
                        SailCard(
                          title: 'Latest BitNames Block',
                          subtitle: 'Most recent block on the BitNames sidechain (L2-S2)',
                          child: ((model.latestBitnamesBlock?.blockHeight ?? 0) > 0)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SailText.primary13('Height: ${model.latestBitnamesBlock?.blockHeight}'),
                                    const SizedBox(height: 4),
                                    SailText.primary13(
                                      'Hash: ${model.latestBitnamesBlock?.hash}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    SailText.primary13('Time: ${model.latestBitnamesBlock?.formattedTime}'),
                                    const SizedBox(height: 4),
                                    SailText.primary13(
                                      model.latestBitnamesBlock?.timeSince() ?? '',
                                      color: context.sailTheme.colors.orange,
                                      bold: true,
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SailText.primary13(
                                      'Unable to connect to BitNames',
                                      color: context.sailTheme.colors.error,
                                      bold: true,
                                    ),
                                  ],
                                ),
                        ),
                        SailCard(
                          title: 'Latest Zside Block',
                          subtitle: 'Most recent block on the Zside sidechain (L2-S98)',
                          child: ((model.latestZsideBlock?.blockHeight ?? 0) > 0)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SailText.primary13('Height: ${model.latestZsideBlock?.blockHeight}'),
                                    const SizedBox(height: 4),
                                    SailText.primary13(
                                      'Hash: ${model.latestZsideBlock?.hash}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    SailText.primary13('Time: ${model.latestZsideBlock?.formattedTime}'),
                                    const SizedBox(height: 4),
                                    SailText.primary13(
                                      model.latestZsideBlock?.timeSince() ?? '',
                                      color: context.sailTheme.colors.orange,
                                      bold: true,
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SailText.primary13(
                                      'Unable to connect to Zside',
                                      color: context.sailTheme.colors.error,
                                      bold: true,
                                    ),
                                  ],
                                ),
                        ),
                      ];

                      int crossAxisCount = (constraints.maxWidth / 550).ceil();
                      double gridSpacing = SailStyleValues.padding16;
                      double totalSpacing = gridSpacing * (crossAxisCount - 1);
                      double cardWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
                      double desiredCardHeight = 180; // Set your ideal card height here

                      double childAspectRatio = cardWidth / desiredCardHeight;

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: gridSpacing,
                        mainAxisSpacing: gridSpacing,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        childAspectRatio: childAspectRatio,
                        children: cardList,
                      );
                    },
                  ),
                  ConstrainedBox(constraints: const BoxConstraints(maxHeight: 500), child: ConsoleCard()),
                  SailSpacing(SailStyleValues.padding64 * 4),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ConsoleCard extends StatelessWidget {
  const ConsoleCard({super.key});

  API get api => GetIt.I.get<API>();

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Enforcer RPC',
      subtitle:
          'Get information from the enforcer. Try typing in "enforcer" in the input below, or GetCtip {"sidechain_number": 9} to get thunders ctip.',
      child: ConsoleView(
        services: [
          ConsoleService(
            name: 'enforcer',
            commands: api.getMethods(),
            execute: (command, args) async {
              String jsonBody = '{}';
              if (args.isNotEmpty) {
                try {
                  json.decode(args[0]).toString();
                  jsonBody = args[0];
                } catch (e) {
                  throw Exception('Argument must be a single JSON object, e.g. {"key": "value"} $e');
                }
              }
              return await api.callRAW(command, 'cusf.mainchain.v1.ValidatorService', jsonBody);
            },
          ),
        ],
      ),
    );
  }
}
