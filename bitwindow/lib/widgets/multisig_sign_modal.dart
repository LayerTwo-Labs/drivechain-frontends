import 'package:bitwindow/utils/explorer_url.dart';
import 'package:bitwindow/widgets/hardware_device_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

class MultisigSignModal extends StatefulWidget {
  final String walletId;
  final String initialPsbt;
  final wmpb.MultisigInfo multisig;

  const MultisigSignModal({
    super.key,
    required this.walletId,
    required this.initialPsbt,
    required this.multisig,
  });

  @override
  State<MultisigSignModal> createState() => _MultisigSignModalState();
}

class _MultisigSignModalState extends State<MultisigSignModal> {
  OrchestratorWalletRPC get _wallet => GetIt.I.get<OrchestratorRPC>().wallet;

  late String _psbt = widget.initialPsbt;
  int _signatures = 0;
  bool _finalizable = false;
  List<bool> _signed = const [];
  String? _busyKey;
  String? _error;

  bool _isBusy(String key) => _busyKey == key;
  bool _blocked(String key) => _busyKey != null && _busyKey != key;

  int get _threshold => widget.multisig.m;
  List<wmpb.MultisigCosignerInfo> get _cosigners => widget.multisig.cosigners;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  bool _cosignerSigned(int i) => i < _signed.length && _signed[i];

  Future<void> _refreshStatus() async {
    final forPsbt = _psbt;
    try {
      final s = await _wallet.multisigPsbtStatus(walletId: widget.walletId, psbtBase64: forPsbt);
      if (!mounted || forPsbt != _psbt) return;
      setState(() {
        _signatures = s.signatures;
        _finalizable = s.finalizable;
        _signed = s.cosignerSigned;
      });
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to read signing status: $e');
    }
  }

  Future<void> _run(String key, Future<void> Function() action) async {
    setState(() {
      _busyKey = key;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  Future<void> _signCosigner(int index) => _run('cosigner-$index', () async {
    final signed = await _wallet.signPsbtWithCosigner(
      walletId: widget.walletId,
      psbtBase64: _psbt,
      cosignerXpub: _cosigners[index].xpub,
    );
    _psbt = signed;
    await _refreshStatus();
  });

  Future<void> _signWithDevice(int index) => _run('device-$index', () async {
    final c = _cosigners[index];
    final sel = wmpb.HardwareDeviceSelector(type: c.hardwareDeviceType, fingerprint: c.fingerprint);
    final signed = await _signOnDevice(sel);
    _psbt = await _wallet.combinePsbt(psbtsBase64: [_psbt, signed]);
    await _refreshStatus();
  });

  Future<String> _signOnDevice(wmpb.HardwareDeviceSelector sel) async {
    try {
      return await _wallet.signPsbtWithDevice(device: sel, psbtBase64: _psbt);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final needsDevice =
          msg.contains('locked') ||
          msg.contains('promptpin') ||
          msg.contains('-12') ||
          msg.contains('not found') ||
          msg.contains('no device') ||
          msg.contains('libusb');
      if (!needsDevice || !mounted) rethrow;
      final unlocked = await showHardwareDevicePicker(context);
      if (unlocked == null) rethrow;
      // Sign the just-unlocked device by path: a re-locked device has no
      // fingerprint, and path skips the re-enumeration that races auto-lock.
      final byPath = wmpb.HardwareDeviceSelector(type: unlocked.type, path: unlocked.path);
      return await _wallet.signPsbtWithDevice(device: byPath, psbtBase64: _psbt);
    }
  }

  Future<void> _importSignedPsbt() async {
    final imported = await showThemedDialog<String>(
      context: context,
      builder: (context) => const _ImportPsbtDialog(),
    );
    if (imported == null || imported.isEmpty) return;
    await _run('import', () async {
      final combined = await _wallet.combinePsbt(psbtsBase64: [_psbt, imported]);
      _psbt = combined;
      await _refreshStatus();
    });
  }

  Future<void> _copyPsbt() async {
    await Clipboard.setData(ClipboardData(text: _psbt));
    if (mounted) showSailToast(context, 'PSBT copied', variant: SailToastVariant.success);
  }

  Future<void> _broadcast() => _run('broadcast', () async {
    final hex = await _wallet.finalizePsbt(psbtBase64: _psbt);
    final txid = await _wallet.broadcastTransaction(walletId: widget.walletId, txHex: hex);
    final network = GetIt.I.get<BitcoinConfProvider>().network;
    GetIt.I.get<NotificationProvider>().add(
      title: 'Transaction broadcast',
      content: txid,
      dialogType: DialogType.success,
      links: [NotificationLink(text: 'View transaction', url: mempoolTxUrl(txid, network))],
    );
    if (mounted) Navigator.of(context).pop(txid);
  });

  @override
  Widget build(BuildContext context) {
    return SailModal(
      constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
      child: SailCard(
        title: 'Sign transaction',
        subtitle: '$_signatures of $_threshold signatures',
        error: _error,
        child: SingleChildScrollView(
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _progressBar(context),
              ..._cosigners.asMap().entries.map((e) => _cosignerRow(context, e.key, e.value)),
              const SizedBox(height: 4),
              _actions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBar(BuildContext context) {
    final theme = SailTheme.of(context);
    final fraction = _threshold == 0 ? 0.0 : (_signatures / _threshold).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: 6,
        backgroundColor: theme.colors.backgroundSecondary,
        valueColor: AlwaysStoppedAnimation(
          _finalizable ? theme.colors.success : theme.colors.primary,
        ),
      ),
    );
  }

  Widget _cosignerRow(BuildContext context, int i, wmpb.MultisigCosignerInfo c) {
    final theme = SailTheme.of(context);
    final signed = _cosignerSigned(i);
    return SailCard(
      shadowSize: ShadowSize.none,
      child: Row(
        children: [
          SailSVG.icon(
            signed ? SailSVGAsset.iconSuccess : SailSVGAsset.iconWallet,
            width: 18,
            color: signed ? theme.colors.success : theme.colors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SailText.primary13('Cosigner ${i + 1}', bold: true),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            (c.held
                                    ? theme.colors.primary
                                    : c.hardwareDeviceType.isNotEmpty
                                    ? theme.colors.success
                                    : theme.colors.orange)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SailText.secondary12(
                        c.held
                            ? 'On disk'
                            : c.hardwareDeviceType.isNotEmpty
                            ? 'Hardware'
                            : 'Watch-only',
                        color: c.held
                            ? theme.colors.primary
                            : c.hardwareDeviceType.isNotEmpty
                            ? theme.colors.success
                            : theme.colors.orange,
                      ),
                    ),
                  ],
                ),
                if (c.fingerprint.isNotEmpty) SailText.secondary12('Fingerprint: ${c.fingerprint}', monospace: true),
              ],
            ),
          ),
          if (signed)
            SailText.secondary12('Signed', color: theme.colors.success)
          else if (c.held)
            SailButton(
              label: 'Sign',
              small: true,
              loading: _isBusy('cosigner-$i'),
              disabled: _blocked('cosigner-$i'),
              onPressed: () async => _signCosigner(i),
            )
          else if (c.hardwareDeviceType.isNotEmpty)
            SailButton(
              label: 'Sign on device',
              small: true,
              loading: _isBusy('device-$i'),
              disabled: _blocked('device-$i'),
              onPressed: () async => _signWithDevice(i),
            )
          else
            SailText.secondary12('Signs elsewhere', color: theme.colors.textSecondary),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        SailButton(
          label: 'Copy PSBT',
          variant: ButtonVariant.ghost,
          onPressed: () async => _copyPsbt(),
        ),
        SailButton(
          label: 'Import signed PSBT',
          variant: ButtonVariant.secondary,
          loading: _isBusy('import'),
          disabled: _blocked('import'),
          onPressed: () async => _importSignedPsbt(),
        ),
        SailButton(
          label: 'Broadcast',
          disabled: !_finalizable || _blocked('broadcast'),
          loading: _isBusy('broadcast'),
          onPressed: () async => _broadcast(),
        ),
      ],
    );
  }
}

/// Small dialog to paste a base64 PSBT that another cosigner signed.
class _ImportPsbtDialog extends StatefulWidget {
  const _ImportPsbtDialog();

  @override
  State<_ImportPsbtDialog> createState() => _ImportPsbtDialogState();
}

class _ImportPsbtDialogState extends State<_ImportPsbtDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SailModal(
      constraints: const BoxConstraints(maxWidth: 560),
      child: SailCard(
        title: 'Import signed PSBT',
        subtitle: 'Paste the base64 PSBT a cosigner signed elsewhere',
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailTextField(
              controller: _controller,
              hintText: 'cHNidP8B...',
              size: TextFieldSize.small,
              minLines: 3,
              maxLines: 6,
              suffixWidget: SailButton(
                label: 'Paste',
                variant: ButtonVariant.ghost,
                small: true,
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null) _controller.text = data!.text!.trim();
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SailButton(
                  label: 'Cancel',
                  variant: ButtonVariant.ghost,
                  onPressed: () async => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                SailButton(
                  label: 'Import',
                  onPressed: () async => Navigator.of(context).pop(_controller.text.trim()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
