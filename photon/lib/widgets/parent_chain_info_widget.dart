import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class ParentChainInfoWidget extends StatelessWidget {
  const ParentChainInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ParentChainInfoViewModel>.reactive(
      viewModelBuilder: () => ParentChainInfoViewModel(),
      builder: (context, model, child) {
        final theme = SailTheme.of(context);

        return SailCard(
          title: 'Parent Chain Info',
          widgetHeaderEnd: SailButton(
            label: 'Refresh',
            variant: ButtonVariant.secondary,
            small: true,
            onPressed: model.refresh,
            loading: model.isRefreshing,
          ),
          child: model.error != null
              ? SailText.primary13(model.error!, color: theme.colors.error)
              : SailColumn(
                  spacing: SailStyleValues.padding08,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      label: 'Mainchain tip hash',
                      value: model.mainchainTipHash ?? '-',
                      loading: model.mainchainTipHash == null,
                      selectable: true,
                    ),
                    _InfoRow(
                      label: 'Mainchain tip height',
                      value: model.mainchainTipHeight?.toString() ?? '-',
                      loading: model.mainchainTipHeight == null,
                    ),
                    _InfoRow(
                      label: 'Sidechain wealth',
                      value: model.sidechainWealthFormatted,
                      loading: model.sidechainWealth == null,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool loading;
  final bool selectable;

  const _InfoRow({
    required this.label,
    required this.value,
    this.loading = false,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      children: [
        SailText.secondary13('$label:'),
        Expanded(
          child: SailSkeletonizer(
            enabled: loading,
            description: 'Loading...',
            child: selectable
                ? SelectableText(
                    value,
                    style: SailStyleValues.thirteen.copyWith(
                      fontFamily: 'monospace',
                      color: SailTheme.of(context).colors.text,
                    ),
                  )
                : SailText.primary13(value, monospace: true),
          ),
        ),
      ],
    );
  }
}

class ParentChainInfoViewModel extends BaseViewModel {
  PhotonRPC get _rpc => GetIt.I.get<PhotonRPC>();
  MainchainRPC get _mainchainRPC => GetIt.I.get<MainchainRPC>();

  String? mainchainTipHash;
  int? mainchainTipHeight;
  double? sidechainWealth;
  String? error;
  bool isRefreshing = false;

  String get sidechainWealthFormatted {
    if (sidechainWealth == null) return '-';
    return '${sidechainWealth!.toStringAsFixed(8)} BTC';
  }

  ParentChainInfoViewModel() {
    _fetchInfo();
  }

  Future<void> _fetchInfo() async {
    try {
      error = null;

      final hashFuture = _rpc.getBestMainchainBlockHash();
      final wealthFuture = _rpc.getSidechainWealth();
      final blockchainInfoFuture = _mainchainRPC.getBlockchainInfo();

      final results = await Future.wait([hashFuture, wealthFuture, blockchainInfoFuture]);

      mainchainTipHash = results[0] as String?;
      sidechainWealth = results[1] as double?;
      mainchainTipHeight = (results[2] as BlockchainInfo?)?.blocks;

      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    isRefreshing = true;
    notifyListeners();

    try {
      await _fetchInfo();
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }
}
