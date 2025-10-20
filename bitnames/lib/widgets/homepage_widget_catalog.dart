import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/pages/sidechains/sidechain_overview_page.dart';
import 'package:stacked/stacked.dart';

class BitnamesWidgetCatalog {
  static final Map<String, HomepageWidgetInfo> _widgets = {
    'balance_card': HomepageWidgetInfo(
      id: 'balance_card',
      name: 'Balance Card',
      description: 'Shows Bitnames balance',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconWallet,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          final formatter = GetIt.I<FormatterProvider>();

          return ListenableBuilder(
            listenable: formatter,
            builder: (context, child) => SizedBox(
              height: 200,
              child: SailCard(
                title: 'Balance',
                child: SailColumn(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailSkeletonizer(
                      enabled: !model.balanceInitialized,
                      description: 'Waiting for bitnames to boot...',
                      child: SailText.primary24(
                        '${formatter.formatBTC(model.totalBalance)} ${model.ticker}',
                        bold: true,
                      ),
                    ),
                    const SizedBox(height: 4),
                    BalanceRow(
                      label: 'Available',
                      amount: model.balance,
                      ticker: model.ticker,
                      loading: !model.balanceInitialized,
                    ),
                    BalanceRow(
                      label: 'Pending',
                      amount: model.pendingBalance,
                      ticker: model.ticker,
                      loading: !model.balanceInitialized,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),

    'receive_card': HomepageWidgetInfo(
      id: 'receive_card',
      name: 'Receive Card',
      description: 'Shows receive address',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconReceive,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          return SizedBox(
            height: 150,
            child: SailCard(
              title: 'Receive on Sidechain',
              error: model.receiveError,
              child: SailColumn(
                spacing: SailStyleValues.padding04,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailColumn(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailTextField(
                        loading: LoadingDetails(
                          enabled: model.receiveAddress == null,
                          description: 'Waiting for bitnames to boot...',
                        ),
                        controller: TextEditingController(text: model.receiveAddress),
                        hintText: 'Generating deposit address...',
                        readOnly: true,
                        suffixWidget: CopyButton(text: model.receiveAddress ?? ''),
                      ),
                    ],
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
      description: 'Send Bitnames',
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
                  SailText.secondary15('Pay to'),
                  SailTextField(
                    controller: model.bitcoinAddressController,
                    hintText: 'Enter a bitcoin address',
                  ),
                  NumericField(
                    label: 'Amount',
                    controller: model.bitcoinAmountController,
                    hintText: '0.00',
                  ),
                  SailButton(
                    label: 'Send',
                    onPressed: () async => await model.executeSendOnSidechain(context),
                    loading: model.isSending,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),

    'bitnames_table': HomepageWidgetInfo(
      id: 'bitnames_table',
      name: 'Transaction History',
      description: 'Shows transaction history',
      size: WidgetSize.full,
      icon: SailSVGAsset.iconTransactions,
      builder: (_) => SizedBox(
        height: 400,
        child: ViewModelBuilder<LatestWalletTransactionsViewModel>.reactive(
          viewModelBuilder: () => LatestWalletTransactionsViewModel(),
          builder: (context, model, child) {
            return TransactionTable(
              model: model,
              searchWidget: SailTextField(
                controller: model.searchController,
                hintText: 'Search with txid, address or amount',
              ),
            );
          },
        ),
      ),
    ),
  };

  static Map<String, HomepageWidgetInfo> getCatalogMap() {
    return Map.from(_widgets);
  }
}
