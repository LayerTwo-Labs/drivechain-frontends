import 'dart:convert';
import 'dart:math';

import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/widgets/pagination.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/misc/v1/misc.pb.dart';
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
          subtitle: 'Stay up-to-date on the latest world developments',
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
                    ...viewModel.paginatedEntries
                        .map((entry) => CoinNewsEntry(entry: entry, allTopics: viewModel.topics)),
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
  final NewsProvider _newsProvider = GetIt.I.get<NewsProvider>();
  final ClientSettings _settings = GetIt.I.get<ClientSettings>();
  final TextEditingController searchController = TextEditingController();

  // Pagination state
  int currentPage = 1;
  int pageSize = 3;

  List<CoinNews> get entries => _newsProvider.news
      .where(
        (news) =>
            _selectedTopicIds.contains(news.topic) &&
            (searchController.text.isEmpty ||
                news.headline.toLowerCase().contains(searchController.text.toLowerCase()) ||
                news.content.toLowerCase().contains(searchController.text.toLowerCase())),
      )
      .toList();

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
