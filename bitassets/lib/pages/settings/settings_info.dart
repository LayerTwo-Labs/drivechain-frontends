import 'dart:io';

import 'package:auto_updater/auto_updater.dart';
import 'package:bitassets/gen/version.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SettingsInfo extends StatefulWidget {
  const SettingsInfo({super.key});

  @override
  State<SettingsInfo> createState() => _SettingsInfoState();
}

class _SettingsInfoState extends State<SettingsInfo> {
  bool _isCheckingForUpdates = false;
  String? _updateMessage;

  Future<void> _checkForUpdates() async {
    if (Platform.isLinux) return;

    setState(() {
      _isCheckingForUpdates = true;
      _updateMessage = null;
    });

    try {
      await autoUpdater.checkForUpdates();
      setState(() {
        _updateMessage = 'Check complete. If an update is available, you will be notified.';
      });
    } catch (e) {
      setState(() {
        _updateMessage = 'Error checking for updates: $e';
      });
    } finally {
      setState(() {
        _isCheckingForUpdates = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary20('Info'),
            SailText.secondary13('Application version and build information'),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Version'),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(AppVersion.versionString),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Build Date'),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(AppVersion.buildDate),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Commit'),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(AppVersion.commitFull),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Application'),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(AppVersion.appName),
          ],
        ),
        if (!Platform.isLinux)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary15('Updates'),
              const SailSpacing(SailStyleValues.padding08),
              SailButton(
                label: 'Check for Updates',
                loading: _isCheckingForUpdates,
                onPressed: () async => await _checkForUpdates(),
              ),
              if (_updateMessage != null) ...[
                const SailSpacing(4),
                SailText.secondary12(_updateMessage!),
              ],
            ],
          ),
      ],
    );
  }
}
