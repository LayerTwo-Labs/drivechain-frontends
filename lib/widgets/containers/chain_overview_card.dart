import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/config/sidechains.dart';

class ChainOverviewCard extends StatelessWidget {
  final Sidechain chain;
  final double confirmedBalance;
  final double unconfirmedBalance;
  final bool highlighted;
  final bool currentChain;
  final VoidCallback? onPressed;

  const ChainOverviewCard({
    super.key,
    required this.chain,
    required this.confirmedBalance,
    required this.unconfirmedBalance,
    required this.highlighted,
    required this.currentChain,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailScaleButton(
      onPressed: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200),
        child: SizedBox(
          height: 87,
          child: SailBorder(
            padding: const EdgeInsets.symmetric(
              horizontal: SailStyleValues.padding12,
              vertical: SailStyleValues.padding08,
            ),
            backgroundColor: highlighted ? theme.colors.actionHeader : null,
            child: SailColumn(
              spacing: 0,
              children: [
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
                      decoration: BoxDecoration(
                        color: chain.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SailText.primary12(chain.ticker),
                    ),
                    SailRow(
                      spacing: SailStyleValues.padding05,
                      children: [
                        SailText.primary12(chain.name),
                        if (onPressed != null) SailSVG.icon(SailSVGAsset.iconArrow, width: 5.5),
                      ],
                    ),
                  ],
                ),
                if (!currentChain) SailText.secondary12('Open ${chain.name}'),
                if (currentChain)
                  Column(
                    children: [
                      const SailSpacing(SailStyleValues.padding08),
                      SailRow(
                        spacing: SailStyleValues.padding08,
                        children: [
                          SailSVG.icon(SailSVGAsset.iconSuccess),
                          SailText.secondary12('${confirmedBalance.toStringAsFixed(8)} ${chain.ticker}'),
                        ],
                      ),
                      const SailSpacing(SailStyleValues.padding08),
                      SailRow(
                        spacing: SailStyleValues.padding08,
                        children: [
                          SailSVG.icon(SailSVGAsset.iconPending),
                          SailText.secondary12('${confirmedBalance.toStringAsFixed(8)} ${chain.ticker}'),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
