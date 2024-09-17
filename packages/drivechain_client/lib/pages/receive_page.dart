import 'package:auto_route/auto_route.dart';
import 'package:drivechain_client/pages/send_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class ReceivePage extends StatelessWidget {
  const ReceivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => ReceivePageViewModel(),
        onViewModelReady: (viewModel) => viewModel.init(),
        builder: (context, viewModel, child) {
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: SailTextField(
                                    controller: viewModel.addressController,
                                    hintText: 'A Drivechain address',
                                    readOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                QtIconButton(
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(text: viewModel.addressController.text))
                                        .then((_) {
                                      if (context.mounted) showSnackBar(context, 'Copied address');
                                    }).catchError((error) {
                                      if (context.mounted) showSnackBar(context, 'Could not copy address: $error ');
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.content_paste_rounded,
                                    size: 20.0,
                                  ),
                                ),
                              ],
                            ),
                            QtButton(
                              onPressed: viewModel.generateNewAddress,
                              child: SailText.primary12('New'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    QrImageView(
                      data: viewModel.addressController.text,
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
  late TextEditingController addressController;

  void init() {
    addressController = TextEditingController(text: '1KwVGQhtYkrbNgHpSUjUpbrfCGu9WXgZhS');
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  void generateNewAddress() {
    addressController.text = 'NewGeneratedAddress';
    notifyListeners();
  }
}
