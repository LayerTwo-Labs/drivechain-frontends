import 'dart:io';

/// The directory that replaces the user's home for every data path.
const bitwindowHomeKey = 'BITWINDOW_HOME';

/// The integer added to every fixed port.
const portOffsetKey = 'BITWINDOW_PORT_OFFSET';

/// Keeps the highest generated port, 58004 for a signet sidechain, under 65536.
const maxPortOffset = 7500;

const _defines = {
  bitwindowHomeKey: String.fromEnvironment(bitwindowHomeKey),
  portOffsetKey: String.fromEnvironment(portOffsetKey),
};

/// Reads [key] from the environment, or from --dart-define when the environment does not set it.
String _setting(Map<String, String>? env, String key) {
  final value = (env ?? Platform.environment)[key] ?? '';
  return value.isNotEmpty ? value : _defines[key]!;
}

String? _phoneHome;

/// Sets BITWINDOW_HOME for this process when the environment has none. Dart cannot read the process environment on iOS.
void setBitwindowHome(String home) => _phoneHome = home;

/// BITWINDOW_HOME, or null when it is not set.
String? bitwindowHome([Map<String, String>? env]) {
  final home = _setting(env, bitwindowHomeKey);
  if (home.isEmpty) {
    return _phoneHome;
  }
  return home;
}

/// BITWINDOW_PORT_OFFSET, or 0 when it is not set.
int portOffset([Map<String, String>? env]) {
  final raw = _setting(env, portOffsetKey);
  if (raw.isEmpty) {
    return 0;
  }
  final offset = int.tryParse(raw);
  if (offset == null || offset < 0 || offset > maxPortOffset) {
    throw FormatException('$portOffsetKey="$raw": give an integer from 0 to $maxPortOffset');
  }
  return offset;
}

/// [base] plus the port offset. A base of 0 means no port and stays 0.
int instancePort(int base, [Map<String, String>? env]) => base == 0 ? 0 : base + portOffset(env);

/// The instance settings for a child process, so a value from --dart-define reaches it too.
Map<String, String> instanceEnvironment([Map<String, String>? env]) => {
  bitwindowHomeKey: ?bitwindowHome(env),
  if (portOffset(env) != 0) portOffsetKey: '${portOffset(env)}',
};
