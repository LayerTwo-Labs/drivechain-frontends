import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A lint rule that warns against using private methods that return Widget
/// inside view classes (State, StatelessWidget).
///
/// Instead of:
/// ```dart
/// class _MyPageState extends State<MyPage> {
///   Widget _buildHeader() { ... }  // Flagged
///   Widget _createContent() { ... }  // Also flagged
/// }
/// ```
///
/// Either inline the code directly, or create a separate widget class:
/// ```dart
/// class Header extends StatelessWidget { ... }
/// ```
///
/// This rule does NOT flag:
/// - Methods in ViewModels, providers, or other non-widget classes
/// - Public methods (not starting with _)
class AvoidBuildMethods extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_build_methods',
    'Avoid private methods returning Widget in views. Either inline the code or extract to a widget class.',
    correctionMessage:
        'If used once, inline the code. If used multiple times, create a StatelessWidget/StatefulWidget class.',
  );

  AvoidBuildMethods()
    : super(
        name: 'avoid_build_methods',
        description: 'Avoid private methods that return Widget in State and StatelessWidget classes.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addMethodDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final name = node.name.lexeme;
    final returnType = node.returnType?.toSource();

    // Only check private methods (starting with _) that return Widget
    if (!name.startsWith('_') || returnType != 'Widget') {
      return;
    }

    // Find the enclosing class
    final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDeclaration == null) return;

    // Check if this class is a view (extends State or StatelessWidget)
    final extendsClause = classDeclaration.extendsClause;
    if (extendsClause == null) return;

    final superclassName = extendsClause.superclass.name.lexeme;

    // Only flag if inside a State or StatelessWidget class
    // This excludes ViewModels, providers, etc.
    final isViewClass = superclassName == 'State' || superclassName == 'StatelessWidget';

    if (isViewClass) {
      rule.reportAtNode(node);
    }
  }
}
