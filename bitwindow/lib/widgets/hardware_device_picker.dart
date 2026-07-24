import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

/// Enumeration started ahead of the picker opening, plus the last devices seen.
Future<List<wmpb.HardwareDevice>>? _prefetch;
List<wmpb.HardwareDevice> _lastDevices = [];

/// True while a PIN/passphrase prompt is in progress; enumeration is suppressed.
bool _pinFlowActive = false;

/// Passphrase entered for a device, keyed by path. Callers thread it into the
/// selector so later device ops open the same passphrase wallet.
final Map<String, String> _devicePassphrases = {};

/// The passphrase entered for a picked device, or empty.
String hardwareDevicePassphrase(String path) => _devicePassphrases[path] ?? '';

/// Starts a device enumeration now so the picker can show devices immediately.
void prefetchHardwareDevices() {
  if (_pinFlowActive) return;
  final f = GetIt.I.get<OrchestratorRPC>().wallet.enumerateHardwareDevices();
  _prefetch = f;
  f.then((d) => _lastDevices = d).catchError((_) => <wmpb.HardwareDevice>[]);
}

/// Shows the hardware-device picker and returns the chosen device, or null.
Future<wmpb.HardwareDevice?> showHardwareDevicePicker(BuildContext context) {
  return showThemedDialog<wmpb.HardwareDevice>(
    context: context,
    builder: (context) => const HardwareDevicePicker(),
  );
}

/// Enumerates connected USB hardware wallets and returns the picked device
/// (or null on cancel).
class HardwareDevicePicker extends StatefulWidget {
  const HardwareDevicePicker({super.key});

  @override
  State<HardwareDevicePicker> createState() => _HardwareDevicePickerState();
}

class _HardwareDevicePickerState extends State<HardwareDevicePicker> {
  bool _loading = true;
  String? _error;
  String? _status;
  List<wmpb.HardwareDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    if (GetIt.I.isRegistered<HwiProvider>()) {
      final hwi = GetIt.I.get<HwiProvider>();
      hwi.suspended = true; // pause the 5s poll while we hold the device
      if (hwi.devices.isNotEmpty) _devices = hwi.devices;
    }
    _init();
  }

  @override
  void dispose() {
    if (GetIt.I.isRegistered<HwiProvider>()) {
      final hwi = GetIt.I.get<HwiProvider>();
      hwi.suspended = false;
      hwi.fetch();
    }
    super.dispose();
  }

  Future<void> _init() async {
    // Show the prefetched / last-known devices instantly (no spinner) ...
    if (_lastDevices.isNotEmpty) {
      setState(() {
        _devices = _lastDevices;
        _loading = false;
      });
    } else if (_prefetch != null) {
      try {
        final d = await _prefetch!;
        if (mounted) {
          setState(() {
            _devices = d;
            _loading = false;
          });
        }
      } catch (_) {
        // ignored; the background refresh reports any real error
      }
    }
    // ... then always refresh in the background so a just-plugged-in or
    // just-unlocked device appears.
    await _enumerate(background: _devices.isNotEmpty);
    // One locked device: go straight to the PIN prompt, no list to tap through.
    if (mounted && !_pinFlowActive && _devices.length == 1 && _isLocked(_devices.single)) {
      await _unlock(_devices.single);
    }
  }

  Future<void> _enumerate({bool background = false}) async {
    if (_pinFlowActive) return; // don't touch the device mid-PIN prompt
    if (!background) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final devices = await GetIt.I.get<OrchestratorRPC>().wallet.enumerateHardwareDevices();
      _lastDevices = devices;
      if (!mounted) return;
      setState(() {
        _devices = devices;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyError(e);
        _loading = false;
      });
    }
  }

  String _friendlyError(Object e) {
    final s = '$e'.trim();
    if (s.isEmpty || s.length > 160) {
      return 'Error scanning — check the device is connected and unlocked.';
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return SailModal(
      constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
      child: SailCard(
        title: 'Connect hardware wallet',
        subtitle: 'Unlock your device and select it',
        error: _error,
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_loading)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Center(child: LoadingIndicator()),
                    if (_status != null) ...[
                      const SizedBox(height: 12),
                      SailText.secondary13(_status!, textAlign: TextAlign.center),
                    ],
                  ],
                ),
              )
            else if (_devices.isEmpty)
              SailText.secondary13('No devices found. Unlock the device and reconnect it.')
            else
              ..._devices.map((d) => _deviceTile(context, d)),
            SailRow(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: SailStyleValues.padding08,
              children: [
                SailButton(
                  label: 'Rescan',
                  variant: ButtonVariant.secondary,
                  loading: _loading,
                  onPressed: () async => _enumerate(),
                ),
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

  bool _isLocked(wmpb.HardwareDevice d) {
    if (d.needsPin) return true;
    final e = d.error.toLowerCase();
    return e.contains('lock') || e.contains('promptpin') || e.contains('pin');
  }

  bool _isUninitialized(wmpb.HardwareDevice d) => d.errorCode == -18;

  bool _isBusy(wmpb.HardwareDevice d) => d.errorCode == -12 && !_isLocked(d);

  Future<void> _unlock(wmpb.HardwareDevice d) async {
    final wallet = GetIt.I.get<OrchestratorRPC>().wallet;
    final sel = wmpb.HardwareDeviceSelector(type: d.type, path: d.path);
    _pinFlowActive = true; // suppress enumeration until the flow ends
    while (true) {
      setState(() {
        _loading = true;
        _status = 'Look at your device — confirm the PIN prompt';
      });
      try {
        await wallet.promptDevicePin(device: sel); // device shows the matrix
      } catch (e) {
        _pinFlowActive = false;
        if (mounted) {
          setState(() {
            _loading = false;
            _status = null;
            _error = 'Could not prompt for PIN: $e';
          });
        }
        return;
      }
      if (!mounted) {
        _pinFlowActive = false;
        return;
      }
      setState(() {
        _loading = false;
        _status = null;
      });
      final pin = await showThemedDialog<String>(context: context, builder: (context) => const TrezorPinDialog());
      if (pin == null || pin.isEmpty) {
        try {
          await wallet.closeDevice(device: sel);
        } catch (_) {}
        _pinFlowActive = false;
        if (mounted) setState(() => _status = null);
        await _enumerate();
        return;
      }
      setState(() {
        _loading = true;
        _status = 'Unlocking…';
      });
      try {
        await wallet.sendDevicePin(device: sel, pin: pin);
      } catch (_) {
        if (!mounted) {
          _pinFlowActive = false;
          return;
        }
        setState(() {
          _loading = false;
          _status = null;
          _error = 'Incorrect PIN — try again';
        });
        continue; // re-prompt for a fresh matrix
      }
      _pinFlowActive = false;
      _status = null;
      // Auto-select the just-unlocked device so the caller acts before re-lock.
      final devices = await wallet.enumerateHardwareDevices();
      final unlocked = devices.firstWhere((x) => x.path == d.path, orElse: () => d);
      if (mounted) Navigator.of(context).pop(unlocked);
      return;
    }
  }

  Future<void> _enterPassphrase(wmpb.HardwareDevice d) async {
    final wallet = GetIt.I.get<OrchestratorRPC>().wallet;
    final pass = await showThemedDialog<String>(context: context, builder: (context) => const DevicePassphraseDialog());
    if (pass == null) return;
    _pinFlowActive = true;
    setState(() {
      _loading = true;
      _error = null;
      _status = 'Confirming passphrase…';
    });
    try {
      final devices = await wallet.enumerateHardwareDevices(passphrase: pass);
      _pinFlowActive = false;
      wmpb.HardwareDevice? match;
      for (final x in devices) {
        if (x.path == d.path) {
          match = x;
          break;
        }
      }
      if (!mounted) return;
      if (match == null || match.fingerprint.isEmpty) {
        setState(() {
          _loading = false;
          _status = null;
          _error = 'Could not confirm passphrase — check it and try again.';
        });
        return;
      }
      _devicePassphrases[match.path] = pass;
      Navigator.of(context).pop(match);
    } catch (e) {
      _pinFlowActive = false;
      if (!mounted) return;
      setState(() {
        _loading = false;
        _status = null;
        _error = _friendlyError(e);
      });
    }
  }

  Widget _deviceTile(BuildContext context, wmpb.HardwareDevice d) {
    final theme = SailTheme.of(context);
    final locked = _isLocked(d);
    final needsPass = d.needsPassphrase && !locked;
    final uninitialized = _isUninitialized(d);
    final busy = _isBusy(d);
    final blocked = d.error.isNotEmpty && !locked && !needsPass && !uninitialized && !busy;
    final selectable = !uninitialized && !busy && !blocked;

    String? hint;
    if (locked) {
      hint = 'Locked — tap to unlock';
    } else if (needsPass) {
      hint = 'Passphrase required — tap to enter';
    } else if (uninitialized) {
      hint = 'Not initialized — set up the device first';
    } else if (busy) {
      hint = 'Busy — reconnect, then Rescan';
    } else if (blocked) {
      hint = d.error;
    }

    return SailTappable(
      onTap: !selectable
          ? null
          : () async {
              if (locked) return _unlock(d);
              if (needsPass) return _enterPassphrase(d);
              Navigator.of(context).pop(d);
            },
      child: Opacity(
        opacity: selectable ? 1 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colors.background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: theme.colors.border),
          ),
          child: Row(
            children: [
              SailSVG.icon(SailSVGAsset.iconWallet, width: 18, color: theme.colors.text),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary13(d.model.isNotEmpty ? d.model : d.type, bold: true),
                    if (d.fingerprint.isNotEmpty)
                      SailText.secondary12('Fingerprint: ${d.fingerprint}', monospace: true),
                    if (hint != null) SailText.secondary12(hint, color: theme.colors.orange),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Collects a BIP39 passphrase for a passphrase-protected device.
class DevicePassphraseDialog extends StatefulWidget {
  const DevicePassphraseDialog({super.key});

  @override
  State<DevicePassphraseDialog> createState() => _DevicePassphraseDialogState();
}

class _DevicePassphraseDialogState extends State<DevicePassphraseDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SailModal(
      constraints: const BoxConstraints(maxWidth: 380),
      child: SailCard(
        title: 'Enter passphrase',
        subtitle: 'The BIP39 passphrase selects which hidden wallet to open.',
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SailTextField(
              controller: _controller,
              hintText: 'Passphrase',
              obscureText: true,
              textFieldType: TextFieldType.text,
            ),
            SailRow(
              spacing: SailStyleValues.padding08,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SailButton(
                  label: 'Cancel',
                  variant: ButtonVariant.ghost,
                  onPressed: () async => Navigator.of(context).pop(),
                ),
                SailButton(
                  label: 'Confirm',
                  onPressed: () async => Navigator.of(context).pop(_controller.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrambled 3×3 PIN matrix. The user clicks positions matching the device's
/// layout; the picked positions (not digits) unlock it.
class TrezorPinDialog extends StatefulWidget {
  const TrezorPinDialog({super.key});

  @override
  State<TrezorPinDialog> createState() => _TrezorPinDialogState();
}

class _TrezorPinDialogState extends State<TrezorPinDialog> {
  String _pin = '';
  // Numpad layout: 7-8-9 top row down to 1-2-3.
  static const _rows = [
    [7, 8, 9],
    [4, 5, 6],
    [1, 2, 3],
  ];

  @override
  Widget build(BuildContext context) {
    return SailModal(
      constraints: const BoxConstraints(maxWidth: 340),
      child: SailCard(
        title: 'Enter device PIN',
        subtitle: 'Click the positions matching the scrambled digits shown on your device.',
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: SailText.primary24(_pin.isEmpty ? ' ' : '•' * _pin.length)),
            for (final row in _rows)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final pos in row)
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: SizedBox(
                        width: 64,
                        height: 56,
                        child: SailButton(
                          label: '•',
                          variant: ButtonVariant.secondary,
                          onPressed: () async => setState(() => _pin += '$pos'),
                        ),
                      ),
                    ),
                ],
              ),
            SailRow(
              spacing: SailStyleValues.padding08,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SailButton(
                  label: 'Clear',
                  variant: ButtonVariant.ghost,
                  onPressed: () async => setState(() => _pin = ''),
                ),
                SailButton(
                  label: 'Cancel',
                  variant: ButtonVariant.ghost,
                  onPressed: () async => Navigator.of(context).pop(),
                ),
                SailButton(
                  label: 'Unlock',
                  disabled: _pin.isEmpty,
                  onPressed: () async => Navigator.of(context).pop(_pin),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
