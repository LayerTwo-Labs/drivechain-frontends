import 'dart:io';

import 'package:bitwindow/main.dart';
import 'package:bitwindow/pages/message_signer.dart';
import 'package:bitwindow/widgets/address_list.dart';
import 'package:bitwindow/widgets/converter_window.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  final logFile = File('bitwindow.log');

  test('each window type maps to its page', () {
    expect(inAppWindowPage(SubWindowTypes.addressbookId, const {}, logFile), isA<AddressBookTable>());
    expect(inAppWindowPage(SubWindowTypes.messageSignerId, const {}, logFile), isA<MessageSigner>());
    expect(inAppWindowPage(SubWindowTypes.converterId, const {}, logFile), isA<ConverterWindow>());
  });

  test('an unknown window type maps to an error card', () {
    expect(inAppWindowPage('nope', const {}, logFile), isA<SailCard>());
  });
}
