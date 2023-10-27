import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_app_bar.dart';

class SailPage extends StatelessWidget {
  final String title;
  final Widget body;
  final bool scrollable;

  const SailPage({
    super.key,
    required this.title,
    required this.body,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final backgroundColor = theme.colors.background;
    final scaffold = Scaffold(
      backgroundColor: backgroundColor,
      appBar: SailAppBar.build(
        context,
        title: title,
      ),
      body: buildBody(context),
    );
    return scaffold;
  }

  Widget buildBody(BuildContext context) {
    if (scrollable) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: body,
      );
    } else {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: SailStyleValues.padding20,
            bottom: SailStyleValues.padding20,
            left: SailStyleValues.padding10,
            right: SailStyleValues.padding10,
          ),
          child: body,
        ),
      );
    }
  }
}
