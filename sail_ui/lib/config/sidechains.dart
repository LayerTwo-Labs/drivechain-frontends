import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

abstract class Sidechain extends Binary {
  Sidechain({
    required super.name,
    required super.version,
    required super.description,
    required super.repoUrl,
    required super.directories,
    required super.metadata,
    required super.binary,
    required super.network,
    required super.chainLayer,
  });

  int get slot;

  static Sidechain? fromString(String input) {
    switch (input.toLowerCase()) {
      case 'testchain':
        return TestSidechain();

      case 'zcash':
        return ZCash();

      case 'thunder':
        return Thunder();

      case 'bitnames':
        return Bitnames();

      case 'bitassets':
        return BitAssets();
    }
    return null;
  }

  static Sidechain fromBinary(Binary binary) {
    switch (binary.name) {
      case 'Test Sidechain':
        return TestSidechain(
          name: binary.name,
          version: binary.version,
          description: binary.description,
          repoUrl: binary.repoUrl,
          directories: binary.directories,
          metadata: binary.metadata,
          binary: binary.binary,
          network: binary.network,
          chainLayer: binary.chainLayer,
        );

      case 'zSide':
        return ZCash(
          name: binary.name,
          version: binary.version,
          description: binary.description,
          repoUrl: binary.repoUrl,
          directories: binary.directories,
          metadata: binary.metadata,
          binary: binary.binary,
          network: binary.network,
          chainLayer: binary.chainLayer,
        );

      case 'Thunder':
        return Thunder(
          name: binary.name,
          version: binary.version,
          description: binary.description,
          repoUrl: binary.repoUrl,
          directories: binary.directories,
          metadata: binary.metadata,
          binary: binary.binary,
          network: binary.network,
          chainLayer: binary.chainLayer,
        );

      case 'Bitnames':
        return Bitnames(
          name: binary.name,
          version: binary.version,
          description: binary.description,
          repoUrl: binary.repoUrl,
          directories: binary.directories,
          metadata: binary.metadata,
          binary: binary.binary,
          network: binary.network,
          chainLayer: binary.chainLayer,
        );

      case 'BitAssets':
        return BitAssets(
          name: binary.name,
          version: binary.version,
          description: binary.description,
          repoUrl: binary.repoUrl,
          directories: binary.directories,
          metadata: binary.metadata,
          binary: binary.binary,
          network: binary.network,
          chainLayer: binary.chainLayer,
        );
      default:
        throw Exception('Unknown sidechain binary type: ${binary.runtimeType}');
    }
  }

  String? getMnemonicPath(Directory appDir) {
    final walletDir = getWalletDir(appDir);

    if (walletDir == null) {
      return null;
    }

    final mnemonicDir = path.normalize(path.join(walletDir, 'mnemonics'));
    final mnemonicPath = path.normalize(path.join(mnemonicDir, 'sidechain_$slot.txt'));

    if (!File(mnemonicPath).existsSync()) {
      // for some reason the .txt file of the mnemonic does not exist, so we try to
      // recover it from the json
      return _recoverMnemonicTxt(mnemonicPath);
    }

    return mnemonicPath;
  }

  String? _recoverMnemonicTxt(String mnemonicPath) {
    // look outside mnemonic subdir for the json file
    final walletDir = path.dirname(path.dirname(mnemonicPath));
    final mnemonicJson = path.join(walletDir, 'sidechain_${slot}_starter.json');

    if (!File(mnemonicJson).existsSync()) {
      return null;
    }

    try {
      // 1. Read the json file and extract "mnemonic" key
      final jsonContent = File(mnemonicJson).readAsStringSync();

      final jsonData = jsonDecode(jsonContent) as Map<String, dynamic>;
      final mnemonic = jsonData['mnemonic'] as String?;

      if (mnemonic == null || mnemonic.isEmpty) {
        return null;
      }

      // 2. Write a new file sidechain_${slot}.txt with the raw mnemonic
      final mnemonicFile = File(mnemonicPath);

      // Create the directory if it doesn't exist
      mnemonicFile.parent.createSync(recursive: true);
      mnemonicFile.writeAsStringSync(mnemonic);

      // 3. Return the path to the new file
      return mnemonicPath;
    } catch (e) {
      // Handle any errors (file read, JSON parse, file write)
      return null;
    }
  }
}

String? getWalletDir(Directory appDir) {
  var launcherAppDir = Directory(
    path.join(
      appDir.path,
      '..',
      'drivechain-launcher',
    ),
  );

  var walletDir = path.join(launcherAppDir.path, 'wallet_starters');

  if (!Directory(walletDir).existsSync()) {
    if (getOS() != OS.linux) {
      // on windows and macos, this means we couldn't find it
      return null;
    }

    // on linux on the other hand, we can look in one more place
    launcherAppDir = Directory(
      path.join(
        Platform.environment['HOME']!,
        '.config',
        'drivechain-launcher',
      ),
    );

    walletDir = path.join(launcherAppDir.path, 'wallet_starters');
    if (!Directory(walletDir).existsSync()) {
      return null;
    }
  }

  return walletDir;
}

class TestSidechain extends Sidechain {
  TestSidechain({
    super.name = 'Test Sidechain',
    super.version = '0.1.0',
    super.description = 'Test Sidechain',
    super.repoUrl = '',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.binary = 'testchaind',
    NetworkConfig? network,
    super.chainLayer = 2,
  }) : super(
          directories: directories ??
              DirectoryConfig(
                base: {
                  OS.linux: '.testchain',
                  OS.macos: 'testchain',
                  OS.windows: 'testchain',
                },
              ),
          metadata: metadata ??
              MetadataConfig(
                baseUrl: 'https://releases.drivechain.info/',
                files: {
                  OS.linux: 'testchain-latest-x86_64-unknown-linux-gnu.zip',
                  OS.macos: 'testchain-latest-x86_64-apple-darwin.zip',
                  OS.windows: 'testchain-latest-x86_64-pc-windows-msvc.zip',
                },
              ),
          network: network ?? NetworkConfig(port: 38332),
        );

  @override
  int slot = 0;

  @override
  Color color = SailColorScheme.orange;

  @override
  TestSidechain copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    String? binary,
    NetworkConfig? network,
    int? chainLayer,
  }) {
    return TestSidechain(
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
      binary: binary ?? this.binary,
      network: network ?? this.network,
      chainLayer: chainLayer ?? this.chainLayer,
    );
  }
}

class ZCash extends Sidechain {
  ZCash({
    super.name = 'zSide',
    super.version = '0.1.0',
    super.description = 'ZCash Sidechain',
    super.repoUrl = 'https://github.com/LayerTwo-Labs/zebra',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.binary = 'zsided',
    NetworkConfig? network,
    super.chainLayer = 2,
  }) : super(
          directories: directories ??
              DirectoryConfig(
                base: {
                  OS.linux: '.zcash-drivechain',
                  OS.macos: '/zcash-drivechain',
                  OS.windows: '/zcash-drivechain',
                },
              ),
          metadata: metadata ??
              MetadataConfig(
                baseUrl: 'https://releases.drivechain.info/',
                files: {
                  OS.linux: 'L2-S5-ZSide-latest-x86_64-unknown-linux-gnu.zip',
                  OS.macos: 'L2-S5-ZSide-latest-x86_64-apple-darwin.zip',
                  OS.windows: 'L2-S5-ZSide-latest-x86_64-pc-windows-gnu.zip',
                },
              ),
          network: network ?? NetworkConfig(port: 8232),
        );

  @override
  int slot = 5;

  @override
  Color color = SailColorScheme.blue;

  @override
  ZCash copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    String? binary,
    NetworkConfig? network,
    int? chainLayer,
  }) {
    return ZCash(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
      binary: binary ?? this.binary,
      network: network ?? this.network,
      chainLayer: chainLayer ?? this.chainLayer,
    );
  }
}

class Thunder extends Sidechain {
  Thunder({
    super.name = 'Thunder',
    super.version = '0.1.0',
    super.description = 'Thunder Sidechain',
    super.repoUrl = 'https://github.com/LayerTwo-Labs/thunder-rust',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.binary = 'thunder',
    NetworkConfig? network,
    super.chainLayer = 2,
  }) : super(
          directories: directories ??
              DirectoryConfig(
                base: {
                  OS.linux: 'thunder',
                  OS.macos: 'Thunder',
                  OS.windows: 'thunder',
                },
              ),
          metadata: metadata ??
              MetadataConfig(
                baseUrl: 'https://releases.drivechain.info/',
                files: {
                  OS.linux: 'L2-S9-Thunder-latest-x86_64-unknown-linux-gnu.zip',
                  OS.macos: 'L2-S9-Thunder-latest-x86_64-apple-darwin.zip',
                  OS.windows: 'L2-S9-Thunder-latest-x86_64-pc-windows-gnu.zip',
                },
              ),
          network: network ?? NetworkConfig(port: 6009),
        );

  @override
  int slot = 9;

  @override
  Color color = SailColorScheme.purple;

  @override
  Thunder copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    String? binary,
    NetworkConfig? network,
    int? chainLayer,
  }) {
    return Thunder(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
      binary: binary ?? this.binary,
      network: network ?? this.network,
      chainLayer: chainLayer ?? this.chainLayer,
    );
  }
}

class Bitnames extends Sidechain {
  Bitnames({
    super.name = 'Bitnames',
    super.version = '0.1.0',
    super.description = 'Bitnames Sidechain',
    super.repoUrl = 'https://github.com/LayerTwo-Labs/plain-bitnames',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.binary = 'bitnames',
    NetworkConfig? network,
    super.chainLayer = 2,
  }) : super(
          directories: directories ??
              DirectoryConfig(
                base: {
                  OS.linux: 'plain_bitnames',
                  OS.macos: 'plain_bitnames',
                  OS.windows: 'plain_bitnames',
                },
              ),
          metadata: metadata ??
              MetadataConfig(
                baseUrl: 'https://releases.drivechain.info/',
                files: {
                  OS.linux: 'L2-S2-BitNames-latest-x86_64-unknown-linux-gnu.zip',
                  OS.macos: 'L2-S2-BitNames-latest-x86_64-apple-darwin.zip',
                  OS.windows: 'L2-S2-BitNames-latest-x86_64-pc-windows-gnu.zip',
                },
              ),
          network: network ?? NetworkConfig(port: 6002),
        );

  @override
  int slot = 2;

  @override
  Color color = SailColorScheme.green;

  @override
  Bitnames copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    String? binary,
    NetworkConfig? network,
    int? chainLayer,
  }) {
    return Bitnames(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
      binary: binary ?? this.binary,
      network: network ?? this.network,
      chainLayer: chainLayer ?? this.chainLayer,
    );
  }
}

class BitAssets extends Sidechain {
  BitAssets({
    super.name = 'BitAssets',
    super.version = '0.1.0',
    super.description = 'Bitassets Sidechain',
    super.repoUrl = 'https://github.com/LayerTwo-Labs/plain-bitassets',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.binary = 'bitassets',
    NetworkConfig? network,
    super.chainLayer = 2,
  }) : super(
          directories: directories ??
              DirectoryConfig(
                base: {
                  OS.linux: 'plain_bitassets',
                  OS.macos: 'plain_bitassets',
                  OS.windows: 'plain_bitassets',
                },
              ),
          metadata: metadata ??
              MetadataConfig(
                baseUrl: 'https://releases.drivechain.info/',
                files: {
                  OS.linux: 'L2-S4-BitAssets-latest-x86_64-unknown-linux-gnu.zip',
                  OS.macos: 'L2-S4-BitAssets-latest-x86_64-apple-darwin.zip',
                  OS.windows: 'L2-S4-BitAssets-latest-x86_64-pc-windows-gnu.zip',
                },
              ),
          network: network ?? NetworkConfig(port: 6004),
        );

  @override
  int slot = 4;

  @override
  Color color = SailColorScheme.blue;

  @override
  BitAssets copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    String? binary,
    NetworkConfig? network,
    int? chainLayer,
  }) {
    return BitAssets(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
      binary: binary ?? this.binary,
      network: network ?? this.network,
      chainLayer: chainLayer ?? this.chainLayer,
    );
  }
}
