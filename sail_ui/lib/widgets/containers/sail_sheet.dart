import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

enum SailSheetSide { left, right, top, bottom }

/// Shows a [SailSheet] sliding in from [side]. Returns the same future as
/// [Navigator.push]: completes when the sheet is dismissed.
Future<T?> showSailSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  SailSheetSide side = SailSheetSide.right,
  bool barrierDismissible = true,
  Duration transitionDuration = const Duration(milliseconds: 220),
  Color? barrierColor,
}) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      opaque: false,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? const Color(0x66000000),
      barrierLabel: 'sheet',
      transitionDuration: transitionDuration,
      reverseTransitionDuration: transitionDuration,
      pageBuilder: (ctx, anim, secondary) {
        return SailSheet(
          side: side,
          child: Builder(builder: builder),
        );
      },
      transitionsBuilder: (ctx, anim, secondary, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        Offset begin;
        switch (side) {
          case SailSheetSide.left:
            begin = const Offset(-1, 0);
            break;
          case SailSheetSide.right:
            begin = const Offset(1, 0);
            break;
          case SailSheetSide.top:
            begin = const Offset(0, -1);
            break;
          case SailSheetSide.bottom:
            begin = const Offset(0, 1);
            break;
        }
        return SlideTransition(
          position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
          child: child,
        );
      },
    ),
  );
}

class SailSheet extends StatelessWidget {
  final Widget child;
  final SailSheetSide side;
  final double? size;

  const SailSheet({
    super.key,
    required this.child,
    this.side = SailSheetSide.right,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final mq = MediaQuery.of(context).size;

    final isHorizontal = side == SailSheetSide.left || side == SailSheetSide.right;
    final defaultSize = isHorizontal ? mq.width * 0.4 : mq.height * 0.4;
    final extent = (size ?? defaultSize).clamp(220.0, isHorizontal ? mq.width : mq.height);

    Alignment alignment;
    switch (side) {
      case SailSheetSide.left:
        alignment = Alignment.centerLeft;
        break;
      case SailSheetSide.right:
        alignment = Alignment.centerRight;
        break;
      case SailSheetSide.top:
        alignment = Alignment.topCenter;
        break;
      case SailSheetSide.bottom:
        alignment = Alignment.bottomCenter;
        break;
    }

    return Align(
      alignment: alignment,
      child: Container(
        width: isHorizontal ? extent : double.infinity,
        height: isHorizontal ? double.infinity : extent,
        decoration: BoxDecoration(
          color: theme.colors.background,
          border: Border.all(color: theme.colors.border),
          boxShadow: [
            BoxShadow(
              color: theme.colors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
