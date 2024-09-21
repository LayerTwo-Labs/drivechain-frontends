import 'package:auto_route/auto_route.dart';
import 'package:drivechain_client/api.dart';
import 'package:drivechain_client/pages/send_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/sail_ui.dart';
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
          return Column(
            children: [
              QtContainer(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: QtContainer(
                        child: SailColumn(
                          spacing: SailStyleValues.padding05,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: SailTextField(
                                    controller: model.addressController,
                                    hintText: 'A Drivechain address',
                                    readOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                QtIconButton(
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(text: model.addressController.text))
                                        .then((_) {
                                      if (context.mounted) showSnackBar(context, 'Copied address');
                                    }).catchError((error) {
                                      if (context.mounted) showSnackBar(context, 'Could not copy address: $error ');
                                    });
                                  },
                                  icon: Icon(
                                    Icons.content_paste_rounded,
                                    size: 15,
                                    color: theme.colors.text,
                                  ),
                                ),
                              ],
                            ),
                            QtButton(
                              onPressed: model.generateNewAddress,
                              loading: model.isBusy,
                              child: SailText.primary12('New'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    QrImageView(
                      eyeStyle: QrEyeStyle(color: theme.colors.text, eyeShape: QrEyeShape.square),
                      dataModuleStyle: QrDataModuleStyle(color: theme.colors.text),
                      data: model.addressController.text,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ],
                ),
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
    final address = await api.wallet.getNewAddress();
    addressController.text = address;
    setBusy(false);
    notifyListeners();
  }
}
