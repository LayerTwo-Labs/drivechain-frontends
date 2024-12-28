/// Models for chain configuration data structures
class ChainConfig {
  final String id;
  final String version;
  final String displayName;
  final String description;
  final String repoUrl;
  final DirectoryConfig directories;
  final DownloadConfig download;
  final Map<String, String> binary;
  final NetworkConfig network;
  final int chainType;
  final int slot;

  ChainConfig({
    required this.id,
    required this.version,
    required this.displayName,
    required this.description,
    required this.repoUrl,
    required this.directories,
    required this.download,
    required this.binary,
    required this.network,
    required this.chainType,
    required this.slot,
  });

  factory ChainConfig.fromJson(Map<String, dynamic> json) {
    return ChainConfig(
      id: json['id'] as String,
      version: json['version'] as String,
      displayName: json['display_name'] as String,
      description: json['description'] as String,
      repoUrl: json['repo_url'] as String,
      directories: DirectoryConfig.fromJson(json['directories'] as Map<String, dynamic>),
      download: DownloadConfig.fromJson(json['download'] as Map<String, dynamic>),
      binary: Map<String, String>.from(json['binary'] as Map),
      network: NetworkConfig.fromJson(json['network'] as Map<String, dynamic>),
      chainType: json['chain_type'] as int,
      slot: json['slot'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'version': version,
    'display_name': displayName,
    'description': description,
    'repo_url': repoUrl,
    'directories': directories.toJson(),
    'download': download.toJson(),
    'binary': binary,
    'network': network.toJson(),
    'chain_type': chainType,
    'slot': slot,
  };
}

/// Configuration for component directories
class DirectoryConfig {
  final Map<String, String> base;
  final String wallet;

  DirectoryConfig({
    required this.base,
    required this.wallet,
  });

  factory DirectoryConfig.fromJson(Map<String, dynamic> json) {
    return DirectoryConfig(
      base: Map<String, String>.from(json['base'] as Map),
      wallet: json['wallet'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'base': base,
    'wallet': wallet,
  };
}

/// Configuration for component downloads
class DownloadConfig {
  final String baseUrl;
  final Map<String, String> files;
  final Map<String, int> sizes;
  final Map<String, String> hashes;

  DownloadConfig({
    required this.baseUrl,
    required this.files,
    required this.sizes,
    required this.hashes,
  });

  factory DownloadConfig.fromJson(Map<String, dynamic> json) {
    return DownloadConfig(
      baseUrl: json['base_url'] as String,
      files: Map<String, String>.from(json['files'] as Map),
      sizes: Map<String, int>.from(json['sizes'] as Map),
      hashes: Map<String, String>.from(json['hashes'] as Map),
    );
  }

  Map<String, dynamic> toJson() => {
    'base_url': baseUrl,
    'files': files,
    'sizes': sizes,
    'hashes': hashes,
  };
}

/// Configuration for network settings
class NetworkConfig {
  final int port;

  NetworkConfig({
    required this.port,
  });

  factory NetworkConfig.fromJson(Map<String, dynamic> json) {
    return NetworkConfig(
      port: json['port'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'port': port,
  };
}

/// Root configuration containing all chain configs
class ChainConfigs {
  final String schemaVersion;
  final List<ChainConfig> chains;

  ChainConfigs({
    required this.schemaVersion,
    required this.chains,
  });

  factory ChainConfigs.fromJson(Map<String, dynamic> json) {
    return ChainConfigs(
      schemaVersion: json['schema_version'] as String,
      chains: (json['chains'] as List)
          .map((e) => ChainConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'schema_version': schemaVersion,
    'chains': chains.map((e) => e.toJson()).toList(),
  };
}
