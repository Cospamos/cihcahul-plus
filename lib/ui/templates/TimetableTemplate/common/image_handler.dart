import 'dart:math';

import 'package:flutter/widgets.dart';

class ImageHandler {
  static String getRndImage(int min, int max) {
    min--;
    max--;
    final idx = min + Random().nextInt(max - min + 1);
    return "assets/blob${idx + 1}.png";
  }

  static List<Widget> getImageList(int imagesCnt) {
    if (imagesCnt < 2) return [Image.asset(getRndImage(1, 5))];
    bool toggle = false;
    List<Widget> images = [];
    String randomImage = getRndImage(6, 8);
    for (int i = 0; i < imagesCnt; ++i) {
      if (toggle) {
        switch (randomImage) {
          case "assets/blob8.png":
            images.add(
              Transform.rotate(angle: -pi / 2, child: Image.asset(randomImage)),
            );
          case "assets/blob7.png":
            images.add(
              Transform.rotate(angle: pi, child: Image.asset(randomImage)),
            );
          case "assets/blob6.png":
            images.add(
              Transform.rotate(
                angle: -pi,
                child: Transform.scale(
                  scaleX: -1,
                  child: Image.asset(randomImage),
                ),
              ),
            );
          default:
            images.add(
              Transform.rotate(
                angle: pi,
                child: Transform.scale(
                  scale: 0.9,
                  child: Image.asset(getRndImage(1, 5)),
                ),
              ),
            );
        }
        toggle = !toggle;
        continue;
      }
      images.add(Image.asset(randomImage));
      toggle = !toggle;
    }

    return images;
  }
}
