import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/sidechain_activation_management_page.dart';
import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/sidechains/hosted_modules.dart';
import 'package:bitwindow/sidechains/sidechain_scope.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';
import 'package:stacked/stacked.dart' show BaseViewModel, ViewModelBuilder;

/// Opens the view of [chain] inside BitWindow.
Future<void> openSidechainHere(Sidechain chain) {
  return GetIt.I.get<AppRouter>().navigate(SidechainsRoute(children: [SidechainHostRoute(chain: chain.registryKey)]));
}

/// The navigator of a chain that BitWindow hosts, on the router of BitWindow.
class HostChainNavigator implements ChainNavigator {
  final Sidechain chain;

  const HostChainNavigator(this.chain);

  AppRouter get _router => GetIt.I.get<AppRouter>();

  @override
  Future<void> openTab(PageRouteInfo tab) => _router.navigate(
    SidechainsRoute(
      children: [
        SidechainHostRoute(chain: chain.registryKey, children: [tab]),
      ],
    ),
  );

  @override
  Future<void> push(PageRouteInfo route) => _router.push(route);

  @override
  Future<void> pop() => _router.maybePop();
}

/// One sidechain inside BitWindow: the chain list on the left, the chain and its tabs on the right.
@RoutePage()
class SidechainHostPage extends StatelessWidget {
  final String chain;

  const SidechainHostPage({super.key, @PathParam('chain') required this.chain});

  @override
  Widget build(BuildContext context) {
    final module = hostedModuleByKey(chain);
    final colors = SailTheme.of(context).colors;

    return ViewModelBuilder<SidechainSidebarViewModel>.reactive(
      viewModelBuilder: () => SidechainSidebarViewModel(),
      builder: (context, model, child) => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SidechainSidebar(
            entries: model.entries(open: module),
            selected: module?.chain.registryKey,
            total: model.total,
            onSelect: (entry) => openSidechainHere(entry.module.chain),
            onAllSlots: () => context.router.navigate(const SidechainSlotsRoute()),
            onAddRemove: model.sidechainManagementUnavailable
                ? null
                : () => showSidechainActivationManagementModal(context),
          ),
          Container(width: 1, color: colors.divider),
          Expanded(
            child: module == null
                ? Center(child: SailText.secondary13('BitWindow cannot open $chain here.'))
                : KeyedSubtree(
                    key: ValueKey(module.chain.registryKey),
                    child: SidechainScopeHost(
                      module: module,
                      child: HostedChainView(module: module),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Holds the GetIt scope of [module] while it is on screen.
class SidechainScopeHost extends StatefulWidget {
  final SidechainModule module;
  final Widget child;

  const SidechainScopeHost({super.key, required this.module, required this.child});

  @override
  State<SidechainScopeHost> createState() => _SidechainScopeHostState();
}

class _SidechainScopeHostState extends State<SidechainScopeHost> {
  late final Future<void> _entered;

  @override
  void initState() {
    super.initState();
    _entered = enterSidechainScope(
      widget.module,
      navigator: HostChainNavigator(widget.module.chain),
      applicationDir: GetIt.I.get<WindowProvider>().appDir,
      log: GetIt.I.get<Logger>(),
    );
  }

  @override
  void dispose() {
    unawaited(exitSidechainScope(widget.module));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _entered,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: SailText.secondary13('Could not open ${widget.module.appName}: ${snapshot.error}'));
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: LoadingIndicator());
        }
        return widget.child;
      },
    );
  }
}

/// The header of the open chain, its tabs, and the page of the active tab.
class HostedChainView extends StatelessWidget {
  final SidechainModule module;

  const HostedChainView({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    final labels = shellTabLabels(module);

    return AutoTabsRouter(
      homeIndex: ShellTabIndex.of(module).homepage,
      routes: shellTabRoutes(module),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SailStyleValues.padding16,
                SailStyleValues.padding12,
                SailStyleValues.padding16,
                0,
              ),
              child: ViewModelBuilder<HostedChainViewModel>.reactive(
                viewModelBuilder: () => HostedChainViewModel(module),
                builder: (context, model, _) => HostedChainHeader(model: model),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding16),
              child: ChainTabRow(
                labels: labels,
                activeIndex: tabsRouter.activeIndex,
                onSelect: tabsRouter.setActiveIndex,
              ),
            ),
            Container(height: 1, color: colors.divider),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

/// Underline tabs: the active tab carries an orange line.
class ChainTabRow extends StatelessWidget {
  final List<String> labels;
  final int activeIndex;
  final void Function(int index) onSelect;

  const ChainTabRow({super.key, required this.labels, required this.activeIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SailRow(
        spacing: SailStyleValues.padding25,
        children: [
          for (final (index, label) in labels.indexed)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(index),
                child: Container(
                  padding: const EdgeInsets.only(top: SailStyleValues.padding08, bottom: SailStyleValues.padding08),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: index == activeIndex ? colors.orange : const Color(0x00000000),
                        width: 2,
                      ),
                    ),
                  ),
                  child: SailText.primary13(label, color: index == activeIndex ? colors.text : colors.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HostedChainHeader extends StatelessWidget {
  final HostedChainViewModel model;

  const HostedChainHeader({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SailText.primary15(model.chain.name, bold: true),
        const SizedBox(width: SailStyleValues.padding12),
        SailBadge(model.stateLabel, tone: model.stateTone),
        const SizedBox(width: SailStyleValues.padding12),
        if (model.running) SailText.secondary13(model.balance),
        const Spacer(),
        SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            SailButton(
              label: 'Deposit',
              variant: ButtonVariant.outline,
              onPressed: () => showDepositModal(context, model.chain.slot, model.chain.name),
            ),
            if (model.hasWindow)
              SailButton(
                label: 'Open in separate window',
                variant: ButtonVariant.outline,
                onPressed: model.openWindow,
              ),
            if (model.running || model.starting)
              SailButton(label: 'Stop', variant: ButtonVariant.outline, onPressed: model.stop)
            else
              SailButton(label: 'Start', variant: ButtonVariant.primary, onPressed: model.start),
          ],
        ),
      ],
    );
  }
}

class HostedChainViewModel extends BaseViewModel {
  final SidechainModule module;
  final BinaryProvider _binaries = GetIt.I.get<BinaryProvider>();
  final SidechainBalanceProvider _balance = GetIt.I.get<SidechainBalanceProvider>();
  final FormatterProvider _formatter = GetIt.I.get<FormatterProvider>();

  HostedChainViewModel(this.module) {
    _binaries.addListener(notifyListeners);
    _balance.addListener(notifyListeners);
    _formatter.addListener(notifyListeners);
  }

  Sidechain get chain =>
      (_binaries.binaries.firstWhereOrNull((b) => b.type == module.chain.type) ?? module.chain) as Sidechain;

  bool get running => _binaries.isConnected(chain);
  bool get starting => !running && _binaries.isInitializing(chain);
  bool get hasWindow => _binaries.hasWindow(chain);

  String get stateLabel => running
      ? 'Running'
      : starting
      ? 'Starting'
      : 'Stopped';

  SailBadgeTone get stateTone => running
      ? SailBadgeTone.success
      : starting
      ? SailBadgeTone.warning
      : SailBadgeTone.neutral;

  String get balance => _formatter.formatBTC(_balance.balance);

  Future<void> start() => _binaries.start(chain, background: true);
  Future<void> stop() => _binaries.stop(chain);
  Future<void> openWindow() => _binaries.start(chain);

  @override
  void dispose() {
    _binaries.removeListener(notifyListeners);
    _balance.removeListener(notifyListeners);
    _formatter.removeListener(notifyListeners);
    super.dispose();
  }
}

/// One chain in the sidebar.
class SidechainSidebarEntry {
  final SidechainModule module;
  final Color color;
  final bool running;

  /// The balance of a running chain, else its state.
  final String trailing;

  const SidechainSidebarEntry({
    required this.module,
    required this.color,
    required this.running,
    required this.trailing,
  });
}

/// The hosted chains, grouped by state, with the total of the running balances.
class SidechainSidebar extends StatelessWidget {
  final List<SidechainSidebarEntry> entries;
  final String? selected;
  final String total;
  final void Function(SidechainSidebarEntry entry) onSelect;
  final VoidCallback onAllSlots;
  final VoidCallback? onAddRemove;

  const SidechainSidebar({
    super.key,
    required this.entries,
    required this.selected,
    required this.total,
    required this.onSelect,
    required this.onAllSlots,
    required this.onAddRemove,
  });

  @override
  Widget build(BuildContext context) {
    final running = entries.where((e) => e.running).toList();
    final stopped = entries.where((e) => !e.running).toList();

    return SizedBox(
      width: 240,
      child: Padding(
        padding: const EdgeInsets.all(SailStyleValues.padding12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.secondary12('Sidechain balance'),
                  const SizedBox(height: SailStyleValues.padding04),
                  SailText.primary20(total),
                ],
              ),
            ),
            const SizedBox(height: SailStyleValues.padding20),
            Expanded(
              child: ListView(
                children: [
                  if (running.isNotEmpty) ...[
                    _GroupTitle('Running'),
                    for (final entry in running) _row(entry),
                    const SizedBox(height: SailStyleValues.padding12),
                  ],
                  if (stopped.isNotEmpty) ...[
                    _GroupTitle('Stopped'),
                    for (final entry in stopped) _row(entry),
                  ],
                ],
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onAllSlots,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SailStyleValues.padding08,
                    vertical: SailStyleValues.padding08,
                  ),
                  child: SailText.secondary13('All slots'),
                ),
              ),
            ),
            SailButton(
              label: 'Add / Remove',
              variant: ButtonVariant.outline,
              onPressed: onAddRemove == null ? null : () async => onAddRemove!(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(SidechainSidebarEntry entry) => _SidebarRow(
    entry: entry,
    selected: entry.module.chain.registryKey == selected,
    onTap: () => onSelect(entry),
  );
}

class _GroupTitle extends StatelessWidget {
  final String title;

  const _GroupTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding08, vertical: SailStyleValues.padding04),
      child: SailText.secondary12(title),
    );
  }
}

class _SidebarRow extends StatelessWidget {
  final SidechainSidebarEntry entry;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarRow({required this.entry, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    final name = entry.module.chain.name;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          key: ValueKey('sidebar_${entry.module.chain.registryKey}'),
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding08),
          decoration: BoxDecoration(
            color: selected ? colors.backgroundSecondary : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Opacity(
                opacity: entry.running ? 1 : 0.45,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: entry.color, borderRadius: BorderRadius.circular(4)),
                  child: SailText.primary10(name.substring(0, 1).toUpperCase(), color: const Color(0xFFFFFFFF)),
                ),
              ),
              const SizedBox(width: SailStyleValues.padding08),
              Expanded(
                child: SailText.primary13(
                  name,
                  bold: selected,
                  color: entry.running ? colors.text : colors.textSecondary,
                ),
              ),
              SailText.secondary12(entry.trailing),
            ],
          ),
        ),
      ),
    );
  }
}

class SidechainSidebarViewModel extends BaseViewModel {
  final BinaryProvider _binaries = GetIt.I.get<BinaryProvider>();
  final BalanceProvider _balances = GetIt.I.get<BalanceProvider>();
  final SidechainProvider _slots = GetIt.I.get<SidechainProvider>();
  final FormatterProvider _formatter = GetIt.I.get<FormatterProvider>();

  SidechainSidebarViewModel() {
    _binaries.addListener(notifyListeners);
    _balances.addListener(notifyListeners);
    _slots.addListener(notifyListeners);
    _formatter.addListener(notifyListeners);
  }

  bool get sidechainManagementUnavailable => !NodeModeProvider.runsLocalBackends;

  Binary _binary(SidechainModule module) =>
      _binaries.binaries.firstWhereOrNull((b) => b.type == module.chain.type) ?? module.chain;

  bool _running(SidechainModule module) => _binaries.isConnected(_binary(module));

  double _balance(SidechainModule module) => _balances.balanceFor(module.registerRPC(GetIt.I)).$1;

  /// The hosted chains in an active slot, and [open] in all cases.
  List<SidechainSidebarEntry> entries({SidechainModule? open}) => [
    for (final module in hostedModules)
      if (module == open || _slots.sidechains[module.chain.slot] != null)
        SidechainSidebarEntry(
          module: module,
          color: _binary(module).color,
          running: _running(module),
          trailing: _running(module)
              ? _formatter.formatBTC(_balance(module))
              : _binary(module).isDownloaded
              ? 'Stopped'
              : 'Not downloaded',
        ),
  ];

  String get total => _formatter.formatBTC(
    hostedModules.where(_running).fold(0.0, (sum, module) => sum + _balance(module)),
  );

  @override
  void dispose() {
    _binaries.removeListener(notifyListeners);
    _balances.removeListener(notifyListeners);
    _slots.removeListener(notifyListeners);
    _formatter.removeListener(notifyListeners);
    super.dispose();
  }
}
