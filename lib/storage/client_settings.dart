abstract class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> delete(String key);
}

class ClientSettings {
  final KeyValueStore store;

  const ClientSettings({
    required this.store,
  });

  Future<SettingValue<T>> getValue<T extends Object>(SettingValue<T> setting) async {
    final jsonString = await store.getString(setting.key);
    if (jsonString == null) return setting.withValue(null);

    final value = setting.fromJson(jsonString);

    return setting.withValue(value);
  }

  Future<SettingValue<T>> setValue<T extends Object>(SettingValue<T> setting) async {
    final json = setting.toJson();

    await store.setString(setting.key, json);

    return getValue(setting);
  }
}

abstract class SettingValue<T> {
  String get key;
  T get value => _value ?? defaultValue();
  T? _value;

  SettingValue({T? newValue}) {
    _value = newValue ?? defaultValue();
  }

  /// Passing [_value] null means the [defaultValue] will be used
  /// when calling the [value] getter.
  ///
  /// [withValue] enables creation of a setting without having to reference the class
  ///
  /// In [ClientSettings.getValue] we can try to deserialize
  /// json from local storage, and pass it to an implementation of this method
  /// This should usually just call the constructor with the value
  SettingValue<T> withValue([T? value]);

  /// If [fromJson] returns null, [ClientSettings.getValue] will
  /// pass a null to the [withValue] factory, which means that
  /// when [value] is called, the setting that is returned
  /// will be the result from [defaultValue]
  T? fromJson(String jsonString);

  String toJson();

  T defaultValue();
}
