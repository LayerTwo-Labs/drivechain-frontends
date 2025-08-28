import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:math';
import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/wallet_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:convert/convert.dart' show hex;
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class CreateWalletPage extends StatefulWidget {
  final WelcomeScreen initalScreen;

  const CreateWalletPage({
    super.key,
    this.initalScreen = WelcomeScreen.initial,
  });

  @override
  State<CreateWalletPage> createState() => _CreateWalletPageState();
}

enum WelcomeScreen {
  initial,
  restore,
  advanced,
  success,
}

class _CreateWalletPageState extends State<CreateWalletPage> {
  late WelcomeScreen _currentScreen;
  final TextEditingController _mnemonicController = TextEditingController();
  final TextEditingController _passphraseController = TextEditingController();
  final WalletProvider _walletProvider = GetIt.I.get<WalletProvider>();
  bool _isHexMode = false;
  bool _isValidInput = false;
  Map<String, dynamic> _currentWalletData = {};

  bool hasExistingWallet = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();

    _currentScreen = widget.initalScreen;
    _mnemonicController.addListener(_onMnemonicChanged);
    _passphraseController.addListener(setstate);

    _walletProvider.hasExistingWallet().then((value) {
      setState(() {
        hasExistingWallet = value;
      });
    });
  }

  void setstate() {
    setState(() {});
  }

  @override
  void dispose() {
    _mnemonicController.removeListener(_onMnemonicChanged);
    _passphraseController.removeListener(setstate);
    _mnemonicController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SailTheme.of(context).colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: hasExistingWallet,
        backgroundColor: SailTheme.of(context).colors.background,
        foregroundColor: SailTheme.of(context).colors.text,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            switch (_currentScreen) {
              case WelcomeScreen.initial:
                return _buildInitialScreen();
              case WelcomeScreen.restore:
                return _buildRestoreScreen();
              case WelcomeScreen.advanced:
                return _buildAdvancedScreen();
              case WelcomeScreen.success:
                return _buildSuccessScreen();
            }
          },
        ),
      ),
    );
  }

  void _clearWalletData() {
    setState(() {
      _currentWalletData.clear();
      _isValidInput = false;
    });
  }

  bool _isValidEntropy(String entropyHex) {
    if (entropyHex.isEmpty) return false;
    try {
      if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(entropyHex)) {
        return false;
      }
      if (entropyHex.length > 64) {
        return false;
      }
      final paddedHex = entropyHex.padRight(((entropyHex.length + 31) ~/ 32) * 32, '0');
      hex.decode(paddedHex);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _onMnemonicChanged() {
    if (_currentScreen != WelcomeScreen.advanced) return;
    final input = _mnemonicController.text.trim();
    if (input.isEmpty) {
      _clearWalletData();
      return;
    }
    if (_isHexMode) {
      final isValid = _isValidEntropy(input);
      setState(() {
        _isValidInput = isValid;
      });
      if (isValid) {
        _generateWalletFromEntropy(input);
      } else {
        _clearWalletData();
      }
    } else {
      final bytes = utf8.encode(input);
      final hash = sha256.convert(bytes);
      final entropy = hash.bytes.sublist(0, 16);
      final entropyHex = hex.encode(entropy);
      _generateWalletFromEntropy(entropyHex);
      setState(() {
        _isValidInput = true;
      });
    }
  }

  Future<void> _generateWalletFromEntropy(String entropyHex) async {
    try {
      final paddedHex = entropyHex.trim().padRight(((entropyHex.length + 31) ~/ 32) * 32, '0');
      final entropy = hex.decode(paddedHex);
      if (entropy.isEmpty) {
        _clearWalletData();
        return;
      }
      try {
        final wallet = await _walletProvider.generateWalletFromEntropy(entropy, passphrase: null, doNotSave: true);
        setState(() {
          _currentWalletData = Map<String, dynamic>.from(wallet);
          _isValidInput = true;
        });
      } catch (e) {
        await _showErrorDialog('Error generating from entropy: $e');
        _clearWalletData();
        return;
      }
    } catch (e) {
      _clearWalletData();
    }
  }

  Future<void> _handleAdvancedCreate() async {
    if (!_isValidInput) return;
    try {
      final entropyHex = _mnemonicController.text.trim();
      List<int> entropy;
      if (_isHexMode) {
        entropy = hex.decode(entropyHex);
        if (entropy.length < 16 || entropy.length > 32 || entropy.length % 4 != 0) {
          await _showErrorDialog('Invalid entropy length. Must be 16-32 bytes and a multiple of 4.');
          return;
        }
      } else {
        final bytes = utf8.encode(entropyHex);
        final hash = sha256.convert(bytes);
        entropy = hash.bytes.sublist(0, 16);
      }

      final wallet = await _walletProvider.generateWalletFromEntropy(entropy, passphrase: null);
      setState(() {
        _currentWalletData = Map<String, dynamic>.from(wallet);
        _isValidInput = true;
      });
    } catch (e) {
      await _showErrorDialog('Error creating wallet: $e');
    }
  }

  Future<void> _showErrorDialog(String message) async {
    await errorDialog(
      context: context,
      action: 'Error',
      title: 'Error',
      subtitle: message,
    );
    _mnemonicController.clear();
  }

  Widget _buildMnemonicDisplay() {
    if (_currentWalletData.isEmpty || !_currentWalletData.containsKey('mnemonic')) {
      return const SizedBox.shrink();
    }
    final theme = SailTheme.of(context);
    final words = _currentWalletData['mnemonic'].split(' ');
    final binaryString = _currentWalletData['bip39_binary'] ?? '';
    final checksumBinary = _currentWalletData['bip39_checksum'] ?? '';
    final entropyBits = binaryString.length;
    final checksumBits = entropyBits ~/ 32;
    final totalBits = entropyBits + checksumBits;
    final expectedWords = totalBits ~/ 11;
    if (words.length != expectedWords) {
      return const SizedBox.shrink();
    }
    final fullBinary = binaryString + checksumBinary;
    final binaryStrings = <String>[];
    for (int i = 0; i < fullBinary.length; i += 11) {
      final end = i + 11 > fullBinary.length ? fullBinary.length : i + 11;
      final chunk = fullBinary.substring(i, end).padRight(11, '0');
      binaryStrings.add(chunk);
    }
    return SailCard(
      padding: true,
      secondary: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SailText.primary10(
              'Entropy ($entropyBits bits) + Checksum ($checksumBits bits) = $totalBits bits ÷ 11 = $expectedWords words',
              color: theme.colors.textSecondary,
            ),
          ),
          for (int row = 0; row < (words.length / 6).ceil(); row++)
            Padding(
              padding: EdgeInsets.only(bottom: row < (words.length / 6).ceil() - 1 ? 4 : 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (int col = 0; col < 6; col++) ...[
                    if (row * 6 + col < words.length)
                      SizedBox(
                        width: 100,
                        child: SailColumn(
                          spacing: 2,
                          children: [
                            SailText.primary10(words[row * 6 + col], bold: true),
                            if (row * 6 + col < binaryStrings.length)
                              row * 6 + col == words.length - 1
                                  ? RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: binaryStrings[row * 6 + col].substring(0, 7),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: theme.colors.textSecondary,
                                              fontFamily: 'IBM Plex Mono',
                                            ),
                                          ),
                                          TextSpan(
                                            text: binaryStrings[row * 6 + col].substring(7),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: theme.colors.success,
                                              fontFamily: 'IBM Plex Mono',
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SailText.primary10(
                                      binaryStrings[row * 6 + col],
                                      color: theme.colors.textSecondary,
                                    ),
                          ],
                        ),
                      ),
                    if (col < 5 && row * 6 + col < words.length - 1) const SizedBox(width: 2),
                  ],
                ],
              ),
            ),
          if (_currentWalletData.containsKey('mnemonic'))
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 40,
                  child: SailButton(
                    label: 'Copy Mnemonic',
                    variant: ButtonVariant.secondary,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _currentWalletData['mnemonic']));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Mnemonic copied to clipboard'),
                            backgroundColor: SailTheme.of(context).colors.success,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    final theme = SailTheme.of(context);
    final binaryString = _currentWalletData['bip39_binary'] ?? '';
    final checksumBinary = _currentWalletData['bip39_checksum'] ?? '';
    return SailCard(
      padding: true,
      secondary: true,
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SizedBox(
                width: 100,
                child: SailText.primary10('BIP39 Binary:', bold: true),
              ),
              Expanded(
                child: SailText.primary10(
                  binaryString,
                  color: theme.colors.textSecondary,
                ),
              ),
            ],
          ),
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SizedBox(
                width: 100,
                child: SailText.primary10('Checksum:', bold: true),
              ),
              SailText.primary10(
                checksumBinary,
                color: theme.colors.success,
              ),
              const SizedBox(width: SailStyleValues.padding16),
              SailText.primary10('Hex:', bold: true),
              const SizedBox(width: SailStyleValues.padding04),
              SailText.primary10(
                _currentWalletData['bip39_checksum_hex'] ?? '',
                color: theme.colors.success,
              ),
              Expanded(child: Container()),
            ],
          ),
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary10('Master Key:', bold: true),
                    SailText.primary10(
                      _currentWalletData['master_key'] ?? '',
                      color: theme.colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary10('Chain Code:', bold: true),
                    SailText.primary10(
                      _currentWalletData['chain_code'] ?? '',
                      color: theme.colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedScreen() {
    final theme = SailTheme.of(context);
    return Stack(
      children: [
        // Main scrollable content
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SizedBox(
              width: 800,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 50), // Space for buttons
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BootTitle(
                      title: 'Create with custom entropy',
                      subtitle:
                          'Generate a wallet by providing your own entropy. Or leave the generation to us, but stay hooked in to all the nitty gritty byte-details. This is used to create your seed.',
                    ),
                    const SizedBox(height: 50), // Spacing after title
                    SailCard(
                      padding: true,
                      secondary: true,
                      child: SailColumn(
                        spacing: SailStyleValues.padding12,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SailRow(
                            spacing: SailStyleValues.padding08,
                            children: [
                              SailText.primary13('Custom Entropy'),
                              SailCheckbox(
                                value: _isHexMode,
                                onChanged: (value) {
                                  setState(() {
                                    _isHexMode = value;
                                    _mnemonicController.clear();
                                    _clearWalletData();
                                  });
                                },
                                label: 'Hex',
                              ),
                              const Spacer(),
                              if (_isHexMode)
                                SailText.secondary12(
                                  _mnemonicController.text.isEmpty
                                      ? 'Enter up to 64 hex characters (0-9 and A-F)'
                                      : (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(_mnemonicController.text)
                                            ? 'Invalid hex characters (only 0-9 and A-F allowed)'
                                            : (_mnemonicController.text.length > 64
                                                  ? 'Too many characters (maximum 64)'
                                                  : 'Valid hex input')),
                                  color: _mnemonicController.text.isEmpty
                                      ? theme.colors.textSecondary
                                      : (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(_mnemonicController.text) ||
                                                _mnemonicController.text.length > 64
                                            ? theme.colors.error
                                            : theme.colors.success),
                                ),
                            ],
                          ),
                          SizedBox(
                            height: 40,
                            child: SailTextField(
                              controller: _mnemonicController,
                              hintText: _isHexMode ? 'Enter hex entropy (16-32 bytes)' : 'Enter text to hash',
                              textFieldType: TextFieldType.text,
                              size: TextFieldSize.small,
                            ),
                          ),
                          SailRow(
                            spacing: SailStyleValues.padding08,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Spacer(),
                              SizedBox(
                                height: 40,
                                child: SailButton(
                                  label: 'Random',
                                  variant: ButtonVariant.secondary,
                                  onPressed: () async {
                                    setState(() {
                                      _isHexMode = true;
                                    });
                                    final entropy = List.generate(16, (index) => Random.secure().nextInt(256));
                                    final entropyHex = hex.encode(entropy);
                                    _mnemonicController.text = entropyHex;
                                    _onMnemonicChanged();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_currentWalletData.containsKey('mnemonic')) const SizedBox(height: 16),
                    if (_currentWalletData.containsKey('mnemonic')) _buildMnemonicDisplay(),
                    if (_currentWalletData.containsKey('mnemonic')) const SizedBox(height: 16),
                    if (_currentWalletData.containsKey('mnemonic')) _buildInfoPanel(),
                    if (_currentWalletData.containsKey('mnemonic')) const SizedBox(height: 16),
                    const SizedBox(height: 50), // Bottom spacing
                  ],
                ),
              ),
            ),
          ),
        ),
        // Navigation buttons at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            color: SailTheme.of(context).colors.background,
            child: Center(
              child: SizedBox(
                width: 800,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SailButton(
                      label: '← Back',
                      variant: ButtonVariant.secondary,
                      onPressed: () async => setState(() => _currentScreen = WelcomeScreen.initial),
                    ),
                    SailButton(
                      label: 'Create Wallet',
                      variant: ButtonVariant.primary,
                      disabled: !_isValidInput,
                      onPressed: _handleAdvancedCreate,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialScreen() {
    final theme = SailTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SizedBox(
          width: 800,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              BootTitle(
                title: hasExistingWallet ? 'Create New Wallet' : 'Set up your wallet',
                subtitle: hasExistingWallet
                    ? "Let's create a new wallet. Note that creating a new wallet will wipe your current wallet, and you should backup your current wallet before generating a new one."
                    : "Welcome to Drivechain! Let's begin by setting up your wallet. The same seed is used for your mainchain node and all your sidechain wallets. This ensures you can easily back up and restore all wallets at a later date.",
              ),
              Spacer(),
              SizedBox(
                width: 400,
                height: 64,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colors.primary,
                        theme.colors.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: _isGenerating
                        ? null
                        : () {
                            setState(() => _isGenerating = true);
                            // Schedule the wallet generation to run after this frame
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _handleFastMode();
                            });
                          },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SailText.primary15(
                            _isGenerating
                                ? 'Generating Your Wallet'
                                : hasExistingWallet
                                ? 'Create New Wallet'
                                : 'Generate Wallet',
                            color: Colors.white,
                            bold: true,
                          ),
                        ),
                        if (_isGenerating)
                          SizedBox(
                            width: 15,
                            height: 15,
                            child: LoadingIndicator.insideButton(Colors.white),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SailButton(
                    label: 'Restore from backup',
                    variant: ButtonVariant.ghost,
                    onPressed: () async => setState(() => _currentScreen = WelcomeScreen.restore),
                  ),
                  const SizedBox(width: 24),
                  SailText.secondary15('·'),
                  const SizedBox(width: 24),
                  SailButton(
                    label: 'Paranoid mode',
                    variant: ButtonVariant.ghost,
                    onPressed: () async => setState(() => _currentScreen = WelcomeScreen.advanced),
                  ),
                ],
              ),
              const Spacer(),
              const Spacer(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SizedBox(
          width: 800,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              BootTitle(
                title: 'Restore your wallet',
                subtitle:
                    'Restore your mainchain wallet and all sidechain wallets from a seed backup. This can also be used to create a wallet with a custom seed of yours.',
              ),
              const Spacer(),
              SailTextField(
                controller: _mnemonicController,
                hintText: 'Enter BIP39 mnemonic (12 or 24 words)',
                maxLines: 3,
                textFieldType: TextFieldType.text,
                size: TextFieldSize.regular,
              ),
              const SizedBox(height: 16),
              SailTextField(
                controller: _passphraseController,
                hintText: 'Optional passphrase',
                textFieldType: TextFieldType.text,
                size: TextFieldSize.regular,
              ),
              const SizedBox(height: 32),
              const Spacer(),
              const Spacer(),
              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SailButton(
                    label: '← Back',
                    variant: ButtonVariant.secondary,
                    onPressed: () async => setState(() => _currentScreen = WelcomeScreen.initial),
                  ),
                  SailButton(
                    label: 'Restore',
                    variant: ButtonVariant.primary,
                    onPressed: _handleRestore,
                    loadingLabel: 'Restoring your wallet',
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleFastMode() async {
    // setState is already called in the button's onPressed
    try {
      await _walletProvider.generateWallet();
      if (mounted) {
        setState(() => _currentScreen = WelcomeScreen.success);
      }
    } catch (e) {
      if (mounted) {
        await _showErrorDialog('Failed to generate wallet: $e');
      }
    }

    if (mounted) {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _handleRestore() async {
    if (!_isValidMnemonic(_mnemonicController.text)) {
      await _showErrorDialog('Invalid mnemonic format. Please enter 12 or 24 words.');
      return;
    }
    try {
      await _walletProvider.generateWallet(
        customMnemonic: _mnemonicController.text,
        passphrase: _passphraseController.text.isNotEmpty ? _passphraseController.text : null,
      );
      if (mounted) {
        setState(() => _currentScreen = WelcomeScreen.success);
      }
    } catch (e) {
      await _showErrorDialog('Failed to generate wallet: $e');
    }
  }

  bool _isValidMnemonic(String mnemonic) {
    final words = mnemonic.trim().split(' ');
    return words.length == 12 || words.length == 24;
  }

  Widget _buildSuccessScreen() {
    final theme = SailTheme.of(context);
    final binaryProvider = GetIt.I.get<BinaryProvider>();
    final runningSidechains = binaryProvider.runningBinaries.whereType<Sidechain>().toList();
    final hasRunningSidechains = runningSidechains.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SizedBox(
          width: 800,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              BootTitle(
                title: 'Wallet Created',
                subtitle: hasRunningSidechains
                    ? 'Your wallet was created successfully.\r\n\r\nI can see you have some sidechains running. Do you want to restart them to apply the new wallet?'
                    : 'Your wallet was created successfully. You can now continue to the world of Drivechain.',
              ),
              SailSVG.icon(
                SailSVGAsset.iconSuccess,
                width: 64,
                height: 64,
                color: hasRunningSidechains ? theme.colors.orange : theme.colors.success,
              ),
              const Spacer(),
              if (hasRunningSidechains)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailButton(
                      label: 'Continue without restart',
                      variant: ButtonVariant.secondary,
                      onPressed: () async {
                        GetIt.I.get<AppRouter>().popUntilRoot();
                      },
                    ),
                    SailButton(
                      label: 'Restart and Continue',
                      variant: ButtonVariant.primary,
                      loadingLabel: 'Restarting ${runningSidechains.length} sidechains',
                      onPressed: () async {
                        // Restart all running sidechains
                        await Future.wait(
                          runningSidechains.map((sidechain) => binaryProvider.stop(sidechain)),
                        );
                        await Future.delayed(const Duration(seconds: 3));
                        for (final sidechain in runningSidechains) {
                          unawaited(binaryProvider.start(sidechain));
                        }
                        if (mounted) {
                          GetIt.I.get<AppRouter>().popUntilRoot();
                        }
                      },
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SailButton(
                      label: 'Continue',
                      variant: ButtonVariant.primary,
                      onPressed: () async {
                        GetIt.I.get<AppRouter>().pop();
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class BootTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const BootTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        SailText.primary40(
          title,
          bold: true,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SailText.primary15(
          subtitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
