import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thunder/routing/router.dart';

String _describe(List<AutoRoute> routes, [String indent = '']) {
  final out = StringBuffer();
  for (final route in routes) {
    out.writeln('$indent${route.name} initial=${route.initial} guards=${route.guards.map((g) => g.runtimeType)}');
    out.write(_describe(route.children ?? const [], '$indent  '));
  }
  return out.toString();
}

void main() {
  test('the shell routes keep the route tree, the guards and the order of the thunder router', () {
    expect(_describe(AppRouter().routes), '''
SidechainHomeRoute initial=true guards=(NetworkGuard, WalletGuard, PasswordGuard)
  ParentChainRoute initial=false guards=()
  ExplorerRoute initial=false guards=()
  BmmRoute initial=false guards=()
  SidechainHomepageRoute initial=true guards=()
  SidechainSettingsRoute initial=false guards=()
  ConsoleTabRoute initial=false guards=()
LogRoute initial=false guards=()
ShutDownRoute initial=false guards=()
SidechainConfigureHomepageRoute initial=false guards=()
UnlockWalletRoute initial=false guards=()
SailCreateWalletRoute initial=false guards=()
BackupWalletRoute initial=false guards=()
RestoreWalletRoute initial=false guards=()
BitcoinConfEditorRoute initial=false guards=()
EnforcerConfEditorRoute initial=false guards=()
SidechainConfEditorRoute initial=false guards=()
SailTestRoute initial=false guards=()
''');
  });
}
