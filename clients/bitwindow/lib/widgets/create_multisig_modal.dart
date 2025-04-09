import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class CreateMultisigModal extends StatelessWidget {
  const CreateMultisigModal({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateMultisigModalViewModel>.reactive(
      viewModelBuilder: () => CreateMultisigModalViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SailCard(
              title: 'Create ${model.n} of ${model.m} Multisig Lounge',
              subtitle: 'Create a new multisig wallet with multiple participants',
              error: model.modelError,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // First key (automatically derived)
                  SailColumn(
                    spacing: SailStyleValues.padding08,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary13('First Key (Your Key)'),
                      SailText.secondary12(
                        "Automatically derived from path m/44'/0'/0'/${7000 + model.nextP}",
                        color: context.sailTheme.colors.textTertiary,
                      ),
                      const SailSpacing(SailStyleValues.padding08),
                      SailTextField(
                        controller: model.firstKeyController,
                        readOnly: true,
                        hintText: 'Your public key will appear here',
                      ),
                    ],
                  ),
                  const SailSpacing(SailStyleValues.padding16),

                  // Lounge Name
                  SailColumn(
                    spacing: SailStyleValues.padding08,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary13('Lounge Name'),
                      SailText.secondary12(
                        'Enter a name for this multisig lounge',
                        color: context.sailTheme.colors.textTertiary,
                      ),
                      const SailSpacing(SailStyleValues.padding08),
                      SailTextField(
                        controller: model.loungeNameController,
                        hintText: 'Enter lounge name',
                      ),
                    ],
                  ),
                  const SailSpacing(SailStyleValues.padding16),

                  // N and M selection
                  SailRow(
                    spacing: SailStyleValues.padding16,
                    children: [
                      Expanded(
                        child: SailColumn(
                          spacing: SailStyleValues.padding08,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SailText.primary13('Required Signatures (N)'),
                            SailDropdownButton<int>(
                              value: model.n,
                              items: List.generate(model.m, (i) => i + 1)
                                  .map(
                                    (n) => SailDropdownItem(
                                      value: n,
                                      child: SailText.primary13('$n'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: model.setN,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SailColumn(
                          spacing: SailStyleValues.padding08,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SailText.primary13('Total Participants (M)'),
                            SailDropdownButton<int>(
                              value: model.m,
                              items: List.generate(15, (i) => i + 2)
                                  .map(
                                    (m) => SailDropdownItem(
                                      value: m,
                                      child: SailText.primary13('$m'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: model.setM,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SailSpacing(SailStyleValues.padding16),

                  // Additional keys
                  ...List.generate(
                    model.m - 1,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: SailStyleValues.padding16),
                      child: SailColumn(
                        spacing: SailStyleValues.padding08,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailText.primary13('Key ${i + 2}'),
                          SailTextField(
                            controller: model.additionalKeyControllers[i],
                            hintText: 'Enter public key',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Action buttons
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SailButton(
                        label: 'Create',
                        onPressed: model.canCreate ? () => model.create(context) : null,
                      ),
                      SailButton(
                        label: 'Cancel',
                        variant: ButtonVariant.ghost,
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CreateMultisigModalViewModel extends BaseViewModel {
  final TextEditingController firstKeyController = TextEditingController();
  final TextEditingController loungeNameController = TextEditingController();
  final List<TextEditingController> additionalKeyControllers = [];
  Logger get log => GetIt.I.get<Logger>();

  int n = 2; // Required signatures
  int m = 2; // Total participants
  int nextP = 0;
  String? _multisigDir;
  String? _configPath;

  bool get canCreate =>
      loungeNameController.text.isNotEmpty && additionalKeyControllers.every((c) => c.text.isNotEmpty);

  Future<void> init() async {
    try {
      // Initialize directories
      final appDir = await Environment.datadir();
      _multisigDir = '${appDir.path}/bitdrive/multisig';
      _configPath = '$_multisigDir/multisig.conf';

      // Create directory if it doesn't exist
      final dir = Directory(_multisigDir!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Read or create config file
      final configFile = File(_configPath!);
      if (!await configFile.exists()) {
        await configFile.writeAsString('');
      }

      // Parse config to find next P
      nextP = await _getNextP();

      // Initialize controllers
      _updateControllers();

      notifyListeners();
    } catch (e) {
      log.e('Error initializing multisig modal: $e');
      setError(e.toString());
    }
  }

  Future<int> _getNextP() async {
    try {
      final file = File(_configPath!);
      final lines = await file.readAsLines();

      // Find highest P value
      int maxP = -1;
      for (final line in lines) {
        if (line.trim().isEmpty) continue;

        final parts = line.split('=');
        if (parts.length != 2) continue;

        final pStr = parts[0].trim();
        if (!pStr.startsWith('P')) continue;

        try {
          final p = int.parse(pStr.substring(1));
          maxP = p > maxP ? p : maxP;
        } catch (_) {
          continue;
        }
      }

      return maxP + 1;
    } catch (e) {
      log.e('Error getting next P value: $e');
      return 0;
    }
  }

  void _updateControllers() {
    // Clear existing controllers
    for (final controller in additionalKeyControllers) {
      controller.dispose();
    }
    additionalKeyControllers.clear();

    // Add new controllers
    for (int i = 0; i < m - 1; i++) {
      additionalKeyControllers.add(TextEditingController());
    }

    notifyListeners();
  }

  void setN(int? value) {
    if (value != null && value <= m) {
      n = value;
      notifyListeners();
    }
  }

  void setM(int? value) {
    if (value != null && value >= n) {
      m = value;
      _updateControllers();
    }
  }

  Future<void> create(BuildContext context) async {
    if (!canCreate) return;

    setBusy(true);
    try {
      // Validate lounge name
      final name = loungeNameController.text.trim();
      if (name.isEmpty) {
        throw Exception('Lounge name cannot be empty');
      }

      // Add entry to config file
      final file = File(_configPath!);
      await file.writeAsString(
        'P$nextP="$name"\n',
        mode: FileMode.append,
      );

      // TODO: Implement key derivation and multisig creation logic

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      log.e('Error creating multisig lounge: $e');
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    firstKeyController.dispose();
    loungeNameController.dispose();
    for (final controller in additionalKeyControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
