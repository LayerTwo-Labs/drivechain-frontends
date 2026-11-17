import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/widgets/address_list.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _FakeAddressBook extends ChangeNotifier implements AddressBookProvider {
  @override
  final List<AddressBookEntry> entries = [
    AddressBookEntry(id: Int64(1), label: 'bravo', address: 'bcrt1qa', direction: Direction.DIRECTION_SEND),
    AddressBookEntry(id: Int64(2), label: 'charlie', address: 'bcrt1qc', direction: Direction.DIRECTION_SEND),
    AddressBookEntry(id: Int64(3), label: 'alpha', address: 'bcrt1qb', direction: Direction.DIRECTION_SEND),
  ];

  @override
  List<AddressBookEntry> get sendEntries => entries.where((e) => e.direction == Direction.DIRECTION_SEND).toList();

  @override
  List<AddressBookEntry> get receiveEntries =>
      entries.where((e) => e.direction == Direction.DIRECTION_RECEIVE).toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<AddressBookProvider>(_FakeAddressBook());
  });

  tearDown(() => GetIt.I.reset());

  List<String> shownLabels(WidgetTester tester) => tester
      .widgetList<SailTableCell>(find.byType(SailTableCell))
      .map((cell) => cell.value)
      .where((v) => ['alpha', 'bravo', 'charlie'].contains(v))
      .toList();

  testWidgets('sorts the entries by label at first', (tester) async {
    await tester.pumpSailPage(const AddressBookTable());
    await tester.pumpAndSettle();

    expect(shownLabels(tester), ['alpha', 'bravo', 'charlie']);
  });

  testWidgets('a tap on a header sorts the rows by that column', (tester) async {
    await tester.pumpSailPage(const AddressBookTable());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Address'));
    await tester.pumpAndSettle();
    expect(shownLabels(tester), ['bravo', 'alpha', 'charlie']);

    await tester.tap(find.text('Address'));
    await tester.pumpAndSettle();
    expect(shownLabels(tester), ['charlie', 'alpha', 'bravo']);
  });
}
