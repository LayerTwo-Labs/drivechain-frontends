import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:zside/providers/cast_provider.dart';

/// Formats a bill amount in sats, or in BTC with spaced decimals from 1 BTC up.
String billAmountLabel(int sats) {
  if (sats < 100000000) {
    return _groupDigits(sats.toString());
  }
  final fraction = (sats % 100000000).toString().padLeft(8, '0');
  return '${_groupDigits((sats ~/ 100000000).toString())}.${fraction.substring(0, 2)} ${_groupDigits(fraction.substring(2))}';
}

String _groupDigits(String digits) {
  final groups = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    groups.insert(0, digits.substring(end < 3 ? 0 : end - 3, end));
  }
  return groups.join(' ');
}

@RoutePage()
class ZSideBillPage extends StatelessWidget {
  const ZSideBillPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZSideBillTabViewModel(),
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
                            for (var row = 0; row < 6; row++)
                              _buildTableRow([for (var day = 0; day < 7; day++) billAmountLabel(1 << (row * 7 + day))]),
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
                child: SailText.primary12(cell, textAlign: TextAlign.right, monospace: true),
              ),
            ),
          )
          .toList(),
    );
  }
}

class ZSideBillTabViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  CastProvider get _castProvider => GetIt.I.get<CastProvider>();
  ZSideRPC get _rpc => GetIt.I.get<ZSideRPC>();

  List<PendingCastBill> get pendingBills => _castProvider.futureCasts.toList().sublist(1);

  Binary get chain => _rpc.chain;

  bool hideDust = true;

  void setShowAll(bool to) {
    hideDust = to;
    notifyListeners();
  }

  ZSideBillTabViewModel() {
    _castProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _castProvider.removeListener(notifyListeners);
  }
}
