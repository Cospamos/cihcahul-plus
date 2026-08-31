import 'package:cihcahul_plus/core/services/localization_service.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:flutter/material.dart';

class NavPanel extends StatefulWidget {
  final VoidCallback? onTabChanged;
  const NavPanel({super.key, this.onTabChanged});

  @override
  State<NavPanel> createState() => _NavPanelState();
}

class _NavPanelState extends State<NavPanel> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = ReactiveStore.get('nav_selected')?.get() ?? 0;
  }

  void _setIndex(int index) async {
    setState(() => _selectedIndex = index);
    final varNav =
        ReactiveStore.get('nav_selected') ??
        ReactiveStore.createAndGet(
          name: 'nav_selected',
          value: 0,
          toSave: true,
        );

    await varNav?.set(index);
    widget.onTabChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.primary,
      child: Container(
        width: double.infinity,
        height: 40,
        margin: const EdgeInsets.only(top: 35, left: 20, right: 20, bottom: 10),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: context.theme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final segmentWidth = width / 2;

            return Stack(
              alignment: Alignment.center,
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  left: _selectedIndex * segmentWidth,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: segmentWidth,
                    decoration: BoxDecoration(
                      color: context.theme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _setIndex(0),
                        borderRadius: BorderRadius.circular(4),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              L10n.tr("nav_today"),
                              textAlign: TextAlign.center,
                              // Same color selected or not — the sliding
                              // highlight behind the text already shows
                              // which tab is active, so the text doesn't
                              // need its own color swap (which broke down
                              // on palettes where the "accent" color is
                              // close in tone to the highlight itself).
                              style: TextStyle(color: context.theme.textPrimary),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => _setIndex(1),
                        borderRadius: BorderRadius.circular(4),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              L10n.tr("nav_week"),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: context.theme.textPrimary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
