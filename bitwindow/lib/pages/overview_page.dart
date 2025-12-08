import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/env.dart';
import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/homepage_provider.dart' as bitwindow;
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/widgets/homepage_widget_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/providers/price_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OverviewViewModel>.reactive(
      viewModelBuilder: () => OverviewViewModel(),
      builder: (context, viewModel, child) => QtPage(
        child: HomepageBuilder(
          configuration: viewModel.homepageConfiguration,
          widgetCatalog: HomepageWidgetCatalog.getCatalogMap(),
          isPreview: false,
        ),
      ),
    );
  }
}

class OverviewViewModel extends BaseViewModel {
  bitwindow.BitwindowHomepageProvider get _homepageProvider => GetIt.I.get<bitwindow.BitwindowHomepageProvider>();
  HomepageConfiguration get homepageConfiguration => _homepageProvider.configuration;

  OverviewViewModel() {
    _homepageProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _homepageProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

class FireplaceViewModel extends BaseViewModel {
  final PriceProvider priceProvider = GetIt.I.get<PriceProvider>();
  final BitwindowRPC api = GetIt.I.get<BitwindowRPC>();
  final EnforcerRPC _enforcerRPC = GetIt.I<EnforcerRPC>();

  bool get loading => _enforcerRPC.initializingBinary;

  String get priceLastUpdated => priceProvider.priceAge;
  String get price => priceProvider.formattedPrice;

  Timer? _timer;

  FireplaceViewModel() {
    fetchFireplaceStats();
    priceProvider.addListener(fetchFireplaceStats);

    if (!Environment.isInTest) {
      _timer = Timer.periodic(
        Duration(seconds: 1),
        // notify listeners every second to update the last updated time
        (timer) => notifyListeners(),
      );
    }
  }

  GetFireplaceStatsResponse? stats;

  Future<void> fetchFireplaceStats() async {
    try {
      final response = await api.bitwindowd.getFireplaceStats();
      if (response.toDebugString() != stats?.toDebugString()) {
        stats = response;
        notifyListeners();
      }
    } catch (_) {
      // is a fine to swallow
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class FireplaceStats extends StatelessWidget {
  const FireplaceStats({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FireplaceViewModel>.reactive(
      viewModelBuilder: () => FireplaceViewModel(),
      builder: (context, model, child) => FireplaceStatsView(
        priceLastUpdated: model.priceLastUpdated,
        price: model.price,
        stats: model.stats ?? GetFireplaceStatsResponse(),
        loading: model.loading,
      ),
    );
  }
}

class FireplaceStat extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final SailSVGAsset icon;
  final bool bitcoinAmount;
  final bool loading;

  const FireplaceStat({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    this.bitcoinAmount = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SailCardStats(
      title: title,
      subtitle: subtitle,
      value: value,
      icon: icon,
      loading: LoadingDetails(
        enabled: loading,
        description: 'Waiting for enforcer to boot and wallet to sync..',
      ),
    );
  }
}

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TransactionsViewModel>.reactive(
      viewModelBuilder: () => TransactionsViewModel(),
      builder: (context, model, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Responsive columns based on width
            int crossAxisCount = (constraints.maxWidth / 600).ceil();
            double gridSpacing = SailStyleValues.padding16;
            double totalSpacing = gridSpacing * (crossAxisCount - 1);
            double cardWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
            double desiredCardHeight = 300;

            double childAspectRatio = cardWidth / desiredCardHeight;

            List<Widget> cardList = [
              SailCard(
                bottomPadding: false,
                title: 'Latest Transactions',
                error: model.hasErrorForKey('blockchain') ? model.error('blockchain').toString() : null,
                child: SizedBox(
                  height: 300,
                  child: LatestTransactionTable(
                    entries: model.recentTransactions,
                  ),
                ),
              ),
              SailCard(
                title: 'Latest Blocks',
                bottomPadding: false,
                child: SizedBox(
                  height: 300,
                  child: LatestBlocksTable(
                    blocks: model.recentBlocks,
                  ),
                ),
              ),
            ];

            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: gridSpacing,
              mainAxisSpacing: gridSpacing,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: childAspectRatio,
              children: cardList,
            );
          },
        );
      },
    );
  }
}

class TransactionsViewModel extends BaseViewModel {
  final BlockchainProvider blockchainProvider = GetIt.I.get<BlockchainProvider>();
  final BalanceProvider balanceProvider = GetIt.I.get<BalanceProvider>();
  TransactionsViewModel() {
    balanceProvider.addListener(notifyListeners);
    blockchainProvider.addListener(notifyListeners);
  }

  void errorListener() {
    if (balanceProvider.error != null) {
      setErrorForObject('balance', balanceProvider.error);
    }
    if (blockchainProvider.error != null) {
      setErrorForObject('blockchain', blockchainProvider.error);
    }
  }

  List<Block> get recentBlocks => blockchainProvider.blocks;
  List<RecentTransaction> get recentTransactions => blockchainProvider.recentTransactions;
}

class QtSeparator extends StatelessWidget {
  final double width;

  const QtSeparator({
    super.key,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
      ),
      child: Container(
        height: 1.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.35, 0.36, 1.0],
            colors: [
              Colors.grey,
              Colors.grey.withValues(alpha: 0.3),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
      ),
    );
  }
}

class LatestTransactionTable extends StatefulWidget {
  final List<RecentTransaction> entries;

  const LatestTransactionTable({
    super.key,
    required this.entries,
  });

  @override
  State<LatestTransactionTable> createState() => _LatestTransactionTableState();
}

class _LatestTransactionTableState extends State<LatestTransactionTable> {
  String sortColumn = 'time';
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    onSort(sortColumn);
  }

  void onSort(String column) {
    if (sortColumn == column) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }
    sortEntries();
    setState(() {});
  }

  void sortEntries() {
    widget.entries.sort((a, b) {
      dynamic aValue = '';
      dynamic bValue = '';

      switch (sortColumn) {
        case 'time':
          aValue = a.time.toDateTime().millisecondsSinceEpoch;
          bValue = b.time.toDateTime().millisecondsSinceEpoch;
          break;
        case 'fee':
          aValue = a.feeSats;
          bValue = b.feeSats;
          break;
        case 'txid':
          aValue = a.txid;
          bValue = b.txid;
          break;
        case 'size':
          aValue = a.virtualSize;
          bValue = b.virtualSize;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => widget.entries[index].txid,
      headerBuilder: (context) => [
        SailTableHeaderCell(
          name: 'Time',
          onSort: () => onSort('time'),
        ),
        SailTableHeaderCell(
          name: 'Fee',
          onSort: () => onSort('fee'),
        ),
        SailTableHeaderCell(
          name: 'TxID',
          onSort: () => onSort('txid'),
        ),
        SailTableHeaderCell(
          name: 'Size',
          onSort: () => onSort('size'),
        ),
        SailTableHeaderCell(
          name: 'Height',
          onSort: () => onSort('block'),
        ),
      ],
      rowBuilder: (context, row, selected) {
        final entry = widget.entries[row];
        return [
          SailTableCell(value: entry.time.toDateTime().toLocal().toString()),
          SailTableCell(value: entry.feeSats.toString()),
          SailTableCell(value: entry.txid),
          SailTableCell(value: entry.virtualSize.toString()),
          SailTableCell(
            value: entry.confirmedInBlock == 0 ? '-' : entry.confirmedInBlock.toString(),
          ),
        ];
      },
      rowCount: widget.entries.length,
      emptyPlaceholder: 'No transactions yet',
      drawGrid: true,
      sortColumnIndex: ['time', 'fee', 'txid', 'size', 'height'].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(['time', 'fee', 'txid', 'size', 'height'][columnIndex]);
      },
    );
  }
}

class LatestBlocksTable extends StatefulWidget {
  final List<Block> blocks;

  const LatestBlocksTable({
    super.key,
    required this.blocks,
  });

  @override
  State<LatestBlocksTable> createState() => _LatestBlocksTableState();
}

class _LatestBlocksTableState extends State<LatestBlocksTable> {
  String sortColumn = 'time';
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    onSort(sortColumn);
  }

  void onSort(String column) {
    if (sortColumn == column) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }
    sortEntries();
    setState(() {});
  }

  void sortEntries() {
    widget.blocks.sort((a, b) {
      dynamic aValue = '';
      dynamic bValue = '';

      switch (sortColumn) {
        case 'time':
          aValue = a.blockTime.toDateTime().millisecondsSinceEpoch;
          bValue = b.blockTime.toDateTime().millisecondsSinceEpoch;
          break;
        case 'height':
          aValue = a.height;
          bValue = b.height;
          break;
        case 'hash':
          aValue = a.hash;
          bValue = b.hash;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => widget.blocks[index].hash,
      headerBuilder: (context) => [
        const SailTableHeaderCell(name: 'Time'),
        const SailTableHeaderCell(name: 'Height'),
        const SailTableHeaderCell(name: 'Block Hash'),
      ],
      rowBuilder: (context, row, selected) {
        final entry = widget.blocks[row];
        return [
          SailTableCell(value: entry.blockTime.toDateTime().toLocal().format()),
          SailTableCell(value: entry.height.toString()),
          SailTableCell(value: entry.hash),
        ];
      },
      rowCount: widget.blocks.length,
      emptyPlaceholder: 'No blocks yet',
      drawGrid: true,
      sortColumnIndex: ['time', 'height', 'hash'].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(['time', 'height', 'hash'][columnIndex]);
      },
    );
  }
}

Future<void> displayBroadcastNewsDialog(BuildContext context) async {
  await widgetDialog(
    context: context,
    title: 'Broadcast News',
    subtitle: 'Broadcast News to the whole world',
    child: BroadcastNewsView(),
  );
}

Future<void> displayNewsOverviewDialog(BuildContext context, {required CoinNews news}) async {
  await widgetDialog(
    context: context,
    title: news.headline,
    subtitle: '',
    child: NewsOverviewView(news: news),
  );
}

Future<void> displayCreateTopicDialog(BuildContext context) async {
  await widgetDialog(
    context: context,
    title: 'Manage News Subscriptions',
    subtitle: 'View, subscribe to, and create news topics',
    maxWidth: 700,
    child: const ManageNewsSubscriptionsView(),
  );
}

Future<void> displayGraffitiExplorerDialog(BuildContext context) async {
  await widgetDialog(
    context: context,
    title: 'Graffiti Explorer',
    subtitle: 'List all previous OP_RETURN messages found in the blockchain.',
    maxWidth: MediaQuery.of(context).size.width - 100,
    child: const GraffitiExplorerView(),
  );
}

void _showNewsHelp(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('News Help'),
      content: const Text(
        'With this page you can pay a fee to broadcast news on any topic. '
        'Clicking "Broadcast" will create a transaction with an OP_RETURN '
        'output that encodes the text you have entered. Anyone subscribed to '
        'the topic will see posts filtered by time and sorted by fee amount.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

class BroadcastNewsView extends StatelessWidget {
  const BroadcastNewsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BroadcastNewsViewModel>.reactive(
      viewModelBuilder: () => BroadcastNewsViewModel(),
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          child: SailColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: SailStyleValues.padding16,
            mainAxisSize: MainAxisSize.min,
            leadingSpacing: true,
            children: [
              SailDropdownButton<Topic>(
                items: [
                  ...viewModel.topics.map(
                    (topic) => SailDropdownItem(
                      value: topic,
                      label: topic.confirmed ? topic.name : '${topic.name} (pending)',
                    ),
                  ),
                ],
                onChanged: viewModel.setTopic,
                value: viewModel.topic,
                hint: 'Select a topic',
              ),
              SailTextField(
                label: 'Headline (max 64 characters)',
                controller: viewModel.headlineController,
                hintText: 'Enter a headline',
                size: TextFieldSize.small,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(64),
                ],
              ),
              SailTextField(
                label: 'Content',
                controller: viewModel.contentController,
                hintText: 'Enter news content',
                minLines: 10,
                maxLines: null,
              ),
              SailRow(
                spacing: SailStyleValues.padding08,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SailButton(
                    label: 'Help',
                    variant: ButtonVariant.ghost,
                    icon: SailSVGAsset.iconQuestion,
                    onPressed: () async => _showNewsHelp(context),
                  ),
                  SailButton(
                    label: 'Broadcast',
                    onPressed: () async => viewModel.broadcastNews(context),
                    disabled:
                        viewModel.headlineController.text.isEmpty || viewModel.headlineController.text.length > 64,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class LastUsedTopicSetting extends SettingValue<String> {
  @override
  String get key => 'last_used_broadcast_topic';

  LastUsedTopicSetting({super.newValue});

  @override
  String defaultValue() => '';

  @override
  String? fromJson(String jsonString) {
    return jsonString;
  }

  @override
  String toJson() {
    return value;
  }

  @override
  SettingValue<String> withValue([String? value]) {
    return LastUsedTopicSetting(newValue: value);
  }
}

class BroadcastNewsViewModel extends BaseViewModel {
  final NewsProvider _newsProvider = GetIt.I.get<NewsProvider>();
  final BitwindowRPC _api = GetIt.I.get<BitwindowRPC>();
  final ClientSettings _settings = GetIt.I.get<ClientSettings>();

  final TextEditingController headlineController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  Topic? topic;

  List<Topic> get topics => _newsProvider.topics;

  BroadcastNewsViewModel() {
    _loadLastUsedTopic();
    headlineController.addListener(notifyListeners);
    contentController.addListener(notifyListeners);
  }

  Future<void> _loadLastUsedTopic() async {
    final setting = LastUsedTopicSetting();
    final lastUsedTopicId = (await _settings.getValue(setting)).value;

    if (lastUsedTopicId.isNotEmpty) {
      // Try to find the last used topic in the available topics
      topic = topics.firstWhere(
        (t) => t.topic == lastUsedTopicId,
        orElse: () => topics.first,
      );
    } else {
      topic = topics.first;
    }

    // Defer notifyListeners to avoid mouse tracker assertion during dialog initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setTopic(Topic? newTopic) async {
    if (newTopic == null) {
      return;
    }

    topic = newTopic;
    // Persist the selected topic
    await _settings.setValue(LastUsedTopicSetting(newValue: newTopic.topic));

    // Defer notifyListeners to avoid mouse tracker assertion during dropdown interaction
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> broadcastNews(BuildContext context) async {
    if (headlineController.text.isEmpty) {
      return;
    }

    if (headlineController.text.length > 64) {
      showSnackBar(context, 'Headline must be 64 characters or less');
      return;
    }

    try {
      await _api.misc.broadcastNews(topic!.topic, headlineController.text, contentController.text);
      if (!context.mounted) return;
      showSnackBar(context, 'news broadcast successfully!');
      Navigator.of(context).pop();
    } catch (e) {
      showSnackBar(context, 'could not broadcast news: $e');
    }
  }

  @override
  void dispose() {
    headlineController.removeListener(notifyListeners);
    headlineController.dispose();
    contentController.removeListener(notifyListeners);
    contentController.dispose();
    super.dispose();
  }
}

class NewsOverviewView extends StatelessWidget {
  final CoinNews news;

  const NewsOverviewView({
    super.key,
    required this.news,
  });

  @override
  Widget build(BuildContext context) {
    return SailText.primary12(news.content);
  }
}

class ManageNewsSubscriptionsView extends StatelessWidget {
  const ManageNewsSubscriptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ManageNewsSubscriptionsViewModel>.reactive(
      viewModelBuilder: () => ManageNewsSubscriptionsViewModel(),
      builder: (context, viewModel, child) {
        return SizedBox(
          height: 400,
          child: InlineTabBar(
            tabs: [
              SingleTabItem(
                label: 'Your Topics',
                child: _YourTopicsTab(viewModel: viewModel),
              ),
              SingleTabItem(
                label: 'Subscribe',
                child: _SubscribeTab(viewModel: viewModel),
              ),
              SingleTabItem(
                label: 'Create Topic',
                child: _CreateTopicTab(viewModel: viewModel),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _YourTopicsTab extends StatelessWidget {
  final ManageNewsSubscriptionsViewModel viewModel;

  const _YourTopicsTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SailTable(
            getRowId: (index) => viewModel.topics[index].topic,
            headerBuilder: (context) => [
              const SailTableHeaderCell(name: 'Name'),
              const SailTableHeaderCell(name: 'Identifier'),
              const SailTableHeaderCell(name: 'Status'),
            ],
            rowBuilder: (context, row, selected) {
              final topic = viewModel.topics[row];
              return [
                SailTableCell(value: topic.name),
                SailTableCell(value: topic.topic, monospace: true),
                SailTableCell(
                  value: topic.confirmed ? 'Confirmed' : 'Pending',
                  textColor: topic.confirmed ? context.sailTheme.colors.success : context.sailTheme.colors.orangeLight,
                ),
              ];
            },
            rowCount: viewModel.topics.length,
            emptyPlaceholder: 'No topics subscribed',
            drawGrid: true,
            onDoubleTap: (rowId) {
              final topic = viewModel.topics.firstWhere((t) => t.topic == rowId);
              if (topic.txid.isNotEmpty) {
                showTransactionDetails(context, topic.txid);
              }
            },
          ),
        ),
        SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            SailButton(
              label: 'Export',
              variant: ButtonVariant.secondary,
              onPressed: () async => viewModel.exportTopics(context),
            ),
            SailButton(
              label: 'Import',
              variant: ButtonVariant.secondary,
              onPressed: () async => viewModel.importTopics(context),
            ),
            const Spacer(),
            SailButton(
              label: 'Restore Defaults',
              variant: ButtonVariant.secondary,
              onPressed: () async => viewModel.restoreDefaults(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _SubscribeTab extends StatelessWidget {
  final ManageNewsSubscriptionsViewModel viewModel;

  const _SubscribeTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SailText.secondary13('Add news topic by URL:'),
        SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            Expanded(
              child: SailTextField(
                controller: viewModel.urlController,
                hintText: 'Enter URL e.g. 7{a1a1a1a1}US Weekly',
              ),
            ),
            SailButton(
              label: 'Paste',
              variant: ButtonVariant.secondary,
              onPressed: () async => viewModel.pasteUrl(),
            ),
            SailButton(
              label: 'Add',
              onPressed: viewModel.urlController.text.isNotEmpty ? () async => viewModel.addFromUrl(context) : null,
            ),
          ],
        ),
        const SailSpacing(SailStyleValues.padding16),
        SailText.secondary12(
          'URL format: {days}{identifier}Name\n'
          'Example: 7{a1a1a1a1}US Weekly means a topic named "US Weekly" with identifier a1a1a1a1 and 7 day retention',
          color: context.sailTheme.colors.textTertiary,
        ),
      ],
    );
  }
}

class _CreateTopicTab extends StatelessWidget {
  final ManageNewsSubscriptionsViewModel viewModel;

  const _CreateTopicTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final pendingTopics = viewModel.topics.where((t) => !t.confirmed).toList();

    return SingleChildScrollView(
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SailTextField(
            label: 'Title',
            controller: viewModel.nameController,
            hintText: 'Enter title (e.g. "US Weekly")',
          ),
          SailTextField(
            label: 'Header Bytes (8 hex chars to identify this news type)',
            controller: viewModel.identifierController,
            hintText: 'Enter header bytes e.g. A1A1A1A1',
          ),
          SailButton(
            label: 'Create Topic',
            onPressed: viewModel.canCreate ? () async => viewModel.createTopic(context) : null,
          ),
          if (pendingTopics.isNotEmpty) ...[
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13('Pending Topics (awaiting confirmation)'),
            ...pendingTopics.map(
              (topic) => InkWell(
                onDoubleTap: () => showTransactionDetails(context, topic.txid),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: context.sailTheme.colors.backgroundSecondary,
                    borderRadius: SailStyleValues.borderRadius,
                  ),
                  child: SailRow(
                    spacing: SailStyleValues.padding08,
                    children: [
                      SailText.primary13(topic.name),
                      SailText.secondary12('(${topic.topic})'),
                      const Spacer(),
                      SailText.secondary12(
                        'double-click to view tx',
                        italic: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ManageNewsSubscriptionsViewModel extends BaseViewModel {
  final NewsProvider _newsProvider = GetIt.I.get<NewsProvider>();
  final BitwindowRPC _api = GetIt.I.get<BitwindowRPC>();

  List<Topic> get topics => _newsProvider.topics;

  final TextEditingController identifierController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController urlController = TextEditingController();

  bool get canCreate =>
      identifierController.text.isNotEmpty && nameController.text.isNotEmpty && identifierController.text.length == 8;

  ManageNewsSubscriptionsViewModel() {
    _newsProvider.addListener(notifyListeners);
    identifierController.addListener(notifyListeners);
    nameController.addListener(notifyListeners);
    urlController.addListener(notifyListeners);
  }

  Future<void> createTopic(BuildContext context) async {
    if (identifierController.text.isEmpty || nameController.text.isEmpty) {
      return;
    }
    if (identifierController.text.length != 8) {
      showSnackBar(context, 'Identifier must be exactly 8 hex characters');
      return;
    }
    final hexRegex = RegExp(r'^[0-9A-Fa-f]+$');
    if (!hexRegex.hasMatch(identifierController.text)) {
      showSnackBar(context, 'Identifier must contain only valid hex characters (0-9, A-F)');
      return;
    }
    if (nameController.text.length > 20) {
      showSnackBar(context, 'Name must be 20 characters or less');
      return;
    }

    try {
      final response = await _api.misc.createTopic(identifierController.text, nameController.text);
      await _newsProvider.fetch();
      if (!context.mounted) return;
      showSnackBar(context, 'Topic created! txid: ${response.txid.substring(0, 8)}...');
      identifierController.clear();
      nameController.clear();
    } catch (e) {
      showSnackBar(context, 'Could not create topic: $e');
    }
  }

  Future<void> pasteUrl() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      urlController.text = data!.text!;
    }
  }

  Future<void> addFromUrl(BuildContext context) async {
    final url = urlController.text.trim();
    if (url.isEmpty) return;

    // Parse URL format: {days}{identifier}Name
    // Example: 7{a1a1a1a1}US Weekly
    final regex = RegExp(r'^(\d+)\{([a-fA-F0-9]{8})\}(.+)$');
    final match = regex.firstMatch(url);

    if (match == null) {
      showSnackBar(context, 'Invalid URL format. Expected: {days}{identifier}Name');
      return;
    }

    final identifier = match.group(2)!;
    final name = match.group(3)!;

    try {
      final response = await _api.misc.createTopic(identifier, name);
      await _newsProvider.fetch();
      if (!context.mounted) return;
      showSnackBar(context, 'Subscribed to "$name"! txid: ${response.txid.substring(0, 8)}...');
      urlController.clear();
    } catch (e) {
      showSnackBar(context, 'Could not subscribe: $e');
    }
  }

  Future<void> exportTopics(BuildContext context) async {
    final urls = topics.map((t) => '7{${t.topic}}${t.name}').join('\n');
    await Clipboard.setData(ClipboardData(text: urls));
    if (!context.mounted) return;
    showSnackBar(context, 'Topics exported to clipboard');
  }

  Future<void> importTopics(BuildContext context) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null || data!.text!.isEmpty) {
      if (!context.mounted) return;
      showSnackBar(context, 'Clipboard is empty');
      return;
    }

    final lines = data.text!.split('\n').where((l) => l.trim().isNotEmpty).toList();
    var imported = 0;
    var failed = 0;

    for (final line in lines) {
      final regex = RegExp(r'^(\d+)\{([a-fA-F0-9]{8})\}(.+)$');
      final match = regex.firstMatch(line.trim());

      if (match != null) {
        final identifier = match.group(2)!;
        final name = match.group(3)!;

        // Check if already subscribed
        if (topics.any((t) => t.topic == identifier)) {
          continue;
        }

        try {
          await _api.misc.createTopic(identifier, name);
          imported++;
        } catch (e) {
          failed++;
        }
      } else {
        failed++;
      }
    }

    await _newsProvider.fetch();
    if (!context.mounted) return;

    if (imported > 0) {
      showSnackBar(context, 'Imported $imported topic(s)${failed > 0 ? ', $failed failed' : ''}');
    } else if (failed > 0) {
      showSnackBar(context, 'Failed to import $failed topic(s)');
    } else {
      showSnackBar(context, 'No new topics to import');
    }
  }

  Future<void> restoreDefaults(BuildContext context) async {
    // Default topics from mainchain-deprecated
    const defaults = [
      ('a1a1a1a1', 'US Weekly'),
      ('a2a2a2a2', 'Japan Weekly'),
    ];

    var restored = 0;
    for (final (identifier, name) in defaults) {
      if (!topics.any((t) => t.topic == identifier)) {
        try {
          await _api.misc.createTopic(identifier, name);
          restored++;
        } catch (e) {
          // Ignore errors for defaults
        }
      }
    }

    await _newsProvider.fetch();
    if (!context.mounted) return;

    if (restored > 0) {
      showSnackBar(context, 'Restored $restored default topic(s)');
    } else {
      showSnackBar(context, 'All default topics already exist');
    }
  }

  @override
  void dispose() {
    _newsProvider.removeListener(notifyListeners);
    identifierController.removeListener(notifyListeners);
    identifierController.dispose();
    nameController.removeListener(notifyListeners);
    nameController.dispose();
    urlController.removeListener(notifyListeners);
    urlController.dispose();
    super.dispose();
  }
}

class NewGraffitiView extends StatelessWidget {
  const NewGraffitiView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NewGraffitiViewModel>.reactive(
      viewModelBuilder: () => NewGraffitiViewModel(),
      builder: (context, viewModel, child) {
        return SailColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: SailStyleValues.padding16,
          mainAxisSize: MainAxisSize.min,
          leadingSpacing: true,
          children: [
            SailTextField(
              label: 'Message',
              controller: viewModel.messageController,
              hintText: 'Enter a message',
              size: TextFieldSize.small,
            ),
            SailButton(
              label: 'Broadcast',
              onPressed: () => viewModel.createGraffiti(context),
              disabled: viewModel.messageController.text.isEmpty,
            ),
          ],
        );
      },
    );
  }
}

class NewGraffitiViewModel extends BaseViewModel {
  final TextEditingController messageController = TextEditingController();
  final BitwindowRPC _api = GetIt.I<BitwindowRPC>();
  WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();

  NewGraffitiViewModel() {
    messageController.addListener(notifyListeners);
  }

  Future<void> createGraffiti(BuildContext context) async {
    if (messageController.text.isEmpty) {
      return;
    }

    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');

      final address = await _api.wallet.getNewAddress(walletId);
      final _ = await _api.wallet.sendTransaction(
        walletId,
        {address: 10000}, // 0.0001 BTC
        opReturnMessage: messageController.text,
        feeSatPerVbyte: 1,
      );

      if (!context.mounted) return;

      showSnackBar(context, 'graffiti broadcast successfully!');
      messageController.clear();
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, 'could not broadcast graffiti: $e');
    }
  }

  @override
  void dispose() {
    messageController.removeListener(notifyListeners);
    messageController.dispose();
    super.dispose();
  }
}

class GraffitiExplorerView extends StatelessWidget {
  const GraffitiExplorerView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GraffitiExplorerViewModel>.reactive(
      viewModelBuilder: () => GraffitiExplorerViewModel(),
      builder: (context, viewModel, child) {
        final hasFilters =
            viewModel.fromDate != null || viewModel.toDate != null || viewModel.searchController.text.isNotEmpty;

        return SailCard(
          title: 'Graffiti Explorer',
          subtitle: 'Browse blockchain graffiti and OP_RETURN data',
          widgetHeaderEnd: SailButton(
            label: 'New Graffiti',
            onPressed: () => newGraffitiDialog(context),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate available height for the table (total height minus filter row and spacing)
              final tableHeight = constraints.maxHeight.isFinite ? constraints.maxHeight - 60 : 500.0;

              return SailColumn(
                spacing: SailStyleValues.padding16,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SailRow(
                    spacing: SailStyleValues.padding16,
                    children: [
                      Expanded(
                        flex: 2,
                        child: SailTextField(
                          hintText: 'Search by message or txid...',
                          controller: viewModel.searchController,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 12, right: 8),
                            child: SailSVG.fromAsset(
                              SailSVGAsset.search,
                              color: context.sailTheme.colors.textTertiary,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(maxHeight: 20, maxWidth: 40),
                        ),
                      ),
                      Expanded(
                        child: _DatePickerField(
                          label: 'From',
                          value: viewModel.fromDate,
                          onChanged: viewModel.setFromDate,
                          lastDate: viewModel.toDate ?? DateTime.now(),
                        ),
                      ),
                      Expanded(
                        child: _DatePickerField(
                          label: 'To',
                          value: viewModel.toDate,
                          onChanged: viewModel.setToDate,
                          firstDate: viewModel.fromDate,
                          lastDate: DateTime.now(),
                        ),
                      ),
                      if (hasFilters)
                        SailButton(
                          label: 'Clear',
                          variant: ButtonVariant.secondary,
                          onPressed: () async => viewModel.clearFilters(),
                        ),
                    ],
                  ),
                  SizedBox(
                    height: tableHeight,
                    child: GraffitiTable(
                      entries: viewModel.entries,
                      onSort: viewModel.onSort,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> newGraffitiDialog(BuildContext context) async {
    await widgetDialog(
      context: context,
      title: 'New Graffiti',
      subtitle: 'Write whatever you want and broadcast it to the blockchain',
      child: const NewGraffitiView(),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2009),
          lastDate: lastDate ?? DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: theme.colors.primary,
                  onPrimary: theme.colors.text,
                  surface: theme.colors.background,
                  onSurface: theme.colors.text,
                ),
                dialogTheme: DialogThemeData(backgroundColor: theme.colors.background),
              ),
              child: child!,
            );
          },
        );
        onChanged(picked);
      },
      borderRadius: SailStyleValues.borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colors.backgroundSecondary,
          borderRadius: SailStyleValues.borderRadius,
          border: Border.all(color: theme.colors.border),
        ),
        child: SailRow(
          spacing: SailStyleValues.padding08,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SailText.secondary12(
              value != null ? formatDate(value!) : label,
              color: value != null ? theme.colors.text : theme.colors.textTertiary,
            ),
            SailSVG.fromAsset(
              SailSVGAsset.calendar,
              color: theme.colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class GraffitiExplorerViewModel extends BaseViewModel {
  final NewsProvider _newsProvider = GetIt.I.get<NewsProvider>();
  final TextEditingController searchController = TextEditingController();

  String _sortColumn = 'time';
  bool _sortAscending = false;

  // Date range filter
  DateTime? _fromDate;
  DateTime? _toDate;

  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  List<OPReturn> get allEntries => _newsProvider.opReturns;

  List<OPReturn> get entries {
    var filtered = allEntries.where((entry) {
      // Apply search filter
      if (searchController.text.isNotEmpty) {
        final searchLower = searchController.text.toLowerCase();
        if (!entry.message.toLowerCase().contains(searchLower) && !entry.txid.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Apply date range filter
      final entryDate = entry.createTime.toDateTime();
      if (_fromDate != null) {
        final fromStart = DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
        if (entryDate.isBefore(fromStart)) {
          return false;
        }
      }
      if (_toDate != null) {
        final toEnd = DateTime(_toDate!.year, _toDate!.month, _toDate!.day, 23, 59, 59);
        if (entryDate.isAfter(toEnd)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      dynamic aValue = '';
      dynamic bValue = '';

      switch (_sortColumn) {
        case 'message':
          aValue = a.message;
          bValue = b.message;
          break;
        case 'time':
          aValue = a.createTime.toDateTime().millisecondsSinceEpoch;
          bValue = b.createTime.toDateTime().millisecondsSinceEpoch;
          break;
        case 'height':
          aValue = a.height;
          bValue = b.height;
          break;
        case 'txid':
          aValue = a.txid;
          bValue = b.txid;
          break;
      }

      return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });

    return filtered;
  }

  GraffitiExplorerViewModel() {
    _newsProvider.fetch();
    _newsProvider.addListener(notifyListeners);
    searchController.addListener(notifyListeners);
  }

  void setFromDate(DateTime? date) {
    _fromDate = date;
    notifyListeners();
  }

  void setToDate(DateTime? date) {
    _toDate = date;
    notifyListeners();
  }

  void clearFilters() {
    _fromDate = null;
    _toDate = null;
    searchController.clear();
    notifyListeners();
  }

  void onSort(String column) {
    if (_sortColumn == column) {
      _sortAscending = !_sortAscending;
    } else {
      _sortColumn = column;
      _sortAscending = column != 'time';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _newsProvider.removeListener(notifyListeners);
    searchController.removeListener(notifyListeners);
    searchController.dispose();
    super.dispose();
  }
}

class GraffitiTable extends StatelessWidget {
  final List<OPReturn> entries;
  final Function(String) onSort;

  const GraffitiTable({
    super.key,
    required this.entries,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I<FormatterProvider>();

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => SailTable(
        backgroundColor: theme.colors.backgroundSecondary,
        getRowId: (index) => entries[index].id.toString(),
        headerBuilder: (context) => [
          SailTableHeaderCell(name: 'Time', onSort: () => onSort('time')),
          SailTableHeaderCell(name: 'Height', onSort: () => onSort('height')),
          SailTableHeaderCell(name: 'TXID', onSort: () => onSort('txid')),
          SailTableHeaderCell(name: 'Message', onSort: () => onSort('message')),
        ],
        rowBuilder: (context, row, selected) {
          final entry = entries[row];
          return [
            SailTableCell(value: entry.createTime.toDateTime().toLocal().format()),
            SailTableCell(value: entry.height == 0 ? '-' : entry.height.toString()),
            SailTableCell(value: entry.txid),
            SailTableCell(value: entry.message),
          ];
        },
        rowCount: entries.length,
        emptyPlaceholder: 'No graffiti found',
        onSort: (columnIndex, ascending) {
          onSort(['message', 'time', 'height'][columnIndex]);
        },
      ),
    );
  }
}

class FireplaceStatsView extends StatelessWidget {
  final String priceLastUpdated;
  final String price;
  final GetFireplaceStatsResponse stats;
  final bool loading;

  const FireplaceStatsView({
    super.key,
    required this.priceLastUpdated,
    required this.price,
    required this.stats,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = min(4, (constraints.maxWidth / 301).ceil());
        double gridSpacing = SailStyleValues.padding16;
        double totalSpacing = gridSpacing * (crossAxisCount - 1);
        double cardWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
        double desiredCardHeight = 128; // Set your ideal card height here

        double childAspectRatio = cardWidth / desiredCardHeight;

        List<Widget> cardList = [
          FireplaceStat(
            title: 'Bitcoin Price',
            subtitle: 'Last updated $priceLastUpdated',
            value: price,
            bitcoinAmount: true,
            icon: SailSVGAsset.dollarSign,
            loading: loading,
          ),
          FireplaceStat(
            title: 'New transactions',
            value: stats.transactionCount24h.toString(),
            subtitle: 'Last 24 hours',
            icon: SailSVGAsset.iconTransactions,
            loading: loading,
          ),
          FireplaceStat(
            title: 'New coinnews',
            value: stats.coinnewsCount7d.toString(),
            subtitle: 'Last 7 days',
            icon: SailSVGAsset.newspaper,
            loading: loading,
          ),
          FireplaceStat(
            title: 'Number of blocks',
            value: stats.blockCount24h.toString(),
            subtitle: 'Last 24 hours',
            icon: SailSVGAsset.blocks,
            loading: loading,
          ),
        ];

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: gridSpacing,
          mainAxisSpacing: gridSpacing,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: childAspectRatio,
          children: cardList,
        );
      },
    );
  }
}
