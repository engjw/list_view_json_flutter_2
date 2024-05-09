import 'package:flutter/material.dart';

class ValueStyles {
  static TextStyle headline = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white);

  static const TextStyle title = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  static TextStyle bodyBlack = const TextStyle(
      fontWeight: FontWeight.w400, fontSize: 16, color: Colors.black);

  static TextStyle bodyGrey = const TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: Color.fromARGB(255, 161, 161, 162));
}
