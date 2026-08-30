import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/fork_provider.dart';
import 'package:bitwindow/providers/psbt_draft_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/utils/explorer_url.dart';
import 'package:bitwindow/widgets/hardware_device_picker.dart';
import 'package:bitwindow/widgets/tx_flow_diagram.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as walletpb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/gen/walletpsbt/v1/walletpsbt.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// The saved-transaction view for one PSBT draft: the flow card, the keys
/// table, and the sign / import / broadcast actions. Drawn as frame 12 of
/// the Multisig signing design.
class MultisigSignPanel extends StatefulWidget {
  final String walletId;
  final String draftId;

  const MultisigSignPanel({
    super.key,
    required this.walletId,
    required this.draftId,
  });

  @override
  State<MultisigSignPanel> createState() => _MultisigSignPanelState();
}

class _MultisigSignPanelState extends State<MultisigSignPanel> {
  OrchestratorWalletRPC get _wallet => GetIt.I.get<OrchestratorRPC>().wallet;
  PsbtDraftProvider get _drafts => GetIt.I.get<PsbtDraftProvider>();
  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();
  AddressBookProvider get _addressBook => GetIt.I.get<AddressBookProvider>();
  TransactionProvider get _transactions => GetIt.I.get<TransactionProvider>();

  DecodedTransaction? _decoded;
  Set<String> _walletAddresses = {};
  String? _busyKey;
  String? _error;
  bool _showDiagram = false;
  String _decodedForPsbt = '';
  final Map<int, DateTime> _signedAt = {};

  bool _isBusy(String key) => _busyKey == key;
  bool _blocked(String key) => _busyKey != null && _busyKey != key;

  PsbtDraft? get _draft {
    for (final d in _drafts.drafts) {
      if (d.id == widget.draftId) {
        return d;
      }
    }
    return null;
  }

  DraftSigningStatus? get _status => _drafts.statusFor(widget.draftId);
  wmpb.MultisigInfo? get _multisig => _walletReader.activeWallet?.multisig;
  String get _walletName => _walletReader.activeWallet?.name ?? 'this wallet';

  @override
  void initState() {
    super.initState();
    _drafts.addListener(_onDraftsChanged);
    _addressBook.addListener(_onDraftsChanged);
    _loadWalletAddresses();
    _decode();
  }

  @override
  void dispose() {
    _drafts.removeListener(_onDraftsChanged);
    _addressBook.removeListener(_onDraftsChanged);
    super.dispose();
  }

  void _onDraftsChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
    _decode();
  }

  Future<void> _decode() async {
    final draft = _draft;
    if (draft == null || draft.psbtBase64 == _decodedForPsbt) {
      return;
    }
    final forPsbt = draft.psbtBase64;
    try {
      final decoded = await _wallet.decodeTransaction(input: forPsbt, walletId: widget.walletId);
      if (!mounted || _draft?.psbtBase64 != forPsbt) {
        return;
      }
      setState(() {
        _decoded = decoded;
        _decodedForPsbt = forPsbt;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to decode the transaction: $e');
      }
    }
  }

  Future<void> _loadWalletAddresses() async {
    try {
      final resp = await _wallet.listReceiveAddresses(widget.walletId);
      if (!mounted) {
        return;
      }
      setState(() {
        _walletAddresses = resp.addresses.map((a) => a.address).toSet();
      });
    } catch (e) {
      // The change badge degrades to "payment"; the amounts stay correct.
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
      if (mounted) {
        setState(() => _error = _plainError(e));
      }
    } finally {
      if (mounted) {
        setState(() => _busyKey = null);
      }
    }
  }

  /// A draft outlives its inputs: another spend can take the same coin.
  /// Name that cause plainly instead of surfacing a raw RPC error.
  String _plainError(Object e) {
    final msg = e.toString();
    final lower = msg.toLowerCase();
    if (lower.contains('missing inputs') || lower.contains('missingorspent') || lower.contains('bad-txns-inputs')) {
      return 'A coin this transaction spends is no longer available — '
          'another transaction spent it. Discard this transaction and create a new one.';
    }
    return msg;
  }

  Future<void> _signCosigner(int index) => _run('cosigner-$index', () async {
    final draft = _draft!;
    final signed = await _wallet.signPsbtWithCosigner(
      walletId: widget.walletId,
      psbtBase64: draft.psbtBase64,
      cosignerXpub: _multisig!.cosigners[index].xpub,
    );
    await _drafts.updatePsbt(draft.id, signed);
    _signedAt[index] = DateTime.now();
  });

  Future<void> _signWithDevice(int index) => _run('device-$index', () async {
    final draft = _draft!;
    final c = _multisig!.cosigners[index];
    final sel = wmpb.HardwareDeviceSelector(type: c.hardwareDeviceType, fingerprint: c.fingerprint);
    final signed = await _signOnDevice(sel, draft.psbtBase64);
    final combined = await _wallet.combinePsbt(psbtsBase64: [draft.psbtBase64, signed]);
    await _drafts.updatePsbt(draft.id, combined);
    _signedAt[index] = DateTime.now();
  });

  Future<String> _signOnDevice(wmpb.HardwareDeviceSelector sel, String psbt) async {
    try {
      return await _wallet.signPsbtWithDevice(device: sel, psbtBase64: psbt);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final needsDevice =
          msg.contains('locked') ||
          msg.contains('promptpin') ||
          msg.contains('-12') ||
          msg.contains('not found') ||
          msg.contains('no device') ||
          msg.contains('libusb');
      if (!needsDevice || !mounted) {
        rethrow;
      }
      final unlocked = await showHardwareDevicePicker(context);
      if (unlocked == null) {
        rethrow;
      }
      // Sign the just-unlocked device by path: a re-locked device has no
      // fingerprint, and path skips the re-enumeration that races auto-lock.
      final byPath = wmpb.HardwareDeviceSelector(
        type: unlocked.type,
        path: unlocked.path,
        passphrase: hardwareDevicePassphrase(unlocked.path),
      );
      return await _wallet.signPsbtWithDevice(device: byPath, psbtBase64: psbt);
    }
  }

  Future<void> _importSignedPsbt() async {
    final imported = await showThemedDialog<String>(
      context: context,
      builder: (context) => const _ImportPsbtDialog(),
    );
    if (imported == null || imported.isEmpty) {
      return;
    }
    await _run('import', () async {
      final draft = _draft!;
      final combined = await _wallet.combinePsbt(psbtsBase64: [draft.psbtBase64, imported]);
      await _drafts.updatePsbt(draft.id, combined);
    });
  }

  Future<void> _copyPsbt() async {
    final draft = _draft;
    if (draft == null) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: draft.psbtBase64));
    if (mounted) {
      showSailToast(context, 'PSBT copied', variant: SailToastVariant.success);
    }
  }

  Future<void> _broadcast() => _run('broadcast', () async {
    final draft = _draft!;
    _drafts.setBroadcastPending(draft.id, true);
    try {
      final hex = await _wallet.finalizePsbt(psbtBase64: draft.psbtBase64);
      final txid = await _wallet.broadcastTransaction(walletId: widget.walletId, txHex: hex);
      final fork = GetIt.I.get<ForkProvider>();
      final decoded = _decoded;
      // An undecoded transaction can hold a coin from both chains, so it counts
      // as one until the decode says otherwise.
      final spendsRisk =
          decoded == null || decoded.details.inputs.any((i) => fork.isReplayRisk('${i.prevTxid}:${i.prevVout}'));
      final protected = decoded != null && decoded.details.locktime == replayLockTime;
      if (spendsRisk && !protected) {
        fork.rememberUnprotectedSend(txid);
      }

      // The transaction is on the network from here on. A failure below is
      // bookkeeping only and must never read as a broadcast failure.
      final network = GetIt.I.get<BitcoinConfProvider>().network;
      GetIt.I.get<NotificationProvider>().add(
        title: 'Transaction broadcast',
        content: txid,
        dialogType: DialogType.success,
        links: [NotificationLink(text: 'View transaction', url: mempoolTxUrl(txid, network))],
      );
      try {
        await _drafts.setTxid(draft.id, txid);
        if (draft.label.isNotEmpty) {
          await _transactions.saveNote(txid, draft.label);
        }
        await _transactions.fetch();
      } catch (e) {
        if (mounted) {
          setState(() => _error = 'The broadcast succeeded ($txid), but the draft update failed: $e');
        }
      }
    } finally {
      _drafts.setBroadcastPending(draft.id, false);
    }
  });

  @override
  Widget build(BuildContext context) {
    final draft = _draft;
    if (draft == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        children: [
          _flowCard(context),
          _keysCard(context, draft),
          SailSpacing(SailStyleValues.padding64),
        ],
      ),
    );
  }

  // ─── Flow card ───────────────────────────────────────────────────

  Widget _flowCard(BuildContext context) {
    final decoded = _decoded;
    return SailCard(
      title: 'Flow',
      widgetHeaderEnd: SailButton(
        label: _showDiagram ? 'Hide diagram' : 'Show diagram',
        variant: ButtonVariant.ghost,
        small: true,
        onPressed: () async => setState(() => _showDiagram = !_showDiagram),
      ),
      child: decoded == null
          ? SailText.secondary13('Decoding the transaction…')
          : SailColumn(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_showDiagram)
                  TxFlowDiagram(
                    inputs: [
                      for (final input in decoded.details.inputs) FlowSlot(sats: input.valueSats.toInt()),
                    ],
                    outputs: [
                      for (final output in decoded.details.outputs) FlowSlot(sats: output.valueSats.toInt()),
                      if (decoded.hasFee) FlowSlot(sats: decoded.details.feeSats.toInt(), isFee: true),
                    ],
                  ),
                _flowLabels(context, decoded),
              ],
            ),
    );
  }

  Widget _flowLabels(BuildContext context, DecodedTransaction decoded) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spends = _spendsColumn(context, decoded);
        final creates = _createsColumn(context, decoded);
        if (constraints.maxWidth > 800) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: spends),
              const SizedBox(width: SailStyleValues.padding32),
              Expanded(child: creates),
            ],
          );
        }
        return SailColumn(
          spacing: SailStyleValues.padding16,
          children: [spends, creates],
        );
      },
    );
  }

  Widget _spendsColumn(BuildContext context, DecodedTransaction decoded) {
    final inputs = decoded.details.inputs;
    final total = decoded.details.totalInputSats.toInt();
    return SailColumn(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary12(
          'SPENDS · ${inputs.length} ${inputs.length == 1 ? 'coin' : 'coins'} · ${_fmt(total)}',
          bold: true,
        ),
        for (final input in inputs)
          SailRow(
            spacing: SailStyleValues.padding12,
            children: [
              SailText.primary13(_fmt(input.valueSats.toInt()), monospace: true),
              Flexible(
                child: SailText.secondary13(
                  _inputLabel(input),
                  monospace: true,
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _inputLabel(walletpb.TransactionInput input) {
    final address = _shortAddress(input.address);
    final received = _receivedDate('${input.prevTxid}:${input.prevVout}');
    if (received == null) {
      return address;
    }
    return '$address · received $received';
  }

  String? _receivedDate(String outpoint) {
    for (final utxo in _transactions.utxos) {
      if (utxo.output == outpoint && utxo.hasReceivedAt()) {
        return formatDate(utxo.receivedAt.toDateTime(), long: false);
      }
    }
    return null;
  }

  Widget _createsColumn(BuildContext context, DecodedTransaction decoded) {
    final theme = context.sailTheme;
    final outputs = decoded.details.outputs;
    return SailColumn(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary12(
          'CREATES · ${outputs.length} ${outputs.length == 1 ? 'output' : 'outputs'}${decoded.hasFee ? ' + fee' : ''}',
          bold: true,
        ),
        for (final output in outputs) _outputRow(context, output),
        if (decoded.hasFee)
          SailRow(
            spacing: SailStyleValues.padding12,
            children: [
              SailText.secondary13(_fmt(decoded.details.feeSats.toInt()), monospace: true),
              Flexible(
                child: SailText.secondary13('paid to the miner, not an output', color: theme.colors.textTertiary),
              ),
            ],
          ),
      ],
    );
  }

  Widget _outputRow(BuildContext context, walletpb.TransactionOutput output) {
    final theme = context.sailTheme;
    final address = output.address;
    // The PSBT derivation records mark the change output; a funded wallet
    // address is a fallback for PSBTs from other builders.
    final isChange =
        (_decoded?.changeOutputIndexes.contains(output.index) ?? false) ||
        (address.isNotEmpty && _walletAddresses.contains(address));
    final bookName = _addressBookName(address);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary13(_fmt(output.valueSats.toInt()), monospace: true),
        const SizedBox(width: SailStyleValues.padding12),
        Expanded(
          child: Wrap(
            spacing: SailStyleValues.padding08,
            runSpacing: SailStyleValues.padding04,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SailText.secondary13(
                bookName == null ? _shortAddress(address) : '$bookName · ${_shortAddress(address)}',
                monospace: true,
              ),
              if (isChange)
                _Chip(label: 'change · back to $_walletName', color: theme.colors.success)
              else
                _Chip(label: 'payment', color: theme.colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  String? _addressBookName(String address) {
    for (final entry in _addressBook.entries) {
      if (entry.address == address) {
        return entry.label;
      }
    }
    return null;
  }

  // ─── Keys card ───────────────────────────────────────────────────

  Widget _keysCard(BuildContext context, PsbtDraft draft) {
    final theme = context.sailTheme;
    final multisig = _multisig;
    final status = _status;
    final threshold = status?.threshold ?? multisig?.m ?? 0;
    final signatures = status?.signatures ?? 0;

    if (multisig == null) {
      return const SizedBox.shrink();
    }

    return SailCard(
      title: 'Keys',
      subtitle: '$_walletName needs ${multisig.m} of its ${multisig.n} keys.',
      error: _error ?? _drafts.modelError,
      widgetHeaderEnd: _Chip(
        label: '$signatures of $threshold collected',
        color: (status?.finalizable ?? false) ? theme.colors.success : theme.colors.orange,
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _keysHeader(context),
          for (var i = 0; i < multisig.cosigners.length; i++) _keyRow(context, i, multisig.cosigners[i]),
          _footer(context, draft),
        ],
      ),
    );
  }

  static const _colKey = 1;
  static const _colHeldBy = 2;
  static const _colType = 2;
  static const _colFingerprint = 2;
  static const _colStatus = 3;
  static const _colSigned = 2;
  static const _colAction = 2;

  Widget _keysHeader(BuildContext context) {
    final theme = context.sailTheme;
    Widget head(String label, int flex, {bool end = false}) => Expanded(
      flex: flex,
      child: SailText.secondary12(label, color: theme.colors.textTertiary, textAlign: end ? TextAlign.end : null),
    );
    return Row(
      children: [
        head('KEY', _colKey),
        head('HELD BY', _colHeldBy),
        head('TYPE', _colType),
        head('FINGERPRINT', _colFingerprint),
        head('STATUS', _colStatus),
        head('SIGNED', _colSigned),
        head('ACTION', _colAction, end: true),
      ],
    );
  }

  Widget _keyRow(BuildContext context, int i, wmpb.MultisigCosignerInfo c) {
    final theme = context.sailTheme;
    final status = _status;
    final signed = status != null && i < status.cosignerSigned.length && status.cosignerSigned[i];
    final canSign = !signed && (c.held || c.hardwareDeviceType.isNotEmpty) && _draft?.txid.isEmpty == true;
    final busyKey = c.held ? 'cosigner-$i' : 'device-$i';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding08),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colors.divider)),
      ),
      child: Row(
        children: [
          Expanded(flex: _colKey, child: SailText.primary13('Key ${i + 1}', bold: true)),
          Expanded(flex: _colHeldBy, child: SailText.primary13(_heldBy(c))),
          Expanded(flex: _colType, child: SailText.secondary13(_keyType(c))),
          Expanded(flex: _colFingerprint, child: SailText.secondary13(c.fingerprint, monospace: true)),
          Expanded(
            flex: _colStatus,
            child: Align(
              alignment: Alignment.centerLeft,
              child: signed
                  ? _Chip(label: 'Signed', color: theme.colors.success)
                  : _Chip(label: 'Awaiting signature', color: theme.colors.orange),
            ),
          ),
          Expanded(
            flex: _colSigned,
            child: SailText.secondary13(signed ? _signedLabel(i) : '-'),
          ),
          Expanded(
            flex: _colAction,
            child: Align(
              alignment: Alignment.centerRight,
              child: canSign
                  ? SailButton(
                      label: 'Sign',
                      small: true,
                      loading: _isBusy(busyKey),
                      disabled: _blocked(busyKey),
                      onPressed: () async => c.held ? _signCosigner(i) : _signWithDevice(i),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  String _heldBy(wmpb.MultisigCosignerInfo c) {
    if (c.held) {
      return 'This computer';
    }
    if (c.hardwareDeviceType.isNotEmpty) {
      return _capitalize(c.hardwareDeviceType);
    }
    return 'Somewhere else';
  }

  String _keyType(wmpb.MultisigCosignerInfo c) {
    if (c.held) {
      return 'Software';
    }
    if (c.hardwareDeviceType.isNotEmpty) {
      return 'Hardware';
    }
    return 'Watch-only';
  }

  String _signedLabel(int i) {
    final at = _signedAt[i];
    if (at == null) {
      return '—';
    }
    return _relativeTime(at);
  }

  Widget _footer(BuildContext context, PsbtDraft draft) {
    final theme = context.sailTheme;
    final broadcast = draft.txid.isNotEmpty;
    final finalizable = _status?.finalizable ?? false;

    if (broadcast) {
      final network = GetIt.I.get<BitcoinConfProvider>().network;
      return SailRow(
        spacing: SailStyleValues.padding08,
        children: [
          _Chip(label: 'Broadcast', color: theme.colors.success),
          Flexible(child: SailText.secondary13(draft.txid, monospace: true)),
          SailButton(
            label: 'View transaction',
            variant: ButtonVariant.ghost,
            small: true,
            onPressed: () async => launchUrl(Uri.parse(mempoolTxUrl(draft.txid, network))),
          ),
        ],
      );
    }

    // The provider-level lock survives a panel remount from a tab switch;
    // the local busy key alone does not.
    final pending = _drafts.isBroadcastPending(draft.id);

    return Wrap(
      spacing: SailStyleValues.padding08,
      runSpacing: SailStyleValues.padding08,
      alignment: WrapAlignment.end,
      children: [
        SailButton(
          label: 'Copy PSBT',
          variant: ButtonVariant.ghost,
          onPressed: () async => _copyPsbt(),
        ),
        SailButton(
          label: 'Import a signature',
          variant: ButtonVariant.secondary,
          loading: _isBusy('import'),
          disabled: _blocked('import') || pending,
          onPressed: () async => _importSignedPsbt(),
        ),
        SailButton(
          label: 'Broadcast',
          disabled: !finalizable || _blocked('broadcast') || pending,
          loading: _isBusy('broadcast') || pending,
          onPressed: () async => _broadcast(),
        ),
        SailButton(
          label: 'Discard',
          variant: ButtonVariant.outline,
          disabled: _busyKey != null || pending,
          onPressed: () async => confirmDeleteDraft(context, draft, _decoded),
        ),
      ],
    );
  }

  String _fmt(int sats) => formatBitcoin(satoshiToBTC(sats));

  static String _shortAddress(String address) {
    if (address.length <= 14) {
      return address;
    }
    return '${address.substring(0, 6)}…${address.substring(address.length - 4)}';
  }

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  static String _relativeTime(DateTime at) {
    final elapsed = DateTime.now().difference(at);
    if (elapsed.inMinutes < 1) {
      return 'a moment ago';
    }
    if (elapsed.inHours < 1) {
      return '${elapsed.inMinutes} min ago';
    }
    return formatDate(at, long: false);
  }
}

/// Frame 14: the confirm names the transaction and what dies with it.
/// Deletes the draft when confirmed and returns true.
Future<bool> confirmDeleteDraft(BuildContext context, PsbtDraft draft, DecodedTransaction? decoded) async {
  // A delete between the broadcast RPC and its bookkeeping loses the txid.
  if (GetIt.I.get<PsbtDraftProvider>().isBroadcastPending(draft.id)) {
    showSailToast(context, 'A broadcast is in flight for this transaction. Wait for it to finish.');
    return false;
  }

  final name = draft.label.isNotEmpty ? draft.label : 'Transaction ${draftReference(draft)}';
  var summary = name;
  final payment = decoded?.details.outputs.firstOrNull;
  if (payment != null) {
    summary = '$name · ${formatBitcoin(satoshiToBTC(payment.valueSats.toInt()))}';
  }
  final subtitle = draft.txid.isNotEmpty
      ? '$summary. The transaction is already broadcast — the delete only removes this tab. The coins moved.'
      : '$summary. The signatures collected are deleted with it. Nothing was broadcast, so no coins move.';

  final confirmed = await showThemedDialog<bool>(
    context: context,
    builder: (context) => SailModal(
      constraints: const BoxConstraints(maxWidth: 560),
      child: SailCard(
        title: 'Are you sure you want to delete this transaction?',
        subtitle: subtitle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SailButton(
              label: 'Cancel',
              variant: ButtonVariant.ghost,
              onPressed: () async => Navigator.of(context).pop(false),
            ),
            const SizedBox(width: SailStyleValues.padding08),
            SailButton(
              label: 'Delete transaction',
              onPressed: () async => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    ),
  );

  if (confirmed != true) {
    return false;
  }
  await GetIt.I.get<PsbtDraftProvider>().delete(draft.id);
  return true;
}

/// The short reference shown in the tab: the first four characters of the
/// server-generated draft id.
String draftReference(PsbtDraft draft) {
  return draft.id.length <= 4 ? draft.id : draft.id.substring(0, 4);
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SailText.secondary12(label, color: color),
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
        title: 'Import a signature',
        subtitle: 'Paste the base64 PSBT a cosigner signed elsewhere',
        child: SailColumn(
          mainAxisSize: MainAxisSize.min,
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
                  if (data?.text != null) {
                    _controller.text = data!.text!.trim();
                  }
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
