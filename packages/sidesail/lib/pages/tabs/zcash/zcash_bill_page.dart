import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/components/dashboard_group.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/providers/cast_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/tabs/zcash_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class ZCashBillPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZCashBillPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZcashBillTabViewModel(),
      builder: ((context, viewModel, child) {
        return SailPage(
          widgetTitle: SailText.primary15('Cast Dates'),
          scrollable: true,
          body: Padding(
            padding: const EdgeInsets.only(bottom: SailStyleValues.padding30),
            child: SailColumn(
              spacing: SailStyleValues.padding30,
              children: [
                SailColumn(
                  spacing: SailStyleValues.padding30,
                  children: [
                    DashboardGroup(
                      title: 'Cast Dates',
                      children: [
                        SailColumn(
                          spacing: 0,
                          withDivider: true,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: viewModel.pendingBills.length,
                              itemBuilder: (context, index) => PendingCastView(
                                key: ValueKey<int>(viewModel.pendingBills[index].powerOf),
                                pending: viewModel.pendingBills[index],
                                chain: viewModel.chain,
                              ),
                            ),
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
}

class ZcashBillTabViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  CastProvider get _castProvider => GetIt.I.get<CastProvider>();
  SidechainContainer get _sideRPC => GetIt.I.get<SidechainContainer>();

  List<PendingCastBill> get pendingBills => _castProvider.futureCasts.toList().sublist(1);

  Sidechain get chain => _sideRPC.rpc.chain;

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
