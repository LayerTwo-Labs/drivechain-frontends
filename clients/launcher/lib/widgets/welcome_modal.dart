import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/buttons/button.dart';

Future<bool?> showWelcomeModal(BuildContext context) async {
  return await widgetDialog<bool>(
    context: context,
    title: 'Welcome to Drivechain',
    child: const _WelcomeModalContent(),
  );
}

class WelcomeModal extends StatelessWidget {
  const WelcomeModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(); // Placeholder since we use showWelcomeModal
  }
}

class _WelcomeModalContent extends StatefulWidget {
  const _WelcomeModalContent({Key? key}) : super(key: key);

  @override
  _WelcomeModalContentState createState() => _WelcomeModalContentState();
}

class _WelcomeModalContentState extends State<_WelcomeModalContent> {
  bool _showAdvanced = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleFastMode() {
    // TODO: Implement fast withdrawal creation logic
    Navigator.of(context).pop(true);
  }

  void _handleAdvancedMode() {
    setState(() {
      _showAdvanced = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding12,
      mainAxisSize: MainAxisSize.min,
      children: [
        SailText.primary15(
          'Welcome to Drivechain Launcher! This application helps you manage and interact with your Drivechain sidechains.',
          color: SailTheme.of(context).colors.textSecondary,
        ),
        const SizedBox(height: 8),
        SailText.primary15(
          'Get started by creating a wallet!',
          color: SailTheme.of(context).colors.textSecondary,
        ),
        if (_showAdvanced) ...[
          const SizedBox(height: 16),
          SailTextField(
            controller: _textController,
            hintText: 'Enter advanced settings...',
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SailButton.secondary(
              'Fast Mode',
              onPressed: _handleFastMode,
              size: ButtonSize.regular,
            ),
            const SizedBox(width: 8),
            SailButton.primary(
              'Advanced Mode',
              onPressed: _handleAdvancedMode,
              size: ButtonSize.regular,
            ),
          ],
        ),
      ],
    );
  }
}
