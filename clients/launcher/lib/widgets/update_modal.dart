import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

Future<bool?> showUpdateModal(BuildContext context) async {
  return await infoDialog<bool>(
    context: context,
    title: 'Update Available',
    subtitle: 'A new version of Drivechain Launcher is available. Would you like to update now?',
    onConfirm: () => Navigator.of(context).pop(true),
  );
}

class UpdateModal extends StatelessWidget {
  const UpdateModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(); // This widget is now just a placeholder since we use showUpdateModal
  }
}
