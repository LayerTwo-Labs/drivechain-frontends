import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

const _headerHeight = 24.0;

class SailTable extends StatefulWidget {
  const SailTable({
    required this.headerBuilder,
    required this.rowBuilder,
    required this.rowCount,
    required this.columnCount,
    required this.columnWidths,
    this.columnMinWidths,
    this.columnMaxWidths,
    this.defaultMinColumnWidth = 50,
    this.defaultMaxColumnWidth = 200,
    this.backgroundColor,
    this.altBackgroundColor,
    this.headerDecoration,
    this.selectedRow,
    this.selectableRows = true,
    this.onSelectedRow,
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
    super.key,
  });

  final List<Widget> Function(BuildContext context) headerBuilder;
  final List<Widget> Function(BuildContext context, int row, bool selected) rowBuilder;
  final List<double> columnWidths;
  final List<double>? columnMinWidths;
  final List<double>? columnMaxWidths;
  final double defaultMinColumnWidth;
  final double defaultMaxColumnWidth;
  final int rowCount;
  final int columnCount;
  final Color? backgroundColor;
  final Color? altBackgroundColor;
  final BoxDecoration? headerDecoration;
  final int? selectedRow;
  final bool selectableRows;
  final ValueChanged<int?>? onSelectedRow;
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

  @override
  State<SailTable> createState() => _SailTableState();
}

class _SailTableState extends State<SailTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  int? _selectedRow;
  double get _totalColumnWidths => _widths.fold(0, (prev, e) => prev + e);

  final _widths = <double>[];

  int? _sortColumnIndex;
  bool _sortAscending = true;

  double _horizontalRowPadding(BuildContext context) {
    return context.isWindows || widget.drawGrid ? 0.0 : 8.0;
  }

  @override
  void initState() {
    super.initState();
    _selectedRow = widget.selectedRow;
    _sortColumnIndex = widget.sortColumnIndex;
    _sortAscending = widget.sortAscending ?? true;
    for (var width in widget.columnWidths) {
      _widths.add(width);
    }

    _verticalController.addListener(_checkScrollPosition);
  }

  @override
  void dispose() {
    super.dispose();
    _horizontalController.dispose();
    _verticalController.dispose();
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
    var horizontalRowPadding = _horizontalRowPadding(context);

    return Container(
      color: theme.colors.backgroundSecondary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double totalColumnSpace = constraints.maxWidth - horizontalRowPadding * 2;
          bool hasHorizontalOverflow = _totalColumnWidths > totalColumnSpace;

          double extraSpace = 0;
          if (!hasHorizontalOverflow) {
            extraSpace = totalColumnSpace - _totalColumnWidths;
          }

          Widget innerListView;

          if (widget.shrinkWrap) {
            var children = <Widget>[];
            for (int i = 0; i < widget.rowCount; i++) {
              var backgroundColor = i % 2 == 1 ? altBgColor : null;
              var isLastRow = i == widget.rowCount - 1;
              children.add(
                _TableRow(
                  cells: widget.rowBuilder(context, i, _selectedRow == i),
                  widths: _widths,
                  height: widget.cellHeight,
                  selected: _selectedRow == i,
                  backgroundColor: isWindows || widget.drawGrid ? null : backgroundColor,
                  hasHorizontalOverflow: hasHorizontalOverflow,
                  horizontalRowPadding: horizontalRowPadding,
                  grid: widget.drawGrid,
                  extraSpace: extraSpace,
                  drawBorder: (widget.drawLastRowsBorder && isLastRow) || !isLastRow,
                  onPressed: () {
                    if (widget.selectableRows) {
                      setState(() {
                        _selectedRow = i;
                      });
                      if (widget.onSelectedRow != null) {
                        widget.onSelectedRow!(i);
                      }
                    }
                  },
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
                width: hasHorizontalOverflow ? _totalColumnWidths + horizontalRowPadding * 2 : constraints.maxWidth,
                height: widget.cellHeight,
              ),
              itemBuilder: (context, row) {
                var backgroundColor = row % 2 == 1 ? altBgColor : null;
                var isLastRow = row == widget.rowCount - 1;
                return _TableRow(
                  cells: widget.rowBuilder(context, row, false),
                  widths: _widths,
                  height: widget.cellHeight,
                  selected: _selectedRow == row,
                  backgroundColor: isWindows || widget.drawGrid ? null : backgroundColor,
                  hasHorizontalOverflow: hasHorizontalOverflow,
                  horizontalRowPadding: horizontalRowPadding,
                  grid: widget.drawGrid,
                  extraSpace: extraSpace,
                  drawBorder: (widget.drawLastRowsBorder && isLastRow) || !isLastRow,
                  onPressed: () {
                    if (widget.selectableRows) {
                      setState(() {
                        _selectedRow = row;
                      });
                      if (widget.onSelectedRow != null) {
                        widget.onSelectedRow!(row);
                      }
                    }
                  },
                );
              },
            );
          }

          // Update the header builder to include sort indicators and functionality
          List<Widget> header = widget.headerBuilder(context);
          for (int i = 0; i < header.length; i++) {
            header[i] = GestureDetector(
              onTap: () => _sort(i, _sortColumnIndex != i || !_sortAscending),
              child: header[i],
            );
          }

          return Scrollbar(
            controller: _horizontalController,
            scrollbarOrientation: ScrollbarOrientation.bottom,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: hasHorizontalOverflow ? _totalColumnWidths + horizontalRowPadding * 2 : constraints.maxWidth,
                child: Column(
                  children: [
                    _TableHeader(
                      widths: _widths,
                      decoration: widget.headerDecoration ??
                          BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: theme.colors.divider, width: 1),
                            ),
                            color: theme.colors.background,
                          ),
                      cells: header,
                      grid: widget.drawGrid,
                      resizableColumns: widget.resizableColumns,
                      horizontalRowPadding: horizontalRowPadding,
                      extraSpace: extraSpace,
                      onStartResizeColumn: _onStartResizeColumn,
                      onEndResizeColumn: _onEndResizeColumn,
                      onResizedColumn: _onResizedColumn,
                    ),
                    if (!widget.shrinkWrap)
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            scrollbars: !hasHorizontalOverflow,
                          ),
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
      ),
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
    var maxWidth = widget.columnMaxWidths?.elementAt(column) ?? widget.defaultMaxColumnWidth;

    setState(() {
      var width = _startColumnWidth + delta;
      if (width < minWidth) {
        width = minWidth;
      } else if (width > maxWidth) {
        width = maxWidth;
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
    required this.extraSpace,
    required this.onResizedColumn,
    required this.onStartResizeColumn,
    required this.onEndResizeColumn,
    required this.horizontalRowPadding,
  });

  final List<Widget> cells;
  final List<double> widths;
  final BoxDecoration? decoration;
  final bool grid;
  final bool resizableColumns;
  final double extraSpace;
  final double horizontalRowPadding;
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
          child: DefaultTextStyle(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SailStyleValues.ten,
            child: cell,
          ),
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
      decoration: decoration ??
          BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: context.sailTheme.colors.divider,
                width: 1.0,
              ),
            ),
            color: context.sailTheme.colors.background,
          ),
      height: _headerHeight,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalRowPadding,
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
    required this.hasHorizontalOverflow,
    required this.widths,
    required this.height,
    required this.grid,
    required this.extraSpace,
    required this.horizontalRowPadding,
    required this.drawBorder,
    this.backgroundColor,
  });

  final List<Widget> cells;
  final VoidCallback onPressed;
  final bool selected;
  final bool hasHorizontalOverflow;
  final Color? backgroundColor;
  final List<double> widths;
  final double height;
  final bool grid;
  final double extraSpace;
  final double horizontalRowPadding;
  final bool drawBorder;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    var isWindows = context.isWindows;

    var cellWidgets = <Widget>[];
    int i = 0;
    for (var cell in cells) {
      cellWidgets.add(
        Container(
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
          width: widths[i],
          height: height,
          child: DefaultTextStyle(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? Colors.white : null,
            ),
            child: cell,
          ),
        ),
      );
      i += 1;
    }

    if (extraSpace > 0) {
      cellWidgets.add(
        SizedBox(
          width: extraSpace,
          height: height,
        ),
      );
    }

    Widget contents;

    if (isWindows || grid) {
      contents = Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalRowPadding,
        ),
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
        margin: EdgeInsets.symmetric(
          horizontal: hasHorizontalOverflow ? 0.0 : horizontalRowPadding,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: hasHorizontalOverflow ? horizontalRowPadding : 0.0,
        ),
        decoration: BoxDecoration(
          borderRadius:
              hasHorizontalOverflow ? null : const BorderRadius.all(Radius.circular(SailStyleValues.padding05)),
          color: selected ? theme.colors.primary : backgroundColor,
        ),
        child: Row(
          children: cellWidgets,
        ),
      );
    }

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: contents,
    );
  }
}

class SailTableCell extends StatelessWidget {
  const SailTableCell({
    required this.child,
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.plainIconTheme,
    this.selectedIconTheme,
    super.key,
  });

  final Widget child;
  final Alignment alignment;
  final EdgeInsets padding;
  final IconThemeData? plainIconTheme;
  final IconThemeData? selectedIconTheme;

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
        child: child,
      ),
    );
  }
}

class SailTableHeaderCell extends StatelessWidget {
  const SailTableHeaderCell({
    required this.child,
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.onSort,
    super.key,
  });

  final Widget child;
  final Alignment alignment;
  final EdgeInsets padding;
  final VoidCallback? onSort;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSort,
      child: Container(
        alignment: alignment,
        padding: padding,
        child: child,
      ),
    );
  }
}
