import 'package:collection/collection.dart';
import 'package:sail_ui/sail_ui.dart';

class BitcoinUnitSetting extends SettingValue<BitcoinUnit> {
  BitcoinUnitSetting({super.newValue});

  @override
  String get key => 'bitcoin_unit';

  @override
  BitcoinUnit defaultValue() => BitcoinUnit.btc;

  @override
  String toJson() {
    return value.name;
  }

  @override
  BitcoinUnit? fromJson(String jsonString) {
    return BitcoinUnit.values.firstWhereOrNull(
      (element) => element.name == jsonString,
    );
  }

  @override
  SettingValue<BitcoinUnit> withValue([BitcoinUnit? value]) {
    return BitcoinUnitSetting(
      newValue: value,
    );
  }
}
