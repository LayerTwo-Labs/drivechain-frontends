import 'dart:io';

import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// About/version section shared by all apps; pass the app's AppVersion fields.
class SettingsInfo extends StatefulWidget {
  final String appName;
  final String versionString;
  final String buildDate;
  final String commitFull;
  final String applicationName;

  const SettingsInfo({
    super.key,
    required this.appName,
    required this.versionString,
    required this.buildDate,
    required this.commitFull,
    required this.applicationName,
  });

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
    if (!Platform.isLinux) {
      return;
    }

    final confirmed = await showThemedDialog<bool>(
      context: context,
      builder: (context) => SailAlertCard(
        title: 'Update ${widget.appName}?',
        subtitle:
            'The application will download and install version ${_updateProvider.latestVersion}, then restart automatically.',
        onConfirm: () async => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _updateProvider.performUpdate();
    } catch (e) {
      if (mounted) {
        showSailToast(
          context,
          'Update failed: $e',
          variant: SailToastVariant.destructive,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailSettingsBody(
      children: [
        SailSettingsGroup(
          title: 'Build',
          children: [
            SailSettingsRow(label: 'Application', trailing: SailText.secondary13(widget.applicationName)),
            SailSettingsRow(label: 'Version', trailing: SailText.secondary13(widget.versionString)),
            SailSettingsRow(label: 'Build date', trailing: SailText.secondary13(widget.buildDate)),
            SailSettingsRow(label: 'Commit', trailing: SailText.secondary13(widget.commitFull)),
          ],
        ),
        SailSettingsGroup(
          title: 'Updates',
          children: [
            SailSettingsRow(
              label: 'Application updates',
              description:
                  _updateProvider.errorMessage ??
                  (_updateProvider.updateAvailable
                      ? 'Update available: v${_updateProvider.latestVersion}'
                      : 'You are on the newest version'),
              descriptionColor: _updateProvider.errorMessage != null ? theme.colors.error : null,
              trailing: SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  SailButton(
                    label: 'Check for updates',
                    small: true,
                    variant: ButtonVariant.secondary,
                    loading: _updateProvider.checking || _updateProvider.updating,
                    onPressed: () async => await _checkForUpdates(),
                  ),
                  if (_updateProvider.updateAvailable && Platform.isLinux)
                    SailButton(
                      label: 'Install',
                      small: true,
                      onPressed: () async => await _performUpdate(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
