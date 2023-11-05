import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_app_bar.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class SailPage extends StatelessWidget {
  final String title;
  final Widget? widgetTitle;
  final Widget body;
  final bool scrollable;

  const SailPage({
    super.key,
    required this.title,
    required this.body,
    this.widgetTitle,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final backgroundColor = theme.colors.background;
    final scaffold = SelectionArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: title == '' && widgetTitle == null
            ? null
            : SailAppBar.build(
                context,
                title: widgetTitle != null
                    ? widgetTitle!
                    : SailText.primary20(
                        title,
                        bold: true,
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
        child: Padding(padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding40), child: body),
      );
    } else {
      return Padding(
        padding: widgetTitle != null
            ? const EdgeInsets.symmetric(vertical: SailStyleValues.padding10)
            : const EdgeInsets.only(
                bottom: SailStyleValues.padding20,
              ),
        child: body,
      );
    }
  }
}
