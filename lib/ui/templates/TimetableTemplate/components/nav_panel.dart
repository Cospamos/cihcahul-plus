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
                              "Orarul pe azi",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? _selectedIndex == 0
                                          ? context.theme.textPrimary
                                          : context.theme.primary
                                    : _selectedIndex == 0
                                    ? context.theme.surface
                                    : context.theme.textPrimary,
                              ),
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
                              "Toate zilele",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? _selectedIndex == 0
                                          ? context.theme.primary
                                          : context.theme.textPrimary
                                    : _selectedIndex == 0
                                    ? context.theme.textPrimary
                                    : context.theme.surface,
                              ),
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
