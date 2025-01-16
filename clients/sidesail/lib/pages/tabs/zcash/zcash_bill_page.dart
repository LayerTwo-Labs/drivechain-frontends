import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/providers/cast_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class ZCashBillPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZCashBillPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZcashBillTabViewModel(),
      builder: ((context, model, child) {
        return SailPage(
          widgetTitle: SailText.primary15('Bill Amounts'),
          scrollable: true,
          body: Padding(
            padding: const EdgeInsets.only(bottom: SailStyleValues.padding32),
            child: SailColumn(
              spacing: SailStyleValues.padding32,
              children: [
                SailColumn(
                  spacing: SailStyleValues.padding32,
                  children: [
                    DashboardGroup(
                      title: 'Bill Amounts (in sats)',
                      children: [
                        Table(
                          border: TableBorder.all(color: theme.colors.text, width: 1),
                          children: [
                            TableRow(
                              children: [
                                TableCell(child: Center(child: SailText.primary13('Sunday'))),
                                TableCell(child: Center(child: SailText.primary13('Monday'))),
                                TableCell(child: Center(child: SailText.primary13('Tuesday'))),
                                TableCell(child: Center(child: SailText.primary13('Wednesday'))),
                                TableCell(child: Center(child: SailText.primary13('Thursday'))),
                                TableCell(child: Center(child: SailText.primary13('Friday'))),
                                TableCell(child: Center(child: SailText.primary13('Saturday'))),
                              ],
                            ),
                            _buildTableRow([
                              '1',
                              '2',
                              '4',
                              '8',
                              '16',
                              '32',
                              '64',
                            ]),
                            _buildTableRow([
                              '128',
                              '256',
                              '512',
                              '1 024',
                              '2 048',
                              '4 096',
                              '8 192',
                            ]),
                            _buildTableRow([
                              '16 384',
                              '32 768',
                              '65 536',
                              '31 072',
                              '262 144',
                              '524 288',
                              '1 048 576',
                            ]),
                            _buildTableRow([
                              '2 097 152',
                              '4 194 304',
                              '8 388 608',
                              '16 777 216',
                              '33 554 432',
                              '67 108 864',
                              '1.34 217 728',
                            ]),
                            _buildTableRow([
                              '2.68 435 456',
                              '5.36 870 912',
                              '10.73 718 240',
                              '21.47 436 480',
                              '42.94 972 960',
                              '85.89 945 920',
                              '171.79 891 840',
                            ]),
                            _buildTableRow([
                              '343.58 983 680',
                              '687.17 967 360',
                              '1 374.35 934 720',
                              '2 748.71 869 440',
                              '5 497.43 738 880',
                              '10 994.87 477 760',
                              '21 989.74 955 520',
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  TableRow _buildTableRow(List<String> cells) {
    return TableRow(
      children: cells
          .map(
            (cell) => TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SailText.primary12(cell, textAlign: TextAlign.right),
              ),
            ),
          )
          .toList(),
    );
  }
}

class ZcashBillTabViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  CastProvider get _castProvider => GetIt.I.get<CastProvider>();
  SidechainContainer get _sideRPC => GetIt.I.get<SidechainContainer>();

  List<PendingCastBill> get pendingBills => _castProvider.futureCasts.toList().sublist(1);

  Binary get chain => _sideRPC.rpc.chain;

  bool hideDust = true;

  void setShowAll(bool to) {
    hideDust = to;
    notifyListeners();
  }

  ZcashBillTabViewModel() {
    _castProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _castProvider.removeListener(notifyListeners);
  }
}
