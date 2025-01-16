class ChainConfig {
  final String name;
  final String binary;
  final int chainLayer;
  final String downloadUrl;
  final String linuxFile;
  final String macosFile;
  final String windowsFile;

  ChainConfig({
    required this.name,
    required this.binary,
    required this.chainLayer,
    required this.downloadUrl,
    required this.linuxFile,
    required this.macosFile,
    required this.windowsFile,
  });

  factory ChainConfig.fromJson(Map<String, dynamic> json) {
    return ChainConfig(
      name: json['name'] as String,
      binary: json['binary'] as String,
      chainLayer: json['chainLayer'] as int,
      downloadUrl: json['downloadUrl'] as String,
      linuxFile: json['linuxFile'] as String,
      macosFile: json['macosFile'] as String,
      windowsFile: json['windowsFile'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'binary': binary,
      'chainLayer': chainLayer,
      'downloadUrl': downloadUrl,
      'linuxFile': linuxFile,
      'macosFile': macosFile,
      'windowsFile': windowsFile,
    };
  }
}
