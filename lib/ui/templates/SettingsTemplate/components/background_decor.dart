import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:flutter/material.dart';

Widget backgroundDecor(BuildContext context) {
  // Violet keeps the exact original code path (no color arguments at all —
  // identical to how this file always looked) so there's zero chance of it
  // drifting from how it's actually shipped. Only the local neutral-design
  // experiment tints these shapes.
  final isNeutral = ReactiveStore.get("design")?.get() == "neutral";
  final tint = context.theme.decorAccent;

  Widget decorImage(String asset) {
    if (!isNeutral) return Image.asset(asset);
    return Image.asset(asset, color: tint, colorBlendMode: BlendMode.srcIn);
  }

  return SizedBox.expand(
    child: Stack(
      children: [
        Positioned(top: 0, right: 0, child: decorImage("assets/decor6.png")),
        Positioned(
          left: -50,
          top: -40,
          child: decorImage("assets/decor4.png"),
        ),
        Positioned(right: 0, top: 200, child: decorImage("assets/decor7.png")),
      ],
    ),
  );
}
