import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:bitwindow/pages/tools/hash_calculator_viewmodel.dart';

@RoutePage()
class HashCalculatorPage extends StatelessWidget {
  const HashCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HashCalculatorViewModel>.reactive(
      viewModelBuilder: () => HashCalculatorViewModel(),
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(SailStyleValues.padding16),
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Hash Calculator
                SailRawCard(
                  title: 'Basic Hash Calculator',
                  subtitle: 'Calculate SHA256, SHA256D, and SHA512 hashes',
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailRow(
                        spacing: SailStyleValues.padding08,
                        children: [
                          QtButton(
                            label: 'Clear',
                            onPressed: viewModel.clearBasic,
                            size: ButtonSize.small,
                          ),
                          QtButton(
                            label: 'Paste',
                            onPressed: viewModel.pasteFromClipboard,
                            size: ButtonSize.small,
                          ),
                          if (viewModel.canFlip)
                            QtButton(
                              label: 'Flip',
                              onPressed: viewModel.flipHex,
                              size: ButtonSize.small,
                              style: SailButtonStyle.secondary,
                            ),
                        ],
                      ),
                      SailRow(
                        spacing: SailStyleValues.padding08,
                        children: [
                          SailText.primary13('Hex mode:'),
                          Switch(
                            value: viewModel.isHexMode,
                            onChanged: (_) => viewModel.toggleHexMode(),
                          ),
                          const SizedBox(width: 16),
                          SailText.primary13('Bitcoin Utility:'),
                          Switch(
                            value: viewModel.showBitcoinUsage,
                            onChanged: (_) => viewModel.toggleBitcoinUsage(),
                          ),
                          if (viewModel.isHexMode && viewModel.invalidHex)
                            SailRow(
                              spacing: SailStyleValues.padding04,
                              children: [
                                Icon(Icons.warning, color: SailColorScheme.orange, size: 16),
                                SailText.secondary13(
                                  'Invalid hex input',
                                  color: SailColorScheme.orange,
                                ),
                              ],
                            ),
                        ],
                      ),
                      SailTextField(
                        controller: viewModel.basicInputController,
                        label: viewModel.isHexMode ? 'Enter Hex' : 'Enter text',
                        hintText: viewModel.isHexMode ? 'Enter hex value' : 'Enter text to hash',
                        maxLines: 5,
                        size: TextFieldSize.small,
                      ),
                      if (viewModel.getBasicOutput() != null)
                        SelectableRegion(
                          focusNode: FocusNode(),
                          selectionControls: MaterialTextSelectionControls(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...viewModel.getHashSections().map((section) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: RichText(
                                    text: TextSpan(
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      children: [
                                        TextSpan(
                                          text: section.title + (viewModel.showBitcoinUsage ? ' - ${section.bitcoinUsage}' : '') + ':\n',
                                        ),
                                        TextSpan(text: section.output.hex + '\n'),
                                        TextSpan(text: section.output.bin + '\n'),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    const TextSpan(text: '\nDecode:\n'),
                                    TextSpan(text: viewModel.getBasicOutput()!.split('Decode:\n')[1]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // HMAC Calculator
                SailRawCard(
                  title: 'HMAC Calculator',
                  subtitle: 'Calculate HMAC-SHA256 and HMAC-SHA512',
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailRow(
                        spacing: SailStyleValues.padding08,
                        children: [
                          QtButton(
                            label: 'Clear',
                            onPressed: viewModel.clearHmac,
                            size: ButtonSize.small,
                          ),
                        ],
                      ),
                      SailRow(
                        spacing: SailStyleValues.padding08,
                        children: [
                          SailText.primary13('Hex mode:'),
                          Switch(
                            value: viewModel.hmacIsHexMode,
                            onChanged: (_) => viewModel.toggleHmacHexMode(),
                          ),
                          if (viewModel.hmacIsHexMode && viewModel.hmacInvalidHex)
                            SailRow(
                              spacing: SailStyleValues.padding04,
                              children: [
                                Icon(Icons.warning, color: SailColorScheme.orange, size: 16),
                                SailText.secondary13(
                                  'Invalid hex input',
                                  color: SailColorScheme.orange,
                                ),
                              ],
                            ),
                        ],
                      ),
                      SailTextField(
                        controller: viewModel.hmacKeyController,
                        label: viewModel.hmacIsHexMode ? 'Key (hex)' : 'Key',
                        hintText: viewModel.hmacIsHexMode ? 'Enter hex key' : 'Enter key',
                        size: TextFieldSize.small,
                      ),
                      SailTextField(
                        controller: viewModel.hmacMessageController,
                        label: viewModel.hmacIsHexMode ? 'Message (hex)' : 'Message',
                        hintText: viewModel.hmacIsHexMode ? 'Enter hex message' : 'Enter message',
                        maxLines: 5,
                        size: TextFieldSize.small,
                      ),
                      if (viewModel.getHmacOutput() != null)
                        SelectableText(
                          viewModel.getHmacOutput()!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}