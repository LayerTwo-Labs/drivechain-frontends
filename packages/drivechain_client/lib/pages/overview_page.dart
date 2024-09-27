import 'package:auto_route/auto_route.dart';
import 'package:drivechain_client/gen/bitcoind/v1/bitcoind.pbgrpc.dart';
import 'package:drivechain_client/providers/balance_provider.dart';
import 'package:drivechain_client/providers/blockchain_provider.dart';
import 'package:drivechain_client/widgets/error_container.dart';
import 'package:drivechain_client/widgets/qt_container.dart';
import 'package:drivechain_client/widgets/qt_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money2/money2.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const QtPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExperimentalBanner(),
          SizedBox(height: SailStyleValues.padding15),
          BalancesView(),
          SizedBox(height: SailStyleValues.padding15),
          TransactionsView(),
        ],
      ),
    );
  }
}

class ExperimentalBanner extends StatelessWidget {
  const ExperimentalBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: SailTheme.of(context).colors.orangeLight.withOpacity(0.8),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(4.0),
      child: SailText.primary12(
        'This is experimental sidechain software. Use at your own risk!',
        bold: true,
      ),
    );
  }
}

class BalancesView extends StatelessWidget {
  const BalancesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => BalancesViewModel(),
      builder: (context, model, child) {
        if (model.hasErrorForKey('balance')) {
          return ErrorContainer(
            error: model.error('balance').toString(),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SailText.primary13(
                      'Balances',
                      bold: true,
                    ),
                    const SizedBox(height: SailStyleValues.padding15),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SailText.primary13('Available: '),
                          SailText.primary13(
                            formatBitcoin(
                              satoshiToBTC(model.confirmedBalance),
                            ),
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SailStyleValues.padding15),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SailText.primary13('Pending: '),
                          SailText.primary13(
                            formatBitcoin(
                              satoshiToBTC(model.pendingBalance),
                            ),
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    const QtSeparator(width: 150),
                    const SizedBox(height: 24.0),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SailText.primary13('Total: '),
                          SailText.primary13(
                            formatBitcoin(
                              satoshiToBTC(
                                model.totalBalance,
                              ),
                            ),
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BitcoinPrice(
                      money: Money.fromNumWithCurrency(
                        50000,
                        CommonCurrencies().usd,
                      ),
                    ),
                    const SizedBox(height: SailStyleValues.padding15),
                    // Sum of all balances converted to USD at current BTC price
                    SailText.primary13(
                      Money.fromNumWithCurrency(
                        model.totalBalanceUSD,
                        CommonCurrencies().usd,
                      ).format('S###,###.##'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BalancesViewModel>.reactive(
      viewModelBuilder: () => BalancesViewModel(),
      builder: (context, model, child) {
        if (model.hasErrorForKey('blockchain')) {
          return ErrorContainer(
            error: model.error('blockchain').toString(),
          );
        }
        return Expanded(
          child: QtContainer(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary13('Latest transactions:'),
                      const SailSpacing(SailStyleValues.padding08),
                      LatestTransactionTable(
                        entries: model.unconfirmedTransactions,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: SailStyleValues.padding15), // Add some space between the two tables
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary13('Latest blocks:'),
                      const SailSpacing(SailStyleValues.padding08),
                      LatestBlocksTable(
                        blocks: model.recentBlocks,
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

class BalancesViewModel extends BaseViewModel {
  final BlockchainProvider blockchainProvider = GetIt.I.get<BlockchainProvider>();
  final BalanceProvider balanceProvider = GetIt.I.get<BalanceProvider>();

  BalancesViewModel() {
    balanceProvider.addListener(notifyListeners);
    blockchainProvider.addListener(notifyListeners);

    setErrorForObject('balance', 'test');
  }

  void errorListener() {
    if (balanceProvider.error != null) {
      setErrorForObject('balance', balanceProvider.error);
    }
    if (blockchainProvider.error != null) {
      setErrorForObject('blockchain', blockchainProvider.error);
    }

    // test
    setErrorForObject('balance', 'test');
  }

  int get confirmedBalance => balanceProvider.balance;
  int get pendingBalance => balanceProvider.pendingBalance;
  int get totalBalance => balanceProvider.balance + balanceProvider.pendingBalance;
  double get totalBalanceUSD => (satoshiToBTC(totalBalance) * 50000);

  List<ListRecentBlocksResponse_RecentBlock> get recentBlocks => blockchainProvider.recentBlocks;
  List<UnconfirmedTransaction> get unconfirmedTransactions => blockchainProvider.unconfirmedTXs;
}

class QtSeparator extends StatelessWidget {
  final double width;

  const QtSeparator({
    super.key,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
      ),
      child: Container(
        height: 1.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.35, 0.36, 1.0],
            colors: [
              Colors.grey,
              Colors.grey.withOpacity(0.3),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
      ),
    );
  }
}

class BitcoinPrice extends StatelessWidget {
  final Money money;

  const BitcoinPrice({super.key, required this.money});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SailText.primary13(
          '${money.format('S###,###.##')}/BTC',
        ),
        const SizedBox(width: 8.0),
        SailScaleButton(
          onPressed: () {
            showSnackBar(context, 'Not implemented');
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: SailStyleValues.padding15, vertical: 4.0),
            child: Icon(Icons.settings),
          ),
        ),
      ],
    );
  }
}

class LatestTransactionTable extends StatelessWidget {
  final List<UnconfirmedTransaction> entries;

  const LatestTransactionTable({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return QtContainer(
      tight: true,
      child: SizedBox(
        height: 300, // Set the maximum height to 300 pixels
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical, // Enable vertical scrolling
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Enable horizontal scrolling
            child: DataTable(
              decoration: BoxDecoration(
                color: context.sailTheme.colors.backgroundSecondary,
                border: Border.all(
                  color: context.sailTheme.colors.formFieldBorder,
                  width: 1.0,
                ),
              ),
              border: TableBorder.symmetric(
                inside: BorderSide(
                  color: context.sailTheme.colors.formFieldBorder,
                  width: 1.0,
                ),
              ),
              headingRowColor: WidgetStateProperty.all(
                context.sailTheme.colors.formFieldBorder,
              ),
              columnSpacing: SailStyleValues.padding15,
              headingRowHeight: 24.0,
              dataTextStyle: SailStyleValues.twelve,
              headingTextStyle: SailStyleValues.ten,
              dividerThickness: 0,
              dataRowMaxHeight: 48.0,
              columns: [
                DataColumn(
                  label: SailText.primary12('Time'),
                  headingRowAlignment: MainAxisAlignment.spaceBetween,
                ),
                DataColumn(
                  label: SailText.primary12('sat/vB'),
                  headingRowAlignment: MainAxisAlignment.spaceBetween,
                ),
                DataColumn(
                  label: SailText.primary12('TxID'),
                  headingRowAlignment: MainAxisAlignment.spaceBetween,
                ),
                DataColumn(
                  label: SailText.primary12('Size'),
                  headingRowAlignment: MainAxisAlignment.spaceBetween,
                ),
              ],
              rows: entries
                  .map(
                    (entry) => DataRow(
                      color: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return context.sailTheme.colors.primary.withOpacity(0.5);
                        }
                        return Colors.transparent;
                      }),
                      cells: [
                        DataCell(SailText.primary12(entry.time.toDateTime().format())),
                        DataCell(SailText.primary12(entry.feeSatoshi.toString())),
                        DataCell(SailText.primary12(entry.txid)),
                        DataCell(SailText.primary12(entry.virtualSize.toString())),
                      ],
                    ),
                  )
                  .toList(),
              sortColumnIndex: [
                'time',
                'fee',
                'txid',
                'size',
              ].indexOf('time'),
              sortAscending: false,
            ),
          ),
        ),
      ),
    );
  }
}

class LatestBlocksTable extends StatelessWidget {
  final List<ListRecentBlocksResponse_RecentBlock> blocks;

  const LatestBlocksTable({
    super.key,
    required this.blocks,
  });

  @override
  Widget build(BuildContext context) {
    return QtContainer(
      tight: true,
      child: SizedBox(
        height: 300, // Set the maximum height to 300 pixels
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical, // Enable vertical scrolling
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Enable horizontal scrolling
            child: DataTable(
              decoration: BoxDecoration(
                color: context.sailTheme.colors.backgroundSecondary,
                border: Border.all(
                  color: context.sailTheme.colors.formFieldBorder,
                  width: 1.0,
                ),
              ),
              border: TableBorder.symmetric(
                inside: BorderSide(
                  color: context.sailTheme.colors.formFieldBorder,
                  width: 1.0,
                ),
              ),
              headingRowColor: WidgetStateProperty.all(
                context.sailTheme.colors.formFieldBorder,
              ),
              // Set the sort arrow color using the theme's primary color
              columnSpacing: SailStyleValues.padding15,
              headingRowHeight: 24.0,
              dataTextStyle: SailStyleValues.twelve,
              headingTextStyle: SailStyleValues.ten,
              dividerThickness: 0,
              dataRowMaxHeight: 48.0,
              columns: [
                DataColumn(
                  label: SailText.primary12('Time'),
                  headingRowAlignment: MainAxisAlignment.spaceBetween,
                ),
                DataColumn(
                  label: SailText.primary12('Height'),
                  headingRowAlignment: MainAxisAlignment.spaceBetween,
                ),
                DataColumn(
                  label: SailText.primary12('Hash'),
                  headingRowAlignment: MainAxisAlignment.spaceBetween,
                ),
              ],
              rows: blocks
                  .map(
                    (entry) => DataRow(
                      color: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return context.sailTheme.colors.primary.withOpacity(0.5);
                        }
                        return Colors.transparent;
                      }),
                      cells: [
                        DataCell(SailText.primary12(entry.blockTime.toDateTime().format())),
                        DataCell(SailText.primary12(entry.blockHeight.toString())),
                        DataCell(SailText.primary12(entry.hash)),
                      ],
                    ),
                  )
                  .toList(),
              sortColumnIndex: ['time', 'height', 'hash'].indexOf('time'),
              sortAscending: false,
            ),
          ),
        ),
      ),
    );
  }
}
