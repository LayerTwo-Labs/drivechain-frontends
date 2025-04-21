import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

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
          child: SailCard(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(SailStyleValues.padding16),
                child: SailColumn(
                  spacing: SailStyleValues.padding32,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: SailStyleValues.padding32),
                      child: SailColumn(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: SailStyleValues.padding04,
                        trailingSpacing: true,
                        children: [
                          ActionHeaderChip(title: category),
                          for (final child in children) child,
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(SailStyleValues.padding04),
                      child: SailRow(
                        spacing: SailStyleValues.padding10,
                        children: [
                          Expanded(child: Container()),
                          SailButton(
                            label: 'Close',
                            variant: ButtonVariant.ghost,
                            onPressed: () async {
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
  final Future<void> Function() onPressed;

  const HelpButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SailButton(
      variant: ButtonVariant.icon,
      onPressed: onPressed,
      icon: SailSVGAsset.iconQuestion,
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
      child: SailText.primary13(text),
    );
  }
}
