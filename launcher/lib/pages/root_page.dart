import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/routing/router.dart';
import 'package:launcher/widgets/welcome_modal.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:window_manager/window_manager.dart';

@RoutePage()
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver, WindowListener {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWindowManager();

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

  Future<void> _initializeWindowManager() async {
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
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

        return Scaffold(
          backgroundColor: theme.colors.background,
          appBar: TopNav(
            routes: [
              TopNavRoute(
                label: 'Overview',
              ),
              TopNavRoute(
                label: 'Tools',
              ),
              TopNavRoute(
                label: 'Settings',
              ),
            ],
          ),
          body: Expanded(child: child),
        );
      },
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> onShutdown({required VoidCallback onComplete}) async {
    try {
      final binaryProvider = GetIt.I.get<BinaryProvider>();
      final processProvider = GetIt.I.get<ProcessProvider>();

      // Get list of running binaries
      final runningBinaries = processProvider.runningProcesses.values.map((process) => process.binary).toList();

      // Show shutdown page with running binaries
      unawaited(
        GetIt.I.get<AppRouter>().push(
              ShuttingDownRoute(
                binaries: runningBinaries,
                onComplete: onComplete,
              ),
            ),
      );

      final futures = <Future>[];
      // Try to stop all binaries regardless of state
      for (final binary in binaryProvider.binaries) {
        futures.add(binaryProvider.stop(binary));
      }

      // Wait for all stop operations to complete
      await Future.wait(futures);

      // after all binaries are killed, make sure to kill any lingering processes started
      await processProvider.shutdown();
    } catch (error) {
      // do nothing, we just always need to return true
    }

    return true;
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    await onShutdown(
      onComplete: () async {
        if (isPreventClose) {
          await windowManager.destroy();
        }
      },
    );
  }
}
