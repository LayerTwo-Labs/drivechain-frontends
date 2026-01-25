import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sail_ui/sail_ui.dart';

const double defaultMinColumnWidth = 60;

class SailTable extends StatefulWidget {
  const SailTable({
    required this.headerBuilder,
    required this.rowBuilder,
    required this.rowCount,
    this.backgroundColor,
    this.altBackgroundColor,
    this.selectedRowId,
    this.selectableRows = true,
    this.onSelectedRow,
    this.onDoubleTap,
    this.contextMenuItems,
    this.cellHeight = 24.0,
    this.shrinkWrap = false,
    this.drawGrid = false,
    this.resizableColumns = true,
    this.onColumnWidthsChanged,
    this.drawLastRowsBorder = true,
    this.onScrollApproachingEnd,
    this.sortColumnIndex,
    this.sortAscending,
    this.onSort,
    required this.getRowId,
    this.rowBackgroundColor,
    this.emptyPlaceholder,
    super.key,
  });

  final List<Widget> Function(BuildContext context) headerBuilder;
  final List<Widget> Function(BuildContext context, int row, bool selected) rowBuilder;
  final int rowCount;
  final Color? backgroundColor;
  final Color? altBackgroundColor;
  final String? selectedRowId;
  final bool selectableRows;
  final ValueChanged<String?>? onSelectedRow;
  final void Function(String rowId)? onDoubleTap;
  final List<SailMenuEntity> Function(String rowId)? contextMenuItems;
  final double cellHeight;
  final bool shrinkWrap;
  final bool drawGrid;
  final bool resizableColumns;
  final bool drawLastRowsBorder;
  final void Function(List<double> widths)? onColumnWidthsChanged;
  final VoidCallback? onScrollApproachingEnd;
  final int? sortColumnIndex;
  final bool? sortAscending;
  final Function(int columnIndex, bool ascending)? onSort;
  final String Function(int index) getRowId;
  final Color? Function(int index)? rowBackgroundColor;

  /// Widget to display when the table has no rows.
  /// If null and rowCount is 0, the table will show an empty area.
  final String? emptyPlaceholder;

  @override
  State<SailTable> createState() => _SailTableState();
}

class _SailTableState extends State<SailTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  final List<double> _widths = [];

  String? _selectedId;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  BoxConstraints? _currentConstraints;
  double _startColumnWidth = 0;
  int? _numColumns;

  double get _totalColumnWidths => _widths.fold(0, (prev, e) => prev + e);

  @override
  void initState() {
    super.initState();
    _initializeState();
    _verticalController.addListener(_checkScrollPosition);
  }

  @override
  void didUpdateWidget(SailTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update internal state for selection/sort (no column resize needed)
    _selectedId = widget.selectedRowId;
    _sortColumnIndex = widget.sortColumnIndex;
    _sortAscending = widget.sortAscending ?? true;

    // Recalculate column widths when row count changes
    if (oldWidget.rowCount != widget.rowCount) {
      if (_currentConstraints != null && mounted) {
        // For 0 → N transition (first data load), resize immediately
        if (oldWidget.rowCount == 0 && widget.rowCount > 0) {
          _resizeColumns(_currentConstraints!.maxWidth, force: true);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _resizeColumns(_currentConstraints!.maxWidth, force: true);
            }
          });
        }
      }
    }
  }

  void _initializeState() {
    _selectedId = widget.selectedRowId;
    _sortColumnIndex = widget.sortColumnIndex;
    _sortAscending = widget.sortAscending ?? true;

    // Get column count from header builder
    final headers = widget.headerBuilder(context);
    _numColumns = headers.length;

    // Initialize with default widths immediately
    if (_widths.isEmpty) {
      _widths.addAll(List.filled(_numColumns!, defaultMinColumnWidth));
    }

    // Still keep the post-frame callback to adjust to actual size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final parentWidth = context.size?.width ?? double.infinity;
      if (parentWidth.isFinite) {
        _resizeColumns(parentWidth, force: true);
      }
    });
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Only auto-size if width is valid and changed
        if (_currentConstraints?.maxWidth != constraints.maxWidth &&
            constraints.maxWidth > 0 &&
            constraints.maxWidth != double.infinity) {
          _currentConstraints = constraints;
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _resizeColumns(constraints.maxWidth, force: true);
            });
          }
        }

        // Calculate total width including resize handles
        final handleWidth = widget.resizableColumns ? (_numColumns! - 1) * 8.0 : 0.0;
        final tableWidth = _totalColumnWidths + handleWidth;

        // Build header cells with resize handles
        final headerCells = <Widget>[];
        final headers = widget.headerBuilder(context);
        for (var i = 0; i < headers.length; i++) {
          final cell = headers[i];
          // Wrap header cell
          if (cell is SailTableHeaderCell) {
            headerCells.add(
              SizedBox(
                width: _widths[i],
                child: ClipRect(
                  child: SailTableHeaderCell(
                    name: cell.name,
                    alignment: cell.alignment,
                    padding: cell.padding,
                    isSorted: _sortColumnIndex == i,
                    isAscending: _sortAscending,
                    onSort: () => _handleSort(i),
                  ),
                ),
              ),
            );
          } else {
            headerCells.add(
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _handleSort(i),
                child: SizedBox(
                  width: _widths[i],
                  child: ClipRect(child: cell),
                ),
              ),
            );
          }

          // Add resize handle between columns
          if (i < headers.length - 1 && widget.resizableColumns) {
            headerCells.add(
              _ResizeHandle(
                index: i,
                onDragStart: (index) {
                  _startColumnWidth = _widths[index];
                },
                onDragUpdate: (index, globalX, startX) {
                  final dragDelta = globalX - startX;
                  _handleColumnResize(index, dragDelta);
                },
              ),
            );
          }
        }

        // Build rows content
        Widget rowsContent;
        if (widget.rowCount == 0 && widget.emptyPlaceholder != null) {
          rowsContent = Center(
            child: SailText.primary15(widget.emptyPlaceholder!, color: theme.colors.textTertiary),
          );
        } else if (widget.shrinkWrap) {
          rowsContent = Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.rowCount, (index) {
              final rowId = widget.getRowId(index);
              final isSelected = rowId == _selectedId;
              final isLastRow = index == widget.rowCount - 1;
              final bgColor =
                  widget.rowBackgroundColor?.call(index) ?? (index % 2 == 1 ? widget.altBackgroundColor : null);
              return _TableRow(
                cells: widget.rowBuilder(context, index, isSelected),
                widths: _widths,
                height: widget.cellHeight,
                selected: isSelected,
                backgroundColor: bgColor,
                grid: widget.drawGrid,
                drawBorder: widget.drawLastRowsBorder || !isLastRow,
                onPressed: () => _handleRowSelection(rowId),
                onDoubleTap: widget.onDoubleTap == null ? null : () => widget.onDoubleTap!(rowId),
                contextMenuItems: widget.contextMenuItems,
                rowId: rowId,
              );
            }),
          );
        } else {
          rowsContent = ListView.builder(
            padding: EdgeInsets.zero,
            controller: _verticalController,
            itemCount: widget.rowCount,
            itemExtent: widget.cellHeight,
            itemBuilder: (context, index) {
              final rowId = widget.getRowId(index);
              final isSelected = rowId == _selectedId;
              final isLastRow = index == widget.rowCount - 1;
              final bgColor =
                  widget.rowBackgroundColor?.call(index) ?? (index % 2 == 1 ? widget.altBackgroundColor : null);
              return _TableRow(
                cells: widget.rowBuilder(context, index, isSelected),
                widths: _widths,
                height: widget.cellHeight,
                selected: isSelected,
                backgroundColor: bgColor,
                grid: widget.drawGrid,
                drawBorder: widget.drawLastRowsBorder || !isLastRow,
                onPressed: () => _handleRowSelection(rowId),
                onDoubleTap: widget.onDoubleTap == null ? null : () => widget.onDoubleTap!(rowId),
                contextMenuItems: widget.contextMenuItems,
                rowId: rowId,
              );
            },
          );
        }

        return SelectionContainer.disabled(
          child: Scrollbar(
            controller: _horizontalController,
            scrollbarOrientation: ScrollbarOrientation.bottom,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: theme.colors.divider)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(children: headerCells),
                    ),
                    if (!widget.shrinkWrap) Expanded(child: rowsContent),
                    if (widget.shrinkWrap) rowsContent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _resizeColumns(double parentWidth, {bool force = false}) {
    if (parentWidth <= 0 || !mounted) return;

    setState(() {
      _autoSizeColumns(parentWidth);
    });
  }

  void _autoSizeColumns(double availableWidth) {
    _widths.clear();

    final columnWidths = List<double>.filled(_numColumns!, 0);

    final headers = widget.headerBuilder(context);
    for (int col = 0; col < headers.length; col++) {
      final headerWidth = _calculateColumnWidth(headers[col]);
      columnWidths[col] = max(columnWidths[col], headerWidth);
    }

    final rowsToSample = <int>[];
    if (widget.rowCount <= 20) {
      rowsToSample.addAll(List.generate(widget.rowCount, (i) => i));
    } else {
      rowsToSample.addAll(List.generate(10, (i) => i));
      rowsToSample.addAll(List.generate(10, (i) => widget.rowCount - 10 + i));
    }

    for (int row in rowsToSample) {
      final cells = widget.rowBuilder(context, row, false);
      for (int col = 0; col < cells.length && col < _numColumns!; col++) {
        final cellWidth = _calculateColumnWidth(cells[col]);
        columnWidths[col] = max(columnWidths[col], cellWidth);
      }
    }

    for (int i = 0; i < _numColumns!; i++) {
      columnWidths[i] = max(columnWidths[i], defaultMinColumnWidth);
    }

    _widths.addAll(columnWidths);
  }

  double _calculateColumnWidth(Widget widget) {
    String text = '';
    TextStyle? textStyle;

    if (widget is SailTableCell) {
      text = widget.value;
      textStyle = SailStyleValues.twelve.copyWith(fontFamily: widget.monospace ? 'IBMPlexMono' : 'Inter');
    } else if (widget is SailTableHeaderCell) {
      text = widget.name;
      textStyle = SailStyleValues.twelve.copyWith(fontFamily: 'Inter', fontWeight: SailStyleValues.boldWeight);
    }

    return _calculateTextWidth(text, textStyle ?? SailStyleValues.twelve);
  }

  double _calculateTextWidth(String text, TextStyle textStyle) {
    if (text.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      return textPainter.width + 25;
    }

    return defaultMinColumnWidth;
  }

  void _checkScrollPosition() {
    if (widget.onScrollApproachingEnd == null) return;
    if (_verticalController.position.extentAfter < 100) {
      widget.onScrollApproachingEnd!();
    }
  }

  void _handleSort(int columnIndex) {
    if (!mounted) return;
    final ascending = _sortColumnIndex != columnIndex || !_sortAscending;
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    widget.onSort?.call(columnIndex, ascending);
  }

  void _handleColumnResize(int column, double delta) {
    if (!widget.resizableColumns || !mounted) return;

    setState(() {
      final minWidth = defaultMinColumnWidth;
      final maxWidth = _currentConstraints!.maxWidth;
      final newWidth = (_startColumnWidth + delta).clamp(minWidth, maxWidth);

      _widths[column] = newWidth;
      widget.onColumnWidthsChanged?.call(_widths);
    });
  }

  void _handleRowSelection(String rowId) {
    if (!widget.selectableRows) return;
    setState(() {
      _selectedId = _selectedId == rowId ? null : rowId;
    });
    widget.onSelectedRow?.call(_selectedId);
  }
}

class _ResizeHandle extends StatefulWidget {
  final int index;
  final void Function(int index) onDragStart;
  final void Function(int index, double globalX, double startX) onDragUpdate;

  const _ResizeHandle({
    required this.index,
    required this.onDragStart,
    required this.onDragUpdate,
  });

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  double _dragStartX = 0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (details) {
          widget.onDragStart(widget.index);
          _dragStartX = details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          widget.onDragUpdate(widget.index, details.globalPosition.dx, _dragStartX);
        },
        child: Container(
          width: 8,
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: context.sailTheme.colors.divider)),
          ),
          child: Text(''),
        ),
      ),
    );
  }
}

class _TableRow extends StatefulWidget {
  const _TableRow({
    required this.cells,
    required this.onPressed,
    required this.selected,
    required this.widths,
    required this.height,
    required this.grid,
    required this.drawBorder,
    this.backgroundColor,
    this.onDoubleTap,
    this.contextMenuItems,
    required this.rowId,
  });

  final List<Widget> cells;
  final VoidCallback onPressed;
  final bool selected;
  final Color? backgroundColor;
  final List<double> widths;
  final double height;
  final bool grid;
  final bool drawBorder;
  final void Function()? onDoubleTap;
  final List<SailMenuEntity> Function(String rowId)? contextMenuItems;
  final String rowId;

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool isHovered = false;

  void _showContextMenu(BuildContext context, Offset position, String value, String rowId) {
    final maxWidth = widget.contextMenuItems?.call(rowId).fold(0, (m, item) => max(m, item.width.toInt())) ?? 200;

    showSailMenu(
      context: context,
      preferredAnchorPoint: position,
      menu: SailMenu(
        width: maxWidth.toDouble(),
        items: [
          SailMenuItem(
            onSelected: () {
              Clipboard.setData(ClipboardData(text: value));
              Navigator.of(context).pop();
            },
            child: SailText.primary12('Copy value'),
          ),
          if (widget.contextMenuItems != null) ...widget.contextMenuItems!(rowId).map((item) => item),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    var isWindows = context.isWindows;

    var cellWidgets = <Widget>[];
    int i = 0;
    for (var cell in widget.cells) {
      final String? cellValue = cell is SailTableCell ? cell.copyValue ?? cell.value : null;

      // Add the cell
      cellWidgets.add(
        SizedBox(
          width: widget.widths[i],
          height: widget.height,
          child: MouseRegion(
            cursor: cellValue != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onSecondaryTapDown: cellValue != null
                  ? (details) => _showContextMenu(context, details.globalPosition, cellValue, widget.rowId)
                  : null,
              child: Container(
                decoration: widget.grid
                    ? BoxDecoration(
                        border: Border(right: BorderSide(color: theme.colors.divider, width: 1.0)),
                      )
                    : null,
                width: double.infinity,
                height: double.infinity,
                child: cell,
              ),
            ),
          ),
        ),
      );

      // Add a spacer for resize handle width (except for last cell)
      if (i < widget.cells.length - 1) {
        cellWidgets.add(
          const SizedBox(width: 8), // Same width as resize handle
        );
      }

      i += 1;
    }

    Widget contents;

    if (isWindows || widget.grid) {
      contents = DecoratedBox(
        decoration: BoxDecoration(
          color: widget.selected || isHovered ? theme.colors.backgroundSecondary : widget.backgroundColor,
          border: widget.drawBorder ? Border(bottom: BorderSide(color: theme.colors.divider, width: 1.0)) : null,
        ),
        child: Row(children: cellWidgets),
      );
    } else {
      contents = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(SailStyleValues.padding04)),
          color: widget.selected || isHovered ? theme.colors.backgroundSecondary : widget.backgroundColor,
        ),
        child: Row(children: cellWidgets),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onLongPressDown: (_) {
          widget.onPressed();
        },
        onDoubleTapDown: widget.onDoubleTap == null
            ? null
            : (_) {
                widget.onDoubleTap!();
              },
        behavior: HitTestBehavior.translucent,
        child: contents,
      ),
    );
  }
}

class SailTableCell extends StatelessWidget {
  const SailTableCell({
    required this.value,
    this.copyValue,
    this.child,
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.plainIconTheme,
    this.selectedIconTheme,
    this.textColor,
    this.backgroundColor,
    this.monospace = false,
    this.italic = false,
    super.key,
  });

  final String value;
  final String? copyValue;
  final Widget? child;
  final Alignment alignment;
  final EdgeInsets padding;
  final SailSVGAsset? plainIconTheme;
  final SailSVGAsset? selectedIconTheme;
  final Color? textColor;
  final Color? backgroundColor;
  final bool monospace;
  final bool italic;
  @override
  Widget build(BuildContext context) {
    var tableRow = context.findAncestorWidgetOfExactType<_TableRow>();
    assert(tableRow != null, 'Table cell needs to be a child of SailTable');

    return Container(
      alignment: alignment,
      padding: padding,
      color: backgroundColor,
      child:
          child ??
          SailText.primary12(
            value,
            color: textColor,
            monospace: monospace,
            italic: italic,
            overflow: TextOverflow.ellipsis,
          ),
    );
  }
}

class SailTableHeaderCell extends StatelessWidget {
  const SailTableHeaderCell({
    required this.name,
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.onSort,
    this.isSorted = false,
    this.isAscending = true,
    super.key,
  });

  final String name;
  final Alignment alignment;
  final EdgeInsets padding;
  final VoidCallback? onSort;
  final bool isSorted;
  final bool isAscending;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return GestureDetector(
      onTap: onSort,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: padding,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: SailText.primary10(
                name,
                bold: true,
                overflow: TextOverflow.ellipsis,
                color: theme.colors.inactiveNavText,
              ),
            ),
            if (isSorted) ...[
              const SizedBox(width: 4),
              SailSVG.fromAsset(
                isAscending ? SailSVGAsset.arrowUp : SailSVGAsset.arrowDown,
                height: 10,
                color: theme.colors.inactiveNavText,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Formats a [date] according to the user's locale and time format preference.
String formatDate(DateTime date, {bool long = true}) {
  // Try to infer 24-hour format from locale
  final use24Hour = _is24HourLocale(intl.Intl.getCurrentLocale());

  // Choose format string based on 24-hour preference
  var dateFormat = use24Hour ? 'yyyy MMM dd HH:mm' : 'yyyy MMM dd hh:mm a';
  if (!long) {
    dateFormat = dateFormat.replaceAll('yyyy ', '');
  }

  return intl.DateFormat(dateFormat, intl.Intl.getCurrentLocale()).format(date.toLocal());
}

/// Heuristic: Returns true if the locale is likely to use 24-hour time.
/// This is not perfect, but covers common cases.
bool _is24HourLocale(String locale) {
  // Locales that typically use 12-hour time
  const twelveHourLocales = [
    'en_US', 'en_PH', 'en_CA', 'en_AU', 'en_NZ', 'en_IE', 'en_IN',
    // Add more as needed
  ];
  return !twelveHourLocales.contains(locale);
}
