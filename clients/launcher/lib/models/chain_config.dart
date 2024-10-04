import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ChainConfig {
  final String id;
  final String version;
  final String displayName;
  final String description;
  final String repoUrl;
  final int chainType;
  final int slot;
  final Map<String, dynamic> directories;
  final Map<String, dynamic> download;
  final Map<String, String> binary;
  final Map<String, dynamic> network;

  ChainConfig({
    required this.id,
    required this.version,
    required this.displayName,
    required this.description,
    required this.repoUrl,
    required this.chainType,
    required this.slot,
    required this.directories,
    required this.download,
    required this.binary,
    required this.network,
  });

  factory ChainConfig.fromJson(Map<String, dynamic> json) {
    return ChainConfig(
      id: json['id'],
      version: json['version'],
      displayName: json['display_name'],
      description: json['description'],
      repoUrl: json['repo_url'],
      chainType: json['chain_type'],
      slot: json['slot'],
      directories: json['directories'],
      download: json['download'],
      binary: Map<String, String>.from(json['binary']),
      network: json['network'],
    );
  }
}

Future<List<ChainConfig>> loadChainConfigs() async {
  final String jsonString = await rootBundle.loadString('assets/chain_config.json');
  final Map<String, dynamic> jsonMap = json.decode(jsonString);
  final List<dynamic> chainsJson = jsonMap['chains'];
  return chainsJson.map((json) => ChainConfig.fromJson(json)).toList();
}