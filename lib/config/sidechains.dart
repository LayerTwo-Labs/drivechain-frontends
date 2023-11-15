import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

abstract class Sidechain {
  String get name;
  int get slot;
  Color get color;
  SidechainType get type;

  // TODO: turn this into a function that takes a regtest/signet/whatever param
  int get rpcPort;

  String get ticker {
    return 'SC$slot';
  }

  String get binary;
}

class TestSidechain extends Sidechain {
  @override
  String name = 'Testchain';

  @override
  int slot = 0;

  @override
  Color color = SailColorScheme.orange;

  @override
  SidechainType get type => SidechainType.testChain;

  @override
  int get rpcPort => 18743;

  @override
  String get binary => 'testchaind';
}

class EthereumSidechain extends Sidechain {
  @override
  String name = 'Ethereum';

  @override
  int slot = 6;

  @override
  Color color = SailColorScheme.purple;

  @override
  SidechainType get type => SidechainType.ethereum;

  @override
  int get rpcPort => 8545;

  @override
  String get binary => 'sidegeth';
}

enum SidechainType { testChain, ethereum }

extension SidechainPaths on SidechainType {
  String confFile() {
    switch (this) {
      case SidechainType.testChain:
        return 'testchain.conf';
      case SidechainType.ethereum:
        // TODO: make this properly configurable
        return '???';
    }
  }

  String datadir() {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']; // windows!
    if (home == null) {
      throw 'unable to determine HOME location';
    }

    if (Platform.isLinux) {
      return _filePath([
        home,
        _linuxDirname(),
      ]);
    } else if (Platform.isMacOS) {
      return _filePath([
        home,
        'Library',
        'Application Support',
        _macosDirname(),
      ]);
    } else if (Platform.isWindows) {
      throw 'TODO: windows';
    } else {
      throw 'unsupported operating system: ${Platform.operatingSystem}';
    }
  }

  String _linuxDirname() {
    switch (this) {
      case SidechainType.testChain:
        return '.testchain';
      case SidechainType.ethereum:
        // TODO: correct?
        return '.ethereum';
    }
  }

  String _macosDirname() {
    switch (this) {
      case SidechainType.testChain:
        return 'Testchain';
      case SidechainType.ethereum:
        return 'Ethereum';
    }
  }
}

String _filePath(List<String> segments) {
  return segments.where((element) => element.isNotEmpty).join(Platform.pathSeparator);
}
