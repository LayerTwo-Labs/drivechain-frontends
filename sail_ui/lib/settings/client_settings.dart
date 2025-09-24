import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class ClientSettings {
  final KeyValueStore store;
  final Logger log;

  const ClientSettings({required this.store, required this.log});

  Future<SettingValue<T>> getValue<T extends Object>(SettingValue<T> setting) async {
    String? jsonString;
    try {
      jsonString = await store.getString(setting.key);
    } catch (err) {
      // Linux throws here, if the setting is not found
      log.e('could not get $setting value', error: err);
      jsonString = null;
    }
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

class BitwindowClientSettings extends ClientSettings {
  BitwindowClientSettings({required super.store, required super.log});
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
