import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Forbids importing `package:flutter/material.dart` outside the design-system
/// layer — consumers use sail_ui primitives (`SailButton`, `SailCard`,
/// `SailDialog`, …) so the whole UI themes through `SailTheme`.
///
/// Severity is configurable per package in analysis_options.yaml
/// (`custom_lint: rules: - avoid_material_import: severity: error`);
/// defaults to info. Exceptions:
/// - `sail_ui/lib/` (the wrapper layer, via `// ignore_for_file:`)
/// - test files (Material is legitimate harness scaffolding there)
/// - inline `// ignore: avoid_material_import` with a stated reason
class AvoidMaterialImport extends DartLintRule {
  AvoidMaterialImport.fromConfigs(CustomLintConfigs configs)
    : super(code: _codeFor(configs));

  static LintCode _codeFor(CustomLintConfigs configs) {
    final severity =
        switch (configs.rules['avoid_material_import']?.json['severity']) {
          'error' => ErrorSeverity.ERROR,
          'warning' => ErrorSeverity.WARNING,
          _ => ErrorSeverity.INFO,
        };
    return LintCode(
      name: 'avoid_material_import',
      problemMessage:
          'Avoid importing package:flutter/material.dart — prefer sail_ui primitives.',
      correctionMessage:
          'Replace Material widgets with their Sail equivalents (Button → SailButton, '
          'Card → SailCard, Dialog → SailDialog, etc.). If the import is unavoidable, '
          'add an ignore comment and explain why.',
      errorSeverity: severity,
    );
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (resolver.path.contains('/test/')) return;

    context.registry.addImportDirective((node) {
      final uri = node.uri.stringValue;
      if (uri == 'package:flutter/material.dart') {
        reporter.atNode(node, code);
      }
    });
  }
}
