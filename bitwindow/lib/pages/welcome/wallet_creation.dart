import 'package:bitwindow/pages/welcome/multisig_config_step.dart';
import 'package:bitwindow/pages/welcome/wallet_backup_page.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Creates the wallet [result] describes and returns its name.
Future<String> createWalletFromSetup(WalletSetupResult result) async {
  if (result.multisig case final spec?) {
    return createMultisigWallet(m: spec.m, n: spec.n, scriptType: spec.scriptType, cosigners: spec.cosigners);
  }

  final writer = GetIt.I.get<WalletWriterProvider>();
  final name = _nextName();
  final gradient = WalletGradient.fromWalletId(name);
  final single = result.single!;
  final mnemonic = single.mnemonic ?? '';
  if (mnemonic.isEmpty) {
    await writer.createElectrumWallet(
      name: name,
      gradient: gradient,
      xpubOrDescriptor: single.xpubOrDescriptor,
      scriptType: single.scriptType,
      hardwareDeviceType: single.hardwareDeviceType,
      hardwareFingerprint: single.hardwareFingerprint,
    );
  } else if (single.provider == 'core') {
    await writer.createBitcoinCoreWallet(
      name: name,
      gradient: gradient,
      customMnemonic: mnemonic,
      passphrase: single.passphrase ?? '',
      scriptType: single.scriptType,
      derivationPath: (single.derivationPath ?? '').isEmpty ? null : single.derivationPath,
    );
  } else {
    await writer.createElectrumWallet(
      name: name,
      gradient: gradient,
      customMnemonic: mnemonic,
      passphrase: single.passphrase ?? '',
      scriptType: single.scriptType,
      derivationPath: single.derivationPath ?? '',
    );
  }
  return name;
}

/// Creates a multisig wallet over [cosigners] and returns its name.
Future<String> createMultisigWallet({
  required int m,
  required int n,
  required String scriptType,
  required List<CosignerKeystore> cosigners,
}) async {
  final name = _nextName();
  await GetIt.I.get<WalletWriterProvider>().createMultisigWallet(
    name: name,
    gradient: WalletGradient.fromWalletId(name),
    m: m,
    n: n,
    scriptType: scriptType,
    cosigners: cosignerInputs(cosigners),
  );
  return name;
}

/// Creates a single-sig wallet from [seed] at the standard path.
Future<String> createWalletFromSeed(SeedBackup seed) {
  return createWalletFromSetup(
    WalletSetupResult.single(
      SingleSigResult(
        scriptType: hotScriptType('wpkh'),
        provider: defaultWalletProvider(runsLocalBackends: NodeModeProvider.runsLocalBackends),
        mnemonic: seed.mnemonic,
        passphrase: seed.passphrase,
      ),
    ),
  );
}

/// Creates a watch-only or multisig wallet from an output descriptor.
Future<String> importDescriptorWallet(String descriptor) async {
  final policy = await GetIt.I.get<OrchestratorRPC>().wallet.validateDescriptor(descriptor);
  if (policy.multisig) {
    return createMultisigWallet(
      m: policy.m,
      n: policy.n,
      scriptType: policy.scriptType,
      cosigners: keystoresFromPolicy(policy),
    );
  }
  if (policy.keys.any((k) => k.xprv.isNotEmpty)) {
    final name = _nextName();
    await GetIt.I.get<WalletWriterProvider>().createElectrumWallet(
      name: name,
      gradient: WalletGradient.fromWalletId(name),
      privateDescriptor: descriptor.trim(),
    );
    return name;
  }
  return createWalletFromSetup(
    WalletSetupResult.single(
      SingleSigResult(scriptType: hotScriptType(policy.scriptType), xpubOrDescriptor: descriptor.trim()),
    ),
  );
}

/// Creates a multisig wallet from the content of a multisig config file.
Future<String> importMultisigConfigWallet(String content) async {
  final config = await GetIt.I.get<OrchestratorRPC>().wallet.parseMultisigConfig(content);
  return createMultisigWallet(
    m: config.m,
    n: config.n,
    scriptType: config.scriptType.isEmpty ? 'wsh' : config.scriptType,
    cosigners: keystoresFromConfig(config),
  );
}

String _nextName() => nextWalletName(GetIt.I.get<WalletReaderProvider>().availableWallets.map((w) => w.name));
