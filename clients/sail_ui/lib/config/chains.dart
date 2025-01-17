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
  TestSidechain()
      : super(
          name: 'Testchain',
          version: '0.1.0',
          description: 'Test Sidechain',
          repoUrl: 'https://github.com/drivechain-project/testchain',
          directories: DirectoryConfig(
            base: {
              OS.linux: '.testchain',
              OS.macos: 'Testchain',
              OS.windows: 'Testchain',
            },
          ),
          download: DownloadConfig(
            baseUrl: 'https://releases.drivechain.info/',
            files: {
              OS.linux: 'L2-S0-Testchain-latest-x86_64-unknown-linux-gnu.zip',
              OS.macos: 'L2-S0-Testchain-latest-x86_64-apple-darwin.zip',
              OS.windows: 'L2-S0-Testchain-latest-x86_64-pc-windows-gnu.zip',
            },
          ),
          binary: 'testchaind',
          network: NetworkConfig(port: 8272),
          chainLayer: 2,
        );

  @override
  int slot = 0;

  @override
  Color color = SailColorScheme.orange;
}

class ZCashSidechain extends Sidechain {
  ZCashSidechain()
      : super(
          name: 'zSide',
          version: '0.1.0',
          description: 'ZCash Sidechain',
          repoUrl: 'https://github.com/drivechain-project/zside',
          directories: DirectoryConfig(
            base: {
              OS.linux: '.zside',
              OS.macos: 'ZSide',
              OS.windows: 'ZSide',
            },
          ),
          download: DownloadConfig(
            baseUrl: 'https://releases.drivechain.info/',
            files: {
              OS.linux: 'L2-S5-ZCash-latest-x86_64-unknown-linux-gnu.zip',
              OS.macos: 'L2-S5-ZCash-latest-x86_64-apple-darwin.zip',
              OS.windows: 'L2-S5-ZCash-latest-x86_64-pc-windows-gnu.zip',
            },
          ),
          binary: 'zsided',
          network: NetworkConfig(port: 8232),
          chainLayer: 2,
        );

  @override
  int slot = 5;

  @override
  Color color = SailColorScheme.blue;
}

class EthereumSidechain extends Sidechain {
  EthereumSidechain()
      : super(
          name: 'EthSide',
          version: '0.1.0',
          description: 'Ethereum Sidechain',
          repoUrl: 'https://github.com/drivechain-project/ethside',
          directories: DirectoryConfig(
            base: {
              OS.linux: '.ethside',
              OS.macos: 'EthSide',
              OS.windows: 'EthSide',
            },
          ),
          download: DownloadConfig(
            baseUrl: 'https://releases.drivechain.info/',
            files: {
              OS.linux: 'L2-S6-Ethereum-latest-x86_64-unknown-linux-gnu.zip',
              OS.macos: 'L2-S6-Ethereum-latest-x86_64-apple-darwin.zip',
              OS.windows: 'L2-S6-Ethereum-latest-x86_64-pc-windows-gnu.zip',
            },
          ),
          binary: 'sidegeth',
          network: NetworkConfig(port: 8545),
          chainLayer: 2,
        );

  @override
  int slot = 6;

  @override
  Color color = SailColorScheme.purple;
}

class Thunder extends Sidechain {
  Thunder()
      : super(
          name: 'Thunder',
          version: '0.1.0',
          description: 'Thunder Sidechain',
          repoUrl: 'https://github.com/drivechain-project/thunder',
          directories: DirectoryConfig(
            base: {
              OS.linux: '.thunder',
              OS.macos: 'Thunder',
              OS.windows: 'Thunder',
            },
          ),
          download: DownloadConfig(
            baseUrl: 'https://releases.drivechain.info/',
            files: {
              OS.linux: 'L2-S9-Thunder-latest-x86_64-unknown-linux-gnu.zip',
              OS.macos: 'L2-S9-Thunder-latest-x86_64-apple-darwin.zip',
              OS.windows: 'L2-S9-Thunder-latest-x86_64-pc-windows-gnu.zip',
            },
          ),
          binary: 'thunder',
          network: NetworkConfig(port: 38332),
          chainLayer: 2,
        );

  @override
  int slot = 9;

  @override
  Color color = SailColorScheme.green;
}
