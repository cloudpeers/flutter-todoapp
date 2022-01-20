import 'package:flutter/material.dart';

// colors generated with https://github.com/mbitson/mcg
const MaterialColor swatch = MaterialColor(_swatchPrimaryValue, <int, Color>{
  50: Color(0xFFEDEDF5),
  100: Color(0xFFD1D1E6),
  200: Color(0xFFB3B3D5),
  300: Color(0xFF9495C4),
  400: Color(0xFF7D7EB8),
  500: Color(_swatchPrimaryValue),
  600: Color(0xFF5E5FA4),
  700: Color(0xFF53549A),
  800: Color(0xFF494A91),
  900: Color(0xFF383980),
});
const int _swatchPrimaryValue = 0xFF6667AB;

const MaterialColor swatchAccent = MaterialColor(_swatchAccentValue, <int, Color>{
  100: Color(0xFFCFD0FF),
  200: Color(_swatchAccentValue),
  400: Color(0xFF696BFF),
  700: Color(0xFF5052FF),
});
const int _swatchAccentValue = 0xFF9C9EFF;

ThemeData APP_THEME = ThemeData.from(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: swatch,
    accentColor: Color(_swatchPrimaryValue),
  ),
);
