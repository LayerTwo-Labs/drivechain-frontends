import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/main.dart' show restoreBitwindowWalletFromFile;
import 'package:bitwindow/pages/welcome/wallet_backup_page.dart';
import 'package:bitwindow/utils/ur_key.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/widgets/hardware_device_picker.dart';
import 'package:bitwindow/widgets/key_qr_scanner.dart';
import 'package:bitwindow/widgets/ur_qr_scanner.dart' show urCameraScanSupported;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/multisiglounge/v1/multisiglounge.pb.dart' as mlpb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

enum CosignerSource { software, xpub, file, qr, device }

/// BIP341 NUMS point, the taproot internal key that leaves script-path spends
/// as the only way to spend. Must match the backend's.
const _numsInternalKey = '50929b74c1a04954b78b4b6035e97a5e078a5a0f28ec96d547bfee9ace803ac0';

const _addressTypes = {
  'wpkh': 'Native Segwit (bc1q...)',
  'wsh': 'Native Segwit (bc1q...)',
  'tr': 'Taproot (bc1p...)',
  'sh-wpkh': 'Nested Segwit (3...)',
  'sh-wsh': 'Nested Segwit (3...)',
  'pkh': 'Legacy (1...)',
  'sh': 'Legacy (3...)',
};

/// One cosigner in the multisig policy. A key is [isFilled] once it has an xpub.
/// A cosigner with a [mnemonic] is held on disk and can sign; a cosigner with a
/// [hardwareDeviceType] signs on a USB device; the rest are signed elsewhere.
class CosignerKeystore {
  String owner;
  String xpub = '';
  String derivationPath = ''; // full, e.g. m/48'/1'/0'/2' (empty for a bare pasted xpub)
  String? fingerprint; // 8 hex chars
  String? originPath; // without leading m/, e.g. 48'/1'/0'/2'
  String? mnemonic; // present => held on disk, this wallet can sign with it
  String? passphrase; // optional BIP39 passphrase for mnemonic
  String? descriptor; // backend-built single-sig watch descriptor (device/watch-only)
  String? hardwareDeviceType; // present => signs on a USB device
  bool isWallet = false;
  CosignerSource? source;

  CosignerKeystore({required this.owner});

  bool get isFilled => xpub.isNotEmpty;
  bool get held => mnemonic != null && mnemonic!.isNotEmpty;
  bool get isHardware => hardwareDeviceType != null && hardwareDeviceType!.isNotEmpty;
}

class MultisigWalletSpec {
  final int m;
  final int n;
  final String scriptType;
  final List<CosignerKeystore> cosigners;
  final String receiveDescriptor;
  final String changeDescriptor;

  const MultisigWalletSpec({
    required this.m,
    required this.n,
    required this.scriptType,
    required this.cosigners,
    required this.receiveDescriptor,
    required this.changeDescriptor,
  });

  List<wmpb.MultisigCosignerInput> toCosignerInputs() {
    return cosigners
        .map(
          (c) => wmpb.MultisigCosignerInput(
            xpub: c.xpub,
            originPath: c.originPath ?? '',
            fingerprint: c.fingerprint ?? '',
            mnemonic: c.mnemonic ?? '',
            passphrase: c.passphrase ?? '',
            hardwareDeviceType: c.hardwareDeviceType ?? '',
          ),
        )
        .toList();
  }

  /// The Coldcard multisig setup file, imported on the device once before
  /// spending. Null for taproot multisig, which has no Coldcard format.
  String? coldcardConfig(String walletName) {
    final format = switch (scriptType) {
      'sh' => 'P2SH',
      'sh-wsh' => 'P2SH-P2WSH',
      'wsh' => 'P2WSH',
      _ => null,
    };
    if (format == null) {
      return null;
    }
    // Coldcard needs a master fingerprint per cosigner.
    if (cosigners.any((c) => (c.fingerprint ?? '').isEmpty)) {
      return null;
    }
    var name = walletName.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '');
    if (name.isEmpty) {
      name = 'multisig';
    }
    if (name.length > 20) {
      name = name.substring(0, 20);
    }
    final b = StringBuffer()
      ..writeln('# Coldcard Multisig setup file')
      ..writeln('Name: $name')
      ..writeln('Policy: $m of $n')
      ..writeln('Format: $format')
      ..writeln();
    for (final c in cosigners) {
      final path = (c.originPath ?? '').isEmpty ? '' : 'm/${c.originPath}';
      if (path.isNotEmpty) {
        b.writeln('Derivation: $path');
      }
      b.writeln('${(c.fingerprint ?? '').toUpperCase()}: ${c.xpub}');
    }
    return b.toString();
  }
}

bool isPlausibleXpub(String input) {
  return RegExp(r'^[xyztuvYZUV]pub[1-9A-HJ-NP-Za-km-z]{50,120}$').hasMatch(input.trim());
}

({String xpub, String? fingerprint, String? originPath}) parseKeyExpression(String raw) {
  final trimmed = raw.trim();
  // The path is optional: a cosigner may carry only a fingerprint.
  final m = RegExp(r'^\[([0-9a-fA-F]{8})(?:/([^\]]*))?\](.+)$').firstMatch(trimmed);
  if (m != null) {
    final path = m.group(2);
    return (
      xpub: m.group(3)!.trim(),
      fingerprint: m.group(1),
      originPath: path == null || path.isEmpty ? null : path,
    );
  }
  return (xpub: trimmed, fingerprint: null, originPath: null);
}

/// The outcome of the create screen: a multisig spec or a single-sig setup.
class WalletSetupResult {
  final MultisigWalletSpec? multisig;
  final SingleSigResult? single;
  const WalletSetupResult.multisig(MultisigWalletSpec this.multisig) : single = null;
  const WalletSetupResult.single(SingleSigResult this.single) : multisig = null;
  bool get isMultisig => multisig != null;
}

/// A single-sig wallet to create. A [mnemonic] makes a spendable wallet; an
/// [xpubOrDescriptor] a watch-only or hardware one.
class SingleSigResult {
  final String scriptType; // hot-wallet string: native-segwit|nested-segwit|legacy|taproot
  final String? mnemonic;
  final String? passphrase;
  final String? xpubOrDescriptor;
  final String? derivationPath; // account path the seed derives at
  final String? hardwareDeviceType;
  final String? hardwareFingerprint;

  /// Which backend watches the wallet: electrum | core.
  final String provider;

  const SingleSigResult({
    required this.scriptType,
    this.mnemonic,
    this.passphrase,
    this.xpubOrDescriptor,
    this.derivationPath,
    this.hardwareDeviceType,
    this.hardwareFingerprint,
    this.provider = 'electrum',
  });
}

/// The provider a new wallet starts on. A full-mode install runs Bitcoin Core,
/// which is what the user asked for on the node mode step; light mode runs no
/// local node, so only electrum can serve it.
String defaultWalletProvider({required bool runsLocalBackends}) => runsLocalBackends ? 'core' : 'electrum';

class MultisigConfigStep extends StatefulWidget {
  final void Function(WalletSetupResult result) onConfigured;

  /// Called when a backup restore produced a wallet, so the caller can hand
  /// control back the same way it does for a freshly created one — a route
  /// guard may be holding a suspended navigation.
  final Future<void> Function()? onRestored;

  /// Reports whether a restore is in flight, so the host can freeze its own
  /// navigation: the restore rewrites wallet state and restarts L1, and this
  /// page must outlive it.
  final ValueChanged<bool>? onRestoringChanged;

  const MultisigConfigStep({
    required this.onConfigured,
    this.onRestored,
    this.onRestoringChanged,
    super.key,
  });

  @override
  State<MultisigConfigStep> createState() => _MultisigConfigStepState();
}

class _MultisigConfigStepState extends State<MultisigConfigStep> with AutomaticKeepAliveClientMixin {
  // The wizard PageView disposes off-screen pages, which would drop every key
  // the user added when they step forward and come back.
  @override
  bool get wantKeepAlive => true;

  static const int _maxCosigners = 15;

  int _threshold = 1; // m
  int _total = 1; // n
  String _scriptType = 'wpkh'; // multi: wsh|sh-wsh|sh|tr; single: wpkh|sh-wpkh|pkh|tr
  int _selectedTab = 0;
  bool _settingsOpen = false;
  String _provider = defaultWalletProvider(
    runsLocalBackends: NodeModeProvider.runsLocalBackends,
  ); // electrum | core | enforcer

  /// One key is a single-sig wallet; the quorum slider is what makes it multisig.
  bool get _isSingle => _total == 1;

  /// The policy's script type, used to pick a key out of a multi-key export.
  /// Single-sig holds wpkh|sh-wpkh|pkh|tr here, multisig holds wsh|sh-wsh|sh|tr.
  String get _activeScriptType => _scriptType;
  bool _building = false;
  String? _error;
  bool _restoringBackup = false;
  late List<CosignerKeystore> _keystores;
  final TextEditingController _descriptor = TextEditingController();
  final FocusNode _descriptorFocus = FocusNode();
  final TextEditingController _path = TextEditingController();
  final FocusNode _pathFocus = FocusNode();
  List<wmpb.DerivationPathOption> _pathOptions = [];
  String _standardPath = '';
  String? _pathError;
  String? _descriptorError;
  String? _addressTypeNote;

  @override
  void initState() {
    super.initState();
    _keystores = List.generate(_total, (i) => CosignerKeystore(owner: 'Key ${i + 1}'));
    _descriptor.text = _descriptorPreview;
    // Snapping back over a rejected descriptor would take away the text the
    // error is about.
    _descriptorFocus.addListener(() {
      if (!_descriptorFocus.hasFocus && _descriptorError == null) {
        setState(() => _descriptor.text = _descriptorPreview);
      }
    });
    unawaited(_loadPathOptions());
    // Warm up hardware-device enumeration so the picker opens without a spinner.
    prefetchHardwareDevices();
  }

  @override
  void dispose() {
    _descriptor.dispose();
    _descriptorFocus.dispose();
    _path.dispose();
    _pathFocus.dispose();
    super.dispose();
  }

  // The standard paths for the selected keystore's policy, prefilling the
  // derivation of every slot still waiting for a key.
  // Identifies the policy a path request was made for, so a slower earlier
  // response cannot answer for a later one.
  String get _policyKey => '${_isSingle ? _singleHotScriptType() : _scriptType}|${_isSingle ? 1 : 0}';

  Future<void> _loadPathOptions() async {
    final index = _selectedTab;
    final requested = _policyKey;
    final wmpb.ListDerivationPathsResponse paths;
    try {
      paths = await GetIt.I.get<OrchestratorRPC>().wallet.listDerivationPaths(
        scriptType: _isSingle ? _singleHotScriptType() : _scriptType,
        multisig: !_isSingle,
        account: index,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to load derivation paths: ${extractConnectException(e)}');
      }
      return;
    }
    if (!mounted || _selectedTab != index || _policyKey != requested) {
      return;
    }
    setState(() {
      _pathOptions = paths.options;
      _standardPath = paths.defaultPath;
      final k = _keystores[index];
      if (k.derivationPath.isEmpty) {
        k.derivationPath = paths.defaultPath;
      }
      if (!_pathFocus.hasFocus) {
        _path.text = k.derivationPath;
      }
      _pathError = null;
    });
  }

  bool _isCurrentPath(int index, String raw) =>
      index == _selectedTab && index < _keystores.length && _keystores[index].derivationPath == raw;

  Future<void> _onPathChanged(int index, String raw) async {
    final k = _keystores[index];
    k.derivationPath = raw;
    final wmpb.ValidateDerivationPathResponse path;
    try {
      path = await GetIt.I.get<OrchestratorRPC>().wallet.validateDerivationPath(
        raw,
        multisig: !_isSingle,
      );
    } catch (e) {
      // A response for text the user has already moved past says nothing about
      // what is in the field now.
      if (mounted && _isCurrentPath(index, raw)) {
        setState(() => _pathError = extractConnectException(e));
      }
      return;
    }
    if (!mounted || !_isCurrentPath(index, raw)) {
      return;
    }
    // A single-sig wallet is its one keystore, so a standard path names its
    // script type.
    _update(() {
      _pathError = null;
      if (_isSingle && path.scriptType.isNotEmpty && path.scriptType != _scriptType) {
        _scriptType = path.scriptType;
        _addressTypeNote = 'Changed to ${_addressTypeLabel(path.scriptType)} to match this derivation path.';
      }
      // A watch-only key cannot be re-derived, so the path is simply the origin
      // the user vouches for.
      if (k.isFilled && !k.held && !k.isHardware) {
        k.originPath = path.normalized.substring(2);
      }
    });
    if (!k.isFilled || !k.held) {
      return;
    }

    final derived = await _derive(index, mnemonic: k.mnemonic, passphrase: k.passphrase);
    if (derived == null || !mounted || _keystores[index] != k || !_isCurrentPath(index, raw)) {
      return;
    }
    _setKeystore(index, _rederived(k, derived));
  }

  CosignerKeystore _rederived(CosignerKeystore k, wmpb.DeriveKeystoreResponse derived) {
    return CosignerKeystore(owner: k.owner)
      ..xpub = derived.xpub
      ..mnemonic = k.mnemonic
      ..passphrase = k.passphrase
      ..derivationPath = 'm/${derived.originPath}'
      ..originPath = derived.originPath
      ..fingerprint = derived.fingerprint
      ..descriptor = derived.descriptor.isEmpty ? null : derived.descriptor
      ..isWallet = true
      ..source = k.source;
  }

  // A seed on disk follows the wallet's script type. Left at the previous
  // type's standard path it would be submitted as an override, which the
  // backend rejects for the purpose mismatch.
  int _rederiveGeneration = 0;

  Future<void> _rederiveHeldKeystores() async {
    // Newest run wins. Without this an earlier run can land last and leave the
    // previous policy's xpub under the newly chosen one.
    final generation = ++_rederiveGeneration;
    for (var i = 0; i < _keystores.length; i++) {
      final k = _keystores[i];
      if (!k.held) {
        continue;
      }
      k.derivationPath = '';
      final derived = await _derive(i, mnemonic: k.mnemonic, passphrase: k.passphrase);
      if (!mounted || generation != _rederiveGeneration) {
        return;
      }
      if (derived == null || _keystores[i] != k) {
        continue;
      }
      _setKeystore(i, _rederived(k, derived));
    }
  }

  // Drops the paths the new policy's standard one should replace. A key that
  // came with its own origin keeps it.
  void _resetPendingPaths() {
    for (final k in _keystores) {
      if (k.originPath == null) {
        k.derivationPath = '';
      }
    }
    _pathError = null;
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
      _path.text = _keystores[index].derivationPath;
      _pathError = null;
    });
    unawaited(_loadPathOptions());
  }

  // Mutates state and keeps the descriptor field showing the resulting policy,
  // unless the user is typing in it.
  void _update(VoidCallback mutate) {
    setState(() {
      mutate();
      if (!_descriptorFocus.hasFocus) {
        _descriptor.text = _descriptorPreview;
        _descriptorError = null;
      }
    });
  }

  // Adopts the typed descriptor's policy. A descriptor the backend cannot read
  // leaves the settings untouched and reports why.
  Future<void> _onDescriptorChanged(String raw) async {
    if (raw.trim().isEmpty) {
      setState(() => _descriptorError = null);
      return;
    }
    final wmpb.ValidateDescriptorResponse policy;
    try {
      policy = await GetIt.I.get<OrchestratorRPC>().wallet.validateDescriptor(raw);
    } catch (e) {
      // A response for text the user has already moved past says nothing about
      // what is in the field now.
      if (mounted && _descriptor.text == raw) {
        setState(() => _descriptorError = extractConnectException(e));
      }
      return;
    }
    if (!mounted || _descriptor.text != raw) {
      return;
    }

    _update(() {
      _error = null;
      _descriptorError = null;
      _addressTypeNote = null;
      _scriptType = policy.scriptType;
      _threshold = policy.m;
      _total = policy.n;
      final previous = List.of(_keystores);
      _keystores = policy.keys.asMap().entries.map((e) {
        final kept = previous.where((k) => k.xpub == e.value.xpub);
        if (kept.isNotEmpty) {
          return kept.first;
        }
        return CosignerKeystore(owner: 'Key ${e.key + 1}')
          ..xpub = e.value.xpub
          ..fingerprint = e.value.fingerprint.isEmpty ? null : e.value.fingerprint
          ..originPath = e.value.originPath.isEmpty ? null : e.value.originPath
          ..derivationPath = e.value.originPath.isEmpty ? '' : 'm/${e.value.originPath}'
          ..source = CosignerSource.xpub;
      }).toList();
      if (_selectedTab >= _total) {
        _selectedTab = _total - 1;
      }
      _resetPendingPaths();
    });
    await _loadPathOptions();
  }

  // Grow/shrink the keystore list to match n, preserving already-filled slots.
  void _resizeKeystores() {
    if (_total > _keystores.length) {
      for (var i = _keystores.length; i < _total; i++) {
        _keystores.add(CosignerKeystore(owner: 'Key ${i + 1}'));
      }
    } else if (_total < _keystores.length) {
      _keystores = _keystores.sublist(0, _total);
    }
    if (_selectedTab >= _total) {
      _selectedTab = _total - 1;
    }
  }

  String get _descriptorPreview {
    final parts = List.generate(_total, (i) {
      final k = _keystores[i];
      if (!k.isFilled) {
        return k.owner.replaceAll(' ', '');
      }
      if (k.fingerprint != null && k.originPath != null) {
        return '[${k.fingerprint}/${k.originPath}]${k.xpub}';
      }
      return k.xpub;
    });
    if (_isSingle) {
      final key = parts.first;
      return switch (_scriptType) {
        'pkh' => 'pkh($key)',
        'sh-wpkh' => 'sh(wpkh($key))',
        'tr' => 'tr($key)',
        _ => 'wpkh($key)',
      };
    }
    if (_scriptType == 'tr') {
      return 'tr($_numsInternalKey,sortedmulti_a($_threshold,${parts.join(',')}))';
    }
    final inner = 'sortedmulti($_threshold,${parts.join(',')})';
    switch (_scriptType) {
      case 'sh':
        return 'sh($inner)';
      case 'sh-wsh':
        return 'sh(wsh($inner))';
      default:
        return 'wsh($inner)';
    }
  }

  bool get _allFilled => _keystores.every((k) => k.isFilled);

  Future<void> _next() async {
    setState(() => _error = null);

    if (!_allFilled) {
      setState(() => _error = 'Add a key to every cosigner slot');
      return;
    }
    final xpubs = _keystores.map((k) => k.xpub).toSet();
    if (xpubs.length != _keystores.length) {
      setState(() => _error = 'Each cosigner must use a different key');
      return;
    }

    if (_isSingle) {
      final k = _keystores.first;
      // A bare xpub carries no script type, so hand over the policy this screen
      // shows rather than the key alone.
      final descriptor = (k.descriptor ?? '').isNotEmpty ? k.descriptor : _descriptorPreview;
      widget.onConfigured(
        WalletSetupResult.single(
          (k.mnemonic ?? '').isNotEmpty
              ? SingleSigResult(
                  scriptType: _singleHotScriptType(),
                  provider: _effectiveProvider,
                  mnemonic: k.mnemonic,
                  passphrase: k.passphrase,
                  derivationPath: _derivationPathToSubmit(k),
                )
              : SingleSigResult(
                  scriptType: _singleHotScriptType(),
                  xpubOrDescriptor: descriptor,
                  hardwareDeviceType: k.hardwareDeviceType,
                  hardwareFingerprint: k.fingerprint,
                ),
        ),
      );
      return;
    }

    setState(() => _building = true);
    try {
      final group = mlpb.MultisigGroup(
        m: _threshold,
        n: _total,
        keys: _keystores.map(
          (k) => mlpb.MultisigKey(
            xpub: k.xpub,
            derivationPath: k.derivationPath,
            fingerprint: k.fingerprint ?? '',
            originPath: k.originPath ?? '',
            isWallet: k.isWallet,
          ),
        ),
      );

      final resp = await GetIt.I.get<OrchestratorRPC>().multisigLounge.buildDescriptors(
        group,
        scriptType: _scriptType,
      );
      widget.onConfigured(
        WalletSetupResult.multisig(
          MultisigWalletSpec(
            m: _threshold,
            n: _total,
            scriptType: _scriptType,
            cosigners: List.of(_keystores),
            receiveDescriptor: resp.receiveDescriptor,
            changeDescriptor: resp.changeDescriptor,
          ),
        ),
      );
    } catch (e) {
      setState(() => _error = 'Failed to build descriptor: $e');
    } finally {
      if (mounted) {
        setState(() => _building = false);
      }
    }
  }

  // Maps the single-sig script dropdown value to the backend's hot-wallet string.
  String _singleHotScriptType() => switch (_scriptType) {
    'pkh' => 'legacy',
    'sh-wpkh' => 'nested-segwit',
    'tr' => 'taproot',
    _ => 'native-segwit',
  };

  void _setKeystore(int index, CosignerKeystore k) {
    _update(() {
      _keystores[index] = k;
      if (index == _selectedTab && !_pathFocus.hasFocus) {
        _path.text = k.derivationPath;
      }
    });
  }

  void _replaceXpub(int index, String raw) {
    final parsed = parseKeyExpression(raw);
    if (!isPlausibleXpub(parsed.xpub)) {
      setState(() => _error = 'That does not look like an xpub');
      return;
    }

    _update(() {
      _error = null;
      _keystores[index]
        ..xpub = parsed.xpub
        ..fingerprint = parsed.fingerprint
        ..originPath = parsed.originPath
        ..derivationPath = parsed.originPath == null ? '' : 'm/${parsed.originPath}';
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Center(
              child: SizedBox(
                width: 900,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        SailText.primary24('Set up your wallet', bold: true),
                        const SizedBox(height: 8),
                        SailText.secondary13(
                          _total == 1
                              ? 'Choose how this wallet holds its keys: generate or import a seed, watch an '
                                    'xpub, or use a hardware wallet.'
                              : 'Add a key for each cosigner. Software keys hold their seed on disk and sign '
                                    'here; the rest are signed elsewhere.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _keysSection(context),
                    const SizedBox(height: 24),
                    if (_settingsOpen)
                      _walletSettingsSection(context)
                    else
                      Center(
                        child: SailButton(
                          label: 'View Descriptor / Open Wallet Settings',
                          variant: ButtonVariant.ghost,
                          small: true,
                          onPressed: () async => setState(() => _settingsOpen = true),
                        ),
                      ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      SailText.secondary12(_error!, color: SailTheme.of(context).colors.error),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        _bottomBar(context),
      ],
    );
  }

  Widget _bottomBar(BuildContext context) {
    final theme = SailTheme.of(context);
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
                disabled: _restoringBackup,
                onPressed: () async => Navigator.of(context).maybePop(),
              ),
              SailButton(
                label: 'Next',
                loading: _building,
                // A restore rewrites the wallet and restarts L1; stepping on
                // through setup would race a second creation against it.
                disabled: !_allFilled || _restoringBackup,
                onPressed: () async => _next(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _walletSettingsSection(BuildContext context) {
    return SailCard(
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
                    SailText.primary16('Wallet Settings', bold: true),
                    SailText.secondary13(
                      "Advanced settings. If you don't know what these are, you can safely ignore them.",
                    ),
                  ],
                ),
              ),
              SailButton(
                label: 'Close Settings',
                variant: ButtonVariant.ghost,
                small: true,
                onPressed: () async => setState(() => _settingsOpen = false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _labeledRow('Descriptor', _descriptorField(context), alignTop: true),
          if (_descriptorError != null)
            Padding(
              padding: const EdgeInsets.only(left: 110, top: 6),
              child: SailText.secondary12(
                _descriptorError!,
                color: SailTheme.of(context).colors.error,
              ),
            ),
          const SizedBox(height: 12),
          _labeledRow('Address Type', SizedBox(width: 280, child: _scriptDropdown(context))),
          if (_addressTypeNote != null)
            Padding(
              padding: const EdgeInsets.only(left: 110, top: 6),
              child: SailText.secondary12(_addressTypeNote!),
            ),
          const SizedBox(height: 12),
          _labeledRow('Provider', SizedBox(width: 280, child: _providerDropdown(context))),
        ],
      ),
    );
  }

  // Core takes a seed, so it cannot back a watch-only or hardware key, and the
  // backend only watches multisig through Electrum.
  bool get _coreAvailable => _isSingle && _keystores.first.held;

  // Light mode runs no local node, so Bitcoin Core has nothing to talk to.
  bool get _bitcoinCoreAvailable => _coreAvailable && NodeModeProvider.runsLocalBackends;

  /// The provider a wallet would actually be created with: what was picked,
  /// unless it has stopped being on offer (a second key, a watch-only key, or
  /// light mode, which runs no local node).
  String get _effectiveProvider {
    if (!_coreAvailable) {
      return 'electrum';
    }
    if (_provider == 'core' && !_bitcoinCoreAvailable) {
      return 'electrum';
    }
    return _provider;
  }

  Widget _providerDropdown(BuildContext context) {
    return SailDropdownButton<String>(
      value: _effectiveProvider,
      enabled: _coreAvailable,
      onChanged: (v) async {
        if (v == null) {
          return;
        }
        setState(() => _provider = v);
      },
      items: [
        const SailDropdownItem<String>(value: 'electrum', label: 'Electrum'),
        if (_bitcoinCoreAvailable) const SailDropdownItem<String>(value: 'core', label: 'Bitcoin Core'),
      ],
    );
  }

  // Crossing into or out of one key swaps the whole script family, so the paths
  // and any held seed have to follow.
  Future<void> _onQuorumChanged(int m, int n) async {
    final wasSingle = _isSingle;
    _update(() {
      _total = n.clamp(1, _maxCosigners);
      _threshold = m.clamp(1, _total);
      if (wasSingle != (_total == 1)) {
        _scriptType = _total == 1 ? 'wpkh' : 'wsh';
        _addressTypeNote = null;
        _resetPendingPaths();
        // A second key brings M of N into play, so show the settings holding it.
        if (_total > 1) {
          _settingsOpen = true;
        }
      }
      _resizeKeystores();
    });
    if (wasSingle != _isSingle) {
      await _loadPathOptions();
      await _rederiveHeldKeystores();
    }
  }

  String get _quorumLabel {
    final sigs = _threshold == 1 ? '1 signature' : '$_threshold signatures';
    final keys = _total == 1 ? '1 key' : '$_total keys';
    return 'Require $sigs to move funds, out of $keys total';
  }

  // A stored path pins the coin type to the network the wallet was made on, so
  // a later switch would leave the descriptor on the old coin. Both providers
  // carry the address kind in its own field, so only a path the user typed
  // himself travels with the wallet.
  String? _derivationPathToSubmit(CosignerKeystore k) {
    return k.derivationPath == _standardPath ? null : k.derivationPath;
  }

  Widget _labeledRow(String label, Widget field, {bool alignTop = false}) {
    return Row(
      crossAxisAlignment: alignTop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: alignTop ? 8 : 0),
          child: SizedBox(width: 110, child: SailText.secondary13(label)),
        ),
        Expanded(child: field),
      ],
    );
  }

  String _addressTypeLabel(String scriptType) => _addressTypes[scriptType] ?? scriptType;

  Widget _scriptDropdown(BuildContext context) {
    final values = _isSingle ? const ['wpkh', 'tr', 'sh-wpkh', 'pkh'] : const ['wsh', 'tr', 'sh-wsh', 'sh'];
    return SailDropdownButton<String>(
      value: _scriptType,
      onChanged: (v) async {
        if (v == null) {
          return;
        }
        _update(() {
          _scriptType = v;
          _addressTypeNote = null;
          _resetPendingPaths();
        });
        await _loadPathOptions();
        await _rederiveHeldKeystores();
      },
      items: values.map((v) => SailDropdownItem<String>(value: v, label: _addressTypeLabel(v))).toList(),
    );
  }

  Widget _descriptorField(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SailTextField(
            controller: _descriptor,
            focusNode: _descriptorFocus,
            hintText: "wsh(sortedmulti(2,[fp/48'/1'/0'/2']tpub...,...))",
            size: TextFieldSize.small,
            monospace: true,
            minLines: 2,
            maxLines: 4,
            onChanged: _onDescriptorChanged,
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SailButton(
            label: 'Import file',
            variant: ButtonVariant.secondary,
            small: true,
            onPressed: () async => _importConfigFile(context),
          ),
        ),
      ],
    );
  }

  Future<void> _importConfigFile(BuildContext context) async {
    setState(() => _error = null);
    try {
      final result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['txt', 'json', 'conf'],
        dialogTitle: 'Import multisig config',
      );
      if (result == null) {
        return;
      }
      final path = result.path;
      if (path == null) {
        setState(() => _error = 'Could not read the selected file');
        return;
      }
      final fileContent = await File(path).readAsString();
      if (!context.mounted) {
        return;
      }
      await _applyConfig(context, fileContent);
    } catch (e) {
      setState(() => _error = 'Failed to import config: $e');
    }
  }

  Future<void> _applyConfig(BuildContext context, String content) async {
    final held = _keystores.where((k) => k.held).length;
    if (held > 0) {
      final ok = await showThemedDialog<bool>(
        context: context,
        builder: (context) => SailModal(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SailCard(
            title: 'Replace keys?',
            subtitle: 'This replaces all cosigners and discards $held software key(s) whose seed is held on disk.',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SailButton(
                  label: 'Cancel',
                  variant: ButtonVariant.ghost,
                  onPressed: () async => Navigator.of(context).pop(false),
                ),
                const SizedBox(width: 8),
                SailButton(
                  label: 'Replace',
                  onPressed: () async => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ),
        ),
      );
      if (ok != true) {
        return;
      }
    }

    setState(() {
      _error = null;
      _building = true;
    });
    try {
      final resp = await GetIt.I.get<OrchestratorRPC>().wallet.parseMultisigConfig(content);
      _update(() {
        // An imported config is inherently multisig; switch mode so Next builds
        // the multisig wallet instead of a single-sig one from the first leg.
        _threshold = resp.m;
        _total = resp.n;
        if (resp.scriptType.isNotEmpty) {
          _scriptType = resp.scriptType;
        }
        _keystores = resp.cosigners.asMap().entries.map((e) {
          final c = e.value;
          return CosignerKeystore(owner: 'Key ${e.key + 1}')
            ..xpub = c.xpub
            ..fingerprint = c.fingerprint.isEmpty ? null : c.fingerprint
            ..originPath = c.originPath.isEmpty ? null : c.originPath
            ..derivationPath = c.originPath.isEmpty ? '' : 'm/${c.originPath}'
            ..source = CosignerSource.xpub;
        }).toList();
        if (_selectedTab >= _total) {
          _selectedTab = _total - 1;
        }
      });
    } catch (e) {
      setState(() => _error = 'Could not parse descriptor: $e');
    } finally {
      if (mounted) {
        setState(() => _building = false);
      }
    }
  }

  Widget _keysSection(BuildContext context) {
    final theme = SailTheme.of(context);
    final k = _keystores[_selectedTab];
    return SailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary16('Keys', bold: true),
          if (_total > 1) ...[
            const SizedBox(height: 12),
            SailSlider.range(
              rangeStart: _threshold.toDouble(),
              rangeEnd: _total.toDouble(),
              min: 1,
              max: _total.toDouble(),
              divisions: _total - 1,
              label: _quorumLabel,
              onRangeChanged: (start, end) => _onQuorumChanged(start.round(), end.round()),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colors.backgroundSecondary,
                      borderRadius: theme.chrome.radius,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < _total; i++) _tabChip(context, i),
                        SailButton(
                          label: '',
                          icon: SailSVGAsset.plus,
                          variant: ButtonVariant.ghost,
                          small: true,
                          onPressed: () async => _addKey(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (k.isFilled)
            _keyDetails(context, _selectedTab, k)
          else
            SizedBox(width: double.infinity, child: _sourcePicker(context, _selectedTab)),
        ],
      ),
    );
  }

  void _addKey() {
    if (_total >= _maxCosigners) {
      return;
    }
    _update(() {
      _total += 1;
      _resizeKeystores();
      _selectedTab = _total - 1;
      if (_total == 2) {
        _threshold = 2;
        _scriptType = 'wsh';
        _resetPendingPaths();
      }
    });
    unawaited(_loadPathOptions());
    unawaited(_rederiveHeldKeystores());
  }

  void _removeKey(int index) {
    if (_total <= 1) {
      return;
    }
    _update(() {
      _keystores.removeAt(index);
      _total = _keystores.length;
      if (_threshold > _total) {
        _threshold = _total;
      }
      if (_selectedTab >= _total) {
        _selectedTab = _total - 1;
      }
      if (_total == 1) {
        _scriptType = 'wpkh';
        _resetPendingPaths();
      }
      for (var i = 0; i < _keystores.length; i++) {
        if (RegExp(r'^Key \d+$').hasMatch(_keystores[i].owner)) {
          _keystores[i].owner = 'Key ${i + 1}';
        }
      }
    });
    unawaited(_loadPathOptions());
    if (_total == 1) {
      unawaited(_rederiveHeldKeystores());
    }
  }

  // A filled key can be renamed; an empty slot has nothing to name yet.
  Widget _tabChip(BuildContext context, int i) {
    final k = _keystores[i];
    final theme = SailTheme.of(context);
    final selected = i == _selectedTab;
    // Only the open tab offers deletion and renaming, and never the last key.
    return SailTabItem(
      label: k.owner,
      isSelected: selected,
      onTap: () => _selectTab(i),
      onLabelChanged: k.isFilled ? (v) => _update(() => k.owner = v) : null,
      leading: k.isFilled ? SailSVG.icon(SailSVGAsset.iconSuccess, width: 12, color: theme.colors.success) : null,
      trailing: selected && _total > 1
          ? SailTappable(
              onTap: () async => _removeKey(i),
              child: Tooltip(
                message: 'Remove this key',
                child: Icon(Icons.delete_outline, size: 14, color: theme.colors.error),
              ),
            )
          : null,
    );
  }

  Widget _keyDetails(BuildContext context, int index, CosignerKeystore k) {
    final theme = SailTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SailText.primary16('${k.owner} Details', bold: true),
                      const SizedBox(width: 10),
                      if (k.held) ...[
                        SailSVG.icon(SailSVGAsset.iconSuccess, width: 14, color: theme.colors.success),
                        const SizedBox(width: 6),
                      ],
                      SailText.secondary13(_badgeLabel(k), color: _badgeColor(theme, k)),
                    ],
                  ),
                  SailText.secondary13('This key is added to your set. Below are the details.'),
                ],
              ),
            ),
            if (k.held)
              SailButton(
                label: 'View seed',
                variant: ButtonVariant.secondary,
                small: true,
                onPressed: () async => _viewSeed(context, k),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _derivationRow(context, index),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: SailText.secondary13('xpub')),
            Expanded(
              child: k.source == CosignerSource.xpub
                  ? SailEditableText(
                      value: k.xpub,
                      style: SailStyleValues.thirteen.copyWith(
                        fontFamily: 'IBMPlexMono',
                        color: theme.colors.textSecondary,
                      ),
                      tooltip: 'Edit the xpub',
                      editOnDoubleTap: true,
                      wrap: true,
                      onSubmitted: (v) => _replaceXpub(index, v),
                    )
                  : SailText.secondary13(k.xpub, monospace: true),
            ),
            const SizedBox(width: 8),
            CopyButton(text: k.xpub),
          ],
        ),
        if (k.fingerprint != null && k.originPath != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 110),
              SailText.secondary12('Origin: [${k.fingerprint}/${k.originPath}]'),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _viewSeed(BuildContext context, CosignerKeystore k) async {
    await showThemedDialog<void>(
      context: context,
      builder: (context) => SailModal(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SailCard(
          title: '${k.owner} seed',
          subtitle: 'Anyone with these words can spend from this key.',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SailTheme.of(context).colors.backgroundSecondary,
                  borderRadius: SailStyleValues.borderRadius,
                ),
                child: SailText.primary13(
                  k.mnemonic ?? '',
                  monospace: true,
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CopyButton(text: k.mnemonic ?? ''),
                  const SizedBox(width: 8),
                  SailButton(label: 'Close', onPressed: () async => Navigator.of(context).pop()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Only a device key is pinned: its xpub was read at the old path, so the
  // device would have to be read again.
  Widget _derivationRow(BuildContext context, int index) {
    final k = _keystores[index];
    final editable = !k.isHardware;
    final theme = SailTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 110, child: SailText.secondary13('Derivation Path')),
            Expanded(
              child: SailTextField(
                controller: _path,
                focusNode: _pathFocus,
                hintText: "m/84'/0'/0'",
                size: TextFieldSize.small,
                monospace: true,
                readOnly: !editable,
                onChanged: (v) => _onPathChanged(index, v),
              ),
            ),
            const SizedBox(width: 8),
            SailDropdownButton<String>(
              value: _pathOptions.any((o) => o.path == _path.text) ? _path.text : null,
              hint: 'Standard paths',
              enabled: editable,
              onChanged: (v) async {
                if (v == null) {
                  return;
                }
                _path.text = v;
                await _onPathChanged(index, v);
              },
              items: _pathOptions
                  .map(
                    (o) => SailDropdownItem<String>(value: o.path, label: '${o.path}   ${o.label}'),
                  )
                  .toList(),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: editable
                  ? 'The account this key comes from. Pick a standard path or type your own.'
                  : 'Remove this key to read the device at another path.',
              child: Icon(Icons.help_outline, size: 16, color: theme.colors.textSecondary),
            ),
          ],
        ),
        if (_pathError != null)
          Padding(
            padding: const EdgeInsets.only(left: 110, top: 6),
            child: SailText.secondary12(_pathError!, color: theme.colors.error),
          ),
      ],
    );
  }

  String _badgeLabel(CosignerKeystore k) {
    if (k.held) {
      return 'On disk (can sign)';
    }
    if (k.isHardware) {
      return 'Hardware (${k.hardwareDeviceType})';
    }
    return 'Watch-only';
  }

  Color _badgeColor(SailThemeData theme, CosignerKeystore k) {
    if (k.held) {
      return theme.colors.primary;
    }
    if (k.isHardware) {
      return theme.colors.success;
    }
    return theme.colors.orange;
  }

  // The one call to action on an empty wallet, so it is deliberately oversized
  // and carries a lit edge rather than reading as another secondary button.
  Widget _generateKeyButton(BuildContext context, int index) {
    final theme = SailTheme.of(context);
    final enabled = _pathError == null && !_restoringBackup;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SailTappable(
        onTap: enabled ? () async => _addSoftwareKeystore(context, index) : null,
        child: Container(
          width: 400,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.colors.orange, theme.colors.orange.withValues(alpha: 0.88)],
            ),
            border: Border.all(color: theme.colors.orange.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                color: theme.colors.orange.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SailText.primary16('Generate new seed', bold: true, color: SailColorScheme.white),
        ),
      ),
    );
  }

  // Equal weight to generating: a user who already has a seed has nowhere else
  // to put it, and the ghost row below reads as fine print.
  Widget _pasteSeedButton(BuildContext context, int index) {
    final theme = SailTheme.of(context);
    final enabled = _pathError == null && !_restoringBackup;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SailTappable(
        onTap: enabled ? () async => _addSoftwareKeystore(context, index, mode: SeedEntryMode.importExisting) : null,
        child: Container(
          width: 400,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: theme.colors.backgroundSecondary,
            border: Border.all(color: theme.colors.border),
          ),
          child: SailText.primary16('Paste seed phrase', bold: true),
        ),
      ),
    );
  }

  Widget _sourcePicker(BuildContext context, int index) {
    final theme = SailTheme.of(context);
    final links = <(String, bool, Future<void> Function())>[
      ('xPub/ Watch Only', !_restoringBackup, () async => _addFromPaste(context, index)),
      ('Import file', !_restoringBackup, () async => _addFromFile(context, index)),
      ('Scan QR', urCameraScanSupported && !_restoringBackup, () async => _addFromQr(context, index)),
      ('Hardware Wallet', _pathError == null && !_restoringBackup, () async => _addFromDevice(context, index)),
      ('Restore backup', !_restoringBackup, () async => _restoreFromBackup(context)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            _generateKeyButton(context, index),
            _pasteSeedButton(context, index),
          ],
        ),
        const SizedBox(height: 28),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: [
            for (var i = 0; i < links.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SailText.secondary13('\u00b7'),
                ),
              Opacity(
                opacity: links[i].$2 ? 1 : 0.5,
                child: SailButton(
                  label: links[i].$1,
                  variant: ButtonVariant.ghost,
                  small: true,
                  disabled: !links[i].$2,
                  onPressed: links[i].$3,
                ),
              ),
            ],
          ],
        ),
        if (!urCameraScanSupported)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SailText.secondary12(
              'Camera not available here',
              color: theme.colors.textSecondary,
            ),
          ),
      ],
    );
  }

  // Derivation path for the chosen script type (BIP48 script-type level for
  // segwit, BIP45 for legacy P2SH). The slot index is the account, so each
  // software keystore gets a distinct key.

  // The backend derives the account key material. Account = the slot index so
  // each keystore key is distinct.
  Future<wmpb.DeriveKeystoreResponse?> _derive(
    int index, {
    String? mnemonic,
    String? passphrase,
    wmpb.HardwareDeviceSelector? device,
    String? rawKey,
  }) async {
    try {
      return await GetIt.I.get<OrchestratorRPC>().wallet.deriveKeystore(
        mnemonic: mnemonic,
        passphrase: passphrase,
        device: device,
        rawKey: rawKey,
        scriptType: _isSingle ? _singleHotScriptType() : _scriptType,
        multisig: !_isSingle,
        account: index,
        derivationPath: _keystores[index].derivationPath,
      );
    } catch (e) {
      setState(() => _error = 'Failed to derive key: ${extractConnectException(e)}');
      return null;
    }
  }

  Future<void> _addSoftwareKeystore(
    BuildContext context,
    int index, {
    SeedEntryMode mode = SeedEntryMode.generate,
  }) async {
    setState(() => _error = null);
    final seed = await Navigator.of(
      context,
    ).push<SeedBackup>(MaterialPageRoute(builder: (_) => WalletBackupPage(mode: mode)));
    if (seed == null || seed.mnemonic.isEmpty) {
      return;
    }

    final derived = await _derive(index, mnemonic: seed.mnemonic, passphrase: seed.passphrase);
    if (derived == null) {
      return;
    }
    _setKeystore(
      index,
      CosignerKeystore(owner: _keystores[index].owner)
        ..xpub = derived.xpub
        ..mnemonic = seed.mnemonic
        ..passphrase = seed.passphrase.isEmpty ? null : seed.passphrase
        ..derivationPath = 'm/${derived.originPath}'
        ..originPath = derived.originPath
        ..fingerprint = derived.fingerprint
        ..descriptor = derived.descriptor.isEmpty ? null : derived.descriptor
        ..isWallet = true
        ..source = CosignerSource.software,
    );
  }

  Future<void> _addFromPaste(BuildContext context, int index) async {
    final k = await showThemedDialog<CosignerKeystore>(
      context: context,
      builder: (context) => _PasteXpubDialog(defaultOwner: 'Key ${index + 1}'),
    );
    if (k != null) {
      _setKeystore(index, k);
    }
  }

  /// Restores a whole wallet — master seed plus every sidechain wallet — from a
  /// backup file. Unlike the other sources this doesn't fill a key slot: the
  /// wallet already exists once the file lands, so it skips the rest of setup.
  Future<void> _restoreFromBackup(BuildContext context) async {
    setState(() => _error = null);
    final result = await FilePicker.pickFile(
      dialogTitle: 'Upload wallet backup',
      type: FileType.custom,
      allowedExtensions: ['zip', 'json'],
    );
    final path = result?.path;
    if (path == null) {
      return;
    }
    setState(() => _restoringBackup = true);
    widget.onRestoringChanged?.call(true);
    try {
      await restoreBitwindowWalletFromFile(File(path));
      final restored = widget.onRestored;
      if (restored != null) {
        await restored();
        return;
      }
      await GetIt.I.get<AppRouter>().replaceAll([const RootRoute()]);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to restore from backup file: ${extractConnectException(e)}';
          _restoringBackup = false;
        });
        widget.onRestoringChanged?.call(false);
      }
    }
  }

  Future<void> _addFromFile(BuildContext context, int index) async {
    setState(() => _error = null);
    try {
      final result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json', 'conf', 'txt'],
        dialogTitle: 'Select cosigner key file',
      );
      if (result == null) {
        return;
      }
      final path = result.path;
      if (path == null) {
        setState(() => _error = 'Could not read the selected file');
        return;
      }
      final content = await File(path).readAsString();
      final parsed = _parseKeyFile(content, _activeScriptType);
      if (parsed == null) {
        setState(() => _error = 'No extended public key found in that file');
        return;
      }
      _setKeystore(index, parsed..owner = parsed.owner.isEmpty ? 'Key ${index + 1}' : parsed.owner);
    } catch (e) {
      setState(() => _error = 'Failed to import file: $e');
    }
  }

  Future<void> _addFromQr(BuildContext context, int index) async {
    setState(() => _error = null);
    final key = await showKeyQrScanner(context, scriptType: _activeScriptType);
    if (key == null) {
      return;
    }
    _setKeystore(index, _keystoreFromUrKey(key, 'Key ${index + 1}', CosignerSource.qr));
  }

  Future<void> _addFromDevice(BuildContext context, int index) async {
    setState(() => _error = null);
    final device = await showHardwareDevicePicker(context);
    if (device == null) {
      return;
    }

    final derived = await _derive(
      index,
      device: wmpb.HardwareDeviceSelector(
        type: device.type,
        path: device.path,
        fingerprint: device.fingerprint,
        passphrase: hardwareDevicePassphrase(device.path),
      ),
    );
    if (derived == null) {
      return;
    }
    _setKeystore(
      index,
      CosignerKeystore(owner: device.model.isNotEmpty ? device.model : 'Key ${index + 1}')
        ..xpub = derived.xpub
        ..derivationPath = 'm/${derived.originPath}'
        ..originPath = derived.originPath
        ..fingerprint = derived.fingerprint
        ..descriptor = derived.descriptor.isEmpty ? null : derived.descriptor
        ..hardwareDeviceType = device.type
        ..isWallet = false
        ..source = CosignerSource.device,
    );
  }
}

/// Builds a keystore from a raw "[fp/origin]xpub" or bare xpub string, or null
/// if it is not a plausible extended key.
CosignerKeystore? _keystoreFromRaw(String raw, String owner) {
  final parsed = parseKeyExpression(raw);
  if (!isPlausibleXpub(parsed.xpub)) {
    return null;
  }
  return CosignerKeystore(owner: owner)
    ..xpub = parsed.xpub
    ..fingerprint = parsed.fingerprint
    ..originPath = parsed.originPath
    ..derivationPath = parsed.originPath != null ? 'm/${parsed.originPath}' : ''
    ..isWallet = false
    ..source = CosignerSource.qr;
}

/// Builds a keystore from a scanned or imported key.
CosignerKeystore _keystoreFromUrKey(UrKey key, String fallbackOwner, CosignerSource source) {
  final name = key.name ?? '';
  final origin = (key.originPath ?? '').isEmpty ? null : key.originPath;
  return CosignerKeystore(owner: name.isEmpty ? fallbackOwner : name)
    ..xpub = key.xpub
    ..fingerprint = key.fingerprint
    ..originPath = origin
    ..derivationPath = origin == null ? '' : 'm/$origin'
    ..isWallet = false
    ..source = source;
}

/// Parses a wallet export file into a keystore, or null when it holds no key.
CosignerKeystore? _parseKeyFile(String content, String scriptType) {
  try {
    final key = pickKeyForScriptType(parseWalletExportJson(content), scriptType);
    if (key == null || !isPlausibleXpub(key.xpub)) {
      return null;
    }
    return _keystoreFromUrKey(key, '', CosignerSource.file);
  } catch (_) {
    return null;
  }
}

/// Shows the finished multisig wallet's descriptors so the user can back them
/// up or import the wallet into Bitcoin Core as watch-only.
Future<void> showMultisigExportDialog(
  BuildContext context, {
  required String receive,
  required String change,
  String? coldcardConfig,
}) {
  final importCommand =
      "importdescriptors '["
      '{"desc":"$receive","active":true,"internal":false,"timestamp":"now","range":[0,999]},'
      '{"desc":"$change","active":true,"internal":true,"timestamp":"now","range":[0,999]}'
      "]'";

  Widget field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SailText.secondary13(label),
            SailButton(
              label: 'Copy',
              variant: ButtonVariant.ghost,
              small: true,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (context.mounted) {
                  showSailToast(context, 'Copied', variant: SailToastVariant.success);
                }
              },
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: SailTheme.of(context).colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: SailText.secondary12(value, monospace: true),
        ),
      ],
    );
  }

  return showThemedDialog<void>(
    context: context,
    builder: (context) => SailModal(
      constraints: const BoxConstraints(maxWidth: 640, maxHeight: 640),
      child: SailCard(
        title: 'Multisig wallet created',
        subtitle: 'Back up these descriptors. Paste the command into Bitcoin Core to watch this wallet there.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The descriptors are long, so scroll them and keep Done pinned.
            Flexible(
              child: SingleChildScrollView(
                child: SailColumn(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    field('Receive descriptor', receive),
                    field('Change descriptor', change),
                    field('Bitcoin Core import', importCommand),
                    if (coldcardConfig != null) ...[
                      field('Coldcard multisig setup', coldcardConfig),
                      SailText.secondary12(
                        'Save this and import it on the Coldcard once (Settings → Multisig Wallets → '
                        'Import). Required before the Coldcard will sign.',
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SailButton(
                          label: 'Save Coldcard file',
                          variant: ButtonVariant.secondary,
                          small: true,
                          onPressed: () async {
                            final p = await FilePicker.saveFile(
                              dialogTitle: 'Save Coldcard multisig file',
                              fileName: 'multisig-coldcard.txt',
                              bytes: Uint8List.fromList(utf8.encode(coldcardConfig)),
                              type: FileType.custom,
                              allowedExtensions: ['txt'],
                            );
                            if (p == null) {
                              return;
                            }
                            if (context.mounted) {
                              showSailToast(context, 'Saved', variant: SailToastVariant.success);
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SailButton(label: 'Done', onPressed: () async => Navigator.of(context).pop()),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Dialog to paste an xpub (optionally as "[fp/origin]xpub"), with an owner name.
class _PasteXpubDialog extends StatefulWidget {
  final String defaultOwner;
  const _PasteXpubDialog({required this.defaultOwner});

  @override
  State<_PasteXpubDialog> createState() => _PasteXpubDialogState();
}

class _PasteXpubDialogState extends State<_PasteXpubDialog> {
  late final TextEditingController _owner = TextEditingController(text: widget.defaultOwner);
  final TextEditingController _key = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _owner.dispose();
    _key.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SailModal(
      constraints: const BoxConstraints(maxWidth: 560),
      child: SailCard(
        title: 'Paste extended public key',
        subtitle: 'An xpub / Zpub, or the full [fingerprint/origin]xpub form',
        error: _error,
        child: SailColumn(
          mainAxisSize: MainAxisSize.min,
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailTextField(
              label: 'Owner name',
              controller: _owner,
              hintText: 'Cosigner name',
              size: TextFieldSize.small,
            ),
            SailTextField(
              label: 'Extended public key',
              controller: _key,
              hintText: "[d34db33f/48'/1'/0'/2']tpub...  or  tpub...",
              size: TextFieldSize.small,
              minLines: 2,
              maxLines: 4,
              suffixWidget: SailButton(
                label: 'Paste',
                variant: ButtonVariant.ghost,
                small: true,
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null) {
                    _key.text = data!.text!.trim();
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
                  label: 'Add',
                  onPressed: () async {
                    final k = _keystoreFromRaw(_key.text, _owner.text.trim());
                    if (k == null) {
                      setState(() => _error = 'That is not a valid extended public key');
                      return;
                    }
                    k.source = CosignerSource.xpub;
                    Navigator.of(context).pop(k);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
