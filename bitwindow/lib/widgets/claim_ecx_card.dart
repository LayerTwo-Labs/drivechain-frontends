import 'dart:async';

import 'package:bitwindow/utils/explorer_url.dart';
import 'package:bitwindow/utils/paper_wallet_generator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:url_launcher/url_launcher.dart';

const _ticker = 'ECX';
const _checkDebounce = Duration(milliseconds: 400);

enum ClaimEcxStage { idle, invalid, checking, funds, empty, claiming, claimed, failed }

/// Self-contained claim of an investor ECX key: paste it, see what it holds,
/// choose where it lands, sweep it.
class ClaimEcxCard extends StatefulWidget {
  const ClaimEcxCard({super.key});

  @override
  State<ClaimEcxCard> createState() => _ClaimEcxCardState();
}

class _ClaimEcxCardState extends State<ClaimEcxCard> {
  final BitwindowRPC _bitwindow = GetIt.I.get<BitwindowRPC>();
  final OrchestratorWalletRPC _orchestratorWallet = GetIt.I.get<OrchestratorRPC>().wallet;
  final WalletReaderProvider _walletReader = GetIt.I.get<WalletReaderProvider>();

  final TextEditingController _wifController = TextEditingController();
  final TextEditingController _destController = TextEditingController();

  ClaimEcxStage _stage = ClaimEcxStage.idle;
  SweepPreview? _preview;
  String? _walletAddress;
  String? _walletAddressFor;
  bool _editingDestination = false;
  String? _txid;
  int _claimedSats = 0;
  String _failure = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _wifController.dispose();
    _destController.dispose();
    super.dispose();
  }

  String get _wif => _wifController.text.trim();

  String get _destination => _editingDestination ? _destController.text.trim() : (_walletAddress ?? '');

  bool get _destinationReady => _destination.length >= 26;

  void _onWifChanged(String value) {
    _debounce?.cancel();
    final wif = value.trim();

    if (wif.isEmpty) {
      setState(() {
        _stage = ClaimEcxStage.idle;
        _preview = null;
      });
      return;
    }

    _debounce = Timer(_checkDebounce, _check);
  }

  Future<void> _check() async {
    final wif = _wif;
    if (wif.isEmpty) {
      return;
    }

    if (!PaperWalletGenerator.isValidWIF(wif)) {
      setState(() {
        _stage = ClaimEcxStage.invalid;
        _preview = null;
      });
      return;
    }

    setState(() => _stage = ClaimEcxStage.checking);

    try {
      final preview = await _bitwindow.wallet.previewSweep(wif);
      if (!mounted || _wif != wif) {
        return;
      }

      if (preview.hasFunds) {
        await _loadWalletAddress();
        if (!mounted) {
          return;
        }
      }

      setState(() {
        _preview = preview;
        _stage = preview.hasFunds ? ClaimEcxStage.funds : ClaimEcxStage.empty;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _stage = ClaimEcxStage.failed;
        _failure = _reason(e);
      });
    }
  }

  Future<void> _loadWalletAddress() async {
    final walletId = _walletReader.activeWalletId;
    if (walletId == null) {
      return;
    }
    if (_walletAddress != null && _walletAddressFor == walletId) {
      return;
    }

    final address = await _orchestratorWallet.getNewAddress(walletId);
    if (!mounted) {
      return;
    }
    setState(() {
      _walletAddress = address.address;
      _walletAddressFor = walletId;
    });
  }

  Future<void> _claim() async {
    final walletId = _walletReader.activeWalletId;
    if (walletId == null) {
      setState(() {
        _stage = ClaimEcxStage.failed;
        _failure = 'No wallet is open.';
      });
      return;
    }

    if (!_editingDestination) {
      await _loadWalletAddress();
      if (!mounted) {
        return;
      }
    }

    setState(() => _stage = ClaimEcxStage.claiming);

    try {
      final result = await _bitwindow.wallet.sweepCheque(
        walletId,
        _wif,
        _destination,
        _preview?.feeSatPerVbyte ?? 0,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _txid = result.txid;
        _claimedSats = _preview?.receiveSats ?? result.amountSats;
        _stage = ClaimEcxStage.claimed;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      if (e.toString().toLowerCase().contains('wallet is locked')) {
        await _unlockThenClaim();
        return;
      }

      setState(() {
        _stage = ClaimEcxStage.failed;
        _failure = _reason(e);
      });
    }
  }

  Future<void> _unlockThenClaim() async {
    setState(() => _stage = ClaimEcxStage.funds);

    final unlocked = await _showUnlockDialog();
    if (!mounted || !unlocked) {
      return;
    }

    await _claim();
  }

  Future<bool> _showUnlockDialog() async {
    final passwordController = TextEditingController();
    var unlocked = false;
    var unlocking = false;

    await showThemedDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => SailDialog(
          title: 'Unlock your wallet',
          actions: [
            SailButton(
              label: 'Cancel',
              variant: ButtonVariant.ghost,
              onPressed: () async => Navigator.of(context).pop(),
            ),
            SailButton(
              label: 'Unlock',
              loading: unlocking,
              onPressed: () async {
                setDialogState(() => unlocking = true);
                unlocked = await _walletReader.unlockWallet(passwordController.text);
                if (!context.mounted) {
                  return;
                }
                if (unlocked) {
                  Navigator.of(context).pop();
                  return;
                }
                setDialogState(() => unlocking = false);
                showSailToast(context, 'That password is wrong');
              },
            ),
          ],
          child: SizedBox(
            width: 400,
            child: SailColumn(
              spacing: SailStyleValues.padding12,
              mainAxisSize: MainAxisSize.min,
              children: [
                SailText.secondary13('Your wallet must be open to receive the claim.'),
                SailTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    passwordController.dispose();
    return unlocked;
  }

  void _reset() {
    _debounce?.cancel();
    _wifController.clear();
    _destController.clear();
    setState(() {
      _stage = ClaimEcxStage.idle;
      _preview = null;
      _editingDestination = false;
      _walletAddress = null;
      _walletAddressFor = null;
      _txid = null;
      _claimedSats = 0;
      _failure = '';
    });
  }

  String _reason(Object e) {
    final text = e is WalletException ? e.message : e.toString();
    return text.replaceFirst(RegExp(r'^\w+_error: ', caseSensitive: false), '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return switch (_stage) {
      ClaimEcxStage.claimed => _ClaimedCard(
        amountSats: _claimedSats,
        txid: _txid ?? '',
        destination: _destination,
        onAnother: _reset,
      ),
      ClaimEcxStage.failed => _FailedCard(
        reason: _failure,
        onRetry: _preview?.hasFunds == true ? _claim : _check,
        onDifferentKey: _reset,
      ),
      _ => _formCard(theme),
    };
  }

  Widget _formCard(SailThemeData theme) {
    final preview = _preview;
    final showFunds =
        preview != null && preview.hasFunds && (_stage == ClaimEcxStage.funds || _stage == ClaimEcxStage.claiming);

    return SailCard(
      child: SailColumn(
        spacing: 0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Head(icon: SailSVGAsset.key, color: theme.colors.primary, title: 'Claim your $_ticker'),
          const SailSpacing(SailStyleValues.padding04),
          SailText.secondary13(
            'Paste the private key from your investor letter. Nothing moves until you see the amount.',
          ),
          const SailSpacing(SailStyleValues.padding16),
          SailText.secondary12('PRIVATE KEY'),
          const SailSpacing(SailStyleValues.padding08),
          SailTextField(
            controller: _wifController,
            hintText: 'L1aW… or 5K…',
            monospace: true,
            maxLines: 1,
            enabled: _stage != ClaimEcxStage.claiming,
            onChanged: _onWifChanged,
            suffixWidget: PasteButton(
              onPaste: (text) {
                _wifController.text = text.trim();
                _onWifChanged(text);
              },
            ),
          ),
          const SailSpacing(SailStyleValues.padding10),
          _hint(theme),
          if (showFunds) ...[
            const SailSpacing(SailStyleValues.padding16),
            Divider(height: 1, color: theme.colors.divider),
            const SailSpacing(SailStyleValues.padding16),
            SailText.primary24(formatEcx(preview.amountSats)),
            const SailSpacing(SailStyleValues.padding04),
            SailText.secondary12(
              '${preview.outputCount} ${preview.outputCount == 1 ? 'output' : 'outputs'} · ${shortenAddress(preview.address)}',
            ),
            const SailSpacing(SailStyleValues.padding16),
            SailText.secondary12('SEND TO'),
            const SailSpacing(SailStyleValues.padding08),
            _destinationField(theme),
            const SailSpacing(SailStyleValues.padding12),
            _totalRow('Network fee', formatEcx(preview.feeSats), theme.colors.textSecondary),
            const SailSpacing(SailStyleValues.padding04),
            _totalRow('You receive', formatEcx(preview.receiveSats), theme.colors.text, bold: true),
          ],
          const SailSpacing(SailStyleValues.padding16),
          _actionButton(),
        ],
      ),
    );
  }

  Widget _hint(SailThemeData theme) {
    return switch (_stage) {
      ClaimEcxStage.invalid => _HintRow(
        icon: SailSVGAsset.circleAlert,
        color: theme.colors.error,
        text: 'Not a private key — check for a missing character.',
      ),
      ClaimEcxStage.empty => _HintRow(
        icon: SailSVGAsset.circleAlert,
        color: theme.colors.textTertiary,
        text: 'This key is empty — nothing to claim.',
      ),
      ClaimEcxStage.funds || ClaimEcxStage.claiming => _HintRow(
        icon: SailSVGAsset.circleCheck,
        color: theme.colors.success,
        text: 'This key has funds to claim.',
      ),
      _ => SailText.secondary12('The key stays on this computer.'),
    };
  }

  Widget _destinationField(SailThemeData theme) {
    if (_editingDestination) {
      return SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailTextField(
            controller: _destController,
            hintText: 'Paste an address you control',
            monospace: true,
            maxLines: 1,
            enabled: _stage != ClaimEcxStage.claiming,
            onChanged: (_) => setState(() {}),
            suffixWidget: PasteButton(
              onPaste: (text) => setState(() => _destController.text = text.trim()),
            ),
          ),
          SailButton(
            label: 'Use my wallet address',
            variant: ButtonVariant.link,
            small: true,
            onPressed: () async => setState(() {
              _editingDestination = false;
              _destController.clear();
            }),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding12,
        vertical: SailStyleValues.padding10,
      ),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: theme.colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: SailColumn(
              spacing: SailStyleValues.padding04,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.primary13('Your wallet', bold: true),
                SailText.secondary12(_walletAddress ?? 'Loading an address…'),
              ],
            ),
          ),
          SailButton(
            label: 'Change',
            variant: ButtonVariant.link,
            small: true,
            onPressed: () async => setState(() => _editingDestination = true),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, Color color, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SailText.secondary12(label),
        SailText.primary13(value, bold: bold, color: color),
      ],
    );
  }

  Widget _actionButton() {
    final preview = _preview;

    return switch (_stage) {
      ClaimEcxStage.checking => const _WideButton(
        label: 'Checking if the key has funds…',
        loading: true,
      ),
      ClaimEcxStage.claiming => _WideButton(
        label: 'Claiming ${formatEcx(preview?.receiveSats ?? 0)}…',
        loading: true,
      ),
      ClaimEcxStage.empty => _WideButton(
        label: 'Check again',
        icon: SailSVGAsset.refreshCw,
        onPressed: _check,
      ),
      ClaimEcxStage.funds => _WideButton(
        label: 'Claim ${formatEcx(preview?.receiveSats ?? 0)}',
        icon: SailSVGAsset.coins,
        disabled: !_destinationReady,
        onPressed: _claim,
      ),
      _ => const _WideButton(label: 'Claim $_ticker', icon: SailSVGAsset.coins, disabled: true),
    };
  }
}

class _ClaimedCard extends StatelessWidget {
  final int amountSats;
  final String txid;
  final String destination;
  final VoidCallback onAnother;

  const _ClaimedCard({
    required this.amountSats,
    required this.txid,
    required this.destination,
    required this.onAnother,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final network = GetIt.I.get<BitcoinConfProvider>().network;
    final url = mempoolTxUrl(txid, network);

    return SailCard(
      color: theme.colors.success.withValues(alpha: 0.13),
      child: SailColumn(
        spacing: 0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Head(icon: SailSVGAsset.circleCheck, color: theme.colors.success, title: '$_ticker claimed'),
          const SailSpacing(SailStyleValues.padding04),
          SailText.secondary13('Your $_ticker is on the way to your wallet. It lands in the next block.'),
          const SailSpacing(SailStyleValues.padding16),
          SailText.primary24(formatEcx(amountSats)),
          const SailSpacing(SailStyleValues.padding04),
          SailText.secondary12('To ${shortenAddress(destination)}'),
          const SailSpacing(SailStyleValues.padding16),
          SailText.secondary12('TRANSACTION'),
          const SailSpacing(SailStyleValues.padding08),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: SailStyleValues.padding12,
              vertical: SailStyleValues.padding10,
            ),
            decoration: BoxDecoration(
              color: theme.colors.background,
              borderRadius: SailStyleValues.borderRadius,
              border: Border.all(color: theme.colors.border),
            ),
            child: Row(
              children: [
                Expanded(child: SailText.primary12(shortenAddress(txid))),
                CopyButton(text: txid),
              ],
            ),
          ),
          const SailSpacing(SailStyleValues.padding10),
          SailButton(
            label: 'View on the explorer',
            variant: ButtonVariant.link,
            icon: SailSVGAsset.externalLink,
            small: true,
            onPressed: () async => launchUrl(Uri.parse(url)),
          ),
          const SailSpacing(SailStyleValues.padding16),
          _WideButton(
            label: 'Claim another key',
            icon: SailSVGAsset.rotateCcw,
            variant: ButtonVariant.outline,
            onPressed: () async => onAnother(),
          ),
        ],
      ),
    );
  }
}

class _FailedCard extends StatelessWidget {
  final String reason;
  final Future<void> Function() onRetry;
  final VoidCallback onDifferentKey;

  const _FailedCard({required this.reason, required this.onRetry, required this.onDifferentKey});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailCard(
      color: theme.colors.error.withValues(alpha: 0.10),
      child: SailColumn(
        spacing: 0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Head(icon: SailSVGAsset.circleAlert, color: theme.colors.error, title: 'Claim failed'),
          const SailSpacing(SailStyleValues.padding04),
          SailText.secondary13('The network refused the transaction. Your key is untouched and nothing moved.'),
          const SailSpacing(SailStyleValues.padding12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: SailStyleValues.padding12,
              vertical: SailStyleValues.padding10,
            ),
            decoration: BoxDecoration(
              color: theme.colors.background,
              borderRadius: SailStyleValues.borderRadius,
              border: Border.all(color: theme.colors.border),
            ),
            child: SailText.secondary12(reason),
          ),
          const SailSpacing(SailStyleValues.padding16),
          _WideButton(label: 'Try again', icon: SailSVGAsset.refreshCw, onPressed: onRetry),
          const SailSpacing(SailStyleValues.padding10),
          _WideButton(
            label: 'Use a different key',
            variant: ButtonVariant.outline,
            onPressed: () async => onDifferentKey(),
          ),
        ],
      ),
    );
  }
}

class _Head extends StatelessWidget {
  final SailSVGAsset icon;
  final Color color;
  final String title;

  const _Head({required this.icon, required this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SailSVG.icon(icon, width: 18, height: 18, color: color),
        const SizedBox(width: SailStyleValues.padding08),
        SailText.primary15(title, bold: true),
      ],
    );
  }
}

class _HintRow extends StatelessWidget {
  final SailSVGAsset icon;
  final Color color;
  final String text;

  const _HintRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SailSVG.icon(icon, width: 14, height: 14, color: color),
        const SizedBox(width: SailStyleValues.padding08),
        Flexible(child: SailText.primary12(text, color: color)),
      ],
    );
  }
}

class _WideButton extends StatelessWidget {
  final String label;
  final SailSVGAsset? icon;
  final bool loading;
  final bool disabled;
  final ButtonVariant variant;
  final Future<void> Function()? onPressed;

  const _WideButton({
    required this.label,
    this.icon,
    this.loading = false,
    this.disabled = false,
    this.variant = ButtonVariant.primary,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SailButton(
        label: label,
        icon: icon,
        loading: loading,
        disabled: disabled || onPressed == null,
        variant: variant,
        onPressed: onPressed ?? () async {},
      ),
    );
  }
}

/// Renders sats as a grouped 8-decimal ECX amount.
String formatEcx(int sats) {
  final whole = (sats ~/ 100000000).toString();
  final grouped = whole.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
  final fraction = (sats % 100000000).toString().padLeft(8, '0');
  return '$grouped.$fraction $_ticker';
}

/// Elides the middle of an address or txid.
String shortenAddress(String value) {
  if (value.length <= 24) {
    return value;
  }
  return '${value.substring(0, 12)}…${value.substring(value.length - 8)}';
}
