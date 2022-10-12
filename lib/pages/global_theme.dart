import 'package:flutter/material.dart';

class GlobalTheme {
  static Widget backImg(Widget child){
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/wallhaven_background.jpg'),
          fit:BoxFit.none,
        ),
      ),
      child:child,
    );
  }
}