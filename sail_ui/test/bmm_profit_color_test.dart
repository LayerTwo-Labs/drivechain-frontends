import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/pages/sidechains/bmm_tab.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/bmm/v1/bmm.pb.dart' as bmmpb;

void main() {
  final colors = SailThemeData.darkTheme(const Color(0xFF000000), false, SailFontValues.inter).colors;

  // The engine gives up on a won block the chain left behind. The miner keeps
  // the bid, so the row reports a loss and must not read as a win.
  test('an abandoned round paints its loss', () {
    final round = bmmpb.Round(result: 'won', hasProfit: true, profitSats: Int64(-1200));

    expect(profitColor(round, colors), colors.error);
  });

  test('a connected round paints its profit', () {
    final round = bmmpb.Round(result: 'won', hasProfit: true, profitSats: Int64(3800));

    expect(profitColor(round, colors), colors.success);
  });

  test('a round with no profit takes the default colour', () {
    expect(profitColor(bmmpb.Round(result: 'lost'), colors), isNull);
  });
}
