import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Discourages importing `package:flutter/material.dart` outside of the
/// design-system layer. Migrating the project onto sail_ui's self-hosted
/// shadcn-style primitives means consumers should not reach for Material
/// directly — they should use `SailButton`, `SailCard`, `SailDialog`, etc.
///
/// Phase 0 of the design-system migration: this rule is informational
/// only — it surfaces the existing Material surface area so each
/// subsequent phase can be measured. Future phases promote the severity
/// per package as that package hits zero violations.
///
/// Allowed exceptions:
/// - Files inside `sail_ui/lib/` itself (the design system layer wraps
///   Material primitives by definition; this rule disabled for the
///   wrapper sources via `// ignore_for_file: avoid_material_import`).
/// - Anywhere the comment `// ignore: avoid_material_import` is applied
///   inline.
class AvoidMaterialImport extends DartLintRule {
  AvoidMaterialImport() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_material_import',
    problemMessage:
        'Avoid importing package:flutter/material.dart — prefer sail_ui primitives.',
    correctionMessage:
        'Replace Material widgets with their Sail equivalents (Button → SailButton, '
        'Card → SailCard, Dialog → SailDialog, etc.). If the import is unavoidable, '
        'add an ignore comment and explain why.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addImportDirective((node) {
      final uri = node.uri.stringValue;
      if (uri == 'package:flutter/material.dart') {
        reporter.atNode(node, _code);
      }
    });
  }
}
