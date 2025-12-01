import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/m4_provider.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/drivechain/v1/drivechain.pb.dart' as drivechainpb;
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

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        foregroundColor: theme.colors.text,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SizedBox(
              width: 800,
              child: _selectedSidechainSlot == null ? _buildSidechainSelection() : _buildM4Details(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidechainSelection() {
    final sidechainProvider = GetIt.I.get<SidechainProvider>();

    return ListenableBuilder(
      listenable: sidechainProvider,
      builder: (context, child) {
        final activeSidechains = <int>[];
        for (int slot = 0; slot < sidechainProvider.sidechains.length; slot++) {
          if (sidechainProvider.sidechains[slot] != null) {
            activeSidechains.add(slot);
          }
        }

        if (sidechainProvider.sidechains.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SailText.primary24('Withdrawal Voting', bold: true),
            const SizedBox(height: 16),
            SailText.secondary15(
              'Select a sidechain to manage withdrawal bundle voting.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (activeSidechains.isEmpty)
              SailText.secondary13('No active sidechains found')
            else
              SailCard(
                padding: true,
                secondary: true,
                child: Column(
                  children: activeSidechains.map((slot) {
                    final sidechain = sidechainProvider.sidechains[slot];
                    return ListTile(
                      title: SailText.primary15(sidechain?.info.title ?? 'Sidechain $slot'),
                      subtitle: SailText.secondary12('Slot $slot'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => setState(() => _selectedSidechainSlot = slot),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildM4Details() {
    final theme = SailTheme.of(context);
    final sidechainProvider = GetIt.I.get<SidechainProvider>();
    final sidechain = sidechainProvider.sidechains[_selectedSidechainSlot!];

    return ListenableBuilder(
      listenable: _m4Provider,
      builder: (context, child) {
        final hasData = _m4Provider.withdrawalBundlesBySidechain.isNotEmpty || _m4Provider.history.isNotEmpty;
        if (_m4Provider.isLoading && !hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_m4Provider.modelError != null) {
          return Center(child: SailText.primary15('Error: ${_m4Provider.modelError}'));
        }

        final bundles = _m4Provider.getWithdrawalBundles(_selectedSidechainSlot!);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              SailText.primary24(sidechain?.info.title ?? 'Sidechain $_selectedSidechainSlot', bold: true),
              const SizedBox(height: 8),
              SailText.secondary15('Manage withdrawal bundle voting for this sidechain.'),
              const SizedBox(height: 32),

              // Withdrawal Bundles
              SailCard(
                title: 'Pending Withdrawals',
                subtitle: 'Withdrawal bundles waiting for votes',
                padding: true,
                secondary: true,
                child: bundles.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: SailText.secondary13('No withdrawal bundles pending'),
                      )
                    : Column(
                        children: bundles.map((bundle) => _buildBundleRow(theme, bundle)).toList(),
                      ),
              ),
              const SizedBox(height: 16),

              // Vote Preferences
              SailCard(
                title: 'Your Vote Preference',
                subtitle: 'How you vote on withdrawal bundles',
                padding: true,
                secondary: true,
                child: Column(
                  children: [
                    if (_m4Provider.votePreferences.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SailText.secondary13('Default: Abstain'),
                      )
                    else
                      ..._m4Provider.votePreferences
                          .where((v) => v.sidechainSlot == _selectedSidechainSlot)
                          .map(
                            (vote) => ListTile(
                              title: SailText.primary15(vote.voteType.toUpperCase()),
                              subtitle: vote.hasBundleHash()
                                  ? SailText.secondary12('Bundle: ${vote.bundleHash}')
                                  : null,
                            ),
                          ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SailButton(
                          label: 'Set Vote',
                          variant: ButtonVariant.secondary,
                          skipLoading: true,
                          onPressed: () async => await _showSetVoteDialog(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Back button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SailButton(
                    label: '← Back',
                    variant: ButtonVariant.secondary,
                    onPressed: () async => setState(() => _selectedSidechainSlot = null),
                  ),
                  SailButton(
                    label: 'Generate M4 Bytes',
                    variant: ButtonVariant.secondary,
                    skipLoading: true,
                    onPressed: () async => await _showGenerateM4BytesDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBundleRow(SailThemeData theme, drivechainpb.WithdrawalBundle bundle) {
    Color statusColor;
    switch (bundle.status.toLowerCase()) {
      case 'succeeded':
        statusColor = theme.colors.success;
      case 'failed':
        statusColor = theme.colors.error;
      default:
        statusColor = theme.colors.orange;
    }

    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: SailText.primary13(
              bundle.m6id.length > 20 ? '${bundle.m6id.substring(0, 20)}...' : bundle.m6id,
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
      subtitle: SailText.secondary12('Block ${bundle.blockHeight} · Seq ${bundle.sequenceNumber}'),
      onTap: () {
        Clipboard.setData(ClipboardData(text: bundle.m6id));
        showSnackBar(context, 'Copied M6 Bundle Hash');
      },
    );
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
