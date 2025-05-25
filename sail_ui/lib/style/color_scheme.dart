import 'dart:ui';

/// References the color scheme
abstract class SailColorScheme {
  // both theme colors
  static const blue = Color(0xff0D7FFF);
  static const blueDark = Color(0xff0A5CBF);
  static const blueLight = Color(0xffE6F2FF);
  static const pinkLight = Color(0xffFEC1D5);
  static const pink = Color(0xffFF0000);
  static const red = Color(0xffFF0000);
  static const redLight = Color(0xffFD7979);
  static const black = Color(0xff000000);
  static const blackKindaLight = Color.fromARGB(255, 31, 31, 31);
  static const blackLighter = Color.fromARGB(255, 45, 45, 45);
  static const blackLightest = Color(0xff64748B);
  static const purple = Color(0xff5400AA);
  static const greenLight = Color(0xff79FD7E);
  static const green = Color(0xff2AB517);
  static const orange = Color(0xffF7931E);
  static const orangeLight = Color(0xffFFEFDD);
  static const white = Color(0xffFFFFFF);
  static const whiteDark = Color(0xffE7E7E7);
  static const greyDark = Color(0xff3C3B3B);
  static const greyMiddle = Color(0xffC1C1C1);
  static const greyLight = Color(0xffE0E0E0);

  static const superLightGreen = Color(0xffEEF8ED);
  static const lightGreen = Color(0xffEEF8ED);
  static const mediumGreen = Color(0xff5CBE45);
  static const mediumDarkGreen = Color(0xff59B23A);
  static const formFieldGrey = Color(0xffE9EBF0);
  static const whiteLight = Color(0xffEEEFFC);

  // modal colors
  static const darkActionModalBackground = Color.fromRGBO(29, 30, 43, 1);
  static const darkTextHint = Color(0xff4D4F69);
}
