import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/widgets/address_list.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _AddressBook extends ChangeNotifier implements AddressBookProvider {
  @override
  List<AddressBookEntry> get sendEntries => [
    AddressBookEntry(
      id: Int64(1),
      label: 'bb privat',
      address: 'bc1qjyeu20wv7yrwj6q96h5k7ewcc5v474n7yqv023',
      direction: Direction.DIRECTION_SEND,
    ),
    AddressBookEntry(
      id: Int64(2),
      label: 'bb jalborgs',
      address: 'bc1qcq7hfsfal7alfyfhe04jcy3avyt2j8e988zdh0',
      direction: Direction.DIRECTION_SEND,
    ),
  ];

  @override
  List<AddressBookEntry> get receiveEntries => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<AddressBookProvider>(_AddressBook());
  });

  tearDown(() {
    SailStyleValues.phoneLayoutOverride = null;
    return GetIt.I.reset();
  });

  testWidgets('on a phone the buttons sit below the title and each address is a two-line row', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await loadBundledFonts();
    await tester.pumpSailPage(const AddressBookTable());
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SailTable), findsNothing);

    final title = tester.getRect(find.text('Sending Addresses'));
    final add = tester.getRect(find.text('Add Address'));
    final export = tester.getRect(find.text('Export'));
    expect(add.top, greaterThan(title.bottom));
    expect(export.center.dy, closeTo(add.center.dy, 1));

    final label = tester.getRect(find.text('bb privat'));
    final address = tester.getRect(find.text('bc1qjyeu20wv7yrwj6q96h5k7ewcc5v474n7yqv023'));
    expect(label.top, greaterThan(add.bottom));
    expect(address.top, greaterThanOrEqualTo(label.bottom));
    expect(address.left, closeTo(label.left, 1));
    expect(address.height, lessThan(20));
    expect(tester.widget<SailButton>(find.widgetWithText(SailButton, 'Add Address')).small, isFalse);

    final edit = find.byWidgetPredicate((w) => w is SailButton && w.icon == SailSVGAsset.iconPen).first;
    final delete = find.byWidgetPredicate((w) => w is SailButton && w.icon == SailSVGAsset.iconDelete).first;
    expect(tester.getRect(edit).left, greaterThan(address.right));
    expect(tester.getRect(delete).left, greaterThan(tester.getRect(edit).left));
  });

  testWidgets('on desktop the buttons stay in the header and the entries stay a table', (tester) async {
    await tester.pumpSailPage(const AddressBookTable());
    await tester.pumpAndSettle();

    expect(find.byType(SailTable), findsOneWidget);
    final title = tester.getRect(find.text('Sending Addresses'));
    final add = tester.getRect(find.text('Add Address'));
    expect(add.top, lessThan(title.bottom));
  });
}
