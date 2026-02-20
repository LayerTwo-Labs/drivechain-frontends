import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:coinshift/providers/swap_provider.dart';
import 'package:coinshift/widgets/swap/swap_card.dart';
import 'package:coinshift/widgets/swap/swap_list.dart';

@RoutePage()
class SwapsTabPage extends StatelessWidget {
  const SwapsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SwapsPageViewModel>.reactive(
      viewModelBuilder: () => SwapsPageViewModel(),
      builder: (context, model, child) {
        return QtPage(
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            children: [
              // Header with stats
              _SwapStats(model: model),

              // Main content
              Expanded(
                child: SailRow(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side: Create swap form
                    const SizedBox(
                      width: 400,
                      child: SwapCard(),
                    ),

                    // Right side: Swap list
                    const Expanded(
                      child: SwapList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SwapStats extends StatelessWidget {
  final SwapsPageViewModel model;

  const _SwapStats({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailCard(
      child: SailRow(
        spacing: SailStyleValues.padding32,
        children: [
          _StatItem(
            label: 'Total Swaps',
            value: model.totalSwaps.toString(),
            color: theme.colors.text,
          ),
          _StatItem(
            label: 'Active',
            value: model.activeSwaps.toString(),
            color: theme.colors.info,
          ),
          _StatItem(
            label: 'Ready to Claim',
            value: model.claimableSwaps.toString(),
            color: theme.colors.success,
          ),
          _StatItem(
            label: 'Completed',
            value: model.completedSwaps.toString(),
            color: theme.colors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding04,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary12(label),
        SailText.primary24(value, bold: true, color: color),
      ],
    );
  }
}

class SwapsPageViewModel extends BaseViewModel {
  SwapProvider get _swapProvider => GetIt.I.get<SwapProvider>();

  int get totalSwaps => _swapProvider.swaps.length;
  int get activeSwaps => _swapProvider.activeSwaps.length;
  int get claimableSwaps => _swapProvider.claimableSwaps.length;
  int get completedSwaps => _swapProvider.completedSwaps.length;

  SwapsPageViewModel() {
    _swapProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _swapProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
