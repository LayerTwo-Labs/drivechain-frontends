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
    required super.port,
    required super.chainLayer,
    required super.downloadInfo,
    required super.extraBootArgs,
  });

  int get slot;

  static Sidechain? fromString(String input) {
    switch (input.toLowerCase()) {
      case 'testchain':
        return TestSidechain();

      case 'zside':
        return ZSide();

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
          port: binary.port,
          chainLayer: binary.chainLayer,
        );

      case 'zSide':
        return ZSide(
          name: binary.name,
          version: binary.version,
          description: binary.description,
          repoUrl: binary.repoUrl,
          directories: binary.directories,
          metadata: binary.metadata,
          binary: binary.binary,
          port: binary.port,
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
          port: binary.port,
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
          port: binary.port,
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
          port: binary.port,
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

    final mnemonicPath = path.normalize(path.join(walletDir.path, 'sidechain_${slot}_starter.txt'));

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

Directory? getWalletDir(Directory appDir) {
  final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
  return walletDir.existsSync() ? walletDir : null;
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
    super.port = 38332,
    super.chainLayer = 2,
    super.downloadInfo = const DownloadInfo(),
    super.extraBootArgs = const [],
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
                remoteTimestamp: null,
                downloadedTimestamp: null,
                binaryPath: null,
                updateable: false,
              ),
        );

  @override
  int slot = 0;

  @override
  BinaryType get type => BinaryType.testSidechain;

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
    int? port,
    int? chainLayer,
    DownloadInfo? downloadInfo,
  }) {
    return TestSidechain(
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
      binary: binary ?? this.binary,
      port: port ?? this.port,
      chainLayer: chainLayer ?? this.chainLayer,
      downloadInfo: downloadInfo ?? this.downloadInfo,
    );
  }
}

class ZSide extends Sidechain {
  ZSide({
    super.name = 'zSide',
    super.version = '0.1.0',
    super.description = 'ZSide Sidechain',
    super.repoUrl = 'https://github.com/LayerTwo-Labs/thunder-orchard',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.binary = 'zsided',
    super.port = 6098,
    super.chainLayer = 2,
    super.downloadInfo = const DownloadInfo(),
    super.extraBootArgs = const [],
  }) : super(
          directories: directories ??
              DirectoryConfig(
                base: {
                  OS.linux: '.thunder-orchard',
                  OS.macos: '/thunder-orchard',
                  OS.windows: '/thunder-orchard',
                },
              ),
          metadata: metadata ??
              MetadataConfig(
                baseUrl: 'https://releases.drivechain.info/',
                files: {
                  OS.linux: 'L2-S98-ZSide-latest-x86_64-unknown-linux-gnu.zip',
                  OS.macos: 'L2-S98-ZSide-latest-x86_64-apple-darwin.zip',
                  OS.windows: 'L2-S98-ZSide-latest-x86_64-pc-windows-gnu.zip',
                },
                remoteTimestamp: null,
                downloadedTimestamp: null,
                binaryPath: null,
                updateable: false,
              ),
        );

  @override
  int slot = 98;

  @override
  BinaryType get type => BinaryType.zSide;

  @override
  Color color = SailColorScheme.blue;

  @override
  ZSide copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    String? binary,
    int? port,
    int? chainLayer,
    DownloadInfo? downloadInfo,
    List<String>? extraBootArgs,
  }) {
    return ZSide(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
      binary: binary ?? this.binary,
      port: port ?? this.port,
      chainLayer: chainLayer ?? this.chainLayer,
      downloadInfo: downloadInfo ?? this.downloadInfo,
      extraBootArgs: extraBootArgs ?? this.extraBootArgs,
    );
  }
}

class Thunder extends Sidechain {
  Thunder({
    super.name = 'Thunder',
    super.version = 'latest',
    super.description = 'Large & growing blocksize, plus fraud proofs',
    super.repoUrl = 'https://github.com/LayerTwo-Labs/thunder-rust',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.binary = 'thunder',
    super.port = 6009,
    super.chainLayer = 2,
    super.downloadInfo = const DownloadInfo(),
    super.extraBootArgs = const [],
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
                remoteTimestamp: null,
                downloadedTimestamp: null,
                binaryPath: null,
                updateable: false,
              ),
        );

  @override
  int slot = 9;

  @override
  BinaryType get type => BinaryType.thunder;

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
    int? port,
    int? chainLayer,
    DownloadInfo? downloadInfo,
    List<String>? extraBootArgs,
  }) {
    return Thunder(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
      binary: binary ?? this.binary,
      port: port ?? this.port,
      chainLayer: chainLayer ?? this.chainLayer,
      downloadInfo: downloadInfo ?? this.downloadInfo,
      extraBootArgs: extraBootArgs ?? this.extraBootArgs,
    );
  }
}

class Bitnames extends Sidechain {
  Bitnames({
    super.name = 'Bitnames',
    super.version = 'latest',
    super.description = 'Variant of BitDNS that aims to replace ICANN',
    super.repoUrl = 'https://github.com/LayerTwo-Labs/plain-bitnames',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.binary = 'bitnames',
    super.port = 6002,
    super.chainLayer = 2,
    super.downloadInfo = const DownloadInfo(),
    super.extraBootArgs = const [],
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
                remoteTimestamp: null,
                downloadedTimestamp: null,
                binaryPath: null,
                updateable: false,
              ),
        );

  @override
  int slot = 2;

  @override
  BinaryType get type => BinaryType.bitnames;

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
    int? port,
    int? chainLayer,
    DownloadInfo? downloadInfo,
    List<String>? extraBootArgs,
  }) {
    return Bitnames(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
      binary: binary ?? this.binary,
      port: port ?? this.port,
      chainLayer: chainLayer ?? this.chainLayer,
      downloadInfo: downloadInfo ?? this.downloadInfo,
      extraBootArgs: extraBootArgs ?? this.extraBootArgs,
    );
  }
}

class BitAssets extends Sidechain {
  BitAssets({
    super.name = 'BitAssets',
    super.version = 'latest',
    super.description = 'Variant of BitDNS that aims to replace ICANN',
    super.repoUrl = 'https://github.com/LayerTwo-Labs/plain-bitassets',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.binary = 'bitassets',
    super.port = 6004,
    super.chainLayer = 2,
    super.downloadInfo = const DownloadInfo(),
    super.extraBootArgs = const [],
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
                remoteTimestamp: null,
                downloadedTimestamp: null,
                binaryPath: null,
                updateable: false,
              ),
        );

  @override
  int slot = 4;

  @override
  BinaryType get type => BinaryType.bitAssets;

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
    int? port,
    int? chainLayer,
    DownloadInfo? downloadInfo,
    List<String>? extraBootArgs,
  }) {
    return BitAssets(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
      binary: binary ?? this.binary,
      port: port ?? this.port,
      chainLayer: chainLayer ?? this.chainLayer,
      downloadInfo: downloadInfo ?? this.downloadInfo,
      extraBootArgs: extraBootArgs ?? this.extraBootArgs,
    );
  }
}
