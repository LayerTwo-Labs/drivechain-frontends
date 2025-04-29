import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/sail_ui.dart';

class SailTable extends StatefulWidget {
  const SailTable({
    required this.headerBuilder,
    required this.rowBuilder,
    required this.rowCount,
    required this.columnWidths,
    this.columnMinWidths,
    this.columnMaxWidths,
    this.defaultMinColumnWidth = 50,
    this.backgroundColor,
    this.altBackgroundColor,
    this.headerDecoration,
    this.selectedRowId,
    this.selectableRows = true,
    this.onSelectedRow,
    this.onDoubleTap,
    this.contextMenuItems,
    this.cellHeight = 24.0,
    this.shrinkWrap = false,
    this.physics,
    this.drawGrid = false,
    this.resizableColumns = true,
    this.onColumnWidthsChanged,
    this.drawLastRowsBorder = true,
    this.onScrollApproachingEnd,
    this.sortColumnIndex,
    this.sortAscending,
    this.onSort,
    required this.getRowId,
    super.key,
  });

  final List<Widget> Function(BuildContext context) headerBuilder;
  final List<Widget> Function(BuildContext context, int row, bool selected) rowBuilder;
  final List<double> columnWidths;
  final List<double>? columnMinWidths;
  final List<double>? columnMaxWidths;
  final double defaultMinColumnWidth;
  final int rowCount;
  final Color? backgroundColor;
  final Color? altBackgroundColor;
  final BoxDecoration? headerDecoration;
  final String? selectedRowId;
  final bool selectableRows;
  final ValueChanged<String?>? onSelectedRow;
  final void Function(String rowId)? onDoubleTap;
  final List<SailMenuItem> Function(String rowId)? contextMenuItems;
  final double cellHeight;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool drawGrid;
  final bool resizableColumns;
  final bool drawLastRowsBorder;
  final void Function(List<double> widths)? onColumnWidthsChanged;
  final VoidCallback? onScrollApproachingEnd;
  final int? sortColumnIndex;
  final bool? sortAscending;
  final Function(int columnIndex, bool ascending)? onSort;
  final String Function(int index) getRowId;

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

  double get _totalColumnWidths => _widths.fold(0, (prev, e) => prev + e);

  @override
  void initState() {
    super.initState();
    _initializeState();
    _verticalController.addListener(_checkScrollPosition);
  }

  void _initializeState() {
    _selectedId = widget.selectedRowId;
    _sortColumnIndex = widget.sortColumnIndex;
    _sortAscending = widget.sortAscending ?? true;
    _widths.addAll(widget.columnWidths);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final parentWidth = context.size?.width ?? double.infinity;
      if (parentWidth.isFinite) {
        _resizeColumns(parentWidth);
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_currentConstraints?.maxWidth != constraints.maxWidth) {
          _currentConstraints = constraints;
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _resizeColumns(constraints.maxWidth);
            });
          }
        }
        return _buildTable(context, constraints);
      },
    );
  }

  void _resizeColumns(double parentWidth) {
    if (parentWidth <= 0 || !mounted) return;

    setState(() {
      final totalWidth = widget.columnWidths.fold(0.0, (sum, width) => sum + width);
      final minTotalWidth = widget.columnWidths.length * widget.defaultMinColumnWidth;
      final effectiveParentWidth = max(parentWidth, minTotalWidth);

      _widths.clear();
      _distributeColumnWidths(effectiveParentWidth, totalWidth);
    });
  }

  void _distributeColumnWidths(double availableWidth, double totalWidth) {
    double remainingWidth = availableWidth;
    _widths.clear();

    // Account for resize handles in the total width
    final numResizeHandles = widget.columnWidths.length - 1;
    remainingWidth -= (numResizeHandles * 8); // Subtract resize handle widths from available space

    for (var i = 0; i < widget.columnWidths.length; i++) {
      final minWidth = widget.columnMinWidths?.elementAt(i) ?? widget.defaultMinColumnWidth;
      _widths.add(minWidth);
      remainingWidth -= minWidth;
    }

    if (remainingWidth > 0) {
      for (var i = 0; i < widget.columnWidths.length; i++) {
        final proportion = widget.columnWidths[i] / totalWidth;
        final extraWidth = remainingWidth * proportion;
        final maxWidth = widget.columnMaxWidths?.elementAt(i);

        if (maxWidth != null) {
          _widths[i] = min(_widths[i] + extraWidth, maxWidth);
        } else {
          _widths[i] += extraWidth;
        }
      }
    }
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
      final minWidth = widget.columnMinWidths?.elementAt(column) ?? widget.defaultMinColumnWidth;
      final maxWidth = widget.columnMaxWidths?.elementAt(column);
      final newWidth = (_startColumnWidth + delta).clamp(
        minWidth,
        maxWidth ?? _currentConstraints!.maxWidth,
      );

      _widths[column] = newWidth;
      widget.onColumnWidthsChanged?.call(_widths);
    });
  }

  Widget _buildTable(BuildContext context, BoxConstraints constraints) {
    final tableWidth = constraints.maxWidth != double.infinity ? constraints.maxWidth : _totalColumnWidths;

    return Scrollbar(
      controller: _horizontalController,
      scrollbarOrientation: ScrollbarOrientation.bottom,
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          width: tableWidth,
          child: OverflowBox(
            maxWidth: tableWidth,
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                _buildHeader(context),
                if (!widget.shrinkWrap) Expanded(child: _buildRows(context)),
                if (widget.shrinkWrap) _buildRows(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = SailTheme.of(context);
    final headerCells =
        widget.headerBuilder(context).asMap().map((i, cell) => MapEntry(i, _wrapHeaderCell(i, cell))).values.toList();

    return Container(
      decoration: widget.headerDecoration ??
          BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.colors.divider),
            ),
          ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: _addResizeHandles(headerCells),
      ),
    );
  }

  Widget _wrapHeaderCell(int index, Widget cell) {
    if (cell is SailTableHeaderCell) {
      return SizedBox(
        width: _widths[index],
        child: ClipRect(
          child: SailTableHeaderCell(
            name: cell.name,
            alignment: cell.alignment,
            padding: cell.padding,
            isSorted: _sortColumnIndex == index,
            isAscending: _sortAscending,
            onSort: () => _handleSort(index),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleSort(index),
      child: SizedBox(
        width: _widths[index],
        child: ClipRect(child: cell),
      ),
    );
  }

  List<Widget> _addResizeHandles(List<Widget> cells) {
    final result = <Widget>[];
    for (var i = 0; i < cells.length; i++) {
      result.add(cells[i]);

      if (i < cells.length - 1 && widget.resizableColumns) {
        result.add(_buildResizeHandle(i));
      }
    }
    return result;
  }

  Widget _buildResizeHandle(int index) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) {
          _startColumnWidth = _widths[index];
        },
        onHorizontalDragUpdate: (details) {
          _handleColumnResize(index, details.delta.dx);
        },
        child: Container(
          width: 8,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: context.sailTheme.colors.divider,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRows(BuildContext context) {
    if (widget.shrinkWrap) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          widget.rowCount,
          (index) => _buildRow(context, index),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      controller: _verticalController,
      itemCount: widget.rowCount,
      itemBuilder: (context, index) => _buildRow(context, index),
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    final rowId = widget.getRowId(index);
    final isSelected = rowId == _selectedId;
    final isLastRow = index == widget.rowCount - 1;
    final backgroundColor = index % 2 == 1 ? widget.altBackgroundColor : null;

    return _TableRow(
      cells: widget.rowBuilder(context, index, isSelected),
      widths: _widths,
      height: widget.cellHeight,
      selected: isSelected,
      backgroundColor: backgroundColor,
      grid: widget.drawGrid,
      drawBorder: widget.drawLastRowsBorder || !isLastRow,
      onPressed: () => _handleRowSelection(rowId),
      onDoubleTap: widget.onDoubleTap == null ? null : () => widget.onDoubleTap!(rowId),
      contextMenuItems: widget.contextMenuItems,
      rowId: rowId,
    );
  }

  void _handleRowSelection(String rowId) {
    if (!widget.selectableRows) return;
    setState(() {
      _selectedId = _selectedId == rowId ? null : rowId;
    });
    widget.onSelectedRow?.call(_selectedId);
  }

  @override
  void didUpdateWidget(SailTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(oldWidget.columnWidths, widget.columnWidths)) {
      _resizeColumns(_currentConstraints!.maxWidth);
    }
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
  final List<SailMenuItem> Function(String rowId)? contextMenuItems;
  final String rowId;

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool isHovered = false;

  void _showContextMenu(BuildContext context, Offset position, String value, String rowId) {
    showSailMenu(
      context: context,
      preferredAnchorPoint: position,
      menu: SailMenu(
        width: 200,
        items: [
          SailMenuItem(
            onSelected: () {
              Clipboard.setData(ClipboardData(text: value));
              Navigator.of(context).pop();
            },
            child: SailText.primary12('Copy value'),
          ),
          if (widget.contextMenuItems != null)
            ...widget.contextMenuItems!(rowId).map(
              (item) => SailMenuItem(
                onSelected: () {
                  item.onSelected?.call();
                  Navigator.of(context).pop();
                },
                child: item.child,
              ),
            ),
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
                        border: Border(
                          right: BorderSide(
                            color: theme.colors.divider,
                            width: 1.0,
                          ),
                        ),
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
      i += 1;
    }

    Widget contents;

    if (isWindows || widget.grid) {
      contents = DecoratedBox(
        decoration: BoxDecoration(
          color: widget.selected || isHovered ? theme.colors.backgroundSecondary : widget.backgroundColor,
          border: widget.drawBorder
              ? Border(
                  bottom: BorderSide(
                    color: theme.colors.divider,
                    width: 1.0,
                  ),
                )
              : null,
        ),
        child: Row(
          children: cellWidgets,
        ),
      );
    } else {
      contents = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(SailStyleValues.padding04)),
          color: widget.selected || isHovered ? theme.colors.primary : widget.backgroundColor,
        ),
        child: Row(
          children: cellWidgets,
        ),
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
  final bool monospace;
  final bool italic;
  @override
  Widget build(BuildContext context) {
    var tableRow = context.findAncestorWidgetOfExactType<_TableRow>();
    assert(
      tableRow != null,
      'Table cell needs to be a child of SailTable',
    );

    return Container(
      alignment: alignment,
      padding: padding,
      child: child ??
          SailText.primary12(
            value,
            color: textColor,
            monospace: monospace,
            italic: italic,
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
              child: SailText.primary13(
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
String formatDate(DateTime date) {
  // Try to infer 24-hour format from locale
  final use24Hour = _is24HourLocale(Intl.getCurrentLocale());

  // Choose format string based on 24-hour preference
  final dateFormat = use24Hour ? 'yyyy MMM dd HH:mm' : 'yyyy MMM dd hh:mm a';

  return DateFormat(dateFormat, Intl.getCurrentLocale()).format(date.toLocal());
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
