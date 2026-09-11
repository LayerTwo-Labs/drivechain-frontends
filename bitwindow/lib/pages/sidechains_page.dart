import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/utils/deposit_fee.dart';
import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/sidechain_activation_management_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/widgets/fast_withdrawal_tab.dart';
import 'package:bitwindow/widgets/starters_tab.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class SidechainsPage extends StatelessWidget {
  const SidechainsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => SidechainsViewModel(),
        builder: (context, model, child) {
          return InlineTabBar(
            key: ValueKey('sidechains_page'),
            tabs: [
              TabItem(label: 'Overview', child: SidechainsTab()),
              TabItem(label: 'Fast Withdrawal', child: FastWithdrawalTab()),
              TabItem(label: 'Starters', child: StartersTab()),
            ],
            initialIndex: 0,
          );
        },
      ),
    );
  }
}

class SidechainsTab extends ViewModelWidget<SidechainsViewModel> {
  const SidechainsTab({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    final hashWarning = viewModel.hashMismatchWarning;

    final gated = viewModel.networkSupportsSidechains && viewModel.l1Gate != L1Gate.ready;

    final Widget mainContent = gated
        ? const _L1RequiredCard()
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: SidechainsList(smallVersion: false)),
              const SizedBox(width: SailStyleValues.padding08),
              Expanded(flex: 4, child: const DepositWithdrawView()),
            ],
          );

    if (hashWarning == null) {
      return mainContent;
    }

    // A possibly-tampered binary outranks the gate: the warning stays up through
    // an hours-long sync rather than being hidden behind it.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HashMismatchBanner(names: hashWarning),
        Expanded(child: mainContent),
      ],
    );
  }
}

/// Why the sidechains tab can't do anything yet.
enum L1Gate { ready, unavailable, stopped, starting, syncing }

/// The enforcer must connect and complete its sync before the tab opens.
@visibleForTesting
L1Gate resolveL1Gate({
  required bool walletNeedsBackends,
  required bool remoteEnforcerAvailable,
  required bool coreConnected,
  required bool enforcerConnected,
  required bool coming,
  required bool synced,
  required bool chainIsEmpty,
}) {
  if (!walletNeedsBackends && !remoteEnforcerAvailable) {
    return L1Gate.unavailable;
  }
  if ((walletNeedsBackends && !coreConnected) || !enforcerConnected) {
    return coming ? L1Gate.starting : L1Gate.stopped;
  }
  // A fresh regtest node sits at 0/0 with nothing to sync from, and isSynced
  // needs a non-zero goal — waiting for it would block the tab until someone
  // mines. The orchestrator calls that steady state too (health.go). Once the
  // chain has any height this no longer applies: catching up is real syncing.
  if (chainIsEmpty) {
    return L1Gate.ready;
  }
  return synced ? L1Gate.ready : L1Gate.syncing;
}

/// Names the networks that serve sidechains in light mode.
@visibleForTesting
String lightSidechainNetworksLine(List<String> networks) {
  if (networks.isEmpty) {
    return 'No network hosts an enforcer yet, so light mode serves sidechains nowhere.';
  }
  return 'Light mode serves sidechains on ${networks.join(', ')}.';
}

/// Stands in for the whole tab while the L1 stack is missing, and in full mode
/// doubles as the place to start it — the same daemons the bottom nav reports on.
class _L1RequiredCard extends ViewModelWidget<SidechainsViewModel> {
  const _L1RequiredCard();

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    final gate = viewModel.l1Gate;

    if (gate == L1Gate.unavailable) {
      return SailCard(
        title: 'Sidechains are unavailable in light mode',
        child: Padding(
          padding: const EdgeInsets.all(SailStyleValues.padding12),
          child: SailColumn(
            spacing: SailStyleValues.padding08,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.secondary13(
                'This network hosts no enforcer. Select full mode in Settings to use sidechains here.',
              ),
              SailText.secondary13(lightSidechainNetworksLine(viewModel.remoteEnforcerNetworks)),
              SailText.secondary13('Your Bitcoin wallet still uses Electrum.'),
            ],
          ),
        ),
      );
    }

    return SailCard(
      title: switch (gate) {
        L1Gate.stopped => 'The enforcer connection is not ready',
        L1Gate.starting => 'The enforcer connection starts',
        _ => 'The enforcer sync is not complete',
      },
      child: Padding(
        padding: const EdgeInsets.all(SailStyleValues.padding12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 820,
              child: SailText.secondary13(
                switch (gate) {
                  L1Gate.stopped =>
                    'The enforcer must connect and complete its sync before this tab can show sidechain data.',
                  // One string for both: the enforcer drops in and out while it
                  // catches up, and a per-state string reflows the page each time.
                  _ => 'The slot list and balances stay empty until the enforcer reaches the chain tip.',
                },
              ),
            ),
            const SailSpacing(SailStyleValues.padding16),
            // The same cards the bottom nav shows, so status, sync progress and
            // the per-daemon restart/logs controls stay in one implementation.
            if (NodeModeProvider.runsLocalBackends)
              DaemonConnectionCard(
                connection: viewModel.mainchainConnection,
                syncInfo: viewModel.mainchainSyncInfo,
                infoMessage: null,
                restartDaemon: () => viewModel.restartDaemon(BitcoinCore()),
                stopDaemon: () => viewModel.stopDaemon(BitcoinCore()),
                navigateToLogs: viewModel.navigateToLogs,
              ),
            DaemonConnectionCard(
              connection: viewModel.enforcerConnection,
              syncInfo: viewModel.enforcerSyncInfo,
              infoMessage: viewModel.enforcerInfoMessage,
              restartDaemon: NodeModeProvider.runsLocalBackends ? () => viewModel.restartDaemon(Enforcer()) : null,
              stopDaemon: NodeModeProvider.runsLocalBackends ? () => viewModel.stopDaemon(Enforcer()) : null,
              navigateToLogs: viewModel.navigateToLogs,
            ),
            if (gate == L1Gate.stopped && NodeModeProvider.runsLocalBackends) ...[
              const SailSpacing(SailStyleValues.padding16),
              Row(
                children: [
                  SailButton(
                    label: 'Start Bitcoin Core + Enforcer',
                    onPressed: viewModel.startL1,
                  ),
                  const SizedBox(width: SailStyleValues.padding12),
                  Flexible(
                    child: SailText.secondary12('The first start must download and check the chain.'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HashMismatchBanner extends StatelessWidget {
  final String names;

  const _HashMismatchBanner({required this.names});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailTooltip(
      message:
          'The downloaded binaries do not match the expected hashes from the release server.\n'
          'This could indicate the binaries were tampered with or the download was corrupted.\n'
          'Re-download these sidechains to resolve.',
      child: Container(
        padding: const EdgeInsets.all(SailStyleValues.padding12),
        margin: const EdgeInsets.only(bottom: SailStyleValues.padding08),
        decoration: BoxDecoration(
          color: theme.colors.error.withValues(alpha: 0.1),
          borderRadius: SailStyleValues.borderRadius,
          border: Border.all(color: theme.colors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            SailSVG.fromAsset(SailSVGAsset.triangleAlert, width: 18, color: theme.colors.error),
            const SizedBox(width: SailStyleValues.padding08),
            Expanded(
              child: SailText.primary13(
                'Hash mismatch detected for $names',
                color: theme.colors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SidechainsList extends ViewModelWidget<SidechainsViewModel> {
  final bool smallVersion;

  const SidechainsList({super.key, required this.smallVersion});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    // Check if network supports sidechains
    if (!viewModel.networkSupportsSidechains) {
      return SailCard(
        title: 'Sidechains',
        subtitle: 'Not available on this network',
        child: Padding(
          padding: const EdgeInsets.all(SailStyleValues.padding20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary20('Unlock Sidechains with BIP300'),
              const SailSpacing(SailStyleValues.padding20),
              SailText.secondary13(
                'Sidechains are only available on Drivechain-enabled networks (eCash and Signet). '
                'These networks implement BIP300, which enables trustless two-way pegged sidechains.',
              ),
              const SailSpacing(SailStyleValues.padding20),
              SailText.primary15('What are Sidechains?'),
              const SailSpacing(SailStyleValues.padding08),
              SailText.secondary13(
                'Sidechains allow you to move your Bitcoin to separate blockchains with different features, '
                'while maintaining the security and scarcity of Bitcoin. Think of them as Bitcoin-backed '
                'altcoins that you can freely move between.',
              ),
              const SailSpacing(SailStyleValues.padding20),
              SailText.primary15('How to Enable Sidechains'),
              const SailSpacing(SailStyleValues.padding08),
              SailText.secondary13(
                '1. Go to Settings\n'
                '2. Switch to "eCash" or "Signet" network\n'
                '3. Restart BitWindow\n'
                '4. Return to this tab to activate sidechains',
              ),
              const SailSpacing(SailStyleValues.padding20),
              SailText.primary15('Learn More'),
              const SailSpacing(SailStyleValues.padding08),
              SailText.secondary13(
                'BIP300 (Hashrate Escrows) and BIP301 (Blind Merged Mining) enable true sidechain functionality. '
                'Visit drivechain.info to learn more about how Drivechain works and why it matters for Bitcoin.',
              ),
            ],
          ),
        ),
      );
    }

    final error = viewModel.error('sidechain');

    return SailCard(
      title: 'Sidechains',
      titleTooltip:
          'List of all active sidechains with accompanying balance, and all empty slots where future sidechains will be added',
      subtitle: viewModel._enforcerRPC.initializingBinary ? 'Enforcer is initializing...' : null,
      error: viewModel._enforcerRPC.initializingBinary ? null : error,
      widgetHeaderEnd: smallVersion
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SailToggle(
                  label: 'Show only filled slots',
                  value: viewModel.showOnlyFilled,
                  onChanged: (value) => viewModel.setShowOnlyFilled(value),
                ),
                const SizedBox(width: SailStyleValues.padding12),
                SailButton(
                  label: 'Add / Remove',
                  variant: ButtonVariant.outline,
                  onPressed: viewModel.sidechainManagementUnavailable
                      ? null
                      : () => showSidechainActivationManagementModal(context),
                ),
              ],
            ),
      child: SailSkeletonizer(
        description: 'Waiting for enforcer to become available..',
        enabled: viewModel.loading,
        child: viewModel.showOnlyFilled ? OnlyFilledTable() : FullTable(),
      ),
    );
  }
}

class OnlyFilledTable extends ViewModelWidget<SidechainsViewModel> {
  const OnlyFilledTable({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    return _SidechainsTable(
      key: const ValueKey('sidechains_table_filled'),
      slots: [
        for (int slot = 0; slot < viewModel.sidechains.length; slot++)
          if (viewModel.sidechains[slot] != null) slot,
      ],
      emptyPlaceholder: 'No active sidechains',
    );
  }
}

class FullTable extends StatelessWidget {
  const FullTable({super.key});

  @override
  Widget build(BuildContext context) {
    return _SidechainsTable(
      key: const ValueKey('sidechains_table_full'),
      slots: List.generate(256, (slot) => slot),
    );
  }
}

/// Height of the bordered table: the header strip, the rows and the frame.
double _tableHeight(int rows) => (rows == 0 ? 96 : rows * 48) + 40;

class _SidechainsTable extends ViewModelWidget<SidechainsViewModel> {
  final List<int> slots;
  final String? emptyPlaceholder;

  const _SidechainsTable({super.key, required this.slots, this.emptyPlaceholder});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    final formatter = GetIt.I<FormatterProvider>();
    final colors = context.sailTheme.colors;

    return LayoutBuilder(
      builder: (context, constraints) => Container(
        height: min(constraints.maxHeight, _tableHeight(slots.length)),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListenableBuilder(
          listenable: formatter,
          builder: (context, child) => SailTable(
            getRowId: (index) => slots[index].toString(),
            cellHeight: 48,
            headerBackgroundColor: colors.backgroundSecondary,
            headerBuilder: (context) => [
              const SailTableHeaderCell(name: 'Slot', sortable: false),
              const SailTableHeaderCell(name: 'Name', sortable: false),
              const SailTableHeaderCell(name: 'Sidechain Balance', alignment: Alignment.centerRight, sortable: false),
              const SailTableHeaderCell(name: 'Your balance', alignment: Alignment.centerRight, sortable: false),
              const SailTableHeaderCell(name: '', sortable: false),
            ],
            rowBuilder: (context, row, selected) => _sidechainRow(context, viewModel, formatter, slots[row]),
            rowCount: slots.length,
            emptyPlaceholder: emptyPlaceholder,
            selectedRowId: viewModel.selectedIndex?.toString(),
            // rowId is the SLOT NUMBER (e.g., "2", "4", "98") from getRowId
            onSelectedRow: (rowId) => viewModel.toggleSelection(int.parse(rowId ?? '0')),
            onDoubleTap: (rowId) {
              final sidechain = viewModel.sidechains[int.parse(rowId)];
              if (sidechain == null || sidechain.info.chaintipTxid == '') {
                return;
              }

              showTransactionDetails(context, sidechain.info.chaintipTxid);
            },
            contextMenuItems: (rowId) {
              final sidechain = viewModel.sidechains[int.parse(rowId)];
              if (sidechain == null || sidechain.info.chaintipTxid == '') {
                return [];
              }

              return [
                SailMenuItem(
                  onSelected: () => showTransactionDetails(context, sidechain.info.chaintipTxid),
                  child: SailText.primary12('Show Chaintip Transaction'),
                ),
              ];
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _sidechainRow(
    BuildContext context,
    SidechainsViewModel viewModel,
    FormatterProvider formatter,
    int slot,
  ) {
    final colors = context.sailTheme.colors;
    final sidechain = viewModel.sidechains[slot];
    final slotCell = SailTableCell(value: '$slot', width: 56, textColor: colors.textSecondary);

    if (sidechain == null) {
      return [
        slotCell,
        SailTableCell(value: ''),
        SailTableCell(value: '', width: 130),
        SailTableCell(value: '', width: 130),
        SailTableCell(value: '', width: 300),
      ];
    }

    final yourBalance = viewModel.yourBalance(slot);

    return [
      slotCell,
      SailTableCell(
        value: sidechain.info.title,
        child: Row(
          children: [
            viewModel.sidechainStatusDot(context, slot) ?? const SizedBox(width: 8),
            const SizedBox(width: SailStyleValues.padding08),
            Flexible(
              child: SailText.primary13(sidechain.info.title, color: colors.text, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      SailTableCell(
        value: formatter.formatSats(sidechain.info.balanceSatoshi.toInt()),
        width: 130,
        alignment: Alignment.centerRight,
        textColor: colors.text,
      ),
      SailTableCell(
        value: yourBalance == null ? '—' : formatter.formatBTC(yourBalance),
        width: 130,
        alignment: Alignment.centerRight,
        textColor: yourBalance == null ? colors.textSecondary : colors.text,
      ),
      SailTableCell(
        value: '',
        width: 300,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: SailStyleValues.padding12),
        child: _SidechainActions(viewModel: viewModel, slot: slot, sidechain: sidechain),
      ),
    ];
  }
}

/// The main action, Deposit and the settings button of one sidechain row.
class _SidechainActions extends StatelessWidget {
  final SidechainsViewModel viewModel;
  final int slot;
  final SidechainOverview sidechain;

  const _SidechainActions({required this.viewModel, required this.slot, required this.sidechain});

  @override
  Widget build(BuildContext context) {
    final mainAction = viewModel.sidechainWidget(context, slot);
    final settingsConnection = viewModel.sidechainForSlot(slot) == null ? null : viewModel.rpcForSlot(slot);

    // Scales down when a theme font is too wide for the fixed column.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mainAction != null) ...[
            mainAction,
            const SizedBox(width: SailStyleValues.padding08),
          ],
          _depositButton(context),
          const SizedBox(width: SailStyleValues.padding08),
          SizedBox.square(
            dimension: 32,
            child: settingsConnection == null
                ? null
                : SailButton(
                    variant: ButtonVariant.icon,
                    icon: SailSVGAsset.settings,
                    small: true,
                    onPressed: () async {
                      await showThemedDialog(
                        context: context,
                        builder: (context) => ChainSettingsModal(connection: settingsConnection),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _depositButton(BuildContext context) {
    final canDeposit = viewModel.canDeposit(slot);
    final button = SailButton(
      label: 'Deposit',
      variant: ButtonVariant.outline,
      disabled: !canDeposit,
      onPressed: () => showDepositModal(context, slot, sidechain.info.title),
    );

    if (canDeposit) {
      return button;
    }

    return SailTooltip(message: 'Start the sidechain before depositing', child: button);
  }
}

/// A slim progress bar with its percent, and an optional label in front.
class _ActionProgress extends StatelessWidget {
  final String? label;
  final double width;
  final double current;
  final double goal;
  final Color color;
  final String tooltip;

  const _ActionProgress({
    super.key,
    this.label,
    required this.width,
    required this.current,
    required this.goal,
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    final fraction = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return SailTooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            SailText.secondary12(label!),
            const SizedBox(width: SailStyleValues.padding08),
          ],
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: width,
              height: 6,
              color: colors.backgroundSecondary,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraction,
                heightFactor: 1,
                child: ColoredBox(color: color),
              ),
            ),
          ),
          const SizedBox(width: SailStyleValues.padding08),
          SizedBox(
            width: 32,
            child: SailText.secondary12(progressPercent(current, goal), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

/// Whole percent done, never 100% before the goal; a dash when the goal is unknown.
@visibleForTesting
String progressPercent(double current, double goal) {
  if (goal <= 0) {
    return '—';
  }
  final percent = min((current * 100 / goal).floor(), 100);
  return current < goal ? '${min(percent, 99)}%' : '$percent%';
}

class SidechainsViewModel extends BaseViewModel with ChangeTrackingMixin {
  final TransactionProvider _transactionsProvider = GetIt.I.get<TransactionProvider>();
  final BalanceProvider _balanceProvider = GetIt.I.get<BalanceProvider>();
  final BitwindowRPC _api = GetIt.I.get<BitwindowRPC>();
  final SidechainProvider _sidechainProvider = GetIt.I.get<SidechainProvider>();
  final EnforcerRPC _enforcerRPC = GetIt.I.get<EnforcerRPC>();
  final BinaryProvider _binaryProvider = GetIt.I.get<BinaryProvider>();
  final BitcoinConfProvider _confProvider = GetIt.I.get<BitcoinConfProvider>();
  final SyncProvider _syncProvider = GetIt.I.get<SyncProvider>();
  final NodeModeProvider? _nodeMode = GetIt.I.isRegistered<NodeModeProvider>() ? GetIt.I.get<NodeModeProvider>() : null;
  DownloadProvider? get _downloadProvider =>
      GetIt.I.isRegistered<DownloadProvider>() ? GetIt.I.get<DownloadProvider>() : null;
  WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();

  // Resolve a Sidechain Binary to its SidechainType enum (key into
  // SyncProvider.sidechains). bitwindowd is intentionally absent — the
  // orchestrator doesn't manage it, so it never shows up there.
  SidechainType? _sidechainType(Binary b) => switch (b) {
    Thunder() => SidechainType.SIDECHAIN_TYPE_THUNDER,
    ZSide() => SidechainType.SIDECHAIN_TYPE_ZSIDE,
    BitNames() => SidechainType.SIDECHAIN_TYPE_BITNAMES,
    BitAssets() => SidechainType.SIDECHAIN_TYPE_BITASSETS,
    Truthcoin() => SidechainType.SIDECHAIN_TYPE_TRUTHCOIN,
    Photon() => SidechainType.SIDECHAIN_TYPE_PHOTON,
    CoinShift() => SidechainType.SIDECHAIN_TYPE_COINSHIFT,
    _ => null,
  };

  DownloadProgress? _downloadProgressFor(Binary b) => _downloadProvider?.statusFor(b.type);

  bool _isDownloadingFor(Binary b) => _downloadProgressFor(b) != null;

  SyncInfo? _syncInfoFor(Binary b) {
    final type = _sidechainType(b);
    if (type == null) {
      return null;
    }
    return _syncProvider.sidechains[type];
  }

  final TextEditingController addressController = TextEditingController();
  final TextEditingController depositAmountController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  late final DepositFeeEstimate depositFee = DepositFeeEstimate(feeController);

  SidechainsViewModel() {
    initChangeTracker();

    addressController.addListener(_onChange);
    depositAmountController.addListener(_onChange);
    feeController.addListener(_onChange);
    unawaited(setDepositFeeTarget(depositFee.confTarget, keepEdits: true));

    _sidechainProvider.addListener(_onChange);
    _sidechainProvider.fetch();

    _walletReader.addListener(_onChange);
    _nodeMode?.addListener(_onChange);
    _balanceProvider.addListener(notifyListeners);

    _binaryProvider.addListener(_onChange);
    _binaryProvider.addListener(notifyListeners);
    _syncProvider.addListener(_onChange);
    _syncProvider.addListener(notifyListeners);
    // DownloadProvider polls every 100ms while downloads are active. Without
    // this listener the table never rebuilds during a download, so progress
    // never advances and the button doesn't flip from "Download" → "Start"
    // until the user touches the row.
    _downloadProvider?.addListener(_onChange);
    // _onChange only fires notifyListeners on start/stop transitions because
    // mbDownloaded isn't in the tracked binaryStates map — so without this
    // direct hook the in-flight progress bar never repaints (#1728). Cheap:
    // active downloads only, and the rebuild reads o(1) provider state.
    _downloadProvider?.addListener(notifyListeners);
  }

  bool get loading => _enforcerRPC.initializingBinary;

  /// Networks that serve sidechains in light mode.
  List<String> get remoteEnforcerNetworks => _nodeMode?.remoteEnforcerNetworks ?? const [];

  /// The connection state before the tab can read BIP300 data.
  L1Gate get l1Gate => resolveL1Gate(
    walletNeedsBackends: NodeModeProvider.runsLocalBackends,
    remoteEnforcerAvailable: _nodeMode?.remoteEnforcerAvailable ?? false,
    coreConnected: _binaryProvider.isConnected(BitcoinCore()),
    enforcerConnected: _binaryProvider.isConnected(Enforcer()),
    coming:
        _binaryProvider.isInitializing(BitcoinCore()) ||
        _binaryProvider.isInitializing(Enforcer()) ||
        _isDownloadingFor(BitcoinCore()) ||
        _isDownloadingFor(Enforcer()),
    synced: NodeModeProvider.runsLocalBackends
        ? _syncProvider.isSynced
        : (_syncProvider.enforcerSyncInfo?.isSynced ?? false),
    chainIsEmpty: _regtestChainIsEmpty,
  );

  /// Regtest alone can legitimately sit at height 0 with nothing to sync from.
  /// Any reported height means it is catching up like any other chain — and an
  /// absent or failed sample is unknown, not empty, so it never opens the tab.
  bool get _regtestChainIsEmpty {
    if (_confProvider.network != BitcoinNetwork.BITCOIN_NETWORK_REGTEST) {
      return false;
    }
    if (_syncProvider.mainchainError != null || _syncProvider.enforcerError != null) {
      return false;
    }
    final mainchain = _syncProvider.mainchainSyncInfo;
    final enforcer = _syncProvider.enforcerSyncInfo;
    if (mainchain == null || enforcer == null) {
      return false;
    }
    return mainchain.progressGoal == 0 &&
        mainchain.progressCurrent == 0 &&
        enforcer.progressGoal == 0 &&
        enforcer.progressCurrent == 0;
  }

  RPCConnection get mainchainConnection => GetIt.I.get<BitcoindConnection>();
  RPCConnection get enforcerConnection => _enforcerRPC;

  SyncInfo? get mainchainSyncInfo => _syncProvider.mainchainSyncInfo;
  SyncInfo? get enforcerSyncInfo => _syncProvider.enforcerSyncInfo;

  /// The enforcer boots behind Core and reports 0/0 until headers land, which
  /// reads as a fault unless we say what it is waiting for.
  String? get enforcerInfoMessage {
    if (mainchainConnection.initializingBinary) {
      return 'Waiting for mainchain to finish initializing';
    }
    if (_syncProvider.inHeaderSync) {
      return 'Waiting for L1 to sync headers...';
    }
    return null;
  }

  Binary _binaryFor(Binary binary) =>
      _binaryProvider.binaries.firstWhere((b) => b.name == binary.name, orElse: () => binary);

  Future<void> restartDaemon(Binary binary) => _binaryProvider.restart(_binaryFor(binary));

  Future<void> stopDaemon(Binary binary) => _binaryProvider.stop(_binaryFor(binary));

  Future<void> startL1() async {
    // Starting the enforcer boots the whole L1 chain: Core first, then this.
    await _binaryProvider.start(_binaryFor(Enforcer()));
  }

  /// The daemon cards enable "View logs" on their own and then call this
  /// unconditionally, so it has to be supplied wherever a card is rendered.
  void navigateToLogs(String title, String logPath, BinaryType binaryType) {
    GetIt.I.get<AppRouter>().push(
      LogRoute(title: title, logPath: logPath, binaryType: binaryType),
    );
  }

  /// Check if current network supports sidechains (L2L networks only)
  bool get networkSupportsSidechains {
    final network = _confProvider.network;
    return network == BitcoinNetwork.BITCOIN_NETWORK_ECASH ||
        network == BitcoinNetwork.BITCOIN_NETWORK_SIGNET ||
        network == BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
  }

  /// True when no local enforcer runs, so nothing can add, remove or withdraw.
  /// Reading chains, chain settings and deposits all work without one.
  bool get sidechainManagementUnavailable => !NodeModeProvider.runsLocalBackends;

  String? _depositWalletId;

  String? get depositWalletId => _walletReader.resolveFundingWalletId(_depositWalletId);

  Future<void> setDepositFeeTarget(int confTarget, {bool keepEdits = false}) async {
    await depositFee.refresh(confTarget, keepEdits: keepEdits);
    notifyListeners();
  }

  void setDepositWalletId(String walletId) {
    _depositWalletId = walletId;
    notifyListeners();
  }

  List<SidechainOverview?> get sidechains => _sidechainProvider.sidechains;

  bool showOnlyFilled = true;
  void setShowOnlyFilled(bool value) {
    showOnlyFilled = value;
    notifyListeners();
  }

  Sidechain? sidechainForSlot(int slot) {
    return _binaryProvider.binaries.firstWhereOrNull((b) => b is Sidechain && b.slot == slot) as Sidechain?;
  }

  RPCConnection? rpcForSlot(int slot) {
    final sidechain = sidechainForSlot(slot);
    if (sidechain == null) {
      return null;
    }

    // Check if binary is running
    final rpc = switch (sidechain) {
      var b when b is BitcoinCore =>
        GetIt.I.isRegistered<BitcoindConnection>() ? GetIt.I.get<BitcoindConnection>() : null,
      var b when b is Enforcer => GetIt.I.isRegistered<EnforcerRPC>() ? GetIt.I.get<EnforcerRPC>() : null,
      var b when b is BitWindow => GetIt.I.isRegistered<BitwindowRPC>() ? GetIt.I.get<BitwindowRPC>() : null,
      var b when b is Thunder => GetIt.I.isRegistered<ThunderRPC>() ? GetIt.I.get<ThunderRPC>() : null,
      var b when b is BitNames => GetIt.I.isRegistered<BitnamesRPC>() ? GetIt.I.get<BitnamesRPC>() : null,
      var b when b is BitAssets => GetIt.I.isRegistered<BitAssetsRPC>() ? GetIt.I.get<BitAssetsRPC>() : null,
      var b when b is ZSide => GetIt.I.isRegistered<ZSideRPC>() ? GetIt.I.get<ZSideRPC>() : null,
      var b when b is Truthcoin => GetIt.I.isRegistered<TruthcoinRPC>() ? GetIt.I.get<TruthcoinRPC>() : null,
      var b when b is Photon => GetIt.I.isRegistered<PhotonRPC>() ? GetIt.I.get<PhotonRPC>() : null,
      var b when b is CoinShift => GetIt.I.isRegistered<CoinShiftRPC>() ? GetIt.I.get<CoinShiftRPC>() : null,
      _ => null,
    };

    return rpc;
  }

  /// Returns names of sidechains with hash mismatches, formatted for display.
  String? get hashMismatchWarning {
    final mismatched = <String>[];
    for (final binary in _binaryProvider.binaries) {
      if (binary.downloadInfo.hashMatch == false) {
        mismatched.add(binary.name);
      }
    }
    if (mismatched.isEmpty) {
      return null;
    }
    if (mismatched.length == 1) {
      return mismatched.first;
    }
    final last = mismatched.removeLast();
    return '${mismatched.join(', ')} and $last';
  }

  bool canDeposit(int slot) => isSidechainRunning(slot);

  /// The user's wallet balance in BTC on the chain in [slot], or null while the chain does not run.
  double? yourBalance(int slot) {
    final rpc = _sidechainRPC(slot);
    if (rpc == null || !rpc.connected || !_balanceProvider.connections.contains(rpc)) {
      return null;
    }
    final (confirmed, pending) = _balanceProvider.balanceFor(rpc);
    return confirmed + pending;
  }

  bool isSidechainRunning(int slot) => _sidechainRPC(slot)?.connected ?? false;

  /// The RPC connection for a slot, or null when this build has none.
  RPCConnection? _sidechainRPC(int slot) {
    final sidechain = sidechainForSlot(slot);
    if (sidechain == null) {
      return null;
    }

    return switch (sidechain) {
      var b when b is Thunder => (GetIt.I.isRegistered<ThunderRPC>() ? GetIt.I.get<ThunderRPC>() : null),
      var b when b is BitNames => (GetIt.I.isRegistered<BitnamesRPC>() ? GetIt.I.get<BitnamesRPC>() : null),
      var b when b is BitAssets => (GetIt.I.isRegistered<BitAssetsRPC>() ? GetIt.I.get<BitAssetsRPC>() : null),
      var b when b is ZSide => (GetIt.I.isRegistered<ZSideRPC>() ? GetIt.I.get<ZSideRPC>() : null),
      var b when b is Truthcoin => (GetIt.I.isRegistered<TruthcoinRPC>() ? GetIt.I.get<TruthcoinRPC>() : null),
      var b when b is Photon => (GetIt.I.isRegistered<PhotonRPC>() ? GetIt.I.get<PhotonRPC>() : null),
      var b when b is CoinShift => (GetIt.I.isRegistered<CoinShiftRPC>() ? GetIt.I.get<CoinShiftRPC>() : null),
      _ => null,
    };
  }

  // Third-party sidechains aren't vetted by Layer Two Labs, so make the user
  // accept the risk before the download starts.
  Future<bool> _confirmUntrustedDownload(BuildContext context, Sidechain sidechain) async {
    final confirmed = await showThemedDialog<bool>(
      context: context,
      builder: (dialogContext) => SailAlertCard(
        title: 'Download ${sidechain.name}?',
        subtitle:
            'This sidechain was not developed by Layer Two Labs, has not been audited for security '
            'issues, and can introduce dangerous code at any time. Run this sidechain at your own risk.',
        confirmText: 'Download anyway',
        confirmButtonVariant: ButtonVariant.destructive,
        onConfirm: () async => Navigator.of(dialogContext).pop(true),
        onCancel: () async => Navigator.of(dialogContext).pop(false),
      ),
    );
    return confirmed == true;
  }

  Widget? sidechainWidget(BuildContext context, int slot) {
    final sidechain = sidechainForSlot(slot);

    if (sidechain == null) {
      return null;
    }

    final colors = SailTheme.of(context).colors;
    final isRunning = _binaryProvider.isSidechainUp(sidechain);
    final isInitializing = _binaryProvider.isInitializing(sidechain);
    final stopping = _binaryProvider.isStopping(sidechain);
    final progress = _downloadProgressFor(sidechain);
    if (progress != null) {
      // A download of a binary already on disk is an update.
      final updating = sidechain.isDownloaded;
      final verb = updating ? 'Updating' : 'Downloading';
      final tooltip = progress.mbTotal > 0
          ? '$verb ${sidechain.name}\n'
                'Progress: ${formatDataSizeFromMB(progress.mbDownloaded.toDouble())}\n'
                'Size: ${formatDataSizeFromMB(progress.mbTotal.toDouble())}'
          : '$verb ${sidechain.name}\n'
                '${formatDataSizeFromMB(progress.mbDownloaded.toDouble())} so far (size unknown)';

      return _ActionProgress(
        key: ValueKey('${updating ? 'updating' : 'downloading'}_slot_${sidechain.slot}_${sidechain.name}'),
        label: updating ? 'Updating' : null,
        width: updating ? 64 : 96,
        current: progress.mbDownloaded.toDouble(),
        goal: progress.mbTotal > 0 ? progress.mbTotal.toDouble() : 0,
        color: updating ? colors.primary : colors.orangeLight,
        tooltip: tooltip,
      );
    }

    if (stopping) {
      return SailButton(
        key: ValueKey('stopping_slot_${sidechain.slot}_${sidechain.name}'),
        label: 'Stopping...',
        variant: ButtonVariant.outline,
        onPressed: null,
        loading: true,
      );
    }

    if (isRunning) {
      // Running but indexing: the same SyncInfo the bottom nav reports.
      final syncInfo = _syncInfoFor(sidechain);
      if (syncInfo != null && !syncInfo.isSynced && syncInfo.progressGoal > 0) {
        return _ActionProgress(
          key: ValueKey('syncing_slot_${sidechain.slot}_${sidechain.name}'),
          width: 96,
          current: syncInfo.progressCurrent,
          goal: syncInfo.progressGoal,
          color: colors.orangeLight,
          tooltip:
              '${sidechain.name}\n'
              'Current height ${formatProgress(syncInfo.progressCurrent, false)}\n'
              'Header height ${formatProgress(syncInfo.progressGoal, false)}',
        );
      }
      return _withUpdate(
        sidechain,
        SailButton(
          key: ValueKey('stop_slot_${sidechain.slot}_${sidechain.name}'),
          label: 'Stop',
          variant: ButtonVariant.outline,
          onPressed: () async => _binaryProvider.stop(sidechain),
        ),
      );
    }

    if (isInitializing) {
      return SailButton(
        key: ValueKey('launching_slot_${sidechain.slot}_${sidechain.name}'),
        label: 'Launching...',
        variant: ButtonVariant.outline,
        onPressed: null,
        loading: true,
      );
    }

    if (!sidechain.isDownloaded) {
      return SailButton(
        key: ValueKey('download_slot_${sidechain.slot}_${sidechain.name}'),
        label: 'Download',
        variant: ButtonVariant.primary,
        onPressed: () async {
          if (!sidechain.developedByLayerTwoLabs && !await _confirmUntrustedDownload(context, sidechain)) {
            return;
          }
          await _binaryProvider.download(sidechain);
        },
      );
    }

    return _withUpdate(
      sidechain,
      SailButton(
        key: ValueKey('start_slot_${sidechain.slot}_${sidechain.name}'),
        label: 'Start',
        variant: sidechain.updateAvailable ? ButtonVariant.outline : ButtonVariant.primary,
        onPressed: () async => await _binaryProvider.start(sidechain),
      ),
    );
  }

  Widget _withUpdate(Sidechain sidechain, Widget action) {
    if (!sidechain.updateAvailable) {
      return action;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SailButton(
          key: ValueKey('update_slot_${sidechain.slot}_${sidechain.name}'),
          label: 'Update',
          icon: SailSVGAsset.circleArrowUp,
          variant: ButtonVariant.primary,
          onPressed: () async => _binaryProvider.update(sidechain),
        ),
        const SizedBox(width: SailStyleValues.padding08),
        action,
      ],
    );
  }

  /// Connection status dot: green when connected, orange while it comes up,
  /// red on a connection error. The tooltip holds the error.
  Widget? sidechainStatusDot(BuildContext context, int slot) {
    final sidechain = sidechainForSlot(slot);
    if (sidechain == null) {
      return null;
    }

    final theme = SailTheme.of(context);
    final rpc = rpcForSlot(slot);
    if (rpc == null) {
      return null;
    }

    final isRunning = _binaryProvider.isConnected(sidechain);
    final isInitializing = _binaryProvider.isInitializing(sidechain);
    final downloading = _isDownloadingFor(sidechain);
    final error = _binaryProvider.connectionError(sidechain);
    final startupErr = rpc.startupError;

    // Don't show a dot if binary is not active at all
    if (!isRunning && !isInitializing && !downloading && error == null) {
      return null;
    }

    final Color color;
    if (downloading || isInitializing) {
      color = theme.colors.orangeLight;
    } else if (isRunning) {
      color = theme.colors.success;
    } else {
      color = theme.colors.error;
    }

    final tooltipMessage =
        error ??
        startupErr ??
        (isRunning
            ? 'Connected'
            : isInitializing
            ? 'Connecting...'
            : '');

    return SailTooltip(
      message: tooltipMessage,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  int? _selectedIndex;

  int? get selectedIndex => _selectedIndex;

  void toggleSelection(int index) {
    if (_selectedIndex == index) {
      _selectedIndex = null; // Deselect if the same item is selected again
    } else {
      _selectedIndex = index; // Select the new item
    }
    notifyListeners();
  }

  void decrementSelectedIndex() {
    _selectedIndex = max(0, (_selectedIndex ?? 0) - 1);
    notifyListeners();
  }

  void incrementSelectedIndex() {
    _selectedIndex = min(255, (_selectedIndex ?? 0) + 1);
    notifyListeners();
  }

  List<ListSidechainDepositsResponse_SidechainDeposit> _sortedDeposits = [];
  String depositSortColumn = 'amount';
  bool depositSortAscending = true;

  List<ListSidechainDepositsResponse_SidechainDeposit> get sortedDeposits {
    if (!listEquals(_sortedDeposits, recentDeposits)) {
      _sortedDeposits = List<ListSidechainDepositsResponse_SidechainDeposit>.from(recentDeposits);
      _sortDeposits();
    }
    return _sortedDeposits;
  }

  List<WithdrawalBundle> get sortedWithdrawals {
    return _sidechainProvider.sidechains[_selectedIndex ?? 255]?.withdrawals ?? [];
  }

  void sortDeposits(String column) {
    if (depositSortColumn == column) {
      depositSortAscending = !depositSortAscending;
    } else {
      depositSortColumn = column;
      depositSortAscending = true;
    }
    _sortDeposits();
    notifyListeners();
  }

  void _sortDeposits() {
    _sortedDeposits.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (depositSortColumn) {
        case 'amount':
          aValue = a.amount;
          bValue = b.amount;
          break;
        case 'txid':
          aValue = a.txid;
          bValue = b.txid;
          break;
        case 'confirmations':
          aValue = a.confirmations;
          bValue = b.confirmations;
          break;
        default:
          return 0;
      }

      return depositSortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  List<ListSidechainDepositsResponse_SidechainDeposit> get recentDeposits =>
      _sidechainProvider.sidechains[_selectedIndex ?? 255]?.deposits ?? [];

  Future<void> clearAddress() async {
    addressController.clear();
    notifyListeners();
  }

  Future<void> formatAddress() async {
    if (_selectedIndex == null) {
      return;
    }

    addressController.text = formatDepositAddress(addressController.text, _selectedIndex!);
    notifyListeners();
  }

  String? get formatError {
    if (addressController.text.isEmpty) {
      return 'A deposit address from your sidechain must be set before you can format it.';
    }

    if (addressController.text.contains('_')) {
      return 'You can only format an address once. Unformatted addresses can not contain underscores.';
    }

    return null;
  }

  void deposit(BuildContext context) async {
    if (double.tryParse(depositAmountController.text) == null) {
      showSailToast(context, 'Invalid amount, enter a number');
      return;
    }
    if (double.tryParse(feeController.text) == null) {
      showSailToast(context, 'Invalid fee, enter a number');
      return;
    }

    try {
      final walletId = depositWalletId;
      if (walletId == null) {
        throw Exception('No wallet selected to fund the deposit');
      }

      setBusy(true);
      await _api.wallet.createSidechainDeposit(
        walletId,
        _selectedIndex ?? 255,
        addressController.text,
        double.parse(depositAmountController.text),
        double.parse(feeController.text),
      );
    } catch (e) {
      if (context.mounted) {
        showSailToast(context, 'Could not create deposit:\n$e');
      }
    } finally {
      setBusy(false);
    }

    // refetching the transaction list also triggers the balance to be updated
    await _transactionsProvider.fetch();
    // refetching the balance also triggers the balance to be updated
    await _balanceProvider.fetch();
    // refetch sidechain transaction list
    await _sidechainProvider.fetch();
  }

  @override
  void dispose() {
    _sidechainProvider.removeListener(_onChange);
    _walletReader.removeListener(_onChange);
    _nodeMode?.removeListener(_onChange);
    _balanceProvider.removeListener(notifyListeners);
    addressController.removeListener(_onChange);
    depositAmountController.removeListener(_onChange);
    feeController.removeListener(_onChange);
    _binaryProvider.removeListener(_onChange);
    _binaryProvider.removeListener(notifyListeners);
    _syncProvider.removeListener(_onChange);
    _syncProvider.removeListener(notifyListeners);
    _downloadProvider?.removeListener(_onChange);
    _downloadProvider?.removeListener(notifyListeners);
    super.dispose();
  }

  void _onChange() {
    // Core data that affects the UI
    track('sidechains', _sidechainProvider.sidechains);
    track('recentDeposits', recentDeposits);

    // Switching between an electrum and a backend-backed wallet changes nothing
    // else tracked here, so without this the tab keeps rendering the old gate.
    final gate = l1Gate;
    if (track('l1Gate', gate) && gate == L1Gate.ready) {
      // SidechainProvider only refetches once isSynced flips, which never
      // happens on an empty regtest chain — the slot list would stay as it was
      // when the daemons were still down.
      unawaited(_sidechainProvider.fetch());
    }

    // UI state that affects rendering
    track('showOnlyFilled', showOnlyFilled);
    track('selectedIndex', selectedIndex);
    track('depositWalletId', depositWalletId);

    // Sorting state
    track('depositSortColumn', depositSortColumn);
    track('depositSortAscending', depositSortAscending);

    // Text input values
    track('depositAmount', depositAmountController.text);
    track('addressController', addressController.text);
    track('fee', feeController.text);

    // Binary states that affect sidechainWidget() rendering - notify immediately
    // so sidechain list buttons update instantly when binaries connect/disconnect.
    final binaryChanged = track('binaryStates', _getBinaryStates());

    // Loading and error states
    track('loading', loading);
    // Error handling
    final errorChanged = track('error', _sidechainProvider.error);
    if (errorChanged) {
      setErrorForObject('sidechain', _sidechainProvider.error);
    }

    if (binaryChanged) {
      // Binary state changes (connect/disconnect/start/stop) must rebuild
      // immediately - bypass the ChangeTrackingMixin debounce.
      notifyListeners();
    } else {
      notifyIfChanged();
    }
  }

  // Helper method to track binary states efficiently.
  // Uses per-binary helper methods for connected/initializing/stopping,
  // and tracks errors + download state for status icon tooltips.
  Map<String, dynamic> _getBinaryStates() {
    final states = <String, dynamic>{};

    for (final binary in _binaryProvider.binaries) {
      final key = binary.name;
      states['${key}_connected'] = _binaryProvider.isConnected(binary);
      states['${key}_initializing'] = _binaryProvider.isInitializing(binary);
      states['${key}_stopping'] = _binaryProvider.isStopping(binary);
      states['${key}_downloading'] = _isDownloadingFor(binary);
      states['${key}_error'] = _binaryProvider.connectionError(binary);
      states['${key}_downloaded'] = binary.isDownloaded;
    }

    return states;
  }
}

class DepositWithdrawView extends ViewModelWidget<SidechainsViewModel> {
  const DepositWithdrawView({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    return const InlineTabBar(
      tabs: [
        TabItem(
          label: 'Create Deposits',
          icon: SailSVGAsset.iconDeposit,
          child: MakeDepositsView(),
        ),
        TabItem(
          label: 'See Withdrawals',
          icon: SailSVGAsset.iconWithdraw,
          child: SeeWithdrawalsView(),
        ),
      ],
      initialIndex: 0,
    );
  }
}

/// The deposit fee, on a rate the backend estimated for a block target.
class DepositFeeFields extends StatelessWidget {
  final DepositFeeEstimate estimate;
  final ValueChanged<int> onTargetChanged;

  const DepositFeeFields({
    super.key,
    required this.estimate,
    required this.onTargetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailRow(
          spacing: SailStyleValues.padding08,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 2,
              child: NumericField(
                label: 'Fee',
                controller: estimate.controller,
                hintText: '0.00000000',
              ),
            ),
            UnitDropdown(value: Unit.BTC, onChanged: (_) => {}, enabled: false),
            Expanded(
              flex: 2,
              child: SailColumn(
                spacing: SailStyleValues.padding08,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary13('Fee target', bold: true),
                  SizedBox(
                    width: double.infinity,
                    child: SailDropdownButton<int>(
                      value: estimate.confTarget,
                      items: depositFeeTargets
                          .map(
                            (target) => SailDropdownItem<int>(
                              value: target,
                              label: depositFeeTargetLabel(target),
                            ),
                          )
                          .toList(),
                      onChanged: (target) {
                        if (target != null) {
                          onTargetChanged(target);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SailText.secondary12(estimate.hint, color: context.sailTheme.colors.textTertiary),
      ],
    );
  }
}

class MakeDepositsView extends ViewModelWidget<SidechainsViewModel> {
  const MakeDepositsView({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    return SailCard(
      bottomPadding: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailRow(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2, // take up 2/3 of the space
                  child: SailTextField(
                    label: 'Sidechain Deposit Address',
                    controller: viewModel.addressController,
                    hintText: 's${viewModel._selectedIndex ?? 0}_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx_xxxxxx',
                    size: TextFieldSize.small,
                  ),
                ),
                SailButton(
                  variant: ButtonVariant.icon,
                  onPressed: () async {
                    try {
                      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                      if (clipboardData?.text != null) {
                        viewModel.addressController.text = clipboardData!.text!;
                        viewModel.notifyListeners(); // Make sure UI updates
                      }
                    } catch (e) {
                      if (!context.mounted) {
                        return;
                      }
                      showSailToast(context, 'Error accessing clipboard');
                    }
                  },
                  icon: SailSVGAsset.clipboardPaste,
                ),
                SailTooltip(
                  message: viewModel.formatError ?? 'Format as deposit address',
                  child: SailButton(
                    variant: ButtonVariant.icon,
                    onPressed: viewModel.formatAddress,
                    disabled: viewModel.formatError != null,
                    icon: SailSVGAsset.iconFormat,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SailStyleValues.padding08),
            SailRow(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: NumericField(
                    label: 'Deposit Amount',
                    controller: viewModel.depositAmountController,
                    hintText: '0.00',
                  ),
                ),
                UnitDropdown(value: Unit.BTC, onChanged: (_) => {}, enabled: false),
                Expanded(
                  flex: 2,
                  child: FromWalletField(
                    selectedWalletId: viewModel.depositWalletId,
                    onChanged: viewModel.setDepositWalletId,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SailStyleValues.padding08),
            DepositFeeFields(
              estimate: viewModel.depositFee,
              onTargetChanged: viewModel.setDepositFeeTarget,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding08),
              child: SailText.secondary13(
                'The sidechain may also deduct a fee from your deposit.',
                color: context.sailTheme.colors.textTertiary,
              ),
            ),
            SailButton(
              label: 'Deposit',
              disabled:
                  viewModel.depositWalletId == null ||
                  viewModel.addressController.text == '' ||
                  viewModel.depositAmountController.text == '' ||
                  viewModel.feeController.text == '',
              onPressed: () async => viewModel.deposit(context),
            ),
            const SizedBox(height: SailStyleValues.padding16),
            SizedBox(
              height: 250,
              child: SailCard(
                title:
                    'Your Recent Deposits${viewModel.selectedIndex != null && viewModel.sidechains[viewModel.selectedIndex!] != null ? " to ${viewModel.sidechains[viewModel.selectedIndex!]!.info.title}" : ""}',
                subtitle: 'Recent deposits to sidechains, coming from your onchain-wallet.',
                shadowSize: ShadowSize.none,
                bottomPadding: false,
                child: RecentDepositsTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeeWithdrawalsView extends ViewModelWidget<SidechainsViewModel> {
  const SeeWithdrawalsView({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    return SailCard(
      bottomPadding: false,
      child: const RecentWithdrawalsTable(),
    );
  }
}

class RecentDepositsTable extends ViewModelWidget<SidechainsViewModel> {
  const RecentDepositsTable({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    final formatter = GetIt.I<FormatterProvider>();

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => SailTable(
        getRowId: (index) => viewModel.sortedDeposits[index].txid,
        headerBuilder: (context) => [
          SailTableHeaderCell(name: 'Txid', onSort: () => viewModel.sortDeposits('txid')),
          SailTableHeaderCell(name: 'Amount', onSort: () => viewModel.sortDeposits('amount')),
          SailTableHeaderCell(name: 'Fee', onSort: () => viewModel.sortDeposits('fee')),
          SailTableHeaderCell(
            name: 'Confirmations',
            onSort: () => viewModel.sortDeposits('confirmations'),
          ),
        ],
        rowBuilder: (context, row, selected) {
          final deposit = viewModel.sortedDeposits[row];
          return [
            SailTableCell(value: '${deposit.txid.substring(0, 10)}..', copyValue: deposit.txid),
            SailTableCell(value: formatter.formatSats(deposit.amount.toInt())),
            SailTableCell(value: formatter.formatSats(deposit.fee.toInt())),
            SailTableCell(value: deposit.confirmations.toString()),
          ];
        },
        rowCount: viewModel.sortedDeposits.length,
        emptyPlaceholder: 'No deposits yet',
        drawGrid: true,
        sortAscending: viewModel.depositSortAscending,
        sortColumnIndex: [
          'txid',
          'amount',
          'fee',
          'confirmations',
        ].indexOf(viewModel.depositSortColumn),
        onSort: (columnIndex, ascending) => viewModel.sortDeposits(viewModel.depositSortColumn),
        onDoubleTap: (rowId) => showTransactionDetails(context, rowId),
        contextMenuItems: (rowId) {
          return [
            SailMenuItem(
              onSelected: () => showTransactionDetails(context, rowId),
              child: SailText.primary12('Show Transaction Details'),
            ),
          ];
        },
      ),
    );
  }
}

class RecentWithdrawalsTable extends ViewModelWidget<SidechainsViewModel> {
  const RecentWithdrawalsTable({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    if (viewModel.sortedWithdrawals.isEmpty) {
      return Center(child: SailText.secondary13('No withdrawal bundles found for this sidechain'));
    }

    return SailTable(
      getRowId: (index) => viewModel.sortedWithdrawals[index].m6id,
      headerBuilder: (context) => [
        const SailTableHeaderCell(name: 'M6 ID'),
        const SailTableHeaderCell(name: 'Status'),
        const SailTableHeaderCell(name: 'Block Height'),
        const SailTableHeaderCell(name: 'Sequence #'),
      ],
      rowBuilder: (context, row, selected) {
        final withdrawal = viewModel.sortedWithdrawals[row];
        return [
          SailTableCell(
            value: '${withdrawal.m6id.substring(0, 10)}...',
            copyValue: withdrawal.m6id,
          ),
          SailTableCell(value: withdrawal.status),
          SailTableCell(value: withdrawal.blockHeight.toString()),
          SailTableCell(
            value: withdrawal.sequenceNumber.toInt() > 0 ? withdrawal.sequenceNumber.toString() : '-',
          ),
        ];
      },
      rowCount: viewModel.sortedWithdrawals.length,
      emptyPlaceholder: 'No withdrawal bundles',
      drawGrid: true,
      sortAscending: true,
      sortColumnIndex: 2,
    );
  }
}

Future<void> showDepositModal(BuildContext context, int slot, String sidechainName) {
  return showThemedDialog<void>(
    barrierDismissible: true,
    context: context,
    builder: (context) => DepositModal(slot: slot, sidechainName: sidechainName),
  );
}

class DepositModal extends StatefulWidget {
  final int slot;
  final String sidechainName;

  const DepositModal({super.key, required this.slot, required this.sidechainName});

  @override
  State<DepositModal> createState() => _DepositModalState();
}

class _DepositModalState extends State<DepositModal> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  late final DepositFeeEstimate depositFee = DepositFeeEstimate(feeController);

  bool isLoading = false;
  bool isFetchingAddress = true;
  String? depositAddress;
  String? fetchError;
  String? selectedWalletId;

  String? get fromWalletId => GetIt.I<WalletReaderProvider>().resolveFundingWalletId(selectedWalletId);

  @override
  void initState() {
    super.initState();
    _fetchDepositAddress();
    unawaited(_setFeeTarget(depositFee.confTarget, keepEdits: true));
    amountController.addListener(_onTextChanged);
    feeController.addListener(_onTextChanged);
  }

  Future<void> _setFeeTarget(int confTarget, {bool keepEdits = false}) async {
    await depositFee.refresh(confTarget, keepEdits: keepEdits);
    if (mounted) {
      setState(() {});
    }
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    amountController.removeListener(_onTextChanged);
    feeController.removeListener(_onTextChanged);
    amountController.dispose();
    feeController.dispose();
    super.dispose();
  }

  SidechainRPC? _getSidechainRPC(int slot) {
    final binaryProvider = GetIt.I<BinaryProvider>();

    // Find the sidechain binary by slot
    final sidechain = binaryProvider.binaries.firstWhereOrNull(
      (b) => b is Sidechain && b.slot == slot,
    );
    if (sidechain == null) {
      return null;
    }

    // Get the RPC for this sidechain type
    // Thunder goes through drivechaind, so no direct SidechainRPC available here
    final rpc = switch (sidechain) {
      Truthcoin() => GetIt.I.isRegistered<TruthcoinRPC>() ? GetIt.I.get<TruthcoinRPC>() : null,
      Photon() => GetIt.I.isRegistered<PhotonRPC>() ? GetIt.I.get<PhotonRPC>() : null,
      BitNames() => GetIt.I.isRegistered<BitnamesRPC>() ? GetIt.I.get<BitnamesRPC>() : null,
      BitAssets() => GetIt.I.isRegistered<BitAssetsRPC>() ? GetIt.I.get<BitAssetsRPC>() : null,
      ZSide() => GetIt.I.isRegistered<ZSideRPC>() ? GetIt.I.get<ZSideRPC>() : null,
      CoinShift() => GetIt.I.isRegistered<CoinShiftRPC>() ? GetIt.I.get<CoinShiftRPC>() : null,
      Thunder() => GetIt.I.isRegistered<ThunderRPC>() ? GetIt.I.get<ThunderRPC>() : null,
      _ => null,
    };

    // The same rule the deposit button reads.
    if (rpc != null && rpc.connected) {
      return rpc;
    }
    return null;
  }

  Future<void> _fetchDepositAddress() async {
    setState(() {
      isFetchingAddress = true;
      fetchError = null;
    });

    try {
      final sidechainRPC = _getSidechainRPC(widget.slot);
      if (sidechainRPC == null) {
        throw Exception('Sidechain is not running. Start it first to deposit.');
      }

      final address = await sidechainRPC.getDepositAddress();
      if (mounted) {
        setState(() {
          depositAddress = address;
          isFetchingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          fetchError = e.toString();
          isFetchingAddress = false;
        });
      }
    }
  }

  Future<void> _deposit() async {
    if (depositAddress == null) {
      showSailToast(context, 'No deposit address available');
      return;
    }
    if (double.tryParse(amountController.text) == null) {
      showSailToast(context, 'Invalid amount, enter a number');
      return;
    }
    if (double.tryParse(feeController.text) == null) {
      showSailToast(context, 'Invalid fee, enter a number');
      return;
    }

    final api = GetIt.I<BitwindowRPC>();
    final transactionsProvider = GetIt.I<TransactionProvider>();
    final balanceProvider = GetIt.I<BalanceProvider>();
    final sidechainProvider = GetIt.I<SidechainProvider>();

    try {
      final walletId = fromWalletId;
      if (walletId == null) {
        throw Exception('No wallet selected to fund the deposit');
      }

      setState(() => isLoading = true);

      final txid = await api.wallet.createSidechainDeposit(
        walletId,
        widget.slot,
        depositAddress!,
        double.parse(amountController.text),
        double.parse(feeController.text),
      );

      if (mounted) {
        Navigator.of(context).pop();
        showSailToast(context, 'Deposited in txid: $txid');
      }

      // Refresh data
      await transactionsProvider.fetch();
      await balanceProvider.fetch();
      await sidechainProvider.fetch();
    } catch (e) {
      if (mounted) {
        showSailToast(context, 'Could not create deposit:\n$e');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // fromWalletId resolves against the live wallet list, so rebuild with it —
    // otherwise the dropdown keeps showing a wallet the deposit no longer uses.
    return ListenableBuilder(
      listenable: GetIt.I<WalletReaderProvider>(),
      builder: (context, _) => _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.25,
        vertical: MediaQuery.of(context).size.height * 0.2,
      ),
      child: ClipRRect(
        borderRadius: SailStyleValues.borderRadius,
        child: SailCard(
          title: 'Deposit to ${widget.sidechainName}',
          subtitle: 'Slot ${widget.slot}',
          error: fetchError,
          withCloseButton: true,
          // The card sits inside a fixed share of the window, so a short
          // window cuts the tail of this form off.
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    Expanded(
                      child: SailTextField(
                        label: 'Deposit Address',
                        loading: LoadingDetails(
                          enabled: isFetchingAddress,
                          description: 'Fetching deposit address from ${widget.sidechainName}...',
                        ),
                        controller: TextEditingController(text: depositAddress ?? ''),
                        hintText: 's${widget.slot}_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx_xxxxxx',
                        readOnly: true,
                        suffixWidget: depositAddress != null ? CopyButton(text: depositAddress!) : null,
                      ),
                    ),
                    SailTooltip(
                      message: 'Generate new address',
                      child: SailButton(
                        variant: ButtonVariant.icon,
                        icon: SailSVGAsset.iconRestart,
                        onPressed: isFetchingAddress ? null : _fetchDepositAddress,
                      ),
                    ),
                  ],
                ),
                const SailSpacing(SailStyleValues.padding16),
                SailRow(
                  spacing: SailStyleValues.padding08,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 2,
                      child: NumericField(
                        label: 'Deposit Amount',
                        controller: amountController,
                        hintText: '0.00',
                      ),
                    ),
                    UnitDropdown(value: Unit.BTC, onChanged: (_) {}, enabled: false),
                    Expanded(
                      flex: 2,
                      child: FromWalletField(
                        selectedWalletId: fromWalletId,
                        onChanged: (walletId) => setState(() => selectedWalletId = walletId),
                      ),
                    ),
                  ],
                ),
                const SailSpacing(SailStyleValues.padding08),
                DepositFeeFields(estimate: depositFee, onTargetChanged: _setFeeTarget),
                const SailSpacing(SailStyleValues.padding08),
                _LeavesWalletRow(amount: amountController.text, fee: feeController.text),
                const SailSpacing(SailStyleValues.padding08),
                SailText.secondary13(
                  '${widget.sidechainName} may deduct its own fee, so the credited amount can be lower.',
                  color: context.sailTheme.colors.textTertiary,
                ),
                const SailSpacing(SailStyleValues.padding20),
                SailButton(
                  label: 'Deposit',
                  loading: isLoading,
                  disabled:
                      depositAddress == null ||
                      fromWalletId == null ||
                      amountController.text.isEmpty ||
                      feeController.text.isEmpty,
                  onPressed: _deposit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The deposit amount plus the L1 fee. Hidden until both parse.
class _LeavesWalletRow extends StatelessWidget {
  final String amount;
  final String fee;

  const _LeavesWalletRow({required this.amount, required this.fee});

  @override
  Widget build(BuildContext context) {
    final amountBTC = double.tryParse(amount);
    final feeBTC = double.tryParse(fee);
    if (amountBTC == null || feeBTC == null) {
      return const SizedBox.shrink();
    }

    final formatter = GetIt.I<FormatterProvider>();
    final totalSats = btcToSatoshi(amountBTC) + btcToSatoshi(feeBTC);

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, _) => Container(
        padding: const EdgeInsets.only(top: SailStyleValues.padding12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.sailTheme.colors.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SailText.primary13('Leaves your wallet'),
            SailText.primary13(formatter.formatSats(totalSats), bold: true),
          ],
        ),
      ),
    );
  }
}
