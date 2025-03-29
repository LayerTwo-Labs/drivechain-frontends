import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/routing/router.dart';
import 'package:launcher/widgets/wallet_button.dart';
import 'package:launcher/widgets/welcome_modal.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/pages/router.gr.dart' as sailroutes;
import 'package:sail_ui/providers/binary_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/nav/top_nav.dart';

@RoutePage()
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Show welcome modal after widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appDir = await getApplicationSupportDirectory();
      final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
      final masterFile = File(path.join(walletDir.path, 'master_starter.json'));

      if (!masterFile.existsSync()) {
        if (mounted) {
          await showWelcomeModal(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.tabBar(
      animatePageTransition: false,
      routes: const [
        OverviewRoute(),
        ToolsRoute(),
        SettingsRoute(),
      ],
      builder: (context, child, controller) {
        final theme = SailTheme.of(context);
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          backgroundColor: theme.colors.background,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(30),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colors.background,
                    theme.colors.backgroundSecondary,
                  ],
                ),
              ),
              child: Row(
                children: [
                  QtTab(
                    icon: SailSVGAsset.iconHome,
                    label: 'Overview',
                    active: tabsRouter.activeIndex == 0,
                    onTap: () => tabsRouter.setActiveIndex(0),
                  ),
                  QtTab(
                    icon: SailSVGAsset.iconTabTools,
                    label: 'Tools',
                    active: tabsRouter.activeIndex == 1,
                    onTap: () => tabsRouter.setActiveIndex(1),
                  ),
                  QtTab(
                    icon: SailSVGAsset.iconTabSettings,
                    label: 'Settings',
                    active: tabsRouter.activeIndex == 2,
                    onTap: () => tabsRouter.setActiveIndex(2),
                  ),
                  Expanded(child: Container()),
                  const WalletButton(),
                  const SizedBox(width: 8),
                  const ToggleThemeButton(),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              const Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey,
              ),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    await onShutdown(context);

    return AppExitResponse.exit;
  }

  Future<bool> onShutdown(BuildContext context) async {
    final router = GetIt.I.get<AppRouter>();
    unawaited(router.push(const sailroutes.ShuttingDownRoute()));
    final binaryProvider = GetIt.I.get<BinaryProvider>();
    final proccessProvider = GetIt.I.get<ProcessProvider>();

    final futures = <Future>[];
    // Try to stop all binaries regardless of state
    for (final binary in binaryProvider.binaries) {
      futures.add(binaryProvider.stop(binary));
    }

    // If no processes are running, return immediately
    if (futures.isEmpty) {
      return true;
    }

    // Wait for all stop operations to complete
    await Future.wait(futures);

    // after all binaries are killed, make sure to kill any lingering processes started
    await proccessProvider.shutdown();

    return true;
  }
}
