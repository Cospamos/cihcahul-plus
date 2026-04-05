import 'dart:async';

import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/services/timetable_processor.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:cihcahul_plus/core/utils/converter.dart';
import 'package:cihcahul_plus/core/utils/getter.dart';
import 'package:cihcahul_plus/ui/templates/TimetableTemplate/common/lesson_container.dart';
import 'package:cihcahul_plus/ui/widgets/headinfo_container.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:cihcahul_plus/ui/templates/TimetableTemplate/common/image_handler.dart';

class TimetableContainer extends StatefulWidget {
  const TimetableContainer({super.key});

  @override
  State<TimetableContainer> createState() => _TimetableContainerState();
}

class _TimetableContainerState extends State<TimetableContainer> {
  @override
  void initState() {
    final nowDay = DateTime.now().weekday - 1;
    ReactiveStore.get("day_idx")?.set(nowDay);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(top: 250),
      child: Container(
        padding: EdgeInsets.only(top: 110, bottom: 30, left: 20, right: 20),
        width: double.infinity,
        constraints: BoxConstraints(minHeight: screenHeight - 250),
        decoration: BoxDecoration(
          color: context.theme.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: FutureBuilder<List<List<List<List<String>>>>>(
          future: TimetableProcessor().parseTimetable(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}\n\n${snapshot.stackTrace}");
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: 50),
                child: Text("Datele nu au fost regasite"),
              );
            }

            final days = snapshot.data!;
            return Column(
              children: List.generate(days.length, (dayIdx) {
                final intervals = days[dayIdx];
                if (intervals.isEmpty) return SizedBox.shrink();

                return Column(
                  children: [
                    if (dayIdx != 0) SizedBox(height: 30),
                    ...List.generate(intervals.length, (i) {
                      final lessons = intervals[i];
                      final interval = lessons.first[0];
                      List<Widget> images = ImageHandler.getImageList(
                        lessons.length,
                      );
                      int idx = -1;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          HeadInfoContainer(
                            text1: Text(
                              interval,
                              style: context.theme.textTheme.bodyMedium!
                                  .copyWith(color: context.theme.textPrimary),
                            ),
                            text2: Text(
                              Converter.iTDay(dayIdx),
                              style: context.theme.textTheme.bodyMedium!
                                  .copyWith(color: context.theme.textPrimary),
                            ),
                          ),
                          ...lessons.map((data) {
                            idx++;
                            return LessonContainer(
                              image: images[idx],
                              subject: data[1],
                              teacher: data[2],
                              classroom: data[3],
                              weeks: data[4],
                              group: data[5],
                            );
                          }),
                        ],
                      );
                    }),
                  ],
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class TimetableContainerByDay extends StatefulWidget {
  final int initialDayIdx;
  final VoidCallback? onDayChanged;
  const TimetableContainerByDay({
    super.key,
    required this.initialDayIdx,
    this.onDayChanged,
  });

  @override
  State<TimetableContainerByDay> createState() =>
      _TimetableContainerByDayState();
}

class _TimetableContainerByDayState extends State<TimetableContainerByDay> {
  late PageController _pageController;
  late int _currentDayIdx;

  late final Variable? _showWeekendVar;

  static late int _daysInWeek;

  static const int _fakeWeeks = 1000;
  static late int _totalPages;

  final int _middleWeek = _fakeWeeks ~/ 2;
  late int _middlePage;

  late Variable? _savedDayIdx;

  late int _initialParity;
  late int _initialWeekStart;

  @override
  void initState() {
    super.initState();

    _showWeekendVar = ReactiveStore.get("show_weekend");
    _daysInWeek = (_showWeekendVar?.get() ?? false) ? 7 : 5;
    _totalPages = _daysInWeek * _fakeWeeks;

    _currentDayIdx = widget.initialDayIdx;
    if (_currentDayIdx >= _daysInWeek) {
      _currentDayIdx = 0;
    }
    _middlePage = _middleWeek * _daysInWeek + _currentDayIdx;

    _pageController = PageController(initialPage: _middlePage);

    _savedDayIdx =
        ReactiveStore.get("day_idx") ??
        ReactiveStore.createAndGet(
          name: "day_idx",
          value: _currentDayIdx,
          toSave: false,
        );
    _savedDayIdx!.set(_currentDayIdx);

    _initialParity = Getter.getWeekParity();
    _initialWeekStart = _middlePage - _currentDayIdx;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(top: 250),
      child: Container(
        constraints: BoxConstraints(minHeight: screenHeight - 250),
        padding: const EdgeInsets.only(
          top: 80,
          bottom: 30,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: context.theme.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: ExpandablePageView.builder(
          controller: _pageController,
          itemCount: _totalPages,

          onPageChanged: (page) {
            widget.onDayChanged?.call();

            final virtualDay = page % _daysInWeek;

            if (virtualDay != _currentDayIdx) {
              setState(() {
                _currentDayIdx = virtualDay;
              });
              _savedDayIdx?.set(_currentDayIdx);
            }

            if (page < _daysInWeek * 10 ||
                page > _totalPages - _daysInWeek * 10) {
              final currentOffset = (page - _middlePage) ~/ _daysInWeek;
              final targetPage = _middleWeek * _daysInWeek + _currentDayIdx;

              final oldDayIdx = page % _daysInWeek;
              final oldStart = page - oldDayIdx;
              final oldOffset = (oldStart - _initialWeekStart) ~/ _daysInWeek;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _pageController.jumpToPage(targetPage);
                _middlePage = targetPage - currentOffset * _daysInWeek;

                final targetStart = targetPage - _currentDayIdx;
                _initialWeekStart = targetStart - oldOffset * _daysInWeek;
              });
            }
          },
          itemBuilder: (context, index) {
            final dayIdx = index % _daysInWeek;
            final startOfWeek = index - dayIdx;
            final offset = (startOfWeek - _initialWeekStart) ~/ _daysInWeek;

            final parityMod = offset % 2;
            final absMod = parityMod < 0 ? -parityMod : parityMod;
            final flip = (absMod % 2) == 1;
            final parity = flip ? 3 - _initialParity : _initialParity;

            final v =
                ReactiveStore.get("virtual_week_parity") ??
                ReactiveStore.createAndGet(
                  name: "virtual_week_parity",
                  value: parity,
                  toSave: false,
                )!;
            v.set(parity);
            final normalizedDayIdx = dayIdx.clamp(0, _daysInWeek - 1);
            return DayPage(
              key: ValueKey(normalizedDayIdx),
              dayIdx: normalizedDayIdx,
              parity: parity,
            );
          },
        ),
      ),
    );
  }
}

class DayPage extends StatefulWidget {
  final int dayIdx;
  final int parity;
  const DayPage({super.key, required this.dayIdx, required this.parity});

  @override
  State<DayPage> createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> with AutomaticKeepAliveClientMixin {
  List<List<List<String>>>? _data;
  List<List<Widget>> _imagesPerInterval = [];
  late Future<List<List<List<String>>>> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final timetableType =
        ReactiveStore.get("timetable_type") ??
        ReactiveStore.createAndGet(
          name: "timetable_type",
          value: "student",
          toSave: true,
        );
    if (timetableType!.get() == "student") {
      _future = TimetableProcessor().parseStudentTimetableByDay(widget.dayIdx);
    } else if (timetableType.get() == "teacher") {
      _future = TimetableProcessor().parseTeacherTimetableByDay(widget.dayIdx);
    }

    _future
        .then((data) {
          if (mounted) {
            setState(() {
              _data = data;
              _initImages(data);
            });
          }
        })
        .catchError((error) {});
  }

  @override
  void didUpdateWidget(covariant DayPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parity != widget.parity && _data != null) {
      setState(() {
        _initImages(_data!);
      });
    }
  }

  void _initImages(List<List<List<String>>> intervals) {
    _imagesPerInterval = List.generate(intervals.length, (i) {
      final lessons = intervals[i];
      final visibleLessons = lessons.where((data) {
        final weeksStr = data[4];
        final weeks = int.tryParse(weeksStr) ?? 0;
        return weeks == 0 || weeks == widget.parity;
      }).toList();
      if (visibleLessons.isEmpty) {
        return [];
      }
      return ImageHandler.getImageList(visibleLessons.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_data == null) {
      if (widget.dayIdx >= 5) {
        return Padding(
          padding: EdgeInsets.only(top: 200),
          child: Center(
            child: Text(
              "Nu sunt lecții...",
              style: context.theme.textTheme.bodyLarge!.copyWith(
                color: context.theme.textSecondary,
              ),
            ),
          ),
        );
      }
      return const Padding(
        padding: EdgeInsets.only(top: 200),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_data!.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 200),
        child: Center(
          child: Text(
            "Datele nu au fost regăsite",
            style: context.theme.textTheme.bodyMedium!.copyWith(
              color: context.theme.textSecondary,
            ),
          ),
        ),
      );
    }

    final intervals = _data!;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: intervals.length,
      itemBuilder: (context, i) {
        final lessons = intervals[i];
        final visibleLessons = lessons.where((data) {
          final weeksStr = data[4];
          final weeks = int.tryParse(weeksStr) ?? 0;
          return weeks == 0 || weeks == widget.parity;
        }).toList();

        if (visibleLessons.isEmpty) {
          return const SizedBox.shrink();
        }

        final interval = visibleLessons.first[0];
        final images = _imagesPerInterval[i];
        int idx = -1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeadInfoContainer(
              text1: Text(
                interval,
                style: context.theme.textTheme.bodyMedium!.copyWith(
                  color: context.theme.textPrimary,
                ),
              ),
            ),
            ...visibleLessons.map((data) {
              idx++;
              return LessonContainer(
                image: images[idx],
                subject: Converter.subjectToAbbreviation(data[1]),
                teacher: data[2],
                classroom: data[3],
                weeks: data[4],
                group: data[5],
              );
            }),
          ],
        );
      },
    );
  }
}
