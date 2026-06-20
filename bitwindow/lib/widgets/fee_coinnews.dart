import 'package:bitwindow/env.dart';
import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/widgets/coinnews.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

const _headlineChars = 64;

String _truncateHeadline(String headline) {
  var end = headline.length;
  var truncated = false;

  final newline = headline.indexOf(RegExp(r'[\r\n]'));
  if (newline != -1 && newline < end) {
    end = newline;
    truncated = true;
  }
  if (end > _headlineChars) {
    end = _headlineChars;
    truncated = true;
  }

  final str = headline.substring(0, end);
  return truncated ? '$str...' : str;
}

class FeeCoinNewsView extends ViewModelWidget<FeeCoinNewsViewModel> {
  const FeeCoinNewsView({super.key});

  @override
  Widget build(BuildContext context, FeeCoinNewsViewModel viewModel) {
    return SailCard(
      title: 'Coin News',
      titleTooltip: "On-chain news ranked by fee, within each topic's retention window",
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
      child: SailColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 0,
        mainAxisSize: MainAxisSize.min,
        children: [
          SailRow(
            spacing: SailStyleValues.padding16,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              SailDropdownButton<String>(
                items: viewModel.topicItems,
                onChanged: (value) {
                  if (value != null) viewModel.setTopic(value);
                },
                value: viewModel.selectedTopic,
                hint: 'Select topic',
              ),
              SailButton(
                label: 'Broadcast',
                onPressed: viewModel.selectedTopic != null ? () => displayBroadcastNewsDialog(context) : null,
              ),
            ],
          ),
          const SailSpacing(16),
          FeeCoinNewsTable(
            entries: viewModel.entries,
            loading: viewModel.loading,
            onArticleSelected: (news) => showCoinNewsArticle(context, news),
          ),
        ],
      ),
    );
  }
}

class FeeCoinNewsViewModel extends BaseViewModel {
  final NewsProvider _newsProvider = GetIt.I.get<NewsProvider>();
  final ClientSettings _settings = GetIt.I.get<ClientSettings>();

  String? selectedTopic;

  FeeCoinNewsViewModel() {
    _newsProvider.addListener(notifyListeners);
    _loadTopic();
  }

  bool get loading => !_newsProvider.initialized;
  List<Topic> get topics => _newsProvider.topics;

  List<SailDropdownItem<String>> get topicItems => topics
      .map(
        (topic) => SailDropdownItem<String>(
          value: topic.topic,
          label: topic.confirmed ? topic.name : '${topic.name} (pending)',
        ),
      )
      .toList();

  List<CoinNews> get entries {
    if (loading) return [...dummyData];

    return _newsProvider.news.where((news) => news.topic == selectedTopic).toList()
      ..sort((a, b) => b.feeSats.compareTo(a.feeSats));
  }

  Future<void> _loadTopic() async {
    if (Environment.isInTest) return;

    final loaded = (await _settings.getValue(FeeTopicSetting(_topicKey))).value;
    selectedTopic = loaded.isNotEmpty ? loaded : (topics.isNotEmpty ? topics.first.topic : null);
    notifyListeners();
  }

  Future<void> setTopic(String topic) async {
    selectedTopic = topic;
    await _settings.setValue(FeeTopicSetting(_topicKey, newValue: topic));
    notifyListeners();
  }

  @override
  void dispose() {
    _newsProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

class FeeCoinNewsLargeView extends ViewModelWidget<FeeCoinNewsLargeViewModel> {
  const FeeCoinNewsLargeView({super.key});

  @override
  Widget build(BuildContext context, FeeCoinNewsLargeViewModel viewModel) {
    return SizedBox(
      height: 300,
      child: SailRow(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SailStyleValues.padding16,
        children: [
          Expanded(
            child: SailCard(
              child: SailColumn(
                children: [
                  SizedBox(
                    height: 36,
                    child: SailRow(
                      children: [
                        SailText.primary15('Coin News', bold: true),
                        Expanded(child: Container()),
                        SailDropdownButton<String>(
                          items: viewModel.topicItems,
                          onChanged: (value) {
                            if (value != null) viewModel.setLeftTopic(value);
                          },
                          value: viewModel.leftTopic,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FeeCoinNewsTable(
                      entries: viewModel.leftEntries,
                      loading: viewModel.loading,
                      shrinkWrap: false,
                      onArticleSelected: (news) => showCoinNewsArticle(context, news),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SailCard(
              child: SailColumn(
                children: [
                  SizedBox(
                    height: 36,
                    child: SailRow(
                      children: [
                        SailDropdownButton<String>(
                          items: viewModel.topicItems,
                          onChanged: (value) {
                            if (value != null) viewModel.setRightTopic(value);
                          },
                          value: viewModel.rightTopic,
                        ),
                        Expanded(child: Container()),
                        SailButton(
                          label: 'Broadcast News',
                          variant: ButtonVariant.primary,
                          icon: SailSVGAsset.newspaper,
                          onPressed: () => displayBroadcastNewsDialog(context),
                          skipLoading: true,
                        ),
                        ExtraActionsDropdown(
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
                      ],
                    ),
                  ),
                  Expanded(
                    child: FeeCoinNewsTable(
                      entries: viewModel.rightEntries,
                      loading: viewModel.loading,
                      shrinkWrap: false,
                      onArticleSelected: (news) => showCoinNewsArticle(context, news),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeeCoinNewsLargeViewModel extends BaseViewModel {
  final NewsProvider _newsProvider = GetIt.I.get<NewsProvider>();
  final ClientSettings _settings = GetIt.I.get<ClientSettings>();

  String leftTopic = 'a1a1a1a1';
  String rightTopic = 'a2a2a2a2';

  FeeCoinNewsLargeViewModel() {
    _newsProvider.addListener(notifyListeners);
    _loadTopics();
  }

  bool get loading => !_newsProvider.initialized;
  List<Topic> get topics => _newsProvider.topics;

  List<SailDropdownItem<String>> get topicItems => topics
      .map(
        (topic) => SailDropdownItem<String>(
          value: topic.topic,
          label: topic.confirmed ? topic.name : '${topic.name} (pending)',
        ),
      )
      .toList();

  List<CoinNews> get leftEntries => _entriesFor(leftTopic);
  List<CoinNews> get rightEntries => _entriesFor(rightTopic);

  List<CoinNews> _entriesFor(String topic) {
    if (loading) return [...dummyData];

    return _newsProvider.news.where((news) => news.topic == topic).toList()
      ..sort((a, b) => b.feeSats.compareTo(a.feeSats));
  }

  Future<void> _loadTopics() async {
    if (Environment.isInTest) return;

    final left = (await _settings.getValue(FeeTopicSetting(_leftKey))).value;
    final right = (await _settings.getValue(FeeTopicSetting(_rightKey))).value;

    leftTopic = left.isNotEmpty ? left : (topics.isNotEmpty ? topics.first.topic : leftTopic);
    rightTopic = right.isNotEmpty ? right : (topics.length > 1 ? topics[1].topic : leftTopic);
    notifyListeners();
  }

  Future<void> setLeftTopic(String topic) async {
    leftTopic = topic;
    await _settings.setValue(FeeTopicSetting(_leftKey, newValue: topic));
    notifyListeners();
  }

  Future<void> setRightTopic(String topic) async {
    rightTopic = topic;
    await _settings.setValue(FeeTopicSetting(_rightKey, newValue: topic));
    notifyListeners();
  }

  @override
  void dispose() {
    _newsProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

class FeeCoinNewsTable extends StatelessWidget {
  final List<CoinNews> entries;
  final bool loading;
  final bool shrinkWrap;
  final void Function(CoinNews news)? onArticleSelected;

  const FeeCoinNewsTable({
    super.key,
    required this.entries,
    required this.loading,
    this.shrinkWrap = true,
    this.onArticleSelected,
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
          getRowId: (index) => index.toString(),
          headerBuilder: (context) => const [
            SailTableHeaderCell(name: 'Fees'),
            SailTableHeaderCell(name: 'Time'),
            SailTableHeaderCell(name: 'Headline'),
          ],
          rowBuilder: (context, row, selected) {
            final entry = entries[row];
            return [
              SailTableCell(value: formatter.formatSats(entry.feeSats.toInt())),
              SailTableCell(value: formatDate(entry.createTime.toDateTime(), long: false)),
              SailTableCell(value: _truncateHeadline(entry.headline)),
            ];
          },
          rowCount: entries.length,
          emptyPlaceholder: 'No news articles yet',
          drawGrid: true,
          onSelectedRow: (rowId) {
            if (rowId == null || onArticleSelected == null) return;
            final index = int.tryParse(rowId);
            if (index != null && index < entries.length) {
              onArticleSelected!(entries[index]);
            }
          },
          contextMenuItems: (rowId) {
            return [
              SailMenuItem(
                onSelected: () {
                  final index = int.tryParse(rowId);
                  if (index != null && index < entries.length && onArticleSelected != null) {
                    onArticleSelected!(entries[index]);
                  }
                },
                child: SailText.primary12('Show Details'),
              ),
            ];
          },
        ),
      ),
    );
  }
}

const _topicKey = 'fee_coin_news_topic';
const _leftKey = 'fee_coin_news_left_topic';
const _rightKey = 'fee_coin_news_right_topic';

class FeeTopicSetting extends SettingValue<String> {
  final String _key;

  FeeTopicSetting(this._key, {super.newValue});

  @override
  String get key => _key;

  @override
  String defaultValue() => '';

  @override
  String? fromJson(String jsonString) => jsonString;

  @override
  String toJson() => value;

  @override
  SettingValue<String> withValue([String? value]) => FeeTopicSetting(_key, newValue: value);
}
