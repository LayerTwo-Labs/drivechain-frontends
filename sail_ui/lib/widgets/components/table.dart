import 'dart:math';

import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    this.cellHeight = 40.0,
    this.minColumnWidths = const {},
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
    this.phoneColumns,
    this.rowBackgroundColor,
    this.headerBackgroundColor,
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

  /// Minimum widths in logical pixels, by column index.
  final Map<int, double> minColumnWidths;
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
  final Color? headerBackgroundColor;

  /// Widget to display when the table has no rows.
  /// If null and rowCount is 0, the table will show an empty area.
  final String? emptyPlaceholder;

  /// The column indices that the phone layout shows. Null shows every column.
  final List<int>? phoneColumns;

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
  TextScaler? _lastScaler;
  String? _lastFontFamily;

  double get _totalColumnWidths => _widths.fold(0, (prev, e) => prev + e);

  List<int>? _visibleColumns(BuildContext context) =>
      widget.phoneColumns != null && SailStyleValues.phoneLayout(context) ? widget.phoneColumns : null;

  /// The index in the caller's columns of the shown column [i].
  int _sourceColumn(int i) {
    final visible = _visibleColumns(context);
    return visible == null ? i : visible[i];
  }

  List<Widget> _pick(BuildContext context, List<Widget> all) {
    final visible = _visibleColumns(context);
    return visible == null ? all : [for (final i in visible) all[i]];
  }

  List<Widget> _headers(BuildContext context) => _pick(context, widget.headerBuilder(context));

  List<Widget> _cells(BuildContext context, int row, bool selected) =>
      _pick(context, widget.rowBuilder(context, row, selected));

  @override
  void initState() {
    super.initState();
    _initializeState();
    _verticalController.addListener(_checkScrollPosition);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scaler = MediaQuery.of(context).textScaler;
    final fontFamily = SailTheme.of(context).chrome.textFamily();
    if (_lastScaler != null &&
        (_lastScaler != scaler || _lastFontFamily != fontFamily) &&
        _currentConstraints != null) {
      _resizeColumns(_currentConstraints!.maxWidth, force: true);
    }
    _lastScaler = scaler;
    _lastFontFamily = fontFamily;
  }

  @override
  void didUpdateWidget(SailTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.cellHeight != widget.cellHeight && _verticalController.hasClients) {
      final row = _verticalController.offset / oldWidget.cellHeight;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _verticalController.hasClients) {
          final position = _verticalController.position;
          _verticalController.jumpTo(
            (row * widget.cellHeight).clamp(position.minScrollExtent, position.maxScrollExtent),
          );
        }
      });
    }

    // Update internal state for selection/sort (no column resize needed)
    _selectedId = widget.selectedRowId;
    _sortColumnIndex = widget.sortColumnIndex;
    _sortAscending = widget.sortAscending ?? true;

    // A caller can add or drop a column between builds. Every width reads by
    // column index, so the list must follow the header count.
    final headers = _headers(context);
    if (headers.length != _numColumns) {
      _numColumns = headers.length;
      _widths
        ..clear()
        ..addAll(List.filled(_numColumns!, defaultMinColumnWidth));
      if (_currentConstraints != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _resizeColumns(_currentConstraints!.maxWidth, force: true);
          }
        });
      }
      return;
    }

    if (!mapEquals(oldWidget.minColumnWidths, widget.minColumnWidths) && _currentConstraints != null) {
      _resizeColumns(_currentConstraints!.maxWidth, force: true);
    }

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
    final headers = _headers(context);
    _numColumns = headers.length;

    // Initialize with default widths immediately
    if (_widths.isEmpty) {
      _widths.addAll(List.filled(_numColumns!, defaultMinColumnWidth));
    }

    // Still keep the post-frame callback to adjust to actual size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
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
          _autoSizeColumns(constraints.maxWidth);
        }

        // Calculate total width including resize handles
        final handleWidth = widget.resizableColumns ? (_numColumns! - 1) * 8.0 : 0.0;
        final tableWidth = _totalColumnWidths + handleWidth;

        // Build header cells with resize handles
        final headerCells = <Widget>[];
        final headers = _headers(context);
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
                    sortable: cell.sortable,
                    isSorted: cell.sortable && _sortColumnIndex == _sourceColumn(i),
                    isAscending: _sortAscending,
                    onSort: cell.sortable ? () => _handleSort(_sourceColumn(i)) : null,
                    filterWidget: cell.filterWidget,
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

        final window = context.getInheritedWidgetOfExactType<_SailTableWindow>();
        Widget rowsContent;
        var rowsSized = false;
        if (widget.rowCount == 0 && widget.emptyPlaceholder != null) {
          rowsContent = Center(
            child: SailText.primary15(
              widget.emptyPlaceholder!,
              color: theme.colors.textTertiary,
            ),
          );
        } else if (window != null) {
          rowsSized = widget.shrinkWrap || !constraints.hasBoundedHeight;
          rowsContent = _LazyRows(
            rowCount: widget.rowCount,
            rowHeight: widget.cellHeight,
            // The table context, so a lookup in a row rebuilds the table and
            // drops the rows that _LazyRows keeps.
            builder: (_, index) => _buildRow(context, index),
          );
          if (rowsSized) {
            rowsContent = SizedBox(height: widget.rowCount * widget.cellHeight, child: rowsContent);
          }
        } else if (widget.shrinkWrap) {
          // Rows past a bounded height are clipped, so they are not built.
          final builtRows = constraints.hasBoundedHeight
              ? min(widget.rowCount, (constraints.maxHeight / widget.cellHeight).ceil())
              : widget.rowCount;
          rowsContent = Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(builtRows, (index) => _buildRow(context, index)),
          );
        } else {
          rowsContent = ListView.builder(
            padding: EdgeInsets.zero,
            controller: _verticalController,
            itemCount: widget.rowCount,
            itemExtent: widget.cellHeight,
            itemBuilder: _buildRow,
          );
        }
        final rowsExpand = !widget.shrinkWrap && !rowsSized;

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
                        color: widget.headerBackgroundColor,
                        border: Border(
                          bottom: BorderSide(color: theme.colors.divider),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding10),
                      child: Row(children: headerCells),
                    ),
                    if (rowsExpand) Expanded(child: rowsContent),
                    if (!rowsExpand) rowsContent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    final rowId = widget.getRowId(index);
    final isSelected = rowId == _selectedId;
    final isLastRow = index == widget.rowCount - 1;
    final bgColor = widget.rowBackgroundColor?.call(index) ?? (index % 2 == 1 ? widget.altBackgroundColor : null);
    return _TableRow(
      cells: _cells(context, index, isSelected),
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
  }

  void _resizeColumns(double parentWidth, {bool force = false}) {
    if (parentWidth <= 0 || !mounted) {
      return;
    }

    setState(() {
      _autoSizeColumns(parentWidth);
    });
  }

  void _autoSizeColumns(double availableWidth) {
    _widths.clear();

    final columnWidths = List<double>.filled(_numColumns!, 0);
    final fixedColumns = List<bool>.filled(_numColumns!, false);

    final headers = _headers(context);
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

    final hugging = List<bool>.filled(_numColumns!, false);
    final filling = List<bool>.filled(_numColumns!, false);
    for (int row in rowsToSample) {
      final cells = _cells(context, row, false);
      for (int col = 0; col < cells.length && col < _numColumns!; col++) {
        final cell = cells[col];
        if (cell is SailTableCell && cell.fill) {
          filling[col] = true;
        }
        if (cell is SailTableCell && (cell.width != null || cell.hugContent)) {
          fixedColumns[col] = true;
          hugging[col] = hugging[col] || cell.hugContent;
        }
        final cellWidth = _calculateColumnWidth(cell);
        columnWidths[col] = max(columnWidths[col], cellWidth);
      }
    }

    // A hugging column takes no spare width, so a row outside the sample would
    // render in a column too narrow for it.
    if (hugging.contains(true) && rowsToSample.length < widget.rowCount) {
      for (int row = 0; row < widget.rowCount; row++) {
        final cells = _cells(context, row, false);
        for (int col = 0; col < cells.length && col < _numColumns!; col++) {
          if (!hugging[col]) {
            continue;
          }
          columnWidths[col] = max(columnWidths[col], _calculateColumnWidth(cells[col]));
        }
      }
    }

    for (int i = 0; i < _numColumns!; i++) {
      columnWidths[i] = max(columnWidths[i], widget.minColumnWidths[_sourceColumn(i)] ?? 0);
      if (fixedColumns[i]) {
        continue;
      }
      columnWidths[i] = max(columnWidths[i], defaultMinColumnWidth);
    }

    final fillColumn = filling.indexOf(true);
    if (fillColumn >= 0) {
      final handleWidth = widget.resizableColumns ? (_numColumns! - 1) * 8.0 : 0.0;
      var others = 0.0;
      for (int i = 0; i < _numColumns!; i++) {
        if (i != fillColumn) {
          others += columnWidths[i];
        }
      }
      columnWidths[fillColumn] = max(defaultMinColumnWidth, availableWidth - handleWidth - others);
    } else {
      _stretchToFill(columnWidths, fixedColumns, availableWidth);
    }

    _widths.addAll(columnWidths);
  }

  void _stretchToFill(
    List<double> columnWidths,
    List<bool> fixedColumns,
    double availableWidth,
  ) {
    final handleWidth = widget.resizableColumns ? (_numColumns! - 1) * 8.0 : 0.0;
    final contentWidth = columnWidths.fold<double>(0, (prev, e) => prev + e);
    final slack = availableWidth - handleWidth - contentWidth;
    if (slack <= 0) {
      return;
    }

    final growable = <int>[];
    for (int i = 0; i < _numColumns!; i++) {
      if (!fixedColumns[i]) {
        growable.add(i);
      }
    }
    if (growable.isEmpty) {
      return;
    }

    final share = slack / growable.length;
    for (final i in growable) {
      columnWidths[i] += share;
    }
  }

  double _calculateColumnWidth(Widget widget) {
    String text = '';
    TextStyle? textStyle;

    // A cell renders at thirteen, so a measurement at twelve leaves the widest
    // value one ellipsis short of its own column.
    if (widget is SailTableCell) {
      if (widget.width != null) {
        return widget.width!;
      }
      text = widget.value;
      textStyle = SailStyleValues.thirteen.copyWith(
        fontFamily: SailTheme.of(context).chrome.textFamily(monospace: widget.monospace),
      );
      return _calculateTextWidth(text, textStyle, widget.padding.horizontal);
    } else if (widget is SailTableHeaderCell) {
      text = widget.name;
      textStyle = SailStyleValues.thirteen.copyWith(
        fontFamily: SailTheme.of(context).chrome.textFamily(),
        fontWeight: SailStyleValues.boldWeight,
      );
      return _calculateTextWidth(text, textStyle, widget.padding.horizontal);
    }

    return _calculateTextWidth(text, SailStyleValues.thirteen, 24);
  }

  double _calculateTextWidth(String text, TextStyle textStyle, double padding) {
    if (text.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: DefaultTextStyle.of(context).style.merge(textStyle)),
        textDirection: TextDirection.ltr,
        // The same scaler SailText renders with, clamp included.
        textScaler: MediaQuery.of(context).textScaler.clamp(maxScaleFactor: 2),
      );
      textPainter.layout();
      final width = textPainter.width;
      textPainter.dispose();
      return width + padding + 1;
    }

    return defaultMinColumnWidth;
  }

  void _checkScrollPosition() {
    if (widget.onScrollApproachingEnd == null) {
      return;
    }
    if (_verticalController.position.extentAfter < 100) {
      widget.onScrollApproachingEnd!();
    }
  }

  void _handleSort(int columnIndex) {
    if (!mounted) {
      return;
    }
    final ascending = _sortColumnIndex != columnIndex || !_sortAscending;
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    widget.onSort?.call(columnIndex, ascending);
  }

  void _handleColumnResize(int column, double delta) {
    if (!widget.resizableColumns || !mounted) {
      return;
    }

    setState(() {
      final minWidth = max(defaultMinColumnWidth, widget.minColumnWidths[column] ?? 0);
      final maxWidth = max(minWidth, _currentConstraints!.maxWidth);
      final newWidth = (_startColumnWidth + delta).clamp(minWidth, maxWidth);

      _widths[column] = newWidth;
      widget.onColumnWidthsChanged?.call(_widths);
    });
  }

  void _handleRowSelection(String rowId) {
    if (!widget.selectableRows) {
      return;
    }
    setState(() {
      _selectedId = _selectedId == rowId ? null : rowId;
    });
    widget.onSelectedRow?.call(_selectedId);
  }
}

/// A sliver that holds a box with a [SailTable] in a scroll view. The box is
/// [minHeight] tall, or taller so that each row shows. The table builds only
/// the rows in or near the viewport, and does not scroll on its own.
class SliverSailTable extends StatelessWidget {
  const SliverSailTable({super.key, required this.minHeight, required this.child});

  final double minHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fit = _SailTableFit(minHeight: minHeight, child: child);
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final start = constraints.scrollOffset + constraints.cacheOrigin;
        return SliverToBoxAdapter(
          child: _SailTableWindow(start: start, end: start + constraints.remainingCacheExtent, child: fit),
        );
      },
    );
  }
}

/// The part of a [SliverSailTable] box in or near the viewport, in box coordinates.
class _SailTableWindow extends InheritedWidget {
  const _SailTableWindow({required this.start, required this.end, required super.child});

  final double start;
  final double end;

  @override
  bool updateShouldNotify(_SailTableWindow oldWidget) => start != oldWidget.start || end != oldWidget.end;
}

class _SailTableFit extends SingleChildRenderObjectWidget {
  const _SailTableFit({required this.minHeight, required super.child});

  final double minHeight;

  @override
  _RenderSailTableFit createRenderObject(BuildContext context) => _RenderSailTableFit(minHeight);

  @override
  void updateRenderObject(BuildContext context, _RenderSailTableFit renderObject) {
    renderObject.minHeight = minHeight;
  }
}

class _RenderSailTableFit extends RenderProxyBox {
  _RenderSailTableFit(this._minHeight);

  double _minHeight;
  set minHeight(double value) {
    if (value == _minHeight) {
      return;
    }
    _minHeight = value;
    markNeedsLayout();
  }

  final Set<_RenderLazyRows> _rows = {};

  double get _missing => _rows.fold(0, (m, rows) => max(m, rows.missing));

  // Loose, so the child is no relayout boundary: a row count change inside it
  // lays out this box again.
  BoxConstraints _upTo(double height) => BoxConstraints(
    minWidth: constraints.minWidth,
    maxWidth: constraints.maxWidth,
    maxHeight: constraints.constrainHeight(height),
  );

  @override
  void performLayout() {
    final child = this.child!;
    child.layout(_upTo(_minHeight), parentUsesSize: true);
    final missing = _missing;
    if (missing > 0) {
      child.layout(_upTo(child.size.height + missing), parentUsesSize: true);
    }
    size = constraints.constrain(Size(child.size.width, max(child.size.height, _minHeight)));
  }
}

class _LazyRows extends StatefulWidget {
  const _LazyRows({required this.rowCount, required this.rowHeight, required this.builder});

  final int rowCount;
  final double rowHeight;
  final IndexedWidgetBuilder builder;

  @override
  State<_LazyRows> createState() => _LazyRowsState();
}

class _LazyRowsState extends State<_LazyRows> {
  final Map<int, Widget> _built = {};
  Widget? _last;
  int _first = 0;
  int _end = 0;
  double _top = 0;
  bool _checkScheduled = false;

  @override
  void didUpdateWidget(_LazyRows oldWidget) {
    super.didUpdateWidget(oldWidget);
    _built.clear();
    _last = null;
  }

  double? _measureTop() {
    final box = context.findRenderObject();
    final fit = context.findAncestorRenderObjectOfType<_RenderSailTableFit>();
    if (box is! RenderBox || fit == null || !box.attached || !box.hasSize) {
      return null;
    }
    return box.localToGlobal(Offset.zero, ancestor: fit).dy;
  }

  void _checkTop(Duration _) {
    _checkScheduled = false;
    if (!mounted) {
      return;
    }
    final top = _measureTop();
    if (top != null && top != _top) {
      setState(() => _last = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final window = context.dependOnInheritedWidgetOfExactType<_SailTableWindow>()!;
    _top = _measureTop() ?? _top;
    final h = widget.rowHeight;
    final first = ((window.start - _top) / h).floor().clamp(0, widget.rowCount);
    final end = ((window.end - _top) / h).ceil().clamp(first, widget.rowCount);
    if (_last != null && first == _first && end == _end) {
      return _last!;
    }
    _first = first;
    _end = end;
    _built.removeWhere((i, _) => i < first || i >= end);
    // The clip and the repaint boundaries match the layers of a ListView, so a
    // fractional scroll offset puts each row on the same pixels.
    _last = _RowsExtent(
      extent: widget.rowCount * h,
      child: RepaintBoundary(
        child: ClipRect(
          child: Stack(
            children: [
              for (var i = first; i < end; i++)
                _built.putIfAbsent(
                  i,
                  () => Positioned(
                    key: ValueKey(i),
                    top: i * h,
                    left: 0,
                    right: 0,
                    height: h,
                    child: RepaintBoundary(child: widget.builder(context, i)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (!_checkScheduled) {
      _checkScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback(_checkTop);
    }
    return _last!;
  }
}

class _RowsExtent extends SingleChildRenderObjectWidget {
  const _RowsExtent({required this.extent, required super.child});

  final double extent;

  @override
  _RenderLazyRows createRenderObject(BuildContext context) => _RenderLazyRows(extent);

  @override
  void updateRenderObject(BuildContext context, _RenderLazyRows renderObject) {
    renderObject.extent = extent;
  }
}

/// Tells the enclosing [_RenderSailTableFit] how much taller it must be to
/// show each row. It lays out inside the fit box, which has no relayout
/// boundary below it.
class _RenderLazyRows extends RenderProxyBox {
  _RenderLazyRows(this._extent);

  double _extent;
  set extent(double value) {
    if (value == _extent) {
      return;
    }
    _extent = value;
    markNeedsLayout();
  }

  double missing = 0;
  _RenderSailTableFit? _fit;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    var node = parent;
    while (node != null && node is! _RenderSailTableFit) {
      node = node.parent;
    }
    _fit = node as _RenderSailTableFit?;
    _fit?._rows.add(this);
  }

  @override
  void detach() {
    _fit?._rows.remove(this);
    _fit = null;
    super.detach();
  }

  @override
  void performLayout() {
    super.performLayout();
    missing = _extent - size.height;
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
          widget.onDragUpdate(
            widget.index,
            details.globalPosition.dx,
            _dragStartX,
          );
        },
        child: Container(
          width: 8,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: context.sailTheme.colors.divider),
            ),
          ),
          child: const SizedBox(height: 20),
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

  void _showContextMenu(
    BuildContext context,
    Offset position,
    String value,
    String rowId,
  ) {
    final maxWidth = widget.contextMenuItems?.call(rowId).fold(0, (m, item) => max(m, item.width.toInt())) ?? 200;

    showSailMenu(
      context: context,
      preferredAnchorPoint: position,
      menu: SailMenu(
        width: maxWidth.toDouble(),
        items: [
          SailMenuItem(
            closeOnSelect: false,
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
    final phone = SailStyleValues.phoneLayout(context);

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
                  ? (details) => _showContextMenu(
                      context,
                      details.globalPosition,
                      cellValue,
                      widget.rowId,
                    )
                  : null,
              onLongPressStart: cellValue != null && phone
                  ? (details) => _showContextMenu(
                      context,
                      details.globalPosition,
                      cellValue,
                      widget.rowId,
                    )
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
          border: widget.drawBorder
              ? Border(
                  bottom: BorderSide(color: theme.colors.divider, width: 1.0),
                )
              : null,
        ),
        child: Row(children: cellWidgets),
      );
    } else {
      contents = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(SailStyleValues.padding04),
          ),
          color: widget.selected || isHovered ? theme.colors.backgroundSecondary : widget.backgroundColor,
        ),
        child: Row(children: cellWidgets),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () {
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
    this.width,
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.symmetric(horizontal: SailStyleValues.padding12),
    this.plainIconTheme,
    this.selectedIconTheme,
    this.textColor,
    this.backgroundColor,
    this.monospace = false,
    this.italic = false,
    this.hugContent = false,
    this.fill = false,
    super.key,
  });

  final String value;
  final String? copyValue;
  final Widget? child;
  // Width override for cells whose child is wider than the value text.
  final double? width;

  /// True keeps the column at the width its widest value needs, so the free
  /// width of the table goes to the columns that can use it.
  final bool hugContent;

  /// True gives the column the width the other columns leave, also when its widest value needs more.
  final bool fill;
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
          SailText.primary13(
            value,
            color: textColor,
            monospace: monospace,
            italic: italic,
            overflow: null,
          ),
    );
  }
}

class SailTableHeaderCell extends StatelessWidget {
  const SailTableHeaderCell({
    required this.name,
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.symmetric(horizontal: SailStyleValues.padding12),
    this.onSort,
    this.sortable = true,
    this.isSorted = false,
    this.isAscending = true,
    this.filterWidget,
    super.key,
  });

  final String name;
  final Alignment alignment;
  final EdgeInsets padding;
  final VoidCallback? onSort;

  /// False when a tap on the header must not sort the table.
  final bool sortable;
  final bool isSorted;
  final bool isAscending;
  final Widget? filterWidget;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return GestureDetector(
      onTap: onSort,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: padding,
        alignment: alignment,
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: switch (alignment.x) {
                  > 0 => MainAxisAlignment.end,
                  < 0 => MainAxisAlignment.start,
                  _ => MainAxisAlignment.center,
                },
                children: [
                  Flexible(
                    child: SailText.primary13(
                      name,
                      bold: true,
                      overflow: TextOverflow.ellipsis,
                      color: theme.colors.textSecondary,
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
            ?filterWidget,
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
    // For short format, include year only if date is from a different year
    final now = DateTime.now();
    if (date.year != now.year) {
      dateFormat = use24Hour ? "MMM dd ''yy HH:mm" : "MMM dd ''yy hh:mm a";
    } else {
      dateFormat = use24Hour ? 'MMM dd HH:mm' : 'MMM dd hh:mm a';
    }
  }

  return cachedDateFormat(dateFormat, intl.Intl.getCurrentLocale()).format(date.toLocal());
}

final _dateFormats = <(String, String), intl.DateFormat>{};

/// One [intl.DateFormat] per pattern and locale, built on first use.
intl.DateFormat cachedDateFormat(String pattern, String locale) =>
    _dateFormats.putIfAbsent((pattern, locale), () => intl.DateFormat(pattern, locale));

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
