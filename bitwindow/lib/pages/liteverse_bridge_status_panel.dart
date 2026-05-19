import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sail_ui/sail_ui.dart';

const int _canonicalLiteverseSlot = 1;
const String _liteverseOpsStateUrl = 'http://127.0.0.1:8787/state';

class LiteverseBridgeStatusPanel extends StatefulWidget {
  const LiteverseBridgeStatusPanel({super.key});

  @override
  State<LiteverseBridgeStatusPanel> createState() => _LiteverseBridgeStatusPanelState();
}

class _LiteverseBridgeStatusPanelState extends State<LiteverseBridgeStatusPanel> {
  late Future<LiteverseBridgeStatus> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = LiteverseBridgeStatus.fetch();
  }

  Future<void> _refresh() async {
    setState(() {
      _statusFuture = LiteverseBridgeStatus.fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LiteverseBridgeStatus>(
      future: _statusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final status = snapshot.data;
        final error = snapshot.error;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReadOnlyNotice(onRefresh: _refresh, generatedAt: status?.generatedAt),
              const SizedBox(height: SailStyleValues.padding12),
              if (error != null)
                SailCard(
                  title: 'Liteverse Bridge Status',
                  error: 'Could not read Liteverse Ops status',
                  child: SailText.secondary13(error.toString()),
                )
              else if (status != null) ...[
                if (status.slotMismatch) ...[
                  _SlotMismatchBanner(status: status),
                  const SizedBox(height: SailStyleValues.padding12),
                ],
                _SlotSummaryCard(status: status),
                const SizedBox(height: SailStyleValues.padding12),
                _ChainHealthCard(status: status),
                const SizedBox(height: SailStyleValues.padding12),
                _BridgeStateCard(status: status),
                const SizedBox(height: SailStyleValues.padding12),
                _EvidenceCard(status: status),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ReadOnlyNotice extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final String? generatedAt;

  const _ReadOnlyNotice({required this.onRefresh, this.generatedAt});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Liteverse Bridge Status',
      subtitle: generatedAt == null ? 'Read-only local status' : 'Read-only local status · $generatedAt',
      widgetHeaderEnd: SailButton(
        label: 'Refresh',
        variant: ButtonVariant.ghost,
        onPressed: onRefresh,
      ),
      child: SailText.secondary13(
        'This panel only reads the local Liteverse Ops state. It does not create peg-ins or peg-outs, '
        'does not sign transactions, and does not modify Litecoin, enforcer, Besu, relayer, or Ops state.',
      ),
    );
  }
}

class _SlotMismatchBanner extends StatelessWidget {
  final LiteverseBridgeStatus status;

  const _SlotMismatchBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    const warningColor = Color(0xFFD97706);
    final detected = status.detectedSlotLabel;

    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: 0.14),
        border: Border.all(color: warningColor.withValues(alpha: 0.4)),
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: warningColor, size: 18),
          const SizedBox(width: SailStyleValues.padding08),
          Expanded(
            child: SailText.primary13(
              'Slot mismatch: Liteverse target is slot $_canonicalLiteverseSlot, '
              'but the current validated local stack is running slot $detected.',
              color: warningColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotSummaryCard extends StatelessWidget {
  final LiteverseBridgeStatus status;

  const _SlotSummaryCard({required this.status});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Slot Target',
      subtitle: 'Canonical slot versus detected local stack',
      child: _MetricGrid(
        children: [
          _MetricTile(label: 'Canonical slot', value: _canonicalLiteverseSlot.toString()),
          _MetricTile(label: 'Detected slot', value: status.detectedSlotLabel),
          _MetricTile(label: 'Slot 1 active', value: status.isCanonicalSlotActive ? 'yes' : 'no'),
          _MetricTile(label: 'Active sidechains', value: status.activeSlotsLabel),
        ],
      ),
    );
  }
}

class _ChainHealthCard extends StatelessWidget {
  final LiteverseBridgeStatus status;

  const _ChainHealthCard({required this.status});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Local Services',
      subtitle: 'Litecoin, enforcer, Besu, and Ops health',
      child: _MetricGrid(
        children: [
          _MetricTile(label: 'Litecoin network', value: status.litecoinChain ?? 'not available'),
          _MetricTile(label: 'Litecoin height', value: status.litecoinHeight?.toString() ?? 'not available'),
          _MetricTile(label: 'Enforcer', value: status.enforcerHealthyLabel),
          _MetricTile(label: 'Besu / EVM', value: status.besuHealthyLabel),
          _MetricTile(label: 'EVM block', value: status.evmBlockNumber?.toString() ?? 'not available'),
          _MetricTile(label: 'EVM peers', value: status.evmPeerCount?.toString() ?? 'not available'),
          _MetricTile(label: 'Ops API', value: status.opsHealthyLabel),
          _MetricTile(label: 'Ops issues', value: status.opsIssuesLabel),
        ],
      ),
    );
  }
}

class _BridgeStateCard extends StatelessWidget {
  final LiteverseBridgeStatus status;

  const _BridgeStateCard({required this.status});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Bridge State',
      subtitle: 'Read-only bridge and CTIP evidence',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricGrid(
            children: [
              _MetricTile(label: 'Bridge address', value: status.bridgeAddress ?? 'not available'),
              _MetricTile(label: 'CTIP value', value: status.ctipValueLabel),
              _MetricTile(label: 'CTIP sidechain', value: status.ctipSidechainLabel),
              _MetricTile(label: 'Sender bridge balance', value: 'not available from Ops API'),
            ],
          ),
          const SizedBox(height: SailStyleValues.padding12),
          SailText.secondary12('CTIP outpoint'),
          const SizedBox(height: SailStyleValues.padding04),
          SelectableText(
            status.ctipOutpoint ?? 'not available',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  final LiteverseBridgeStatus status;

  const _EvidenceCard({required this.status});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Peg-Out Evidence',
      subtitle: 'BMM, H*, M6, and withdrawal visibility',
      child: _MetricGrid(
        children: [
          _MetricTile(label: 'Recent deposits', value: status.recentDepositCountLabel),
          _MetricTile(label: 'Recent withdrawals', value: status.recentWithdrawalCountLabel),
          _MetricTile(label: 'BMM / H*', value: status.bmmStatusLabel),
          _MetricTile(label: 'M6 / peg-out', value: 'not available from Ops API'),
          _MetricTile(label: 'Withdrawals requested', value: 'not available from Ops API'),
          _MetricTile(label: 'Withdrawals finalized', value: 'not available from Ops API'),
          _MetricTile(label: 'Withdrawals pending', value: 'not available from Ops API'),
          _MetricTile(label: 'Relayer state', value: status.relayerStateLabel),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final List<Widget> children;

  const _MetricGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 620
            ? 3
            : 2;
        final width = (constraints.maxWidth - (columnCount - 1) * SailStyleValues.padding12) / columnCount;

        return Wrap(
          spacing: SailStyleValues.padding12,
          runSpacing: SailStyleValues.padding12,
          children: [
            for (final child in children)
              SizedBox(
                width: width,
                child: child,
              ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SailText.secondary12(label),
          const SizedBox(height: SailStyleValues.padding04),
          SelectableText(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class LiteverseBridgeStatus {
  final String? generatedAt;
  final bool opsHealthy;
  final List<String> opsIssues;
  final int? detectedSlot;
  final List<int> activeSlots;
  final String? litecoinChain;
  final int? litecoinHeight;
  final bool? enforcerHealthy;
  final String? enforcerPing;
  final bool? besuHealthy;
  final int? evmBlockNumber;
  final int? evmPeerCount;
  final String? bridgeAddress;
  final String? ctipOutpoint;
  final int? ctipValueSats;
  final int? ctipSidechain;
  final int? recentDepositCount;
  final int? recentWithdrawalCount;
  final int? recentBmmCount;
  final bool relayerStateExists;

  const LiteverseBridgeStatus({
    required this.generatedAt,
    required this.opsHealthy,
    required this.opsIssues,
    required this.detectedSlot,
    required this.activeSlots,
    required this.litecoinChain,
    required this.litecoinHeight,
    required this.enforcerHealthy,
    required this.enforcerPing,
    required this.besuHealthy,
    required this.evmBlockNumber,
    required this.evmPeerCount,
    required this.bridgeAddress,
    required this.ctipOutpoint,
    required this.ctipValueSats,
    required this.ctipSidechain,
    required this.recentDepositCount,
    required this.recentWithdrawalCount,
    required this.recentBmmCount,
    required this.relayerStateExists,
  });

  bool get slotMismatch => detectedSlot != null && detectedSlot != _canonicalLiteverseSlot;
  bool get isCanonicalSlotActive => activeSlots.contains(_canonicalLiteverseSlot);
  String get detectedSlotLabel => detectedSlot?.toString() ?? 'not available';
  String get activeSlotsLabel => activeSlots.isEmpty ? 'not available' : activeSlots.join(', ');
  String get opsHealthyLabel => opsHealthy ? 'healthy' : 'attention required';
  String get opsIssuesLabel => opsIssues.isEmpty ? 'none' : '${opsIssues.length} issue(s)';
  String get enforcerHealthyLabel {
    if (enforcerHealthy == null) return 'not available';
    if (enforcerHealthy!) return enforcerPing == null ? 'healthy' : enforcerPing!;
    return 'attention required';
  }

  String get besuHealthyLabel {
    if (besuHealthy == null) return 'not available';
    return besuHealthy! ? 'healthy' : 'attention required';
  }

  String get ctipValueLabel => ctipValueSats == null ? 'not available' : '$ctipValueSats sats';
  String get ctipSidechainLabel => ctipSidechain == null ? 'not available' : ctipSidechain.toString();
  String get recentDepositCountLabel => recentDepositCount?.toString() ?? 'not available';
  String get recentWithdrawalCountLabel => recentWithdrawalCount?.toString() ?? 'not available';
  String get bmmStatusLabel {
    if (recentBmmCount == null) return 'not available from Ops API';
    if (recentBmmCount == 0) return 'no recent BMM events';
    return '$recentBmmCount recent event(s)';
  }

  String get relayerStateLabel => relayerStateExists ? 'state file present' : 'state file not present';

  static Future<LiteverseBridgeStatus> fetch() async {
    final response = await http.get(Uri.parse(_liteverseOpsStateUrl)).timeout(const Duration(seconds: 4));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Ops API returned HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Ops API returned an unexpected payload');
    }

    return LiteverseBridgeStatus.fromOpsState(decoded);
  }

  factory LiteverseBridgeStatus.fromOpsState(Map<String, dynamic> state) {
    final config = _map(state['config']);
    final litecoin = _map(_map(state['litecoin'])['value']);
    final evmContainer = _map(state['evm']);
    final evm = _map(evmContainer['value']);
    final enforcerContainer = _map(state['enforcer']);
    final enforcer = _map(enforcerContainer['value']);
    final relayer = _map(state['relayer']);
    final recentEvents = _map(_map(enforcer['recentEvents'])['value']);
    final ctipBySidechain = _map(enforcer['ctipBySidechain']);
    final activeSidechains = _list(enforcer['activeSidechains']);
    final detectedSlot = _asInt(config['sidechainId']) ?? _asInt(enforcer['configuredSidechainId']);
    final ctipSlot = detectedSlot ?? _canonicalLiteverseSlot;
    final ctip = _map(_map(ctipBySidechain[ctipSlot.toString()])['value']);

    return LiteverseBridgeStatus(
      generatedAt: _asString(state['generatedAt']),
      opsHealthy: state['ok'] == true,
      opsIssues: _list(state['issues']).map((issue) => issue.toString()).toList(),
      detectedSlot: detectedSlot,
      activeSlots: [
        for (final sidechain in activeSidechains)
          if (_asInt(_map(_map(sidechain)['proposal'])['sidechain_number']) != null)
            _asInt(_map(_map(sidechain)['proposal'])['sidechain_number'])!,
      ],
      litecoinChain: _asString(litecoin['chain']),
      litecoinHeight: _asInt(litecoin['blocks']),
      enforcerHealthy: enforcerContainer['ok'] is bool ? enforcerContainer['ok'] as bool : null,
      enforcerPing: _asString(enforcer['ping']),
      besuHealthy: evmContainer['ok'] is bool ? evmContainer['ok'] as bool : null,
      evmBlockNumber: _asInt(evm['blockNumber']),
      evmPeerCount: _asInt(evm['peerCount']),
      bridgeAddress: _asString(evm['bridgeAddress']),
      ctipOutpoint: _asString(ctip['outpoint']),
      ctipValueSats: _asInt(ctip['value']),
      ctipSidechain: ctip.isEmpty ? null : ctipSlot,
      recentDepositCount: _list(recentEvents['deposits']).length,
      recentWithdrawalCount: _list(recentEvents['withdrawals']).length,
      recentBmmCount: _list(recentEvents['bmm']).length,
      relayerStateExists: relayer['stateExists'] == true,
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, dynamic value) => MapEntry(key.toString(), value));
  return <String, dynamic>{};
}

List<dynamic> _list(dynamic value) {
  if (value is List) return value;
  return const [];
}

String? _asString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
