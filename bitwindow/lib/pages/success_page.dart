import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/welcome/create_wallet_page.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Reusable success screen widget - can be embedded in other pages or used standalone
class SuccessScreen extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Widget? actions;

  const SuccessScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
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
                title: title,
                subtitle: subtitle ?? '',
              ),
              SailSVG.icon(
                SailSVGAsset.iconSuccess,
                width: 64,
                height: 64,
                color: iconColor ?? theme.colors.success,
              ),
              const Spacer(),
              if (actions != null) actions!,
              if (actions == null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SailButton(
                      label: 'Continue',
                      variant: ButtonVariant.primary,
                      onPressed: () async {
                        await GetIt.I.get<AppRouter>().maybePop();
                      },
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

/// Standalone success page route
@RoutePage()
class SuccessPage extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SuccessPage({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: SafeArea(
        child: SuccessScreen(
          title: title,
          subtitle: subtitle,
        ),
      ),
    );
  }
}
