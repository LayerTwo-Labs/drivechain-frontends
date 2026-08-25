import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

WalletGradient _gradient({String? picturePath}) => WalletGradient(
  backgroundSvg: 'background_northern.svg',
  picturePath: picturePath,
  colors: const ['#000000', '#111111', '#222222'],
  stops: const [0, 0.5, 1],
  centerX: 0,
  centerY: 0,
  radius: 1.2,
  seed: 7,
);

Widget _host(WalletGradient gradient) => MaterialApp(
  home: Scaffold(body: WalletBlobAvatar(gradient: gradient, size: 24)),
);

void main() {
  // A picture the user moved or deleted must not leave a broken avatar.
  testWidgets('a missing picture falls back to the generated avatar', (tester) async {
    await tester.pumpWidget(_host(_gradient(picturePath: '/does/not/exist.png')));
    await tester.pump();

    expect(find.byType(Image), findsNothing);
  });

  testWidgets('a wallet with no picture keeps the generated avatar', (tester) async {
    await tester.pumpWidget(_host(_gradient()));
    await tester.pump();

    expect(find.byType(Image), findsNothing);
  });
}
