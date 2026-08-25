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

  /// True while the keys step is restoring a backup: this page must not be
  /// popped out from under it.

  bool _isCreating = false;

  bool _restoringBackup = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    // The configure step's callback returns before this finishes, so a second
    // click would create the same wallet twice.
    if (_isCreating) {
      return;
    }
    _isCreating = true;

    try {
      final walletProvider = GetIt.I.get<WalletWriterProvider>();
      _walletName = nextWalletName(GetIt.I.get<WalletReaderProvider>().availableWallets.map((w) => w.name));
      _selectedGradient = WalletGradient.fromWalletId(_walletName);

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
      // The wizard has no back button, so a failure has to let the user try
      // again rather than hold the guard.
      _isCreating = false;
      if (mounted) {
        showSailToast(
          context,
          'Failed to create wallet: $e',
          variant: SailToastVariant.destructive,
        );
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
          _createWallet();
        },
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
