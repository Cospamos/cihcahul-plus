import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:flutter/material.dart';

class BackButtonContainer extends StatefulWidget {
  const BackButtonContainer({super.key});
  
  @override
  State<BackButtonContainer> createState() => _BackButtonContainerState();
}

class _BackButtonContainerState extends State<BackButtonContainer> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 50, left: 20, right: 20),
          child: GestureDetector(
            onTap: () {
              final variable = ReactiveStore.get("settings_toggle");
              variable!.set(false);
            },
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: context.theme.primary,
              ),
              child: Icon(Icons.arrow_back),
            ),
          ),
        ),
      ],
    );
  }
}