import 'package:flutter/material.dart';

int _orangePrimaryValue = 0xffF26522;
MaterialColor primaryOrange = MaterialColor(
    _orangePrimaryValue,
    <int, Color>{
        50: const Color(0xffFEE5D6),
        100: const Color(0xffFDC9A8),
        200: const Color(0xffFBAD79),
        300: const Color(0xffF9914B),
        800: const Color(0xffD1541C),
        900: Color(_orangePrimaryValue),
    }
);

int _darkPrimaryValue = 0xff18181B;
MaterialColor primaryDark = MaterialColor(
    _darkPrimaryValue,
    <int, Color>{
            50: const Color(0xffE3E3E4),
            100: const Color(0xffB9B9BC),
            200: const Color(0xff8B8B8F),
            300: const Color(0xff5D5D62),
            800: const Color(0xff0F0F11),
            900: Color(_darkPrimaryValue),
    }
);

// Define the colors as integers
int _goldBright = 0xFFFFF176;
int _goldMedium = 0xFFFFD700;
int _goldDeep = 0xFFFFA000;

// Define the gradient using these
final LinearGradient metallicGold = LinearGradient(
  colors: [
    Color(_goldBright),
    Color(_goldMedium),
    Color(_goldDeep),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final LinearGradient bluePinkGradient = LinearGradient(
  colors: [
    Color(0xFF2196F3), // blue
    Color(0xFFF83E7E), // pink
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient royalGold = LinearGradient(
  colors: [
    Colors.white,
    Color(0xFFFFF176), // bright yellow gold
    Color(0xFFFFD700), // pure gold
    Color(0xFFB8860B), // dark metallic gold
  ],
);

 LinearGradient pearlWhite = LinearGradient(
  colors: [
    Color(0xFFFFFFFF), // pure white
    Colors.purpleAccent,
    Colors.indigo.shade300,
  ],
);