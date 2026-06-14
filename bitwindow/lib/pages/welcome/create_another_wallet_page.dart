import 'dart:convert' show utf8;
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:convert/convert.dart' show hex;
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class CreateAnotherWalletPage extends StatefulWidget {
  const CreateAnotherWalletPage({super.key});

  @override
  State<CreateAnotherWalletPage> createState() => _CreateAnotherWalletPageState();
}

/// How the wallet's seed or keys are sourced.
enum WalletSetupMethod { generate, importSeed, importDescriptor }

/// Which backend serves the wallet. The provider and how keys are sourced are
/// orthogonal — any provider can run any method (including watch-only).
enum WalletProvider { bitcoinCore, electrum }

/// For the generate method: a standard auto-generated seed, or a seed derived
/// from user-supplied custom entropy ("paranoid mode").
enum GenerateMode { standard, paranoid }

class _CreateAnotherWalletPageState extends State<CreateAnotherWalletPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // State preservation
  WalletSetupMethod? _method;
  WalletProvider? _provider;
  GenerateMode? _generateMode;
  String _walletName = '';
  WalletGradient? _selectedGradient;
  String _xpubOrDescriptor = '';
  String _mnemonic = '';
  String _entropyMnemonic = '';
  bool _isCreating = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _xpubController = TextEditingController();
  final TextEditingController _mnemonicController = TextEditingController();
  final TextEditingController _entropyController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _xpubController.dispose();
    _mnemonicController.dispose();
    _entropyController.dispose();
    super.dispose();
  }

  /// Generate method with custom entropy — collects entropy and derives a seed.
  bool get _isParanoid => _method == WalletSetupMethod.generate && _generateMode == GenerateMode.paranoid;

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

  Future<void> _createWallet() async {
    setState(() => _isCreating = true);

    try {
      final walletProvider = GetIt.I.get<WalletWriterProvider>();

      final descriptor = _method == WalletSetupMethod.importDescriptor ? _xpubOrDescriptor : null;
      // A null mnemonic on the spendable path means "backend generates a fresh
      // seed"; a non-null one imports it (typed seed or entropy-derived).
      final mnemonic = _method == WalletSetupMethod.importSeed ? _mnemonic : (_isParanoid ? _entropyMnemonic : null);

      if (descriptor != null) {
        // Watch-only: same descriptor either way; the provider just picks the
        // backend that serves chain data.
        if (_provider == WalletProvider.electrum) {
          await walletProvider.createElectrumWallet(
            name: _walletName,
            gradient: _selectedGradient!,
            xpubOrDescriptor: descriptor,
          );
        } else {
          await walletProvider.createWatchOnlyWallet(
            name: _walletName,
            xpubOrDescriptor: descriptor,
            gradient: _selectedGradient!,
          );
        }
      } else {
        if (_provider == WalletProvider.electrum) {
          await walletProvider.createElectrumWallet(
            name: _walletName,
            gradient: _selectedGradient!,
            customMnemonic: mnemonic,
          );
        } else {
          await walletProvider.createBitcoinCoreWallet(
            name: _walletName,
            gradient: _selectedGradient!,
            customMnemonic: mnemonic,
          );
        }
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
      _MethodStep(
        selectedMethod: _method,
        onMethodSelected: (method) {
          setState(() => _method = method);
          _nextStep();
        },
      ),
      _ProviderStep(
        selectedProvider: _provider,
        onProviderSelected: (provider) {
          setState(() => _provider = provider);
          _nextStep();
        },
      ),
      if (_method == WalletSetupMethod.generate)
        _GenerateModeStep(
          onModeSelected: (mode) {
            setState(() => _generateMode = mode);
            _nextStep();
          },
        ),
      if (_isParanoid)
        _EntropyStep(
          entropyController: _entropyController,
          onNext: (mnemonic) {
            setState(() => _entropyMnemonic = mnemonic);
            _nextStep();
          },
        ),
      if (_method == WalletSetupMethod.importSeed)
        _SeedStep(
          mnemonicController: _mnemonicController,
          onNext: () {
            setState(() => _mnemonic = _mnemonicController.text.trim());
            _nextStep();
          },
        ),
      if (_method == WalletSetupMethod.importDescriptor)
        _XpubStep(
          xpubController: _xpubController,
          onNext: () {
            setState(() => _xpubOrDescriptor = _xpubController.text.trim());
            _nextStep();
          },
        ),
      _NameStep(
        nameController: _nameController,
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

    return SailScaffold(
      backgroundColor: theme.colors.background,
      appBar: SailAppBar.build(
        context,
        // Always provide a leading so the material AppBar doesn't auto-imply its
        // own oversized back button (which gets clipped by toolbarHeight). Step
        // 0 pops the route; later steps walk back through the wizard.
        leading: SailButton(
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
    );
  }
}

class _MethodStep extends StatelessWidget {
  final WalletSetupMethod? selectedMethod;
  final Function(WalletSetupMethod) onMethodSelected;

  const _MethodStep({required this.selectedMethod, required this.onMethodSelected});

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
              SailText.primary24('How do you want to set up the new wallet?', bold: true),
              const SizedBox(height: 8),
              SailText.secondary13(
                'This wallet is for mainchain transactions only — it cannot interact with sidechains',
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _MethodCard(
                    title: 'Generate a new wallet',
                    description: 'Create a fresh seed',
                    icon: SailSVGAsset.iconWallet,
                    isSelected: selectedMethod == WalletSetupMethod.generate,
                    onTap: () => onMethodSelected(WalletSetupMethod.generate),
                  ),
                  _MethodCard(
                    title: 'Import a seed phrase',
                    description: 'Restore an existing wallet from its mnemonic',
                    icon: SailSVGAsset.iconRestart,
                    isSelected: selectedMethod == WalletSetupMethod.importSeed,
                    onTap: () => onMethodSelected(WalletSetupMethod.importSeed),
                  ),
                  _MethodCard(
                    title: 'Import watch-only wallet',
                    description: 'Import an xpub or a descriptor',
                    icon: SailSVGAsset.iconSearch,
                    isSelected: selectedMethod == WalletSetupMethod.importDescriptor,
                    onTap: () => onMethodSelected(WalletSetupMethod.importDescriptor),
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

class _ProviderStep extends StatelessWidget {
  final WalletProvider? selectedProvider;
  final Function(WalletProvider) onProviderSelected;

  const _ProviderStep({required this.selectedProvider, required this.onProviderSelected});

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
              SailText.primary24('Where do you want the wallet to live?', bold: true),
              const SizedBox(height: 8),
              SailText.secondary13(
                "The provider decides which backend serves the wallet's chain data",
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _MethodCard(
                    title: 'Bitcoin Core',
                    description: 'Served by your local Bitcoin Core node',
                    icon: SailSVGAsset.iconWallet,
                    isSelected: selectedProvider == WalletProvider.bitcoinCore,
                    onTap: () => onProviderSelected(WalletProvider.bitcoinCore),
                  ),
                  _MethodCard(
                    title: 'Electrum',
                    description: 'Lightweight — chain data from a remote server, no local node',
                    icon: SailSVGAsset.iconSearch,
                    isSelected: selectedProvider == WalletProvider.electrum,
                    onTap: () => onProviderSelected(WalletProvider.electrum),
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

class _GenerateModeStep extends StatelessWidget {
  final Function(GenerateMode) onModeSelected;

  const _GenerateModeStep({required this.onModeSelected});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SizedBox(
          width: 600,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SailText.primary24('Generate your wallet', bold: true),
              const SizedBox(height: 8),
              SailText.secondary13(
                'A fresh seed is created for you. Prefer full control? Supply your own entropy in paranoid mode.',
              ),
              const SizedBox(height: 48),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onModeSelected(GenerateMode.standard),
                  child: Container(
                    width: 400,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colors.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: SailText.primary15('Generate Wallet', color: Colors.white, bold: true),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 400,
                child: SailButton(
                  label: 'Paranoid mode',
                  variant: ButtonVariant.secondary,
                  onPressed: () async => onModeSelected(GenerateMode.paranoid),
                ),
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

  const _NameStep({required this.nameController, required this.onNext});

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

  const _XpubStep({required this.xpubController, required this.onNext});

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
              SailText.primary24('Enter xpub or descriptor', bold: true),
              const SizedBox(height: 8),
              SailText.secondary13('Supports xpub, wpkh, wsh, and multi-sig descriptors'),
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

  const _SeedStep({required this.mnemonicController, required this.onNext});

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

/// Converts custom entropy input to BIP39 entropy bytes. Hex mode requires a
/// valid 16–32 byte hex string (a multiple of 4 bytes); text mode hashes the
/// input to a deterministic 16-byte entropy. Returns null when invalid.
List<int>? entropyBytesFromInput(String input, {required bool hexMode}) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  if (hexMode) {
    // Reject non-hex and odd-length input before decoding — hex.decode throws a
    // FormatException on an odd number of nibbles, which would crash build().
    if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(trimmed) || trimmed.length.isOdd) return null;
    final bytes = hex.decode(trimmed);
    if (bytes.length < 16 || bytes.length > 32 || bytes.length % 4 != 0) return null;
    return bytes;
  }
  return sha256.convert(utf8.encode(trimmed)).bytes.sublist(0, 16);
}

class _EntropyStep extends StatefulWidget {
  final TextEditingController entropyController;
  final Function(String mnemonic) onNext;

  const _EntropyStep({required this.entropyController, required this.onNext});

  @override
  State<_EntropyStep> createState() => _EntropyStepState();
}

class _EntropyStepState extends State<_EntropyStep> {
  bool _hexMode = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    widget.entropyController.addListener(() => setState(() {}));
  }

  Future<void> _next() async {
    final entropy = entropyBytesFromInput(widget.entropyController.text, hexMode: _hexMode);
    if (entropy == null) return;
    setState(() => _busy = true);
    try {
      // Derive the mnemonic locally without saving; the chosen provider's
      // create call imports it just like a typed seed.
      final result = await GetIt.I.get<WalletWriterProvider>().generateWalletFromEntropy(
        entropy,
        doNotSave: true,
      );
      final mnemonic = result['mnemonic'] as String?;
      if (mnemonic == null || mnemonic.isEmpty) {
        throw Exception('could not derive a seed from that entropy');
      }
      widget.onNext(mnemonic);
    } catch (e) {
      if (mounted) {
        showSailToast(context, 'Invalid entropy: $e', variant: SailToastVariant.destructive);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final input = widget.entropyController.text.trim();
    final valid = entropyBytesFromInput(input, hexMode: _hexMode) != null;
    final showError = input.isNotEmpty && !valid;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SizedBox(
          width: 600,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary24('Provide custom entropy', bold: true),
              const SizedBox(height: 8),
              SailText.secondary13(
                _hexMode
                    ? 'Enter 16–32 bytes of hex (a multiple of 4 bytes)'
                    : 'Enter any text — it is hashed into a seed',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  SailCheckbox(
                    value: _hexMode,
                    onChanged: (v) => setState(() => _hexMode = v),
                    label: 'Hex',
                  ),
                  const Spacer(),
                  SailButton(
                    label: 'Random',
                    variant: ButtonVariant.secondary,
                    onPressed: () async {
                      final bytes = List.generate(16, (_) => Random.secure().nextInt(256));
                      setState(() {
                        _hexMode = true;
                        widget.entropyController.text = hex.encode(bytes);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SailTextField(
                controller: widget.entropyController,
                hintText: _hexMode ? 'hex entropy (16–32 bytes)' : 'text to hash',
                textFieldType: TextFieldType.text,
              ),
              if (showError) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SailText.secondary12(
                    'Enter 16–32 bytes of valid hex (a multiple of 4).',
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
                    loading: _busy,
                    disabled: !valid,
                    onPressed: () async => _next(),
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
                      child: FittedBox(fit: BoxFit.cover, child: SailSVG.fromAsset(widget.bgAsset)),
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
