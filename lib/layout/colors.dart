import 'package:flutter/material.dart';

class AppColors {
  static Color primary = const Color.fromRGBO(67, 80, 94, 1);
  static Color second = const Color.fromRGBO(88, 104, 121, 1);
  static Color patternText = const Color.fromRGBO(173, 173, 173, 1);

  /* static const MaterialColor kToDark = MaterialColor(
    0xff43505e, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xff56626e), //10%
      100: Color(0xff69737e), //20%
      200: Color(0xff7b858e), //30%
      300: Color(0xff8e969e), //40%
      400: Color(0xffa1a8af), //50%
      500: Color(0xffb4b9bf), //60%
      600: Color(0xffc7cbcf), //70%
      700: Color(0xffd9dcdf), //80%
      800: Color(0xffeceeef), //90%
      900: Color(0xffffffff), //100%
    },
  ); */

  static const MaterialColor kToDark = MaterialColor(0xFF3E5A86, <int, Color>{
    50: Color(0xFFE8EBF0),
    100: Color(0xFFC5CEDB),
    200: Color(0xFF9FADC3),
    300: Color(0xFF788CAA),
    400: Color(0xFF5B7398),
    500: Color(0xFF3E5A86),
    600: Color(0xFF38527E),
    700: Color(0xFF304873),
    800: Color(0xFF283F69),
    900: Color(0xFF1B2E56),
  });
}
