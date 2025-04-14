import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

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
            padding: const EdgeInsets.all(SailStyleValues.padding16),
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
                  SailText.primary12('Required'),
                  const SizedBox(height: SailStyleValues.padding08),
                  _buildRequiredSection(context, model),
                  const SizedBox(height: SailStyleValues.padding25),
                  Row(
                    children: [
                      SailText.primary12('Optional (but recommended)'),
                      const SizedBox(width: SailStyleValues.padding08),
                      SailButton(
                        label: 'Read more',
                        variant: ButtonVariant.ghost,
                        icon: SailSVGAsset.iconInfo,
                        onPressed: () async => _showInfoDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: SailStyleValues.padding08),
                  _buildOptionalSection(context, model),
                  const SizedBox(height: SailStyleValues.padding25),
                  SailButton(
                    label: 'Propose Sidechain',
                    onPressed: () async {
                      if (model.formKey.currentState!.validate()) {
                        await model.proposeSidechain(context);
                      }
                    },
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  size: TextFieldSize.small,
                ),
              ),
              const SizedBox(width: SailStyleValues.padding16),
              Expanded(
                flex: 3,
                child: SailTextFormField(
                  label: 'Title',
                  hintText: 'Sidechain title',
                  controller: model.titleController,
                  validator: (value) => model.validateTitle(value),
                  errorText: model.titleError,
                  size: TextFieldSize.small,
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
          SailTextFormField(
            label: 'Description',
            hintText: 'Sidechain description',
            controller: model.descriptionController,
            maxLines: 5,
            size: TextFieldSize.small,
          ),
          const SizedBox(height: SailStyleValues.padding16),
          SailTextFormField(
            label: 'Version',
            hintText: '0',
            controller: model.versionController,
            keyboardType: TextInputType.number,
            validator: (value) => model.validateVersion(value),
            errorText: model.versionError,
            size: TextFieldSize.small,
          ),
          const SizedBox(height: SailStyleValues.padding16),
          SailTextFormField(
            label: 'Release tarball hash (256 bits)',
            hintText: 'Gitian build tarball hash (Linux x86-64)',
            controller: model.tarballHashController,
            validator: (value) => model.validateHash(value, 256),
            errorText: model.tarballHashError,
            size: TextFieldSize.small,
          ),
          const SizedBox(height: SailStyleValues.padding16),
          SailTextFormField(
            label: 'Build commit hash (160 bits)',
            hintText: 'Gitian build commit hash',
            controller: model.commitHashController,
            validator: (value) => model.validateHash(value, 160),
            errorText: model.commitHashError,
            size: TextFieldSize.small,
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Center(
          child: SailCard(
            child: Padding(
              padding: const EdgeInsets.all(SailStyleValues.padding16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary12('''
These fields are optional but highly recommended.

Description:
Brief description of the sidechain's purpose and where to find more information.

Release tarball hash:
Hash of the original gitian software build of this sidechain.
Use the sha256sum utility to generate this hash, or copy the hash when it is printed to the console after gitian builds complete.

Example:
sha256sum Drivechain-12.0.21.00-x86_64-linux-gnu.tar.gz

Result:
fd9637e427f1e967cc658bfe1a836d537346ce3a6dd0746878129bb5bc646680  Drivechain-12-0.21.00-x86_64-linux-gnu.tar.gz

Build commit hash (160 bits):
If the software was developed using git, the build commit hash should match the commit hash of the first sidechain release.
To verify it later, you can look up this commit in the repository history.

These help users find the sidechain full node software. Only this software can filter out invalid withdrawals.
                      '''),
                ],
              ),
            ),
          ),
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

  DrivechainAPI get drivechain => GetIt.I.get<DrivechainAPI>();

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

    return showSnackBar(context, 'Propose sidechain not implemented');
    /*
    try {
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
    */
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

Future<void> showSidechainProposalModal(BuildContext context) {
  return showDialog<void>(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.2,
          vertical: MediaQuery.of(context).size.height * 0.01,
        ),
        child: Material(
          clipBehavior: Clip.antiAlias,
          borderRadius: SailStyleValues.borderRadius,
          child: const SidechainProposalPage(),
        ),
      );
    },
  );
}
