import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

/// State that belongs to one network and must be dropped when it changes.
abstract interface class NetworkScoped {
  Future<void> onNetworkChanged();
}

/// Registers a provider with GetIt and enrols it for network resets in one
/// call, so a new provider cannot be added and then silently forgotten.
abstract final class NetworkScopedRegistry {
  static final List<NetworkScoped> _enrolled = [];
  static final List<NetworkScoped Function()> _lazy = [];

  static T register<T extends Object>(T instance) {
    GetIt.I.registerSingleton<T>(instance);
    if (instance is NetworkScoped) {
      _enrolled.add(instance);
    }
    return instance;
  }

  static T enrol<T extends NetworkScoped>(T instance) {
    _enrolled.add(instance);
    return instance;
  }

  /// Enrols a lazily-registered provider, resolved from GetIt only when a
  /// network change actually happens.
  static void enrolLazy<T extends Object>() {
    _lazy.add(() => GetIt.I.get<T>() as NetworkScoped);
  }

  /// Drops every enrolled provider's state. One failure must not stop the rest,
  /// or the network swap leaves some providers on the old chain.
  static Future<void> clearAll() async {
    final resolved = <NetworkScoped>[..._enrolled];
    for (final supplier in List<NetworkScoped Function()>.of(_lazy)) {
      try {
        resolved.add(supplier());
      } catch (e) {
        if (GetIt.I.isRegistered<Logger>()) {
          GetIt.I.get<Logger>().e('could not resolve a network-scoped provider: $e');
        }
      }
    }

    for (final provider in resolved) {
      try {
        await provider.onNetworkChanged();
      } catch (e) {
        if (GetIt.I.isRegistered<Logger>()) {
          GetIt.I.get<Logger>().e('network reset failed for ${provider.runtimeType}: $e');
        }
      }
    }
  }

  static void clearRegistrations() {
    _enrolled.clear();
    _lazy.clear();
  }
}
