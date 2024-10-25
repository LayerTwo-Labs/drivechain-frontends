import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class ChainOverviewCard extends StatelessWidget {
  final Chain chain;
  final double confirmedBalance;
  final double unconfirmedBalance;
  final bool highlighted;
  final bool currentChain;
  final bool inBottomNav;
  final VoidCallback? onPressed;

  const ChainOverviewCard({
    super.key,
    required this.chain,
    required this.confirmedBalance,
    required this.unconfirmedBalance,
    required this.highlighted,
    required this.currentChain,
    required this.inBottomNav,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailScaleButton(
      onPressed: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200),
        child: SailBorder(
          border: inBottomNav
              ? Border(
                  right: BorderSide(color: theme.colors.formFieldBorder, width: 0.5),
                )
              : null,
          borderRadius: inBottomNav ? BorderRadius.zero : null,
          padding: const EdgeInsets.symmetric(
            horizontal: SailStyleValues.padding04,
            vertical: SailStyleValues.padding04,
          ),
          backgroundColor: highlighted ? theme.colors.actionHeader : null,
          child: SailColumn(
            spacing: 0,
            children: [
              if (onPressed != null && !inBottomNav)
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
                      decoration: BoxDecoration(
                        color: chain.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SailText.primary12(chain.ticker, color: theme.colors.background),
                    ),
                    SailRow(
                      spacing: SailStyleValues.padding04,
                      children: [
                        SailText.primary12(chain.name),
                        if (onPressed != null) SailSVG.icon(SailSVGAsset.iconArrow, height: 8),
                      ],
                    ),
                  ],
                ),
              if (!inBottomNav) const SailSpacing(SailStyleValues.padding10),
              if (!currentChain) SailText.secondary12('Open ${chain.name}'),
              if (currentChain)
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    Tooltip(
                      message: 'Confirmed balance',
                      child: SailRow(
                        spacing: SailStyleValues.padding08,
                        children: [
                          SailSVG.icon(SailSVGAsset.iconSuccess),
                          SailText.secondary12(formatBitcoin(confirmedBalance, symbol: chain.ticker)),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: 'Unconfirmed balance',
                      child: SailRow(
                        spacing: SailStyleValues.padding08,
                        children: [
                          SailSVG.icon(SailSVGAsset.iconPending),
                          SailText.secondary12(formatBitcoin(unconfirmedBalance, symbol: chain.ticker)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
