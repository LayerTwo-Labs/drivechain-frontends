import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class QuestionContainer extends StatelessWidget {
  final String category;
  final List<Widget> children;

  const QuestionContainer({
    super.key,
    required this.category,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SelectionArea(
      child: Dialog(
        backgroundColor: theme.colors.actionHeader,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 540,
            maxHeight: 540,
          ),
          child: SailRawCard(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(SailStyleValues.padding15),
                child: SailColumn(
                  spacing: SailStyleValues.padding30,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: SailStyleValues.padding30),
                      child: SailColumn(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 0,
                        withDivider: true,
                        trailingSpacing: true,
                        children: [
                          ActionHeaderChip(title: category),
                          for (final child in children) child,
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(SailStyleValues.padding05),
                      child: SailRow(
                        spacing: SailStyleValues.padding10,
                        children: [
                          Expanded(child: Container()),
                          SailTextButton(
                            label: 'Close',
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HelpButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HelpButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SailScaleButton(
      onPressed: onPressed,
      child: SailSVG.icon(SailSVGAsset.iconQuestion),
    );
  }
}

class QuestionTitle extends StatelessWidget {
  final String question;

  const QuestionTitle(
    this.question, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: SailStyleValues.padding25,
      ),
      child: SailText.primary20(question),
    );
  }
}

class QuestionText extends StatelessWidget {
  final String text;

  const QuestionText(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: SailStyleValues.padding08,
      ),
      child: SailText.secondary13(text),
    );
  }
}
