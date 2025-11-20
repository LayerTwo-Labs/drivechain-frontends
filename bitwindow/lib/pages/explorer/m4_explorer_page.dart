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
  late M4Provider _m4Provider;

  @override
  void initState() {
    super.initState();
    _m4Provider = M4Provider();
  }

  @override
  void dispose() {
    _m4Provider.dispose();
    super.dispose();
  }

  void _selectSidechain(int slot) {
    setState(() {
      _selectedSidechainSlot = slot;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        foregroundColor: theme.colors.text,
        title: SailText.primary20('M4 Explorer', bold: true),
        leading: _selectedSidechainSlot != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedSidechainSlot = null;
                  });
                },
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _m4Provider.fetchAll(),
          ),
        ],
      ),
      body: SafeArea(
        child: _selectedSidechainSlot == null ? _buildSidechainSelectionTable() : _buildM4Details(),
      ),
    );
  }

  Widget _buildSidechainSelectionTable() {
    final sidechainProvider = GetIt.I.get<SidechainProvider>();
    final formatter = GetIt.I<FormatterProvider>();

    return ListenableBuilder(
      listenable: sidechainProvider,
      builder: (context, child) {
        // Get list of active sidechains
        final activeSidechains = <int>[];
        for (int slot = 0; slot < sidechainProvider.sidechains.length; slot++) {
          if (sidechainProvider.sidechains[slot] != null) {
            activeSidechains.add(slot);
          }
        }

        if (sidechainProvider.sidechains.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (activeSidechains.isEmpty) {
          return Center(
            child: SailText.primary15('No active sidechains found'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary20('Select a sidechain to view M4 data', bold: true),
              const SizedBox(height: 16),
              Expanded(
                child: SailTable(
                  getRowId: (index) => activeSidechains[index].toString(),
                  headerBuilder: (context) => [
                    const SailTableHeaderCell(name: 'Slot'),
                    const SailTableHeaderCell(name: 'Name'),
                    const SailTableHeaderCell(name: 'Balance'),
                  ],
                  rowBuilder: (context, row, selected) {
                    final slot = activeSidechains[row];
                    final sidechain = sidechainProvider.sidechains[slot];
                    final textColor = context.sailTheme.colors.text;

                    return [
                      SailTableCell(
                        value: '$slot:',
                        textColor: textColor,
                        child: InkWell(
                          onTap: () => _selectSidechain(slot),
                          child: SailText.primary13('$slot:', color: textColor),
                        ),
                      ),
                      SailTableCell(
                        value: sidechain?.info.title ?? '',
                        textColor: textColor,
                        child: InkWell(
                          onTap: () => _selectSidechain(slot),
                          child: SailText.primary13(sidechain?.info.title ?? '', color: textColor),
                        ),
                      ),
                      SailTableCell(
                        value: formatter.formatSats(sidechain?.info.balanceSatoshi.toInt() ?? 0),
                        textColor: textColor,
                        child: InkWell(
                          onTap: () => _selectSidechain(slot),
                          child: SailText.primary13(
                            formatter.formatSats(sidechain?.info.balanceSatoshi.toInt() ?? 0),
                            color: textColor,
                          ),
                        ),
                      ),
                    ];
                  },
                  rowCount: activeSidechains.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildM4Details() {
    return ListenableBuilder(
      listenable: _m4Provider,
      builder: (context, child) {
        final theme = SailTheme.of(context);

        if (_m4Provider.isLoading && _m4Provider.history.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_m4Provider.modelError != null) {
          return Center(
            child: SailText.primary15(
              'Error: ${_m4Provider.modelError}',
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWithdrawalBundlesSection(theme),
                const SizedBox(height: 24),
                _buildVotePreferencesSection(theme),
                const SizedBox(height: 24),
                _buildM4HistorySection(theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWithdrawalBundlesSection(SailThemeData theme) {
    final bundles = _m4Provider.getWithdrawalBundles(_selectedSidechainSlot!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary20('Withdrawal Bundles', bold: true),
        const SizedBox(height: 12),
        if (bundles.isEmpty)
          SailText.secondary13('No withdrawal bundles found')
        else
          ...bundles.map((bundle) => _buildWithdrawalBundleCard(theme, bundle)),
      ],
    );
  }

  Widget _buildWithdrawalBundleCard(SailThemeData theme, drivechainpb.WithdrawalBundle bundle) {
    Color statusColor;
    switch (bundle.status.toLowerCase()) {
      case 'succeeded':
        statusColor = theme.colors.success;
        break;
      case 'failed':
        statusColor = theme.colors.error;
        break;
      case 'pending':
      default:
        statusColor = theme.colors.orange;
    }

    return Card(
      color: theme.colors.backgroundSecondary,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SailText.primary15('Sidechain ${bundle.sidechainId}', bold: true),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: SailStyleValues.borderRadiusSmall,
                  ),
                  child: SailText.secondary12(bundle.status.toUpperCase()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SailText.secondary12(
              'M6 ID: ${bundle.m6id}',
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.secondary13('Block Height'),
                      const SizedBox(height: 4),
                      SailText.primary15('${bundle.blockHeight}', bold: true),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.secondary13('Sequence Number'),
                      const SizedBox(height: 4),
                      SailText.primary15('${bundle.sequenceNumber}', bold: true),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVotePreferencesSection(SailThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SailText.primary20('Vote Preferences', bold: true),
            const Spacer(),
            SailButton(
              label: 'Generate M4 Bytes',
              onPressed: () async => await _showGenerateM4BytesDialog(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_m4Provider.votePreferences.isEmpty)
          SailText.secondary13('No vote preferences set')
        else
          ..._m4Provider.votePreferences.map((vote) => _buildVotePreferenceCard(theme, vote)),
        const SizedBox(height: 12),
        SailButton(
          label: 'Set Vote Preference',
          onPressed: () async => await _showSetVotePreferenceDialog(),
        ),
      ],
    );
  }

  Widget _buildVotePreferenceCard(SailThemeData theme, m4pb.M4Vote vote) {
    return Card(
      color: theme.colors.backgroundSecondary,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            SailText.primary15('Slot ${vote.sidechainSlot}', bold: true),
            const SizedBox(width: 16),
            SailText.primary13('Vote: ${vote.voteType}'),
            if (vote.hasBundleHash()) ...[
              const SizedBox(width: 8),
              Expanded(
                child: SailText.secondary12(
                  'Bundle: ${vote.bundleHash}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildM4HistorySection(SailThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary20('Recent M4 Messages', bold: true),
        const SizedBox(height: 12),
        if (_m4Provider.history.isEmpty)
          SailText.secondary13('No M4 messages found')
        else
          ..._m4Provider.history.map((entry) => _buildHistoryCard(theme, entry)),
      ],
    );
  }

  Widget _buildHistoryCard(SailThemeData theme, m4pb.M4HistoryEntry entry) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(entry.blockTime.toInt() * 1000);
    final formattedTime =
        '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    return Card(
      color: theme.colors.backgroundSecondary,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SailText.primary15('Height ${entry.blockHeight}', bold: true),
                const SizedBox(width: 16),
                SailText.secondary13(formattedTime),
                const Spacer(),
                SailText.secondary12('Version ${entry.version}'),
              ],
            ),
            const SizedBox(height: 8),
            SailText.secondary12(
              'Block: ${entry.blockHash}',
              overflow: TextOverflow.ellipsis,
            ),
            if (entry.votes.isNotEmpty) ...[
              const SizedBox(height: 8),
              SailText.secondary13('Votes:', bold: true),
              ...entry.votes.map((vote) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: SailText.secondary12(
                    'Slot ${vote.sidechainSlot}: ${vote.voteType}${vote.hasBundleIndex() ? " (index ${vote.bundleIndex})" : ""}',
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showSetVotePreferenceDialog() async {
    const availableSlots = [
      {'slot': 0, 'name': 'Thunder'},
      {'slot': 1, 'name': 'BitNames'},
      {'slot': 2, 'name': 'ZSide'},
      {'slot': 3, 'name': 'BitAssets'},
    ];

    int selectedSlot = 0;
    String voteType = 'abstain';
    final bundleHashController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: SailText.primary20('Set Vote Preference'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: selectedSlot,
                    items: availableSlots.map((sc) {
                      return DropdownMenuItem(
                        value: sc['slot'] as int,
                        child: SailText.primary15('Slot ${sc['slot']}: ${sc['name']}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedSlot = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: voteType,
                    items: const [
                      DropdownMenuItem(value: 'abstain', child: Text('Abstain')),
                      DropdownMenuItem(value: 'alarm', child: Text('Alarm')),
                      DropdownMenuItem(value: 'upvote', child: Text('Upvote')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => voteType = value);
                      }
                    },
                  ),
                  if (voteType == 'upvote') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: bundleHashController,
                      decoration: const InputDecoration(
                        labelText: 'Bundle Hash (optional)',
                        hintText: 'Enter bundle hash',
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: SailText.primary13('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: SailText.primary13('Set'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      await _m4Provider.setVotePreference(
        sidechainSlot: selectedSlot,
        voteType: voteType,
        bundleHash: bundleHashController.text.isEmpty ? null : bundleHashController.text,
      );

      if (mounted) {
        showSnackBar(context, 'Vote preference set');
      }
    }
  }

  Future<void> _showGenerateM4BytesDialog() async {
    final result = await _m4Provider.generateM4Bytes();
    if (result == null) {
      if (mounted) {
        showSnackBar(context, 'Failed to generate M4 bytes');
      }
      return;
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: SailText.primary20('M4 Bytes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SailText.secondary13('Hex: ${result.hex}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result.hex));
                      showSnackBar(context, 'Copied to clipboard');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SailText.primary15('Interpretation:', bold: true),
              const SizedBox(height: 8),
              SailText.secondary13(result.interpretation),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: SailText.primary13('Close'),
            ),
          ],
        );
      },
    );
  }
}
