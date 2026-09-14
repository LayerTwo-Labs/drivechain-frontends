import 'dart:async';

import 'package:bitwindow/models/burn_ecx_amount.dart';
import 'package:bitwindow/utils/explorer_url.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:url_launcher/url_launcher.dart';

typedef _BurnContext = ({String? walletId, BitcoinNetwork network, String networkId, String? blocked});

class BurnEcxCard extends StatefulWidget {
  final String burnAddress;
  final int minimumSats;

  const BurnEcxCard({
    super.key,
    this.burnAddress = burnEcxAddress,
    this.minimumSats = burnEcxMinimumSats,
  });

  @override
  State<BurnEcxCard> createState() => _BurnEcxCardState();
}

class _BurnEcxCardState extends State<BurnEcxCard> {
  final _wallet = GetIt.I.get<OrchestratorRPC>().wallet;
  final _reader = GetIt.I.get<WalletReaderProvider>();
  final _conf = GetIt.I.get<BitcoinConfProvider>();
  final _amountController = TextEditingController();
  late _BurnContext _context;
  Timer? _timer;
  int _version = 0;
  int? _amountSats;
  int? _feeSats;
  String? _address;
  String? _psbt;
  String _warningMessage = '';
  String? _error;
  String? _txid;
  String? _explorerUrl;
  bool _prepareBusy = false;
  bool _sendBusy = false;

  _BurnContext _readContext() {
    final wallet = _reader.activeWallet;
    final blocked = _reader.isWalletLocked
        ? 'Unlock this wallet to burn coins.'
        : wallet == null
        ? 'Select a wallet to burn coins.'
        : !wallet.isElectrum
        ? 'This wallet cannot burn coins. Select an Electrum wallet.'
        : wallet.isMultisig
        ? 'Use the CLI to export this multisig burn and collect cosigner signatures.'
        : wallet.isWatchOnly || wallet.isHardware
        ? 'This wallet cannot sign this burn. Select a software wallet with its private key.'
        : null;
    return (
      walletId: wallet?.id,
      network: _conf.network,
      networkId: _conf.ecashNetworkId.isNotEmpty ? _conf.ecashNetworkId : _conf.currentNetworkOptionId,
      blocked: blocked,
    );
  }

  bool get _isAlphanet => _context.network == BitcoinNetwork.BITCOIN_NETWORK_ECASH && _context.networkId == 'alphanet';

  @override
  void initState() {
    super.initState();
    _context = _readContext();
    _reader.addListener(_onContextChanged);
    _conf.addListener(_onContextChanged);
  }

  @override
  void didUpdateWidget(BurnEcxCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.burnAddress != widget.burnAddress || oldWidget.minimumSats != widget.minimumSats) {
      _reset();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _reader.removeListener(_onContextChanged);
    _conf.removeListener(_onContextChanged);
    _amountController.dispose();
    super.dispose();
  }

  void _onContextChanged() {
    final next = _readContext();
    if (next == _context) {
      return;
    }
    setState(() {
      _context = next;
      _reset();
    });
  }

  void _reset() {
    _timer?.cancel();
    _version++;
    _amountController.clear();
    _amountSats = null;
    _feeSats = null;
    _address = null;
    _psbt = null;
    _warningMessage = '';
    _error = null;
    _txid = null;
    _explorerUrl = null;
    _prepareBusy = false;
    _sendBusy = false;
  }

  bool _isCurrent(int version, _BurnContext context) =>
      mounted && version == _version && context == _readContext() && _isAlphanet && context.blocked == null;

  void _onAmountChanged(String value) {
    _timer?.cancel();
    _version++;
    setState(() {
      _psbt = null;
      _warningMessage = '';
      _feeSats = null;
      _address = null;
      _error = null;
      _amountSats = null;
      _prepareBusy = false;
      if (value.trim().isEmpty) {
        return;
      }
      try {
        _amountSats = parseBurnAmount(value);
        if (_amountSats! <= widget.minimumSats) {
          _error = 'The amount must exceed ${formatBurnAmount(widget.minimumSats)}.';
          return;
        }
      } on FormatException catch (error) {
        _error = error.message;
        return;
      }
      _prepareBusy = true;
      _timer = Timer(const Duration(milliseconds: 400), _prepare);
    });
  }

  Future<void> _prepare() async {
    final version = _version;
    final context = _context;
    final amount = _amountSats;
    if (amount == null || amount <= widget.minimumSats || !_isCurrent(version, context)) {
      return;
    }
    setState(() {
      _prepareBusy = true;
      _error = null;
    });
    try {
      final addresses = await _wallet.deriveAddresses(walletId: context.walletId!, startIndex: 0, count: 1);
      if (!_isCurrent(version, context)) {
        return;
      }
      if (addresses.addresses.length != 1 || addresses.addresses.single.isEmpty) {
        throw const FormatException('The wallet did not return its first address.');
      }
      final address = addresses.addresses.single;
      final psbt = await _wallet.createPsbt(
        walletId: context.walletId!,
        destinations: {widget.burnAddress: amount},
        opReturnMessage: address,
        subtractFeeFromAmount: false,
        allowReplay: false,
      );
      if (!_isCurrent(version, context)) {
        return;
      }
      final decoded = await _wallet.decodeTransaction(input: psbt, walletId: context.walletId!);
      if (!_isCurrent(version, context)) {
        return;
      }
      if (!decoded.hasFee || decoded.details.feeSats.isNegative) {
        throw const FormatException('The transaction has no exact network fee.');
      }
      setState(() {
        _address = address;
        _psbt = psbt;
        _feeSats = decoded.details.feeSats.toInt();
        _warningMessage = decoded.details.warningMessage;
        _prepareBusy = false;
      });
    } catch (error) {
      if (!_isCurrent(version, context)) {
        return;
      }
      setState(() {
        _prepareBusy = false;
        _error = _reason(error);
      });
    }
  }

  Future<void> _burn() async {
    final version = _version;
    final context = _context;
    final psbt = _psbt;
    if (psbt == null || _sendBusy || !_isCurrent(version, context)) {
      return;
    }
    setState(() {
      _sendBusy = true;
      _error = null;
    });
    try {
      final signed = await _wallet.signPsbt(walletId: context.walletId!, psbtBase64: psbt);
      if (!_isCurrent(version, context)) {
        return;
      }
      final hex = await _wallet.finalizePsbt(psbtBase64: signed);
      if (!_isCurrent(version, context)) {
        return;
      }
      final txid = await _wallet.broadcastTransaction(walletId: context.walletId!, txHex: hex);
      if (!_isCurrent(version, context)) {
        return;
      }
      setState(() {
        _txid = txid;
        _explorerUrl = mempoolTxUrl(txid, context.network);
        _sendBusy = false;
      });
    } catch (error) {
      if (!_isCurrent(version, context)) {
        return;
      }
      setState(() {
        _sendBusy = false;
        _error = _reason(error);
      });
    }
  }

  String _reason(Object error) => switch (error) {
    WalletException() => error.message,
    FormatException() => error.message,
    _ => error.toString(),
  };

  @override
  Widget build(BuildContext context) {
    if (!_isAlphanet) {
      return const SizedBox.shrink();
    }
    final theme = SailTheme.of(context);
    return SailCard(
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _txid != null ? _receipt(theme) : _form(theme),
      ),
    );
  }

  List<Widget> _form(SailThemeData theme) {
    final amount = _amountSats;
    final fee = _feeSats;
    return [
      SailColumn(
        spacing: SailStyleValues.padding04,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary15('Burn Transaction', bold: true),
          SailText.secondary13('Burn Alphanet coins to receive 1/100 of the amount as real ECX.'),
        ],
      ),
      SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary12('Alphanet amount', bold: true),
          SailTextField(
            controller: _amountController,
            hintText: '0.00000000',
            suffix: 'ECX',
            monospace: true,
            maxLines: 1,
            enabled: !_sendBusy && _context.blocked == null,
            onChanged: _onAmountChanged,
          ),
          if (_context.blocked != null) SailText.secondary12(_context.blocked!),
          if (_error != null) SailText.secondary12(_error!, color: theme.colors.error),
          if (_prepareBusy) SailText.secondary12('Please wait for the exact network fee.'),
        ],
      ),
      if (amount != null && amount > widget.minimumSats) ...[
        _route(theme, amount),
        _outputs(theme, amount),
        if (fee != null) _totals(theme, amount, fee),
      ],
      SailColumn(
        spacing: SailStyleValues.padding10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_warningMessage.isEmpty)
            SailText.secondary12('You cannot reverse this burn')
          else
            SailAlert(variant: SailAlertVariant.warning, description: _warningMessage),
          SizedBox(
            width: double.infinity,
            child: SailButton(
              label: 'Burn Transaction',
              icon: SailSVGAsset.coins,
              loading: _sendBusy,
              disabled: _psbt == null || _context.blocked != null,
              onPressed: _burn,
            ),
          ),
          if (_error != null && _psbt == null && amount != null && amount > widget.minimumSats)
            SailButton(label: 'Try again', variant: ButtonVariant.link, onPressed: _prepare),
        ],
      ),
    ];
  }

  Widget _outputs(SailThemeData theme, int amount) => SailColumn(
    spacing: SailStyleValues.padding08,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SailText.secondary12('Transaction outputs', bold: true),
      _panel(
        theme,
        SailColumn(
          spacing: SailStyleValues.padding08,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('To BitcoinEater', formatBurnAmount(amount)),
            SailText.primary12(widget.burnAddress, overflow: TextOverflow.visible),
            SailText.secondary12('This transaction burns the bitcoins on Alphanet.'),
            Divider(height: 1, color: theme.colors.divider),
            _row('OP_RETURN', '0 ECX'),
            SailText.primary12(
              _address ?? 'The wallet will provide its first address.',
              overflow: TextOverflow.visible,
            ),
            SailText.secondary12('You will receive 1/100 of the amount you burn as real ECX at this address.'),
            SailText.secondary12('The credit rounds up to a whole ECX satoshi.'),
            SailText.secondary12('The address used is the first address of this wallet.'),
          ],
        ),
      ),
    ],
  );

  Widget _totals(SailThemeData theme, int amount, int fee) => SailColumn(
    spacing: SailStyleValues.padding08,
    children: [
      Divider(height: 1, color: theme.colors.divider),
      _row('Network fee', formatBurnAmount(fee)),
      _row('Total from Alphanet', formatBurnAmount(amount + fee)),
    ],
  );

  Widget _route(SailThemeData theme, int amount, {bool sent = false}) => _panel(
    theme,
    Row(
      children: [
        Expanded(
          child: SailColumn(
            spacing: SailStyleValues.padding04,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.secondary12('Alphanet'),
              SailText.primary13(formatBurnAmount(amount, compact: true), bold: true),
              SailText.secondary12(sent ? 'Burn sent' : 'Burn permanently'),
            ],
          ),
        ),
        SailSVG.icon(SailSVGAsset.arrowRight, width: 16, color: theme.colors.textSecondary),
        const SailSpacing(SailStyleValues.padding12),
        Expanded(
          child: SailColumn(
            spacing: SailStyleValues.padding04,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.secondary12('Real ECX'),
              SailText.primary13(formatEcxCredit(amount, compact: true), bold: true),
              SailText.secondary12(sent ? 'Credit pending' : 'Credit after acceptance'),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _panel(SailThemeData theme, Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(SailStyleValues.padding12),
    decoration: BoxDecoration(
      color: theme.colors.background,
      borderRadius: SailStyleValues.borderRadius,
      border: Border.all(color: theme.colors.border),
    ),
    child: child,
  );

  Widget _row(String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: SailText.secondary12(label)),
      const SailSpacing(SailStyleValues.padding08),
      Expanded(child: SailText.primary12(value, textAlign: TextAlign.end)),
    ],
  );

  List<Widget> _receipt(SailThemeData theme) => [
    SailText.primary15('Burn sent', bold: true),
    if (_warningMessage.isNotEmpty) SailAlert(variant: SailAlertVariant.warning, description: _warningMessage),
    _route(theme, _amountSats!, sent: true),
    SailText.secondary12('Your real ECX credit remains pending.'),
    _outputs(theme, _amountSats!),
    _totals(theme, _amountSats!, _feeSats!),
    _panel(theme, SailText.primary12(_txid!, overflow: TextOverflow.visible)),
    SailButton(
      label: 'View on the explorer',
      variant: ButtonVariant.link,
      icon: SailSVGAsset.externalLink,
      onPressed: () async {
        final version = _version;
        try {
          final opened = await launchUrl(Uri.parse(_explorerUrl!));
          if (mounted && version == _version) {
            setState(() => _error = opened ? null : 'The explorer did not open.');
          }
        } catch (error) {
          if (mounted && version == _version) {
            setState(() => _error = _reason(error));
          }
        }
      },
    ),
    if (_error != null) SailText.secondary12(_error!, color: theme.colors.error),
    SailButton(
      label: 'Back to burn form',
      variant: ButtonVariant.link,
      onPressed: () async => setState(_reset),
    ),
  ];
}
