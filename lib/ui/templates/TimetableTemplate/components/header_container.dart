import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/services/timetable_processor.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:cihcahul_plus/core/utils/converter.dart';
import 'package:flutter/material.dart';

Widget headerContentContainer(BuildContext context) {
  final todayIdx = DateTime.now().weekday - 1;
  final nowH = DateTime.now().hour;
  final nowM = DateTime.now().minute;

  return SizedBox(
    width: MediaQuery.of(context).size.width,
    child: Row(
      children: [
        Image.asset("assets/mascot1.png"),
        Expanded(
          child: Transform.translate(
            offset: const Offset(-25, 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<Variable?>(
                  future: ReactiveStore.wait(
                    "day_idx",
                  ).then((_) => ReactiveStore.get("day_idx")),
                  initialData: null,
                  builder: (context, snapshot) {
                    
                    if (!snapshot.hasData || snapshot.data == null) {
                      return _dayAndLessons(
                        context,
                        dayIndex: todayIdx,
                        nowH: nowH,
                        nowM: nowM,
                      );
                    }

                    final variable = snapshot.data!;

                    return StreamBuilder<dynamic>(
                      stream: variable.stream,
                      initialData: variable.get() ?? todayIdx,
                      builder: (context, snapshot) {
                        final currentDayIdx =
                            (snapshot.data as int?) ?? todayIdx;
                        return _dayAndLessons(
                          context,
                          dayIndex: currentDayIdx,
                          nowH: nowH,
                          nowM: nowM,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _dayAndLessons(
  BuildContext context, {
  required int dayIndex,
  required int nowH,
  required int nowM,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        Converter.iTDay(dayIndex),
        style: context.theme.textTheme.displayLarge,
      ),
      DefaultTextStyle(
        style: context.theme.textTheme.bodyMedium!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: TimetableProcessor().getNowLesson(dayIndex, nowH, nowM),
              builder: (context, snapshot) {
                final nowLesson = snapshot.hasData
                    ? snapshot.data!
                    : "Ma gindesc...";
                
                return Row(
                  children: [
                    if (nowLesson.isNotEmpty)
                      const Icon(Icons.circle, size: 13),
                    Expanded(
                      child: Text(
                        Converter.subjectToAbbreviation(nowLesson),
                        style: context.theme.textTheme.bodySmall!.copyWith(
                          color: context.theme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                );
              },
            ),
            FutureBuilder<String>(
              future: TimetableProcessor().getFutureLesson(
                dayIndex,
                nowH,
                nowM,
              ),
              builder: (context, snapshot) {
                final futureLesson = snapshot.hasData
                    ? snapshot.data!
                    : "Ma gindesc...";
                return Row(
                  children: [
                    if (futureLesson.isNotEmpty)
                      const Icon(Icons.arrow_circle_right_outlined, size: 14),
                    Expanded(
                      child: Text(
                        Converter.subjectToAbbreviation(futureLesson),
                        style: context.theme.textTheme.bodySmall!.copyWith(
                          color: context.theme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ],
  );
}
