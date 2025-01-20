import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/routing/router.dart';
import 'package:launcher/widgets/welcome_modal.dart';
import 'package:launcher/widgets/wallet_button.dart';
import 'package:launcher/pages/tools_page.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/nav/top_nav.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

@RoutePage()
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final _toolsViewModel = GetIt.I.get<ToolsPageViewModel>();
  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();
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

  void _handleTabChange(int index) {
    if (_lastIndex == 1 && index != 1) {
      // If leaving the Tools tab
      _toolsViewModel.resetStartersTab();
    }
    _lastIndex = index;
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

        // Handle tab changes
        if (tabsRouter.activeIndex != _lastIndex) {
          _handleTabChange(tabsRouter.activeIndex);
        }

        return Scaffold(
          backgroundColor: theme.colors.background,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
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
}
