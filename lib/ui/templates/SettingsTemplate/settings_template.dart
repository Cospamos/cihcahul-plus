import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/ui/templates/SettingsTemplate/components/back_button_container.dart';
import 'package:cihcahul_plus/ui/templates/SettingsTemplate/components/background_decor.dart';
import 'package:cihcahul_plus/ui/templates/SettingsTemplate/components/template_container.dart';
import 'package:flutter/material.dart';

class SettingsTemplate extends StatefulWidget {
  const SettingsTemplate({super.key});

  @override
  State<SettingsTemplate> createState() => _SettingsTemplateState();
}

class _SettingsTemplateState extends State<SettingsTemplate> {
  late final Variable? settingsToggle = ReactiveStore.get("settings_toggle");

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          backgroundDecor(),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                BackButtonContainer(),
                Padding(
                  padding: EdgeInsets.only(top: 114),
                  child: Column(
                    children: [
                      Text(
                        "Setari",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      SizedBox(height: 5),
                      TemplateContainer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  }
}
