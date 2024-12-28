import 'package:get_it/get_it.dart';
import 'configuration_service.dart';
import 'download_manager.dart';
import 'resource_downloader.dart';

/// Registers and provides access to application services
class ServiceProvider {
  static final _getIt = GetIt.instance;

  /// Initialize and register all services
  static Future<void> initialize() async {
    // Register configuration service
    _getIt.registerSingleton<ConfigurationService>(ConfigurationService());
    await _getIt<ConfigurationService>().initialize();

    // Register resource downloader
    _getIt.registerSingleton<ResourceDownloader>(ResourceDownloader());

    // Register download manager
    _getIt.registerSingleton<DownloadManager>(DownloadManager());
    await _getIt<DownloadManager>().initialize();
  }

  /// Get a registered service instance
  static T get<T extends Object>() => _getIt<T>();

  /// Clean up resources
  static void dispose() {
    _getIt<DownloadManager>().dispose();
  }
}
