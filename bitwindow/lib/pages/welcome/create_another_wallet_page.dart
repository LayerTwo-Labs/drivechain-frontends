import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class CreateAnotherWalletPage extends StatefulWidget {
  const CreateAnotherWalletPage({super.key});

  @override
  State<CreateAnotherWalletPage> createState() => _CreateAnotherWalletPageState();
}

enum WalletCreationType {
  bitcoinCore,
  electrum,
  watchOnly,
  restoreFromBackup,
  customEntropy,
}

/// How an electrum wallet's keys are sourced.
enum ElectrumMethod {
  generate,
  importSeed,
  importDescriptor,
}

class _CreateAnotherWalletPageState extends State<CreateAnotherWalletPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // State preservation
  WalletCreationType? _selectedType;
  ElectrumMethod? _electrumMethod;
  String _walletName = '';
  WalletGradient? _selectedGradient;
  String _xpubOrDescriptor = '';
  String _mnemonic = '';
  bool _isCreating = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _xpubController = TextEditingController();
  final TextEditingController _mnemonicController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _xpubController.dispose();
    _mnemonicController.dispose();
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

  /// Whether the active electrum sub-flow collects a descriptor/xpub.
  bool get _needsXpubStep =>
      _selectedType == WalletCreationType.watchOnly ||
      (_selectedType == WalletCreationType.electrum && _electrumMethod == ElectrumMethod.importDescriptor);

  /// Whether the active electrum sub-flow collects a seed phrase.
  bool get _needsSeedStep =>
      _selectedType == WalletCreationType.electrum && _electrumMethod == ElectrumMethod.importSeed;

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

  Future<void> _createWallet() async {
    setState(() => _isCreating = true);

    try {
      final walletProvider = GetIt.I.get<WalletWriterProvider>();

      switch (_selectedType!) {
        case WalletCreationType.bitcoinCore:
          await walletProvider.createBitcoinCoreWallet(
            name: _walletName,
            gradient: _selectedGradient!,
          );
          break;
        case WalletCreationType.electrum:
          await walletProvider.createElectrumWallet(
            name: _walletName,
            gradient: _selectedGradient!,
            customMnemonic: _electrumMethod == ElectrumMethod.importSeed ? _mnemonic : null,
            xpubOrDescriptor: _electrumMethod == ElectrumMethod.importDescriptor ? _xpubOrDescriptor : null,
          );
          break;
        case WalletCreationType.watchOnly:
          await walletProvider.createWatchOnlyWallet(
            name: _walletName,
            xpubOrDescriptor: _xpubOrDescriptor,
            gradient: _selectedGradient!,
          );
          break;
        case WalletCreationType.restoreFromBackup:
          // Navigate to existing restore flow
          if (mounted) {
            await GetIt.I.get<AppRouter>().push(
              SailCreateWalletRoute(homeRoute: const RootRoute(), initialScreen: WelcomeScreen.restore),
            );
          }
          return;
        case WalletCreationType.customEntropy:
          // Navigate to existing advanced flow
          if (mounted) {
            await GetIt.I.get<AppRouter>().push(
              SailCreateWalletRoute(homeRoute: const RootRoute(), initialScreen: WelcomeScreen.advanced),
            );
          }
          return;
      }

      if (mounted) {
        await GetIt.I.get<AppRouter>().replaceAll([const RootRoute()]);
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
      _TypeSelectionStep(
        selectedType: _selectedType,
        onTypeSelected: (type) {
          setState(() => _selectedType = type);
          if (type == WalletCreationType.restoreFromBackup || type == WalletCreationType.customEntropy) {
            _createWallet();
          } else {
            _nextStep();
          }
        },
      ),
      if (_selectedType == WalletCreationType.electrum)
        _ElectrumMethodStep(
          selectedMethod: _electrumMethod,
          onMethodSelected: (method) {
            setState(() => _electrumMethod = method);
            _nextStep();
          },
        ),
      _NameStep(
        nameController: _nameController,
        onNext: () {
          setState(() {
            _walletName = _nameController.text.trim();
          });
          _nextStep();
        },
      ),
      if (_needsXpubStep)
        _XpubStep(
          xpubController: _xpubController,
          onNext: () {
            setState(() {
              _xpubOrDescriptor = _xpubController.text.trim();
            });
            _nextStep();
          },
        ),
      if (_needsSeedStep)
        _SeedStep(
          mnemonicController: _mnemonicController,
          onNext: () {
            setState(() {
              _mnemonic = _mnemonicController.text.trim();
            });
            _nextStep();
          },
        ),
      _BackgroundSelectionStep(
        selectedGradient: _selectedGradient,
        isCreating: _isCreating,
        onBackgroundSelected: (gradient) {
          setState(() {
            _selectedGradient = gradient;
          });
        },
        onCreateWallet: _createWallet,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    final List<Widget> pages = _buildPages();

    return SailScaffold(
      backgroundColor: theme.colors.background,
      appBar: SailAppBar.build(
        context,
        leading: _currentStep > 0 ? SailAppBarBackButton(onPressed: _previousStep) : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: pages,
        ),
      ),
    );
  }
}

class _TypeSelectionStep extends StatelessWidget {
  final WalletCreationType? selectedType;
  final Function(WalletCreationType) onTypeSelected;

  const _TypeSelectionStep({
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SizedBox(
          width: 900,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary24(
                'Create a New Wallet',
                bold: true,
              ),
              const SizedBox(height: 8),
              SailText.secondary13(
                'This wallet will not be able to interact with sidechains, only for mainchain transactions',
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _WalletTypeCard(
                    type: WalletCreationType.bitcoinCore,
                    title: 'Bitcoin Core Wallet',
                    description: 'Automatically generate a seed',
                    icon: SailSVGAsset.iconWallet,
                    isSelected: selectedType == WalletCreationType.bitcoinCore,
                    onTap: () => onTypeSelected(WalletCreationType.bitcoinCore),
                  ),
                  _WalletTypeCard(
                    type: WalletCreationType.electrum,
                    title: 'Electrum',
                    description: 'Lightweight — no local Bitcoin Core or enforcer; chain data from a remote server',
                    icon: SailSVGAsset.iconWallet,
                    isSelected: selectedType == WalletCreationType.electrum,
                    onTap: () => onTypeSelected(WalletCreationType.electrum),
                  ),
                  _WalletTypeCard(
                    type: WalletCreationType.watchOnly,
                    title: 'Watch-Only Wallet',
                    description: 'Monitor addresses without private keys',
                    icon: SailSVGAsset.iconSearch,
                    isSelected: selectedType == WalletCreationType.watchOnly,
                    onTap: () => onTypeSelected(WalletCreationType.watchOnly),
                  ),
                  _WalletTypeCard(
                    type: WalletCreationType.restoreFromBackup,
                    title: 'Restore from Backup',
                    description: 'Import wallet from seed phrase',
                    icon: SailSVGAsset.iconRestart,
                    isSelected: selectedType == WalletCreationType.restoreFromBackup,
                    onTap: () => onTypeSelected(WalletCreationType.restoreFromBackup),
                  ),
                  _WalletTypeCard(
                    type: WalletCreationType.customEntropy,
                    title: 'Paranoid Mode',
                    description: 'Create wallet with custom entropy',
                    icon: SailSVGAsset.iconShield,
                    isSelected: selectedType == WalletCreationType.customEntropy,
                    onTap: () => onTypeSelected(WalletCreationType.customEntropy),
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

class _NameStep extends StatefulWidget {
  final TextEditingController nameController;
  final VoidCallback onNext;

  const _NameStep({
    required this.nameController,
    required this.onNext,
  });

  @override
  State<_NameStep> createState() => _NameStepState();
}

/// True when [name], trimmed and case-folded, collides with any existing
/// wallet's name.
bool isWalletNameTaken(String name, Iterable<String> existingNames) {
  final normalized = name.trim().toLowerCase();
  if (normalized.isEmpty) return false;
  return existingNames.any((n) => n.trim().toLowerCase() == normalized);
}

class _NameStepState extends State<_NameStep> {
  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(() => setState(() {}));
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
              SailText.primary24(
                'What do you want to call the wallet?',
                bold: true,
              ),
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

class _XpubStep extends StatefulWidget {
  final TextEditingController xpubController;
  final VoidCallback onNext;

  const _XpubStep({
    required this.xpubController,
    required this.onNext,
  });

  @override
  State<_XpubStep> createState() => _XpubStepState();
}

/// Loose check for an xpub-style key (xpub/tpub/ypub/zpub/upub/vpub) or a
/// descriptor (anything containing balanced parentheses). Catches obvious
/// garbage at the form layer; the backend remains the authoritative validator.
bool isPlausibleXpubOrDescriptor(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return false;
  if (RegExp(r'^[xyztuv]pub[1-9A-HJ-NP-Za-km-z]{50,120}$').hasMatch(trimmed)) {
    return true;
  }
  return trimmed.contains('(') && trimmed.contains(')');
}

class _XpubStepState extends State<_XpubStep> {
  @override
  void initState() {
    super.initState();
    widget.xpubController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final raw = widget.xpubController.text;
    final trimmed = raw.trim();
    final showError = trimmed.isNotEmpty && !isPlausibleXpubOrDescriptor(trimmed);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SizedBox(
          width: 600,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SailText.primary24(
                'Enter xpub or descriptor',
                bold: true,
              ),
              const SizedBox(height: 8),
              SailText.secondary13(
                'Supports xpub, wpkh, wsh, and multi-sig descriptors',
              ),
              const SizedBox(height: 48),
              SailTextField(
                controller: widget.xpubController,
                hintText: 'xpub, wpkh(...), wsh(multi(...)), etc.',
                textFieldType: TextFieldType.text,
                maxLines: 3,
              ),
              if (showError) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SailText.secondary12(
                    "That doesn't look like an xpub or a descriptor.",
                    color: SailTheme.of(context).colors.error,
                  ),
                ),
              ],
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SailButton(
                    label: 'Next',
                    disabled: !isPlausibleXpubOrDescriptor(trimmed),
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

class _ElectrumMethodStep extends StatelessWidget {
  final ElectrumMethod? selectedMethod;
  final Function(ElectrumMethod) onMethodSelected;

  const _ElectrumMethodStep({
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SizedBox(
          width: 900,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary24('How do you want to set up the wallet?', bold: true),
              const SizedBox(height: 48),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _MethodCard(
                    title: 'Generate a new wallet',
                    description: 'Create a fresh seed locally',
                    icon: SailSVGAsset.iconWallet,
                    isSelected: selectedMethod == ElectrumMethod.generate,
                    onTap: () => onMethodSelected(ElectrumMethod.generate),
                  ),
                  _MethodCard(
                    title: 'Import a seed phrase',
                    description: 'Restore an existing wallet from its mnemonic',
                    icon: SailSVGAsset.iconRestart,
                    isSelected: selectedMethod == ElectrumMethod.importSeed,
                    onTap: () => onMethodSelected(ElectrumMethod.importSeed),
                  ),
                  _MethodCard(
                    title: 'Import a descriptor',
                    description: 'Watch-only from an xpub or descriptor — cannot sign or send',
                    icon: SailSVGAsset.iconSearch,
                    isSelected: selectedMethod == ElectrumMethod.importDescriptor,
                    onTap: () => onMethodSelected(ElectrumMethod.importDescriptor),
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

/// True for a BIP39-shaped mnemonic: a whitespace-separated word list whose
/// length is one of the standard 12/15/18/21/24. The backend validates the
/// checksum; this only catches obvious garbage at the form layer.
bool isPlausibleMnemonic(String input) {
  final words = input.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  return const {12, 15, 18, 21, 24}.contains(words.length);
}

class _SeedStep extends StatefulWidget {
  final TextEditingController mnemonicController;
  final VoidCallback onNext;

  const _SeedStep({
    required this.mnemonicController,
    required this.onNext,
  });

  @override
  State<_SeedStep> createState() => _SeedStepState();
}

class _SeedStepState extends State<_SeedStep> {
  @override
  void initState() {
    super.initState();
    widget.mnemonicController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = widget.mnemonicController.text.trim();
    final showError = trimmed.isNotEmpty && !isPlausibleMnemonic(trimmed);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SizedBox(
          width: 600,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SailText.primary24('Enter your seed phrase', bold: true),
              const SizedBox(height: 8),
              SailText.secondary13('12 or 24 words, separated by spaces'),
              const SizedBox(height: 48),
              SailTextField(
                controller: widget.mnemonicController,
                hintText: 'word1 word2 word3 ...',
                textFieldType: TextFieldType.text,
                maxLines: 3,
              ),
              if (showError) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SailText.secondary12(
                    "That doesn't look like a 12/24-word seed phrase.",
                    color: SailTheme.of(context).colors.error,
                  ),
                ),
              ],
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SailButton(
                    label: 'Next',
                    disabled: !isPlausibleMnemonic(trimmed),
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

class _MethodCard extends StatefulWidget {
  final String title;
  final String description;
  final SailSVGAsset icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MethodCard> createState() => _MethodCardState();
}

class _MethodCardState extends State<_MethodCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 420,
          height: 140,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected || _isHovered ? theme.colors.primary : theme.colors.border,
              width: widget.isSelected ? 3 : 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SailSVG.icon(
                    widget.icon,
                    width: 32,
                    height: 32,
                    color: widget.isSelected ? theme.colors.primary : theme.colors.text,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary15(widget.title, bold: true),
                    const SizedBox(height: 4),
                    SailText.secondary13(widget.description),
                  ],
                ),
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
              SailText.primary24(
                'Select a visual style for your wallet',
                bold: true,
              ),
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
                    final bgAsset = allBackgrounds[index];
                    final bgFileName = bgAsset.toAssetPath().split('/').last;
                    final isSelected = selectedGradient?.backgroundSvg == bgFileName;
                    final isTaken = takenBackgrounds.contains(bgFileName);

                    return _BackgroundTile(
                      key: ValueKey('${bgFileName}_$isSelected'),
                      bgAsset: bgAsset,
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
  final SailSVGAsset bgAsset;
  final bool isSelected;
  final bool isTaken;
  final VoidCallback onTap;

  const _BackgroundTile({
    super.key,
    required this.bgAsset,
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
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SailSVG.fromAsset(widget.bgAsset),
                      ),
                    ),
                    if (widget.isTaken)
                      Container(
                        color: theme.colors.background.withValues(alpha: 0.7),
                        child: Center(
                          child: SailText.primary10(
                            'In use',
                            color: theme.colors.text,
                          ),
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

class _WalletTypeCard extends StatefulWidget {
  final WalletCreationType type;
  final String title;
  final String description;
  final SailSVGAsset icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletTypeCard({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_WalletTypeCard> createState() => _WalletTypeCardState();
}

class _WalletTypeCardState extends State<_WalletTypeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 420,
          height: 140,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected || _isHovered ? theme.colors.primary : theme.colors.border,
              width: widget.isSelected ? 3 : 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SailSVG.icon(
                    widget.icon,
                    width: 32,
                    height: 32,
                    color: widget.isSelected ? theme.colors.primary : theme.colors.text,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary15(
                      widget.title,
                      bold: true,
                    ),
                    const SizedBox(height: 4),
                    SailText.secondary13(
                      widget.description,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
