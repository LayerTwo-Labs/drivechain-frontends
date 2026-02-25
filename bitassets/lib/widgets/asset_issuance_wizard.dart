import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

/// Multi-step wizard for creating new BitAssets
class AssetIssuanceWizard extends StatelessWidget {
  const AssetIssuanceWizard({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AssetIssuanceWizardViewModel>.reactive(
      viewModelBuilder: () => AssetIssuanceWizardViewModel(),
      builder: (context, model, child) {
        final theme = SailTheme.of(context);

        return SailCard(
          title: 'Create BitAsset',
          subtitle: 'Issue a new asset on the BitAssets sidechain',
          child: model.isSuccess
              ? _SuccessView(
                  assetName: model.nameController.text,
                  txid: model.registrationTxid!,
                  onCreateAnother: model.reset,
                )
              : SailColumn(
                  spacing: SailStyleValues.padding16,
                  children: [
                    // Step indicator
                    _StepIndicator(
                      currentStep: model.currentStep,
                      steps: const ['Reserve Name', 'Register Asset'],
                    ),

                    const SizedBox(height: 8),

                    // Step content
                    if (model.currentStep == 0) _ReserveNameStep(model: model) else _RegisterAssetStep(model: model),

                    // Error display
                    if (model.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(SailStyleValues.padding12),
                        decoration: BoxDecoration(
                          color: theme.colors.error.withValues(alpha: 0.1),
                          borderRadius: SailStyleValues.borderRadius,
                          border: Border.all(color: theme.colors.error.withValues(alpha: 0.3)),
                        ),
                        child: SailRow(
                          spacing: SailStyleValues.padding08,
                          children: [
                            SailSVG.icon(SailSVGAsset.iconClose, width: 16, color: theme.colors.error),
                            Expanded(
                              child: SailText.secondary12(model.errorMessage!, color: theme.colors.error),
                            ),
                          ],
                        ),
                      ),

                    // Navigation buttons
                    const SizedBox(height: 8),
                    SailRow(
                      spacing: SailStyleValues.padding12,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (model.currentStep > 0 && !model.isLoading)
                          SailButton(
                            label: 'Back',
                            onPressed: () async => model.previousStep(),
                            variant: ButtonVariant.secondary,
                          ),
                        if (model.currentStep == 0)
                          SailButton(
                            label: model.isLoading ? 'Reserving...' : 'Reserve Name',
                            onPressed: model.canReserve && !model.isLoading ? () async => model.reserveName() : null,
                            disabled: !model.canReserve || model.isLoading,
                          )
                        else
                          SailButton(
                            label: model.isLoading ? 'Registering...' : 'Register Asset',
                            onPressed: model.canRegister && !model.isLoading ? () async => model.registerAsset() : null,
                            disabled: !model.canRegister || model.isLoading,
                          ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const _StepIndicator({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailRow(
      spacing: 0,
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? theme.colors.primary : theme.colors.divider,
            ),
          );
        } else {
          // Step circle
          final stepIndex = index ~/ 2;
          final isActive = stepIndex == currentStep;
          final isCompleted = stepIndex < currentStep;

          return SailColumn(
            spacing: SailStyleValues.padding08,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? theme.colors.primary
                      : isActive
                      ? theme.colors.primary.withValues(alpha: 0.2)
                      : theme.colors.backgroundSecondary,
                  border: Border.all(
                    color: isActive || isCompleted ? theme.colors.primary : theme.colors.divider,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? SailSVG.icon(SailSVGAsset.iconCheck, width: 16, color: Colors.white)
                      : SailText.primary13(
                          '${stepIndex + 1}',
                          color: isActive ? theme.colors.primary : theme.colors.textSecondary,
                          bold: isActive,
                        ),
                ),
              ),
              SailText.secondary12(
                steps[stepIndex],
                color: isActive ? theme.colors.text : theme.colors.textSecondary,
                bold: isActive,
              ),
            ],
          );
        }
      }),
    );
  }
}

class _ReserveNameStep extends StatelessWidget {
  final AssetIssuanceWizardViewModel model;

  const _ReserveNameStep({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Explanation
        Container(
          padding: const EdgeInsets.all(SailStyleValues.padding12),
          decoration: BoxDecoration(
            color: theme.colors.info.withValues(alpha: 0.1),
            borderRadius: SailStyleValues.borderRadius,
            border: Border.all(color: theme.colors.info.withValues(alpha: 0.3)),
          ),
          child: SailRow(
            spacing: SailStyleValues.padding08,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailSVG.icon(SailSVGAsset.iconInfo, width: 16, color: theme.colors.info),
              Expanded(
                child: SailText.secondary12(
                  'Step 1: Reserve a unique name for your BitAsset. This creates a commitment '
                  'that prevents others from registering the same name. After reservation, '
                  'you can proceed to register the asset with its initial supply.',
                ),
              ),
            ],
          ),
        ),

        // Name input
        SailColumn(
          spacing: SailStyleValues.padding08,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.secondary13('Asset Name'),
            SailTextField(
              hintText: 'Enter a unique name for your asset',
              controller: model.nameController,
            ),
            SailText.secondary12(
              'Choose a memorable name. This will be the plaintext identifier for your asset.',
            ),
          ],
        ),

        // Fee info
        Container(
          padding: const EdgeInsets.all(SailStyleValues.padding12),
          decoration: BoxDecoration(
            color: theme.colors.backgroundSecondary,
            borderRadius: SailStyleValues.borderRadius,
          ),
          child: SailRow(
            spacing: SailStyleValues.padding08,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SailText.secondary13('Reservation Fee'),
              SailText.primary13('~1,000 sats', monospace: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _RegisterAssetStep extends StatelessWidget {
  final AssetIssuanceWizardViewModel model;

  const _RegisterAssetStep({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reservation success message
        Container(
          padding: const EdgeInsets.all(SailStyleValues.padding12),
          decoration: BoxDecoration(
            color: theme.colors.success.withValues(alpha: 0.1),
            borderRadius: SailStyleValues.borderRadius,
            border: Border.all(color: theme.colors.success.withValues(alpha: 0.3)),
          ),
          child: SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailSVG.icon(SailSVGAsset.iconCheck, width: 16, color: theme.colors.success),
              Expanded(
                child: SailColumn(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary13('Name Reserved: "${model.nameController.text}"', bold: true),
                    SailText.secondary12('Txid: ${model.reservationTxid ?? "pending"}'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Initial supply input
        SailColumn(
          spacing: SailStyleValues.padding08,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.secondary13('Initial Supply *'),
            SailTextField(
              hintText: 'Total number of tokens to create',
              controller: model.supplyController,
            ),
            SailText.secondary12(
              'The total supply of tokens. This is the maximum that will ever exist unless you mint more later.',
            ),
          ],
        ),

        // Advanced options toggle
        InkWell(
          onTap: model.toggleAdvancedOptions,
          child: SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              Icon(
                model.showAdvancedOptions ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: theme.colors.textSecondary,
              ),
              SailText.secondary13('Advanced Options'),
            ],
          ),
        ),

        // Advanced options
        if (model.showAdvancedOptions)
          Container(
            padding: const EdgeInsets.all(SailStyleValues.padding12),
            decoration: BoxDecoration(
              color: theme.colors.backgroundSecondary,
              borderRadius: SailStyleValues.borderRadius,
            ),
            child: SailColumn(
              spacing: SailStyleValues.padding12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.secondary12('Optional metadata for your asset:', bold: true),
                const SizedBox(height: 4),

                // Commitment
                SailColumn(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.secondary12('Commitment Hash'),
                    SailTextField(
                      hintText: '64-character hex string (optional)',
                      controller: model.commitmentController,
                    ),
                  ],
                ),

                // Encryption pubkey
                SailColumn(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.secondary12('Encryption Public Key'),
                    SailTextField(
                      hintText: 'Public key for encrypted messages (optional)',
                      controller: model.encryptionPubkeyController,
                    ),
                  ],
                ),

                // Signing pubkey
                SailColumn(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.secondary12('Signing Public Key'),
                    SailTextField(
                      hintText: 'Public key for signature verification (optional)',
                      controller: model.signingPubkeyController,
                    ),
                  ],
                ),

                // IPv4 address
                SailColumn(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.secondary12('IPv4 Socket Address'),
                    SailTextField(
                      hintText: 'e.g., 192.168.1.1:8080 (optional)',
                      controller: model.socketAddrV4Controller,
                    ),
                  ],
                ),

                // IPv6 address
                SailColumn(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.secondary12('IPv6 Socket Address'),
                    SailTextField(
                      hintText: 'e.g., [::1]:8080 (optional)',
                      controller: model.socketAddrV6Controller,
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Fee info
        Container(
          padding: const EdgeInsets.all(SailStyleValues.padding12),
          decoration: BoxDecoration(
            color: theme.colors.backgroundSecondary,
            borderRadius: SailStyleValues.borderRadius,
          ),
          child: SailRow(
            spacing: SailStyleValues.padding08,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SailText.secondary13('Registration Fee'),
              SailText.primary13('~1,000 sats', monospace: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String assetName;
  final String txid;
  final VoidCallback onCreateAnother;

  const _SuccessView({
    required this.assetName,
    required this.txid,
    required this.onCreateAnother,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: SailStyleValues.padding16,
      children: [
        const SizedBox(height: 24),

        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colors.success.withValues(alpha: 0.1),
          ),
          child: Center(
            child: SailSVG.icon(SailSVGAsset.iconCheck, width: 40, color: theme.colors.success),
          ),
        ),

        SailText.primary20('Asset Created!', bold: true),
        SailText.secondary13('Your BitAsset has been successfully registered'),

        const SizedBox(height: 16),

        // Details
        Container(
          padding: const EdgeInsets.all(SailStyleValues.padding16),
          decoration: BoxDecoration(
            color: theme.colors.backgroundSecondary,
            borderRadius: SailStyleValues.borderRadius,
          ),
          child: SailColumn(
            spacing: SailStyleValues.padding12,
            children: [
              SailRow(
                spacing: SailStyleValues.padding08,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SailText.secondary13('Asset Name'),
                  SailText.primary13(assetName, bold: true),
                ],
              ),
              SailRow(
                spacing: SailStyleValues.padding08,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.secondary13('Transaction ID'),
                  Expanded(
                    child: SailText.primary12(
                      txid,
                      monospace: true,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SailButton(
          label: 'Create Another Asset',
          onPressed: () async => onCreateAnother(),
          variant: ButtonVariant.secondary,
        ),
      ],
    );
  }
}

class AssetIssuanceWizardViewModel extends BaseViewModel {
  final BitAssetsRPC rpc = GetIt.I.get<BitAssetsRPC>();
  final BitAssetsProvider bitAssetsProvider = GetIt.I.get<BitAssetsProvider>();
  final NotificationProvider notificationProvider = GetIt.I.get<NotificationProvider>();

  // Step management
  int currentStep = 0;
  bool isLoading = false;
  String? errorMessage;
  bool showAdvancedOptions = false;

  // Reservation
  String? reservationTxid;

  // Registration
  String? registrationTxid;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController supplyController = TextEditingController();
  final TextEditingController commitmentController = TextEditingController();
  final TextEditingController encryptionPubkeyController = TextEditingController();
  final TextEditingController signingPubkeyController = TextEditingController();
  final TextEditingController socketAddrV4Controller = TextEditingController();
  final TextEditingController socketAddrV6Controller = TextEditingController();

  AssetIssuanceWizardViewModel() {
    nameController.addListener(notifyListeners);
    supplyController.addListener(notifyListeners);
  }

  bool get canReserve => nameController.text.isNotEmpty;

  bool get canRegister {
    final supply = int.tryParse(supplyController.text);
    return supply != null && supply > 0 && reservationTxid != null;
  }

  bool get isSuccess => registrationTxid != null;

  void toggleAdvancedOptions() {
    showAdvancedOptions = !showAdvancedOptions;
    notifyListeners();
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> reserveName() async {
    if (!canReserve) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final txid = await rpc.reserveBitAsset(nameController.text);
      reservationTxid = txid;

      // Save the name mapping so we can look it up later
      await bitAssetsProvider.saveHashNameMapping(nameController.text, isMine: true);

      currentStep = 1;
      notificationProvider.add(
        title: 'Name Reserved',
        content: 'Successfully reserved "${nameController.text}"',
        dialogType: DialogType.success,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerAsset() async {
    if (!canRegister) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final supply = int.parse(supplyController.text);

      // Build BitAssetRequest with optional data
      final data = BitAssetRequest(
        initialSupply: supply,
        commitment: commitmentController.text.isNotEmpty ? commitmentController.text : null,
        encryptionPubkey: encryptionPubkeyController.text.isNotEmpty ? encryptionPubkeyController.text : null,
        signingPubkey: signingPubkeyController.text.isNotEmpty ? signingPubkeyController.text : null,
        socketAddrV4: socketAddrV4Controller.text.isNotEmpty ? socketAddrV4Controller.text : null,
        socketAddrV6: socketAddrV6Controller.text.isNotEmpty ? socketAddrV6Controller.text : null,
      );

      final txid = await rpc.registerBitAsset(nameController.text, data);
      registrationTxid = txid;

      // Refresh the asset list
      await bitAssetsProvider.fetch();

      notificationProvider.add(
        title: 'Asset Registered',
        content: 'Successfully registered "${nameController.text}"',
        dialogType: DialogType.success,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    currentStep = 0;
    isLoading = false;
    errorMessage = null;
    showAdvancedOptions = false;
    reservationTxid = null;
    registrationTxid = null;

    nameController.clear();
    supplyController.clear();
    commitmentController.clear();
    encryptionPubkeyController.clear();
    signingPubkeyController.clear();
    socketAddrV4Controller.clear();
    socketAddrV6Controller.clear();

    notifyListeners();
  }

  @override
  void dispose() {
    nameController.removeListener(notifyListeners);
    supplyController.removeListener(notifyListeners);
    nameController.dispose();
    supplyController.dispose();
    commitmentController.dispose();
    encryptionPubkeyController.dispose();
    signingPubkeyController.dispose();
    socketAddrV4Controller.dispose();
    socketAddrV6Controller.dispose();
    super.dispose();
  }
}
