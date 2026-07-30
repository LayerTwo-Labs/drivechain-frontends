import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/widgets/hardware_device_picker.dart';
import 'package:bitwindow/widgets/ur_qr_scanner.dart' show urCameraScanSupported;
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sail_ui/gen/multisiglounge/v1/multisiglounge.pb.dart' as mlpb;
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

enum CosignerSource { software, xpub, file, qr, device }

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
    if (format == null) return null;
    // Coldcard needs a master fingerprint per cosigner.
    if (cosigners.any((c) => (c.fingerprint ?? '').isEmpty)) return null;
    var name = walletName.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '');
    if (name.isEmpty) name = 'multisig';
    if (name.length > 20) name = name.substring(0, 20);
    final b = StringBuffer()
      ..writeln('# Coldcard Multisig setup file')
      ..writeln('Name: $name')
      ..writeln('Policy: $m of $n')
      ..writeln('Format: $format')
      ..writeln();
    for (final c in cosigners) {
      final path = (c.originPath ?? '').isEmpty ? '' : 'm/${c.originPath}';
      if (path.isNotEmpty) b.writeln('Derivation: $path');
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
  final m = RegExp(r'^\[([0-9a-fA-F]{8})/(.+?)\](.+)$').firstMatch(trimmed);
  if (m != null) {
    return (xpub: m.group(3)!.trim(), fingerprint: m.group(1), originPath: m.group(2));
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
  const SingleSigResult({
    required this.scriptType,
    this.mnemonic,
    this.passphrase,
    this.xpubOrDescriptor,
    this.derivationPath,
    this.hardwareDeviceType,
    this.hardwareFingerprint,
  });
}

class MultisigConfigStep extends StatefulWidget {
  final void Function(WalletSetupResult result) onConfigured;

  const MultisigConfigStep({required this.onConfigured, super.key});

  @override
  State<MultisigConfigStep> createState() => _MultisigConfigStepState();
}

class _MultisigConfigStepState extends State<MultisigConfigStep> {
  static const int _maxCosigners = 15;

  String _policy = 'multi'; // single | multi
  int _threshold = 2; // m
  int _total = 3; // n
  String _scriptType = 'wsh'; // multi: wsh|sh-wsh|sh|tr; single: wpkh|sh-wpkh|pkh|tr
  int _selectedTab = 0;

  bool get _isSingle => _policy == 'single';
  bool _building = false;
  String? _error;
  late List<CosignerKeystore> _keystores;
  final TextEditingController _descriptor = TextEditingController();
  final FocusNode _descriptorFocus = FocusNode();
  final TextEditingController _path = TextEditingController();
  final FocusNode _pathFocus = FocusNode();
  List<wmpb.DerivationPathOption> _pathOptions = [];
  String? _pathError;

  @override
  void initState() {
    super.initState();
    _keystores = List.generate(_total, (i) => CosignerKeystore(owner: 'Keystore ${i + 1}'));
    _descriptor.text = _descriptorPreview;
    _descriptorFocus.addListener(() {
      if (!_descriptorFocus.hasFocus) setState(() => _descriptor.text = _descriptorPreview);
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
  Future<void> _loadPathOptions() async {
    final index = _selectedTab;
    final wmpb.ListDerivationPathsResponse paths;
    try {
      paths = await GetIt.I.get<OrchestratorRPC>().wallet.listDerivationPaths(
        scriptType: _isSingle ? _singleHotScriptType() : _scriptType,
        multisig: !_isSingle,
        account: index,
      );
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load derivation paths: ${extractConnectException(e)}');
      return;
    }
    if (!mounted || _selectedTab != index) return;
    setState(() {
      _pathOptions = paths.options;
      final k = _keystores[index];
      if (k.derivationPath.isEmpty) k.derivationPath = paths.defaultPath;
      if (!_pathFocus.hasFocus) _path.text = k.derivationPath;
      _pathError = null;
    });
  }

  bool _isCurrentPath(int index, String raw) =>
      index < _keystores.length && _keystores[index].derivationPath == raw;

  Future<void> _onPathChanged(int index, String raw) async {
    final k = _keystores[index];
    k.derivationPath = raw;
    final wmpb.ValidateDerivationPathResponse path;
    try {
      path = await GetIt.I.get<OrchestratorRPC>().wallet.validateDerivationPath(raw, multisig: !_isSingle);
    } catch (e) {
      // A response for text the user has already moved past says nothing about
      // what is in the field now.
      if (mounted && _isCurrentPath(index, raw)) setState(() => _pathError = extractConnectException(e));
      return;
    }
    if (!mounted || !_isCurrentPath(index, raw)) return;
    // A single-sig wallet is its one keystore, so a standard path names its
    // script type.
    _update(() {
      _pathError = null;
      if (_isSingle && path.scriptType.isNotEmpty) _scriptType = path.scriptType;
      // A watch-only key cannot be re-derived, so the path is simply the origin
      // the user vouches for.
      if (k.isFilled && !k.held && !k.isHardware) k.originPath = path.normalized.substring(2);
    });
    if (!k.isFilled || !k.held) return;

    final derived = await _derive(index, mnemonic: k.mnemonic, passphrase: k.passphrase);
    if (derived == null || !mounted || _keystores[index] != k || !_isCurrentPath(index, raw)) return;
    _setKeystore(
      index,
      CosignerKeystore(owner: k.owner)
        ..xpub = derived.xpub
        ..mnemonic = k.mnemonic
        ..passphrase = k.passphrase
        ..derivationPath = 'm/${derived.originPath}'
        ..originPath = derived.originPath
        ..fingerprint = derived.fingerprint
        ..descriptor = derived.descriptor.isEmpty ? null : derived.descriptor
        ..isWallet = true
        ..source = k.source,
    );
  }

  // Drops the paths the new policy's standard one should replace. A key that
  // came with its own origin keeps it.
  void _resetPendingPaths() {
    for (final k in _keystores) {
      if (k.originPath == null) k.derivationPath = '';
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
      if (!_descriptorFocus.hasFocus) _descriptor.text = _descriptorPreview;
    });
  }

  void _onSliderChanged(RangeValues v) {
    _update(() {
      _threshold = v.start.round().clamp(1, _maxCosigners);
      _total = v.end.round().clamp(1, _maxCosigners);
      if (_threshold > _total) _threshold = _total;
      _resizeKeystores();
    });
  }

  // Adopts the typed descriptor's policy. A descriptor the backend cannot read
  // leaves the settings untouched.
  Future<void> _onDescriptorChanged(String raw) async {
    if (raw.trim().isEmpty) return;
    final wmpb.ValidateDescriptorResponse policy;
    try {
      policy = await GetIt.I.get<OrchestratorRPC>().wallet.validateDescriptor(raw);
    } catch (_) {
      return;
    }
    if (!mounted || _descriptor.text != raw) return;

    _update(() {
      _error = null;
      _policy = policy.multisig ? 'multi' : 'single';
      _scriptType = policy.scriptType;
      _threshold = policy.m;
      _total = policy.n;
      final previous = List.of(_keystores);
      _keystores = policy.keys.asMap().entries.map((e) {
        final kept = previous.where((k) => k.xpub == e.value.xpub);
        if (kept.isNotEmpty) return kept.first;
        return CosignerKeystore(owner: 'Keystore ${e.key + 1}')
          ..xpub = e.value.xpub
          ..fingerprint = e.value.fingerprint.isEmpty ? null : e.value.fingerprint
          ..originPath = e.value.originPath.isEmpty ? null : e.value.originPath
          ..derivationPath = e.value.originPath.isEmpty ? '' : 'm/${e.value.originPath}'
          ..source = CosignerSource.xpub;
      }).toList();
      if (_selectedTab >= _total) _selectedTab = _total - 1;
      _resetPendingPaths();
    });
    await _loadPathOptions();
  }

  // Grow/shrink the keystore list to match n, preserving already-filled slots.
  void _resizeKeystores() {
    if (_total > _keystores.length) {
      for (var i = _keystores.length; i < _total; i++) {
        _keystores.add(CosignerKeystore(owner: 'Keystore ${i + 1}'));
      }
    } else if (_total < _keystores.length) {
      _keystores = _keystores.sublist(0, _total);
    }
    if (_selectedTab >= _total) _selectedTab = _total - 1;
  }

  String get _descriptorPreview {
    final parts = List.generate(_total, (i) {
      final k = _keystores[i];
      if (!k.isFilled) return k.owner.replaceAll(' ', '');
      if (k.fingerprint != null && k.originPath != null) return '[${k.fingerprint}/${k.originPath}]${k.xpub}';
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
      return 'tr(sortedmulti_a($_threshold,${parts.join(',')}))';
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
                  mnemonic: k.mnemonic,
                  passphrase: k.passphrase,
                  derivationPath: k.derivationPath,
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
      if (mounted) setState(() => _building = false);
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
      if (index == _selectedTab && !_pathFocus.hasFocus) _path.text = k.derivationPath;
    });
  }

  void _clearKeystore(int index) {
    _update(() => _keystores[index] = CosignerKeystore(owner: 'Keystore ${index + 1}'));
    unawaited(_loadPathOptions());
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: SizedBox(
          width: 900,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary24(_isSingle ? 'Create a wallet' : 'Create a multisig wallet', bold: true),
              const SizedBox(height: 4),
              SailText.secondary13(
                _isSingle
                    ? 'Choose how this wallet holds its key: generate or import a seed, watch an xpub, or use a '
                          'hardware wallet.'
                    : 'Add a keystore for each cosigner. Software keystores hold their seed on disk and sign here; '
                          'the rest are signed elsewhere. Importable into Bitcoin Core and Sparrow.',
              ),
              const SizedBox(height: 24),
              _settingsSection(context),
              const SizedBox(height: 24),
              _scriptPolicySection(context),
              const SizedBox(height: 24),
              _keystoresSection(context),
              if (_error != null) ...[
                const SizedBox(height: 12),
                SailText.secondary12(_error!, color: SailTheme.of(context).colors.error),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SailButton(
                    label: 'Next',
                    loading: _building,
                    disabled: !_allFilled,
                    onPressed: () async => _next(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsSection(BuildContext context) {
    return SailCard(
      title: 'Settings',
      child: Padding(
        padding: const EdgeInsets.only(top: SailStyleValues.padding08),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _labeledRow('Policy Type', _policyDropdown(context)),
                  const SizedBox(height: 12),
                  _labeledRow('Script Type', _scriptDropdown(context)),
                ],
              ),
            ),
            const SizedBox(width: 32),
            if (!_isSingle)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.secondary13('Cosigners'),
                    const SizedBox(height: 4),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: SailTheme.of(context).colors.primary,
                        thumbColor: SailTheme.of(context).colors.primary,
                      ),
                      child: RangeSlider(
                        min: 1,
                        max: _maxCosigners.toDouble(),
                        divisions: _maxCosigners - 1,
                        values: RangeValues(_threshold.toDouble(), _total.toDouble()),
                        labels: RangeLabels('$_threshold', '$_total'),
                        onChanged: _onSliderChanged,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SailText.primary15('M of N:  $_threshold / $_total', bold: true),
                  ],
                ),
              )
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _labeledRow(String label, Widget field) {
    return Row(
      children: [
        SizedBox(width: 110, child: SailText.secondary13(label)),
        Expanded(child: field),
      ],
    );
  }

  Widget _policyDropdown(BuildContext context) {
    return SailDropdownButton<String>(
      value: _policy,
      onChanged: (v) async {
        if (v == null || v == _policy) return;
        _update(() {
          _policy = v;
          if (_isSingle) {
            _threshold = 1;
            _total = 1;
            _scriptType = 'wpkh';
          } else {
            _threshold = 2;
            _total = 3;
            _scriptType = 'wsh';
          }
          _selectedTab = 0;
          _resizeKeystores();
          _resetPendingPaths();
        });
        await _loadPathOptions();
      },
      items: const [
        SailDropdownItem<String>(value: 'single', label: 'Single Signature'),
        SailDropdownItem<String>(value: 'multi', label: 'Multi Signature'),
      ],
    );
  }

  Widget _scriptDropdown(BuildContext context) {
    final items = _isSingle
        ? const [
            SailDropdownItem<String>(value: 'wpkh', label: 'Native Segwit (P2WPKH)'),
            SailDropdownItem<String>(value: 'tr', label: 'Taproot (P2TR)'),
            SailDropdownItem<String>(value: 'sh-wpkh', label: 'Nested Segwit (P2SH-P2WPKH)'),
            SailDropdownItem<String>(value: 'pkh', label: 'Legacy (P2PKH)'),
          ]
        : const [
            SailDropdownItem<String>(value: 'wsh', label: 'Native Segwit (P2WSH)'),
            SailDropdownItem<String>(value: 'tr', label: 'Taproot (P2TR)'),
            SailDropdownItem<String>(value: 'sh-wsh', label: 'Nested Segwit (P2SH-P2WSH)'),
            SailDropdownItem<String>(value: 'sh', label: 'Legacy (P2SH)'),
          ];
    return SailDropdownButton<String>(
      value: _scriptType,
      onChanged: (v) async {
        if (v == null) return;
        _update(() {
          _scriptType = v;
          _resetPendingPaths();
        });
        await _loadPathOptions();
      },
      items: items,
    );
  }

  Widget _scriptPolicySection(BuildContext context) {
    return SailCard(
      title: 'Script Policy',
      child: Padding(
        padding: const EdgeInsets.only(top: SailStyleValues.padding08),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(width: 110, child: SailText.secondary13('Descriptor')),
            ),
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
        ),
      ),
    );
  }

  Future<void> _importConfigFile(BuildContext context) async {
    setState(() => _error = null);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'json', 'conf'],
        dialogTitle: 'Import multisig config',
      );
      if (result == null || result.files.isEmpty) return;
      final path = result.files.first.path;
      if (path == null) {
        setState(() => _error = 'Could not read the selected file');
        return;
      }
      final fileContent = await File(path).readAsString();
      if (!context.mounted) return;
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
            title: 'Replace keystores?',
            subtitle: 'This replaces all cosigners and discards $held software keystore(s) whose seed is held on disk.',
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
      if (ok != true) return;
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
        _policy = 'multi';
        _threshold = resp.m;
        _total = resp.n;
        if (resp.scriptType.isNotEmpty) _scriptType = resp.scriptType;
        _keystores = resp.cosigners.asMap().entries.map((e) {
          final c = e.value;
          return CosignerKeystore(owner: 'Keystore ${e.key + 1}')
            ..xpub = c.xpub
            ..fingerprint = c.fingerprint.isEmpty ? null : c.fingerprint
            ..originPath = c.originPath.isEmpty ? null : c.originPath
            ..derivationPath = c.originPath.isEmpty ? '' : 'm/${c.originPath}'
            ..source = CosignerSource.xpub;
        }).toList();
        if (_selectedTab >= _total) _selectedTab = _total - 1;
      });
    } catch (e) {
      setState(() => _error = 'Could not parse descriptor: $e');
    } finally {
      if (mounted) setState(() => _building = false);
    }
  }

  Widget _keystoresSection(BuildContext context) {
    return SailCard(
      title: 'Keystores',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(_total, (i) => _tabChip(context, i)),
          ),
          const SizedBox(height: 16),
          _keystoreBody(context, _selectedTab),
        ],
      ),
    );
  }

  Widget _tabChip(BuildContext context, int i) {
    final selected = i == _selectedTab;
    final filled = _keystores[i].isFilled;
    final theme = SailTheme.of(context);
    return SailTappable(
      onTap: () async => _selectTab(i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? theme.colors.primary.withValues(alpha: 0.12) : theme.colors.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? theme.colors.primary : theme.colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (filled) ...[
              SailSVG.icon(SailSVGAsset.iconSuccess, width: 12, color: theme.colors.success),
              const SizedBox(width: 6),
            ],
            SailText.secondary13('Keystore ${i + 1}'),
          ],
        ),
      ),
    );
  }

  Widget _keystoreBody(BuildContext context, int index) {
    final k = _keystores[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _derivationRow(context, index),
        const SizedBox(height: 16),
        if (k.isFilled) _filledKeystore(context, index, k) else _sourcePicker(context, index),
      ],
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
            SizedBox(width: 110, child: SailText.secondary13('Derivation:')),
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
                if (v == null) return;
                _path.text = v;
                await _onPathChanged(index, v);
              },
              items: _pathOptions
                  .map((o) => SailDropdownItem<String>(value: o.path, label: '${o.path}   ${o.label}'))
                  .toList(),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: editable
                  ? 'The account this key comes from. Pick a standard path or type your own.'
                  : 'Remove this keystore to read the device at another path.',
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
    if (k.held) return 'On disk (can sign)';
    if (k.isHardware) return 'Hardware (${k.hardwareDeviceType})';
    return 'Watch-only';
  }

  Color _badgeColor(SailThemeData theme, CosignerKeystore k) {
    if (k.held) return theme.colors.primary;
    if (k.isHardware) return theme.colors.success;
    return theme.colors.orange;
  }

  Widget _filledKeystore(BuildContext context, int index, CosignerKeystore k) {
    final theme = SailTheme.of(context);
    return SailCard(
      shadowSize: ShadowSize.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SailText.primary15(k.owner, bold: true),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _badgeColor(theme, k).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SailText.secondary12(_badgeLabel(k), color: _badgeColor(theme, k)),
                  ),
                ],
              ),
              SailButton(
                label: 'Remove',
                variant: ButtonVariant.ghost,
                small: true,
                onPressed: () async => _clearKeystore(index),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (k.fingerprint != null && k.originPath != null)
            SailText.secondary12('Origin: [${k.fingerprint}/${k.originPath}]'),
          SailText.secondary12('xPub: ${k.xpub}', monospace: true),
        ],
      ),
    );
  }

  Widget _sourcePicker(BuildContext context, int index) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _sourceCard(
          context,
          icon: SailSVGAsset.iconWallet,
          title: 'Create New Software Wallet',
          subtitle: 'Generate or import a seed, held on disk to sign',
          enabled: _pathError == null,
          onTap: () async => _addSoftwareKeystore(context, index),
        ),
        _sourceCard(
          context,
          icon: SailSVGAsset.iconSearch,
          title: 'xPub / Watch Only',
          subtitle: 'Paste an extended public key',
          onTap: () async => _addFromPaste(context, index),
        ),
        _sourceCard(
          context,
          icon: SailSVGAsset.iconRestart,
          title: 'Import File',
          subtitle: 'Coldcard / JSON export',
          onTap: () async => _addFromFile(context, index),
        ),
        _sourceCard(
          context,
          icon: SailSVGAsset.iconWallet,
          title: 'Scan QR',
          subtitle: urCameraScanSupported ? 'Airgapped key QR' : 'Camera not available here',
          enabled: urCameraScanSupported,
          onTap: () async => _addFromQr(context, index),
        ),
        _sourceCard(
          context,
          icon: SailSVGAsset.iconWallet,
          title: 'Hardware Wallet',
          subtitle: 'Trezor, Ledger, Coldcard over USB',
          enabled: _pathError == null,
          onTap: () async => _addFromDevice(context, index),
        ),
      ],
    );
  }

  Widget _sourceCard(
    BuildContext context, {
    required SailSVGAsset icon,
    required String title,
    required String subtitle,
    required Future<void> Function() onTap,
    bool enabled = true,
  }) {
    final theme = SailTheme.of(context);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SailTappable(
        onTap: enabled ? () async => onTap() : null,
        child: Container(
          width: 190,
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SailSVG.icon(icon, width: 28, color: theme.colors.text),
              const SizedBox(height: 12),
              SailText.primary13(title, bold: true),
              const SizedBox(height: 4),
              SailText.secondary12(subtitle, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
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

  Future<void> _addSoftwareKeystore(BuildContext context, int index) async {
    setState(() => _error = null);
    final seed = await showThemedDialog<SoftwareSeed>(
      context: context,
      builder: (context) => const _SoftwareKeystoreDialog(),
    );
    if (seed == null || seed.mnemonic.isEmpty) return;

    final derived = await _derive(index, mnemonic: seed.mnemonic, passphrase: seed.passphrase);
    if (derived == null) return;
    _setKeystore(
      index,
      CosignerKeystore(owner: 'Keystore ${index + 1}')
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
      builder: (context) => _PasteXpubDialog(defaultOwner: 'Keystore ${index + 1}'),
    );
    if (k != null) _setKeystore(index, k);
  }

  Future<void> _addFromFile(BuildContext context, int index) async {
    setState(() => _error = null);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'conf', 'txt'],
        dialogTitle: 'Select cosigner key file',
      );
      if (result == null || result.files.isEmpty) return;
      final path = result.files.first.path;
      if (path == null) {
        setState(() => _error = 'Could not read the selected file');
        return;
      }
      final content = await File(path).readAsString();
      final parsed = _parseKeyFile(content);
      if (parsed == null) {
        setState(() => _error = 'No extended public key found in that file');
        return;
      }
      _setKeystore(
        index,
        parsed..owner = parsed.owner.isEmpty ? 'Keystore ${index + 1}' : parsed.owner,
      );
    } catch (e) {
      setState(() => _error = 'Failed to import file: $e');
    }
  }

  Future<void> _addFromQr(BuildContext context, int index) async {
    final raw = await showThemedDialog<String>(
      context: context,
      builder: (context) => const _XpubQrScannerDialog(),
    );
    if (raw == null) return;
    final k = _keystoreFromRaw(raw, 'Keystore ${index + 1}');
    if (k == null) {
      setState(() => _error = 'Scanned code is not an extended public key');
      return;
    }
    _setKeystore(index, k);
  }

  Future<void> _addFromDevice(BuildContext context, int index) async {
    setState(() => _error = null);
    final device = await showHardwareDevicePicker(context);
    if (device == null) return;

    final derived = await _derive(
      index,
      device: wmpb.HardwareDeviceSelector(
        type: device.type,
        path: device.path,
        fingerprint: device.fingerprint,
        passphrase: hardwareDevicePassphrase(device.path),
      ),
    );
    if (derived == null) return;
    _setKeystore(
      index,
      CosignerKeystore(owner: device.model.isNotEmpty ? device.model : 'Keystore ${index + 1}')
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
  if (!isPlausibleXpub(parsed.xpub)) return null;
  return CosignerKeystore(owner: owner)
    ..xpub = parsed.xpub
    ..fingerprint = parsed.fingerprint
    ..originPath = parsed.originPath
    ..derivationPath = parsed.originPath != null ? 'm/${parsed.originPath}' : ''
    ..isWallet = false
    ..source = CosignerSource.qr;
}

/// Parses a JSON key export (Coldcard-style fields) into a keystore, or null.
CosignerKeystore? _parseKeyFile(String content) {
  try {
    final json = jsonDecode(content) as Map<String, dynamic>;
    final xpub = (json['xpub'] ?? json['extended_public_key'] ?? json['pubkey'] ?? '') as String;
    if (!isPlausibleXpub(xpub)) return null;
    final path = (json['path'] ?? json['derivation_path'] ?? json['bip32_path'] ?? '') as String;
    final origin =
        (json['origin_path'] ?? json['origin'] ?? (path.startsWith('m/') ? path.substring(2) : path)) as String;
    return CosignerKeystore(owner: (json['owner'] ?? json['name'] ?? '') as String)
      ..xpub = xpub
      ..derivationPath = path
      ..originPath = origin.isEmpty ? null : origin
      ..fingerprint = (json['fingerprint'] ?? json['master_fingerprint']) as String?
      ..isWallet = false
      ..source = CosignerSource.file;
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
                              type: FileType.custom,
                              allowedExtensions: ['txt'],
                            );
                            if (p == null) return;
                            await File(p).writeAsString(coldcardConfig);
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

/// A software keystore's seed and optional BIP39 passphrase.
class SoftwareSeed {
  final String mnemonic;
  final String passphrase;
  const SoftwareSeed(this.mnemonic, this.passphrase);
}

/// Dialog to add a software keystore: generate a fresh seed (shown once for
/// backup) or import an existing one, with an optional BIP39 passphrase.
class _SoftwareKeystoreDialog extends StatefulWidget {
  const _SoftwareKeystoreDialog();

  @override
  State<_SoftwareKeystoreDialog> createState() => _SoftwareKeystoreDialogState();
}

class _SoftwareKeystoreDialogState extends State<_SoftwareKeystoreDialog> {
  HDWalletProvider get _hd => GetIt.I.get<HDWalletProvider>();
  WalletWriterProvider get _writer => GetIt.I.get<WalletWriterProvider>();
  final TextEditingController _import = TextEditingController();
  final TextEditingController _passphrase = TextEditingController();
  final TextEditingController _entropy = TextEditingController();
  String? _generated;
  bool _busy = false;
  bool _paranoid = false;
  bool _isHexMode = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _import.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _import.dispose();
    _passphrase.dispose();
    _entropy.dispose();
    super.dispose();
  }

  Widget _passphraseField() {
    return SailTextField(
      label: 'BIP39 passphrase (optional)',
      controller: _passphrase,
      hintText: 'Leave blank for none',
      size: TextFieldSize.small,
    );
  }

  bool _isValidMnemonic(String s) {
    final words = s.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    return const {12, 15, 18, 21, 24}.contains(words.length);
  }

  Future<void> _generate() async {
    setState(() => _busy = true);
    try {
      final m = await _hd.generateRandomMnemonic();
      if (m.isEmpty) {
        setState(() => _error = 'Failed to generate a seed');
        return;
      }
      setState(() => _generated = m);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  List<int> _entropyFromHex(String s) {
    final padded = s.trim().padRight(((s.length + 31) ~/ 32) * 32, '0');
    return hex.decode(padded);
  }

  Future<void> _createFromEntropy() async {
    final input = _entropy.text.trim();
    if (input.isEmpty) {
      setState(() => _error = 'Enter some entropy first');
      return;
    }
    if (_isHexMode && (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(input) || input.length > 64)) {
      setState(() => _error = 'Enter up to 64 hex characters (0-9, A-F)');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final entropy = _isHexMode ? _entropyFromHex(input) : sha256.convert(utf8.encode(input)).bytes.sublist(0, 16);
      final wallet = await _writer.generateWalletFromEntropy(entropy, doNotSave: true);
      final m = wallet['mnemonic'] as String?;
      if (m == null || m.isEmpty) {
        setState(() => _error = 'Failed to derive a seed from that entropy');
        return;
      }
      setState(() => _generated = m);
    } catch (e) {
      setState(() => _error = 'Error deriving seed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _randomEntropy() {
    final rng = Random.secure();
    final bytes = List.generate(16, (_) => rng.nextInt(256));
    setState(() {
      _isHexMode = true;
      _entropy.text = hex.encode(bytes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailModal(
      constraints: const BoxConstraints(maxWidth: 560),
      child: SailCard(
        title: 'Software keystore',
        subtitle: 'The seed is stored on disk so this wallet can sign for this cosigner.',
        error: _error,
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_generated == null && !_paranoid) ...[
              SailTextField(
                label: 'Import an existing seed phrase',
                controller: _import,
                hintText: 'word1 word2 word3 ...  (12 or 24 words)',
                size: TextFieldSize.small,
                minLines: 2,
                maxLines: 3,
              ),
              _passphraseField(),
              Row(
                children: [
                  SailButton(
                    label: 'Generate new seed',
                    variant: ButtonVariant.primary,
                    loading: _busy,
                    onPressed: () async => _generate(),
                  ),
                  const SizedBox(width: 8),
                  SailButton(
                    label: 'Paranoid mode',
                    variant: ButtonVariant.ghost,
                    onPressed: () async => setState(() {
                      _paranoid = true;
                      _error = null;
                    }),
                  ),
                  const Spacer(),
                  SailButton(
                    label: 'Import',
                    variant: ButtonVariant.secondary,
                    disabled: !_isValidMnemonic(_import.text),
                    onPressed: () async {
                      if (!_isValidMnemonic(_import.text)) {
                        setState(() => _error = 'Enter a 12 or 24-word seed phrase');
                        return;
                      }
                      Navigator.of(
                        context,
                      ).pop(SoftwareSeed(_import.text.trim(), _passphrase.text));
                    },
                  ),
                ],
              ),
            ] else if (_generated == null && _paranoid) ...[
              SailText.secondary13(
                'Provide your own entropy instead of trusting the generator. This becomes your seed.',
              ),
              Row(
                children: [
                  SailText.primary13('Custom entropy'),
                  const SizedBox(width: 12),
                  SailCheckbox(
                    value: _isHexMode,
                    onChanged: (v) => setState(() {
                      _isHexMode = v;
                      _entropy.clear();
                    }),
                    label: 'Hex',
                  ),
                ],
              ),
              SailTextField(
                controller: _entropy,
                hintText: _isHexMode ? 'Up to 64 hex characters (16-32 bytes)' : 'Type text to hash into entropy',
                size: TextFieldSize.small,
              ),
              _passphraseField(),
              Row(
                children: [
                  SailButton(
                    label: 'Back',
                    variant: ButtonVariant.ghost,
                    onPressed: () async => setState(() {
                      _paranoid = false;
                      _error = null;
                    }),
                  ),
                  const SizedBox(width: 8),
                  SailButton(
                    label: 'Random',
                    variant: ButtonVariant.secondary,
                    onPressed: () async => _randomEntropy(),
                  ),
                  const Spacer(),
                  SailButton(
                    label: 'Create seed',
                    loading: _busy,
                    onPressed: () async => _createFromEntropy(),
                  ),
                ],
              ),
            ] else ...[
              SailText.secondary13(
                "Write these words down and keep them safe — they control this cosigner's funds.",
                color: SailTheme.of(context).colors.orange,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SailTheme.of(context).colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SailText.primary13(_generated!, monospace: true, overflow: TextOverflow.visible),
              ),
              _passphraseField(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SailButton(
                    label: 'Back',
                    variant: ButtonVariant.ghost,
                    onPressed: () async => setState(() => _generated = null),
                  ),
                  const SizedBox(width: 8),
                  SailButton(
                    label: 'Use this seed',
                    onPressed: () async => Navigator.of(context).pop(SoftwareSeed(_generated!, _passphrase.text)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
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
                  if (data?.text != null) _key.text = data!.text!.trim();
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

/// Dialog that scans a single QR frame containing an xpub or descriptor string.
class _XpubQrScannerDialog extends StatefulWidget {
  const _XpubQrScannerDialog();

  @override
  State<_XpubQrScannerDialog> createState() => _XpubQrScannerDialogState();
}

class _XpubQrScannerDialogState extends State<_XpubQrScannerDialog> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      if (raw == null || raw.isEmpty) continue;
      _done = true;
      Navigator.of(context).pop(raw.trim());
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SailModal(
      constraints: const BoxConstraints(maxWidth: 420),
      child: SailCard(
        title: 'Scan key QR',
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (urCameraScanSupported)
              SizedBox(
                width: 320,
                height: 320,
                child: MobileScanner(controller: _controller, onDetect: _onDetect),
              )
            else
              SailText.secondary13('Camera scanning is not available on this platform.'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SailButton(
                  label: 'Cancel',
                  variant: ButtonVariant.ghost,
                  onPressed: () async => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
