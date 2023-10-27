import 'package:flutter/material.dart';

abstract class SailStyleValues {
  // ---------- PADDINGS AND SPACINGS ----------
  static BorderRadius borderRadiusRegular = BorderRadius.circular(21);

  static const double padding5 = 5;
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

  static const TextStyle text25Bold = TextStyle(
    fontSize: 25,
    fontWeight: mediumWeight,
  );
  static const TextStyle text25 = TextStyle(
    fontSize: 25,
    fontWeight: regularWeight,
  );
  static const TextStyle text14Bold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle text16 = TextStyle(
    fontSize: 16,
  );
  static const TextStyle text16Bold = TextStyle(
    fontSize: 16,
    fontWeight: mediumWeight,
  );
  static const TextStyle text18 = TextStyle(
    fontSize: 18,
  );
  static const TextStyle text14 = TextStyle(
    fontSize: 14,
  );
  static const TextStyle text13Bold = TextStyle(
    fontSize: 13,
    fontWeight: mediumWeight,
  );
  static const TextStyle text11 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // 'new' text values from here on out
  static const TextStyle medium35 = TextStyle(
    fontSize: 35,
    fontWeight: mediumWeight,
  );
  static const TextStyle medium30 = TextStyle(
    fontSize: 30,
    fontWeight: mediumWeight,
  );
  static const TextStyle medium25 = TextStyle(
    fontSize: 25,
    fontWeight: mediumWeight,
  );
  static const TextStyle medium20 = TextStyle(
    fontSize: 20,
    fontWeight: mediumWeight,
  );
  static const TextStyle medium16 = TextStyle(
    fontSize: 16,
    fontWeight: mediumWeight,
  );
  static const TextStyle regular16 = TextStyle(
    fontSize: 16,
    fontWeight: regularWeight,
  );
  static const TextStyle regular14 = TextStyle(
    fontSize: 14,
    fontWeight: regularWeight,
  );
  static const TextStyle medium14 = TextStyle(
    fontSize: 14,
    fontWeight: mediumWeight,
  );
  static const TextStyle light14 = TextStyle(
    fontSize: 14,
    fontWeight: lightWeight,
  );
  static const TextStyle regular12 = TextStyle(
    fontSize: 12,
    fontWeight: regularWeight,
  );
  static const TextStyle light12 = TextStyle(
    fontSize: 12,
    fontWeight: lightWeight,
  );
  static const TextStyle medium12 = TextStyle(
    fontSize: 12,
    fontWeight: mediumWeight,
  );
  static const TextStyle medium10 = TextStyle(
    fontSize: 10,
    fontWeight: mediumWeight,
  );
}
