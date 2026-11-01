import 'dart:async';
import 'dart:convert';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// A seed the user has seen and typed back, with an optional BIP39 passphrase.
class SeedBackup {
  final String mnemonic;
  final String passphrase;
  const SeedBackup(this.mnemonic, this.passphrase);
}

/// Whether a phrase is a seed of the Electrum app, whose words hash to a
/// version prefix. A BIP39 wallet cannot restore it.
bool _isElectrumSeed(String phrase) {
  final version = Hmac(sha512, utf8.encode('Seed version')).convert(utf8.encode(phrase)).toString();
  return const ['01', '100', '101', '102'].any(version.startsWith);
}

/// Where the seed comes from: minted here, or one the user already has.
enum SeedEntryMode { generate, importExisting }

enum _Stage { entropy, reenter, import }

/// Derives a seed from the entropy field, which starts with OS entropy and
/// grows with every key the mouse types, then asks the user to type the words
/// back. The words come only from the field text.
/// In [SeedEntryMode.importExisting] the same grid starts empty and the user
/// pastes their own words into it.
class WalletBackupPage extends StatefulWidget {
  final SeedEntryMode mode;

  /// Creates the wallet from the confirmed seed before the page closes. Null
  /// hands the seed back to the caller.
  final Future<void> Function(SeedBackup seed)? onCreate;

  const WalletBackupPage({super.key, this.mode = SeedEntryMode.generate, this.onCreate});

  @override
  State<WalletBackupPage> createState() => _WalletBackupPageState();
}

class _WalletBackupPageState extends State<WalletBackupPage> {
  WalletWriterProvider get _writer => GetIt.I.get<WalletWriterProvider>();

  final _EntropyController _entropy = _EntropyController();
  final TextEditingController _passphrase = TextEditingController();
  List<TextEditingController> _reentered = [];
  List<TextEditingController> _imported = [];

  late _Stage _stage;
  List<String> _words = [];
  int _wordCount = 12;
  bool _wantPassphrase = false;
  bool _busy = false;
  int _deriveId = 0;

  /// The id of the last derive that answered. The words match the field only
  /// when it equals [_deriveId].
  int _landedId = 0;
  String? _error;

  /// The number of characters the keyboard typed into the field.
  int _samples = 0;
  static const int _sampleTarget = 256;

  @override
  void initState() {
    super.initState();
    if (widget.mode == SeedEntryMode.importExisting) {
      _stage = _Stage.import;
      _imported = List.generate(_wordCount, (_) => TextEditingController());
      return;
    }
    _stage = _Stage.entropy;
    unawaited(_randomEntropy());
  }

  @override
  void dispose() {
    _entropy.dispose();
    _passphrase.dispose();
    for (final c in [..._reentered, ..._imported]) {
      c.dispose();
    }
    super.dispose();
  }

  // Fills the field with OS entropy from the backend, so the field and the
  // words agree.
  Future<void> _randomEntropy() async {
    final id = ++_deriveId;
    try {
      final wallet = await _writer.generateWalletFromEntropy(
        const [],
        wordCount: _wordCount,
        doNotSave: true,
      );
      if (!mounted || id != _deriveId) {
        return;
      }
      final hex = (wallet['entropy_hex'] as String?) ?? '';
      _entropy.osEntropy = hex;
      _entropy.text = hex;
      _samples = 0;
      await _derive(hex);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Error generating entropy: $e');
      }
    }
  }

  // Any input is entropy: the backend hashes the whole text, so a sentence
  // works as well as hex. Only the newest derive may land.
  Future<void> _derive(String text) async {
    final id = ++_deriveId;
    if (text.isEmpty) {
      setState(() {
        _words = [];
        _error = null;
        _landedId = id;
      });
      return;
    }
    try {
      final wallet = await _writer.generateWalletFromEntropy(
        const [],
        sourceText: text,
        wordCount: _wordCount,
        doNotSave: true,
      );
      if (!mounted || id != _deriveId) {
        return;
      }
      final mnemonic = (wallet['mnemonic'] as String?) ?? '';
      setState(() {
        _words = mnemonic.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
        _error = mnemonic.isEmpty ? 'Failed to derive a seed from that entropy' : null;
        _landedId = id;
      });
    } catch (e) {
      if (!mounted || id != _deriveId) {
        return;
      }
      setState(() {
        _words = [];
        _error = 'Error deriving seed: $e';
        _landedId = id;
      });
    }
  }

  /// _type appends one character the keyboard produced and derives at once.
  void _type(String char) {
    _entropy.text += char;
    setState(() => _samples++);
    unawaited(_derive(_entropy.text));
  }

  Future<void> _setWordCount(int count) async {
    if (_stage == _Stage.import) {
      setState(() => _resizeImported(count));
      return;
    }
    setState(() => _wordCount = count);
    await _derive(_entropy.text);
  }

  /// Grows or shrinks the input grid, keeping whatever is already typed.
  /// Call inside setState.
  void _resizeImported(int count) {
    _wordCount = count;
    final kept = _imported.take(count).toList();
    final dropped = _imported.skip(count).toList();
    _imported = [
      ...kept,
      ...List.generate(count - kept.length, (_) => TextEditingController()),
    ];
    // The TextFields holding these are still mounted until the rebuild lands.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in dropped) {
        c.dispose();
      }
    });
  }

  List<String> get _importedWords =>
      _imported.map((c) => c.text.trim().toLowerCase()).where((w) => w.isNotEmpty).toList();

  int get _importedCount => _importedWords.length;

  /// Valid only when every box is filled and the words form a real BIP39
  /// sentence — a typo in one word changes the wallet silently, so the
  /// checksum is what the Create button waits for.
  bool get _importValid {
    if (_importedCount != _imported.length) {
      return false;
    }
    try {
      Mnemonic.fromSentence(_importedWords.join(' '), Language.english);
      return true;
    } catch (_) {
      return false;
    }
  }

  List<String> _split(String value) =>
      value.trim().toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  void _fill(
    List<TextEditingController> fields,
    int start,
    List<String> words,
  ) {
    for (var i = 0; i < words.length && start + i < fields.length; i++) {
      fields[start + i].text = words[i];
    }
  }

  /// Spreads a multi-word paste across the import boxes. A full 12 or 24 words
  /// is the whole phrase however it arrived, so it fills the grid from the
  /// start and resizes it to fit; anything shorter fills forward from [index].
  void _spread(int index, String value) {
    final words = _split(value);
    if (words.length < 2) {
      setState(() {});
      return;
    }
    final wholePhrase = words.length == 12 || words.length == 24;
    setState(() {
      if (wholePhrase && words.length != _imported.length) {
        _resizeImported(words.length);
      }
      _fill(_imported, wholePhrase ? 0 : index, words);
    });
  }

  /// Spreads a multi-word paste across the re-enter boxes. The box count is
  /// fixed here, so a paste of the whole phrase fills from the start.
  void _spreadReentered(int index, String value) {
    final words = _split(value);
    setState(() {
      if (words.length >= 2) {
        _fill(_reentered, words.length == _reentered.length ? 0 : index, words);
      }
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      setState(() => _error = 'Clipboard is empty');
      return;
    }
    setState(() => _error = null);
    _spread(0, text);
  }

  Future<void> _finishImport() => _complete(
    SeedBackup(
      _importedWords.join(' '),
      _wantPassphrase ? _passphrase.text : '',
    ),
  );

  Future<void> _complete(SeedBackup seed) async {
    final create = widget.onCreate;
    if (create != null) {
      setState(() {
        _busy = true;
        _error = null;
      });
      try {
        await create(seed);
      } catch (e) {
        if (mounted) {
          setState(() {
            _busy = false;
            _error = 'Failed to create wallet: $e';
          });
        }
        return;
      }
    }
    if (mounted) {
      Navigator.of(context).pop(seed);
    }
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
    if (ok) {
      setState(() => _wantPassphrase = true);
    }
  }

  void _startReenter() {
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

  Future<void> _finish() => _complete(SeedBackup(_words.join(' '), ''));

  void _back() {
    if (_stage == _Stage.reenter) {
      setState(() => _stage = _Stage.entropy);
      return;
    }
    Navigator.of(context).pop();
  }

  /// Asks before a wallet is made with no word typed back.
  Future<void> _skipBackup(BuildContext context) async {
    final create = await showThemedDialog<bool>(
      context: context,
      builder: (context) => SailModal(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SailCard(
          title: 'Create wallet without a backup?',
          subtitle: 'If you lose the ${_words.length} words, you lose the coins in this wallet.',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SailButton(
                label: 'Create without backup',
                variant: ButtonVariant.destructive,
                onPressed: () async => Navigator.of(context).pop(true),
              ),
              const SizedBox(width: 8),
              SailButton(
                label: 'Re-enter words',
                onPressed: () async => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
    if (create == true) {
      await _finish();
    }
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
  }) async {
    final answer = await showThemedDialog<bool>(
      context: context,
      builder: (context) {
        final theme = SailTheme.of(context);
        return SailModal(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SailCard(
            child: SailColumn(
              mainAxisSize: MainAxisSize.min,
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SailSVG.icon(
                      SailSVGAsset.iconWarning,
                      width: 20,
                      color: theme.colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: SailText.primary16(title, bold: true)),
                  ],
                ),
                SailText.secondary13(body),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SailButton(
                      label: 'No',
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
  Widget build(BuildContext context) => _scaffold(context);

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 40,
                ),
                child: Center(
                  child: SizedBox(
                    width: 900,
                    child: switch (_stage) {
                      _Stage.entropy => _entropyBody(context),
                      _Stage.reenter => _reenterBody(context),
                      _Stage.import => _importBody(context),
                    },
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

  Widget _progressBar(BuildContext context) {
    final theme = SailTheme.of(context);
    final fraction = (_samples / _sampleTarget).clamp(0.0, 1.0);
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: theme.colors.border,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fraction,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colors.text,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _entropyBody(BuildContext context) {
    final theme = SailTheme.of(context);
    final count = _entropy.text.characters.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading(
          'Add mouse entropy',
          'Move your mouse in a random pattern inside the box below. We mix your movements into the '
              'randomness your computer supplies. When you are ready, press Continue to get your words.',
        ),
        SailCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: SailText.primary16('Mnemonic Words (BIP39)', bold: true)),
                  SizedBox(width: 210, child: _wordCountDropdown()),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SailTextField(
                      controller: _entropy,
                      hintText: 'Type anything: a sentence, dice rolls, hex, whatever you like',
                      size: TextFieldSize.small,
                      monospace: true,
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
                    onPressed: _randomEntropy,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SailText.secondary12(count == 1 ? '1 character' : '$count characters'),
              const SizedBox(height: 6),
              Row(
                children: [
                  SailSVG.icon(SailSVGAsset.iconInfo, width: 12, color: theme.colors.text),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SailText.primary12(
                      "The text in white is os entropy added by default. Remove it if you don't want it mixed in.",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SailEntropyKeyboard(
                onType: _type,
                showKeys: true,
                caption: 'Move your mouse as randomly as you can across this grid. The more the better.',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _progressBar(context)),
                  const SizedBox(width: 12),
                  SailText.secondary12(_samples == 1 ? '1 sample' : '$_samples samples'),
                ],
              ),
              const SizedBox(height: 16),
              SailMnemonicGrid(words: _words),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_words.isNotEmpty) ...[
                    SailSVG.icon(
                      SailSVGAsset.iconSuccess,
                      width: 12,
                      color: theme.colors.success,
                    ),
                    const SizedBox(width: 6),
                    SailText.secondary13(
                      'Valid checksum',
                      color: theme.colors.success,
                    ),
                  ],
                  const Spacer(),
                  SailButton(
                    label: 'Copy Mnemonic for backup',
                    variant: ButtonVariant.secondary,
                    disabled: _words.isEmpty,
                    onPressed: () async => copySecretToClipboard(_words.join(' ')),
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

  Widget _wordCountDropdown() {
    return SailDropdownButton<int>(
      value: _wordCount,
      onChanged: (v) async {
        if (v != null) {
          await _setWordCount(v);
        }
      },
      items: const [
        SailDropdownItem<int>(value: 12, label: 'Use 12 Words'),
        SailDropdownItem<int>(value: 24, label: 'Use 24 Words'),
      ],
    );
  }

  Widget _passphraseLink(BuildContext context) {
    return Row(
      children: [
        SailButton(
          label: 'Add passphrase',
          variant: ButtonVariant.ghost,
          small: true,
          disabled: _wantPassphrase,
          onPressed: () async => _addPassphrase(context),
        ),
      ],
    );
  }

  Widget _importBody(BuildContext context) {
    final theme = SailTheme.of(context);
    final complete = _importedCount == _imported.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading(
          'Enter your seed phrase',
          'Paste the words from your backup, or type them into the numbered boxes. '
              'They rebuild the same keys, so any coins on them come back with the wallet.',
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
                        SailText.primary16(
                          'Mnemonic Words (BIP39)',
                          bold: true,
                        ),
                        SailText.secondary13(
                          'Paste the whole phrase into the first box, or fill them one by one.',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 210,
                    child: SailDropdownButton<int>(
                      value: _wordCount,
                      onChanged: (v) async {
                        if (v != null) {
                          await _setWordCount(v);
                        }
                      },
                      items: const [
                        SailDropdownItem<int>(value: 12, label: 'Use 12 Words'),
                        SailDropdownItem<int>(value: 24, label: 'Use 24 Words'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SailMnemonicGrid(controllers: _imported, onChanged: _spread),
              const SizedBox(height: 16),
              _passphraseLink(context),
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
                  Expanded(
                    child: _importValid
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SailSVG.icon(
                                SailSVGAsset.iconSuccess,
                                width: 12,
                                color: theme.colors.success,
                              ),
                              const SizedBox(width: 6),
                              SailText.secondary13(
                                'Valid checksum',
                                color: theme.colors.success,
                              ),
                            ],
                          )
                        : SailText.secondary13(
                            !complete
                                ? '$_importedCount of ${_imported.length} words entered'
                                : _isElectrumSeed(_importedWords.join(' '))
                                ? 'These words are an Electrum seed, not a BIP39 phrase — restore them in Electrum'
                                : 'These words are not a valid BIP39 phrase — check for a typo',
                            color: complete ? theme.colors.error : theme.colors.textSecondary,
                          ),
                  ),
                  const SizedBox(width: 12),
                  SailButton(
                    label: 'Paste from clipboard',
                    variant: ButtonVariant.secondary,
                    onPressed: _pasteFromClipboard,
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
              SailText.secondary13(
                'Paste the whole phrase into the first box, or type them one by one.',
              ),
              const SizedBox(height: 16),
              SailMnemonicGrid(
                controllers: _reentered,
                onChanged: _spreadReentered,
              ),
              const SizedBox(height: 12),
              SailText.secondary12(
                '$_enteredCount of ${_words.length} entered',
                color: _reenterMatches ? theme.colors.success : theme.colors.textSecondary,
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

  Widget _bottomBar(BuildContext context) {
    final theme = SailTheme.of(context);
    final ready = switch (_stage) {
      _Stage.entropy => _words.isNotEmpty && _landedId == _deriveId,
      _Stage.reenter => true,
      _Stage.import => _importValid,
    };
    final label = switch (_stage) {
      _Stage.entropy => 'Continue',
      _Stage.reenter when _enteredCount == 0 => 'Skip and create wallet',
      _ => 'Create Wallet',
    };
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
                label: label,
                loading: _busy,
                disabled: !ready,
                onPressed: () async {
                  switch (_stage) {
                    case _Stage.entropy:
                      _startReenter();
                    case _Stage.reenter when _enteredCount == 0:
                      await _skipBackup(context);
                    case _Stage.reenter:
                      if (_reenterMatches) {
                        await _finish();
                      }
                    case _Stage.import:
                      await _finishImport();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws the OS entropy at the start of the field in the text color, and every
/// character after it in the primary color.
class _EntropyController extends TextEditingController {
  String osEntropy = '';

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final colors = SailTheme.of(context).colors;
    final os = osEntropy.isNotEmpty && text.startsWith(osEntropy) ? osEntropy : '';
    return TextSpan(
      style: style,
      children: [
        TextSpan(
          text: os,
          style: TextStyle(color: colors.text),
        ),
        TextSpan(
          text: text.substring(os.length),
          style: TextStyle(color: colors.primary),
        ),
      ],
    );
  }
}
