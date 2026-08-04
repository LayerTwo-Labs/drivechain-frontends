import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// A seed the user has seen and typed back, with an optional BIP39 passphrase.
class SeedBackup {
  final String mnemonic;
  final String passphrase;
  const SeedBackup(this.mnemonic, this.passphrase);
}

enum _Stage { backup, reenter }

/// Shows a freshly generated seed, offers a passphrase or the user's own
/// entropy, then makes the user type the words back before accepting them.
class WalletBackupPage extends StatefulWidget {
  const WalletBackupPage({super.key});

  @override
  State<WalletBackupPage> createState() => _WalletBackupPageState();
}

class _WalletBackupPageState extends State<WalletBackupPage> {
  WalletWriterProvider get _writer => GetIt.I.get<WalletWriterProvider>();

  final TextEditingController _entropy = TextEditingController();
  final TextEditingController _passphrase = TextEditingController();
  List<TextEditingController> _reentered = [];

  _Stage _stage = _Stage.backup;
  List<String> _words = [];
  int _wordCount = 12;
  bool _paranoid = false;
  bool _wantPassphrase = false;
  bool _busy = false;
  int _deriveId = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_generate());
  }

  @override
  void dispose() {
    _entropy.dispose();
    _passphrase.dispose();
    for (final c in _reentered) {
      c.dispose();
    }
    super.dispose();
  }

  // Fills the entropy box from the backend, so the box and the words agree.
  Future<void> _randomEntropy() async {
    try {
      final wallet = await _writer.generateWalletFromEntropy(
        const [],
        wordCount: _wordCount,
        doNotSave: true,
      );
      if (!mounted) return;
      _entropy.text = (wallet['entropy_hex'] as String?) ?? '';
      await _derive(_entropy.text);
    } catch (e) {
      if (mounted) setState(() => _error = 'Error generating entropy: $e');
    }
  }

  // The backend mints the entropy with crypto/rand; nothing random happens here.
  Future<void> _generate() async {
    final id = ++_deriveId;
    setState(() {
      _words = [];
      _error = null;
      _busy = true;
    });
    try {
      final wallet = await _writer.generateWalletFromEntropy(
        const [],
        wordCount: _wordCount,
        doNotSave: true,
      );
      if (!mounted || id != _deriveId) return;
      final mnemonic = (wallet['mnemonic'] as String?) ?? '';
      setState(() {
        _words = mnemonic.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
        _error = mnemonic.isEmpty ? 'Failed to generate a seed' : null;
        _busy = false;
      });
    } catch (e) {
      if (!mounted || id != _deriveId) return;
      setState(() {
        _error = 'Error generating seed: $e';
        _busy = false;
      });
    }
  }

  // Any input is entropy: the backend hashes it, so a sentence works as well as
  // hex. Every keystroke starts a derive, so only the newest one may land.
  Future<void> _derive(String raw) async {
    final input = raw.trim();
    final id = ++_deriveId;
    if (input.isEmpty) {
      setState(() {
        _words = [];
        _error = null;
        _busy = false;
      });
      return;
    }
    setState(() {
      _words = [];
      _error = null;
      _busy = true;
    });
    try {
      final wallet = await _writer.generateWalletFromEntropy(
        const [],
        sourceText: input,
        wordCount: _wordCount,
        doNotSave: true,
      );
      if (!mounted || id != _deriveId) return;
      final mnemonic = (wallet['mnemonic'] as String?) ?? '';
      setState(() {
        _words = mnemonic.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
        _error = mnemonic.isEmpty ? 'Failed to derive a seed from that entropy' : null;
        _busy = false;
      });
    } catch (e) {
      if (!mounted || id != _deriveId) return;
      setState(() {
        _error = 'Error deriving seed: $e';
        _busy = false;
      });
    }
  }

  Future<void> _setWordCount(int count) async {
    setState(() => _wordCount = count);
    await (_paranoid ? _derive(_entropy.text) : _generate());
  }

  Future<void> _enableParanoid(BuildContext context) async {
    final ok = await _confirm(
      context,
      title: 'Enable paranoid mode?',
      body:
          "Paranoid mode lets you supply your own entropy. Useful if you don't trust us to generate a "
          'random one for you. Optional added security for advanced users. Enabling will wipe your '
          'currently generated seed. Are you sure?',
      confirmLabel: 'Yes, enable',
    );
    if (!ok) return;
    _deriveId++;
    setState(() {
      _paranoid = true;
      _words = [];
      _busy = false;
      _entropy.clear();
    });
  }

  Future<void> _addPassphrase(BuildContext context) async {
    final ok = await _confirm(
      context,
      title: 'Add a passphrase?',
      body:
          'A passphrase is not a password. Any variation you enter later still loads a valid wallet, '
          'just with different addresses — and there is no way to tell which one was yours. Optional '
          'added security for advanced users. Are you sure?',
      confirmLabel: 'Yes, add one',
    );
    if (ok) setState(() => _wantPassphrase = true);
  }

  Future<void> _startReenter(BuildContext context) async {
    final ok = await _confirm(
      context,
      title: 'Have these ${_words.length} words been written down?',
      body: 'In the next step you will re-enter them, so make sure your copy is complete and in order.',
      confirmLabel: 'Yes, continue',
      cancelLabel: 'Not yet',
      warn: false,
    );
    if (!ok) return;
    setState(() {
      for (final c in _reentered) {
        c.dispose();
      }
      _reentered = List.generate(_words.length, (_) => TextEditingController());
      _stage = _Stage.reenter;
    });
  }

  int get _enteredCount => _reentered.where((c) => c.text.trim().isNotEmpty).length;

  bool get _reenterMatches =>
      _reentered.length == _words.length &&
      Iterable<int>.generate(_words.length).every(
        (i) => _reentered[i].text.trim().toLowerCase() == _words[i].toLowerCase(),
      );

  void _finish() {
    Navigator.of(context).pop(
      SeedBackup(_words.join(' '), _wantPassphrase ? _passphrase.text : ''),
    );
  }

  void _back() {
    if (_stage == _Stage.reenter) {
      setState(() => _stage = _Stage.backup);
      return;
    }
    Navigator.of(context).pop();
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    String cancelLabel = 'No',
    bool warn = true,
  }) async {
    final answer = await showThemedDialog<bool>(
      context: context,
      builder: (context) {
        final theme = SailTheme.of(context);
        return SailModal(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SailCard(
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (warn) ...[
                      SailSVG.icon(SailSVGAsset.iconWarning, width: 20, color: theme.colors.orange),
                      const SizedBox(width: 8),
                    ],
                    Expanded(child: SailText.primary16(title, bold: true)),
                  ],
                ),
                SailText.secondary13(body),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SailButton(
                      label: cancelLabel,
                      variant: ButtonVariant.ghost,
                      onPressed: () async => Navigator.of(context).pop(false),
                    ),
                    const SizedBox(width: 8),
                    SailButton(
                      label: confirmLabel,
                      onPressed: () async => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return answer == true;
  }

  @override
  Widget build(BuildContext context) {
    final ambient = SailTheme.of(context);
    return SailTheme(
      data: _paranoid
          ? SailThemeData.darkTheme(ambient.colors.primary, ambient.dense, ambient.font, ambient.style)
          : ambient,
      child: Builder(builder: _scaffold),
    );
  }

  Widget _scaffold(BuildContext context) {
    final theme = SailTheme.of(context);
    return SailScaffold(
      backgroundColor: theme.colors.background,
      appBar: SailAppBar.build(
        context,
        leading: SailButton(
          variant: ButtonVariant.icon,
          icon: SailSVGAsset.chevronLeft,
          onPressed: () async => _back(),
          iconHeight: 14,
          iconWidth: 14,
          small: true,
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Center(
                  child: SizedBox(
                    width: 900,
                    child: _stage == _Stage.backup ? _backupBody(context) : _reenterBody(context),
                  ),
                ),
              ),
            ),
            _bottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _heading(String title, String subtitle) {
    return Column(
      children: [
        SailText.primary24(title, bold: true),
        const SizedBox(height: 8),
        SailText.secondary13(subtitle, textAlign: TextAlign.center),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _backupBody(BuildContext context) {
    final theme = SailTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading(
          'Backup your wallet',
          'Write down this wallet backup and stash it somewhere safe. Do not under any circumstances '
              'share it with other people. They are very very secret.',
        ),
        SailCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SailText.primary16('Mnemonic Words (BIP39)', bold: true),
                        SailText.secondary13('Write these down. You will re-enter them in the next step.'),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 210,
                    child: SailDropdownButton<int>(
                      value: _wordCount,
                      onChanged: (v) async {
                        if (v != null) await _setWordCount(v);
                      },
                      items: const [
                        SailDropdownItem<int>(value: 12, label: 'Use 12 Words'),
                        SailDropdownItem<int>(value: 24, label: 'Use 24 Words'),
                      ],
                    ),
                  ),
                ],
              ),
              if (_paranoid) ...[
                const SizedBox(height: 16),
                _entropyRow(context),
              ],
              const SizedBox(height: 16),
              SailMnemonicGrid(words: _words),
              const SizedBox(height: 16),
              _optionLinks(context),
              if (_wantPassphrase) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: 300,
                  child: SailTextField(
                    controller: _passphrase,
                    hintText: 'Passphrase',
                    size: TextFieldSize.small,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_words.isNotEmpty) ...[
                    SailSVG.icon(SailSVGAsset.iconSuccess, width: 12, color: theme.colors.success),
                    const SizedBox(width: 6),
                    SailText.secondary13('Valid checksum', color: theme.colors.success),
                  ],
                  const Spacer(),
                  SailButton(
                    label: 'Copy Mnemonic',
                    variant: ButtonVariant.secondary,
                    disabled: _words.isEmpty,
                    onPressed: () async => Clipboard.setData(ClipboardData(text: _words.join(' '))),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          SailText.secondary12(_error!, color: theme.colors.error),
        ],
      ],
    );
  }

  Widget _entropyRow(BuildContext context) {
    final count = _entropy.text.characters.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SailTextField(
                controller: _entropy,
                hintText: 'Type anything: a sentence, dice rolls, hex, whatever you like',
                size: TextFieldSize.small,
                onChanged: (v) {
                  setState(() {});
                  unawaited(_derive(v));
                },
              ),
            ),
            const SizedBox(width: 8),
            SailButton(
              label: 'Generate Random',
              variant: ButtonVariant.secondary,
              onPressed: () async {
                await _randomEntropy();
                if (mounted) setState(() {});
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        SailText.secondary12(count == 1 ? '1 character' : '$count characters'),
      ],
    );
  }

  Widget _optionLinks(BuildContext context) {
    return Row(
      children: [
        SailButton(
          label: 'Add passphrase',
          variant: ButtonVariant.ghost,
          small: true,
          disabled: _wantPassphrase,
          onPressed: () async => _addPassphrase(context),
        ),
        const SizedBox(width: 8),
        SailButton(
          label: 'Paranoid mode',
          variant: ButtonVariant.ghost,
          small: true,
          disabled: _paranoid,
          onPressed: () async => _enableParanoid(context),
        ),
      ],
    );
  }

  Widget _reenterBody(BuildContext context) {
    final theme = SailTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading(
          'Re-enter your words',
          'Type the ${_words.length} words back in, in the same order, to confirm your backup is correct.',
        ),
        SailCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary16('Re-enter Mnemonic Words', bold: true),
              SailText.secondary13('Enter each word in the numbered box it belongs in.'),
              const SizedBox(height: 16),
              SailMnemonicGrid(
                controllers: _reentered,
                onChanged: (_, _) => setState(() {}),
              ),
              const SizedBox(height: 12),
              SailText.secondary12(
                '$_enteredCount of ${_words.length} entered',
                color: _reenterMatches ? theme.colors.success : theme.colors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomBar(BuildContext context) {
    final theme = SailTheme.of(context);
    final ready = _stage == _Stage.backup ? _words.isNotEmpty && !_busy : _reenterMatches;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colors.border)),
      ),
      child: Center(
        child: SizedBox(
          width: 900,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SailButton(
                label: '← Back',
                variant: ButtonVariant.secondary,
                onPressed: () async => _back(),
              ),
              SailButton(
                label: 'Create Wallet',
                loading: _busy,
                disabled: !ready,
                onPressed: () async => _stage == _Stage.backup ? await _startReenter(context) : _finish(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
