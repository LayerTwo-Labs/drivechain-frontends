import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:zside/pages/tabs/sidechain_overview_page.dart';

class ZSideWidgetCatalog {
  static final Map<String, HomepageWidgetInfo> _widgets = {
    'balance_card': HomepageWidgetInfo(
      id: 'balance_card',
      name: 'Balance Card',
      description: 'Shows ZSide balance',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconWallet,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          return SizedBox(
            height: 200,
            child: SailCard(
              title: 'Balance',
              child: SailColumn(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary24(
                    '${formatBitcoin(model.totalBalance)} ${model.ticker}',
                    bold: true,
                  ),
                  const SizedBox(height: 4),
                  BalanceRow(
                    label: 'Available',
                    amount: model.balance,
                    ticker: model.ticker,
                  ),
                  BalanceRow(
                    label: 'Pending',
                    amount: model.pendingBalance,
                    ticker: model.ticker,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),

    'transparent_receive_card': HomepageWidgetInfo(
      id: 'transparent_receive_card',
      name: 'Receive Transparent',
      description: 'Shows transparent receive address',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconReceive,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          return SizedBox(
            height: 150,
            child: SailCard(
              title: 'Receive - Transparent Address',
              error: model.receiveError,
              child: SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  Expanded(
                    child: SailTextField(
                      controller: TextEditingController(text: model.transparentReceiveAddress),
                      hintText: 'Generating transparent address...',
                      readOnly: true,
                      suffixWidget: model.isGeneratingTransparentAddress
                          ? const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: LoadingIndicator(),
                              ),
                            )
                          : CopyButton(
                              text: model.transparentReceiveAddress ?? '',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),

    'shielded_receive_card': HomepageWidgetInfo(
      id: 'shielded_receive_card',
      name: 'Receive Private',
      description: 'Shows shielded receive address',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconReceive,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          return SizedBox(
            height: 150,
            child: SailCard(
              title: 'Receive - Private Address',
              error: model.shieldedReceiveError,
              child: SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  Expanded(
                    child: SailTextField(
                      controller: TextEditingController(text: model.shieldedReceiveAddress),
                      hintText: 'Generating private address...',
                      readOnly: true,
                      suffixWidget: model.isGeneratingShieldedAddress
                          ? const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: LoadingIndicator(),
                              ),
                            )
                          : CopyButton(
                              text: model.shieldedReceiveAddress ?? '',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),

    'send_card': HomepageWidgetInfo(
      id: 'send_card',
      name: 'Send Card',
      description: 'Send ZSide',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconSend,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          return SizedBox(
            height: 300,
            child: SailCard(
              title: 'Send on Sidechain',
              error: model.sendError,
              child: SailColumn(
                spacing: SailStyleValues.padding16,
                children: [
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    children: [
                      SailText.secondary15('Pay to'),
                      if (model.addressType.isNotEmpty) ...[
                        SailText.secondary13(
                          '(${model.addressType})',
                          color: model.isShieldedAddress
                              ? SailTheme.of(context).colors.success
                              : SailTheme.of(context).colors.info,
                        ),
                      ],
                    ],
                  ),
                  SailTextField(
                    controller: model.bitcoinAddressController,
                    hintText: 'Enter a transparent or private address',
                  ),
                  NumericField(
                    label: 'Amount',
                    controller: model.bitcoinAmountController,
                    hintText: '0.00',
                  ),
                  SailButton(
                    label: model.isShieldedAddress ? 'Send Private' : 'Send Transparent',
                    onPressed: () async => model.executeSendOnSidechain(context),
                    loading: model.isSending,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),

    'transactions_table': HomepageWidgetInfo(
      id: 'transactions_table',
      name: 'Transaction History',
      description: 'Shows transaction history',
      size: WidgetSize.full,
      icon: SailSVGAsset.iconTransactions,
      builder: (_) => SizedBox(
        height: 400,
        child: const TransactionsTab(),
      ),
    ),
  };

  static Map<String, HomepageWidgetInfo> getCatalogMap() {
    return Map.from(_widgets);
  }
}
