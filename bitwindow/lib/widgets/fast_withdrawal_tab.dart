import 'package:bitwindow/providers/fast_withdrawal_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class FastWithdrawalTab extends StatelessWidget {
  const FastWithdrawalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GetIt.I.get<FastWithdrawalProvider>(),
      builder: (context, _) {
        return SingleChildScrollView(
          child: FastWithdrawalForm(),
        );
      },
    );
  }
}

class FastWithdrawalForm extends StatelessWidget {
  const FastWithdrawalForm({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = GetIt.I.get<FastWithdrawalProvider>();
    final theme = SailTheme.of(context);

    if (!GetIt.I.get<BitcoinConfProvider>().networkSupportsSidechains) {
      return SailCard(
        error: 'Fast withdrawals are not available on mainnet (no sidechains)',
        child: SizedBox(),
      );
    }

    final walletReader = GetIt.I.get<WalletReaderProvider>();
    final activeWallet = walletReader.activeWallet;
    if (activeWallet != null && activeWallet.walletType != BinaryType.enforcer) {
      return SailCard(
        error: 'Switch to your enforcer wallet to interact with sidechains',
        child: SizedBox(),
      );
    }

    switch (provider.stage) {
      case FastWithdrawalStage.idle:
      case FastWithdrawalStage.requesting:
        return _WithdrawalForm(provider: provider, colors: theme.colors);
      case FastWithdrawalStage.awaitingPayment:
      case FastWithdrawalStage.sendingL2:
      case FastWithdrawalStage.completing:
        return _PaymentSection(provider: provider, colors: theme.colors);
      case FastWithdrawalStage.done:
        return _SuccessSection(provider: provider);
      case FastWithdrawalStage.error:
        return _ErrorSection(provider: provider, colors: theme.colors);
    }
  }
}

class _WithdrawalForm extends StatefulWidget {
  final FastWithdrawalProvider provider;
  final SailColor colors;

  const _WithdrawalForm({required this.provider, required this.colors});

  @override
  State<_WithdrawalForm> createState() => _WithdrawalFormState();
}

class _WithdrawalFormState extends State<_WithdrawalForm> {
  final TextEditingController amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final isRequesting = provider.stage == FastWithdrawalStage.requesting;

    return SailCard(
      title: 'Fast Withdrawal',
      subtitle: 'Quickly withdraw L2 coins to your L1-wallet',
      padding: true,
      error: provider.errorMessage,
      child: SailColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: SailStyleValues.padding16,
        children: [
          SailTextField(
            label: 'Withdraw amount (BTC)',
            controller: amountController,
            hintText: 'How much do you want to withdraw?',
            textFieldType: TextFieldType.bitcoin,
            suffixWidget: PasteButton(
              onPaste: (text) => amountController.text = text,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.secondary13('From L2'),
              const SizedBox(height: 8),
              SailDropdownButton(
                items: FastWithdrawalProvider.supportedLayer2Chains
                    .map((chain) => SailDropdownItem(label: chain, value: chain))
                    .toList(),
                value: provider.layer2Chain,
                onChanged: (dynamic value) {
                  provider.setLayer2Chain(value as String);
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.secondary13('Using fast withdrawal server'),
                    const SizedBox(height: 8),
                    SailDropdownButton(
                      items: FastWithdrawalProvider.fastWithdrawalServers
                          .map((e) => SailDropdownItem(label: e['name']!, value: e['url']!))
                          .toList(),
                      value: provider.selectedServer,
                      onChanged: (dynamic value) {
                        provider.setSelectedServer(value as String);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SailButton(
            label: isRequesting ? 'Requesting...' : 'Request Withdrawal',
            onPressed: isRequesting ? null : () => provider.requestWithdrawal(amountController.text),
            variant: ButtonVariant.primary,
            loading: isRequesting,
          ),
        ],
      ),
    );
  }
}

class _PaymentSection extends StatefulWidget {
  final FastWithdrawalProvider provider;
  final SailColor colors;

  const _PaymentSection({required this.provider, required this.colors});

  @override
  State<_PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<_PaymentSection> {
  final TextEditingController paymentTxIdController = TextEditingController();

  @override
  void dispose() {
    paymentTxIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final colors = widget.colors;
    final isSendingL2 = provider.stage == FastWithdrawalStage.sendingL2;
    final isCompleting = provider.stage == FastWithdrawalStage.completing;
    final isBusy = isSendingL2 || isCompleting;

    return SailCard(
      title: 'Complete withdrawal',
      subtitle: isSendingL2
          ? 'Sending L2 coins...'
          : isCompleting
          ? 'Completing withdrawal...'
          : 'Send funds to the info below to complete the withdrawal',
      error: provider.errorMessage,
      widgetHeaderEnd: SailButton(
        label: 'Cancel Withdrawal',
        onPressed: isBusy
            ? null
            : () async {
                provider.reset();
              },
        variant: ButtonVariant.destructive,
      ),
      child: SailColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: SailStyleValues.padding16,
        children: [
          // Show L2 address and amount
          if (provider.l2Address != null && provider.l2Amount != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
              child: SailColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: SailStyleValues.padding08,
                children: [
                  SailText.primary13('Send L2 ${provider.layer2Chain} Coins to the info below'),
                  SailTextField(
                    controller: TextEditingController(text: provider.l2Amount),
                    hintText: 'Amount',
                    readOnly: true,
                    suffixWidget: CopyButton(text: provider.l2Amount!),
                  ),
                  SailTextField(
                    controller: TextEditingController(text: provider.l2Address),
                    hintText: 'L2 address',
                    readOnly: true,
                    suffixWidget: CopyButton(text: provider.l2Address!),
                  ),
                ],
              ),
            ),

          // Progress indicator when busy
          if (isBusy)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  SailText.primary13(
                    isSendingL2 ? 'Sending L2 coins...' : 'Completing withdrawal with server...',
                  ),
                ],
              ),
            ),

          // Auto-send button (only if sidechain RPC is available and not busy)
          if (!isBusy && provider.canAutoSend)
            SailButton(
              label: 'Send & Complete Automatically',
              onPressed: () => provider.sendL2AndComplete(null),
              variant: ButtonVariant.primary,
            ),

          // Manual txid paste (always available when not busy)
          if (!isBusy)
            Row(
              children: [
                Expanded(
                  child: SailTextField(
                    label: 'Or paste the L2 txid manually',
                    controller: paymentTxIdController,
                    hintText: 'Paste L2 payment txid',
                    suffixWidget: PasteButton(
                      onPaste: (text) => paymentTxIdController.text = text,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SailButton(
                  label: 'Complete Withdrawal',
                  onPressed: () => provider.sendL2AndComplete(paymentTxIdController.text),
                  variant: ButtonVariant.secondary,
                ),
              ],
            ),

          // Withdrawal hash
          if (provider.withdrawalHash != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.secondary13('Withdrawal Hash:'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: SailText.primary13(provider.withdrawalHash!)),
                      CopyButton(text: provider.withdrawalHash!),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SuccessSection extends StatelessWidget {
  final FastWithdrawalProvider provider;

  const _SuccessSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SailColorScheme.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SailColorScheme.green),
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        children: [
          Icon(Icons.check_circle, color: SailColorScheme.green, size: 48),
          SailText.primary24('Withdrawal Completed'),
          const SizedBox(height: 8),
          SailText.secondary13(
            'Coins are on their way to your L1-wallet and should show up in your unconfirmed balance soon.',
          ),
          if (provider.l1Txid != null) SailText.secondary13('L1 TXID: ${provider.l1Txid}'),
          if (provider.l2Txid != null) SailText.secondary13('L2 TXID: ${provider.l2Txid}'),
          const SizedBox(height: 16),
          SailButton(
            label: 'Start New Withdrawal',
            onPressed: () async {
              provider.reset();
            },
            variant: ButtonVariant.primary,
          ),
        ],
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final FastWithdrawalProvider provider;
  final SailColor colors;

  const _ErrorSection({required this.provider, required this.colors});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Withdrawal Error',
      error: provider.errorMessage,
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        children: [
          Row(
            children: [
              SailButton(
                label: 'Try Again',
                onPressed: () async {
                  provider.reset();
                },
                variant: ButtonVariant.primary,
              ),
              const SizedBox(width: 16),
              if (provider.withdrawalHash != null)
                SailButton(
                  label: 'Back to Payment',
                  onPressed: () async {
                    // Go back to awaiting payment stage so user can retry completing
                    provider.retryPayment();
                  },
                  variant: ButtonVariant.secondary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
