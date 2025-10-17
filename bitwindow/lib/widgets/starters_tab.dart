import 'package:bitwindow/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class RevealSeedWarningDialog extends StatefulWidget {
  final String starterName;

  const RevealSeedWarningDialog({
    super.key,
    required this.starterName,
  });

  @override
  State<RevealSeedWarningDialog> createState() => _RevealSeedWarningDialogState();

  static Future<bool?> show(BuildContext context, String starterName) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RevealSeedWarningDialog(starterName: starterName),
    );
  }
}

class _RevealSeedWarningDialogState extends State<RevealSeedWarningDialog> {
  bool _understoodRisk = false;
  bool _verifiedEnvironment = false;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final canReveal = _understoodRisk && _verifiedEnvironment;

    return SailDialog(
      title: 'Reveal Seed Phrase',
      subtitle: 'Security Warning',
      actions: [
        SailButton(
          label: 'Cancel',
          variant: ButtonVariant.secondary,
          onPressed: () async => Navigator.of(context).pop(false),
        ),
        SailButton(
          label: 'Reveal Seed Phrase',
          onPressed: canReveal ? () async => Navigator.of(context).pop(true) : null,
        ),
      ],
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning section
          Container(
            padding: const EdgeInsets.all(SailStyleValues.padding12),
            decoration: BoxDecoration(
              color: theme.colors.orangeLight,
              borderRadius: SailStyleValues.borderRadiusSmall,
              border: Border.all(color: theme.colors.orange),
            ),
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: theme.colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: SailStyleValues.padding08),
                    SailText.primary15(
                      'CRITICAL SECURITY WARNING',
                      color: theme.colors.orange,
                      bold: true,
                    ),
                  ],
                ),
                const SizedBox(height: SailStyleValues.padding08),
                SailText.secondary13(
                  'You are about to reveal the seed phrase for ${widget.starterName}. '
                  'Please read and understand the following:',
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(SailStyleValues.padding12),
            decoration: BoxDecoration(
              color: theme.colors.backgroundSecondary,
              borderRadius: SailStyleValues.borderRadiusSmall,
              border: Border.all(color: theme.colors.border),
            ),
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(
                  context,
                  'Anyone with this seed phrase can steal ALL your funds',
                ),
                _buildBulletPoint(
                  context,
                  'Never share this seed phrase with anyone, ever',
                ),
                _buildBulletPoint(
                  context,
                  'Make sure no cameras, phones, or observers can see your screen',
                ),
                _buildBulletPoint(
                  context,
                  'Disable screen recording and screenshot tools',
                ),
                _buildBulletPoint(
                  context,
                  'Be in a secure, private location before proceeding',
                ),
              ],
            ),
          ),

          // Checkboxes
          GestureDetector(
            onTap: () => setState(() => _understoodRisk = !_understoodRisk),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailCheckbox(
                  value: _understoodRisk,
                  onChanged: (value) => setState(() => _understoodRisk = value),
                ),
                const SizedBox(width: SailStyleValues.padding08),
                Expanded(
                  child: SailText.secondary13(
                    'I understand that anyone with this seed phrase can steal my funds',
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () => setState(() => _verifiedEnvironment = !_verifiedEnvironment),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailCheckbox(
                  value: _verifiedEnvironment,
                  onChanged: (value) => setState(() => _verifiedEnvironment = value),
                ),
                const SizedBox(width: SailStyleValues.padding08),
                Expanded(
                  child: SailText.secondary13(
                    'I have verified this is a secure, private environment',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    final theme = SailTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colors.text,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: SailStyleValues.padding08),
        Expanded(
          child: SailText.secondary13(text),
        ),
      ],
    );
  }
}

class StartersTab extends StatelessWidget {
  const StartersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StartersPageViewModel>.reactive(
      viewModelBuilder: () => StartersPageViewModel(),
      builder: (context, viewModel, child) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: viewModel.loadStarters(),
          builder: (context, snapshot) {
            final starters = snapshot.data ?? [];

            return SailCard(
              title: 'Starters',
              padding: true,
              error: snapshot.hasError ? snapshot.error.toString() : null,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: SailTheme.of(context).colors.divider,
                              width: 1,
                            ),
                            borderRadius: SailStyleValues.borderRadius,
                          ),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2), // Starter column
                              1: FlexColumnWidth(4), // Mnemonic column
                              2: FixedColumnWidth(300), // Buttons column
                            },
                            children: [
                              // Header row with improved styling
                              TableRow(
                                decoration: BoxDecoration(
                                  color: SailTheme.of(context).colors.formField,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SailText.primary15(
                                      'Starter',
                                      color: SailTheme.of(context).colors.text,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SailText.primary15(
                                      'Mnemonic',
                                      color: SailTheme.of(context).colors.text,
                                    ),
                                  ),
                                  const SizedBox(), // Space for buttons
                                ],
                              ),
                              // Master starter row
                              ...starters.where((s) => s['name'] == 'Master').map((starter) {
                                return mnemonicRow(
                                  context,
                                  viewModel,
                                  starter['name'],
                                  starter['mnemonic'],
                                  viewModel.isStarterRevealed(starter['name']),
                                  starter['mnemonic'] != null,
                                );
                              }),
                              // Layer 1 divider and starters
                              if (starters.any((s) => s['name'] == 'Master')) ...[
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: SailTheme.of(context).colors.formField,
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                                      child: SailText.primary15(
                                        'Layer 1',
                                        color: SailTheme.of(context).colors.text,
                                      ),
                                    ),
                                    Container(),
                                    Container(),
                                  ],
                                ),
                              ],
                              // L1 starter row
                              ...starters.where((s) => s['name'] == 'Layer 1' || s['chain_layer'] == 1).map((starter) {
                                final isRevealed = viewModel.isStarterRevealed(starter['name']);

                                return mnemonicRow(
                                  context,
                                  viewModel,
                                  starter['name'],
                                  starter['mnemonic'],
                                  isRevealed,
                                  starter['mnemonic'] != null,
                                );
                              }),
                              // Layer 2 divider
                              if (starters.any((s) => s['chain_layer'] == 2)) ...[
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: SailTheme.of(context).colors.formField,
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                                      child: SailText.primary15(
                                        'Layer 2',
                                        color: SailTheme.of(context).colors.text,
                                      ),
                                    ),
                                    Container(),
                                    Container(),
                                  ],
                                ),
                              ],
                              // Sidechain starter rows
                              ...starters.where((s) => s['chain_layer'] == 2).map((starter) {
                                final isRevealed = viewModel.isStarterRevealed(starter['name']);

                                return mnemonicRow(
                                  context,
                                  viewModel,
                                  starter['name'],
                                  starter['mnemonic'],
                                  isRevealed,
                                  starter['mnemonic'] != null,
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

TableRow mnemonicRow(
  BuildContext context,
  StartersPageViewModel viewModel,
  String name,
  String mnemonic,
  bool isRevealed,
  bool hasMnemonic,
) {
  return TableRow(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: SailTheme.of(context).colors.divider,
          width: 1,
        ),
      ),
    ),
    children: [
      // Starter name
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: SailText.primary13(
          name,
          color: SailTheme.of(context).colors.text,
        ),
      ),
      // Mnemonic
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: SailText.secondary13(
          hasMnemonic ? (isRevealed ? mnemonic : '••••••••••••') : 'No starter generated',
          color: hasMnemonic ? SailTheme.of(context).colors.text : SailTheme.of(context).colors.textSecondary,
        ),
      ),
      // Action buttons
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (hasMnemonic) ...[
              CopyButton(
                text: mnemonic,
              ),
              const SizedBox(width: 8),
              if (!isRevealed)
                SailButton(
                  label: 'Reveal',
                  onPressed: () async => viewModel.toggleStarterReveal(context, name, true),
                  variant: ButtonVariant.secondary,
                )
              else
                SailButton(
                  label: 'Hide',
                  onPressed: () async => viewModel.toggleStarterReveal(context, name, false),
                  variant: ButtonVariant.secondary,
                ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    ],
  );
}

class StartersPageViewModel extends BaseViewModel {
  final Set<String> _revealedStarters = {};
  final WalletProvider _walletProvider = GetIt.I.get<WalletProvider>();

  /// Controllers for user input
  final TextEditingController mainchainAddressController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paymentTxIdController = TextEditingController();

  void init() {
    // Initialize any required data
    amountController.text = '1.0 BTC';
  }

  void resetStartersTab() {
    _revealedStarters.clear();
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> loadStarters() async {
    final BinaryProvider binaryProvider = GetIt.I.get<BinaryProvider>();

    final starters = <Map<String, dynamic>>[];
    final masterData = await _walletProvider.loadMasterStarter();
    if (masterData == null) return starters;

    // Add master starter
    starters.add(masterData);

    final l1Mnemonic = await _walletProvider.getL1Starter();
    starters.add({
      'name': BitcoinCore().name,
      'mnemonic': l1Mnemonic,
      'chain_layer': 1,
    });

    final l2Chains = binaryProvider.binaries.where((b) => b.chainLayer == 2).toList();

    for (var chain in l2Chains) {
      chain = chain as Sidechain;

      final mnemonic = await _walletProvider.getSidechainStarter(chain.slot);
      starters.add({
        'name': chain.name,
        'mnemonic': mnemonic,
        'sidechain_slot': chain.slot,
        'chain_layer': 2,
      });
    }

    return starters;
  }

  bool isStarterRevealed(String? starterName) {
    return starterName != null && _revealedStarters.contains(starterName);
  }

  Future<void> toggleStarterReveal(BuildContext context, String? starterName, bool reveal) async {
    if (starterName == null) return;

    if (reveal) {
      // Show warning dialog before revealing
      final confirmed = await RevealSeedWarningDialog.show(context, starterName);
      if (confirmed != true) {
        // User cancelled, don't reveal
        return;
      }
      _revealedStarters.add(starterName);
    } else {
      _revealedStarters.remove(starterName);
    }

    notifyListeners();
  }

  Future<void> copyStarterMnemonic(String? mnemonic) async {
    if (mnemonic != null) {
      await Clipboard.setData(ClipboardData(text: mnemonic));
    }
  }
}
