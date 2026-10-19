import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Forbids importing `package:flutter/material.dart` outside the design-system
/// layer — consumers use sail_ui primitives (`SailButton`, `SailCard`,
/// `SailDialog`, …) so the whole UI themes through `SailTheme`.
///
/// Exceptions:
/// - sail_ui (the wrapper layer, the rule is not enabled there)
/// - test files (Material is legitimate harness scaffolding there)
/// - inline `// ignore: drivechain_lints/avoid_material_import` with a stated reason
class AvoidMaterialImport extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_material_import',
    'Avoid importing package:flutter/material.dart — prefer sail_ui primitives.',
    correctionMessage:
        'Replace Material widgets with their Sail equivalents (Button → SailButton, '
        'Card → SailCard, Dialog → SailDialog, etc.). If the import is unavoidable, '
        'add an ignore comment and explain why.',
  );

  AvoidMaterialImport()
    : super(
        name: 'avoid_material_import',
        description: 'Avoid importing package:flutter/material.dart outside sail_ui.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    if (context.definingUnit.file.path.contains('/test/')) return;
    registry.addImportDirective(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitImportDirective(ImportDirective node) {
    if (node.uri.stringValue == 'package:flutter/material.dart') {
      rule.reportAtNode(node);
    }
  }
}
