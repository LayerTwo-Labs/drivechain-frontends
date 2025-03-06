import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String? _selectedId;
  double get _totalColumnWidths => _widths.fold(0, (prev, e) => prev + e);

  final _widths = <double>[];

  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedRowId;
    _sortColumnIndex = widget.sortColumnIndex;
    _sortAscending = widget.sortAscending ?? true;
    _widths.addAll(widget.columnWidths);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final parentWidth = context.size?.width ?? double.infinity;
        if (parentWidth.isFinite) {
          _resizeColumns(parentWidth, widget.columnWidths);
        }
      });
    });

    _verticalController.addListener(_checkScrollPosition);
  }

  @override
  void dispose() {
    super.dispose();
    _horizontalController.dispose();
    _verticalController.dispose();
  }

  void _resizeColumns(double parentWidth, List<double> columnWidths) {
    final totalWidth = columnWidths.fold(0.0, (sum, width) => sum + width);
    if (totalWidth > parentWidth) {
      _scaleColumnsToFit(parentWidth, columnWidths, totalWidth);
    } else if (totalWidth < parentWidth) {
      _expandColumnsToFill(parentWidth, columnWidths);
    } else {
      _widths.clear();
      _widths.addAll(columnWidths);
    }
  }

  void _scaleColumnsToFit(double parentWidth, List<double> columnWidths, double totalWidth) {
    final scaleFactor = (parentWidth.floorToDouble()) / totalWidth; // Floor the parent width
    _widths.clear();
    double currentTotal = 0;

    // Handle all columns except the last one
    for (var i = 0; i < columnWidths.length - 1; i++) {
      final scaledWidth = (columnWidths[i] * scaleFactor).floorToDouble();
      var width = scaledWidth < columnWidths[i] ? columnWidths[i] : scaledWidth;
      if (width < 0) {
        width = 0;
      }
      _widths.add(width);
      currentTotal += width;
    }

    // Give remaining width to last column
    final lastWidth = parentWidth - currentTotal;
    _widths.add(lastWidth);
  }

  void _expandColumnsToFill(double parentWidth, List<double> columnWidths) {
    final totalWidth = columnWidths.fold(0.0, (sum, width) => sum + width);
    final scaleFactor = (parentWidth.floorToDouble()) / totalWidth;
    _widths.clear();
    double currentTotal = 0;

    // Handle all columns except the last one
    for (var i = 0; i < columnWidths.length - 1; i++) {
      final scaledWidth = (columnWidths[i] * scaleFactor).floorToDouble();
      _widths.add(scaledWidth);
      currentTotal += scaledWidth;
    }

    // Give remaining width to last column
    final lastWidth = parentWidth - currentTotal;
    _widths.add(lastWidth);
  }

  void _checkScrollPosition() {
    if (widget.onScrollApproachingEnd == null) {
      return;
    }

    if (_verticalController.position.extentAfter < 100) {
      widget.onScrollApproachingEnd!();
    }
  }

  void _sort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    widget.onSort?.call(columnIndex, ascending);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    var themeAltColor = theme.colors.background;
    var altBgColor = widget.altBackgroundColor ?? themeAltColor;

    var isWindows = context.isWindows;

    return LayoutBuilder(
      builder: (context, constraints) {
        print('DEBUG: Table constraints - maxWidth: ${constraints.maxWidth}, minWidth: ${constraints.minWidth}');
        Widget innerListView;

        if (widget.shrinkWrap) {
          var children = <Widget>[];
          for (int i = 0; i < widget.rowCount; i++) {
            final rowId = widget.getRowId(i);
            final isSelected = rowId == _selectedId;
            var backgroundColor = i % 2 == 1 ? altBgColor : null;
            var isLastRow = i == widget.rowCount - 1;
            children.add(
              _TableRow(
                cells: widget.rowBuilder(context, i, isSelected),
                widths: _widths,
                height: widget.cellHeight,
                selected: isSelected,
                backgroundColor: isWindows || widget.drawGrid ? null : backgroundColor,
                grid: widget.drawGrid,
                drawBorder: (widget.drawLastRowsBorder && isLastRow) || !isLastRow,
                onPressed: () {
                  if (widget.selectableRows) {
                    setState(() {
                      _selectedId = _selectedId == rowId ? null : rowId;
                    });
                    widget.onSelectedRow?.call(_selectedId);
                  }
                },
                onDoubleTap: widget.onDoubleTap == null ? null : () => widget.onDoubleTap!(rowId),
                contextMenuItems: widget.contextMenuItems,
                rowId: rowId,
              ),
            );
          }

          innerListView = Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          );
        } else {
          innerListView = ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: isWindows || widget.drawGrid ? 0 : 6,
            ),
            shrinkWrap: widget.shrinkWrap,
            physics: widget.physics,
            itemCount: widget.rowCount,
            controller: _verticalController,
            prototypeItem: SizedBox(
              height: widget.cellHeight,
            ),
            itemBuilder: (context, row) {
              final rowId = widget.getRowId(row);
              final isSelected = rowId == _selectedId;
              var backgroundColor = row % 2 == 1 ? altBgColor : null;
              var isLastRow = row == widget.rowCount - 1;
              return _TableRow(
                cells: widget.rowBuilder(context, row, isSelected),
                widths: _widths,
                height: widget.cellHeight,
                selected: isSelected,
                backgroundColor: isWindows || widget.drawGrid ? null : backgroundColor,
                grid: widget.drawGrid,
                drawBorder: (widget.drawLastRowsBorder && isLastRow) || !isLastRow,
                onPressed: () {
                  if (widget.selectableRows) {
                    setState(() {
                      _selectedId = _selectedId == rowId ? null : rowId;
                    });
                    widget.onSelectedRow?.call(_selectedId);
                  }
                },
                onDoubleTap: widget.onDoubleTap == null ? null : () => widget.onDoubleTap!(rowId),
                contextMenuItems: widget.contextMenuItems,
                rowId: rowId,
              );
            },
          );
        }

        // Update the header builder to include sort indicators and functionality
        List<Widget> header = widget.headerBuilder(context).asMap().entries.map((entry) {
          int i = entry.key;
          Widget headerCell = entry.value;

          if (headerCell is SailTableHeaderCell) {
            return SailTableHeaderCell(
              alignment: headerCell.alignment,
              padding: headerCell.padding,
              isSorted: _sortColumnIndex == i,
              isAscending: _sortAscending,
              onSort: () => _sort(i, _sortColumnIndex != i || !_sortAscending),
              name: headerCell.name,
            );
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _sort(i, _sortColumnIndex != i || !_sortAscending),
            child: headerCell,
          );
        }).toList();

        double tableWidth = constraints.maxWidth != double.infinity ? constraints.maxWidth : _totalColumnWidths;

        return Scrollbar(
          controller: _horizontalController,
          scrollbarOrientation: ScrollbarOrientation.bottom,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _TableHeader(
                    widths: _widths,
                    decoration: widget.headerDecoration ??
                        BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: theme.colors.divider, width: 1),
                          ),
                          color: theme.colors.backgroundSecondary,
                        ),
                    cells: header,
                    grid: widget.drawGrid,
                    resizableColumns: widget.resizableColumns,
                    onStartResizeColumn: _onStartResizeColumn,
                    onEndResizeColumn: _onEndResizeColumn,
                    onResizedColumn: _onResizedColumn,
                  ),
                  if (!widget.shrinkWrap)
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(),
                        child: innerListView,
                      ),
                    ),
                  if (widget.shrinkWrap) innerListView,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant SailTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollPosition();
    });
  }

  double _startColumnWidth = 0;

  void _onStartResizeColumn(int column) {
    _startColumnWidth = _widths[column];
  }

  void _onEndResizeColumn(int column) {
    if (widget.onColumnWidthsChanged != null) {
      widget.onColumnWidthsChanged!(_widths);
    }
  }

  void _onResizedColumn(int column, double delta) {
    if (!widget.resizableColumns) {
      return;
    }

    var minWidth = widget.columnMinWidths?.elementAt(column) ?? widget.defaultMinColumnWidth;

    setState(() {
      var width = _startColumnWidth + delta;
      if (width < minWidth) {
        width = minWidth;
      }
      _widths[column] = width;
    });
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({
    required this.cells,
    required this.widths,
    required this.decoration,
    required this.grid,
    required this.resizableColumns,
    required this.onResizedColumn,
    required this.onStartResizeColumn,
    required this.onEndResizeColumn,
  });

  final List<Widget> cells;
  final List<double> widths;
  final BoxDecoration? decoration;
  final bool grid;
  final bool resizableColumns;
  final void Function(int column, double delta) onResizedColumn;
  final void Function(int column) onStartResizeColumn;
  final void Function(int column) onEndResizeColumn;

  @override
  Widget build(BuildContext context) {
    _TableColumnResizeHandleStyle handleStyle;
    if (grid) {
      handleStyle = _TableColumnResizeHandleStyle.full;
    } else if (!resizableColumns) {
      handleStyle = _TableColumnResizeHandleStyle.none;
    } else if (context.isWindows) {
      handleStyle = _TableColumnResizeHandleStyle.full;
    } else {
      handleStyle = _TableColumnResizeHandleStyle.partial;
    }

    var cellWidgets = <Widget>[];
    int i = 0;
    for (var cell in cells) {
      var index = i;
      var width = widths[i];
      if (i == 0) {
        width -= _TableColumnResizeHandle._width / 2;
      } else {
        width -= _TableColumnResizeHandle._width;
      }

      cellWidgets.add(
        SizedBox(
          width: width,
          child: cell,
        ),
      );

      cellWidgets.add(
        _TableColumnResizeHandle(
          style: handleStyle,
          last: i == cells.length - 1,
          onDragStart: () {
            onStartResizeColumn(index);
          },
          onDragEnd: () {
            onEndResizeColumn(index);
          },
          onDragUpdate: (delta) {
            onResizedColumn(index, delta);
          },
        ),
      );

      i += 1;
    }

    return Container(
      height: 48,
      decoration: decoration,
      padding: EdgeInsets.symmetric(
        vertical: SailStyleValues.padding12,
      ),
      child: Row(
        children: cellWidgets,
      ),
    );
  }
}

enum _TableColumnResizeHandleStyle {
  none,
  full,
  partial,
}

class _TableColumnResizeHandle extends StatefulWidget {
  const _TableColumnResizeHandle({
    required this.onDragUpdate,
    required this.onDragStart,
    required this.onDragEnd,
    required this.last,
    required this.style,
  });

  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  final bool last;
  final _TableColumnResizeHandleStyle style;

  static const _width = 8.0;

  @override
  _TableColumnResizeHandleState createState() => _TableColumnResizeHandleState();
}

class _TableColumnResizeHandleState extends State<_TableColumnResizeHandle> {
  double _downX = 0.0;

  @override
  Widget build(BuildContext context) {
    var verticalGap = widget.style == _TableColumnResizeHandleStyle.partial ? 2.0 : 0.0;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (details) {
          _downX = details.globalPosition.dx;
          widget.onDragStart();
        },
        onHorizontalDragEnd: (details) {
          widget.onDragEnd();
        },
        onHorizontalDragUpdate: (details) {
          var globalDelta = details.globalPosition.dx - _downX;
          widget.onDragUpdate(globalDelta);
        },
        child: SizedBox(
          width: widget.last ? _TableColumnResizeHandle._width / 2 : _TableColumnResizeHandle._width,
          child: Container(
            margin: EdgeInsets.only(
              left: _TableColumnResizeHandle._width / 2 - 1,
              top: verticalGap,
              bottom: verticalGap,
            ),
            decoration: BoxDecoration(
              border: widget.style == _TableColumnResizeHandleStyle.none
                  ? null
                  : Border(
                      left: BorderSide(
                        color: context.sailTheme.colors.divider,
                        width: 1.0,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
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

  void _showContextMenu(BuildContext context, Offset position, String value, String rowId) {
    showSailMenu(
      context: context,
      preferredAnchorPoint: position,
      menu: SailMenu(
        items: [
          SailMenuItem(
            onSelected: () {
              Clipboard.setData(ClipboardData(text: value));
              Navigator.of(context).pop();
            },
            child: SailText.primary12('Copy value'),
          ),
          // Add custom menu items if provided
          if (contextMenuItems != null)
            ...contextMenuItems!(rowId).map(
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
    for (var cell in cells) {
      final String? cellValue = cell is SailTableCell ? cell.value : null;

      cellWidgets.add(
        SizedBox(
          width: widths[i],
          height: height,
          child: MouseRegion(
            cursor: cellValue != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onSecondaryTapDown: cellValue != null
                  ? (details) => _showContextMenu(context, details.globalPosition, cellValue, rowId)
                  : null,
              child: Container(
                decoration: grid
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
                child: DefaultTextStyle(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : null,
                  ),
                  child: cell,
                ),
              ),
            ),
          ),
        ),
      );
      i += 1;
    }

    Widget contents;

    if (isWindows || grid) {
      contents = DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? theme.colors.primary : backgroundColor,
          border: drawBorder
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
      contents = Container(
        margin: EdgeInsets.symmetric(),
        padding: EdgeInsets.symmetric(),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(SailStyleValues.padding04)),
          color: selected ? theme.colors.primary : backgroundColor,
        ),
        child: Row(
          children: cellWidgets,
        ),
      );
    }

    return GestureDetector(
      onLongPressDown: (_) {
        onPressed();
      },
      onDoubleTapDown: onDoubleTap == null
          ? null
          : (_) {
              onDoubleTap!();
            },
      behavior: HitTestBehavior.translucent,
      child: contents,
    );
  }
}

class SailTableCell extends StatelessWidget {
  const SailTableCell({
    required this.value,
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
  final Widget? child;
  final Alignment alignment;
  final EdgeInsets padding;
  final IconThemeData? plainIconTheme;
  final IconThemeData? selectedIconTheme;
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

    final theme = SailTheme.of(context);
    IconThemeData iconTheme;
    if (tableRow!.selected) {
      iconTheme = selectedIconTheme ??
          IconThemeData(
            color: theme.colors.iconHighlighted,
          );
    } else {
      iconTheme = plainIconTheme ??
          IconThemeData(
            color: theme.colors.icon,
          );
    }

    return Container(
      alignment: alignment,
      padding: padding,
      child: IconTheme(
        data: iconTheme,
        child: child ??
            SailText.primary12(
              value,
              color: textColor,
              monospace: monospace,
              italic: italic,
            ),
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
        alignment: alignment,
        padding: padding,
        child: SailRow(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: SailStyleValues.padding04,
          children: [
            SailText.primary15(
              name,
              bold: true,
              color: theme.colors.textSecondary.withValues(alpha: 0.7),
            ),
            if (isSorted)
              Icon(
                isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 13,
                color: SailTheme.of(context).colors.icon,
              ),
          ],
        ),
      ),
    );
  }
}
