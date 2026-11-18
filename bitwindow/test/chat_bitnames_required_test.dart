import 'package:bitwindow/pages/chat_page.dart';
import 'package:bitwindow/providers/chat_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/mocks/mocks.dart';

import 'mocks/store_mock.dart';
import 'test_utils.dart';

void main() {
  tearDown(() => GetIt.I.reset());

  testWidgets('the BitNames required card is a centered 520 px card', (tester) async {
    final log = Logger();
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: MockStore(), log: log));
    final rpc = MockBitnamesRPC();
    GetIt.I.registerSingleton<BitnamesRPC>(rpc);
    GetIt.I.registerSingleton<BalanceProvider>(BalanceProvider(connections: [rpc]));
    GetIt.I.registerSingleton<ChatProvider>(ChatProvider());

    await tester.pumpSailPage(const ChatPage());

    final card = find.ancestor(of: find.text('BitNames sidechain is not connected'), matching: find.byType(SailCard));
    final pageCenter = tester.getCenter(find.byType(ChatPage)).dx;
    expect(tester.getSize(card).width, 520);
    expect(tester.getCenter(card).dx, moreOrLessEquals(pageCenter, epsilon: 1));
    expect(
      tester.getCenter(find.text('BitNames sidechain is not connected')).dx,
      moreOrLessEquals(pageCenter, epsilon: 1),
    );
  });
}
