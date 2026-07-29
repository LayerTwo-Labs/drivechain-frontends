import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// Font size slider with one snap point per [sailFontScales] entry. Runs on
/// the index rather than the scale itself so the unevenly spaced scales still
/// land on evenly spaced snap points.
class FontSizeSlider extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const FontSizeSlider({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    final index = sailFontScales.indexOf(nearestSailFontScale(settingsProvider.fontScale));

    return SailRow(
      spacing: SailStyleValues.padding16,
      children: [
        SizedBox(
          width: 220,
          child: SailSlider(
            value: index.toDouble(),
            min: 0,
            max: (sailFontScales.length - 1).toDouble(),
            divisions: sailFontScales.length - 1,
            onChanged: (double newIndex) async {
              final scale = sailFontScales[newIndex.round()];
              if (scale == settingsProvider.fontScale) return;

              await settingsProvider.updateFontScale(scale);
              if (context.mounted) {
                await SailApp.of(context).loadFontScale(scale);
              }
            },
          ),
        ),
        SailText.primary13('${(sailFontScales[index] * 100).round()}%'),
      ],
    );
  }
}
