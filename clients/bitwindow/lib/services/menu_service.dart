import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/pages/tools/hash_calculator_page.dart';
import 'package:bitwindow/pages/tools/proof_of_funds_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/nav/top_nav.dart';
import 'package:sail_ui/widgets/containers/sail_dialogs.dart';

class MenuService {
  static const platform = MethodChannel('com.layertwolabs.bitwindow/menu');
  final AppRouter _router = GetIt.I.get<AppRouter>();

  MenuService() {
    platform.setMethodCallHandler(_handleMethod);
  }

  Future<void> openHashCalculator(BuildContext context) async {
    await widgetDialog(
      context: context,
      title: 'Tools',
      child: const HashCalculatorPage(),
    );
  }

  Future<void> openMultisigLounge() async {
    await _router.push(const MultisigLoungeRoute());
  }

  Future<void> openProofOfFunds(BuildContext context) async {
    await widgetDialog(
      context: context,
      title: 'Tools',
      child: const ProofOfFundsPage(),
    );
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'openTool':
        final String tool = call.arguments as String;
        switch (tool) {
          case 'hashCalculator':
            if (_router.navigatorKey.currentContext != null) {
              await openHashCalculator(_router.navigatorKey.currentContext!);
            }
            break;
          case 'multisigLounge':
            await openMultisigLounge();
            break;
          case 'proofOfFunds':
            if (_router.navigatorKey.currentContext != null) {
              await openProofOfFunds(_router.navigatorKey.currentContext!);
            }
            break;
        }
        break;
      default:
        throw PlatformException(
          code: 'NotImplemented',
          message: 'Method ${call.method} not implemented',
        );
    }
  }

  Widget buildToolsMenu(BuildContext context) {
    final theme = SailTheme.of(context);
    
    return PopupMenuButton(
      tooltip: 'Tools',
      color: theme.colors.backgroundSecondary,
      offset: const Offset(0, 48),
      itemBuilder: (context) => [
        PopupMenuItem(
          height: 40,
          onTap: () => openHashCalculator(context),
          child: SailText.primary12('Hash Calculator'),
        ),
        PopupMenuItem(
          height: 40,
          onTap: () => openMultisigLounge(),
          child: SailText.primary12('Multisig Lounge'),
        ),
        PopupMenuItem(
          height: 40,
          onTap: () => openProofOfFunds(context),
          child: SailText.primary12('Proof of Funds'),
        ),
      ],
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SailSVG.fromAsset(
              SailSVGAsset.iconTabSettings,
              height: 16,
            ),
            const SizedBox(width: 8),
            SailText.primary12('Tools'),
          ],
        ),
      ),
    );
  }
} 