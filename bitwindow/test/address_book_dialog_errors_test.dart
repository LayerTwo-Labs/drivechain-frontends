import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/widgets/address_list.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _RejectingAddressBook extends ChangeNotifier implements AddressBookProvider {
  @override
  List<AddressBookEntry> get sendEntries => [
    AddressBookEntry(id: Int64(1), label: 'alpha', address: 'bcrt1qa', direction: Direction.DIRECTION_SEND),
  ];

  @override
  List<AddressBookEntry> get receiveEntries => [];

  @override
  Future<void> createEntry(String label, String address, Direction direction) async {
    throw Exception('invalid address "$address"');
  }

  @override
  Future<void> updateLabel(Int64 id, String newLabel) async {
    throw Exception('label "$newLabel" already exists');
  }

  @override
  Future<void> deleteEntry(Int64 id) async {
    throw Exception('entry $id is locked');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<AddressBookProvider>(_RejectingAddressBook());
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('the create dialog shows the error from the server', (tester) async {
    await tester.pumpSailPage(const AddressBookTable());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Address').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).at(0), 'not-an-address');
    await tester.enterText(find.byType(EditableText).at(1), 'bad');
    await tester.pump();
    await tester.tap(find.text('Create').hitTestable().first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(of: find.byType(SailModal), matching: find.textContaining('invalid address')),
      findsOneWidget,
    );
  });

  testWidgets('the edit dialog shows the error from the server', (tester) async {
    await tester.pumpSailPage(const AddressBookTable());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SailButton).hitTestable().at(3));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, 'bravo');
    await tester.pump();
    await tester.tap(find.text('Update').hitTestable().first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(of: find.byType(SailModal), matching: find.textContaining('already exists')),
      findsOneWidget,
    );
  });

  Future<void> closeDialog(WidgetTester tester) async {
    Navigator.of(tester.element(find.byType(SailModal))).pop();
    await tester.pumpAndSettle();
  }

  testWidgets('a create error is gone after the dialog closes', (tester) async {
    await tester.pumpSailPage(const AddressBookTable());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Address').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).at(0), 'not-an-address');
    await tester.enterText(find.byType(EditableText).at(1), 'bad');
    await tester.pump();
    await tester.tap(find.text('Create').hitTestable().first);
    await tester.pumpAndSettle();
    await closeDialog(tester);

    expect(find.textContaining('invalid address'), findsNothing);

    await tester.tap(find.text('Add Address').hitTestable().first);
    await tester.pumpAndSettle();

    expect(find.textContaining('invalid address'), findsNothing);
  });

  testWidgets('an edit error is gone after the dialog closes', (tester) async {
    await tester.pumpSailPage(const AddressBookTable());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SailButton).hitTestable().at(3));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, 'bravo');
    await tester.pump();
    await tester.tap(find.text('Update').hitTestable().first);
    await tester.pumpAndSettle();
    await closeDialog(tester);

    expect(find.textContaining('already exists'), findsNothing);

    await tester.tap(find.byType(SailButton).hitTestable().at(3));
    await tester.pumpAndSettle();

    expect(find.textContaining('already exists'), findsNothing);
  });

  testWidgets('a delete error is gone after the dialog closes', (tester) async {
    await tester.pumpSailPage(const AddressBookTable());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SailButton).hitTestable().at(4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.textContaining('is locked'), findsWidgets);

    await tester.tap(find.text('Cancel').hitTestable().first);
    await tester.pumpAndSettle();

    expect(find.textContaining('is locked'), findsNothing);
  });
}
