import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class BlockExplorerPage extends StatelessWidget {
  const BlockExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder<BlockExplorerViewModel>.reactive(
        viewModelBuilder: () => BlockExplorerViewModel(),
        builder: (context, model, child) {
          final theme = SailTheme.of(context);

          return SailCard(
            title: 'Block Explorer',
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Navigation controls
                _BlockNavigationControls(model: model),
                const Divider(),
                // Block details
                if (model.error != null)
                  SailText.primary13(model.error!, color: theme.colors.error)
                else if (model.block == null)
                  const Center(child: SailCircularProgressIndicator())
                else
                  Expanded(child: _BlockDetails(model: model)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BlockNavigationControls extends StatelessWidget {
  final BlockExplorerViewModel model;

  const _BlockNavigationControls({required this.model});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      children: [
        SailButton(
          label: '<',
          variant: ButtonVariant.secondary,
          onPressed: model.canGoBack ? () async => model.goBack() : null,
          disabled: !model.canGoBack,
        ),
        SizedBox(
          width: 100,
          child: SailTextField(
            controller: model.heightController,
            hintText: 'Height',
            textAlign: TextAlign.center,
            onSubmitted: (_) => model.goToHeight(),
          ),
        ),
        SailButton(
          label: '>',
          variant: ButtonVariant.secondary,
          onPressed: model.canGoForward ? () async => model.goForward() : null,
          disabled: !model.canGoForward,
        ),
        SailButton(
          label: 'Latest',
          variant: ButtonVariant.secondary,
          onPressed: () async => model.goToLatest(),
        ),
        const SizedBox(width: SailStyleValues.padding16),
        SailText.secondary13('Block ${model.currentHeight} of ${model.maxHeight ?? "?"}'),
      ],
    );
  }
}

class _BlockDetails extends StatelessWidget {
  final BlockExplorerViewModel model;

  const _BlockDetails({required this.model});

  @override
  Widget build(BuildContext context) {
    final block = model.block!;
    final formatter = GetIt.I<FormatterProvider>();

    return SingleChildScrollView(
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BlockInfoRow(label: 'Block hash', value: block['hash']?.toString() ?? '-', selectable: true),
          _BlockInfoRow(label: 'Merkle root', value: block['merkle_root']?.toString() ?? '-', selectable: true),
          _BlockInfoRow(label: 'Prev side hash', value: block['prev_side_hash']?.toString() ?? '-', selectable: true),
          _BlockInfoRow(label: 'Prev main hash', value: block['prev_main_hash']?.toString() ?? '-', selectable: true),
          const Divider(),
          _BlockInfoRow(
            label: 'Num transactions',
            value: (block['num_transactions'] ?? block['transactions']?.length ?? 0).toString(),
          ),
          _BlockInfoRow(
            label: 'Coinbase value',
            value: _formatCoinbaseValue(block['coinbase_value'], formatter),
          ),
          _BlockInfoRow(
            label: 'Body size',
            value: _formatSize(block['body_size'] as int?),
          ),
          _BlockInfoRow(
            label: 'Num sigops',
            value: (block['num_sigops'] ?? 0).toString(),
          ),
          if (block['body_size_limit'] != null) ...[
            const Divider(),
            _BlockInfoRow(
              label: 'Body size limit',
              value: _formatSize(block['body_size_limit'] as int?),
            ),
          ],
          if (block['body_sigops_limit'] != null)
            _BlockInfoRow(
              label: 'Body sigops limit',
              value: (block['body_sigops_limit']).toString(),
            ),
          if (block['utreexo_accumulator'] != null) ...[
            const Divider(),
            SailText.secondary13('Utreexo accumulator:'),
            Container(
              padding: const EdgeInsets.all(SailStyleValues.padding08),
              decoration: BoxDecoration(
                color: SailTheme.of(context).colors.backgroundSecondary,
                borderRadius: SailStyleValues.borderRadiusSmall,
              ),
              child: SelectableText(
                block['utreexo_accumulator'].toString(),
                style: SailStyleValues.twelve.copyWith(
                  fontFamily: 'monospace',
                  color: SailTheme.of(context).colors.text,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCoinbaseValue(dynamic value, FormatterProvider formatter) {
    if (value == null) return '-';
    if (value is int) {
      return formatter.formatSats(value);
    }
    return value.toString();
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return '-';
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KiB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MiB';
    }
  }
}

class _BlockInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool selectable;

  const _BlockInfoRow({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: SailText.secondary13('$label:'),
        ),
        Expanded(
          child: selectable
              ? Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        value,
                        style: SailStyleValues.thirteen.copyWith(
                          fontFamily: 'monospace',
                          color: SailTheme.of(context).colors.text,
                        ),
                      ),
                    ),
                    if (value != '-') CopyButton(text: value),
                  ],
                )
              : SailText.primary13(value, monospace: true),
        ),
      ],
    );
  }
}

class BlockExplorerViewModel extends BaseViewModel {
  PhotonRPC get _rpc => GetIt.I.get<PhotonRPC>();

  final TextEditingController heightController = TextEditingController();

  int currentHeight = 0;
  int? maxHeight;
  Map<String, dynamic>? block;
  String? error;

  bool get canGoBack => currentHeight > 0;
  bool get canGoForward => maxHeight != null && currentHeight < maxHeight!;

  BlockExplorerViewModel() {
    _init();
  }

  Future<void> _init() async {
    try {
      maxHeight = await _rpc.getBlockCount();
      currentHeight = maxHeight ?? 0;
      heightController.text = currentHeight.toString();
      await _fetchBlock();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _fetchBlock() async {
    error = null;
    block = null;
    notifyListeners();

    try {
      final bestHash = await _rpc.getBestSidechainBlockHash();
      if (bestHash == null) {
        error = 'Could not get best hash';
        notifyListeners();
        return;
      }

      // For now, we can only fetch the current best block
      // The RPC needs block hash, and we'd need a getblockhash(height) method
      // to navigate by height. For now, show the best block.
      if (currentHeight == maxHeight) {
        block = await _rpc.getBlock(bestHash);
      } else {
        // Try to get block by constructing from the response
        // This is a limitation - we may need additional RPC methods
        block = await _rpc.getBlock(bestHash);
        error = 'Note: Block navigation by height requires additional RPC support. Showing best block.';
      }

      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  void goBack() {
    if (canGoBack) {
      currentHeight--;
      heightController.text = currentHeight.toString();
      _fetchBlock();
    }
  }

  void goForward() {
    if (canGoForward) {
      currentHeight++;
      heightController.text = currentHeight.toString();
      _fetchBlock();
    }
  }

  Future<void> goToLatest() async {
    try {
      maxHeight = await _rpc.getBlockCount();
      currentHeight = maxHeight ?? 0;
      heightController.text = currentHeight.toString();
      await _fetchBlock();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  void goToHeight() {
    final height = int.tryParse(heightController.text);
    if (height != null && height >= 0 && (maxHeight == null || height <= maxHeight!)) {
      currentHeight = height;
      _fetchBlock();
    }
  }

  @override
  void dispose() {
    heightController.dispose();
    super.dispose();
  }
}
