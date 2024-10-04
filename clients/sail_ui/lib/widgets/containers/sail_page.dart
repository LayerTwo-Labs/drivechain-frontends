import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailPage extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? widgetTitle;
  final Widget body;
  final bool scrollable;

  const SailPage({
    super.key,
    this.title,
    this.subtitle,
    this.widgetTitle,
    this.scrollable = false,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final backgroundColor = theme.colors.background;
    final scaffold = SelectionArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: widgetTitle == null
            ? null
            : SailAppBar.build(
                context,
                title: Padding(
                  padding: widgetTitle != null
                      ? const EdgeInsets.symmetric(vertical: SailStyleValues.padding10)
                      : const EdgeInsets.all(0),
                  child: widgetTitle,
                ),
              ),
        body: buildBody(context),
      ),
    );
    return scaffold;
  }

  Widget buildBody(BuildContext context) {
    if (scrollable) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: _pageContainer(),
      );
    }

    return _pageContainer();
  }

  Widget _pageContainer() {
    if (title != null) {
      return _withPadding(
        Row(
          children: [
            Expanded(child: Container()),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 640,
              ),
              child: SailColumn(
                spacing: 0,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: SailStyleValues.padding50),
                    child: SailText.primary24(title ?? ''),
                  ),
                  const SailSpacing(SailStyleValues.padding08),
                  SailText.secondary13(subtitle ?? ''),
                  const SailSpacing(SailStyleValues.padding50),
                  body,
                ],
              ),
            ),
            Expanded(child: Container()),
          ],
        ),
        title,
        scrollable,
      );
    }

    return _withPadding(body, title, scrollable);
  }
}

// placed outside of class to safeguard against using any locally defined variables

Widget _withPadding(
  Widget child,
  String? title,
  bool scrollable,
) {
  if (scrollable) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: SailStyleValues.padding40,
      ),
      child: child,
    );
  }

  return Padding(
    padding: const EdgeInsets.only(
      bottom: SailStyleValues.padding20,
      top: SailStyleValues.padding15,
    ),
    child: child,
  );
}
