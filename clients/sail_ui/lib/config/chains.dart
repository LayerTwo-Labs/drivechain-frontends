import 'package:flutter/material.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/utils/file_utils.dart';

abstract class Sidechain extends Binary {
  Sidechain({
    required super.name,
    required super.version,
    required super.description,
    required super.repoUrl,
    required super.directories,
    required super.download,
    required super.binary,
    required super.network,
    required super.chainLayer,
  });

  int get slot;

  static Sidechain? fromString(String input) {
    switch (input.toLowerCase()) {
      case 'ethereum':
        return EthereumSidechain();

      case 'testchain':
        return TestSidechain();

      case 'zcash':
        return ZCashSidechain();

      case 'thunder':
        return Thunder();
    }
    return null;
  }
}

class TestSidechain extends Sidechain {
  TestSidechain({
    super.name = 'Test Sidechain',
    super.version = '0.1.0',
    super.description = 'Test Sidechain',
    super.repoUrl = 'https://github.com/drivechain-project/testchain',
    DirectoryConfig? directories,
    DownloadConfig? download,
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
          download: download ??
              DownloadConfig(
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
    DownloadConfig? download,
    String? binary,
    NetworkConfig? network,
    int? chainLayer,
  }) {
    return TestSidechain(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      download: download ?? this.download,
      binary: binary ?? this.binary,
      network: network ?? this.network,
      chainLayer: chainLayer ?? this.chainLayer,
    );
  }
}

class ZCashSidechain extends Sidechain {
  ZCashSidechain({
    super.name = 'zSide',
    super.version = '0.1.0',
    super.description = 'ZCash Sidechain',
    super.repoUrl = 'https://github.com/drivechain-project/zside',
    DirectoryConfig? directories,
    DownloadConfig? download,
    super.binary = 'zsided',
    NetworkConfig? network,
    super.chainLayer = 2,
  }) : super(
          directories: directories ??
              DirectoryConfig(
                base: {
                  OS.linux: '.zside',
                  OS.macos: 'ZSide',
                  OS.windows: 'ZSide',
                },
              ),
          download: download ??
              DownloadConfig(
                baseUrl: 'https://releases.drivechain.info/',
                files: {
                  OS.linux: 'L2-S5-ZCash-latest-x86_64-unknown-linux-gnu.zip',
                  OS.macos: 'L2-S5-ZCash-latest-x86_64-apple-darwin.zip',
                  OS.windows: 'L2-S5-ZCash-latest-x86_64-pc-windows-gnu.zip',
                },
              ),
          network: network ?? NetworkConfig(port: 8232),
        );

  @override
  int slot = 5;

  @override
  Color color = SailColorScheme.blue;

  @override
  ZCashSidechain copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    DownloadConfig? download,
    String? binary,
    NetworkConfig? network,
    int? chainLayer,
  }) {
    return ZCashSidechain(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      download: download ?? this.download,
      binary: binary ?? this.binary,
      network: network ?? this.network,
      chainLayer: chainLayer ?? this.chainLayer,
    );
  }
}

class EthereumSidechain extends Sidechain {
  EthereumSidechain({
    super.name = 'EthSide',
    super.version = '0.1.0',
    super.description = 'Ethereum Sidechain',
    super.repoUrl = 'https://github.com/drivechain-project/ethside',
    DirectoryConfig? directories,
    DownloadConfig? download,
    super.binary = 'sidegeth',
    NetworkConfig? network,
    super.chainLayer = 2,
  }) : super(
          directories: directories ??
              DirectoryConfig(
                base: {
                  OS.linux: '.ethside',
                  OS.macos: 'EthSide',
                  OS.windows: 'EthSide',
                },
              ),
          download: download ??
              DownloadConfig(
                baseUrl: 'https://releases.drivechain.info/',
                files: {
                  OS.linux: 'L2-S6-Ethereum-latest-x86_64-unknown-linux-gnu.zip',
                  OS.macos: 'L2-S6-Ethereum-latest-x86_64-apple-darwin.zip',
                  OS.windows: 'L2-S6-Ethereum-latest-x86_64-pc-windows-gnu.zip',
                },
              ),
          network: network ?? NetworkConfig(port: 8545),
        );

  @override
  int slot = 6;

  @override
  Color color = SailColorScheme.purple;

  @override
  EthereumSidechain copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    DownloadConfig? download,
    String? binary,
    NetworkConfig? network,
    int? chainLayer,
  }) {
    return EthereumSidechain(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      download: download ?? this.download,
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
    super.repoUrl = 'https://github.com/drivechain-project/thunder',
    DirectoryConfig? directories,
    DownloadConfig? download,
    super.binary = 'thunder',
    NetworkConfig? network,
    super.chainLayer = 2,
  }) : super(
          directories: directories ??
              DirectoryConfig(
                base: {
                  OS.linux: '.thunder',
                  OS.macos: 'Thunder',
                  OS.windows: 'Thunder',
                },
              ),
          download: download ??
              DownloadConfig(
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
  Color color = SailColorScheme.green;

  @override
  Thunder copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    DownloadConfig? download,
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
      download: download ?? this.download,
      binary: binary ?? this.binary,
      network: network ?? this.network,
      chainLayer: chainLayer ?? this.chainLayer,
    );
  }
}
