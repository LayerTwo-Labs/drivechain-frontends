import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/welcome/multisig_config_step.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class CreateAnotherWalletPage extends StatefulWidget {
  /// Set when a route guard is waiting on the first wallet: the guard resolves
  /// the pending navigation itself, so this page must not replace the stack.
  final VoidCallback? onWalletCreated;

  const CreateAnotherWalletPage({super.key, this.onWalletCreated});

  @override
  State<CreateAnotherWalletPage> createState() => _CreateAnotherWalletPageState();
}

/// How the wallet's seed or keys are sourced.
enum WalletSetupMethod { generate, importSeed, importDescriptor, multisig }

/// Loose form-layer check for an xpub-style key or a descriptor.
bool isPlausibleXpubOrDescriptor(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    return false;
  }
  if (RegExp(r'^[xyztuv]pub[1-9A-HJ-NP-Za-km-z]{50,120}$').hasMatch(trimmed)) {
    return true;
  }
  return trimmed.contains('(') && trimmed.contains(')');
}

class _CreateAnotherWalletPageState extends State<CreateAnotherWalletPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Set by the config screen; consumed by _createWallet.
  WalletSetupMethod? _method;
  String _walletName = '';
  WalletGradient? _selectedGradient;
  String _xpubOrDescriptor = '';
  String? _hardwareDeviceType;
  String? _hardwareFingerprint;
  String _mnemonic = '';
  String _passphrase = '';
  String _singleScriptType = 'native-segwit';
  String _singleDerivationPath = '';
  String _provider = 'electrum';
  MultisigWalletSpec? _multisigSpec;
  bool _isCreating = false;

  /// True while the keys step is restoring a backup: this page must not be
  /// popped out from under it.
  bool _restoringBackup = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _derivationPathController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _accountController.dispose();
    _derivationPathController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final maxSteps = _buildPages().length - 1;

    if (_currentStep < maxSteps) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// True while a route guard holds a suspended navigation waiting on this
  /// wallet — the page must finish through [onWalletCreated], not by popping.
  bool get _guarded => widget.onWalletCreated != null;

  /// Hands control back: to the guard when one is waiting, otherwise home.
  Future<void> _leaveSetup() async {
    final resume = widget.onWalletCreated;
    if (resume != null) {
      resume();
      return;
    }
    await GetIt.I.get<AppRouter>().replaceAll([const RootRoute()]);
  }

  Future<void> _createWallet() async {
    setState(() => _isCreating = true);

    try {
      final walletProvider = GetIt.I.get<WalletWriterProvider>();

      // Multisig: the wizard assembled cosigners (with held seeds); the backend
      // stores them and derives the descriptor. Signs through the same PSBT path
      // as any other electrum wallet.
      if (_method == WalletSetupMethod.multisig) {
        final spec = _multisigSpec!;
        await walletProvider.createMultisigWallet(
          name: _walletName,
          gradient: _selectedGradient!,
          m: spec.m,
          n: spec.n,
          scriptType: spec.scriptType,
          cosigners: spec.toCosignerInputs(),
        );
        if (mounted) {
          await showMultisigExportDialog(
            context,
            receive: spec.receiveDescriptor,
            change: spec.changeDescriptor,
            coldcardConfig: spec.coldcardConfig(_walletName),
          );
          await _leaveSetup();
        }
        return;
      }

      // Single-sig: a descriptor is watch-only/hardware, a mnemonic is spendable.
      final descriptor = _method == WalletSetupMethod.importDescriptor ? _xpubOrDescriptor : null;
      if (descriptor != null && descriptor.isNotEmpty) {
        await walletProvider.createElectrumWallet(
          name: _walletName,
          gradient: _selectedGradient!,
          xpubOrDescriptor: descriptor,
          scriptType: _singleScriptType,
          hardwareDeviceType: _hardwareDeviceType,
          hardwareFingerprint: _hardwareFingerprint,
        );
      } else if (_provider == 'core') {
        await walletProvider.createBitcoinCoreWallet(
          name: _walletName,
          gradient: _selectedGradient!,
          customMnemonic: _mnemonic,
          passphrase: _passphrase,
          scriptType: _singleScriptType,
          derivationPath: _singleDerivationPath.isEmpty ? null : _singleDerivationPath,
        );
      } else {
        await walletProvider.createElectrumWallet(
          name: _walletName,
          gradient: _selectedGradient!,
          customMnemonic: _mnemonic,
          passphrase: _passphrase,
          scriptType: _singleScriptType,
          derivationPath: _singleDerivationPath,
        );
      }

      if (mounted) {
        await _leaveSetup();
      }
    } catch (e) {
      if (mounted) {
        showSailToast(
          context,
          'Failed to create wallet: $e',
          variant: SailToastVariant.destructive,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  List<Widget> _buildPages() {
    return [
      MultisigConfigStep(
        onRestored: _leaveSetup,
        onRestoringChanged: (restoring) => setState(() => _restoringBackup = restoring),
        onConfigured: (result) {
          setState(() {
            if (result.isMultisig) {
              _method = WalletSetupMethod.multisig;
              _multisigSpec = result.multisig;
            } else {
              final s = result.single!;
              _singleScriptType = s.scriptType;
              _singleDerivationPath = s.derivationPath ?? '';
              _provider = s.provider;
              if ((s.mnemonic ?? '').isNotEmpty) {
                _method = WalletSetupMethod.importSeed;
                _mnemonic = s.mnemonic!;
                _passphrase = s.passphrase ?? '';
              } else {
                _method = WalletSetupMethod.importDescriptor;
                _xpubOrDescriptor = s.xpubOrDescriptor ?? '';
                _hardwareDeviceType = s.hardwareDeviceType;
                _hardwareFingerprint = s.hardwareFingerprint;
              }
            }
          });
          _nextStep();
        },
      ),
      _NameStep(
        nameController: _nameController,
        accountController: _accountController,
        derivationPathController: _derivationPathController,
        showDerivation: false,
        onNext: () {
          setState(() => _walletName = _nameController.text.trim());
          _nextStep();
        },
      ),
      _BackgroundSelectionStep(
        selectedGradient: _selectedGradient,
        isCreating: _isCreating,
        onBackgroundSelected: (gradient) {
          setState(() => _selectedGradient = gradient);
        },
        onCreateWallet: _createWallet,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    final List<Widget> pages = _buildPages();

    // Hiding the back button is not enough: an OS or hardware back still pops
    // the guard's redirect route without resolving it. Popping is allowed only
    // when nothing is waiting on this page and there is no wizard step to
    // unwind; a blocked pop mid-wizard walks back a step instead.
    return PopScope(
      canPop: !_guarded && _currentStep == 0 && !_restoringBackup,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        if (_currentStep > 0) {
          _previousStep();
        }
      },
      child: SailScaffold(
        backgroundColor: theme.colors.background,
        appBar: SailAppBar.build(
          context,
          // Always provide a leading so the material AppBar doesn't auto-imply its
          // own oversized back button (which gets clipped by toolbarHeight). Step
          // 0 pops the route; later steps walk back through the wizard. With a
          // guard waiting on the first wallet there is nothing to go back to —
          // popping would drop its redirect and strand the user with no root page.
          leading: (_guarded && _currentStep == 0) || _restoringBackup
              ? const SizedBox.shrink()
              : SailButton(
                  variant: ButtonVariant.icon,
                  icon: SailSVGAsset.chevronLeft,
                  onPressed: () async {
                    if (_currentStep > 0) {
                      _previousStep();
                    } else {
                      await GetIt.I.get<AppRouter>().maybePop();
                    }
                  },
                  iconHeight: 14,
                  iconWidth: 14,
                  small: true,
                ),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: pages,
          ),
        ),
      ),
    );
  }
}

class _NameStep extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController accountController;
  final TextEditingController derivationPathController;
  final bool showDerivation;
  final VoidCallback onNext;

  const _NameStep({
    required this.nameController,
    required this.accountController,
    required this.derivationPathController,
    required this.showDerivation,
    required this.onNext,
  });

  @override
  State<_NameStep> createState() => _NameStepState();
}

/// True when [name], trimmed and case-folded, collides with any existing
/// wallet's name.
bool isWalletNameTaken(String name, Iterable<String> existingNames) {
  final normalized = name.trim().toLowerCase();
  if (normalized.isEmpty) {
    return false;
  }
  return existingNames.any((n) => n.trim().toLowerCase() == normalized);
}

class _NameStepState extends State<_NameStep> {
  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(_onNameChanged);
  }

  // The controller belongs to the wizard, so it outlives this step.
  @override
  void dispose() {
    widget.nameController.removeListener(_onNameChanged);
    super.dispose();
  }

  void _onNameChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final existing = GetIt.I.get<WalletReaderProvider>().availableWallets.map((w) => w.name);
    final trimmed = widget.nameController.text.trim();
    final isTaken = isWalletNameTaken(trimmed, existing);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SizedBox(
          width: 600,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SailText.primary24('What do you want to call the wallet?', bold: true),
              const SizedBox(height: 48),
              SailTextField(
                controller: widget.nameController,
                hintText: 'Wallet name',
                textFieldType: TextFieldType.text,
              ),
              if (isTaken) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SailText.secondary12(
                    'A wallet with that name already exists.',
                    color: SailTheme.of(context).colors.error,
                  ),
                ),
              ],
              if (widget.showDerivation) ...[
                const SizedBox(height: 24),
                SailCollapsible(
                  trigger: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SailText.secondary13('Advanced derivation (optional)'),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        SailTextField(
                          controller: widget.accountController,
                          hintText: 'Account index (default 0)',
                          textFieldType: TextFieldType.number,
                        ),
                        const SizedBox(height: 8),
                        SailTextField(
                          controller: widget.derivationPathController,
                          hintText: "Full account path, e.g. m/84'/0'/0' (overrides account)",
                          textFieldType: TextFieldType.text,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SailButton(
                    label: 'Next',
                    disabled: trimmed.isEmpty || isTaken,
                    onPressed: () async => widget.onNext(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundSelectionStep extends StatelessWidget {
  final WalletGradient? selectedGradient;
  final bool isCreating;
  final Function(WalletGradient) onBackgroundSelected;
  final Future<void> Function() onCreateWallet;

  const _BackgroundSelectionStep({
    required this.selectedGradient,
    required this.isCreating,
    required this.onBackgroundSelected,
    required this.onCreateWallet,
  });

  @override
  Widget build(BuildContext context) {
    final walletReader = GetIt.I.get<WalletReaderProvider>();
    final takenBackgrounds = walletReader.availableWallets
        .map((w) => w.gradient.backgroundSvg)
        .whereType<String>()
        .toList();

    final allBackgrounds = WalletGradient.allBackgrounds;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SizedBox(
          width: 900,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary24('Select a visual style for your wallet', bold: true),
              const SizedBox(height: 24),
              SizedBox(
                height: 350,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: allBackgrounds.length,
                  itemBuilder: (context, index) {
                    final bgFileName = allBackgrounds[index];
                    final isSelected = selectedGradient?.backgroundSvg == bgFileName;
                    final isTaken = takenBackgrounds.contains(bgFileName);

                    return _BackgroundTile(
                      key: ValueKey('${bgFileName}_$isSelected'),
                      bgSvg: bgFileName,
                      isSelected: isSelected,
                      isTaken: isTaken,
                      onTap: () {
                        onBackgroundSelected(
                          WalletGradient.custom(
                            backgroundSvg: bgFileName,
                            colors: WalletGradient.allColorSchemes.first,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SailButton(
                    label: 'Create Wallet',
                    loading: isCreating,
                    disabled: selectedGradient == null,
                    onPressed: onCreateWallet,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundTile extends StatefulWidget {
  final String bgSvg;
  final bool isSelected;
  final bool isTaken;
  final VoidCallback onTap;

  const _BackgroundTile({
    super.key,
    required this.bgSvg,
    required this.isSelected,
    required this.isTaken,
    required this.onTap,
  });

  @override
  State<_BackgroundTile> createState() => _BackgroundTileState();
}

class _BackgroundTileState extends State<_BackgroundTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isTaken ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isTaken ? null : widget.onTap,
        child: Opacity(
          opacity: widget.isTaken ? 0.5 : 1.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.isSelected
                    ? theme.colors.primary
                    : _isHovered
                    ? theme.colors.primary.withValues(alpha: 0.5)
                    : theme.colors.border,
                width: widget.isSelected ? 4 : 2,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(widget.isSelected ? 4 : 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SizedBox.expand(
                      child: BackgroundSvg(widget.bgSvg),
                    ),
                    if (widget.isTaken)
                      Container(
                        color: theme.colors.background.withValues(alpha: 0.7),
                        child: Center(
                          child: SailText.primary10('In use', color: theme.colors.text),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
