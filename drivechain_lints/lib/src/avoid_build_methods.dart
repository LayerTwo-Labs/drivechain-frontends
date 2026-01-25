import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

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
class AvoidBuildMethods extends DartLintRule {
  AvoidBuildMethods() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_build_methods',
    problemMessage:
        'Avoid private methods returning Widget in views. Either inline the code or extract to a widget class.',
    correctionMessage:
        'If used once, inline the code. If used multiple times, create a StatelessWidget/StatefulWidget class.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
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

      final superclassName = extendsClause.superclass.name2.lexeme;

      // Only flag if inside a State or StatelessWidget class
      // This excludes ViewModels, providers, etc.
      final isViewClass = superclassName == 'State' || superclassName == 'StatelessWidget';

      if (isViewClass) {
        reporter.atNode(node, _code);
      }
    });
  }
}
