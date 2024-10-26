import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/servers/api.dart';
import 'package:bitwindow/widgets/error_container.dart';
import 'package:bitwindow/widgets/qt_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/containers/qt_page.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class ReceivePage extends StatelessWidget {
  const ReceivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return QtPage(
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => ReceivePageViewModel(),
        onViewModelReady: (model) => model.init(),
        builder: (context, model, child) {
          if (model.hasError) {
            return ErrorContainer(
              error: model.modelError.toString(),
              onRetry: () => model.init(),
            );
          }
          return Column(
            children: [
              SailRow(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: SailStyleValues.padding08,
                children: [
                  Expanded(
                    child: SailRawCard(
                      title: 'Receive Bitcoin',
                      child: SailColumn(
                        spacing: SailStyleValues.padding16,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailRow(
                            spacing: SailStyleValues.padding08,
                            children: [
                              Expanded(
                                child: SailTextField(
                                  controller: model.addressController,
                                  hintText: 'A Drivechain address',
                                  readOnly: true,
                                ),
                              ),
                              CopyButton(
                                text: model.addressController.text,
                              ),
                            ],
                          ),
                          QtButton(
                            label: 'Generate new address',
                            onPressed: model.generateNewAddress,
                            loading: model.isBusy,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: SailRawCard(
                      padding: true,
                      child: QrImageView(
                        padding: EdgeInsets.zero,
                        eyeStyle: QrEyeStyle(
                          color: theme.colors.text,
                          eyeShape: QrEyeShape.square,
                        ),
                        dataModuleStyle: QrDataModuleStyle(color: theme.colors.text),
                        data: model.addressController.text,
                        version: QrVersions.auto,
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class ReceivePageViewModel extends BaseViewModel {
  final API api = GetIt.I.get<API>();

  TextEditingController addressController = TextEditingController();

  void init() {
    generateNewAddress();
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  void generateNewAddress() async {
    setBusy(true);
    try {
      final address = await api.wallet.getNewAddress();
      addressController.text = address;
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }
}
