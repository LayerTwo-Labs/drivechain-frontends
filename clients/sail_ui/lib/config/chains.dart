import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

abstract class Chain {
  String get name;
  Color get color;
  ChainType get type;
  int get rpcPort;

  String get ticker {
    return '';
  }

  String get binary;
}

abstract class Sidechain extends Chain {
  int get slot;

  static Sidechain? fromString(String input) {
    switch (input.toLowerCase()) {
      case 'ethereum':
        return EthereumSidechain();

      case 'testchain':
        return TestSidechain();

      case 'zcash':
        return ZCashSidechain();
    }
    return null;
  }
}

class TestSidechain extends Sidechain {
  @override
  String name = 'Testchain';

  @override
  int slot = 0;

  @override
  Color color = SailColorScheme.orange;

  @override
  ChainType get type => ChainType.testchain;

  @override
  int get rpcPort => 8272;

  @override
  String get binary => 'testchaind';
}

class ZCashSidechain extends Sidechain {
  @override
  String name = 'zSide';

  @override
  int slot = 5;

  @override
  Color color = SailColorScheme.blue;

  @override
  ChainType get type => ChainType.zcash;

  @override
  int get rpcPort => 8232;

  @override
  String get binary => 'zsided';
}

class EthereumSidechain extends Sidechain {
  @override
  String name = 'EthSide';

  @override
  int slot = 6;

  @override
  Color color = SailColorScheme.purple;

  @override
  ChainType get type => ChainType.ethereum;

  @override
  int get rpcPort => 8545;

  @override
  String get binary => 'sidegeth';
}

class ParentChain extends Chain {
  @override
  String name = 'Parent Chain';

  @override
  Color color = SailColorScheme.green;

  @override
  ChainType get type => ChainType.parentchain;

  @override
  int get rpcPort => 8332;

  @override
  String get binary => 'drivechaind';
}

enum ChainType {
  parentchain,
  testchain,
  ethereum,
  zcash,
}

extension SidechainPaths on ChainType {
  String confFile() {
    switch (this) {
      case ChainType.testchain:
        return 'testchain.conf';
      case ChainType.ethereum:
        return 'config.toml';
      case ChainType.zcash:
        return 'zcash.conf';
      case ChainType.parentchain:
        return 'drivechain.conf';
    }
  }

  String logDir() {
    switch (this) {
      case ChainType.testchain:
        return filePath([datadir(), 'debug.log']);
      case ChainType.ethereum:
        return filePath([datadir(), 'ethereum.log']);
      case ChainType.zcash:
        return filePath([datadir(), 'regtest', 'debug.log']);
      case ChainType.parentchain:
        return filePath([datadir(), 'debug.log']);
    }
  }

  String datadir() {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']; // windows!
    if (home == null) {
      throw 'unable to determine HOME location';
    }

    if (Platform.isLinux) {
      return applicationDir(subdir: _linuxDirname());
    } else if (Platform.isMacOS) {
      return applicationDir(subdir: _macosDirname());
    } else if (Platform.isWindows) {
      return applicationDir(subdir: _windowsDirname());
    } else {
      throw 'unsupported operating system: ${Platform.operatingSystem}';
    }
  }

  String _linuxDirname() {
    switch (this) {
      case ChainType.testchain:
        return 'drivechain_launcher_sidechains/testchain';
      case ChainType.ethereum:
        return '.ethside';
      case ChainType.zcash:
        return '.zcash-drivechain';
      case ChainType.parentchain:
        return '.drivechain';
    }
  }

  String _macosDirname() {
    switch (this) {
      case ChainType.testchain:
        return 'drivechain_launcher_sidechains/testchain';
      case ChainType.ethereum:
        return 'EthSide';
      case ChainType.zcash:
        return 'ZcashDrivechain';
      case ChainType.parentchain:
        return 'Drivechain';
    }
  }

  String _windowsDirname() {
    switch (this) {
      case ChainType.testchain:
        return 'drivechain_launcher_sidechains/testchain';
      case ChainType.ethereum:
        return 'EthSide';
      case ChainType.zcash:
        return 'ZcashDrivechain';
      case ChainType.parentchain:
        return 'Drivechain';
    }
  }
}

String applicationDir({String? subdir}) {
  final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']; // windows!
  if (home == null) {
    throw 'unable to determine HOME location';
  }

  subdir = subdir ?? '';

  if (Platform.isLinux) {
    return filePath([
      home,
      subdir,
    ]);
  } else if (Platform.isMacOS) {
    return filePath([
      home,
      'Library',
      'Application Support',
      subdir,
    ]);
  } else if (Platform.isWindows) {
    return filePath([
      home,
      'AppData',
      'Roaming',
      subdir,
    ]);
  } else {
    throw 'unsupported operating system: ${Platform.operatingSystem}';
  }
}

/// Join a list of filepath segments based on the underlying platform
/// path separator
String filePath(List<String> segments) {
  return segments.where((element) => element.isNotEmpty).join(Platform.pathSeparator);
}
