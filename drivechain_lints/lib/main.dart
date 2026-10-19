import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:drivechain_lints/src/avoid_build_methods.dart';
import 'package:drivechain_lints/src/avoid_material_import.dart';

final plugin = DrivechainLintsPlugin();

class DrivechainLintsPlugin extends Plugin {
  @override
  String get name => 'drivechain_lints';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(AvoidBuildMethods());
    registry.registerLintRule(AvoidMaterialImport());
  }
}
