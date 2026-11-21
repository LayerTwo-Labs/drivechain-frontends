import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/providers/window_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final addressBook = SailWindow(name: 'Address Book', identifier: 'addressbook');

  Future<WindowProvider> provider() async {
    final dir = await Directory.systemTemp.createTemp('window_provider');
    addTearDown(() => dir.delete(recursive: true));
    final p = await WindowProvider.newInstance(File('${dir.path}/app.log'), dir);
    p.desktopWindows = false;
    return p;
  }

  test('without desktop windows, open shows the window in the app', () async {
    final p = await provider();
    final opened = <(String, Map<String, dynamic>)>[];
    p.openInApp = (window, arguments) async => opened.add((window.identifier, arguments));

    final info = await p.open(addressBook, arguments: {'title': 'x'});

    expect(info, isNull);
    expect(opened, hasLength(1));
    expect(opened.single.$1, 'addressbook');
    expect(opened.single.$2, {'title': 'x'});
  });

  test('without desktop windows and no in-app page, open fails', () async {
    final p = await provider();

    expect(() => p.open(addressBook), throwsStateError);
  });
}
