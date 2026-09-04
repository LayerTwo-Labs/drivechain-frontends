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
    expect(profitColor(-1200, colors), colors.error);
  });

  test('a connected round paints its profit', () {
    expect(profitColor(3800, colors), colors.success);
  });

  test('a round with no profit takes the default colour', () {
    expect(profitColor(null, colors), isNull);
  });

  test('a profit carries its sign, and a missing one carries a dash', () {
    expect(profitLabel(2900), '+2\u2009900');
    expect(profitLabel(-1200), '-1\u2009200');
    expect(profitLabel(null), '—');
  });

  test('digits group in threes', () {
    expect(groupDigits(24800), '24\u2009800');
    expect(groupDigits(900), '900');
    expect(groupDigits(1234567), '1\u2009234\u2009567');
  });

  test('a sidechain block reads in the h* form', () {
    expect(shortenCriticalHash('4e9f2c8b1122334455'), 'h*4e9f2c8b..');
    expect(shortenCriticalHash(''), '—');
  });

  // An empty table still has to hold its header and its placeholder.
  test('a table frame fits its header and its rows', () {
    expect(tableFrameHeight(0), 100);
    expect(tableFrameHeight(3), 162);
  });

  group('historic bids', () {
    bmmpb.Round round({
      required String hash,
      required String result,
      int bidSats = 0,
      int blockWorth = 0,
      int? profit,
      String txid = '',
      String includedIn = '',
    }) {
      final value = bmmpb.Round(
        prevMainHash: hash,
        result: result,
        blockWorthSats: Int64(blockWorth),
        includedInBlock: includedIn,
        ourBids: [bmmpb.Bid(txid: txid, bidSats: Int64(bidSats), isOurs: true)],
      );
      if (profit != null) {
        value.profitSats = Int64(profit);
        value.hasProfit = true;
      }
      return value;
    }

    test('the live round leads the finished ones', () {
      final rows = historicBids(
        round(hash: 'a', result: 'open', bidSats: 22000, blockWorth: 24800, txid: 'tx-a'),
        [
          round(
            hash: 'b',
            result: 'won',
            bidSats: 11000,
            blockWorth: 13900,
            profit: 2900,
            txid: 'tx-b',
            includedIn: 'blk',
          ),
        ],
      );

      expect(rows.map((r) => r.state), [bidStateWaiting, bidStateConnected]);
      expect(rows.first.mainchainBlock, '');
      expect(rows.last.mainchainBlock, 'blk');
      expect(rows.last.profitSats, 2900);
    });

    test('a round we never bid on gets no row', () {
      final empty = bmmpb.Round(prevMainHash: 'c', result: 'lost');

      expect(historicBids(null, [empty]), isEmpty);
    });

    // A lost bid never rode in a block, so the winner's block is not ours to
    // name.
    test('a lost round names no mainchain block', () {
      final rows = historicBids(null, [round(hash: 'd', result: 'lost', txid: 'tx-d', includedIn: 'blk')]);

      expect(rows.single.state, bidStateNotIncluded);
      expect(rows.single.mainchainBlock, '');
    });

    test('the live round appears once, even when history repeats it', () {
      final live = round(hash: 'e', result: 'open', txid: 'tx-e');
      final rows = historicBids(live, [round(hash: 'e', result: 'open', txid: 'tx-e')]);

      expect(rows, hasLength(1));
    });
  });
}
