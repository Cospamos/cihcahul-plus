import 'package:flutter/material.dart';

Widget backgroundDecor() {
  return SizedBox.expand(
    child: Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Image.asset("assets/decor1.png"),
        ),
        Positioned(
          left: 0,
          top: 150,
          child:Image.asset("assets/decor2.png"),
        )
      ],
    ),
  );
}