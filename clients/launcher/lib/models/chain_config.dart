import 'dart:ui';

import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/style/color_scheme.dart';

class ChainConfigs {
  final String schemaVersion;
  final List<ChainConfig> chains;

  const ChainConfigs({
    required this.schemaVersion,
    required this.chains,
  });
}

class ChainConfig extends Binary {
  final String id;

  ChainConfig({
    required this.id,
    required super.version,
    required super.name,
    required super.description,
    required super.repoUrl,
    required super.chainLayer,
    required Map<String, String> binary,
    required super.directories,
    required super.download,
    required super.network,
  }) : super(
          binary: binary.values.first,
        );

  @override
  Color get color => SailColorScheme.green; // Default color
}
