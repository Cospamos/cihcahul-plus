import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/localization_service.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToggleContainer extends StatefulWidget {
  final String name;
  final String id;
  final String? description;

  const ToggleContainer({
    super.key,
    required this.name,
    required this.id,
    this.description,
  });

  @override
  State<StatefulWidget> createState() => _ToggleContainerState();
}

class _ToggleContainerState extends State<ToggleContainer> {
  late Variable variable;

  @override
  void initState() {
    super.initState();
    variable =
        ReactiveStore.get(widget.id) ??
        ReactiveStore.createAndGet(
          name: widget.id,
          value: false,
          toSave: true,
        )!;
  }

  void setVar(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(widget.id, newValue);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.name;
    final descriprion = widget.description;
    final currentValue = variable.get();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                name,
                style: context.theme.textTheme.bodyLarge!.copyWith(
                  color: context.theme.textPrimary,
                ),
              ),
              if (descriprion != null && descriprion.isNotEmpty)
                Text(
                  descriprion,
                  softWrap: true,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: context.theme.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: context.theme.chipTrack,
            borderRadius: BorderRadius.circular(8),
          ),
          child: GestureDetector(
            onTap: () {
              variable.set(!variable.get());
              setVar(variable.get());
              setState(() {});
            },
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: currentValue == true
                        ? context.theme.chipSelected
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Text(
                    L10n.tr("toggle_on"),
                    style: TextStyle(
                      color: currentValue == true
                          ? context.theme.chipSelectedText
                          : context.theme.chipUnselectedText,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: currentValue == false
                        ? context.theme.chipSelected
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Text(
                    L10n.tr("toggle_off"),
                    style: TextStyle(
                      color: currentValue == false
                          ? context.theme.chipSelectedText
                          : context.theme.chipUnselectedText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
