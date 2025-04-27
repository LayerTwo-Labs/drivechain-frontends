import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bs58/bs58.dart';
import 'package:convert/convert.dart';
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:sail_ui/sail_ui.dart';

class HDWalletTab extends StatefulWidget {
  const HDWalletTab({super.key});

  @override
  State<HDWalletTab> createState() => _HDWalletTabState();
}

class _HDWalletTabState extends State<HDWalletTab> {
  final TextEditingController _mnemonicController = TextEditingController();
  final TextEditingController _derivationPathController = TextEditingController(text: "m/44'/0'/0'/0");
  final HDWalletProvider _hdWalletProvider = GetIt.I.get<HDWalletProvider>();

  List<HDWalletEntry> _derivedEntries = [];
  bool _isBusy = false;
  bool _hideMnemonic = false;
  bool _hidePrivateKeys = false;
  String? _validationError;
  int _currentPage = 0;
  static const int _entriesPerPage = 10;

  String _masterSeed = '';
  String _xpriv = '';
  String _xpub = '';

  @override
  void initState() {
    super.initState();
    _mnemonicController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _mnemonicController.dispose();
    _derivationPathController.dispose();
    super.dispose();
  }

  bool get _hasMnemonic => _mnemonicController.text.trim().isNotEmpty;

  Future<void> _validateAndDeriveEntries() async {
    final mnemonic = _mnemonicController.text.trim();
    if (mnemonic.isEmpty) {
      setState(() => _validationError = 'Please enter a mnemonic seed phrase');
      return;
    }

    setState(() {
      _isBusy = true;
      _validationError = null;
    });

    await Future.microtask(() async {
      try {
        if (!await _hdWalletProvider.validateMnemonic(mnemonic)) {
          setState(() {
            _validationError = 'Invalid mnemonic seed phrase';
            _isBusy = false;
          });
          return;
        }

        try {
          final mnemonicObj = Mnemonic.fromSentence(mnemonic, Language.english);
          final seedHex = hex.encode(mnemonicObj.seed);
          final chain = Chain.seed(seedHex);
          final masterKey = chain.forPath('m');
          final extendedPublicKey = (masterKey as ExtendedPrivateKey).publicKey();

          setState(() {
            _masterSeed = seedHex;
            _xpriv = masterKey.toString();
            _xpub = extendedPublicKey.toString();
          });
        } catch (e) {
          setState(() {
            _validationError = 'Error deriving master keys';
            _isBusy = false;
          });
          return;
        }

        await _deriveEntries(mnemonic);
      } catch (e) {
        if (mounted) {
          setState(() {
            _validationError = 'Error: $e';
            _isBusy = false;
          });
        }
      }
    });
  }

  Future<void> _deriveEntries(String mnemonic) async {
    try {
      final basePath = _derivationPathController.text.trim();
      await Future.microtask(() {});

      final entries = await compute(_deriveEntriesInBackground, [mnemonic, basePath, _currentPage, _entriesPerPage]);

      if (mounted) {
        setState(() {
          _derivedEntries = entries;
          _isBusy = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _validationError = 'Error deriving addresses: $e';
          _isBusy = false;
        });
      }
    }
  }

  static List<HDWalletEntry> _deriveEntriesInBackground(List<dynamic> params) {
    final mnemonic = params[0] as String;
    final basePath = params[1] as String;
    final currentPage = params[2] as int;
    final entriesPerPage = params[3] as int;

    final entries = <HDWalletEntry>[];

    try {
      final mnemonicObj = Mnemonic.fromSentence(mnemonic, Language.english);
      final seedHex = hex.encode(mnemonicObj.seed);
      final chain = Chain.seed(seedHex);

      final sha256Digest = SHA256Digest();
      final ripemd160Digest = RIPEMD160Digest();
      final pubKeyHash = Uint8List(20);
      final versionedHash = Uint8List(21);
      versionedHash[0] = 0x00; // Version byte for mainnet address
      final shaOutput = Uint8List(32);
      final doubleSHAOutput = Uint8List(32);
      final addressBytes = Uint8List(25);
      final wifBytes = Uint8List(38);
      final wifBuffer = Uint8List(34);
      wifBuffer[0] = 0x80; // Version byte for mainnet private key
      wifBuffer[33] = 0x01; // Compression byte

      final startIndex = currentPage * entriesPerPage;

      for (var i = 0; i < entriesPerPage; i++) {
        try {
          final derivationIndex = startIndex + i;
          final path = '$basePath/$derivationIndex';
          final extendedPrivateKey = chain.forPath(path) as ExtendedPrivateKey;
          final privateKeyHex = extendedPrivateKey.privateKeyHex();
          final publicKey = extendedPrivateKey.publicKey();

          final q = publicKey.q;
          if (q == null) continue;

          final pubKeyBytes = q.getEncoded(true);
          final pubKeyHex = hex.encode(pubKeyBytes);

          // Derive Bitcoin address
          sha256Digest.reset();
          ripemd160Digest.reset();
          final sha256Result = sha256Digest.process(Uint8List.fromList(pubKeyBytes));
          final ripemdResult = ripemd160Digest.process(sha256Result);
          pubKeyHash.setRange(0, 20, ripemdResult);
          versionedHash.setRange(1, 21, pubKeyHash);

          sha256Digest.reset();
          sha256Digest.update(versionedHash, 0, versionedHash.length);
          sha256Digest.doFinal(shaOutput, 0);

          sha256Digest.reset();
          sha256Digest.update(shaOutput, 0, shaOutput.length);
          sha256Digest.doFinal(doubleSHAOutput, 0);

          addressBytes.setRange(0, 21, versionedHash);
          addressBytes.setRange(21, 25, doubleSHAOutput.sublist(0, 4));
          final address = base58.encode(addressBytes);

          // Derive WIF format private key
          final cleanHex = privateKeyHex.startsWith('00') ? privateKeyHex.substring(2) : privateKeyHex;
          final privateKeyBytes = hex.decode(cleanHex);
          wifBuffer.setRange(1, 33, privateKeyBytes);

          sha256Digest.reset();
          sha256Digest.update(wifBuffer, 0, wifBuffer.length);
          sha256Digest.doFinal(shaOutput, 0);

          sha256Digest.reset();
          sha256Digest.update(shaOutput, 0, shaOutput.length);
          sha256Digest.doFinal(doubleSHAOutput, 0);

          wifBytes.setRange(0, 34, wifBuffer);
          wifBytes.setRange(34, 38, doubleSHAOutput.sublist(0, 4));
          final wif = base58.encode(wifBytes);

          entries.add(
            HDWalletEntry(
              path: path,
              address: address,
              publicKey: pubKeyHex,
              privateKey: wif,
            ),
          );
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      // Return any entries we've generated so far
    }

    return entries;
  }

  Future<void> _handlePageChange(bool next) async {
    if (_isBusy || (next && _derivedEntries.isEmpty) || (!next && _currentPage <= 0)) return;

    setState(() {
      if (next) {
        _currentPage++;
      } else {
        _currentPage = _currentPage > 0 ? _currentPage - 1 : 0;
      }
      _isBusy = true;
    });

    await _deriveEntries(_mnemonicController.text.trim());
  }

  Future<void> _handleUseWalletMnemonic() async {
    setState(() => _isBusy = true);

    try {
      await _hdWalletProvider.loadMnemonic();
      final mnemonic = _hdWalletProvider.mnemonic;

      if (mnemonic != null && mnemonic.isNotEmpty) {
        setState(() {
          _mnemonicController.text = mnemonic;
          _hideMnemonic = false;
          _validationError = null;
        });
      } else {
        setState(() => _validationError = "Couldn't load wallet mnemonic");
      }
    } catch (e) {
      setState(() => _validationError = 'Error loading wallet mnemonic');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _handleGenerateRandomMnemonic() async {
    setState(() => _isBusy = true);

    try {
      final mnemonic = await _hdWalletProvider.generateRandomMnemonic();
      setState(() {
        _mnemonicController.text = mnemonic;
        _hideMnemonic = false;
        _validationError = null;
      });
    } catch (e) {
      setState(() => _validationError = 'Error generating random mnemonic');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Widget _buildButton({
    required String label,
    required Future<void> Function()? onPressed,
    required ButtonVariant variant,
  }) {
    return SailButton(
      label: label,
      onPressed: onPressed,
      variant: variant,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'HD Wallet Explorer',
      subtitle: 'Explore BIP32/39/44 wallet derivation paths',
      error: _validationError ?? _hdWalletProvider.error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailSpacing(SailStyleValues.padding16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding16),
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.primary13('Mnemonic Seed'),
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    _buildButton(
                      label: 'Use Wallet',
                      onPressed: _isBusy ? null : _handleUseWalletMnemonic,
                      variant: _hasMnemonic ? ButtonVariant.secondary : ButtonVariant.primary,
                    ),
                    _buildButton(
                      label: 'Random',
                      onPressed: _isBusy ? null : _handleGenerateRandomMnemonic,
                      variant: _hasMnemonic ? ButtonVariant.secondary : ButtonVariant.primary,
                    ),
                    Expanded(
                      child: SailTextField(
                        controller: _hideMnemonic
                            ? TextEditingController(
                                text: _mnemonicController.text.isNotEmpty ? '••••••••••••••••••••••••••••••••' : '',
                              )
                            : _mnemonicController,
                        hintText: 'Enter mnemonic seed phrase',
                        enabled: !_isBusy,
                      ),
                    ),
                    _buildButton(
                      label: 'Copy',
                      onPressed: _mnemonicController.text.isEmpty || _isBusy
                          ? null
                          : () async {
                              await Clipboard.setData(ClipboardData(text: _mnemonicController.text));
                              if (context.mounted) {
                                showSnackBar(context, 'Mnemonic copied to clipboard');
                              }
                            },
                      variant: ButtonVariant.secondary,
                    ),
                    _buildButton(
                      label: 'Clear',
                      onPressed: _mnemonicController.text.isEmpty || _isBusy
                          ? null
                          : () async {
                              setState(() {
                                _mnemonicController.clear();
                                _masterSeed = '';
                                _xpriv = '';
                                _xpub = '';
                                _derivedEntries = [];
                                _currentPage = 0;
                                _validationError = null;
                              });
                            },
                      variant: ButtonVariant.secondary,
                    ),
                    _buildButton(
                      label: _hideMnemonic ? 'Show' : 'Hide',
                      onPressed: _isBusy ? null : () async => setState(() => _hideMnemonic = !_hideMnemonic),
                      variant: ButtonVariant.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: SailStyleValues.padding08),
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    _buildButton(
                      label: 'Derive Addresses',
                      onPressed: (_isBusy || !_hasMnemonic) ? null : _validateAndDeriveEntries,
                      variant: _hasMnemonic ? ButtonVariant.primary : ButtonVariant.secondary,
                    ),
                    Expanded(
                      child: SailTextField(
                        label: 'Derivation Path',
                        controller: _derivationPathController,
                        hintText: "m/44'/0'/0'/0",
                        enabled: !_isBusy,
                      ),
                    ),
                    _buildButton(
                      label: 'Prev',
                      onPressed: (_currentPage <= 0 || _isBusy || _derivedEntries.isEmpty)
                          ? null
                          : () async => _handlePageChange(false),
                      variant: ButtonVariant.secondary,
                    ),
                    SailText.primary13('Page ${_currentPage + 1}'),
                    _buildButton(
                      label: 'Next',
                      onPressed: (_isBusy || _derivedEntries.isEmpty) ? null : () async => _handlePageChange(true),
                      variant: ButtonVariant.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SailSpacing(SailStyleValues.padding16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding16),
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Master key fields
                for (final item in [
                  {'label': 'Master Seed:', 'value': _masterSeed, 'hint': 'Master Seed'},
                  {'label': 'XPRIV:', 'value': _xpriv, 'hint': 'Extended Private Key'},
                  {'label': 'XPUB:', 'value': _xpub, 'hint': 'Extended Public Key'},
                ])
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    children: [
                      SizedBox(width: 120, child: SailText.primary13(item['label']!)),
                      Expanded(
                        child: SailTextField(
                          controller: TextEditingController(text: item['value']!),
                          enabled: false,
                          hintText: item['hint']!,
                        ),
                      ),
                      if (item['value']!.isNotEmpty)
                        _buildButton(
                          label: 'Copy',
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: item['value']!));
                            if (context.mounted) {
                              showSnackBar(context, '${item['label']!.replaceAll(':', '')} copied to clipboard');
                            }
                          },
                          variant: ButtonVariant.secondary,
                        ),
                    ],
                  ),
              ],
            ),
          ),
          SailSpacing(SailStyleValues.padding08),
          Expanded(
            child: SailTable(
              getRowId: (index) => _derivedEntries.isEmpty ? 'empty$index' : _derivedEntries[index].path,
              headerBuilder: (context) => [
                const SailTableHeaderCell(name: 'Path'),
                const SailTableHeaderCell(name: 'Address'),
                const SailTableHeaderCell(name: 'Public Key'),
                const SailTableHeaderCell(name: 'Private Key (WIF)'),
              ],
              rowBuilder: (context, row, selected) {
                if (_derivedEntries.isEmpty) {
                  return [
                    const SailTableCell(value: ''),
                    const SailTableCell(value: ''),
                    const SailTableCell(value: ''),
                    const SailTableCell(value: ''),
                  ];
                }

                final entry = _derivedEntries[row];
                return [
                  SailTableCell(value: entry.path, monospace: true),
                  SailTableCell(value: entry.address, monospace: true),
                  SailTableCell(value: entry.publicKey, monospace: true),
                  SailTableCell(
                    value: _hidePrivateKeys ? '••••••••••••••••••••••••••••••••' : entry.privateKey,
                    monospace: true,
                  ),
                ];
              },
              rowCount: _derivedEntries.isEmpty ? 10 : _derivedEntries.length,
              columnWidths: const [-1, -1, -1, -1],
              drawGrid: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(SailStyleValues.padding16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildButton(
                  variant: ButtonVariant.outline,
                  label: _hidePrivateKeys ? 'Show Private Keys' : 'Hide Private Keys',
                  onPressed: () async => setState(() => _hidePrivateKeys = !_hidePrivateKeys),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HDWalletEntry {
  final String path;
  final String address;
  final String publicKey;
  final String privateKey;

  HDWalletEntry({
    required this.path,
    required this.address,
    required this.publicKey,
    required this.privateKey,
  });
}
