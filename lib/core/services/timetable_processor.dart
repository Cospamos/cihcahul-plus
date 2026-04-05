import 'dart:async';
import 'package:cihcahul_plus/core/models/lesson_time.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/services/timetable_service.dart';
import 'package:cihcahul_plus/core/utils/converter.dart';
import 'package:cihcahul_plus/core/utils/getter.dart';

class TimetableProcessor {
  Future<Duration> getLastTimeInterval(
    int weekday,
    final days,
    int weekParity,
  ) async {
    final day = days[weekday].slots;
    final entries = day.entries.toList();

    Duration? lastLessonDuration;
    for (final e in entries.reversed) {
      final interval = e.key;
      final lesson = day[interval]!.keys.first;
      final weeks = day[interval]![lesson]!.weeks;

      if (weekParity == weeks) {
        lastLessonDuration = Converter.stringToListDuration(interval)[1];
        break;
      }
    }

    return lastLessonDuration ?? Duration(hours: 14, minutes: 50);
  }

  Future<Duration> requestLastTimeInterval(int weekday) async {
    if (weekday >= 5) return Duration(hours: 0, minutes: 0);
    final timetableType = ReactiveStore.get("timetable_type")?.get();
    final days = switch (timetableType) {
      "student" => await TimetableService().getStudentTimetableFromApi(),
      "teacher" => await TimetableService().getTeacherTimetableFronApi(),
      _ => await TimetableService().getStudentTimetableFromApi(),
    };
    final weekParity =
        ReactiveStore.get("virtual_week_parity")?.get() ??
        Getter.getWeekParity();

    final day = days[weekday].slots;
    final entries = days[weekday].slots.entries.toList();

    Duration? lastLessonDuration;
    for (final e in entries.reversed) {
      final interval = e.key;
      final lesson = day[interval]!.keys.first;
      final weeks = day[interval]![lesson]!.weeks;
      if (weekParity == weeks || weeks == 0) {
        lastLessonDuration = Converter.stringToListDuration(interval)[1];
        break;
      }
    }

    return lastLessonDuration ?? Duration(hours: 14, minutes: 50);
  }

  Future<List<LessonTime>> requestNotifyInterval(
    int weekday,
    Duration nowDuration,
  ) async {
    
    if (weekday >= 5) return []; 
    final timetableType = ReactiveStore.get("timetable_type")?.get();
    final getGroup = ReactiveStore.get("show_group")?.get();
    final studentLanguage = ReactiveStore.get("student_language")?.get();
    final excludeGroup = {"first": '2', "second": '1'};
    final languageMap = {"anglophone": "Franceza", "francophone": "Engleza"};
    final weekParity = Getter.getWeekParity();
    
    final days = switch (timetableType) {
      "student" => await TimetableService().getStudentTimetableFromApi(),
      "teacher" => await TimetableService().getTeacherTimetableFronApi(),
      _ => await TimetableService().getStudentTimetableFromApi(),
    };

    final day = days[weekday].slots;
    final entries = day.entries;
    List<LessonTime> res = [];
    for (final e in entries) {
      final interval = e.key;
      final lessons = day[interval]!.keys;
      for (final lesson in lessons) {
        final lessonDuration = Converter.stringToListDuration(interval);
        final classroom = day[interval]![lesson]!.classroom.toString();
        final group = day[interval]![lesson]!.group;
        final weeks = day[interval]![lesson]!.weeks;
        final lessonStartDuration = (nowDuration - lessonDuration[0]).abs() - Duration(minutes: 5);
        final excludedSubject = languageMap[studentLanguage] ?? "";
        
        if (nowDuration < (lessonDuration[0] - Duration(minutes: 5)).abs() &&
            (weeks == weekParity || weeks == 0) &&
            (group == excludeGroup[getGroup] || group == '0' || timetableType == "teacher" || excludeGroup[getGroup] == null) &&
            (!lesson.contains(excludedSubject) || timetableType == "teacher")) {
          res.add(LessonTime(lesson, classroom, lessonStartDuration));
        }
      }
    }
    return res;
  }

  Future<List<List<List<List<String>>>>> parseTimetable() async {
    final timetableType = ReactiveStore.get("timetable_type")?.get();
    final days = switch (timetableType) {
      "student" => await TimetableService().getStudentTimetableFromApi(),
      "teacher" => await TimetableService().getTeacherTimetableFronApi(),
      _ => await TimetableService().getStudentTimetableFromApi(),
    };
    List<List<List<List<String>>>> timetable = [];

    for (var day in days) {
      List<List<List<String>>> timeIntervalList = [];
      final lessons = day.slots;
      lessons.entries.toList().asMap().forEach((idx, e) {
        List<List<String>> lessonList = [];
        final interval = e.key;
        final subjectMap = e.value;

        subjectMap.forEach((subject, entry) {
          lessonList.add([
            interval,
            Converter.subjectToAbbreviation(subject),
            entry.teacher,
            entry.classroom.toString(),
            entry.weeks.toString(),
            entry.group.toString(),
          ]);
        });
        timeIntervalList.add(lessonList);
      });
      timetable.add(timeIntervalList);
    }

    return timetable;
  }

  Future<List<List<List<String>>>> parseTeacherTimetableByDay(
    int dayIdx,
  ) async {
    final days = await TimetableService().getTeacherTimetableFronApi();
    final day = days[dayIdx].slots;
    List<List<List<String>>> lessons = [];

    day.keys.toList().forEach((interval) {
      List<List<String>> intervals = [];
      final subject = day[interval]!.keys.first;

      for (final entry in day[interval]!.values) {
        intervals.add([
          interval,
          Converter.subjectToAbbreviation(subject),
          entry.teacher,
          entry.classroom.toString(),
          entry.weeks.toString(),
          entry.group,
        ]);
      }
      lessons.add(intervals);
    });
    return lessons;
  }

  Future<List<List<List<String>>>> parseStudentTimetableByDay(
    int dayIdx,
  ) async {
    final days = await TimetableService().getStudentTimetableFromApi();
    List<List<List<String>>> timeIntervalList = [];
    final lessons = days[dayIdx].slots;

    final group = ReactiveStore.get("show_group")?.get();
    final studentLanguage = ReactiveStore.get("student_language")?.get();

    final excludeGroup = {"first": '2', "second": '1'};
    final languageMap = {"anglophone": "Franceza", "francophone": "Engleza"};

    lessons.entries.toList().asMap().forEach((idx, e) {
      List<List<String>> lessonList = [];
      final interval = e.key;
      final subjectMap = e.value;

      subjectMap.forEach((subject, entry) {
        final excludedSubject = languageMap[studentLanguage];
        if (excludeGroup[group] == entry.group) return;
        if (excludedSubject != null && subject.contains(excludedSubject)) return;

        lessonList.add([
          interval,
          subject,
          entry.teacher,
          entry.classroom.toString(),
          entry.weeks.toString(),
          entry.group.toString(),
        ]);
      });
      timeIntervalList.add(lessonList);
    });
    return timeIntervalList;
  }

  Future<String> getNowLesson(int weekday, int h, int m) async {
    if (weekday >= 5) return "";

    final timetableType = ReactiveStore.get("timetable_type")?.get();
    final days = switch (timetableType) {
      "student" => await TimetableService().getStudentTimetableFromApi(),
      "teacher" => await TimetableService().getTeacherTimetableFronApi(),
      _ => await TimetableService().getStudentTimetableFromApi(),
    };
    final weekParity =
        ReactiveStore.get("virtual_week_parity")!.get() ??
        Getter.getWeekParity();

    Duration nowDuration = Duration(hours: h, minutes: m);
    final lastLessonDuration = await getLastTimeInterval(
      weekday,
      days,
      weekParity,
    );
    if (nowDuration >= lastLessonDuration) return "";

    final lessons = days[weekday].slots;

    final filterGroup = ReactiveStore.get("show_group")?.get();
    final studentLanguage = ReactiveStore.get("student_language")?.get();

    final groupMap = {"first": '1', "second": '2'};
    final languageMap = {"anglophone": "Engleza", "francophone": "Franceza"};

    for (var e in lessons.entries) {
      List<Duration> interval = Converter.stringToListDuration(e.key);

      if (interval[0] <= nowDuration && nowDuration <= interval[1]) {
        for (int i = 0; i < e.value.keys.length; ++i) {
          final lesson = e.value.keys.toList()[i];
          final group = e.value[lesson]!.group;
          final weeks = e.value[lesson]!.weeks;
          final subject = languageMap[studentLanguage];
          if ((timetableType == 'teacher' ||
                  group == '0' ||
                  groupMap[filterGroup] == group) &&
              (weeks == 0 || weeks == weekParity)) {
            return lesson;
          }
          if (subject != null && lesson.contains(subject)) return lesson;
        }
        return "";
      }
    }

    if (h < 14 || (h == 14 && m <= 50)) {
      return "Pauza";
    }

    return "";
  }

  Future<String> getFutureLesson(int weekday, int h, int m) async {
    if (weekday >= 5) return "";

    final timetableType = ReactiveStore.get("timetable_type")?.get();
    final days = switch (timetableType) {
      "student" => await TimetableService().getStudentTimetableFromApi(),
      "teacher" => await TimetableService().getTeacherTimetableFronApi(),
      _ => await TimetableService().getStudentTimetableFromApi(),
    };
    final weekParity =
        ReactiveStore.get("virtual_week_parity")?.get() ??
        Getter.getWeekParity();

    final lastLessonDuration = await getLastTimeInterval(
      weekday,
      days,
      weekParity,
    );
    final nowDuration = Duration(hours: h, minutes: m);
    if (nowDuration >= lastLessonDuration) return "";

    final lessons = days[weekday].slots;
    String futureLesson = "";

    final filterGroup = ReactiveStore.get("show_group")?.get();
    final studentLanguage = ReactiveStore.get("student_language")?.get();

    final groupMap = {"first": '1', "second": '2'};
    final languageMap = {"anglophone": "Engleza", "francophone": "Franceza"};

    for (var e in lessons.entries) {
      final interval = Converter.stringToListDuration(e.key);

      if (interval[0].inMinutes > nowDuration.inMinutes) {
        for (int i = 0; i < e.value.keys.length; ++i) {
          final lesson = e.value.keys.toList()[i];
          final group = e.value[lesson]!.group;
          final weeks = e.value[lesson]!.weeks;
          final subject = languageMap[studentLanguage];

          if ((timetableType == 'teacher' ||
                  group == '0' ||
                  groupMap[filterGroup] == group) &&
              (weeks == 0 || weeks == weekParity)) {
            return lesson;
          }
          if (subject != null && lesson.contains(subject)) return lesson;
        }
        return "";
      }
    }
    return futureLesson;
  }
}
