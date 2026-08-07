import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/utils/explorer_url.dart';
import 'package:bitwindow/widgets/news_cost.dart';
import 'package:bitwindow/widgets/pagination.dart';
import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:protobuf/protobuf.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class CoinNewsView extends ViewModelWidget<CoinNewsViewModel> {
  const CoinNewsView({
    super.key,
  });

  @override
  Widget build(BuildContext context, CoinNewsViewModel viewModel) {
    return SailCard(
      title: 'Coin News',
      titleTooltip: 'Stay up-to-date on the latest world developments',
      widgetHeaderEnd: ExtraActionsDropdown(
        title: 'Extra Coin News Actions',
        items: [
          ExtraActionItem(
            label: 'Manage Topics',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: SailStyleValues.padding16,
        children: [
          Flexible(
            child: SailColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                              label: topic.confirmed ? topic.name : '${topic.name} (pending)',
                            ),
                          )
                          .toList(),
                      selectedValues: viewModel.selectedTopicIds,
                      onSelected: viewModel.toggleTopic,
                      searchPlaceholder: 'Select topics..',
                    ),
                    SailButton(
                      label: 'Broadcast',
                      onPressed: viewModel.selectedTopicIds.isNotEmpty
                          ? () => displayBroadcastNewsDialog(context)
                          : null,
                    ),
                  ],
                ),
                const SailSpacing(16),
                CoinNewsTable(
                  entries: viewModel.paginatedEntries,
                  onSort: viewModel.sortEntries,
                  loading: viewModel.loading,
                  allTopics: viewModel.topics,
                  onArticleSelected: (news) => showCoinNewsArticle(context, news),
                  onUpvote: viewModel.upvote,
                  onDownvote: viewModel.downvote,
                ),
                const SizedBox(height: 16),
                Pagination(
                  currentPage: viewModel.currentPage,
                  totalPages: viewModel.totalPages,
                  onPageChanged: viewModel.setPage,
                  pageSize: viewModel.pageSize,
                  pageSizeOptions: const [3, 5, 10, 20],
                  onPageSizeChanged: (val) => viewModel.setPageSize(val ?? viewModel.pageSize),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Height that fits four whole story rows per column.
const double _largeWidgetHeight = 387;

class CoinNewsLargeView extends ViewModelWidget<CoinNewsLargeViewModel> {
  const CoinNewsLargeView({
    super.key,
  });

  @override
  Widget build(BuildContext context, CoinNewsLargeViewModel viewModel) {
    return SizedBox(
      height: _largeWidgetHeight,
      child: SailRow(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SailStyleValues.padding16,
        children: [
          Expanded(
            child: _LargeColumn(
              topic: viewModel.leftTopic,
              onTopicChanged: viewModel.setLeftTopic,
              entries: viewModel.entriesFor(viewModel.leftTopic),
              outdatedCount: viewModel.outdatedCountFor(viewModel.leftTopic),
              viewModel: viewModel,
            ),
          ),
          Expanded(
            child: _LargeColumn(
              topic: viewModel.rightTopic,
              onTopicChanged: viewModel.setRightTopic,
              entries: viewModel.entriesFor(viewModel.rightTopic),
              outdatedCount: viewModel.outdatedCountFor(viewModel.rightTopic),
              viewModel: viewModel,
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeColumn extends StatelessWidget {
  final String topic;
  final void Function(String?) onTopicChanged;
  final List<CoinNews> entries;
  final int outdatedCount;
  final CoinNewsLargeViewModel viewModel;

  const _LargeColumn({
    required this.topic,
    required this.onTopicChanged,
    required this.entries,
    required this.outdatedCount,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return SailCard(
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailRow(
            children: [
              SailText.primary15('Coin News', bold: true),
              Expanded(child: Container()),
              SailDropdownButton<String>(
                items: viewModel.topics
                    .map(
                      (t) => SailDropdownItem<String>(
                        value: t.topic,
                        label: t.confirmed ? t.name : '${t.name} (pending)',
                      ),
                    )
                    .toList(),
                onChanged: onTopicChanged,
                value: topic,
              ),
            ],
          ),
          Expanded(child: _body(context)),
          if (outdatedCount > 0 || viewModel.showOutdated) _outdatedLink(context),
        ],
      ),
    );
  }

  Widget _outdatedLink(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SailButton(
        label: viewModel.showOutdated ? 'Hide Outdated' : 'Show Outdated',
        variant: ButtonVariant.link,
        small: true,
        onPressed: () async => viewModel.toggleOutdated(),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (viewModel.loading) {
      return Center(child: SailText.secondary12('Loading…'));
    }
    if (entries.isEmpty) {
      return Center(
        child: SailColumn(
          spacing: SailStyleValues.padding04,
          mainAxisSize: MainAxisSize.min,
          children: [
            SailText.primary15('Nothing here yet', bold: true),
            SailText.secondary12('Broadcast a story to start the feed.'),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: entries.length,
      itemBuilder: (context, i) => _LargeStoryRow(
        entry: entries[i],
        allTopics: viewModel.topics,
        outdated: viewModel.isOutdated(entries[i]),
        onUpvote: () => viewModel.upvote(entries[i]),
        onDownvote: () => viewModel.downvote(entries[i]),
      ),
    );
  }
}

/// One ranked story: votes in a gutter, headline, then its origin.
class _LargeStoryRow extends StatefulWidget {
  final CoinNews entry;
  final List<Topic> allTopics;
  final bool outdated;
  final Future<void> Function() onUpvote;
  final Future<void> Function() onDownvote;

  const _LargeStoryRow({
    required this.entry,
    required this.allTopics,
    required this.outdated,
    required this.onUpvote,
    required this.onDownvote,
  });

  @override
  State<_LargeStoryRow> createState() => _LargeStoryRowState();
}

class _LargeStoryRowState extends State<_LargeStoryRow> {
  bool _hovered = false;

  String get _topicName {
    final match = widget.allTopics.firstWhereOrNull((t) => t.topic == widget.entry.topic);
    return match?.name ?? widget.entry.topic;
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final date = widget.entry.createTime.toDateTime().toLocal().toIso8601String().substring(0, 10);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => showCoinNewsArticle(context, widget.entry),
        child: Opacity(
          opacity: widget.outdated ? 0.5 : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _hovered ? theme.colors.backgroundSecondary : SailColorScheme.transparent,
              border: Border(bottom: BorderSide(color: theme.colors.divider)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SailStyleValues.padding08,
                vertical: SailStyleValues.padding10,
              ),
              child: SailRow(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: SailStyleValues.padding12,
                children: [
                  _VotesCell(
                    upvotes: widget.entry.upvotes.toInt(),
                    downvotes: widget.entry.downvotes.toInt(),
                    onUpvote: widget.onUpvote,
                    onDownvote: widget.onDownvote,
                  ),
                  Expanded(
                    child: SailColumn(
                      spacing: SailStyleValues.padding04,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SailText.primary13(widget.entry.headline, bold: true),
                        SailText.secondary12('$_topicName · $date'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CoinNewsLargeViewModel extends BaseViewModel {
  final NewsProvider _newsProvider = GetIt.I.get<NewsProvider>();

  String leftTopic = 'a1a1a1a1';
  String rightTopic = 'a2a2a2a2';

  /// Stories past their topic's retention are hidden until the user asks.
  bool showOutdated = false;

  CoinNewsLargeViewModel() {
    _newsProvider.addListener(notifyListeners);
  }

  bool get loading => !_newsProvider.initialized;
  List<Topic> get topics => _newsProvider.topics;

  Future<void> upvote(CoinNews news) => _newsProvider.upvote(news);
  Future<void> downvote(CoinNews news) => _newsProvider.downvote(news);

  void setLeftTopic(String? topic) {
    if (topic == null) {
      return;
    }
    leftTopic = topic;
    notifyListeners();
  }

  void setRightTopic(String? topic) {
    if (topic == null) {
      return;
    }
    rightTopic = topic;
    notifyListeners();
  }

  void toggleOutdated() {
    showOutdated = !showOutdated;
    notifyListeners();
  }

  /// A story is outdated once it is older than its topic's retention. Topics
  /// with retention 0 keep everything.
  bool isOutdated(CoinNews news) {
    final topic = topics.firstWhereOrNull((t) => t.topic == news.topic);
    final days = topic?.retentionDays ?? 0;
    if (days <= 0) {
      return false;
    }
    return news.createTime.toDateTime().isBefore(DateTime.now().subtract(Duration(days: days)));
  }

  int outdatedCountFor(String topic) {
    return _allFor(topic).where(isOutdated).length;
  }

  List<CoinNews> entriesFor(String topic) {
    final entries = _allFor(topic).where((news) => showOutdated || !isOutdated(news)).toList();
    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries;
  }

  List<CoinNews> _allFor(String topic) {
    if (loading) {
      return [...dummyData];
    }
    return _newsProvider.news.where((news) => news.topic == topic).toList();
  }

  @override
  void dispose() {
    _newsProvider.removeListener(notifyListeners);
    super.dispose();
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

  // Selected article for side panel
  CoinNews? selectedArticle;
  String? selectedRowId;

  void selectArticle(CoinNews news) {
    // Find the index in paginatedEntries for row highlighting
    final index = paginatedEntries.indexOf(news);
    selectedRowId = index >= 0 ? index.toString() : null;
    selectedArticle = news;
    notifyListeners();
  }

  void clearSelection() {
    selectedArticle = null;
    selectedRowId = null;
    notifyListeners();
  }

  Future<void> upvote(CoinNews news) => _newsProvider.upvote(news);
  Future<void> downvote(CoinNews news) => _newsProvider.downvote(news);

  bool get loading {
    return !_newsProvider.initialized;
  }

  double get coinnewsHeight {
    switch (pageSize) {
      case 3:
        return 289;
      case 5:
        return 337;
      case 10:
        return 457;
      case 20:
        return 553;
      default:
        return 400;
    }
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
        case 'upvotes':
          aValue = a.upvotes.toInt();
          bValue = b.upvotes.toInt();
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
    if (Environment.isInTest) {
      return;
    }

    final setting = SelectedTopicsSetting();
    final loadedSetting = await _settings.getValue(setting);
    final config = loadedSetting.value;

    if (config.selectedTopics.isEmpty && topics.isNotEmpty) {
      // Initialize with all topics if nothing is saved
      _selectedTopicIds = topics.map((topic) => topic.topic).toList();
    } else {
      _selectedTopicIds = config.selectedTopics;
    }
    notifyListeners();
  }

  Future<void> _loadPageSize() async {
    if (Environment.isInTest) {
      return;
    }

    final setting = PageSizeSetting();
    final loadedSetting = await _settings.getValue(setting);
    pageSize = loadedSetting.value;
    notifyListeners();
  }

  Future<void> setSelectedTopics(List<String> topicIds) async {
    _selectedTopicIds = topicIds;

    // Get current config and update it
    final currentSetting = await _settings.getValue(SelectedTopicsSetting());
    final updatedConfig = currentSetting.value.copyWith(selectedTopics: topicIds);

    // Persist the selection
    final setting = SelectedTopicsSetting(newValue: updatedConfig);
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

List<CoinNews> get dummyData => [
  // if loading, add dummy date for the skeletonizer to render things properly
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
    content: 'The long-awaited Drivechain upgrade has been successfully implemented, bringing bitcoin to the masses.',
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

class TopicsConfigData {
  final List<String> selectedTopics;
  final String? leftTopic;
  final String? rightTopic;

  TopicsConfigData({
    required this.selectedTopics,
    this.leftTopic,
    this.rightTopic,
  });

  Map<String, dynamic> toMap() {
    return {
      'selectedTopics': selectedTopics,
      'leftTopic': leftTopic,
      'rightTopic': rightTopic,
    };
  }

  factory TopicsConfigData.fromMap(Map<String, dynamic> map) {
    return TopicsConfigData(
      selectedTopics: List<String>.from(map['selectedTopics'] ?? []),
      leftTopic: map['leftTopic'] as String?,
      rightTopic: map['rightTopic'] as String?,
    );
  }

  TopicsConfigData copyWith({
    List<String>? selectedTopics,
    String? leftTopic,
    String? rightTopic,
  }) {
    return TopicsConfigData(
      selectedTopics: selectedTopics ?? this.selectedTopics,
      leftTopic: leftTopic ?? this.leftTopic,
      rightTopic: rightTopic ?? this.rightTopic,
    );
  }
}

class SelectedTopicsSetting extends SettingValue<TopicsConfigData> {
  @override
  String get key => 'selected_topics_config';

  SelectedTopicsSetting({super.newValue});

  @override
  TopicsConfigData defaultValue() => TopicsConfigData(selectedTopics: []);

  @override
  TopicsConfigData? fromJson(String jsonString) {
    try {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      return TopicsConfigData.fromMap(decoded);
    } catch (e) {
      return null;
    }
  }

  @override
  String toJson() {
    return json.encode(value.toMap());
  }

  @override
  SettingValue<TopicsConfigData> withValue([TopicsConfigData? value]) {
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
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w';
    }

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (date.year != now.year) {
      return "${months[date.month - 1]} '${date.year.toString().substring(2)}";
    }
    return '${date.day} ${months[date.month - 1]}';
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
            color: isHovered ? context.sailTheme.colors.backgroundSecondary : SailColorScheme.transparent,
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

// _VotesCell renders the up/down vote buttons with their on-chain
// tallies (spec §8). Each tap broadcasts a signed Vote.
class _VotesCell extends StatelessWidget {
  final int upvotes;
  final int downvotes;
  final Future<void> Function()? onUpvote;
  final Future<void> Function()? onDownvote;

  const _VotesCell({
    required this.upvotes,
    required this.downvotes,
    this.onUpvote,
    this.onDownvote,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _VoteButton(asset: SailSVGAsset.thumbsUp, count: upvotes, onTap: onUpvote),
          const SailSpacing(SailStyleValues.padding12),
          _VoteButton(asset: SailSVGAsset.thumbsDown, count: downvotes, onTap: onDownvote),
        ],
      ),
    );
  }
}

class _VoteButton extends StatefulWidget {
  final SailSVGAsset asset;
  final int count;
  final Future<void> Function()? onTap;
  final double size;

  const _VoteButton({required this.asset, required this.count, this.onTap, this.size = 16});

  @override
  State<_VoteButton> createState() => _VoteButtonState();
}

class _VoteButtonState extends State<_VoteButton> {
  bool _hovered = false;
  bool _inFlight = false;

  Future<void> _handleTap() async {
    if (_inFlight || widget.onTap == null) {
      return;
    }
    if (!await NewsCost.confirmFirstTime(context, NewsAction.NEWS_ACTION_VOTE)) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _inFlight = true);
    try {
      await widget.onTap!();
    } finally {
      if (mounted) {
        setState(() => _inFlight = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sailTheme.colors;
    final enabled = widget.onTap != null && !_inFlight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NewsCostTooltip(
          action: NewsAction.NEWS_ACTION_VOTE,
          child: MouseRegion(
            cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              onTap: enabled ? _handleTap : null,
              child: SailSVG.fromAsset(
                widget.asset,
                width: widget.size,
                height: widget.size,
                color: _hovered && enabled ? colors.primary : colors.icon,
              ),
            ),
          ),
        ),
        const SailSpacing(SailStyleValues.padding04),
        SailText.primary12(widget.count.toString()),
      ],
    );
  }
}

class CoinNewsTable extends StatelessWidget {
  final List<CoinNews> entries;
  final Function(String) onSort;
  final bool loading;
  final List<Topic> allTopics;
  final bool shrinkWrap;
  final bool condensed;
  final void Function(CoinNews news)? onArticleSelected;
  final Future<void> Function(CoinNews news)? onUpvote;
  final Future<void> Function(CoinNews news)? onDownvote;
  final String? selectedRowId;

  const CoinNewsTable({
    super.key,
    required this.entries,
    required this.onSort,
    required this.loading,
    required this.allTopics,
    this.shrinkWrap = true,
    this.condensed = false,
    this.onArticleSelected,
    this.onUpvote,
    this.onDownvote,
    this.selectedRowId,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();

    return SailSkeletonizer(
      description: 'Waiting for backend to boot and for it to load coin news..',
      enabled: loading,
      duration: const Duration(seconds: 3),
      child: ListenableBuilder(
        listenable: formatter,
        builder: (context, child) => SailTable(
          shrinkWrap: shrinkWrap,
          selectedRowId: selectedRowId,
          getRowId: (index) => index.toString(),
          headerBuilder: (context) => [
            if (condensed) ...[
              const SailTableHeaderCell(name: 'Date'),
              const SailTableHeaderCell(name: 'Fee'),
              const SailTableHeaderCell(name: 'Title'),
              const SailTableHeaderCell(name: 'Votes'),
            ] else ...[
              const SailTableHeaderCell(name: 'Date'),
              const SailTableHeaderCell(name: 'Topic'),
              const SailTableHeaderCell(name: 'Title'),
              const SailTableHeaderCell(name: 'Read time'),
              const SailTableHeaderCell(name: 'Votes'),
            ],
          ],
          rowBuilder: (context, row, selected) {
            final entry = entries[row];
            final matchingTopic = allTopics.firstWhereOrNull((t) => t.topic == entry.topic);
            final votesCell = SailTableCell(
              value: '${entry.upvotes} / ${entry.downvotes}',
              width: 110,
              child: _VotesCell(
                upvotes: entry.upvotes.toInt(),
                downvotes: entry.downvotes.toInt(),
                onUpvote: onUpvote == null ? null : () => onUpvote!(entry),
                onDownvote: onDownvote == null ? null : () => onDownvote!(entry),
              ),
            );

            return [
              if (condensed) ...[
                SailTableCell(value: formatDate(entry.createTime.toDateTime())),
                SailTableCell(value: formatter.formatSats(entry.feeSats.toInt())),
                SailTableCell(value: entry.headline),
                votesCell,
              ] else ...[
                SailTableCell(value: formatDate(entry.createTime.toDateTime())),
                SailTableCell(value: matchingTopic?.name ?? entry.topic),
                SailTableCell(value: entry.headline),
                SailTableCell(value: expectedReadTime(entry.content)),
                votesCell,
              ],
            ];
          },
          rowCount: entries.length,
          emptyPlaceholder: 'No news articles yet',
          drawGrid: true,
          onSort: (columnIndex, ascending) {
            final columns = condensed
                ? ['date', 'topic', 'title', 'upvotes']
                : ['date', 'topic', 'title', 'readtime', 'upvotes'];
            onSort(columns[columnIndex]);
          },
          onSelectedRow: (rowId) {
            if (rowId == null || onArticleSelected == null) {
              return;
            }
            final index = int.tryParse(rowId);
            if (index != null && index < entries.length) {
              onArticleSelected!(entries[index]);
            }
          },
          contextMenuItems: (rowId) {
            final index = int.tryParse(rowId);
            final news = index != null && index < entries.length ? entries[index] : null;
            return [
              SailMenuItem(
                onSelected: () {
                  if (news != null && onArticleSelected != null) {
                    onArticleSelected!(news);
                  }
                },
                child: SailText.primary12('Show Details'),
              ),
              // The indexer does not always report the on-chain position.
              if (news != null && news.txid.isNotEmpty)
                SailMenuItem(
                  onSelected: () async {
                    final network = GetIt.I.get<BitcoinConfProvider>().network;
                    await launchUrl(Uri.parse(mempoolTxUrl(news.txid, network)));
                  },
                  child: SailText.primary12('View on chain'),
                ),
            ];
          },
        ),
      ),
    );
  }
}

void showCoinNewsArticle(BuildContext context, CoinNews news) {
  unawaited(
    showSailSheet(
      context: context,
      side: SailSheetSide.bottom,
      size: MediaQuery.of(context).size.height * 0.95,
      builder: (context) {
        return CoinNewsArticlePanel(
          news: news,
          onClose: () => Navigator.of(context).pop(),
        );
      },
    ),
  );
}

class CoinNewsArticlePanel extends StatefulWidget {
  final CoinNews news;
  final VoidCallback onClose;

  const CoinNewsArticlePanel({
    super.key,
    required this.news,
    required this.onClose,
  });

  @override
  State<CoinNewsArticlePanel> createState() => _CoinNewsArticlePanelState();
}

class _CoinNewsArticlePanelState extends State<CoinNewsArticlePanel> {
  BitwindowRPC get api => GetIt.I.get<BitwindowRPC>();

  List<Comment> _comments = [];
  bool _loading = true;
  bool _posting = false;
  String? _error;
  String? _replyTo; // item_id being replied to; null = top-level
  final Set<String> _voted = {}; // items voted on this session (§8 dedup)
  final TextEditingController _controller = TextEditingController();

  String get _itemId => widget.news.itemId;

  @override
  void initState() {
    super.initState();
    if (_itemId.isNotEmpty) {
      _load();
    } else {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final comments = await api.misc.listComments(_itemId);
      if (!mounted) {
        return;
      }
      setState(() {
        _comments = comments;
        _error = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _post() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _posting) {
      return;
    }
    if (!await NewsCost.confirmFirstTime(context, NewsAction.NEWS_ACTION_COMMENT)) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _posting = true);
    try {
      await api.misc.commentNews(_replyTo ?? _itemId, body);
      if (!mounted) {
        return;
      }
      _controller.clear();
      setState(() => _replyTo = null);
      await _load();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _posting = false);
      }
    }
  }

  /// Broadcasts a signed vote on a comment and optimistically bumps its
  /// count. The confirmed tally updates once the vote is mined. A given
  /// (author, target) counts at most once on-chain (§8), so we vote — and
  /// bump — at most once per item per session.
  Future<void> _vote(Comment comment, {required bool up}) async {
    if (_voted.contains(comment.itemId)) {
      return;
    }
    if (!await NewsCost.confirmFirstTime(context, NewsAction.NEWS_ACTION_VOTE)) {
      return;
    }
    _voted.add(comment.itemId);
    try {
      if (up) {
        await api.misc.upvoteNews(comment.itemId);
      } else {
        await api.misc.downvoteNews(comment.itemId);
      }
      if (!mounted) {
        return;
      }
      final idx = _comments.indexWhere((c) => c.itemId == comment.itemId);
      if (idx != -1) {
        final updated = _comments[idx].deepCopy();
        if (up) {
          updated.upvotes += Int64(1);
        } else {
          updated.downvotes += Int64(1);
        }
        setState(() => _comments[idx] = updated);
      }
    } catch (e) {
      _voted.remove(comment.itemId); // allow retry on failure
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = SailTheme.of(context);

    // Use the opposite theme for the article panel
    final oppositeThemeData = currentTheme.isLightMode()
        ? SailThemeData.darkTheme(currentTheme.colors.primary, currentTheme.dense, currentTheme.font)
        : SailThemeData.lightTheme(currentTheme.colors.primary, currentTheme.dense, currentTheme.font);

    return SailTheme(
      data: oppositeThemeData,
      child: Builder(
        builder: (context) {
          final theme = SailTheme.of(context);

          return SailCard(
            padding: false,
            color: theme.colors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(SailStyleValues.padding08),
                    child: SailButton(
                      label: 'Close',
                      variant: ButtonVariant.ghost,
                      onPressed: () async => widget.onClose(),
                    ),
                  ),
                ),
                Expanded(
                  child: SelectionArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          SailStyleValues.padding40,
                          SailStyleValues.padding08,
                          SailStyleValues.padding40,
                          SailStyleValues.padding40,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 860),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SailText.primary24(widget.news.headline, bold: true),
                              const SailSpacing(SailStyleValues.padding12),
                              SailText.secondary13(
                                widget.news.topic.isEmpty
                                    ? formatDate(widget.news.createTime.toDateTime())
                                    : '${widget.news.topic}  ·  ${formatDate(widget.news.createTime.toDateTime())}',
                                color: theme.colors.textTertiary,
                              ),
                              const SailSpacing(SailStyleValues.padding16),
                              Container(height: 1, color: theme.colors.divider),
                              const SailSpacing(SailStyleValues.padding20),
                              if (widget.news.url.isNotEmpty) ...[
                                GestureDetector(
                                  onTap: () async => launchUrl(Uri.parse(widget.news.url)),
                                  child: SailText.primary13(widget.news.url, color: theme.colors.primary),
                                ),
                                const SailSpacing(SailStyleValues.padding16),
                              ],
                              MarkdownBody(
                                data: widget.news.content,
                                styleSheet: MarkdownStyleSheet(
                                  p: SailStyleValues.fifteen.copyWith(color: theme.colors.text, height: 1.6),
                                  h1: SailStyleValues.twentyTwo.copyWith(color: theme.colors.text),
                                  h2: SailStyleValues.twenty.copyWith(color: theme.colors.text),
                                  h3: SailStyleValues.fifteen.copyWith(
                                    color: theme.colors.text,
                                    fontWeight: SailStyleValues.boldWeight,
                                  ),
                                  listBullet: SailStyleValues.fifteen.copyWith(color: theme.colors.text, height: 1.6),
                                  pPadding: const EdgeInsets.only(bottom: 16),
                                  blockquoteDecoration: BoxDecoration(
                                    color: SailColorScheme.transparent,
                                    borderRadius: SailStyleValues.borderRadius,
                                  ),
                                  codeblockDecoration: BoxDecoration(
                                    color: theme.colors.backgroundSecondary,
                                    borderRadius: SailStyleValues.borderRadius,
                                  ),
                                  code: SailStyleValues.thirteen.copyWith(
                                    color: theme.colors.text,
                                    fontFamily: 'IBMPlexMono',
                                  ),
                                  codeblockPadding: const EdgeInsets.all(12),
                                ),
                                onTapLink: (_, href, _) async {
                                  if (href == null) {
                                    return;
                                  }
                                  await launchUrl(Uri.parse(href));
                                },
                              ),
                              const SailSpacing(SailStyleValues.padding32),
                              if (_itemId.isNotEmpty) _commentsThread(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_itemId.isNotEmpty) _composerFooter(context),
              ],
            ),
          );
        },
      ),
    );
  }

  /// The comment thread (spec §7). Replies nest under their parent;
  /// siblings are ordered by §13 score.
  Widget _commentsThread(BuildContext context) {
    final theme = SailTheme.of(context);
    final roots = _comments.where((c) => c.parentId == _itemId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: theme.colors.divider),
        const SailSpacing(SailStyleValues.padding12),
        SailText.primary15('Comments (${_comments.length})', bold: true),
        const SailSpacing(SailStyleValues.padding12),
        if (_loading)
          SailText.secondary12('Loading comments…')
        else if (_error != null)
          SailText.secondary12(_error!, color: theme.colors.error)
        else if (roots.isEmpty)
          SailText.secondary12('No comments yet. Be the first.')
        else
          ...roots.map((c) => _commentTree(context, c, depth: 0)),
      ],
    );
  }

  Widget _commentTree(BuildContext context, Comment comment, {required int depth}) {
    final children = _comments.where((c) => c.parentId == comment.itemId).toList();
    return Padding(
      padding: EdgeInsets.only(left: depth == 0 ? 0 : SailStyleValues.padding16, bottom: SailStyleValues.padding08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _commentTile(context, comment),
          ...children.map((c) => _commentTree(context, c, depth: depth + 1)),
        ],
      ),
    );
  }

  Widget _commentTile(BuildContext context, Comment comment) {
    final theme = SailTheme.of(context);
    final author = comment.author.length > 10 ? '${comment.author.substring(0, 10)}…' : comment.author;
    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding08),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SailText.secondary12(author, color: theme.colors.textTertiary),
              const SailSpacing(SailStyleValues.padding12),
              _VoteButton(
                asset: SailSVGAsset.thumbsUp,
                count: comment.upvotes.toInt(),
                size: 12,
                onTap: () => _vote(comment, up: true),
              ),
              const SailSpacing(SailStyleValues.padding08),
              _VoteButton(
                asset: SailSVGAsset.thumbsDown,
                count: comment.downvotes.toInt(),
                size: 12,
                onTap: () => _vote(comment, up: false),
              ),
            ],
          ),
          const SailSpacing(SailStyleValues.padding04),
          SailText.primary13(comment.body),
          if (comment.url.isNotEmpty) SailText.secondary12(comment.url, color: theme.colors.textSecondary),
          const SailSpacing(SailStyleValues.padding04),
          SailButton(
            label: _replyTo == comment.itemId ? 'Cancel reply' : 'Reply',
            variant: ButtonVariant.ghost,
            onPressed: () async {
              setState(() => _replyTo = _replyTo == comment.itemId ? null : comment.itemId);
            },
          ),
        ],
      ),
    );
  }

  /// Pinned composer at the bottom of the panel so posting the first
  /// comment never requires scrolling past the article. Tapping a
  /// comment's Reply re-targets this same box; otherwise it posts a
  /// top-level comment.
  Widget _composerFooter(BuildContext context) {
    final theme = SailTheme.of(context);
    final replying = _replyTo != null;

    String? replyAuthor;
    if (replying) {
      final idx = _comments.indexWhere((c) => c.itemId == _replyTo);
      if (idx != -1) {
        final a = _comments[idx].author;
        replyAuthor = a.length > 10 ? '${a.substring(0, 10)}…' : a;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding40,
        vertical: SailStyleValues.padding12,
      ),
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(top: BorderSide(color: theme.colors.divider, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (replyAuthor != null) ...[
            Row(
              children: [
                SailText.secondary12('Replying to $replyAuthor', color: theme.colors.textTertiary),
                const SailSpacing(SailStyleValues.padding08),
                SailButton(
                  label: 'Cancel',
                  variant: ButtonVariant.ghost,
                  onPressed: () async => setState(() => _replyTo = null),
                ),
              ],
            ),
            const SailSpacing(SailStyleValues.padding04),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SailTextField(
                  hintText: replying ? 'Write a reply…' : 'Add a comment…',
                  controller: _controller,
                ),
              ),
              const SailSpacing(SailStyleValues.padding08),
              NewsCostTooltip(
                action: NewsAction.NEWS_ACTION_COMMENT,
                body: _controller.text,
                child: SailButton(
                  label: 'Comment',
                  loading: _posting,
                  onPressed: () async => _post(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
