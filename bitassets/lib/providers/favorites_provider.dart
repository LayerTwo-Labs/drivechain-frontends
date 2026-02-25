import 'package:bitassets/settings/favorites_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:get_it/get_it.dart';

class FavoritesProvider extends ChangeNotifier {
  final ClientSettings _settings = GetIt.I.get<ClientSettings>();

  Set<String> _favorites = {};

  FavoritesProvider() {
    _loadFavorites();
  }

  Set<String> get favorites => _favorites;

  bool isFavorite(String assetHash) => _favorites.contains(assetHash);

  Future<void> _loadFavorites() async {
    final setting = await _settings.getValue(FavoriteAssetsSetting());
    _favorites = setting.value;
    notifyListeners();
  }

  Future<void> toggleFavorite(String assetHash) async {
    if (_favorites.contains(assetHash)) {
      _favorites = Set<String>.from(_favorites)..remove(assetHash);
    } else {
      _favorites = Set<String>.from(_favorites)..add(assetHash);
    }
    await _settings.setValue(FavoriteAssetsSetting(newValue: _favorites));
    notifyListeners();
  }

  Future<void> addFavorite(String assetHash) async {
    if (!_favorites.contains(assetHash)) {
      _favorites = Set<String>.from(_favorites)..add(assetHash);
      await _settings.setValue(FavoriteAssetsSetting(newValue: _favorites));
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String assetHash) async {
    if (_favorites.contains(assetHash)) {
      _favorites = Set<String>.from(_favorites)..remove(assetHash);
      await _settings.setValue(FavoriteAssetsSetting(newValue: _favorites));
      notifyListeners();
    }
  }

  Future<void> clearFavorites() async {
    _favorites = {};
    await _settings.setValue(FavoriteAssetsSetting(newValue: _favorites));
    notifyListeners();
  }
}
