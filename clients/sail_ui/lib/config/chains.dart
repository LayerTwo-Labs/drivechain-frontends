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
    required super.metadata,
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
        return ZCash();

      case 'thunder':
        return Thunder();

      case 'bitnames':
        return Bitnames();
    }
    return null;
  }

  static Sidechain fromBinary(Binary binary) {
    switch (binary.runtimeType) {
      case TestSidechain _:
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
      case ZCash _:
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
      case Thunder _:
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
      case Bitnames _:
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
      default:
        throw Exception('Unknown sidechain binary type: ${binary.runtimeType}');
    }
  }
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
    super.repoUrl = 'https://github.com/drivechain-project/zside',
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

class EthereumSidechain extends Sidechain {
  EthereumSidechain({
    super.name = 'EthSide',
    super.version = '0.1.0',
    super.description = 'Ethereum Sidechain',
    super.repoUrl = 'https://github.com/drivechain-project/ethside',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
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
          metadata: metadata ??
              MetadataConfig(
                baseUrl: 'https://releases.drivechain.info/old-pre-cusf/',
                files: {
                  OS.linux: 'L2-S6-EthSide-latest-x86_64-unknown-linux-gnu.zip',
                  OS.macos: 'L2-S6-EthSide-latest-x86_64-apple-darwin.zip',
                  OS.windows: 'L2-S6-EthSide-latest-x86_64-w64-mingw32.zip',
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
    MetadataConfig? metadata,
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
    super.repoUrl = 'https://github.com/drivechain-project/thunder',
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
  Color color = SailColorScheme.green;

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
    super.repoUrl = 'https://github.com/drivechain-project/bitnames',
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
