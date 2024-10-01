import 'package:drivechain_client/pages/send_page.dart';
import 'package:drivechain_client/widgets/qt_page.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:drivechain_client/widgets/qt_container.dart';
import 'package:drivechain_client/widgets/qt_button.dart';

@RoutePage()
class SidechainProposalPage extends StatelessWidget {
  const SidechainProposalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const QtPage(
      child: SidechainProposalView(),
    );
  }
}

class SidechainProposalView extends StatelessWidget {
  const SidechainProposalView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SidechainProposalViewModel>.reactive(
      viewModelBuilder: () => SidechainProposalViewModel(),
      builder: (context, model, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(SailStyleValues.padding15),
            child: Form(
              key: model.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (model.hasErrorForKey('proposal')) ...{
                    SailText.primary12(
                      'Failed to propose sidechain: ${model.error('proposal')}',
                      color: context.sailTheme.colors.error,
                    ),
                  },
                  SailText.primary20('Create Sidechain Proposal'),
                  const SizedBox(height: SailStyleValues.padding25),
                  _buildRequiredSection(context, model),
                  const SizedBox(height: SailStyleValues.padding25),
                  _buildOptionalSection(context, model),
                  const SizedBox(height: SailStyleValues.padding25),
                  QtButton(
                    onPressed: () {
                      if (model.formKey.currentState!.validate()) {
                        model.proposeSidechain(context);
                      }
                    },
                    child: model.isProposing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : SailText.primary13('Propose Sidechain'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequiredSection(BuildContext context, SidechainProposalViewModel model) {
    return QtContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary15('Required'),
          const SizedBox(height: SailStyleValues.padding15),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SailTextFormField(
                  label: 'Slot #',
                  controller: model.slotController,
                  hintText: '0-255',
                  keyboardType: TextInputType.number,
                  validator: (value) => model.validateSlot(value),
                  errorText: model.slotError,
                ),
              ),
              const SizedBox(width: SailStyleValues.padding15),
              Expanded(
                flex: 3,
                child: SailTextFormField(
                  label: 'Title',
                  hintText: 'Sidechain title',
                  controller: model.titleController,
                  validator: (value) => model.validateTitle(value),
                  errorText: model.titleError,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalSection(BuildContext context, SidechainProposalViewModel model) {
    return QtContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SailText.primary15('Optional (but recommended)'),
              const SizedBox(width: SailStyleValues.padding08),
              QtIconButton(
                icon: const Icon(Icons.info_outline, size: 16),
                onPressed: () => _showInfoDialog(context),
              ),
            ],
          ),
          const SizedBox(height: SailStyleValues.padding15),
          SailTextFormField(
            label: 'Description',
            hintText: 'Sidechain description',
            controller: model.descriptionController,
            maxLines: 5,
          ),
          const SizedBox(height: SailStyleValues.padding15),
          SailTextFormField(
            label: 'Version',
            hintText: '0',
            controller: model.versionController,
            keyboardType: TextInputType.number,
            validator: (value) => model.validateVersion(value),
            errorText: model.versionError,
          ),
          const SizedBox(height: SailStyleValues.padding15),
          SailTextFormField(
            label: 'Release tarball hash (256 bits)',
            hintText: 'Gitian build tarball hash (Linux x86-64)',
            controller: model.tarballHashController,
            validator: (value) => model.validateHash(value, 256),
            errorText: model.tarballHashError,
          ),
          const SizedBox(height: SailStyleValues.padding15),
          SailTextFormField(
            label: 'Build commit hash (160 bits)',
            hintText: 'Gitian build commit hash',
            controller: model.commitHashController,
            validator: (value) => model.validateHash(value, 160),
            errorText: model.commitHashError,
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Optional Fields'),
          content: const Text(
            'These fields are optional but recommended. They provide additional information about your sidechain proposal, which can help others understand and evaluate it better.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class SidechainProposalViewModel extends BaseViewModel {
  final formKey = GlobalKey<FormState>();
  final slotController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final versionController = TextEditingController();
  final tarballHashController = TextEditingController();
  final commitHashController = TextEditingController();

  String? slotError;
  String? titleError;
  String? versionError;
  String? tarballHashError;
  String? commitHashError;

  bool isProposing = false;

  SidechainProposalViewModel() {
    slotController.addListener(notifyListeners);
    titleController.addListener(notifyListeners);
    versionController.addListener(notifyListeners);
    tarballHashController.addListener(notifyListeners);
    commitHashController.addListener(notifyListeners);
  }

  bool get isFormValid {
    return formKey.currentState?.validate() ?? false;
  }

  String? validateSlot(String? value) {
    if (value == null || value.isEmpty) {
      return 'Slot number is required';
    }
    final intValue = int.tryParse(value);
    if (intValue == null || intValue < 0 || intValue > 255) {
      return 'Slot must be between 0 and 255';
    }
    return null;
  }

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    return null;
  }

  String? validateVersion(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final intValue = int.tryParse(value);
    if (intValue == null || intValue < 0) {
      return 'Version must be a positive integer';
    }
    return null;
  }

  String? validateHash(String? value, int bits) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length != bits ~/ 4) {
      return 'Hash must be $bits bits long';
    }
    if (!RegExp(r'^[a-fA-F0-9]+$').hasMatch(value)) {
      return 'Hash must contain only hexadecimal characters';
    }
    return null;
  }

  Future<void> proposeSidechain(BuildContext context) async {
    if (!isFormValid) return;

    isProposing = true;
    notifyListeners();

    try {
      // TODO: Implement the actual API call to propose the sidechain
      await Future.delayed(const Duration(seconds: 2)); // Simulating API call

      // If successful, close the modal
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to propose sidechain: $e')),
        );
      }

      setErrorForObject('proposal', e);
    } finally {
      isProposing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    slotController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    versionController.dispose();
    tarballHashController.dispose();
    commitHashController.dispose();
    super.dispose();
  }
}

Future<void> showSidechainProposalModal(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: const SidechainProposalView(),
        ),
      );
    },
  );
}
