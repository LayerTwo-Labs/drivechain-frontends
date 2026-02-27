import 'dart:io';

import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:photon/gen/version.dart';
import 'package:sail_ui/sail_ui.dart';

class SettingsInfo extends StatefulWidget {
  const SettingsInfo({super.key});

  @override
  State<SettingsInfo> createState() => _SettingsInfoState();
}

class _SettingsInfoState extends State<SettingsInfo> {
  UpdateProvider get _updateProvider => GetIt.I.get<UpdateProvider>();

  @override
  void initState() {
    super.initState();
    _updateProvider.addListener(_onUpdateProviderChanged);
  }

  @override
  void dispose() {
    _updateProvider.removeListener(_onUpdateProviderChanged);
    super.dispose();
  }

  void _onUpdateProviderChanged() {
    setState(() {});
  }

  Future<void> _checkForUpdates() async {
    if (Platform.isLinux) {
      await _updateProvider.checkNow();
    } else {
      await autoUpdater.checkForUpdates();
    }
  }

  Future<void> _performUpdate() async {
    if (!Platform.isLinux) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => SailAlertCard(
        title: 'Update Photon?',
        subtitle:
            'The application will download and install version ${_updateProvider.latestVersion}, then restart automatically.',
        onConfirm: () async => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed != true) return;

    try {
      await _updateProvider.performUpdate();
    } catch (e) {
      if (mounted) {
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
                  loading: _updateProvider.checking || _updateProvider.updating,
                  onPressed: () async => await _checkForUpdates(),
                ),
                if (_updateProvider.updateAvailable && Platform.isLinux)
                  SailButton(
                    label: 'Install Update',
                    variant: ButtonVariant.primary,
                    onPressed: () async => await _performUpdate(),
                  ),
              ],
            ),
            if (_updateProvider.errorMessage != null) ...[
              const SailSpacing(4),
              SailText.secondary12(
                _updateProvider.errorMessage!,
                color: SailTheme.of(context).colors.error,
              ),
            ] else if (_updateProvider.updateAvailable) ...[
              const SailSpacing(4),
              SailText.secondary12(
                'Update available: v${_updateProvider.latestVersion}',
                color: SailTheme.of(context).colors.primary,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
