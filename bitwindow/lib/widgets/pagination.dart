import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int?>? onPageSizeChanged;

  const Pagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.pageSize = 5,
    this.pageSizeOptions = const [5, 10, 20, 50],
    this.onPageSizeChanged,
  });

  List<int> _visiblePages() {
    // Always show first, last, current, and 1 before/after current
    final pages = <int>{1, totalPages, currentPage};
    if (currentPage > 1) pages.add(currentPage - 1);
    if (currentPage < totalPages) pages.add(currentPage + 1);
    // Add 2 before/after for more context if possible
    if (currentPage - 2 > 1) pages.add(currentPage - 2);
    if (currentPage + 2 < totalPages) pages.add(currentPage + 2);
    final sorted = pages.toList()..sort();
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final visiblePages = _visiblePages();
    return SailRow(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 0,
      children: [
        SailButton(
          label: 'Previous',
          variant: ButtonVariant.ghost,
          onPressed: currentPage > 1 ? () async => onPageChanged(currentPage - 1) : null,
          icon: SailSVGAsset.chevronLeft,
          iconHeight: 8,
          small: true,
        ),
        SailSpacing(SailStyleValues.padding16),
        ..._buildPageButtons(context, visiblePages),
        SailSpacing(SailStyleValues.padding16),
        SailButton(
          label: 'Next',
          variant: ButtonVariant.ghost,
          onPressed: currentPage < totalPages ? () async => onPageChanged(currentPage + 1) : null,
          endIcon: SailSVGAsset.chevronRight,
          iconHeight: 8,
          small: true,
        ),
        SailSpacing(SailStyleValues.padding16),
        if (onPageSizeChanged != null)
          SailDropdownButton<int>(
            value: pageSize,
            items: pageSizeOptions.map((size) => SailDropdownItem<int>(value: size, label: '$size / page')).toList(),
            onChanged: (val) => onPageSizeChanged!(val ?? pageSize),
            hint: 'Rows',
          ),
      ],
    );
  }

  List<Widget> _buildPageButtons(BuildContext context, List<int> visiblePages) {
    final widgets = <Widget>[];
    int? last;
    for (final page in visiblePages) {
      if (last != null && page - last > 1) {
        widgets.add(SailText.primary10('...'));
      }
      widgets.add(
        SailButton(
          small: true,
          variant: ButtonVariant.outline,
          onPressed: page == currentPage ? null : () async => onPageChanged(page),
          label: '$page',
        ),
      );
      last = page;
    }
    return widgets;
  }
}
