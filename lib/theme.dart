import 'package:flutter/material.dart';

ThemeData basicTheme() {
  TextTheme _basicTextTheme(TextTheme base) {
    return base.copyWith(
        headline: base.headline.copyWith(
          fontSize: 16.0,
          color: Color(0xFFFFFFFF),
        ),
        title: base.title.copyWith(fontSize: 18.0, color: Colors.red),
        display1: base.headline.copyWith(
          fontSize: 24.0,
          color: Colors.white,
        ),
        display2: base.headline.copyWith(
          fontSize: 22.0,
          color: Colors.grey,
        ),
        caption: base.caption.copyWith(
          color: Color(0xFFCCC5AF),
        ),
        body1: base.body1.copyWith(
          color: Colors.white,
        ),
        overline: base.overline.copyWith(color: Color(0xFFFFC107)));
  }

  final ThemeData base = ThemeData.light();
  return base.copyWith(
      textTheme: _basicTextTheme(base.textTheme),
      primaryColorDark: Color(0xFFD32F2F),
      primaryColor: Color(0xFFF44336),
      indicatorColor: Color(0xFF807A6B),
      accentColor: Color(0xFFFFC107),
      iconTheme: IconThemeData(
        color: Color(0xFFFFFFFF),
        size: 20.0,
      ),
      buttonColor: Colors.white,
      backgroundColor: Colors.white,
      tabBarTheme: base.tabBarTheme.copyWith(
        labelColor: Color(0xFFD32F2F),
        unselectedLabelColor: Colors.grey,
      ));
}
