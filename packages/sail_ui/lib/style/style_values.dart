import 'package:flutter/material.dart';

abstract class SailStyleValues {
  // ---------- PADDINGS AND SPACINGS ----------
  static BorderRadius borderRadiusRegular = BorderRadius.circular(21);
  static BorderRadius borderRadiusButton = BorderRadius.circular(4);

  static const double padding5 = 5;
  static const double padding8 = 8;
  static const double padding10 = 10;
  static const double padding15 = 15;
  static const double padding20 = 20;
  static const double padding25 = 25;
  static const double padding30 = 30;
  static const double padding40 = 40;
  static const double padding45 = 45;

  // ---------- ICON SIZES ----------
  static const iconSizePrimary = 30.0;

  // ---------- FONTS ----------
  static const lightWeight = FontWeight.w300;
  static const regularWeight = FontWeight.w400;
  static const mediumWeight = FontWeight.w500;

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
    fontSize: 16,
    fontWeight: regularWeight,
  );
  static const TextStyle thirteen = TextStyle(
    fontSize: 14,
    fontWeight: regularWeight,
  );
  static const TextStyle twelve = TextStyle(
    fontSize: 12,
    fontWeight: regularWeight,
  );
  static const TextStyle eleven = TextStyle(
    fontSize: 12,
    fontWeight: regularWeight,
  );
}
