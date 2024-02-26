import 'package:collection/collection.dart';
import 'package:sidesail/storage/client_settings.dart';

enum SailNetworkValues { mainnet, regtest }

extension AsString on SailNetworkValues {
  String asString() {
    switch (this) {
      case SailNetworkValues.mainnet:
        return 'mainnet';
      case SailNetworkValues.regtest:
        return 'regtest';
    }
  }
}

class NetworkSetting extends SettingValue<SailNetworkValues> {
  NetworkSetting({super.newValue});

  // default network to mainnet
  @override
  String get key => 'network';

  @override
  SailNetworkValues defaultValue() => SailNetworkValues.mainnet;

  @override
  String toJson() {
    return value.name;
  }

  @override
  SailNetworkValues? fromJson(String jsonString) {
    return SailNetworkValues.values.firstWhereOrNull(
      (element) => element.name == jsonString,
    );
  }

  @override
  SettingValue<SailNetworkValues> withValue([SailNetworkValues? value]) {
    return NetworkSetting(
      newValue: value,
    );
  }
}
