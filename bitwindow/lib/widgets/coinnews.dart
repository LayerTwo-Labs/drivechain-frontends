import 'dart:convert';
import 'dart:math';

import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/widgets/pagination.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class CoinNewsView extends StatelessWidget {
  const CoinNewsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CoinNewsViewModel>.reactive(
      viewModelBuilder: () => CoinNewsViewModel(),
      builder: (context, viewModel, child) {
        return SailCard(
          title: 'Coin News',
          titleTooltip: 'Stay up-to-date on the latest world developments',
          widgetHeaderEnd: ExtraActionsDropdown(
            title: 'Extra Coin News Actions',
            items: [
              ExtraActionItem(
                label: 'Create Topic',
                icon: SailSVGAsset.newspaper,
                onSelect: () => displayCreateTopicDialog(context),
              ),
              ExtraActionItem(
                label: 'Graffiti Explorer',
                icon: SailSVGAsset.sprayCan,
                onSelect: () => displayGraffitiExplorerDialog(context),
              ),
            ],
          ),
          child: SailRow(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: SailStyleValues.padding16,
            children: [
              Flexible(
                child: SailColumn(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 0,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SailRow(
                      spacing: SailStyleValues.padding16,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: SailTextField(
                            hintText: 'Search coin news...',
                            controller: viewModel.searchController,
                          ),
                        ),
                        SailMultiSelectDropdown(
                          selectedCountText: '${viewModel.selectedTopicIds.length} topics',
                          items: viewModel.topics
                              .map(
                                (topic) => SailDropdownItem(
                                  value: topic.topic,
                                  label: topic.name,
                                ),
                              )
                              .toList(),
                          selectedValues: viewModel.selectedTopicIds,
                          onSelected: viewModel.toggleTopic,
                          searchPlaceholder: 'Select topics..',
                        ),
                        SailButton(
                          label: 'Broadcast',
                          onPressed:
                              viewModel.selectedTopicIds.isNotEmpty ? () => displayBroadcastNewsDialog(context) : null,
                        ),
                      ],
                    ),
                    const SailSpacing(16),
                    CoinNewsTable(
                      entries: viewModel.paginatedEntries,
                      onSort: viewModel.sortEntries,
                    ),
                    const SizedBox(height: 16),
                    Pagination(
                      currentPage: viewModel.currentPage,
                      totalPages: viewModel.totalPages,
                      onPageChanged: viewModel.setPage,
                      pageSize: viewModel.pageSize,
                      pageSizeOptions: const [3, 5, 10, 20, 50],
                      onPageSizeChanged: (val) => viewModel.setPageSize(val ?? viewModel.pageSize),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CoinNewsViewModel extends BaseViewModel {
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();

  final NewsProvider _newsProvider = GetIt.I.get<NewsProvider>();
  final ClientSettings _settings = GetIt.I.get<ClientSettings>();
  final TextEditingController searchController = TextEditingController();

  // Pagination state
  int currentPage = 1;
  int pageSize = 5;

  // Sorting state
  bool _sortAscending = false;
  String _sortColumn = 'date';

  bool get loading {
    return !_newsProvider.initialized;
  }

  List<CoinNews> get entries {
    if (loading) {
      // if loading, add dummy date for the skeletonizer to render things properly
      return [
        CoinNews(
          topic: 'bitcoin',
          headline: 'Bitcoin price hits new all-time high',
          content: 'Bitcoin price hits new all-time high',
          createTime: Timestamp.fromDateTime(DateTime.now()),
        ),
        CoinNews(
          topic: 'bitcoin',
          headline: 'Bitcoin price hits new all-time high',
          content: 'Bitcoin price hits new all-time high',
          createTime: Timestamp.fromDateTime(DateTime.now()),
        ),
        CoinNews(
          topic: 'drivechain',
          headline: 'Drivechain upgrade successfully completed',
          content:
              'The long-awaited Drivechain upgrade has been successfully implemented, bringing bitcoin to the masses.',
          createTime: Timestamp.fromDateTime(DateTime.now().subtract(const Duration(hours: 2))),
        ),
        CoinNews(
          topic: 'defi',
          headline: 'New DeFi protocol launches with 100M TVL',
          content:
              'A revolutionary DeFi protocol has launched, offering innovative yield farming strategies and cross-layer (using drivechain!!) liquidity solutions.',
          createTime: Timestamp.fromDateTime(DateTime.now().subtract(const Duration(hours: 4))),
        ),
        CoinNews(
          topic: 'bitcoin',
          headline: 'Major financial institution announces Bitcoin ETF',
          content:
              'A leading financial institution has filed for a spot Bitcoin ETF, potentially opening the door for institutional investors to gain direct exposure to Bitcoin.',
          createTime: Timestamp.fromDateTime(DateTime.now().subtract(const Duration(hours: 6))),
        ),
      ];
    }

    var filteredEntries = _newsProvider.news
        .where(
          (news) =>
              _selectedTopicIds.contains(news.topic) &&
              (searchController.text.isEmpty ||
                  news.headline.toLowerCase().contains(searchController.text.toLowerCase()) ||
                  news.content.toLowerCase().contains(searchController.text.toLowerCase())),
        )
        .toList();

    // Apply sorting
    filteredEntries.sort((a, b) {
      dynamic aValue = '';
      dynamic bValue = '';

      switch (_sortColumn) {
        case 'date':
          aValue = a.createTime.toDateTime().millisecondsSinceEpoch;
          bValue = b.createTime.toDateTime().millisecondsSinceEpoch;
          break;
        case 'topic':
          aValue = a.topic;
          bValue = b.topic;
          break;
        case 'title':
          aValue = a.headline;
          bValue = b.headline;
          break;
        case 'readtime':
          aValue = expectedReadTime(a.content);
          bValue = expectedReadTime(b.content);
          break;
      }

      return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });

    return filteredEntries;
  }

  List<CoinNews> get paginatedEntries {
    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, entries.length);
    return entries.sublist(start, end);
  }

  int get totalPages => (entries.length / pageSize).ceil().clamp(1, 9999);

  void setPage(int page) {
    currentPage = page;
    notifyListeners();
  }

  void setPageSize(int size) async {
    pageSize = size;
    currentPage = 1;

    // Persist the page size
    final setting = PageSizeSetting(newValue: size);
    await _settings.setValue(setting);

    notifyListeners();
  }

  List<Topic> get topics => _newsProvider.topics;

  // Keep track of selected topic IDs
  List<String> _selectedTopicIds = [];
  List<String> get selectedTopicIds => _selectedTopicIds;

  CoinNewsViewModel() {
    _newsProvider.addListener(notifyListeners);
    _loadSelectedTopics();
    _loadPageSize();
    searchController.addListener(notifyListeners);
  }

  Future<void> _loadSelectedTopics() async {
    final setting = SelectedTopicsSetting();
    final loadedSetting = await _settings.getValue(setting);

    if (loadedSetting.value.isEmpty && topics.isNotEmpty) {
      // Initialize with all topics if nothing is saved
      _selectedTopicIds = topics.map((topic) => topic.topic).toList();
    } else {
      _selectedTopicIds = loadedSetting.value;
    }
    notifyListeners();
  }

  Future<void> _loadPageSize() async {
    final setting = PageSizeSetting();
    final loadedSetting = await _settings.getValue(setting);
    pageSize = loadedSetting.value;
    notifyListeners();
  }

  Future<void> setSelectedTopics(List<String> topicIds) async {
    _selectedTopicIds = topicIds;

    // Persist the selection
    final setting = SelectedTopicsSetting(newValue: topicIds);
    await _settings.setValue(setting);

    notifyListeners();
  }

  Future<void> toggleTopic(String topicId) async {
    final newSelection = List<String>.from(_selectedTopicIds);
    if (newSelection.contains(topicId)) {
      newSelection.remove(topicId);
    } else {
      newSelection.add(topicId);
    }
    await setSelectedTopics(newSelection);
  }

  void sortEntries(String column) {
    if (_sortColumn == column) {
      _sortAscending = !_sortAscending;
    } else {
      _sortColumn = column;
      // Default to descending for date column, ascending for others
      _sortAscending = column != 'date';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.removeListener(notifyListeners);
    searchController.dispose();
    super.dispose();
  }
}

// Settings class stays as a List<String>
class SelectedTopicsSetting extends SettingValue<List<String>> {
  @override
  String get key => 'selected_topics';

  SelectedTopicsSetting({super.newValue});

  @override
  List<String> defaultValue() => [];

  @override
  List<String>? fromJson(String jsonString) {
    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.cast<String>();
    } catch (e) {
      return null;
    }
  }

  @override
  String toJson() {
    return json.encode(value);
  }

  @override
  SettingValue<List<String>> withValue([List<String>? value]) {
    return SelectedTopicsSetting(newValue: value);
  }
}

class PageSizeSetting extends SettingValue<int> {
  @override
  String get key => 'coin_news_page_size';

  PageSizeSetting({super.newValue});

  @override
  int defaultValue() => 3; // Default to 3 items per page

  @override
  int? fromJson(String jsonString) {
    try {
      return int.parse(jsonString);
    } catch (e) {
      return null;
    }
  }

  @override
  String toJson() {
    return value.toString();
  }

  @override
  SettingValue<int> withValue([int? value]) {
    return PageSizeSetting(newValue: value);
  }
}

class CoinNewsEntry extends StatefulWidget {
  final CoinNews entry;
  final List<Topic> allTopics;

  const CoinNewsEntry({
    required this.entry,
    required this.allTopics,
    super.key,
  });

  @override
  State<CoinNewsEntry> createState() => _CoinNewsEntryState();
}

class _CoinNewsEntryState extends State<CoinNewsEntry> {
  bool isHovered = false;

  String _getInitials(String topic) {
    final matchingTopic = widget.allTopics.firstWhere((t) => t.topic == topic);
    final words = matchingTopic.name.split(' ');
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return words[0].substring(0, min(2, words[0].length)).toUpperCase();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }

    final months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
    return '${date.day}.${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () {
          final article = Article(
            title: widget.entry.headline,
            markdown: widget.entry.content,
            filename: '',
          );
          showArticleDetails(context, article, 'Coin News');
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovered ? context.sailTheme.colors.backgroundSecondary : Colors.transparent,
            borderRadius: SailStyleValues.borderRadius,
          ),
          child: SailRow(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: SailStyleValues.padding16,
            children: [
              SailColumn(
                spacing: SailStyleValues.padding04,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.sailTheme.colors.backgroundSecondary,
                    ),
                    child: Center(
                      child: SailText.primary12(
                        _getInitials(widget.entry.topic),
                        color: context.sailTheme.colors.textSecondary,
                      ),
                    ),
                  ),
                  Center(
                    child: SailText.secondary12(
                      _formatDate(widget.entry.createTime.toDateTime()),
                      color: context.sailTheme.colors.textTertiary,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SailColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: SailStyleValues.padding04,
                  children: [
                    SailText.primary15(
                      widget.entry.headline,
                      bold: true,
                    ),
                    SailText.secondary12(
                      widget.entry.content.replaceAll('\n', ' '),
                      color: context.sailTheme.colors.textSecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CoinNewsTable extends ViewModelWidget<CoinNewsViewModel> {
  final List<CoinNews> entries;
  final Function(String) onSort;

  const CoinNewsTable({
    super.key,
    required this.entries,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context, CoinNewsViewModel viewModel) {
    return SailSkeletonizer(
      description: 'Waiting for backend to boot and load coin news..',
      enabled: viewModel.loading,
      duration: const Duration(seconds: 3),
      child: SailTable(
        shrinkWrap: true,
        getRowId: (index) => index.toString(),
        headerBuilder: (context) => [
          const SailTableHeaderCell(name: 'Date'),
          const SailTableHeaderCell(name: 'Topic'),
          const SailTableHeaderCell(name: 'Title'),
          const SailTableHeaderCell(name: 'Read time'),
        ],
        rowBuilder: (context, row, selected) {
          final entry = entries[row];
          final matchingTopic = viewModel.topics.firstWhereOrNull((t) => t.topic == entry.topic);

          return [
            SailTableCell(value: formatDate(entry.createTime.toDateTime())),
            SailTableCell(value: matchingTopic?.name ?? entry.topic),
            SailTableCell(value: entry.headline),
            SailTableCell(value: expectedReadTime(entry.content)),
          ];
        },
        rowCount: entries.length,
        drawGrid: true,
        onSort: (columnIndex, ascending) {
          onSort(['date', 'topic', 'title', 'readtime'][columnIndex]);
        },
        onDoubleTap: (rowId) {
          final news = entries[int.parse(rowId)];

          final article = Article(
            title: news.headline,
            markdown: news.content,
            filename: '',
          );

          showArticleDetails(context, article, 'Coin News');
        },
        contextMenuItems: (rowId) {
          return [
            SailMenuItem(
              onSelected: () {
                final news = entries[int.parse(rowId)];

                final article = Article(
                  title: news.headline,
                  markdown: news.content,
                  filename: '',
                );

                showArticleDetails(context, article, 'Coin News');
              },
              child: SailText.primary12('Show Details'),
            ),
          ];
        },
      ),
    );
  }
}
