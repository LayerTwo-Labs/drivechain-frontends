import 'package:launcher/providers/config_provider.dart';
import 'package:sail_ui/config/binaries.dart';

class MockConfigProvider extends ConfigProvider {
  final _testConfigs = [
    ParentChain(),
  ];

  MockConfigProvider() : super(baseDir: '/tmp/test');

  @override
  List<Binary> get configs => _testConfigs;

  @override
  Future<void> initialize() async {
    // No-op for tests
  }
}
