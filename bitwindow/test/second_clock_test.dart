import 'package:bitwindow/pages/root_page.dart';
import 'package:bitwindow/providers/fork_provider.dart';
import 'package:bitwindow/widgets/fork_countdown_timer.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';

class _Clocks extends StatefulWidget {
  const _Clocks();

  @override
  State<_Clocks> createState() => _ClocksState();
}

class _ClocksState extends State<_Clocks> {
  bool showCountdown = false;

  void show() => setState(() => showCountdown = true);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LastBlockAge(
          lastBlockAt: Timestamp.fromDateTime(DateTime.now().subtract(const Duration(minutes: 5))),
          blockInfo: null,
          compact: false,
        ),
        if (showCountdown) const ForkCountdownTimer(),
      ],
    );
  }
}

void main() {
  testWidgets('the block age and the fork countdown change in the same frame', (tester) async {
    GetIt.I.registerSingleton<ForkProvider>(
      ForkProvider()
        ..showCountdown = true
        ..forkHeight = 100
        ..forkTargetDate = DateTime.now().add(const Duration(hours: 1)),
    );
    addTearDown(GetIt.I.reset);

    await tester.pumpWidget(
      SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: const Directionality(textDirection: TextDirection.ltr, child: _Clocks()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    tester.state<_ClocksState>(find.byType(_Clocks)).show();
    await tester.pump();

    var frames = 0;
    SchedulerBinding.instance.addPersistentFrameCallback((_) => frames++);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(frames, 4);
  });
}
