import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class DashboardActionModal extends StatelessWidget {
  const DashboardActionModal(
    this.title, {
    super.key,
    required this.children,
    required this.endActionButton,
  });

  final String title;
  final List<Widget> children;
  final Widget endActionButton;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Dialog(
      backgroundColor: theme.colors.actionHeader,
      child: SailRawCard(
        child: SailColumn(
          spacing: SailStyleValues.padding64,
          mainAxisSize: MainAxisSize.min,
          children: [
            SailColumn(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 0,
              withDivider: true,
              trailingSpacing: true,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: SailStyleValues.padding16,
                    top: SailStyleValues.padding16,
                  ),
                  child: ActionHeaderChip(title: title),
                ),
                for (final child in children) child,
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(SailStyleValues.padding20),
              child: SailRow(
                spacing: SailStyleValues.padding10,
                children: [
                  Expanded(child: Container()),
                  SailButton(
                    label: 'Cancel',
                    variant: ButtonVariant.ghost,
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                  endActionButton,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
