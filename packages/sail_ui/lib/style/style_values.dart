import 'package:flutter/material.dart';

abstract class SailStyleValues {
  // ---------- PADDINGS AND SPACINGS ----------
  static BorderRadius borderRadiusRegular = BorderRadius.circular(21);
  static BorderRadius borderRadiusButton = BorderRadius.circular(4);

  static const double padding05 = 5;
  static const double padding08 = 8;
  static const double padding10 = 10;
  static const double padding12 = 12;
  static const double padding15 = 15;
  static const double padding20 = 20;
  static const double padding25 = 25;
  static const double padding30 = 30;
  static const double padding40 = 40;
  static const double padding50 = 50;

  // ---------- ICON SIZES ----------
  static const iconSizePrimary = 14.0;

  // ---------- FONTS ----------
  static const lightWeight = FontWeight.w300;
  static const regularWeight = FontWeight.w400;
  static const boldWeight = FontWeight.w500;

  static const TextStyle twentyFour = TextStyle(
    fontSize: 24,
    fontWeight: regularWeight,
  );
  static const TextStyle twentyTwo = TextStyle(
    fontSize: 22,
    fontWeight: regularWeight,
  );
  static const TextStyle twenty = TextStyle(
    fontSize: 20,
    fontWeight: regularWeight,
  );
  static const TextStyle fifteen = TextStyle(
    fontSize: 15,
    fontWeight: regularWeight,
  );
  static const TextStyle thirteen = TextStyle(
    fontSize: 13,
    fontWeight: regularWeight,
  );
  static const TextStyle twelve = TextStyle(
    fontSize: 12,
    fontWeight: regularWeight,
  );
  static const TextStyle eleven = TextStyle(
    fontSize: 11,
    fontWeight: regularWeight,
  );
  static const TextStyle ten = TextStyle(
    fontSize: 10,
    fontWeight: regularWeight,
  );
}
