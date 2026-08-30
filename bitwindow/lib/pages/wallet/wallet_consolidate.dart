import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/providers/coin_selection_provider.dart';
import 'package:bitwindow/providers/consolidation_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/utils/consolidation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

/// Why consolidation cannot run on [wallet], or null when it can.
///
/// Consolidation broadcasts on its own. A wallet that cannot sign on its own
/// must not start one, because the send fails after the coins already froze.
String? consolidationBlockReason(WalletData? wallet) {
  if (wallet == null) {
    return 'No wallet is active.';
  }
  if (wallet.isWatchOnly) {
    return 'This wallet is watch-only. It holds no private key, so BitWindow cannot sign a consolidation.';
  }
  if (wallet.isMultisig) {
    return 'This wallet is a multisig wallet. Each transaction needs a signature from every cosigner, '
        'so build the transaction in the Multisig Lounge instead.';
  }
  return null;
}

/// What the table selects before the user ticks a single coin.
enum _SelectionBase { limit, all, none }

/// Merges many small coins into one, in transactions the standard size limit
/// caps.
class ConsolidateTab extends StatefulWidget {
  const ConsolidateTab({super.key});

  @override
  State<ConsolidateTab> createState() => _ConsolidateTabState();
}

class _ConsolidateTabState extends State<ConsolidateTab> {
  TransactionProvider get _txProvider => GetIt.I<TransactionProvider>();
  CoinSelectionProvider get _coinSelection => GetIt.I<CoinSelectionProvider>();
  ConsolidationProvider get _consolidation => GetIt.I<ConsolidationProvider>();
  WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();
  FormatterProvider get _formatter => GetIt.I<FormatterProvider>();

  /// The values the size slider steps through, in satoshis.
  static const List<int> limitSteps = [
    1000,
    5000,
    10000,
    50000,
    100000,
    500000,
    1000000,
    5000000,
    10000000,
    100000000,
  ];

  int _limitIndex = 4;
  int _feeRate = 1;
  bool _hideFrozen = false;
  _SelectionBase _base = _SelectionBase.limit;
  final Map<String, bool> _overrides = {};
  String? _error;

  int get _limitSats => limitSteps[_limitIndex];

  List<UnspentOutput> get _coins => _txProvider.utxos;

  bool _isFrozen(String outpoint) => _coinSelection.isFrozen(outpoint);

  List<UnspentOutput> get _visibleCoins {
    final coins = _coins.where((c) => !_hideFrozen || !_isFrozen(c.output)).toList();
    coins.sort((a, b) => a.valueSats.compareTo(b.valueSats));
    return coins;
  }

  /// The limit picks the coins. A tick or an untick beats the limit.
  bool _isSelected(UnspentOutput coin) {
    if (_isFrozen(coin.output)) {
      return false;
    }
    final override = _overrides[coin.output];
    if (override != null) {
      return override;
    }
    switch (_base) {
      case _SelectionBase.limit:
        return coin.valueSats.toInt() <= _limitSats;
      case _SelectionBase.all:
        return true;
      case _SelectionBase.none:
        return false;
    }
  }

  List<UnspentOutput> get _selectedCoins => _coins.where(_isSelected).toList();

  /// The output the consolidation pays to. It must match the address the send
  /// asks for, or the size and the fee read wrong.
  CoinScriptKind get _destinationKind {
    final wallet = _walletReader.activeWallet;
    if (wallet == null) {
      return CoinScriptKind.p2tr;
    }
    return destinationKindFor(wallet.defaultAddressType);
  }

  ConsolidationPlan get _plan => planConsolidation(
    coins: _selectedCoins,
    feeRateSatPerVbyte: _feeRate,
    frozenOutpoints: _coinSelection.frozenOutpoints,
    destinationKind: _destinationKind,
  );

  void _setBase(_SelectionBase base) {
    setState(() {
      _base = base;
      _overrides.clear();
    });
  }

  void _toggle(String outpoint, bool value) {
    setState(() => _overrides[outpoint] = value);
  }

  Future<void> _start() async {
    final blocked = consolidationBlockReason(_walletReader.activeWallet);
    if (blocked != null) {
      setState(() => _error = blocked);
      return;
    }
    final walletId = _walletReader.activeWalletId;
    if (walletId == null) {
      setState(() => _error = 'No wallet is active.');
      return;
    }

    setState(() => _error = null);
    try {
      await _consolidation.start(walletId: walletId, plan: _plan);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_txProvider, _coinSelection, _consolidation, _formatter]),
      builder: (context, child) {
        final blocked = consolidationBlockReason(_walletReader.activeWallet);
        if (blocked != null) {
          return SailCard(
            title: 'Consolidate',
            subtitle: 'Merge many small coins into one coin.',
            child: SailText.secondary13(blocked),
          );
        }

        return SingleChildScrollView(
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_consolidation.runs.isNotEmpty) _ProgressCard(consolidation: _consolidation),
              SailRow(
                spacing: SailStyleValues.padding16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SailColumn(
                      spacing: SailStyleValues.padding16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_limitCard(), _coinsCard()],
                    ),
                  ),
                  SizedBox(width: 360, child: _planCard()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _limitCard() {
    final belowLimit = _coins.where((c) => c.valueSats.toInt() <= _limitSats).toList();
    final belowSats = belowLimit.fold<int>(0, (sum, c) => sum + c.valueSats.toInt());

    return SailCard(
      title: 'Coin size limit',
      subtitle: 'Select every coin below this value.',
      widgetHeaderEnd: SailText.primary15(_formatter.formatSats(_limitSats), bold: true),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailSlider(
            value: _limitIndex.toDouble(),
            min: 0,
            max: (limitSteps.length - 1).toDouble(),
            divisions: limitSteps.length - 1,
            onChanged: (value) {
              _limitIndex = value.round();
              _setBase(_SelectionBase.limit);
            },
          ),
          SailRow(
            spacing: SailStyleValues.padding12,
            children: [
              Expanded(
                child: SailText.secondary12('${belowLimit.length} coins are below the limit'),
              ),
              SailText.secondary12(_formatter.formatSats(belowSats)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _coinsCard() {
    final coins = _visibleCoins;
    final frozenCount = _coins.where((c) => _isFrozen(c.output)).length;

    return SailCard(
      title: 'Coins',
      subtitle: '${_selectedCoins.length} of ${_coins.length} coins selected',
      bottomPadding: false,
      widgetHeaderEnd: SailRow(
        spacing: SailStyleValues.padding08,
        children: [
          SailCheckbox(
            value: _hideFrozen,
            label: 'Hide frozen ($frozenCount)',
            onChanged: (value) => setState(() => _hideFrozen = value),
          ),
          SailButton(
            label: 'Select all',
            variant: ButtonVariant.outline,
            onPressed: () async => _setBase(_SelectionBase.all),
          ),
          SailButton(
            label: 'Clear',
            variant: ButtonVariant.ghost,
            onPressed: () async => _setBase(_SelectionBase.none),
          ),
        ],
      ),
      child: SizedBox(
        height: 420,
        child: SailTable(
          getRowId: (index) => coins[index].output,
          rowCount: coins.length,
          emptyPlaceholder: 'This wallet holds no coins',
          headerBuilder: (context) => const [
            SailTableHeaderCell(name: ''),
            SailTableHeaderCell(name: 'Date'),
            SailTableHeaderCell(name: 'Coin'),
            SailTableHeaderCell(name: 'Address'),
            SailTableHeaderCell(name: 'Label'),
            SailTableHeaderCell(name: 'Value'),
          ],
          rowBuilder: (context, row, selected) {
            final coin = coins[row];
            final frozen = _isFrozen(coin.output);

            return [
              SailTableCell(
                value: '',
                child: SailCheckbox(
                  value: _isSelected(coin),
                  enabled: !frozen,
                  onChanged: frozen ? null : (value) => _toggle(coin.output, value),
                ),
              ),
              SailTableCell(
                value: coin.hasReceivedAt() ? formatDate(coin.receivedAt.toDateTime().toLocal()) : '—',
              ),
              SailTableCell(
                value: '${coin.output.substring(0, 6)}..:${coin.output.split(':').last}',
                copyValue: coin.output,
              ),
              SailTableCell(value: coin.address, copyValue: coin.address),
              SailTableCell(value: frozen ? 'Frozen' : _coinSelection.getLabel(coin.output)),
              SailTableCell(value: _formatter.formatSats(coin.valueSats.toInt()), monospace: true),
            ];
          },
        ),
      ),
    );
  }

  Widget _planCard() {
    final plan = _plan;
    final tooSmall = plan.skippedFor(ConsolidationSkipReason.tooSmall).length;
    final unknownSize = plan.skippedFor(ConsolidationSkipReason.unknownSize).length;
    final running = _consolidation.running;

    return SailCard(
      title: 'Plan',
      error: _error,
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailRow(
            spacing: SailStyleValues.padding12,
            children: [
              Expanded(child: SailText.secondary13('Fee rate')),
              SizedBox(
                width: 130,
                child: SailDropdownButton<int>(
                  value: _feeRate,
                  items: const [
                    1,
                    2,
                    5,
                    10,
                    20,
                    50,
                  ].map((rate) => SailDropdownItem<int>(value: rate, label: '$rate sat/vB')).toList(),
                  onChanged: (value) => setState(() => _feeRate = value ?? 1),
                ),
              ),
            ],
          ),
          _planRow('Coins', '${plan.coinCount}'),
          _planRow('Transactions', '${plan.transactionCount}'),
          _planRow('Largest transaction', '${plan.largestVbytes} vB'),
          _planRow('Total fee', _formatter.formatSats(plan.totalFeeSats)),
          _planRow('You get', _formatter.formatSats(plan.totalOutputSats)),
          _note('A new address for each transaction. Every address belongs to this wallet.'),
          _note(
            'A transaction stops at $consolidationTargetVbytes vB, below the $maxStandardTxVbytes vB standard limit. '
            'A legacy coin takes more space than a taproot coin, so the size caps a transaction, not the coin count.',
          ),
          _note(
            'BitWindow freezes each coin until its transaction confirms. '
            'The wallet holds ${_coinsAfter(plan)} coins after this run. '
            'Run the flow again to merge them further.',
          ),
          if (tooSmall > 0)
            _note('$tooSmall coins are worth less than the fee to spend them. The plan leaves them out.'),
          if (unknownSize > 0)
            _note(
              '$unknownSize coins carry a script BitWindow cannot size. '
              'A transaction that holds them could pass the size limit, so the plan leaves them out.',
            ),
          SizedBox(
            width: double.infinity,
            child: SailButton(
              label: 'Consolidate ${plan.coinCount} coins',
              disabled: plan.isEmpty || running,
              loading: running,
              onPressed: _start,
            ),
          ),
        ],
      ),
    );
  }

  /// The coins the wallet holds after every transaction confirms. Each merged
  /// coin becomes one output, and every coin outside the plan stays.
  int _coinsAfter(ConsolidationPlan plan) => _coins.length - plan.coinCount + plan.transactionCount;

  Widget _planRow(String label, String value) => SailRow(
    spacing: SailStyleValues.padding12,
    children: [
      Expanded(child: SailText.secondary13(label)),
      SailText.primary13(value, bold: true),
    ],
  );

  Widget _note(String text) {
    final theme = SailTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadiusSmall,
      ),
      child: SailText.secondary12(text),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final ConsolidationProvider consolidation;

  const _ProgressCard({required this.consolidation});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();
    final runs = consolidation.runs;

    return SailCard(
      title: 'Consolidation runs',
      subtitle:
          'BitWindow sent ${consolidation.sentCount} of ${runs.length} transactions. '
          '${consolidation.confirmedCount} transactions confirmed.',
      widgetHeaderEnd: SailRow(
        spacing: SailStyleValues.padding08,
        children: [
          if (consolidation.running)
            SailButton(
              label: 'Stop',
              variant: ButtonVariant.outline,
              onPressed: () async => consolidation.requestStop(),
            ),
          // Clear refuses while a run holds frozen coins, because those runs
          // are the only record of them.
          if (!consolidation.running && !runs.any((r) => r.coinsFrozen))
            SailButton(
              label: 'Clear',
              variant: ButtonVariant.ghost,
              onPressed: () async => consolidation.clear(),
            ),
        ],
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final run in runs)
            SailRow(
              spacing: SailStyleValues.padding12,
              children: [
                SizedBox(width: 110, child: SailText.primary13('${run.index + 1} of ${runs.length}')),
                SizedBox(width: 110, child: SailText.secondary13('${run.coinCount} coins')),
                SizedBox(width: 110, child: SailText.secondary13('${run.vbytes} vB')),
                Expanded(child: SailText.secondary13(formatter.formatSats(run.outputSats))),
                SailText.secondary12(_statusLabel(run.status)),
                if (run.txid != null)
                  SailButton(
                    label: 'Show',
                    variant: ButtonVariant.ghost,
                    onPressed: () async => showTransactionDetails(context, run.txid!),
                  ),
                if (run.canUnfreeze)
                  SailButton(
                    label: 'Unfreeze',
                    variant: ButtonVariant.ghost,
                    onPressed: () async => consolidation.unfreeze(run),
                  ),
              ],
            ),
          for (final run in runs.where((r) => r.error != null))
            SailText.secondary12('Transaction ${run.index + 1}: ${run.error}'),
        ],
      ),
    );
  }

  String _statusLabel(ConsolidationRunStatus status) {
    switch (status) {
      case ConsolidationRunStatus.queued:
        return 'Waits';
      case ConsolidationRunStatus.sending:
        return 'Sends';
      case ConsolidationRunStatus.pending:
        return 'In the mempool';
      case ConsolidationRunStatus.confirmed:
        return 'Confirmed';
      case ConsolidationRunStatus.failed:
        return 'Failed';
      case ConsolidationRunStatus.stopped:
        return 'Stopped';
    }
  }
}
