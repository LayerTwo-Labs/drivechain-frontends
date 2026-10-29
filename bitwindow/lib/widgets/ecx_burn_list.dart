import 'dart:convert';
import 'dart:typed_data';

import 'package:bitwindow/models/burn_ecx_amount.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

Future<void> showEcxBurnList(BuildContext context, {required String networkName, required String networkId}) {
  return showThemedDialog(
    context: context,
    builder: (context) => SailModal(
      constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 900),
      child: EcxBurnList(networkName: networkName, networkId: networkId),
    ),
  );
}

class EcxBurnList extends StatefulWidget {
  final String networkName;
  final String networkId;

  const EcxBurnList({super.key, required this.networkName, required this.networkId});

  @override
  State<EcxBurnList> createState() => _EcxBurnListState();
}

/// Networks whose burns only a node of their own can list.
const nodeOnlyBurnNetworks = {'alphanet'};

class _EcxBurnListState extends State<EcxBurnList> {
  final _wallet = GetIt.I.get<OrchestratorRPC>().wallet;
  final _coreUrl = TextEditingController(text: 'http://127.0.0.1:18302');
  final _coreCookie = TextEditingController();
  wmpb.ListEcxBurnsResponse? _burns;
  String? _error;
  bool _loading = false;

  bool get _needsNode => nodeOnlyBurnNetworks.contains(widget.networkId);

  @override
  void initState() {
    super.initState();
    if (!_needsNode) {
      _load();
    }
  }

  @override
  void dispose() {
    _coreUrl.dispose();
    _coreCookie.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final burns = _needsNode
          ? await _wallet.listEcxBurns(
              networkId: widget.networkId,
              coreUrl: _coreUrl.text.trim(),
              coreCookiePath: _coreCookie.text.trim(),
            )
          : await _wallet.listEcxBurns();
      if (mounted) {
        setState(() => _burns = burns);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'The burn list did not load: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _downloadCsv() async {
    final fileName = 'burn_${widget.networkId}.csv';
    final saved = await FilePicker.saveFile(
      dialogTitle: 'Download CSV',
      fileName: fileName,
      bytes: Uint8List.fromList(utf8.encode(_burns!.csv)),
    );
    if (saved != null && mounted) {
      showSailToast(context, 'Saved $fileName');
    }
  }

  @override
  Widget build(BuildContext context) {
    final burns = _burns;
    return SailColumn(
      spacing: SailStyleValues.padding12,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SailText.primary24('${widget.networkName} burns', bold: true),
        if (_needsNode) _NodeForm(url: _coreUrl, cookie: _coreCookie, loading: _loading, onLoad: _load),
        if (_error != null)
          SailCard(
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.secondary13(_error!, color: SailTheme.of(context).colors.error),
                SailButton(label: 'Try again', variant: ButtonVariant.link, onPressed: _load),
              ],
            ),
          )
        else if (_loading)
          const SailCard(child: Center(child: LoadingIndicator()))
        else if (burns == null)
          const SizedBox.shrink()
        else ...[
          _Summary(burns: burns),
          Flexible(
            child: _BurnTable(burns: burns, onDownload: _downloadCsv),
          ),
        ],
      ],
    );
  }
}

class _NodeForm extends StatelessWidget {
  final TextEditingController url;
  final TextEditingController cookie;
  final bool loading;
  final VoidCallback onLoad;

  const _NodeForm({required this.url, required this.cookie, required this.loading, required this.onLoad});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      child: SailRow(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: SailColumn(
              spacing: SailStyleValues.padding04,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.secondary12('Node RPC URL', bold: true),
                SailTextField(controller: url, hintText: 'http://127.0.0.1:18302', monospace: true, maxLines: 1),
              ],
            ),
          ),
          Expanded(
            child: SailColumn(
              spacing: SailStyleValues.padding04,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.secondary12('Cookie file', bold: true),
                SailTextField(controller: cookie, hintText: '/path/to/.cookie', monospace: true, maxLines: 1),
              ],
            ),
          ),
          SailButton(label: 'Load', loading: loading, onPressed: () async => onLoad()),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final wmpb.ListEcxBurnsResponse burns;

  const _Summary({required this.burns});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailColumn(
            spacing: SailStyleValues.padding04,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary13('Burned', bold: true),
              SailText.primary24(formatBurnAmount(burns.totalBurnSats.toInt(), activeTicker.symbol), bold: true),
              SailText.secondary12('Sent to $burnEcxAddress'),
            ],
          ),
          SailRow(
            spacing: SailStyleValues.padding16,
            children: [
              Expanded(
                child: SailColumn(
                  spacing: SailStyleValues.padding08,
                  children: [
                    _Field('Burns', '${burns.burns.length}'),
                    _Field('Payout addresses', '${burns.payoutAddressCount}'),
                  ],
                ),
              ),
              Expanded(
                child: SailColumn(
                  spacing: SailStyleValues.padding08,
                  children: [_Field('Payout', formatEcxAmount(burns.totalPayoutSats.toInt()))],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;

  const _Field(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadiusSmall,
      ),
      child: SailRow(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [SailText.secondary13(label), SailText.primary13(value)],
      ),
    );
  }
}

class _BurnTable extends StatelessWidget {
  final wmpb.ListEcxBurnsResponse burns;
  final Future<void> Function() onDownload;

  const _BurnTable({required this.burns, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Burns',
      subtitle: '${burns.burns.length} burns · newest first',
      widgetHeaderEnd: SailButton(
        label: 'Download CSV',
        icon: SailSVGAsset.download,
        variant: ButtonVariant.outline,
        disabled: burns.burns.isEmpty,
        onPressed: onDownload,
      ),
      child: SailTable(
        getRowId: (i) => burns.burns[i].txid,
        headerBuilder: (_) => [
          SailTableHeaderCell(name: 'Payout address'),
          SailTableHeaderCell(name: 'Burned'),
          SailTableHeaderCell(name: 'Payout'),
          SailTableHeaderCell(name: 'Height'),
          SailTableHeaderCell(name: 'Transaction'),
        ],
        rowBuilder: (_, i, _) {
          final burn = burns.burns[i];
          return [
            SailTableCell(value: burn.payoutAddress, monospace: true, copyValue: burn.payoutAddress),
            SailTableCell(value: formatBurnAmount(burn.burnSats.toInt(), activeTicker.symbol), monospace: true),
            SailTableCell(value: formatEcxAmount(burn.payoutSats.toInt()), monospace: true),
            SailTableCell(value: burn.height == 0 ? 'Unconfirmed' : '${burn.height}'),
            SailTableCell(value: burn.txid, monospace: true, copyValue: burn.txid),
          ];
        },
        rowCount: burns.burns.length,
        emptyPlaceholder: 'No burns',
      ),
    );
  }
}
