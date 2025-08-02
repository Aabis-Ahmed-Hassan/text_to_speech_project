import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class MyChipTheme {
  MyChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: Colors.grey.withValues(alpha: 0.4),
    labelStyle: const TextStyle(color: Colors.black),
    selectedColor: MyColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: Colors.white,
  );

  static ChipThemeData darkChipTheme = const ChipThemeData(
    disabledColor: MyColors.darkerGrey,
    labelStyle: TextStyle(color: Colors.white),
    selectedColor: MyColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: Colors.white,
  );
}

//
// import 'package:flutter/material.dart';
//
// import '../../constants/colors.dart';
//
// class MyChipTheme {
//   MyChipTheme._();
//
//   static ChipThemeData lightChipTheme = ChipThemeData(
//     disabledColor: MyColors.grey.withValues(alpha: 0.4),
//     labelStyle: const TextStyle(color: MyColors.black),
//     selectedColor: MyColors.primary,
//     padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
//     checkmarkColor: MyColors.white,
//   ); // ChipThemeData
//
//   static ChipThemeData darkChipTheme = const ChipThemeData(
//     disabledColor: MyColors.darkerGrey,
//     labelStyle: TextStyle(color: MyColors.white),
//     selectedColor: MyColors.primary,
//     padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
//     checkmarkColor: MyColors.white,
//   ); // ChipThemeData
// }
