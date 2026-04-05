import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:flutter/material.dart';

class SwitchContainer extends StatefulWidget {
  final String name;
  final List<String> variants;
  final List<String> variatsId;
  final String id;
  final String defaultVariant;
  final String? description;

  const SwitchContainer({
    super.key,
    required this.name,
    required this.id,
    required this.variants,
    required this.variatsId,
    required this.defaultVariant,
    this.description,
  });

  @override
  State<SwitchContainer> createState() => _SwitchContainerState();
}

class _SwitchContainerState extends State<SwitchContainer> {
  late final Variable? v;
  @override
  void initState() {
    v = ReactiveStore.get(widget.id) ??
        ReactiveStore.createAndGet(
          name: widget.id,
          value: widget.defaultVariant,
          toSave: true,
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.name;
    final variants = widget.variants;
    final id = widget.id;
    final descriprion = widget.description;
    final currentValue = ReactiveStore.get(id)?.get();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: descriprion != null && descriprion.isNotEmpty ? 20 : 0,
            ),
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
        ),
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: context.theme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              ...variants.asMap().entries.map((entry) {
                int idx = entry.key;
                String variant = entry.value;
                return GestureDetector(
                  onTap: () {
                    v!.set(widget.variatsId[idx]);
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: currentValue == widget.variatsId[idx]
                          ? context.theme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: EdgeInsets.all(5),
                    child: Text(
                      variant,
                      style: currentValue == widget.variatsId[idx]
                          ? TextStyle(color: context.theme.surfaceDim)
                          : TextStyle(),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
