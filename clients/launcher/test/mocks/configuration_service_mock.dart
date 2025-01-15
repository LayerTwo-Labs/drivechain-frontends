import 'package:launcher/models/chain_config.dart';
import 'package:launcher/services/configuration_service.dart';

class MockConfigurationService extends ConfigurationService {
  final _testConfigs = ChainConfigs(
    schemaVersion: '1.0',
    chains: [
      ChainConfig(
        id: 'test-chain',
        version: '1.0.0',
        displayName: 'Test Chain',
        description: 'A test chain for unit tests',
        repoUrl: 'https://github.com/test/test-chain',
        chainType: 0,
        slot: 1,
        binary: const {'linux': 'test-binary'},
        directories: DirectoryConfig(
          base: const {'linux': 'test-dir'},
          wallet: 'wallet',
        ),
        download: DownloadConfig(
          baseUrl: 'https://test.com/downloads',
          files: const {'linux': 'test-binary.tar.gz'},
          sizes: const {'linux': 1000},
          hashes: const {'linux': 'test-hash'},
        ),
        network: NetworkConfig(port: 8000),
      ),
    ],
  );

  MockConfigurationService() : super(baseDir: '/tmp/test');

  @override
  ChainConfigs get configs => _testConfigs;

  @override
  Future<void> initialize() async {
    // No-op for tests
  }
}