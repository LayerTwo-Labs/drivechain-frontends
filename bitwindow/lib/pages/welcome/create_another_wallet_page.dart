import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/welcome/multisig_config_step.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/pages/welcome/wallet_creation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class CreateAnotherWalletPage extends StatefulWidget {
  const CreateAnotherWalletPage({super.key});

  @override
  State<CreateAnotherWalletPage> createState() => _CreateAnotherWalletPageState();
}

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

  bool _isCreating = false;

  /// True while the keys step is restoring a backup: this page must not be
  /// popped out from under it.
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

  /// Returns to the page that opened this one.
  Future<void> _leaveSetup() async {
    // A finished restore must release the pop lock first, or the pop is refused.
    if (_restoringBackup) {
      setState(() => _restoringBackup = false);
      await WidgetsBinding.instance.endOfFrame;
    }
    if (mounted) {
      await Navigator.of(context).maybePop();
    }
  }

  Future<void> _createWallet(WalletSetupResult result) async {
    // The configure step's callback returns before this finishes, so a second
    // click would create the same wallet twice.
    if (_isCreating) {
      return;
    }
    _isCreating = true;

    try {
      final name = await createWalletFromSetup(result);
      if (!mounted) {
        return;
      }
      if (result.multisig case final spec?) {
        await showMultisigExportDialog(
          context,
          receive: spec.receiveDescriptor,
          change: spec.changeDescriptor,
          coldcardConfig: spec.coldcardConfig(name),
        );
      }
      await _leaveSetup();
    } catch (e) {
      // The wizard has no back button, so a failure has to let the user try
      // again.
      _isCreating = false;
      rethrow;
    }
  }

  List<Widget> _buildPages() {
    return [
      MultisigConfigStep(
        onRestored: _leaveSetup,
        onRestoringChanged: (restoring) => setState(() => _restoringBackup = restoring),
        onConfigured: _createWallet,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    final List<Widget> pages = _buildPages();

    // A blocked pop mid-wizard walks back a step instead.
    return PopScope(
      canPop: _currentStep == 0 && !_restoringBackup,
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
          // own oversized back button (which gets clipped by toolbarHeight).
          leading: _restoringBackup
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
