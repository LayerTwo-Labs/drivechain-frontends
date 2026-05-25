import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

enum SailAccordionType { single, multiple }

class SailAccordionItem {
  final String id;
  final Widget header;
  final Widget body;

  const SailAccordionItem({
    required this.id,
    required this.header,
    required this.body,
  });
}

class SailAccordion extends StatefulWidget {
  final List<SailAccordionItem> items;
  final SailAccordionType type;

  /// Initially open item ids.
  final List<String> initialOpen;

  /// In single mode, allow closing the only-open item leaving none open.
  final bool collapsible;

  final ValueChanged<List<String>>? onChanged;

  const SailAccordion({
    super.key,
    required this.items,
    this.type = SailAccordionType.single,
    this.initialOpen = const [],
    this.collapsible = true,
    this.onChanged,
  });

  @override
  State<SailAccordion> createState() => _SailAccordionState();
}

class _SailAccordionState extends State<SailAccordion> {
  late Set<String> _open;

  @override
  void initState() {
    super.initState();
    _open = Set.of(widget.initialOpen);
    if (widget.type == SailAccordionType.single && _open.length > 1) {
      _open = {_open.first};
    }
  }

  void _toggle(String id) {
    setState(() {
      final isOpen = _open.contains(id);
      if (widget.type == SailAccordionType.single) {
        if (isOpen) {
          if (widget.collapsible) _open.remove(id);
        } else {
          _open = {id};
        }
      } else {
        if (isOpen) {
          _open.remove(id);
        } else {
          _open.add(id);
        }
      }
    });
    widget.onChanged?.call(_open.toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < widget.items.length; i++)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: i == widget.items.length - 1 ? const Color(0x00000000) : theme.colors.divider,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _toggle(widget.items[i].id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SailStyleValues.padding16,
                      vertical: SailStyleValues.padding12,
                    ),
                    child: _AccordionHeader(
                      isOpen: _open.contains(widget.items[i].id),
                      child: widget.items[i].header,
                    ),
                  ),
                ),
                SailCollapsible(
                  open: _open.contains(widget.items[i].id),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SailStyleValues.padding16,
                      0,
                      SailStyleValues.padding16,
                      SailStyleValues.padding12,
                    ),
                    child: widget.items[i].body,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AccordionHeader extends StatelessWidget {
  final Widget child;
  final bool isOpen;

  const _AccordionHeader({required this.child, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return Row(
      children: [
        Expanded(child: child),
        const SizedBox(width: SailStyleValues.padding08),
        AnimatedRotation(
          turns: isOpen ? 0.5 : 0,
          duration: const Duration(milliseconds: 180),
          child: CustomPaint(
            size: const Size(10, 6),
            painter: _ChevronPainter(color: theme.colors.icon),
          ),
        ),
      ],
    );
  }
}

class _ChevronPainter extends CustomPainter {
  final Color color;

  _ChevronPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) => oldDelegate.color != color;
}
