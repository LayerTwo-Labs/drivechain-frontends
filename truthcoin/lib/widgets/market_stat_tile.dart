import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// One number with a label above it and a caption below it.
class MarketStatTile extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final Color? valueColor;

  const MarketStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return SailCard(
      child: SailColumn(
        spacing: SailStyleValues.padding04,
        children: [
          SailText.secondary13(label),
          SailText.primary24(value, bold: true, color: valueColor),
          SailText.secondary12(caption),
        ],
      ),
    );
  }
}

/// A row of stat tiles that folds into more rows on a narrow window.
class MarketStatTileRow extends StatelessWidget {
  final List<MarketStatTile> tiles;

  const MarketStatTileRow({super.key, required this.tiles});

  static const double _minTileWidth = 220;

  @override
  Widget build(BuildContext context) {
    const gap = SailStyleValues.padding16;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fit = ((constraints.maxWidth + gap) / (_minTileWidth + gap)).floor();
        final columns = fit.clamp(1, tiles.length);
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final tile in tiles) SizedBox(width: width, child: tile)],
        );
      },
    );
  }
}
