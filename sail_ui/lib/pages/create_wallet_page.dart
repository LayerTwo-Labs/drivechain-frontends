import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class SailCreateWalletPage extends StatefulWidget {
  final String appName;
  final VoidCallback? onWalletCreated;
  final VoidCallback? onBack;
  final bool showFileRestore;
  final Widget Function(BuildContext context)? additionalRestoreOptionsBuilder;
  // Restores the wallet from a chosen backup file. When set, the restore screen
  // shows an "Upload wallet backup" option alongside the seed phrase, and the
  // Restore button uses the file when one is selected.
  final Future<void> Function(File backupFile)? onRestoreFromFile;
  final Widget Function(BuildContext context, VoidCallback defaultContinue)? successActionsBuilder;
  final WelcomeScreen initialScreen;
  final PageRouteInfo homeRoute;

  const SailCreateWalletPage({
    super.key,
    this.appName = 'Drivechain',
    this.onWalletCreated,
    this.onBack,
    this.showFileRestore = false,
    this.additionalRestoreOptionsBuilder,
    this.onRestoreFromFile,
    this.successActionsBuilder,
    this.initialScreen = WelcomeScreen.initial,
    required this.homeRoute,
  });

  @override
  State<SailCreateWalletPage> createState() => _SailCreateWalletPageState();
}

enum WelcomeScreen { initial, restore, success }

/// Which backend serves the first wallet. The seed comes from the same master
/// flow regardless; the provider only picks the wallet type and which backend
/// serves chain data. Electrum needs no local Bitcoin Core or enforcer.
enum InitialWalletProvider {
  enforcer('Enforcer', 'Full drivechain node — runs Bitcoin Core and the enforcer locally'),
  bitcoinCore('Bitcoin Core', 'Served by your local Bitcoin Core node'),
  electrum('Electrum', 'Lightweight — chain data from a remote server, no local node');

  const InitialWalletProvider(this.label, this.description);
  final String label;
  final String description;
}

class _SailCreateWalletPageState extends State<SailCreateWalletPage> {
  late WelcomeScreen _currentScreen;
  InitialWalletProvider _selectedProvider = InitialWalletProvider.enforcer;
  final TextEditingController _mnemonicController = TextEditingController();
  final TextEditingController _passphraseController = TextEditingController();
  final TextEditingController _walletNameController = TextEditingController();
  // Advanced derivation: account index (default 0) and an optional full
  // account-level path override (m/purpose'/coin'/account').
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _derivationPathController = TextEditingController();
  File? _selectedBackupFile;
  WalletWriterProvider get _walletProvider => GetIt.I.get<WalletWriterProvider>();

  bool hasExistingWallet = false;
  bool _isGenerating = false;
  bool _awaitingBackend = false;
  bool _hasNavigatedInternally = false;
  String? _error;

  void _clearErrorOnInput() {
    if (_error != null && mounted) {
      setState(() => _error = null);
    }
  }

  void _setScreen(WelcomeScreen screen) {
    if (_currentScreen != screen) {
      _hasNavigatedInternally = true;
    }
    setState(() => _currentScreen = screen);
  }

  @override
  void initState() {
    super.initState();

    _currentScreen = widget.initialScreen;
    _passphraseController.addListener(setstate);
    _mnemonicController.addListener(_clearErrorOnInput);
    _passphraseController.addListener(_clearErrorOnInput);
    _walletNameController.addListener(_clearErrorOnInput);

    _walletProvider.hasExistingWallet().then((value) {
      setState(() {
        hasExistingWallet = value;
      });
    });
  }

  void setstate() {
    setState(() {});
  }

  @override
  void dispose() {
    _passphraseController.removeListener(setstate);
    _mnemonicController.removeListener(_clearErrorOnInput);
    _passphraseController.removeListener(_clearErrorOnInput);
    _walletNameController.removeListener(_clearErrorOnInput);
    _mnemonicController.dispose();
    _passphraseController.dispose();
    _walletNameController.dispose();
    _accountController.dispose();
    _derivationPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SailTheme.of(context).colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: SailTheme.of(context).colors.background,
        foregroundColor: SailTheme.of(context).colors.text,
        leading:
            (hasExistingWallet || widget.onBack != null) &&
                (_currentScreen == WelcomeScreen.initial || widget.initialScreen == _currentScreen)
            ? SailAppBarBackButton(
                onPressed: () {
                  if (widget.onBack != null) {
                    widget.onBack!();
                  } else {
                    context.router.maybePop();
                  }
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            switch (_currentScreen) {
              case WelcomeScreen.initial:
                return _buildInitialScreen();
              case WelcomeScreen.restore:
                return _buildRestoreScreen();
              case WelcomeScreen.success:
                return _buildSuccessScreen();
            }
          },
        ),
      ),
    );
  }

  Future<void> _awaitBackendReady() async {
    if (!GetIt.I.isRegistered<OrchestratorRPC>()) {
      return;
    }
    final orchestrator = GetIt.I.get<OrchestratorRPC>();
    if (await _probeWalletManager(orchestrator)) {
      return;
    }

    if (mounted) {
      setState(() => _awaitingBackend = true);
    }

    final ready = ValueNotifier<bool>(false);
    final timer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (await _probeWalletManager(orchestrator)) {
        ready.value = true;
      }
    });

    try {
      await awaitBackendReady(ready);
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _awaitingBackend = false;
          _isGenerating = false;
          _error = 'Backend not ready after 60s — try again';
        });
      }
      rethrow;
    } finally {
      timer.cancel();
      ready.dispose();
      if (mounted && _awaitingBackend) {
        setState(() => _awaitingBackend = false);
      }
    }
  }

  static Future<bool> _probeWalletManager(OrchestratorRPC orchestrator) async {
    try {
      await orchestrator.wallet.getWalletStatus();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ignore: avoid_build_methods
  Widget _buildInitialScreen() {
    final theme = SailTheme.of(context);
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SizedBox(
            width: 560,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                BootTitle(
                  title: hasExistingWallet ? 'Add a wallet' : 'Set up your wallet',
                  subtitle: hasExistingWallet
                      ? 'Runs alongside your existing wallets. Nothing you already have is touched.'
                      : 'Pick where ${widget.appName} reads chain data from. The seed phrase is the same either way.',
                ),
                if (hasExistingWallet) ...[
                  SailTextField(
                    controller: _walletNameController,
                    hintText: 'Wallet name (required)',
                    textFieldType: TextFieldType.text,
                    size: TextFieldSize.regular,
                  ),
                  const SizedBox(height: 24),
                ],
                _buildProviderCards(theme),
                const SizedBox(height: 24),
                // The scroll view leaves the height unbounded, so the row needs an
                // intrinsic one before its children can stretch to match.
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildGenerateButton(theme)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          theme: theme,
                          title: 'Paste a seed phrase',
                          subtitle: 'Import an existing 12 or 24-word mnemonic',
                          onPressed: (_isGenerating || _awaitingBackend)
                              ? null
                              : () => _setScreen(WelcomeScreen.restore),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: SailStyleValues.padding08),
                    child: SailText.primary13(_error!, color: theme.colors.error),
                  ),
                const SizedBox(height: 16),
                _buildDerivationOptions(theme),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _buildProviderCards renders the wallet type as a choice rather than a
  // dropdown. Bitcoin Core stays visible while unavailable so it reads as
  // "not yet" instead of missing.
  Widget _buildProviderCards(SailThemeData theme) {
    final available = _availableProviders;
    return SailColumn(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SailText.secondary12('WALLET TYPE', bold: true),
        for (final provider in InitialWalletProvider.values)
          _buildProviderCard(theme, provider, enabled: available.contains(provider)),
      ],
    );
  }

  Widget _buildProviderCard(SailThemeData theme, InitialWalletProvider provider, {required bool enabled}) {
    final selected = _selectedProvider == provider;
    final description = enabled ? provider.description : '${provider.description} · needs an enforcer wallet first';

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: enabled ? () => setState(() => _selectedProvider = provider) : null,
          child: Container(
            padding: const EdgeInsets.all(SailStyleValues.padding12),
            decoration: BoxDecoration(
              color: theme.colors.backgroundSecondary,
              border: Border.all(
                color: selected ? theme.colors.primary : theme.colors.border,
                width: selected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? theme.colors.primary : theme.colors.textSecondary, width: 1.5),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colors.primary),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SailColumn(
                    spacing: 2,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary15(provider.label, bold: true),
                      SailText.secondary12(description),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton(SailThemeData theme) {
    final busy = _isGenerating || _awaitingBackend;
    return MouseRegion(
      cursor: busy ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: TextButton(
          onPressed: busy
              ? null
              : () {
                  setState(() => _isGenerating = true);
                  // Schedule the wallet generation to run after this frame
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _handleFastMode();
                  });
                },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SailText.primary15(
                      _awaitingBackend
                          ? 'Connecting to bitwindowd…'
                          : _isGenerating
                          ? 'Generating your wallet'
                          : 'Create a new wallet',
                      color: Colors.white,
                      bold: true,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (busy) ...[
                    const SizedBox(width: 8),
                    SizedBox(width: 15, height: 15, child: LoadingIndicator.insideButton(Colors.white)),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              SailText.primary12(
                'Generates a fresh 12-word seed phrase',
                color: Colors.white70,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required SailThemeData theme,
    required String title,
    required String subtitle,
    required VoidCallback? onPressed,
  }) {
    return MouseRegion(
      cursor: onPressed == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.backgroundSecondary,
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SailText.primary15(title, bold: true, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              SailText.secondary12(subtitle, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: avoid_build_methods
  Widget _buildRestoreScreen() {
    final theme = SailTheme.of(context);
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SizedBox(
            width: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                BootTitle(
                  title: 'Paste your seed phrase',
                  subtitle:
                      'Restores your mainchain wallet and every sidechain wallet from a seed phrase, local wallet backup, or backup file.',
                ),
                const SizedBox(height: 24),
                if (hasExistingWallet) ...[
                  SailTextField(
                    controller: _walletNameController,
                    hintText: 'Wallet name (required)',
                    textFieldType: TextFieldType.text,
                    size: TextFieldSize.regular,
                  ),
                  const SizedBox(height: 16),
                ],
                _buildProviderCards(theme),
                const SizedBox(height: 16),
                SailTextField(
                  controller: _mnemonicController,
                  hintText: 'Paste your seed phrase — 12 or 24 words, separated by spaces',
                  maxLines: 3,
                  textFieldType: TextFieldType.text,
                  size: TextFieldSize.regular,
                ),
                const SizedBox(height: 16),
                SailTextField(
                  controller: _passphraseController,
                  hintText: 'Optional passphrase',
                  textFieldType: TextFieldType.text,
                  size: TextFieldSize.regular,
                ),
                const SizedBox(height: 8),
                _buildDerivationOptions(theme),
                // Upload a wallet backup file as an alternative to the seed.
                if (widget.onRestoreFromFile != null) ...[
                  const SizedBox(height: 24),
                  _orDivider(theme),
                  const SizedBox(height: 24),
                  _buildFileRestoreField(theme),
                ],
                // Additional restore options (e.g., file restore for BitWindow)
                if (widget.additionalRestoreOptionsBuilder != null) ...[
                  const SizedBox(height: 24),
                  widget.additionalRestoreOptionsBuilder!(context),
                ],
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: SailStyleValues.padding08),
                    child: SailText.primary13(_error!, color: theme.colors.error),
                  ),
                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SailButton(
                      label: '← Back',
                      variant: ButtonVariant.secondary,
                      onPressed: () async {
                        // If we started on this screen and haven't navigated internally, pop the route
                        if (widget.initialScreen == _currentScreen && !_hasNavigatedInternally) {
                          if (widget.onBack != null) {
                            widget.onBack!();
                          } else {
                            await context.router.maybePop();
                          }
                        } else {
                          _setScreen(WelcomeScreen.initial);
                        }
                      },
                    ),
                    SailButton(
                      label: 'Restore',
                      variant: ButtonVariant.primary,
                      disabled: _awaitingBackend,
                      loading: _awaitingBackend,
                      onPressed: _handleRestore,
                      loadingLabel: _awaitingBackend ? 'Connecting to bitwindowd…' : 'Restoring your wallet',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _buildDerivationOptions renders a collapsed "Advanced derivation" section
  // letting the user set a non-default account index or a full account-level
  // path. Hidden by default; defaults reproduce standard BIP84 account 0.
  Widget _buildDerivationOptions(SailThemeData theme) {
    return SailCollapsible(
      trigger: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SailText.secondary13('Advanced derivation'),
            const SizedBox(width: 6),
            SailText.secondary13('(optional)', color: theme.colors.textSecondary),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SailColumn(
          spacing: SailStyleValues.padding08,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SailTextField(
              controller: _accountController,
              hintText: 'Account index (default 0)',
              textFieldType: TextFieldType.number,
              size: TextFieldSize.regular,
            ),
            SailTextField(
              controller: _derivationPathController,
              hintText: "Full account path, e.g. m/84'/0'/0' (overrides account)",
              textFieldType: TextFieldType.text,
              size: TextFieldSize.regular,
            ),
          ],
        ),
      ),
    );
  }

  Widget _orDivider(SailThemeData theme) {
    return Row(
      children: [
        Expanded(child: Divider(color: theme.colors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SailText.secondary13('or'),
        ),
        Expanded(child: Divider(color: theme.colors.divider)),
      ],
    );
  }

  Widget _buildFileRestoreField(SailThemeData theme) {
    final selected = _selectedBackupFile;
    return GestureDetector(
      onTap: () async {
        final result = await FilePicker.pickFiles(
          dialogTitle: 'Upload wallet backup',
          type: FileType.custom,
          allowedExtensions: ['zip', 'json'],
        );
        final pickedPath = result?.files.single.path;
        if (pickedPath != null) {
          setState(() {
            _selectedBackupFile = File(pickedPath);
            _error = null;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: selected != null ? theme.colors.primary : theme.colors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.upload_file, color: theme.colors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: SailText.secondary13(
                selected != null ? selected.uri.pathSegments.last : 'Upload wallet backup (.zip or .json)',
              ),
            ),
            if (selected != null)
              GestureDetector(
                onTap: () => setState(() => _selectedBackupFile = null),
                child: Icon(Icons.close, color: theme.colors.textSecondary, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  String get _defaultWalletName => '${_selectedProvider.label} Wallet';

  /// Bitcoin Core needs an existing enforcer wallet. The backend turns any
  /// wallet set that has no enforcer into an enforcer wallet, so offering Core
  /// before one exists would silently create an enforcer wallet — and "has any
  /// wallet" isn't enough, since an Electrum-only set still has no enforcer.
  List<InitialWalletProvider> get _availableProviders => GetIt.I.get<WalletReaderProvider>().enforcerWallet != null
      ? InitialWalletProvider.values
      : InitialWalletProvider.values.where((p) => p != InitialWalletProvider.bitcoinCore).toList();

  /// Creates the first wallet of the chosen [InitialWalletProvider]. The seed
  /// always comes from the master flow — the backend generates it, or imports
  /// [customMnemonic] — so the user's backup is identical across providers.
  /// The provider only selects the wallet type and chain-data backend.
  Future<void> _createForProvider({
    required String name,
    String? customMnemonic,
    String? passphrase,
  }) async {
    final account = _resolvedAccountIndex();
    final derivationPath = _derivationPathController.text.trim();
    switch (_selectedProvider) {
      case InitialWalletProvider.enforcer:
        await _walletProvider.generateWallet(
          name: name,
          customMnemonic: customMnemonic,
          passphrase: passphrase,
          account: account,
          derivationPath: derivationPath,
        );
      case InitialWalletProvider.bitcoinCore:
        await _walletProvider.createBitcoinCoreWallet(
          name: name,
          gradient: WalletGradient.fromWalletId(name),
          customMnemonic: customMnemonic,
          passphrase: passphrase,
          account: account,
          derivationPath: derivationPath,
        );
      case InitialWalletProvider.electrum:
        await _walletProvider.createElectrumWallet(
          name: name,
          gradient: WalletGradient.fromWalletId(name),
          customMnemonic: customMnemonic,
          passphrase: passphrase,
          account: account,
          derivationPath: derivationPath,
        );
    }
  }

  // _resolvedAccountIndex reads the optional account-index field; blank = 0. The
  // backend validates range and the full-path override, so this only parses.
  int _resolvedAccountIndex() {
    final raw = _accountController.text.trim();
    if (raw.isEmpty) {
      return 0;
    }
    return int.tryParse(raw) ?? 0;
  }

  Future<void> _handleFastMode() async {
    if (mounted) {
      setState(() => _error = null);
    }
    try {
      final walletName = _walletNameController.text.trim();

      if (hasExistingWallet && walletName.isEmpty) {
        if (mounted) {
          setState(() {
            _error = 'Please enter a wallet name';
            _isGenerating = false;
          });
        }
        return;
      }

      try {
        await _awaitBackendReady();
      } catch (_) {
        return;
      }

      final finalWalletName = walletName.isEmpty ? _defaultWalletName : walletName;

      await _createForProvider(name: finalWalletName);
      if (mounted) {
        _setScreen(WelcomeScreen.success);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to generate wallet: $e');
      }
    }

    if (mounted) {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _handleRestore() async {
    if (mounted) {
      setState(() => _error = null);
    }

    // A chosen backup file takes precedence over the seed phrase.
    final backupFile = _selectedBackupFile;
    if (backupFile != null && widget.onRestoreFromFile != null) {
      if (mounted) {
        setState(() => _awaitingBackend = true);
      }
      try {
        await widget.onRestoreFromFile!(backupFile);
        if (mounted) {
          _setScreen(WelcomeScreen.success);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _error = 'Failed to restore from backup file: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _awaitingBackend = false);
        }
      }
      return;
    }

    if (!_isValidMnemonic(_mnemonicController.text)) {
      if (mounted) {
        setState(() => _error = 'Invalid mnemonic format. Please enter 12 or 24 words.');
      }
      return;
    }

    final walletName = _walletNameController.text.trim();

    if (hasExistingWallet && walletName.isEmpty) {
      if (mounted) {
        setState(() => _error = 'Please enter a wallet name');
      }
      return;
    }

    try {
      await _awaitBackendReady();
    } catch (_) {
      return;
    }

    try {
      final finalWalletName = walletName.isEmpty ? _defaultWalletName : walletName;

      await _createForProvider(
        name: finalWalletName,
        customMnemonic: _mnemonicController.text,
        passphrase: _passphraseController.text.isNotEmpty ? _passphraseController.text : null,
      );
      if (mounted) {
        _setScreen(WelcomeScreen.success);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to generate wallet: $e');
      }
    }
  }

  bool _isValidMnemonic(String mnemonic) {
    final words = mnemonic.trim().split(' ');
    return words.length == 12 || words.length == 24;
  }

  void _handleContinue() {
    if (widget.onWalletCreated != null) {
      widget.onWalletCreated!();
    } else if (context.router.canPop()) {
      // Pop back to let WalletGuard continue navigation
      context.router.pop();
    } else {
      // No route to pop to (replaceAll was used), navigate to home
      context.router.replaceAll([widget.homeRoute]);
    }
  }

  // ignore: avoid_build_methods
  Widget _buildSuccessScreen() {
    final theme = SailTheme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SizedBox(
          width: 800,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              BootTitle(
                title: 'Wallet Created',
                subtitle: 'Your wallet was created successfully. You can now continue.',
              ),
              SailSVG.icon(
                SailSVGAsset.iconSuccess,
                width: 64,
                height: 64,
                color: theme.colors.success,
              ),
              const Spacer(),
              if (widget.successActionsBuilder != null)
                widget.successActionsBuilder!(context, _handleContinue)
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SailButton(
                      label: 'Continue',
                      variant: ButtonVariant.primary,
                      onPressed: () async => _handleContinue(),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
Future<void> awaitBackendReady(
  ValueListenable<bool> ready, {
  Duration timeout = const Duration(seconds: 60),
}) async {
  if (ready.value) {
    return;
  }

  final completer = Completer<void>();
  void listener() {
    if (ready.value && !completer.isCompleted) {
      completer.complete();
    }
  }

  ready.addListener(listener);
  try {
    await completer.future.timeout(timeout);
  } finally {
    ready.removeListener(listener);
  }
}

/// Title widget for wallet creation screens
class BootTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const BootTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        SailText.primary40(title, bold: true, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        SailText.primary15(subtitle, textAlign: TextAlign.center),
        const SizedBox(height: 30),
      ],
    );
  }
}
