import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder<ToolsPageViewModel>.reactive(
        viewModelBuilder: () => ToolsPageViewModel(),
        onViewModelReady: (model) => model.init(),
        builder: (context, model, child) {
          return InlineTabBar(
            tabs: [
              TabItem(
                label: 'Fast Withdrawal',
                icon: SailSVGAsset.iconWithdraw,
                child: WithdrawalTab(),
              ),
              TabItem(
                label: 'Faucet',
                icon: SailSVGAsset.iconCoins,
                child: FaucetTab(),
              ),
            ],
            initialIndex: 0,
          );
        },
      ),
    );
  }
}

class WithdrawalTab extends ViewModelWidget<ToolsPageViewModel> {
  const WithdrawalTab({super.key});

  @override
  Widget build(BuildContext context, ToolsPageViewModel viewModel) {
    return SailRawCard(
      title: 'Fast Withdrawal',
      subtitle: 'Quickly withdraw your funds',
      child: Container(),
    );
  }
}

class FaucetTab extends ViewModelWidget<ToolsPageViewModel> {
  const FaucetTab({super.key});

  @override
  Widget build(BuildContext context, ToolsPageViewModel viewModel) {
    return SailRawCard(
      title: 'Faucet',
      subtitle: 'Get test coins from the faucet',
      child: Container(),
    );
  }
}

class ToolsPageViewModel extends BaseViewModel {
  void init() {
    // Initialize any required data
  }
}
