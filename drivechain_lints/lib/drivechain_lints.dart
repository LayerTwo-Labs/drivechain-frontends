library drivechain_lints;

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:drivechain_lints/src/avoid_build_methods.dart';

PluginBase createPlugin() => _DrivechainLints();

class _DrivechainLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        AvoidBuildMethods(),
      ];
}
