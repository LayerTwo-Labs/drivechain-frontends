import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class MinerWidget extends StatelessWidget {
  const MinerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MinerViewModel>.reactive(
      viewModelBuilder: () => MinerViewModel(),
      builder: (context, model, child) {
        return SailCard(
          title: 'Miner',
          child: SailColumn(
            spacing: SailStyleValues.padding08,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                label: 'Block height',
                value: model.blockHeight?.toString() ?? '-',
                loading: model.blockHeight == null,
              ),
              _InfoRow(
                label: 'Best hash',
                value: model.bestHashTruncated,
                loading: model.bestHash == null,
              ),
              const SizedBox(height: SailStyleValues.padding08),
              SailButton(
                label: 'Mine / Refresh Block',
                onPressed: model.mine,
                loading: model.isMining,
                disabled: model.isMining,
              ),
              if (model.mineError != null)
                Padding(
                  padding: const EdgeInsets.only(top: SailStyleValues.padding08),
                  child: SailText.primary12(
                    model.mineError!,
                    color: SailTheme.of(context).colors.error,
                  ),
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

  const _InfoRow({
    required this.label,
    required this.value,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      children: [
        SailText.secondary13('$label:'),
        SailSkeletonizer(
          enabled: loading,
          description: 'Loading...',
          child: SailText.primary13(value, monospace: true),
        ),
      ],
    );
  }
}

class MinerViewModel extends BaseViewModel {
  PhotonRPC get _rpc => GetIt.I.get<PhotonRPC>();

  int? blockHeight;
  String? bestHash;
  bool isMining = false;
  String? mineError;

  String get bestHashTruncated {
    if (bestHash == null) return '-';
    if (bestHash!.length <= 8) return bestHash!;
    return '${bestHash!.substring(0, 8)}...';
  }

  MinerViewModel() {
    _fetchInfo();
  }

  Future<void> _fetchInfo() async {
    try {
      blockHeight = await _rpc.getBlockCount();
      bestHash = await _rpc.getBestSidechainBlockHash();
      notifyListeners();
    } catch (e) {
      // Ignore errors during initial fetch
    }
  }

  Future<void> mine() async {
    isMining = true;
    mineError = null;
    notifyListeners();

    try {
      await _rpc.mine(0);
      await _fetchInfo();
    } catch (e) {
      mineError = e.toString();
    } finally {
      isMining = false;
      notifyListeners();
    }
  }
}
