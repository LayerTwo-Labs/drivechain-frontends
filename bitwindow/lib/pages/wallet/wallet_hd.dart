import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

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
            _ControlsCard(model: model),
            _AddressesSection(model: model),
          ],
        ),
      ),
    );
  }
}

class _ControlsCard extends StatelessWidget {
  final HDWalletViewModel model;

  const _ControlsCard({required this.model});

  @override
  Widget build(BuildContext context) {
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
                    child: model.hideMnemonic && model.mnemonicController.text.isNotEmpty
                        ? Container(
                            height: 36, // Small text field height
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: context.sailTheme.colors.divider),
                              borderRadius: BorderRadius.circular(4),
                              color: context.sailTheme.colors.background,
                            ),
                            child: SailText.primary13(
                              '••••••••••••••••••••••••••••••••',
                              monospace: true,
                            ),
                          )
                        : SailTextField(
                            controller: model.mnemonicController,
                            hintText: 'Enter mnemonic seed phrase',
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
                  hintText: model.defaultDerivationPath,
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
          const SailSeparator(),
          SailColumn(
            spacing: SailStyleValues.padding08,
            children: [
              for (final item in [
                {'label': 'BIP47 Payment Code:', 'value': model.bip47PaymentCode},
                {'label': 'Master Seed:', 'value': model.masterSeed},
                {'label': 'XPRIV:', 'value': model.xpriv},
                {'label': 'XPUB:', 'value': model.xpub},
              ])
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 160,
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
                          : () async => await model.copyToClipboard(
                              context,
                              item['value']!,
                              item['label']!,
                              secret: item['label'] == 'Master Seed:' || item['label'] == 'XPRIV:',
                            ),
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
}

class _AddressesSection extends StatelessWidget {
  final HDWalletViewModel model;

  const _AddressesSection({required this.model});

  @override
  Widget build(BuildContext context) {
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
  BitcoinConfProvider get _conf => GetIt.I.get<BitcoinConfProvider>();
  late final TextEditingController derivationPathController = TextEditingController(text: defaultDerivationPath);

  /// The BIP84 receive chain of the wallet on the active network.
  String get defaultDerivationPath => "m/84'/${_conf.usesMainnetParams ? 0 : 1}'/0'/0";

  List<HDWalletEntry> _derivedEntries = [];
  String? _errorMessage;
  int _currentPage = 0;
  static const int _entriesPerPage = 10;

  String _masterSeed = '';
  String _xpriv = '';
  String _xpub = '';
  String _bip47PaymentCode = '';
  // An answer from an older run, or from before Clear, must not show its keys.
  int _exploreRun = 0;
  bool _hideMnemonic = false;
  bool _hidePrivateKeys = true;

  // Getters
  List<HDWalletEntry> get derivedEntries => _derivedEntries;
  String? get errorMessage => _errorMessage ?? _hdWalletProvider.error;
  int get currentPage => _currentPage;
  String get masterSeed => _masterSeed;
  String get xpriv => _xpriv;
  String get xpub => _xpub;
  String get bip47PaymentCode => _bip47PaymentCode;
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

  OrchestratorWalletRPC get _orchestratorWallet => GetIt.I.get<OrchestratorRPC>().wallet;

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
      mnemonicController.text = await _orchestratorWallet.generateMnemonic();
    } catch (e) {
      _errorMessage = 'Error generating random mnemonic: ${extractConnectException(e)}';
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
    await _explore(mnemonic);
    notifyListeners();
  }

  Future<void> _explore(String mnemonic) async {
    final run = ++_exploreRun;
    try {
      final explored = await _orchestratorWallet.exploreSeed(
        mnemonic: mnemonic,
        basePath: derivationPathController.text.trim(),
        startIndex: _currentPage * _entriesPerPage,
        count: _entriesPerPage,
      );
      if (run != _exploreRun) {
        return;
      }
      _masterSeed = explored.seedHex;
      _xpriv = explored.xprv;
      _xpub = explored.xpub;
      _bip47PaymentCode = explored.bip47PaymentCode;
      _derivedEntries = [
        for (final key in explored.keys)
          HDWalletEntry(path: key.path, address: key.address, publicKey: key.publicKey, privateKey: key.wif),
      ];
    } catch (e) {
      if (run == _exploreRun) {
        _errorMessage = 'Error deriving keys: ${extractConnectException(e)}';
      }
    }
  }

  Future<void> changePage(bool next) async {
    if (next) {
      _currentPage++;
    } else {
      _currentPage = _currentPage > 0 ? _currentPage - 1 : 0;
    }

    await _explore(mnemonicController.text.trim());
    notifyListeners();
  }

  void clearAll() {
    _exploreRun++;
    mnemonicController.clear();
    _masterSeed = '';
    _xpriv = '';
    _xpub = '';
    _bip47PaymentCode = '';
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
    await copySecretToClipboard(mnemonicController.text);
    if (context.mounted) {
      showSailToast(context, 'Mnemonic copied to clipboard');
    }
  }

  Future<void> copyToClipboard(BuildContext context, String text, String label, {bool secret = false}) async {
    if (secret) {
      await copySecretToClipboard(text);
    } else {
      await Clipboard.setData(ClipboardData(text: text));
    }
    if (context.mounted) {
      showSailToast(context, '${label.replaceAll(':', '')} copied to clipboard');
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
      rowCount: entries.isEmpty ? 0 : entries.length,
      emptyPlaceholder: 'Enter a mnemonic and derivation path to derive addresses',
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
