import 'package:flutter/material.dart';
import 'package:tickdose/core/constants/dimens.dart';

class TextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: Dimens.fontH1,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: Dimens.fontH2,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: Dimens.fontH3,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: Dimens.fontMd,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: Dimens.fontSm,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: Dimens.fontXs,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: Dimens.fontXs,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );
  
  // Button
  static const TextStyle button = TextStyle(
    fontSize: Dimens.fontSm,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  
  // Label
  static const TextStyle label = TextStyle(
    fontSize: Dimens.fontSm,
    fontWeight: FontWeight.w500,
  );
}
