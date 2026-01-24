import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/m4_provider.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/drivechain/v1/drivechain.pb.dart' as drivechainpb;
import 'package:sail_ui/gen/m4/v1/m4.pb.dart' as m4pb;
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class M4ExplorerPage extends StatefulWidget {
  const M4ExplorerPage({super.key});

  @override
  State<M4ExplorerPage> createState() => _M4ExplorerPageState();
}

class _M4ExplorerPageState extends State<M4ExplorerPage> {
  int? _selectedSidechainSlot;
  M4Provider get _m4Provider => GetIt.I.get<M4Provider>();
  SidechainProvider get _sidechainProvider => GetIt.I.get<SidechainProvider>();

  @override
  Widget build(BuildContext context) {
    final confProvider = GetIt.I.get<BitcoinConfProvider>();
    if (!confProvider.networkSupportsSidechains) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AutoRouter.of(context).pop();
      });
      return const SizedBox.shrink();
    }

    final theme = SailTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        foregroundColor: theme.colors.text,
        title: SailText.primary20('Sidechain Withdrawal Admin'),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_sidechainProvider, _m4Provider]),
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.all(SailStyleValues.padding16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Sidechains list
                SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary12('Active Sidechains'),
                      const SizedBox(height: SailStyleValues.padding08),
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colors.background,
                            border: Border.all(color: theme.colors.divider),
                            borderRadius: SailStyleValues.borderRadius,
                          ),
                          // Sidechains list
                          child: Builder(
                            builder: (context) {
                              if (_sidechainProvider.sidechains.isEmpty) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              final activeSidechains = _activeSidechains;

                              return SailTable(
                                getRowId: (index) => activeSidechains[index].toString(),
                                selectedRowId: _selectedSidechainSlot?.toString(),
                                headerBuilder: (context) => [
                                  const SailTableHeaderCell(name: '#'),
                                  const SailTableHeaderCell(name: 'Name'),
                                ],
                                rowBuilder: (context, row, selected) {
                                  final slot = activeSidechains[row];
                                  final sidechain = _sidechainProvider.sidechains[slot];
                                  return [
                                    SailTableCell(value: '$slot'),
                                    SailTableCell(value: sidechain?.info.title ?? 'Sidechain $slot'),
                                  ];
                                },
                                rowCount: activeSidechains.length,
                                emptyPlaceholder: 'No active sidechains',
                                onSelectedRow: (rowId) {
                                  setState(() => _selectedSidechainSlot = rowId != null ? int.tryParse(rowId) : null);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: SailStyleValues.padding20),
                // Right side: Details for selected sidechain
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _selectedSidechainSlot == null
                            ? Center(
                                child: SailText.secondary13('Select a sidechain from the list'),
                              )
                            // M4 Details
                            : Builder(
                                builder: (context) {
                                  final hasData =
                                      _m4Provider.withdrawalBundlesBySidechain.isNotEmpty ||
                                      _m4Provider.history.isNotEmpty;
                                  if (_m4Provider.isLoading && !hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }

                                  if (_m4Provider.modelError != null) {
                                    return Center(child: SailText.primary15('Error: ${_m4Provider.modelError}'));
                                  }

                                  final bundles = _m4Provider.getWithdrawalBundles(_selectedSidechainSlot!)
                                    ..sort((a, b) => b.blockHeight.compareTo(a.blockHeight));
                                  final history = _m4Provider.history;

                                  return Padding(
                                    padding: const EdgeInsets.all(SailStyleValues.padding16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Withdrawal Bundles section
                                        Expanded(
                                          flex: 3,
                                          child: SailCard(
                                            title: 'Pending Withdrawals',
                                            subtitle: 'Withdrawal bundles waiting for votes',
                                            child: bundles.isEmpty
                                                ? Center(child: SailText.secondary13('No withdrawal bundles pending'))
                                                : ListView(
                                                    children: bundles
                                                        .map(
                                                          (bundle) => _BundleRow(
                                                            bundle: bundle,
                                                            onCopy: () {
                                                              Clipboard.setData(ClipboardData(text: bundle.m6id));
                                                              showSnackBar(context, 'Copied M6 Bundle Hash');
                                                            },
                                                          ),
                                                        )
                                                        .toList(),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: SailStyleValues.padding08),

                                        // Vote Preferences row
                                        Row(
                                          children: [
                                            SailText.primary13('Your Vote Preference: '),
                                            if (_m4Provider.votePreferences.isEmpty)
                                              SailText.secondary13('Abstain')
                                            else
                                              ..._m4Provider.votePreferences
                                                  .where((v) => v.sidechainSlot == _selectedSidechainSlot)
                                                  .map((vote) => SailText.primary13(vote.voteType.toUpperCase())),
                                            const Spacer(),
                                            SailButton(
                                              label: 'Set Vote',
                                              variant: ButtonVariant.secondary,
                                              skipLoading: true,
                                              onPressed: () async => await _showSetVoteDialog(),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: SailStyleValues.padding08),

                                        // Vote History section
                                        Expanded(
                                          flex: 2,
                                          child: SailCard(
                                            title: 'Vote History',
                                            subtitle: 'Recent blocks showing withdrawal bundle votes',
                                            child: history.isEmpty
                                                ? Center(child: SailText.secondary13('No vote history available'))
                                                : ListView(
                                                    children: history
                                                        .map(
                                                          (entry) => _HistoryEntry(
                                                            entry: entry,
                                                            selectedSidechainSlot: _selectedSidechainSlot!,
                                                          ),
                                                        )
                                                        .toList(),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: SailStyleValues.padding08),

                                        // Generate M4 Bytes button
                                        SailButton(
                                          label: 'Generate M4 Bytes',
                                          variant: ButtonVariant.secondary,
                                          skipLoading: true,
                                          onPressed: () async => await _showGenerateM4BytesDialog(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<int> get _activeSidechains {
    final result = <int>[];
    for (int slot = 0; slot < _sidechainProvider.sidechains.length; slot++) {
      if (_sidechainProvider.sidechains[slot] != null) {
        result.add(slot);
      }
    }
    return result;
  }

  Future<void> _showSetVoteDialog() async {
    String voteType = 'abstain';
    final bundleHashController = TextEditingController();

    await widgetDialog(
      context: context,
      title: 'Set Vote Preference',
      subtitle: 'Choose how you want to vote on withdrawal bundles for this sidechain.',
      maxWidth: 400,
      child: StatefulBuilder(
        builder: (context, setState) {
          return SailColumn(
            spacing: SailStyleValues.padding16,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SailDropdownButton<String>(
                value: voteType,
                items: const [
                  SailDropdownItem(value: 'abstain', label: 'Abstain'),
                  SailDropdownItem(value: 'alarm', label: 'Alarm (Downvote All)'),
                  SailDropdownItem(value: 'upvote', label: 'Upvote Specific Bundle'),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => voteType = value);
                },
              ),
              if (voteType == 'upvote')
                SailTextField(
                  controller: bundleHashController,
                  label: 'Bundle Hash',
                  hintText: 'Enter the bundle hash to upvote',
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SailButton(
                    label: 'Cancel',
                    variant: ButtonVariant.secondary,
                    onPressed: () async => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  SailButton(
                    label: 'Set Vote',
                    variant: ButtonVariant.primary,
                    onPressed: () async {
                      try {
                        await _m4Provider.setVotePreference(
                          sidechainSlot: _selectedSidechainSlot!,
                          voteType: voteType,
                          bundleHash: bundleHashController.text.isEmpty ? null : bundleHashController.text,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          showSnackBar(context, 'Vote preference updated');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showSnackBar(context, 'Failed to set vote: $e');
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showGenerateM4BytesDialog() async {
    final result = await _m4Provider.generateM4Bytes();
    if (result == null) {
      if (mounted) showSnackBar(context, 'Failed to generate M4 bytes');
      return;
    }

    if (!mounted) return;

    final textColor = context.sailTheme.colors.text;

    await widgetDialog(
      context: context,
      title: 'M4 Commitment Bytes',
      subtitle: 'The bytes to include in the coinbase transaction.',
      maxWidth: 500,
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SailCard(
            padding: true,
            secondary: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.secondary12('Hex'),
                const SizedBox(height: 4),
                SelectableText(
                  result.hex,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Mono',
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          SailCard(
            padding: true,
            secondary: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.secondary12('Interpretation'),
                const SizedBox(height: 4),
                SailText.primary13(result.interpretation),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SailButton(
                label: 'Copy Hex',
                variant: ButtonVariant.secondary,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: result.hex));
                  if (mounted) showSnackBar(context, 'Copied to clipboard');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying a withdrawal bundle row
class _BundleRow extends StatelessWidget {
  final drivechainpb.WithdrawalBundle bundle;
  final VoidCallback onCopy;

  const _BundleRow({
    required this.bundle,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    Color statusColor;
    switch (bundle.status.toLowerCase()) {
      case 'succeeded':
        statusColor = theme.colors.success;
      case 'failed':
        statusColor = theme.colors.error;
      default:
        statusColor = theme.colors.orange;
    }

    // Calculate progress percentage for pending bundles
    final isPending = bundle.status.toLowerCase() == 'pending';
    final progress = isPending && bundle.maxAge > 0 ? (bundle.age / bundle.maxAge).clamp(0.0, 1.0) : 0.0;

    return InkWell(
      onTap: onCopy,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with hash and status
            Row(
              children: [
                Expanded(
                  child: SailText.primary13(
                    bundle.m6id.length > 24 ? '${bundle.m6id.substring(0, 24)}...' : bundle.m6id,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SailText.secondary12(bundle.status.toUpperCase(), color: statusColor),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Age and block info
            if (isPending) ...[
              Row(
                children: [
                  SailText.secondary12('Age: ${bundle.age} / ${bundle.maxAge}'),
                  const SizedBox(width: 16),
                  SailText.secondary12('Blocks left: ${bundle.blocksLeft}'),
                ],
              ),
              const SizedBox(height: 4),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colors.backgroundSecondary,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.8 ? theme.colors.error : theme.colors.orange,
                  ),
                  minHeight: 4,
                ),
              ),
            ] else
              SailText.secondary12('Block ${bundle.blockHeight}'),
            const Divider(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying a vote history entry
class _HistoryEntry extends StatelessWidget {
  final m4pb.M4HistoryEntry entry;
  final int selectedSidechainSlot;

  const _HistoryEntry({
    required this.entry,
    required this.selectedSidechainSlot,
  });

  @override
  Widget build(BuildContext context) {
    // Filter votes to only show ones for the selected sidechain
    final relevantVotes = entry.votes.where((v) => v.sidechainSlot == selectedSidechainSlot).toList();

    return ExpansionTile(
      title: SailText.primary13('Block #${entry.blockHeight}'),
      subtitle: SailText.secondary12(
        relevantVotes.isEmpty ? 'No votes for this sidechain' : '${relevantVotes.length} vote(s)',
      ),
      initiallyExpanded: false,
      children: relevantVotes.isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SailText.secondary12('No withdrawal votes recorded in this block'),
              ),
            ]
          : relevantVotes.map((vote) => _VoteEntry(vote: vote)).toList(),
    );
  }
}

/// Widget for displaying a single vote entry
class _VoteEntry extends StatelessWidget {
  final m4pb.M4Vote vote;

  const _VoteEntry({required this.vote});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    Color voteColor;
    String voteLabel;
    IconData voteIcon;

    switch (vote.voteType.toLowerCase()) {
      case 'upvote':
        voteColor = theme.colors.success;
        voteLabel = 'Upvote';
        voteIcon = Icons.arrow_upward;
      case 'alarm':
      case 'downvote':
        voteColor = theme.colors.error;
        voteLabel = 'Alarm';
        voteIcon = Icons.warning;
      default:
        voteColor = theme.colors.textSecondary;
        voteLabel = 'Abstain';
        voteIcon = Icons.remove;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: voteColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(voteIcon, color: voteColor, size: 16),
      ),
      title: SailText.primary13(voteLabel, color: voteColor),
      subtitle: vote.hasBundleHash()
          ? SailText.secondary12(
              'Bundle: ${vote.bundleHash.length > 16 ? '${vote.bundleHash.substring(0, 16)}...' : vote.bundleHash}',
            )
          : null,
      dense: true,
    );
  }
}
