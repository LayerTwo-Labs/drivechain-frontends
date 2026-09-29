import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:truthcoin/models/voting.dart';
import 'package:truthcoin/providers/voting_provider.dart';
import 'package:truthcoin/widgets/market_stat_tile.dart';

const double _panelWidth = 348;

/// Below this width the side panel sits under the decisions.
const double _twoColumnWidth = 900;

/// Below this width the vote buttons sit under the question.
const double _wideRowWidth = 700;

@RoutePage()
class VotingDashboardPage extends StatelessWidget {
  const VotingDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VotingDashboardViewModel>.reactive(
      viewModelBuilder: () => VotingDashboardViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        if (model.isLoading && model.currentPeriod == null) {
          return QtPage(
            child: Center(
              child: SailSkeletonizer(
                enabled: true,
                description: 'Voting data loads',
                child: SailText.primary15('Voting data loads'),
              ),
            ),
          );
        }

        return QtPage(
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            children: [
              _Header(model: model),
              _StatTiles(model: model),
              if (model.votingError != null) SailInlineError(model.votingError!),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final panel = [
                      _BallotCard(model: model),
                      _PeriodCard(model: model),
                      _VoterCard(model: model),
                    ];

                    if (constraints.maxWidth < _twoColumnWidth) {
                      return SingleChildScrollView(
                        child: SailColumn(
                          spacing: SailStyleValues.padding12,
                          children: [
                            _DecisionsCard(model: model),
                            ...panel,
                          ],
                        ),
                      );
                    }

                    return SailRow(
                      spacing: SailStyleValues.padding16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(child: _DecisionsCard(model: model)),
                        SizedBox(
                          width: _panelWidth,
                          child: SingleChildScrollView(
                            child: SailColumn(spacing: SailStyleValues.padding12, children: panel),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final VotingDashboardViewModel model;

  const _Header({required this.model});

  @override
  Widget build(BuildContext context) {
    final period = model.currentPeriod;
    final status = model.slotStatus;

    return Wrap(
      spacing: SailStyleValues.padding12,
      runSpacing: SailStyleValues.padding08,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SailColumn(
          spacing: SailStyleValues.padding04,
          children: [
            SailText.primary24('Oracle voting', bold: true),
            SailText.secondary13('You answer every decision slot that your Votecoin covers.'),
          ],
        ),
        if (period != null)
          SailBadge(
            'Period ${period.periodId} · ${period.status}',
            tone: period.isActive ? SailBadgeTone.success : SailBadgeTone.neutral,
          ),
        if (status != null) SailText.secondary13('${status.blocksPerPeriod} blocks per period'),
        SailButton(
          label: 'Refresh',
          variant: ButtonVariant.secondary,
          small: true,
          loading: model.isLoading,
          onPressed: () async => model.loadData(),
        ),
      ],
    );
  }
}

class _StatTiles extends StatelessWidget {
  final VotingDashboardViewModel model;

  const _StatTiles({required this.model});

  @override
  Widget build(BuildContext context) {
    final voter = model.currentVoter;
    final period = model.currentPeriod;
    final participation = voter?.currentPeriodParticipation;

    return MarketStatTileRow(
      tiles: [
        MarketStatTile(
          label: 'Your Votecoin',
          value: voter == null ? '—' : '${voter.votecoinBalance}',
          caption: voter?.isRegistered == true ? 'registered voter' : 'not a registered voter',
        ),
        MarketStatTile(
          label: 'Reputation',
          value: voter?.reputationDisplay ?? '—',
          caption: voter == null ? 'no voter data' : 'accuracy ${voter.accuracyPercent}',
        ),
        MarketStatTile(
          label: 'Ballot',
          value: participation == null
              ? '${model.pendingVotesCount}'
              : '${participation.votesCast} of ${participation.decisionsAvailable}',
          caption: '${model.pendingVotesCount} answers wait for a send',
        ),
        MarketStatTile(
          label: 'Period turnout',
          value: period?.stats.participationPercent ?? '—',
          caption: period == null
              ? 'no period data'
              : '${period.stats.activeVoters} of ${period.stats.totalVoters} voters',
        ),
      ],
    );
  }
}

class _DecisionsCard extends StatelessWidget {
  final VotingDashboardViewModel model;

  const _DecisionsCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final period = model.currentPeriod;
    final decisions = period?.decisions ?? [];

    return SailCard(
      title: period == null ? 'Decisions' : 'Decisions in period ${period.periodId}',
      subtitle: decisions.isEmpty ? 'The period holds no decision.' : null,
      child: SingleChildScrollView(
        child: SailColumn(
          spacing: SailStyleValues.padding12,
          withDivider: true,
          children: [
            for (final decision in decisions)
              _DecisionRow(
                decision: decision,
                value: model.getPendingVote(decision.slotIdHex),
                onChanged: (value) => model.setVote(decision.slotIdHex, value),
              ),
          ],
        ),
      ),
    );
  }
}

class _DecisionRow extends StatelessWidget {
  final DecisionSummary decision;
  final double? value;
  final ValueChanged<double?> onChanged;

  const _DecisionRow({
    required this.decision,
    required this.value,
    required this.onChanged,
  });

  String get _kindLabel {
    if (decision.isScaled) return 'scaled slot';
    if (decision.isCategory) return 'category slot';
    return 'binary slot';
  }

  String get _shortSlot => decision.slotIdHex.length > 8 ? decision.slotIdHex.substring(0, 8) : decision.slotIdHex;

  @override
  Widget build(BuildContext context) {
    final question = SailRow(
      spacing: SailStyleValues.padding12,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        SailBadge(_shortSlot, tone: value == null ? SailBadgeTone.neutral : SailBadgeTone.success),
        Expanded(
          child: SailColumn(
            spacing: SailStyleValues.padding04,
            children: [
              SailText.primary14(decision.question),
              SailText.secondary12('$_kindLabel  ·  ${decision.isStandard ? 'standard' : 'custom'}'),
            ],
          ),
        ),
      ],
    );

    final vote = decision.isScaled
        ? _ScaledVoteInput(value: value, onChanged: onChanged)
        : decision.isCategory
        ? _CategoryVoteInput(options: decision.categoryOptions, value: value, onChanged: onChanged)
        : _BinaryVoteInput(value: value, onChanged: onChanged);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _wideRowWidth) {
          return SailColumn(
            spacing: SailStyleValues.padding08,
            children: [question, vote],
          );
        }

        return SailRow(
          spacing: SailStyleValues.padding12,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(child: question),
            SizedBox(width: 340, child: vote),
          ],
        );
      },
    );
  }
}

class _BallotCard extends StatelessWidget {
  final VotingDashboardViewModel model;

  const _BallotCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final voter = model.currentVoter;

    return SailCard(
      title: 'Your ballot',
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        children: [
          _FactRow(label: 'Answers ready', value: '${model.pendingVotesCount}'),
          _FactRow(label: 'Vote weight', value: voter == null ? '—' : '${voter.votecoinBalance} Votecoin'),
          _FactRow(label: 'Reputation', value: voter?.reputationDisplay ?? '—'),
          if (model.userAddress != null) _FactRow(label: 'Address', value: model.shortAddress),
          SailButton(
            label: 'Submit ballot',
            loading: model.isSubmitting,
            disabled: model.pendingVotesCount == 0,
            onPressed: () async => model.submitVotes(context),
          ),
          SailText.secondary12('One transaction carries every answer of this period.'),
        ],
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final VotingDashboardViewModel model;

  const _PeriodCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final period = model.currentPeriod;
    final status = model.slotStatus;
    if (period == null) {
      return SailCard(
        title: 'Period',
        child: SailText.secondary13('The node reports no voting period.'),
      );
    }

    return SailCard(
      title: 'Period ${period.periodId}',
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        children: [
          _FactRow(label: 'State', value: period.status),
          _FactRow(label: 'Start block', value: '${period.startHeight}'),
          _FactRow(label: 'End block', value: '${period.endHeight}'),
          _FactRow(label: 'Decisions', value: '${period.decisions.length}'),
          _FactRow(label: 'Votes cast', value: '${period.stats.totalVotes}'),
          if (status != null) _FactRow(label: 'Period name', value: status.currentPeriodName),
          if (status?.isTestingMode == true)
            SailAlert(
              variant: SailAlertVariant.warning,
              title: 'Test mode',
              description: 'The node runs short periods for a test.',
            ),
        ],
      ),
    );
  }
}

class _VoterCard extends StatelessWidget {
  final VotingDashboardViewModel model;

  const _VoterCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final voter = model.currentVoter;
    if (voter == null) {
      return SailCard(
        title: 'Voter',
        child: SailText.secondary13('This wallet holds no voter record.'),
      );
    }

    return SailCard(
      title: 'Voter record',
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        children: [
          _FactRow(label: 'Registered', value: voter.isRegistered ? 'yes' : 'no'),
          _FactRow(label: 'Active', value: voter.isActive ? 'yes' : 'no'),
          _FactRow(label: 'Total votes', value: '${voter.totalVotes}'),
          _FactRow(label: 'Periods active', value: '${voter.periodsActive}'),
          _FactRow(label: 'Accuracy', value: voter.accuracyPercent),
          _FactRow(label: 'Registered at block', value: '${voter.registeredAtHeight}'),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  final String label;
  final String value;

  const _FactRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(child: SailText.secondary13(label)),
        SailText.primary13(value, bold: true),
      ],
    );
  }
}

class _BinaryVoteInput extends StatelessWidget {
  final double? value;
  final ValueChanged<double?> onChanged;

  const _BinaryVoteInput({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailRow(
      spacing: SailStyleValues.padding08,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: _VoteButton(
            label: 'Yes',
            isSelected: value == 1.0,
            color: theme.colors.success,
            onTap: () => onChanged(value == 1.0 ? null : 1.0),
          ),
        ),
        Expanded(
          child: _VoteButton(
            label: 'No',
            isSelected: value == 0.0,
            color: theme.colors.error,
            onTap: () => onChanged(value == 0.0 ? null : 0.0),
          ),
        ),
        SizedBox(
          width: 90,
          child: _VoteButton(
            label: 'Abstain',
            isSelected: false,
            color: theme.colors.text,
            onTap: () => onChanged(null),
          ),
        ),
      ],
    );
  }
}

class _CategoryVoteInput extends StatelessWidget {
  final List<String> options;
  final double? value;
  final ValueChanged<double?> onChanged;

  const _CategoryVoteInput({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Wrap(
      spacing: SailStyleValues.padding08,
      runSpacing: SailStyleValues.padding08,
      alignment: WrapAlignment.end,
      children: [
        for (final (index, label) in options.indexed)
          SizedBox(
            width: 160,
            child: _VoteButton(
              label: label,
              isSelected: value == index.toDouble(),
              color: theme.colors.primary,
              onTap: () => onChanged(value == index.toDouble() ? null : index.toDouble()),
            ),
          ),
        SizedBox(
          width: 90,
          child: _VoteButton(
            label: 'Abstain',
            isSelected: false,
            color: theme.colors.text,
            onTap: () => onChanged(null),
          ),
        ),
      ],
    );
  }
}

class _ScaledVoteInput extends StatefulWidget {
  final double? value;
  final ValueChanged<double?> onChanged;

  const _ScaledVoteInput({
    required this.value,
    required this.onChanged,
  });

  @override
  State<_ScaledVoteInput> createState() => _ScaledVoteInputState();
}

class _ScaledVoteInputState extends State<_ScaledVoteInput> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value?.toStringAsFixed(2) ?? '');
  }

  @override
  void didUpdateWidget(_ScaledVoteInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != double.tryParse(controller.text)) {
      controller.text = widget.value?.toStringAsFixed(2) ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: SailTextField(
            controller: controller,
            hintText: 'Value',
            size: TextFieldSize.small,
            textFieldType: TextFieldType.bitcoin,
            onChanged: (text) => widget.onChanged(double.tryParse(text)),
          ),
        ),
        SailButton(
          label: 'Clear',
          variant: ButtonVariant.secondary,
          small: true,
          onPressed: () async {
            controller.clear();
            widget.onChanged(null);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _VoteButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _VoteButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailTappable(
      onTap: () async => onTap(),
      borderRadius: SailStyleValues.borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding08),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : theme.colors.background,
          borderRadius: SailStyleValues.borderRadius,
          border: Border.all(
            color: isSelected ? color : theme.colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: SailText.primary13(
            label,
            bold: isSelected,
            color: isSelected ? color : null,
          ),
        ),
      ),
    );
  }
}

class VotingDashboardViewModel extends BaseViewModel {
  final VotingProvider _votingProvider = GetIt.I.get<VotingProvider>();
  final TruthcoinRPC _rpc = GetIt.I.get<TruthcoinRPC>();

  SlotStatus? get slotStatus => _votingProvider.slotStatus;
  VotingPeriodFull? get currentPeriod => _votingProvider.currentPeriod;
  VoterInfoFull? get currentVoter => _votingProvider.currentVoter;
  bool get isLoading => _votingProvider.isLoading;
  String? get votingError => _votingProvider.error;

  int get pendingVotesCount => _votingProvider.pendingVotes.length;
  bool isSubmitting = false;

  String? userAddress;

  String get shortAddress {
    final address = userAddress ?? '';
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}…${address.substring(address.length - 6)}';
  }

  void init() {
    _votingProvider.addListener(_onProviderChange);
    loadData();
  }

  void _onProviderChange() {
    notifyListeners();
  }

  Future<void> loadData() async {
    try {
      final addresses = await _rpc.getWalletAddresses();
      if (addresses.isNotEmpty) {
        userAddress = addresses.first;
      }
    } catch (e) {
      userAddress = null;
    }

    await _votingProvider.loadDashboardData(userAddress);
  }

  double? getPendingVote(String decisionId) {
    return _votingProvider.getPendingVote(decisionId);
  }

  void setVote(String decisionId, double? value) {
    if (value == null) {
      _votingProvider.removePendingVote(decisionId);
    } else {
      _votingProvider.addPendingVote(decisionId, value);
    }
  }

  Future<void> submitVotes(BuildContext context) async {
    if (pendingVotesCount == 0) return;

    isSubmitting = true;
    notifyListeners();

    final txid = await _votingProvider.submitVotes(1000);

    isSubmitting = false;
    notifyListeners();

    if (!context.mounted) return;

    if (txid != null) {
      showSailToast(
        context,
        'Ballot sent: ${txid.length > 16 ? txid.substring(0, 16) : txid}',
        variant: SailToastVariant.success,
      );
    } else {
      showSailToast(
        context,
        _votingProvider.error ?? 'The ballot failed',
        variant: SailToastVariant.destructive,
      );
    }
  }

  @override
  void dispose() {
    _votingProvider.removeListener(_onProviderChange);
    super.dispose();
  }
}
