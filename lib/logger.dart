import 'package:logger/logger.dart';

final printer = PrettyPrinter(
  printTime: true,
  printEmojis: false,
);

final log = Logger(
  level: Level.debug,
  printer: printer,
);
