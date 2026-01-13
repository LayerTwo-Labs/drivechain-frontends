import 'dart:async';
import 'dart:io';

import 'package:bitwindow/main.dart' show bootBinaries;
import 'package:bitwindow/pages/settings_page.dart' show ResetProgressDialog;
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';

class SettingsReset extends StatefulWidget {
  const SettingsReset({super.key});

  @override
  State<SettingsReset> createState() => _SettingsResetState();
}

class _SettingsResetState extends State<SettingsReset> {
  Logger get log => GetIt.I.get<Logger>();
  Directory get appDir => GetIt.I.get<BinaryProvider>().appDir;

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary20('Reset'),
        SailText.secondary13('Start fresh by resetting various data'),
        SailButton(
          label: 'Reset Blockchain Data',
          variant: ButtonVariant.destructive,
          onPressed: () async {
            await _resetBlockchainData(context);
          },
        ),
        SailButton(
          label: 'Delete All Wallets',
          variant: ButtonVariant.destructive,
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => SailAlertCard(
                title: 'Reset Wallet?',
                subtitle:
                    'Are you sure you want to reset all wallet data? This will:\n\n'
                    '• Permanently delete all wallet files from BitWindow\n'
                    '• Permanently delete all wallet files from the Enforcer\n'
                    '• Stop all running processes\n'
                    '• Return you to the wallet creation screen\n\n'
                    'Make sure to backup your seed phrase before proceeding. This action cannot be undone.',
                confirmButtonVariant: ButtonVariant.destructive,
                onConfirm: () async {
                  Navigator.of(context).pop(true);
                },
              ),
            );
            if (confirmed == true && context.mounted) {
              final router = GetIt.I.get<AppRouter>();
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => ResetProgressDialog(
                  resetFunction: (updateStatus) async {
                    await _resetWallets(context, onStatusUpdate: updateStatus);
                  },
                  onComplete: () async {
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                    unawaited(bootBinaries(log));
                  },
                ),
              );
              await Future.delayed(const Duration(milliseconds: 100));
              await router.replaceAll([SailCreateWalletRoute(homeRoute: const RootRoute())]);
            }
          },
        ),
        SailButton(
          label: 'Reset Everything',
          variant: ButtonVariant.destructive,
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => SailAlertCard(
                title: 'Reset Everything?',
                subtitle:
                    'Are you sure you want to reset absolutely everything? Even wallets will be deleted. This action cannot be undone.',
                confirmButtonVariant: ButtonVariant.destructive,
                onConfirm: () async {
                  Navigator.of(context).pop(true);
                },
              ),
            );
            if (confirmed == true && context.mounted) {
              await _resetEverything(context);
            }
          },
          skipLoading: true,
        ),
      ],
    );
  }

  Future<void> _resetBlockchainData(BuildContext context) async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();

    final binaries = [
      BitcoinCore(),
      Enforcer(),
      BitWindow(),
    ];

    final futures = <Future>[];
    for (final binary in binaries) {
      futures.add(binaryProvider.stop(binary));
    }

    await Future.wait(futures);

    await Future.delayed(const Duration(seconds: 3));

    for (final binary in binaries) {
      await binary.wipeAppDir();
    }

    unawaited(bootBinaries(GetIt.I.get<Logger>()));

    final mainchainRPC = GetIt.I.get<MainchainRPC>();
    while (!mainchainRPC.connected) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _resetWallets(
    BuildContext context, {
    Future<void> Function()? beforeBoot,
    void Function(String status)? onStatusUpdate,
  }) async {
    final logger = GetIt.I.get<Logger>();

    try {
      await GetIt.I.get<WalletWriterProvider>().deleteAllWallets(
        beforeBoot: beforeBoot,
        onStatusUpdate: onStatusUpdate,
      );
    } catch (e) {
      logger.e('could not reset wallet data: $e');

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not reset wallets: $e'),
            backgroundColor: SailTheme.of(context).colors.error,
          ),
        );
      }
    }
  }

  Future<void> _resetEverything(BuildContext context) async {
    final router = GetIt.I.get<AppRouter>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ResetProgressDialog(
        resetFunction: (updateStatus) async {
          updateStatus('Wiping wallets');

          await _resetWallets(
            context,
            onStatusUpdate: updateStatus,
            beforeBoot: () async {
              log.i('resetting blockchain data');

              final allBinaries = [
                BitcoinCore(),
                Enforcer(),
                BitWindow(),
                Thunder(),
                BitNames(),
                BitAssets(),
                ZSide(),
              ];

              updateStatus('Wiping blockchain data');

              try {
                await Future.wait(allBinaries.map((binary) => binary.wipeAppDir()));
                log.i('Successfully wiped all blockchain data');
              } catch (e) {
                log.e('could not reset blockchain data: $e');
              }

              updateStatus('Wiping asset data');

              try {
                await Future.wait(allBinaries.map((binary) => binary.wipeAsset(binDir(appDir.path))));

                await copyBinariesFromAssets(log, appDir);
                log.i('Successfully wiped all blockchain data');
              } catch (e) {
                log.e('could not reset blockchain data: $e');
              }
            },
          );
        },
        onComplete: () async {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    );

    await Future.delayed(const Duration(milliseconds: 100));
    unawaited(bootBinaries(log));
    await router.replaceAll([SailCreateWalletRoute(homeRoute: const RootRoute())]);
  }
}
