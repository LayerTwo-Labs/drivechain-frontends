import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  testWidgets('an open tooltip shows a new message', (tester) async {
    final message = ValueNotifier('old');
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SailTheme(
          data: SailThemeData.darkTheme(SailColorScheme.orange, false, SailFontValues.ibmMono, SailThemeStyle.ecash),
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (_) => Center(
                  child: ValueListenableBuilder(
                    valueListenable: message,
                    builder: (_, text, _) => SailTooltip(
                      message: text,
                      showDuration: null,
                      child: const SizedBox(width: 40, height: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(SizedBox).first));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('old'), findsOneWidget);

    message.value = 'new';
    await tester.pump();
    await tester.pump();
    expect(find.text('new'), findsOneWidget);
    await mouse.removePointer();
  });
}
