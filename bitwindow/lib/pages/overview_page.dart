import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/env.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/widgets/coinnews.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/providers/price_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const QtPage(
      child: SingleChildScrollView(
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SailColumn(
              spacing: SailStyleValues.padding16,
              children: [
                FireplaceStats(),
                CoinNewsView(),
                TransactionsView(),
              ],
            ),
          ],
        ),
      ),
    );
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
      builder: (context, model, child) => SailRow(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 16,
        children: [
          Expanded(
            child: FireplaceStat(
              title: 'Bitcoin Price',
              subtitle: 'Last updated ${model.priceLastUpdated}',
              value: model.price,
              bitcoinAmount: true,
              icon: SailSVGAsset.dollarSign,
            ),
          ),
          Expanded(
            child: FireplaceStat(
              title: 'New transactions',
              value: model.stats?.transactionCount24h.toString() ?? '0',
              subtitle: 'Last 24 hours',
              icon: SailSVGAsset.iconTransactions,
            ),
          ),
          Expanded(
            child: FireplaceStat(
              title: 'New coinnews',
              value: model.stats?.coinnewsCount7d.toString() ?? '0',
              subtitle: 'Last 7 days',
              icon: SailSVGAsset.newspaper,
            ),
          ),
          Expanded(
            child: FireplaceStat(
              title: 'Number of blocks',
              value: model.stats?.blockCount24h.toString() ?? '0',
              subtitle: 'Last 24 hours',
              icon: SailSVGAsset.blocks,
            ),
          ),
        ],
      ),
    );
  }
}

class FireplaceStat extends ViewModelWidget<FireplaceViewModel> {
  final String title;
  final String subtitle;
  final String value;
  final SailSVGAsset icon;
  final bool bitcoinAmount;

  const FireplaceStat({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    this.bitcoinAmount = false,
  });

  @override
  Widget build(BuildContext context, FireplaceViewModel viewModel) {
    return SailCardStats(
      title: title,
      subtitle: subtitle,
      value: value,
      icon: icon,
      loading: LoadingDetails(
        enabled: viewModel.loading,
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
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
            ),
            const SizedBox(width: SailStyleValues.padding16),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
            ),
          ],
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
            value: entry.confirmedInBlock.height == 0 ? '-' : entry.confirmedInBlock.height.toString(),
          ),
        ];
      },
      rowCount: widget.entries.length,
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
      drawGrid: true,
      sortColumnIndex: ['time', 'height', 'hash'].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(['time', 'height', 'hash'][columnIndex]);
      },
    );
  }
}

class CoinNewsViewModel extends BaseViewModel {
  final NewsProvider _newsProvider = GetIt.I.get<NewsProvider>();
  List<CoinNews> get leftEntries => _newsProvider.news.where((news) => news.topic == leftTopic.topic).toList();
  List<CoinNews> get rightEntries => _newsProvider.news.where((news) => news.topic == rightTopic.topic).toList();

  List<Topic> get topics => _newsProvider.topics;

  bool _sortAscending = true;
  String _sortColumn = 'date';

  Topic get _defaultLeftTopic => topics[0]; // US Weekly topic
  Topic get _defaultRightTopic => topics[1]; // Japan Weekly topic

  Topic? _leftTopic;
  Topic? _rightTopic;

  Topic get leftTopic => _leftTopic ?? _defaultLeftTopic;
  Topic get rightTopic => _rightTopic ?? _defaultRightTopic;

  CoinNewsViewModel() {
    _newsProvider.addListener(notifyListeners);
  }

  void setLeftTopic(Topic? topic) {
    if (topic == null) {
      return;
    }

    _leftTopic = topic;
    notifyListeners();
  }

  void setRightTopic(Topic? topic) {
    if (topic == null) {
      return;
    }

    _rightTopic = topic;
    notifyListeners();
  }

  void sortEntries(String column) {
    if (_sortColumn == column) {
      _sortAscending = !_sortAscending;
    } else {
      _sortColumn = column;
      _sortAscending = true;
    }
    notifyListeners();
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
    title: 'Create Topic',
    subtitle: 'Create a new topic, that you and others can subscribe to, and post news for.',
    child: const CreateTopicView(),
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
                      label: topic.name,
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
              ),
              SailButton(
                label: 'Broadcast',
                onPressed: () => viewModel.broadcastNews(context),
                disabled: viewModel.headlineController.text.isEmpty || viewModel.headlineController.text.length > 64,
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
    notifyListeners();
  }

  void setTopic(Topic? newTopic) async {
    if (newTopic == null) {
      return;
    }

    topic = newTopic;
    // Persist the selected topic
    await _settings.setValue(LastUsedTopicSetting(newValue: newTopic.topic));
    notifyListeners();
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

class CreateTopicView extends StatelessWidget {
  const CreateTopicView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateTopicViewModel>.reactive(
      viewModelBuilder: () => CreateTopicViewModel(),
      builder: (context, viewModel, child) {
        return SailColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: SailStyleValues.padding16,
          mainAxisSize: MainAxisSize.min,
          leadingSpacing: true,
          children: [
            SailTextField(
              label: 'Identifier (exactly 8 hex characters)',
              controller: viewModel.identifierController,
              hintText: 'Enter a hex-identifier',
              size: TextFieldSize.small,
            ),
            SailTextField(
              label: 'Name (max 20 characters)',
              controller: viewModel.nameController,
              hintText: 'Enter a name (e.g. "US Weekly")',
              size: TextFieldSize.small,
            ),
            SailButton(
              label: 'Create',
              onPressed: () => viewModel.createTopic(context),
              disabled: viewModel.identifierController.text.isEmpty ||
                  viewModel.nameController.text.isEmpty ||
                  viewModel.identifierController.text.length != 8,
            ),
          ],
        );
      },
    );
  }
}

class CreateTopicViewModel extends BaseViewModel {
  final NewsProvider _newsProvider = GetIt.I.get<NewsProvider>();
  final BitwindowRPC _api = GetIt.I.get<BitwindowRPC>();

  late Topic topic;

  List<Topic> get topics => _newsProvider.topics;

  final TextEditingController identifierController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  CreateTopicViewModel() {
    identifierController.addListener(notifyListeners);
    nameController.addListener(notifyListeners);
  }

  Future<void> createTopic(BuildContext context) async {
    if (identifierController.text.isEmpty || nameController.text.isEmpty) {
      return;
    }
    if (identifierController.text.length != 8) {
      showSnackBar(context, 'identifier must be exactly 8 characters');
      return;
    }
    final hexRegex = RegExp(r'^[0-9A-Fa-f]+$');
    if (!hexRegex.hasMatch(identifierController.text)) {
      showSnackBar(context, 'identifier must contain only valid hex characters (0-9, A-F)');
      return;
    }
    if (nameController.text.length > 20) {
      showSnackBar(context, 'name must be 20 characters or less');
      return;
    }

    try {
      await _api.misc.createTopic(identifierController.text, nameController.text);
      if (!context.mounted) return;
      showSnackBar(context, 'topic created successfully!');
    } catch (e) {
      showSnackBar(context, 'could not create topic: $e');
    }
  }

  @override
  void dispose() {
    identifierController.removeListener(notifyListeners);
    identifierController.dispose();
    nameController.removeListener(notifyListeners);
    nameController.dispose();
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

  NewGraffitiViewModel() {
    messageController.addListener(notifyListeners);
  }

  Future<void> createGraffiti(BuildContext context) async {
    if (messageController.text.isEmpty) {
      return;
    }

    try {
      final address = await _api.wallet.getNewAddress();
      final _ = await _api.wallet.sendTransaction(
        {address: 10000}, // 0.0001 BTC
        opReturnMessage: messageController.text,
        fixedFeeSats: 1000,
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
        return SailColumn(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.end,
          leadingSpacing: true,
          children: [
            // add button here, that opens ANOTHER dialog, where you can enter a message.
            SailButton(
              label: 'New Graffiti',
              onPressed: () => newGraffitiDialog(context),
            ),
            Expanded(
              child: GraffitiTable(
                entries: viewModel.entries,
                onSort: viewModel.onSort,
              ),
            ),
          ],
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

class GraffitiExplorerViewModel extends BaseViewModel {
  final NewsProvider _newsProvider = GetIt.I.get<NewsProvider>();

  String _sortColumn = 'time';
  bool _sortAscending = true;
  List<OPReturn> get entries => _newsProvider.opReturns;

  GraffitiExplorerViewModel() {
    _newsProvider.fetch();
    _newsProvider.addListener(notifyListeners);
  }

  void onSort(String column) {
    if (_sortColumn == column) {
      _sortAscending = !_sortAscending;
    } else {
      _sortColumn = column;
      _sortAscending = true;
    }
    _sortEntries();
    notifyListeners();
  }

  void _sortEntries() {
    entries.sort((a, b) {
      dynamic aValue = '';
      dynamic bValue = '';

      switch (_sortColumn) {
        case 'fee':
          aValue = a.feeSats.toInt();
          bValue = b.feeSats.toInt();
          break;
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
      }

      return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  void dispose() {
    _newsProvider.removeListener(notifyListeners);
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

    return SailTable(
      backgroundColor: theme.colors.backgroundSecondary,
      getRowId: (index) => entries[index].id.toString(),
      headerBuilder: (context) => [
        SailTableHeaderCell(name: 'Fee', onSort: () => onSort('fee')),
        SailTableHeaderCell(name: 'Message', onSort: () => onSort('message')),
        SailTableHeaderCell(name: 'TXID', onSort: () => onSort('txid')),
        SailTableHeaderCell(name: 'Time', onSort: () => onSort('time')),
        SailTableHeaderCell(name: 'Height', onSort: () => onSort('height')),
      ],
      rowBuilder: (context, row, selected) {
        final entry = entries[row];
        return [
          SailTableCell(value: formatBitcoin(satoshiToBTC(entry.feeSats.toInt()))),
          SailTableCell(value: entry.message),
          SailTableCell(value: entry.txid),
          SailTableCell(value: entry.createTime.toDateTime().toLocal().format()),
          SailTableCell(value: entry.height == 0 ? '-' : entry.height.toString()),
        ];
      },
      rowCount: entries.length,
      onSort: (columnIndex, ascending) {
        onSort(['fee', 'message', 'time', 'height'][columnIndex]);
      },
    );
  }
}
