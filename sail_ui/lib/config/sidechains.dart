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
    required super.port,
    required super.chainLayer,
    required super.downloadInfo,
    required super.extraBootArgs,
  });

  int get slot;

  static Sidechain? fromString(String input) {
    switch (input.toLowerCase()) {
      case 'zside':
        return ZSide();

      case 'thunder':
        return Thunder();

      case 'bitnames':
        return BitNames();

      case 'bitassets':
        return BitAssets();
    }
    return null;
  }

  static Sidechain fromBinary(Binary binary) {
    switch (binary.name) {
      case 'zSide':
        return ZSide(
          name: binary.name,
          version: binary.version,
          description: binary.description,
          repoUrl: binary.repoUrl,
          directories: binary.directories,
          metadata: binary.metadata,
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
          port: binary.port,
          chainLayer: binary.chainLayer,
        );

      case 'Bitnames':
        return BitNames(
          name: binary.name,
          version: binary.version,
          description: binary.description,
          repoUrl: binary.repoUrl,
          directories: binary.directories,
          metadata: binary.metadata,
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
          port: binary.port,
          chainLayer: binary.chainLayer,
        );
      default:
        throw Exception('Unknown sidechain binary type: ${binary.runtimeType}');
    }
  }
}

File? getWalletFile(Directory appDir) {
  final walletDir = File(path.join(appDir.path, 'wallet.json'));
  return walletDir.existsSync() ? walletDir : null;
}

class ZSide extends Sidechain {
  ZSide({
    super.name = 'zSide',
    super.version = '0.1.0',
    super.description = 'ZSide Sidechain',
    super.repoUrl = 'https://github.com/iwakura-rein/thunder-orchard',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.port = 6098,
    super.chainLayer = 2,
    super.downloadInfo = const DownloadInfo(),
    super.extraBootArgs = const [],
  }) : super(
         directories:
             directories ??
             DirectoryConfig(
               binary: {
                 OS.linux: '.thunder-orchard',
                 OS.macos: 'thunder-orchard',
                 OS.windows: 'thunder-orchard',
               },
               flutterFrontend: {
                 OS.linux: 'com.layertwolabs.zside',
                 OS.macos: 'com.layertwolabs.zside',
                 OS.windows: 'com.layertwolabs.zside',
               },
             ),
         metadata:
             metadata ??
             MetadataConfig(
               downloadConfig: DownloadConfig(
                 binary: 'thunder-orchard',
                 baseUrl: 'https://api.github.com/repos/iwakura-rein/thunder-orchard/releases/latest',
                 files: {
                   OS.linux: r'thunder-orchard-\d+\.\d+\.\d+-x86_64-unknown-linux-gnu',
                   OS.macos: r'thunder-orchard-\d+\.\d+\.\d+-x86_64-apple-darwin',
                   OS.windows: '', // thunder-orchard not available for windows
                 },
               ),
               alternativeDownloadConfig: DownloadConfig(
                 baseUrl: 'https://releases.drivechain.info/',
                 binary: 'zside',
                 files: {
                   OS.linux: 'test-zside-x86_64-unknown-linux-gnu.zip',
                   OS.macos: 'test-zside-x86_64-apple-darwin.zip',
                   OS.windows: '', // zside not available for windows
                 },
               ),
               remoteTimestamp: null,
               downloadedTimestamp: null,
               binaryPath: null,
               updateable: false,
             ),
       );

  @override
  final int slot = 98;

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
    super.repoUrl = 'https://github.com/layerTwo-Labs/thunder-rust',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.port = 6009,
    super.chainLayer = 2,
    super.downloadInfo = const DownloadInfo(),
    super.extraBootArgs = const [],
  }) : super(
         directories:
             directories ??
             DirectoryConfig(
               binary: {OS.linux: 'thunder', OS.macos: 'Thunder', OS.windows: 'thunder'},
               flutterFrontend: {
                 OS.linux: 'com.layertwolabs.thunder',
                 OS.macos: 'com.layertwolabs.thunder',
                 OS.windows: 'com.layertwolabs.thunder',
               },
             ),
         metadata:
             metadata ??
             MetadataConfig(
               downloadConfig: DownloadConfig(
                 baseUrl: 'https://releases.drivechain.info/',
                 binary: 'thunder',
                 files: {
                   OS.linux: 'L2-S9-Thunder-latest-x86_64-unknown-linux-gnu.zip',
                   OS.macos: 'L2-S9-Thunder-latest-x86_64-apple-darwin.zip',
                   OS.windows: 'L2-S9-Thunder-latest-x86_64-pc-windows-gnu.zip',
                 },
               ),
               alternativeDownloadConfig: DownloadConfig(
                 baseUrl: 'https://releases.drivechain.info/',
                 binary: 'thunder',
                 files: {
                   OS.linux: 'test-thunder-x86_64-unknown-linux-gnu.zip',
                   OS.macos: 'test-thunder-x86_64-apple-darwin.zip',
                   OS.windows: 'test-thunder-x86_64-windows.exe', // thunder not available for windows
                 },
               ),
               remoteTimestamp: null,
               downloadedTimestamp: null,
               binaryPath: null,
               updateable: false,
             ),
       );

  @override
  final int slot = 9;

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
      port: port ?? this.port,
      chainLayer: chainLayer ?? this.chainLayer,
      downloadInfo: downloadInfo ?? this.downloadInfo,
      extraBootArgs: extraBootArgs ?? this.extraBootArgs,
    );
  }
}

class BitNames extends Sidechain {
  BitNames({
    super.name = 'Bitnames',
    super.version = 'latest',
    super.description = 'Variant of BitDNS that aims to replace ICANN',
    super.repoUrl = 'https://github.com/LayerTwo-Labs/plain-bitnames',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.port = 6002,
    super.chainLayer = 2,
    super.downloadInfo = const DownloadInfo(),
    super.extraBootArgs = const [],
  }) : super(
         directories:
             directories ??
             DirectoryConfig(
               binary: {OS.linux: 'plain_bitnames', OS.macos: 'plain_bitnames', OS.windows: 'plain_bitnames'},
               flutterFrontend: {
                 OS.linux: 'com.layertwolabs.bitnames',
                 OS.macos: 'com.layertwolabs.bitnames',
                 OS.windows: 'com.layertwolabs.bitnames',
               },
             ),
         metadata:
             metadata ??
             MetadataConfig(
               downloadConfig: DownloadConfig(
                 baseUrl: 'https://releases.drivechain.info/',
                 binary: 'bitnames',
                 files: {
                   OS.linux: 'L2-S2-BitNames-latest-x86_64-unknown-linux-gnu.zip',
                   OS.macos: 'L2-S2-BitNames-latest-x86_64-apple-darwin.zip',
                   OS.windows: 'L2-S2-BitNames-latest-x86_64-pc-windows-gnu.zip',
                 },
               ),
               alternativeDownloadConfig: DownloadConfig(
                 baseUrl: 'https://releases.drivechain.info/',
                 binary: 'bitnames',
                 files: {
                   OS.linux: 'test-bitnames-x86_64-unknown-linux-gnu.zip',
                   OS.macos: 'test-bitnames-x86_64-apple-darwin.zip',
                   OS.windows: 'test-bitnames-x86_64-windows.exe',
                 },
               ),
               remoteTimestamp: null,
               downloadedTimestamp: null,
               binaryPath: null,
               updateable: false,
             ),
       );

  @override
  final int slot = 2;

  @override
  BinaryType get type => BinaryType.bitnames;

  @override
  Color color = SailColorScheme.green;

  @override
  BitNames copyWith({
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
    return BitNames(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
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
    super.port = 6004,
    super.chainLayer = 2,
    super.downloadInfo = const DownloadInfo(),
    super.extraBootArgs = const [],
  }) : super(
         directories:
             directories ??
             DirectoryConfig(
               binary: {
                 OS.linux: 'plain_bitassets',
                 OS.macos: 'plain_bitassets',
                 OS.windows: 'plain_bitassets',
               },
               flutterFrontend: {
                 OS.linux: 'com.layertwolabs.bitassets',
                 OS.macos: 'com.layertwolabs.bitassets',
                 OS.windows: 'com.layertwolabs.bitassets',
               },
             ),
         metadata:
             metadata ??
             MetadataConfig(
               downloadConfig: DownloadConfig(
                 baseUrl: 'https://releases.drivechain.info/',
                 binary: 'bitassets',
                 files: {
                   OS.linux: 'L2-S4-BitAssets-latest-x86_64-unknown-linux-gnu.zip',
                   OS.macos: 'L2-S4-BitAssets-latest-x86_64-apple-darwin.zip',
                   OS.windows: 'L2-S4-BitAssets-latest-x86_64-pc-windows-gnu.zip',
                 },
               ),
               alternativeDownloadConfig: DownloadConfig(
                 baseUrl: 'https://releases.drivechain.info/',
                 binary: 'bitassets',
                 files: {
                   OS.linux: 'test-bitassets-x86_64-unknown-linux-gnu.zip',
                   OS.macos: 'test-bitassets-x86_64-apple-darwin.zip',
                   OS.windows: 'test-bitassets-x86_64-windows.exe',
                 },
               ),
               remoteTimestamp: null,
               downloadedTimestamp: null,
               binaryPath: null,
               updateable: false,
             ),
       );

  @override
  final int slot = 4;

  @override
  BinaryType get type => BinaryType.bitassets;

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
      port: port ?? this.port,
      chainLayer: chainLayer ?? this.chainLayer,
      downloadInfo: downloadInfo ?? this.downloadInfo,
      extraBootArgs: extraBootArgs ?? this.extraBootArgs,
    );
  }
}
