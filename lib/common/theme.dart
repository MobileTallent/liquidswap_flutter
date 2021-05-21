import 'package:flutter/material.dart';

final appTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  textTheme: TextTheme(
    headline1: TextStyle(
      fontFamily: 'Corben',
      fontWeight: FontWeight.w700,
      fontSize: 24,
      color: Colors.black,
    ),
  ),
);

final mainDecoration = BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF003E78), Color(0xFF000E3F)]));

final fontBigTitle = TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
  fontSize: 32,
);

final fontSmallTitle = TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
  fontSize: 24,
);

final fontNormal = TextStyle(
  fontFamily: 'SF Pro Text',
  fontWeight: FontWeight.w400,
  fontSize: 16,
);

final fontNormalGray = fontNormal.merge(TextStyle(color: Colors.grey));

final colorPanels = Color(0xFF003E78);
