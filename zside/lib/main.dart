import 'package:flutter/widgets.dart';
import 'package:sail_ui/shell/shell.dart';
import 'package:zside/zside_module.dart';

Future<void> main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    final errorString = details.exception.toString();

    // Known desktop platform bugs: the mouse tracker and the keyboard state.
    if (errorString.contains('mouse_tracker.dart') ||
        errorString.contains('KeyDownEvent is dispatched') ||
        errorString.contains('_debugDuringDeviceUpdate')) {
      return;
    }

    FlutterError.presentError(details);
  };
  return runSidechainApp(ZSideModule());
}
