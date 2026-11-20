import 'package:bitwindow/widgets/homepage_widget_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only the widgets with a card subtitle carry one in the library', () {
    final subtitles = {
      for (final info in HomepageWidgetCatalog.getCatalogMap().values)
        if (info.subtitle != null) info.id: info.subtitle,
    };

    expect(subtitles, {
      'graffiti_explorer': 'Browse blockchain graffiti and OP_RETURN data',
      'network_traffic': 'Bandwidth over time',
      'network_stats': 'Connection summary',
      'fast_withdrawal': 'Quickly withdraw L2 coins to your L1-wallet',
    });
  });
}
