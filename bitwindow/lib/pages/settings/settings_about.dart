import 'dart:io';

import 'package:auto_updater/auto_updater.dart';
import 'package:bitwindow/gen/version.dart';
import 'package:bitwindow/services/linux_updater.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class SettingsAbout extends StatefulWidget {
  const SettingsAbout({super.key});

  @override
  State<SettingsAbout> createState() => _SettingsAboutState();
}

class _SettingsAboutState extends State<SettingsAbout> {
  LinuxUpdater? _linuxUpdater;
  UpdateStatus _updateStatus = UpdateStatus.idle;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    if (Platform.isLinux) {
      _linuxUpdater = LinuxUpdater(log: GetIt.I.get<Logger>());
    }
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _updateStatus = UpdateStatus.checking;
      _statusMessage = null;
    });

    try {
      if (Platform.isLinux) {
        final hasUpdate = await _linuxUpdater!.checkForUpdates();
        setState(() {
          _updateStatus = _linuxUpdater!.status;

          if (hasUpdate) {
            _statusMessage = 'Update available: v${_linuxUpdater!.latestVersion}';
          } else if (_updateStatus == UpdateStatus.upToDate) {
            _statusMessage = 'You have the latest version';
          } else if (_updateStatus == UpdateStatus.error) {
            _statusMessage = 'Error: ${_linuxUpdater!.errorMessage}';
          }
        });
      } else {
        await autoUpdater.checkForUpdates();
        setState(() {
          _updateStatus = UpdateStatus.upToDate;
          _statusMessage = 'Check complete. If update available, you will be notified.';
        });
      }
    } catch (e) {
      setState(() {
        _updateStatus = UpdateStatus.error;
        _statusMessage = 'Error checking for updates: $e';
      });
    }
  }

  Future<void> _performUpdate() async {
    if (!Platform.isLinux || _linuxUpdater == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => SailAlertCard(
        title: 'Update BitWindow?',
        subtitle:
            'The application will download and install version ${_linuxUpdater!.latestVersion}, then restart automatically.',
        onConfirm: () async => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _updateStatus = UpdateStatus.downloading;
      _statusMessage = 'Downloading update...';
    });

    try {
      await _linuxUpdater!.performUpdate();
    } catch (e) {
      if (mounted) {
        setState(() {
          _updateStatus = UpdateStatus.error;
          _statusMessage = 'Update failed: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: SailTheme.of(context).colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary20('About'),
        SailText.secondary13('Application version and build information'),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Updates'),
            const SailSpacing(SailStyleValues.padding08),
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailButton(
                  label: 'Check for Updates',
                  loading:
                      _updateStatus == UpdateStatus.checking ||
                      _updateStatus == UpdateStatus.downloading ||
                      _updateStatus == UpdateStatus.installing,
                  onPressed: () async => await _checkForUpdates(),
                ),
                if (_updateStatus == UpdateStatus.updateAvailable && Platform.isLinux)
                  SailButton(
                    label: 'Install Update',
                    variant: ButtonVariant.primary,
                    onPressed: () async => await _performUpdate(),
                  ),
              ],
            ),
            if (_statusMessage != null) ...[
              const SailSpacing(4),
              SailText.secondary12(
                _statusMessage!,
                color: _updateStatus == UpdateStatus.error
                    ? SailTheme.of(context).colors.error
                    : _updateStatus == UpdateStatus.updateAvailable
                    ? SailTheme.of(context).colors.primary
                    : null,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
