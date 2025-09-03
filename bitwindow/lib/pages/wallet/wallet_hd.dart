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
import 'package:stacked/stacked.dart';

class HDWalletTab extends StatelessWidget {
  const HDWalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HDWalletViewModel>.reactive(
      viewModelBuilder: () => HDWalletViewModel(),
      builder: (context, model, child) => SingleChildScrollView(
        child: SailColumn(
          spacing: 0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildControlsCard(context, model),
            _buildAddressesSection(context, model, BoxConstraints()),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsCard(BuildContext context, HDWalletViewModel model) {
    return SailCard(
      title: 'HD Wallet Explorer',
      error: model.errorMessage,
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mnemonic input
          SailColumn(
            spacing: SailStyleValues.padding08,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary13('Mnemonic Seed'),
              Row(
                children: [
                  SailButton(
                    label: 'Use Wallet',
                    onPressed: model.useWalletMnemonic,
                    variant: ButtonVariant.secondary,
                    small: true,
                  ),
                  const SizedBox(width: SailStyleValues.padding08),
                  SailButton(
                    label: 'Random',
                    onPressed: model.generateRandomMnemonic,
                    variant: ButtonVariant.secondary,
                    small: true,
                  ),
                  const SizedBox(width: SailStyleValues.padding16),
                  Expanded(
                    child: SailTextField(
                      controller: model.displayMnemonicController,
                      hintText: 'Enter mnemonic seed phrase',
                      enabled: !model.hideMnemonic,
                      size: TextFieldSize.small,
                    ),
                  ),
                  const SizedBox(width: SailStyleValues.padding08),
                  SailButton(
                    label: 'Copy',
                    onPressed: model.mnemonicController.text.isEmpty
                        ? null
                        : () async => await model.copyMnemonic(context),
                    variant: ButtonVariant.secondary,
                    small: true,
                  ),
                  const SizedBox(width: SailStyleValues.padding08),
                  SailButton(
                    label: 'Clear',
                    onPressed: model.mnemonicController.text.isEmpty ? null : () async => model.clearAll(),
                    variant: ButtonVariant.secondary,
                    small: true,
                  ),
                  const SizedBox(width: SailStyleValues.padding08),
                  SailButton(
                    label: model.hideMnemonic ? 'Show' : 'Hide',
                    onPressed: () async => model.toggleMnemonicVisibility(),
                    variant: ButtonVariant.secondary,
                    small: true,
                  ),
                ],
              ),
            ],
          ),
          // Derivation
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: SailTextField(
                  label: 'Derivation Path',
                  controller: model.derivationPathController,
                  hintText: "m/84'/1'/0'/0/0",
                  size: TextFieldSize.small,
                ),
              ),
              const SizedBox(width: SailStyleValues.padding16),
              SailButton(
                label: 'Derive Addresses',
                onPressed: !model.canDeriveAddresses ? null : model.deriveAddresses,
                variant: model.canDeriveAddresses ? ButtonVariant.primary : ButtonVariant.secondary,
              ),
            ],
          ),
          // Master keys
          const Divider(),
          SailColumn(
            spacing: SailStyleValues.padding08,
            children: [
              for (final item in [
                {'label': 'Master Seed:', 'value': model.masterSeed},
                {'label': 'XPRIV:', 'value': model.xpriv},
                {'label': 'XPUB:', 'value': model.xpub},
              ])
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      child: SailText.primary13(item['label']!, bold: true),
                    ),
                    Expanded(
                      child: SailText.primary13(
                        item['value']!.isEmpty ? '' : item['value']!,
                        monospace: true,
                      ),
                    ),
                    const SizedBox(width: SailStyleValues.padding08),
                    SailButton(
                      label: 'Copy',
                      onPressed: item['value']!.isEmpty
                          ? null
                          : () async => await model.copyToClipboard(context, item['value']!, item['label']!),
                      variant: ButtonVariant.secondary,
                      small: true,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesSection(
    BuildContext context,
    HDWalletViewModel model,
    BoxConstraints constraints,
  ) {
    return SailCard(
      title: 'Derived Addresses',
      subtitle: '${model.derivedEntries.length} address(es)',
      bottomPadding: false,
      child: SailColumn(
        spacing: 0,
        children: [
          // Table
          AddressTable(
            entries: model.derivedEntries,
            hidePrivateKeys: model.hidePrivateKeys,
          ),
          // Bottom Controls
          Container(
            padding: const EdgeInsets.all(SailStyleValues.padding16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: context.sailTheme.colors.divider,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SailButton(
                      label: model.hidePrivateKeys ? 'Show Private Keys' : 'Hide Private Keys',
                      onPressed: () async => model.togglePrivateKeyVisibility(),
                      variant: ButtonVariant.outline,
                      small: true,
                    ),
                  ],
                ),
                const SizedBox(height: SailStyleValues.padding16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SailButton(
                      label: 'Prev',
                      onPressed: model.canGoPrevious ? () async => await model.changePage(false) : null,
                      variant: ButtonVariant.secondary,
                      small: true,
                    ),
                    const SizedBox(width: SailStyleValues.padding16),
                    SailText.primary13('Page ${model.currentPage + 1}'),
                    const SizedBox(width: SailStyleValues.padding16),
                    SailButton(
                      label: 'Next',
                      onPressed: model.canGoNext ? () async => await model.changePage(true) : null,
                      variant: ButtonVariant.secondary,
                      small: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HDWalletViewModel extends BaseViewModel {
  final HDWalletProvider _hdWalletProvider = GetIt.I.get<HDWalletProvider>();
  final TextEditingController mnemonicController = TextEditingController();
  final TextEditingController derivationPathController = TextEditingController(text: "m/84'/1'/0'/0/0");

  List<HDWalletEntry> _derivedEntries = [];
  String? _errorMessage;
  int _currentPage = 0;
  static const int _entriesPerPage = 10;

  String _masterSeed = '';
  String _xpriv = '';
  String _xpub = '';

  bool _hideMnemonic = true;
  bool _hidePrivateKeys = true;

  // Getters
  List<HDWalletEntry> get derivedEntries => _derivedEntries;
  String? get errorMessage => _errorMessage ?? _hdWalletProvider.error;
  int get currentPage => _currentPage;
  String get masterSeed => _masterSeed;
  String get xpriv => _xpriv;
  String get xpub => _xpub;
  bool get hideMnemonic => _hideMnemonic;
  bool get hidePrivateKeys => _hidePrivateKeys;
  bool get hasMnemonic => mnemonicController.text.trim().isNotEmpty;
  bool get canGoPrevious => _currentPage > 0 && _derivedEntries.isNotEmpty;
  bool get canGoNext => _derivedEntries.isNotEmpty;
  bool get canDeriveAddresses => hasMnemonic && _isValidDerivationPath();

  bool _isValidDerivationPath() {
    final path = derivationPathController.text.trim();
    // Basic validation for BIP44/84 path format
    final pathRegex = RegExp(r"^m(/\d+'?){3,5}(/\d+)?$");
    return pathRegex.hasMatch(path);
  }

  TextEditingController get displayMnemonicController {
    if (_hideMnemonic && mnemonicController.text.isNotEmpty) {
      return TextEditingController(text: '••••••••••••••••••••••••••••••••');
    }
    return mnemonicController;
  }

  HDWalletViewModel() {
    mnemonicController.addListener(notifyListeners);
  }

  Future<void> useWalletMnemonic() async {
    _errorMessage = null;

    try {
      await _hdWalletProvider.loadMnemonic();
      final mnemonic = _hdWalletProvider.mnemonic;

      if (mnemonic != null && mnemonic.isNotEmpty) {
        mnemonicController.text = mnemonic;
        _hideMnemonic = true;
        _errorMessage = null;
      } else {
        _errorMessage = "Couldn't load wallet mnemonic";
      }
    } catch (e) {
      _errorMessage = 'Error loading wallet mnemonic: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> generateRandomMnemonic() async {
    _errorMessage = null;

    try {
      final mnemonic = await _hdWalletProvider.generateRandomMnemonic();
      mnemonicController.text = mnemonic;
      _hideMnemonic = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error generating random mnemonic: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> deriveAddresses() async {
    final mnemonic = mnemonicController.text.trim();
    if (mnemonic.isEmpty) {
      _errorMessage = 'Please enter a mnemonic seed phrase';
      notifyListeners();
      return;
    }

    _errorMessage = null;

    try {
      if (!await _hdWalletProvider.validateMnemonic(mnemonic)) {
        _errorMessage = 'Invalid mnemonic seed phrase';
        notifyListeners();
        return;
      }

      // Derive master keys
      try {
        final mnemonicObj = Mnemonic.fromSentence(mnemonic, Language.english);
        final seedHex = hex.encode(mnemonicObj.seed);
        final chain = Chain.seed(seedHex);
        final masterKey = chain.forPath('m');
        final extendedPublicKey = (masterKey as ExtendedPrivateKey).publicKey();

        _masterSeed = seedHex;
        _xpriv = masterKey.toString();
        _xpub = extendedPublicKey.toString();
      } catch (e) {
        _errorMessage = 'Error deriving master keys: $e';
        notifyListeners();
        return;
      }

      // Derive addresses
      await _deriveEntries(mnemonic);
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> _deriveEntries(String mnemonic) async {
    try {
      final basePath = derivationPathController.text.trim();
      final entries = await compute(_deriveEntriesInBackground, [mnemonic, basePath, _currentPage, _entriesPerPage]);

      _derivedEntries = entries;
    } catch (e) {
      _errorMessage = 'Error deriving addresses: $e';
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
      versionedHash[0] = 0x00;
      final shaOutput = Uint8List(32);
      final doubleSHAOutput = Uint8List(32);
      final addressBytes = Uint8List(25);
      final wifBytes = Uint8List(38);
      final wifBuffer = Uint8List(34);
      wifBuffer[0] = 0x80;
      wifBuffer[33] = 0x01;

      final startIndex = currentPage * entriesPerPage;

      for (var i = 0; i < entriesPerPage; i++) {
        try {
          final derivationIndex = startIndex + i;
          final path = basePath.endsWith('/') ? '$basePath$derivationIndex' : '$basePath/$derivationIndex';
          final extendedPrivateKey = chain.forPath(path) as ExtendedPrivateKey;
          final privateKeyHex = extendedPrivateKey.privateKeyHex();
          final publicKey = extendedPrivateKey.publicKey();

          final q = publicKey.q;
          if (q == null) continue;

          final pubKeyBytes = q.getEncoded(true);
          final pubKeyHex = hex.encode(pubKeyBytes);

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

  Future<void> changePage(bool next) async {
    if (next) {
      _currentPage++;
    } else {
      _currentPage = _currentPage > 0 ? _currentPage - 1 : 0;
    }

    await _deriveEntries(mnemonicController.text.trim());
    notifyListeners();
  }

  void clearAll() {
    mnemonicController.clear();
    _masterSeed = '';
    _xpriv = '';
    _xpub = '';
    _derivedEntries = [];
    _currentPage = 0;
    _errorMessage = null;
    notifyListeners();
  }

  void toggleMnemonicVisibility() {
    _hideMnemonic = !_hideMnemonic;
    notifyListeners();
  }

  void togglePrivateKeyVisibility() {
    _hidePrivateKeys = !_hidePrivateKeys;
    notifyListeners();
  }

  Future<void> copyMnemonic(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: mnemonicController.text));
    if (context.mounted) {
      showSnackBar(context, 'Mnemonic copied to clipboard');
    }
  }

  Future<void> copyToClipboard(BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      showSnackBar(context, '${label.replaceAll(':', '')} copied to clipboard');
    }
  }

  @override
  void dispose() {
    mnemonicController.removeListener(notifyListeners);
    mnemonicController.dispose();
    derivationPathController.dispose();
    super.dispose();
  }
}

class AddressTable extends StatelessWidget {
  final List<HDWalletEntry> entries;
  final bool hidePrivateKeys;

  const AddressTable({
    super.key,
    required this.entries,
    required this.hidePrivateKeys,
  });

  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => entries.isEmpty ? 'empty$index' : entries[index].path,
      drawGrid: true,
      shrinkWrap: true,
      headerBuilder: (context) => [
        const SailTableHeaderCell(name: 'Path                                   '),
        const SailTableHeaderCell(name: 'Address                                                           '),
        const SailTableHeaderCell(
          name: 'Public Key                                                                             ',
        ),
        const SailTableHeaderCell(name: 'Private Key (WIF)                                                         '),
      ],
      rowBuilder: (context, row, selected) {
        if (entries.isEmpty) {
          return [
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
          ];
        }

        final entry = entries[row];
        return [
          SailTableCell(
            value: entry.path,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SailText.primary12(
                entry.path,
                monospace: true,
              ),
            ),
          ),
          SailTableCell(
            value: entry.address,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SailText.primary12(
                entry.address,
                monospace: true,
              ),
            ),
          ),
          SailTableCell(
            value: entry.publicKey,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SailText.primary12(
                entry.publicKey,
                monospace: true,
              ),
            ),
          ),
          SailTableCell(
            value: hidePrivateKeys ? '••••••••••••••••••••••••••••••••' : entry.privateKey,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SailText.primary12(
                hidePrivateKeys ? '••••••••••••••••••••••••••••••••' : entry.privateKey,
                monospace: true,
              ),
            ),
          ),
        ];
      },
      rowCount: entries.isEmpty ? 10 : entries.length,
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
