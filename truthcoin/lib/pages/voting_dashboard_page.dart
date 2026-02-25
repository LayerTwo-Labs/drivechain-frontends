import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:truthcoin/models/voting.dart';
import 'package:truthcoin/providers/voting_provider.dart';

@RoutePage()
class VotingDashboardPage extends StatelessWidget {
  const VotingDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VotingDashboardViewModel>.reactive(
      viewModelBuilder: () => VotingDashboardViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return QtPage(
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            children: [
              // Header
              SailRow(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SailText.primary24('Voting Dashboard', bold: true),
                  if (model.slotStatus != null) SailText.secondary15('Period: ${model.slotStatus!.currentPeriodName}'),
                ],
              ),

              // Main content
              Expanded(
                child: SailRow(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Voter status and period stats
                    Expanded(
                      flex: 2,
                      child: SailColumn(
                        spacing: SailStyleValues.padding16,
                        children: [
                          _VoterStatusCard(model: model),
                          _PeriodStatsCard(model: model),
                        ],
                      ),
                    ),

                    // Right: Decisions to vote on
                    Expanded(
                      flex: 3,
                      child: _DecisionsCard(model: model),
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

class _VoterStatusCard extends StatelessWidget {
  final VotingDashboardViewModel model;

  const _VoterStatusCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailCard(
      title: 'Your Voter Status',
      child: model.isLoading
          ? SailSkeletonizer(
              enabled: true,
              description: 'Loading voter info...',
              child: SailText.primary15('Loading...'),
            )
          : model.currentVoter == null
          ? SailColumn(
              spacing: SailStyleValues.padding12,
              children: [
                SailText.secondary15('Not registered as a voter'),
                const SizedBox(height: 8),
                SailButton(
                  label: 'Register as Voter',
                  onPressed: () async => model.showRegisterDialog(context),
                ),
              ],
            )
          : SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _VoterStatRow(
                  label: 'Status',
                  value: model.currentVoter!.isActive ? 'Active' : 'Inactive',
                  valueColor: model.currentVoter!.isActive ? theme.colors.success : theme.colors.text,
                ),
                _VoterStatRow(
                  label: 'Reputation',
                  value: model.currentVoter!.reputationDisplay,
                ),
                _VoterStatRow(
                  label: 'Votecoins',
                  value: model.currentVoter!.votecoinBalance.toString(),
                ),
                _VoterStatRow(
                  label: 'Accuracy',
                  value: model.currentVoter!.accuracyPercent,
                ),
                _VoterStatRow(
                  label: 'Total Votes',
                  value: model.currentVoter!.totalVotes.toString(),
                ),
                if (model.currentVoter!.currentPeriodParticipation != null) ...[
                  const Divider(),
                  _VoterStatRow(
                    label: 'Period Votes',
                    value:
                        '${model.currentVoter!.currentPeriodParticipation!.votesCast} / ${model.currentVoter!.currentPeriodParticipation!.decisionsAvailable}',
                  ),
                  _VoterStatRow(
                    label: 'Participation',
                    value: model.currentVoter!.currentPeriodParticipation!.participationPercent,
                  ),
                ],
              ],
            ),
    );
  }
}

class _PeriodStatsCard extends StatelessWidget {
  final VotingDashboardViewModel model;

  const _PeriodStatsCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailCard(
      title: 'Current Period Stats',
      child: model.isLoading || model.currentPeriod == null
          ? SailSkeletonizer(
              enabled: model.isLoading,
              description: 'Loading period...',
              child: SailText.primary15(model.isLoading ? 'Loading...' : 'No active period'),
            )
          : SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _VoterStatRow(
                  label: 'Period ID',
                  value: model.currentPeriod!.periodId.toString(),
                ),
                _VoterStatRow(
                  label: 'Status',
                  value: model.currentPeriod!.status.toUpperCase(),
                  valueColor: model.currentPeriod!.isActive ? theme.colors.success : theme.colors.text,
                ),
                _VoterStatRow(
                  label: 'Active Voters',
                  value: model.currentPeriod!.stats.activeVoters.toString(),
                ),
                _VoterStatRow(
                  label: 'Total Votes',
                  value: model.currentPeriod!.stats.totalVotes.toString(),
                ),
                _VoterStatRow(
                  label: 'Participation',
                  value: model.currentPeriod!.stats.participationPercent,
                ),
                _VoterStatRow(
                  label: 'Decisions',
                  value: model.currentPeriod!.decisions.length.toString(),
                ),
              ],
            ),
    );
  }
}

class _DecisionsCard extends StatelessWidget {
  final VotingDashboardViewModel model;

  const _DecisionsCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailCard(
      title: 'Decisions to Vote On',
      bottomPadding: false,
      child: model.isLoading
          ? SailSkeletonizer(
              enabled: true,
              description: 'Loading decisions...',
              child: SailText.primary15('Loading...'),
            )
          : model.currentPeriod == null || model.currentPeriod!.decisions.isEmpty
          ? Center(
              child: SailText.secondary15('No decisions in current period'),
            )
          : SailColumn(
              spacing: SailStyleValues.padding12,
              children: [
                // Pending votes header
                if (model.pendingVotesCount > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SailRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SailText.primary15(
                          '${model.pendingVotesCount} votes pending',
                          bold: true,
                        ),
                        SailButton(
                          label: 'Submit Votes',
                          onPressed: () async => model.submitVotes(context),
                          loading: model.isSubmitting,
                        ),
                      ],
                    ),
                  ),

                // Decisions list
                Expanded(
                  child: ListView.builder(
                    itemCount: model.currentPeriod!.decisions.length,
                    itemBuilder: (context, index) {
                      final decision = model.currentPeriod!.decisions[index];
                      return _DecisionCard(
                        decision: decision,
                        pendingVote: model.getPendingVote(decision.slotIdHex),
                        onVoteChanged: (value) => model.setVote(decision.slotIdHex, value),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _VoterStatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _VoterStatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SailText.secondary13(label),
        SailText.primary15(value, bold: true, color: valueColor),
      ],
    );
  }
}

class _DecisionCard extends StatelessWidget {
  final DecisionSummary decision;
  final double? pendingVote;
  final ValueChanged<double?> onVoteChanged;

  const _DecisionCard({
    required this.decision,
    required this.pendingVote,
    required this.onVoteChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final hasVote = pendingVote != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasVote ? theme.colors.primary.withValues(alpha: 0.05) : theme.colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasVote ? theme.colors.primary : Colors.transparent,
          width: 1,
        ),
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          SailRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SailText.secondary12('Slot: ${decision.slotIdHex}', monospace: true),
              SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: decision.isScaled
                          ? theme.colors.info.withValues(alpha: 0.2)
                          : theme.colors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SailText.secondary12(decision.isScaled ? 'Scaled' : 'Binary'),
                  ),
                  if (hasVote)
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: theme.colors.success,
                    ),
                ],
              ),
            ],
          ),

          // Question
          SailText.primary15(decision.question),

          // Vote input
          if (decision.isScaled)
            _ScaledVoteInput(
              value: pendingVote,
              onChanged: onVoteChanged,
            )
          else
            _BinaryVoteInput(
              value: pendingVote,
              onChanged: onVoteChanged,
            ),
        ],
      ),
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
      children: [
        Expanded(
          child: _VoteButton(
            label: 'No',
            isSelected: value == 0.0,
            color: theme.colors.error,
            onTap: () => onChanged(value == 0.0 ? null : 0.0),
          ),
        ),
        Expanded(
          child: _VoteButton(
            label: 'Yes',
            isSelected: value == 1.0,
            color: theme.colors.success,
            onTap: () => onChanged(value == 1.0 ? null : 1.0),
          ),
        ),
        SizedBox(
          width: 80,
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
      children: [
        Expanded(
          child: SailTextField(
            controller: controller,
            hintText: 'Enter value',
            textFieldType: TextFieldType.bitcoin,
            onChanged: (text) {
              final value = double.tryParse(text);
              widget.onChanged(value);
            },
          ),
        ),
        SailButton(
          label: 'Clear',
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
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

  void init() {
    _votingProvider.addListener(_onProviderChange);
    loadData();
  }

  void _onProviderChange() {
    notifyListeners();
  }

  Future<void> loadData() async {
    // Get user's first address
    try {
      final addresses = await _rpc.getWalletAddresses();
      if (addresses.isNotEmpty) {
        userAddress = addresses.first;
      }
    } catch (e) {
      // Ignore
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

    if (txid != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Votes submitted: ${txid.substring(0, 16)}...')),
      );
    }
  }

  Future<void> showRegisterDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _RegisterVoterDialog(
        votingProvider: _votingProvider,
      ),
    );

    if (result == true) {
      await loadData();
    }
  }

  @override
  void dispose() {
    _votingProvider.removeListener(_onProviderChange);
    super.dispose();
  }
}

class _RegisterVoterDialog extends StatefulWidget {
  final VotingProvider votingProvider;

  const _RegisterVoterDialog({required this.votingProvider});

  @override
  State<_RegisterVoterDialog> createState() => _RegisterVoterDialogState();
}

class _RegisterVoterDialogState extends State<_RegisterVoterDialog> {
  final TextEditingController bondController = TextEditingController();
  bool isLoading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Register as Voter'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.secondary13(
              'Register to participate in the oracle voting system. '
              'You can optionally provide a reputation bond to increase your initial reputation.',
            ),
            const SizedBox(height: 16),
            SailText.secondary12('Reputation Bond (optional, in sats)'),
            const SizedBox(height: 4),
            SailTextField(
              controller: bondController,
              hintText: 'e.g., 10000',
              textFieldType: TextFieldType.number,
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              SailText.secondary12(error!, color: Colors.red),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _register,
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Register'),
        ),
      ],
    );
  }

  Future<void> _register() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final bondSats = int.tryParse(bondController.text);
    final txid = await widget.votingProvider.registerAsVoter(
      bondSats: bondSats,
      feeSats: 1000,
    );

    setState(() => isLoading = false);

    if (txid != null && mounted) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => error = widget.votingProvider.error ?? 'Registration failed');
    }
  }

  @override
  void dispose() {
    bondController.dispose();
    super.dispose();
  }
}
