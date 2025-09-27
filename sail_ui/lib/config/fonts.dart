import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void addFontLicense() {
  LicenseRegistry.addLicense(() async* {
    final String license = await rootBundle.loadString('fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(<String>['google_fonts'], license);
  });
}
