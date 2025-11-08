import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/welcome/create_wallet_page.dart';
import 'package:bitwindow/providers/wallet_writer_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class CreateAnotherWalletPage extends StatefulWidget {
  const CreateAnotherWalletPage({super.key});

  @override
  State<CreateAnotherWalletPage> createState() => _CreateAnotherWalletPageState();
}

enum WalletCreationType {
  bitcoinCore,
  watchOnly,
  restoreFromBackup,
  customEntropy,
}

class _CreateAnotherWalletPageState extends State<CreateAnotherWalletPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // State preservation
  WalletCreationType? _selectedType;
  String _walletName = '';
  WalletGradient? _selectedGradient;
  String _xpubOrDescriptor = '';
  bool _isCreating = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _xpubController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _xpubController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Calculate max steps based on wallet type
    final maxSteps = _selectedType == WalletCreationType.watchOnly ? 3 : 2;

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
              CreateWalletRoute(initalScreen: WelcomeScreen.restore),
            );
          }
          return;
        case WalletCreationType.customEntropy:
          // Navigate to existing advanced flow
          if (mounted) {
            await GetIt.I.get<AppRouter>().push(
              CreateWalletRoute(initalScreen: WelcomeScreen.advanced),
            );
          }
          return;
      }

      if (mounted) {
        await GetIt.I.get<AppRouter>().replaceAll([const RootRoute()]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create wallet: $e'),
            backgroundColor: SailTheme.of(context).colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    // Build page list based on wallet type
    final List<Widget> pages = [
      _buildTypeSelectionStep(),
      _buildNameStep(),
      if (_selectedType == WalletCreationType.watchOnly) _buildXpubStep(),
      _buildBackgroundStep(),
    ];

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        foregroundColor: theme.colors.text,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
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

  Widget _buildTypeSelectionStep() {
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
                'Create Another Wallet',
                bold: true,
              ),
              const SizedBox(height: 8),
              SailText.secondary13(
                'Choose the type of wallet you want to create',
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _WalletTypeCard(
                    type: WalletCreationType.bitcoinCore,
                    title: 'Bitcoin Core Wallet',
                    description: 'Full-featured wallet with complete control',
                    icon: SailSVGAsset.iconWallet,
                    isSelected: _selectedType == WalletCreationType.bitcoinCore,
                    onTap: () {
                      setState(() => _selectedType = WalletCreationType.bitcoinCore);
                      _nextStep();
                    },
                  ),
                  _WalletTypeCard(
                    type: WalletCreationType.watchOnly,
                    title: 'Watch-Only Wallet',
                    description: 'Monitor addresses without private keys',
                    icon: SailSVGAsset.iconSearch,
                    isSelected: _selectedType == WalletCreationType.watchOnly,
                    onTap: () {
                      setState(() => _selectedType = WalletCreationType.watchOnly);
                      _nextStep();
                    },
                  ),
                  _WalletTypeCard(
                    type: WalletCreationType.restoreFromBackup,
                    title: 'Restore from Backup',
                    description: 'Import wallet from seed phrase',
                    icon: SailSVGAsset.iconRestart,
                    isSelected: _selectedType == WalletCreationType.restoreFromBackup,
                    onTap: () {
                      setState(() => _selectedType = WalletCreationType.restoreFromBackup);
                      _createWallet();
                    },
                  ),
                  _WalletTypeCard(
                    type: WalletCreationType.customEntropy,
                    title: 'Paranoid Mode',
                    description: 'Create wallet with custom entropy',
                    icon: SailSVGAsset.iconShield,
                    isSelected: _selectedType == WalletCreationType.customEntropy,
                    onTap: () {
                      setState(() => _selectedType = WalletCreationType.customEntropy);
                      _createWallet();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return _NameStep(
      nameController: _nameController,
      onNext: () {
        setState(() {
          _walletName = _nameController.text.trim();
        });
        _nextStep();
      },
    );
  }

  Widget _buildXpubStep() {
    return _XpubStep(
      xpubController: _xpubController,
      onNext: () {
        setState(() {
          _xpubOrDescriptor = _xpubController.text.trim();
        });
        _nextStep();
      },
    );
  }

  Widget _buildBackgroundStep() {
    return _BackgroundSelectionStep(
      selectedGradient: _selectedGradient,
      isCreating: _isCreating,
      onBackgroundSelected: (gradient) {
        setState(() {
          _selectedGradient = gradient;
        });
      },
      onCreateWallet: _createWallet,
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

class _NameStepState extends State<_NameStep> {
  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SailButton(
                    label: 'Next',
                    disabled: widget.nameController.text.trim().isEmpty,
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

class _XpubStepState extends State<_XpubStep> {
  @override
  void initState() {
    super.initState();
    widget.xpubController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
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
                'Provide the extended public key or descriptor for watch-only tracking',
              ),
              const SizedBox(height: 48),
              SailTextField(
                controller: widget.xpubController,
                hintText: 'xpub... or wpkh(xpub...)',
                textFieldType: TextFieldType.text,
                maxLines: 3,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SailButton(
                    label: 'Next',
                    disabled: widget.xpubController.text.trim().isEmpty,
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
