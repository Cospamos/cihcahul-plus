import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/services/timetable_processor.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:cihcahul_plus/ui/templates/TimetableTemplate/components/background_decor.dart';
import 'package:cihcahul_plus/ui/templates/TimetableTemplate/components/header_container.dart';
import 'package:cihcahul_plus/ui/templates/TimetableTemplate/components/nav_panel.dart';
import 'package:cihcahul_plus/ui/templates/TimetableTemplate/components/settings_button_container.dart';
import 'package:cihcahul_plus/ui/templates/TimetableTemplate/components/timetable_container.dart';
import 'package:flutter/material.dart';

class TimetableTemplate extends StatefulWidget {
  const TimetableTemplate({super.key});
  @override
  State<TimetableTemplate> createState() => _TimetableTemplateState();
}

class _TimetableTemplateState extends State<TimetableTemplate> {
  final startNavPos = 280;
  final startHeadPos = 160;
  final ScrollController _controller = ScrollController();
  final ValueNotifier<double> navTop = ValueNotifier(280);
  final ValueNotifier<double> headerTop = ValueNotifier(160);
  late final Variable? _navVar;
  final bool _autoDaySwitch = ReactiveStore.get("auto_day_switch")?.get() ?? false;
  int _previousSelected = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final scroll = _controller.offset;
      final nav = startNavPos - scroll;
      if (navTop.value != (nav < 0 ? 0.0 : nav)) {
        navTop.value = nav < 0 ? 0.0 : nav;
      }
      final header = startHeadPos - scroll;
      if (headerTop.value != header) {
        headerTop.value = header;
      }
    });

    _navVar =
        ReactiveStore.get('nav_selected') ??
        ReactiveStore.createAndGet(
          name: 'nav_selected',
          value: 0,
          toSave: true,
        );

    if (_navVar?.get() == null) {
      _navVar?.set(0);
    }
    _previousSelected = _navVar?.get() as int? ?? 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    navTop.dispose();
    headerTop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.now();
    final todayIdx = dateTime.weekday - 1;
    return FutureBuilder<Duration>(
      future: TimetableProcessor().requestLastTimeInterval(todayIdx),
      initialData: const Duration(hours: 16, minutes: 30),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final int virtulaDayIdx = snapshot.hasData
            ? () {
                final nowDuration = Duration(
                  hours: dateTime.hour,
                  minutes: dateTime.minute,
                );
                final lastLessonDuration = snapshot.data!;
                return (nowDuration >= lastLessonDuration && _autoDaySwitch && todayIdx != 5 && todayIdx != 4)
                    ? todayIdx + 1
                    : todayIdx;
              }()
            : todayIdx;
        return Stack(
          children: [
            backgroundDecor(),
            RefreshIndicator(
              onRefresh: () async {
                setState(() {});
                await Future.delayed(const Duration(milliseconds: 400));
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_controller.hasClients) {
                    _controller.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                    navTop.value = startNavPos.toDouble();
                    headerTop.value = startHeadPos.toDouble();
                  }
                });
              },
              displacement: 50,
              color: context.theme.primaryContainer,
              backgroundColor: Colors.white,
              notificationPredicate: (notification) {
                return notification.depth == 0;
              },
              child: SingleChildScrollView(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: StreamBuilder<int>(
                    stream: _navVar!.stream.cast<int>(),
                    initialData: _navVar.get() as int? ?? 0,
                    builder: (context, snapshot) {
                      final selected = snapshot.data ?? 0;
                      if (selected != _previousSelected) {
                        _previousSelected = selected;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_controller.hasClients) {
                            _controller.animateTo(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        });
                      }
                      Widget content = selected == 0
                          ? TimetableContainerByDay(
                              key: ValueKey(
                                'timetable_by_day_refresh_${DateTime.now().millisecondsSinceEpoch}',
                              ),
                              initialDayIdx: virtulaDayIdx,
                              onDayChanged: () {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (_controller.hasClients) {
                                    _controller.jumpTo(0);
                                    navTop.value = startNavPos.toDouble();
                                    headerTop.value = startHeadPos.toDouble();
                                  }
                                });
                              },
                            )
                          : TimetableContainer();
                      return Stack(
                        children: [settingsButtonContainer(context), content],
                      );
                    },
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: navTop,
              child: NavPanel(
                onTabChanged: () {
                  if (_controller.hasClients) {
                    _controller.animateTo(
                      0,
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOutCubicEmphasized,
                    );
                    final double newNav = startNavPos - 0;
                    navTop.value = newNav < 0 ? 0.0 : newNav;
                    final double newHeader = startHeadPos - 0;
                    headerTop.value = newHeader < 0 ? 0.0 : newHeader;
                  }
                },
              ),
              builder: (_, top, child) {
                return Positioned(top: top, left: 0, right: 0, child: child!);
              },
            ),
            ValueListenableBuilder<double>(
              valueListenable: headerTop,
              child: headerContentContainer(context),
              builder: (_, top, child) {
                return Positioned(top: top, left: 0, right: 0, child: child!);
              },
            ),
          ],
        );
      },
    );
  }
}
