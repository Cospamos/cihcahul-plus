import 'package:flutter/material.dart';

Widget backgroundDecor() {
  return SizedBox.expand(
    child: Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Image.asset("assets/decor6.png"),
        ),
        Positioned(
          left: -50,
          top: -40,
          child:Image.asset("assets/decor4.png"),
        ),
        Positioned(
          right: 0,
          top: 200,
          child: Image.asset("assets/decor7.png"),
        )
      ],
    ),
  );
}