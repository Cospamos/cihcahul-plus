import 'dart:convert';
import '../models/timetable_entry.dart';
import '../models/timetable_day.dart';

class StudentTimetableParser {
  final Map<String, dynamic> data;
  final Map<String, dynamic> _tables;
  final String classId;

  late final Map<String, String> _subjects;
  late final Map<String, String> _teachers;
  late final Map<String, String> _classrooms;
  late final Map<String, Map<String, dynamic>> _groups;
  late final Map<String, String> _periodTime; // id -> "08:00-09:35"

  StudentTimetableParser(String jsonString, {this.classId = '-68'})
    : data = json.decode(jsonString),
      _tables = {
        for (var t in json.decode(jsonString)['r']['dbiAccessorRes']['tables'])
          t['id']: t,
      } {
    _initDictionaries();
  }

  void _initDictionaries() {
    _subjects = _makeDict('subjects');
    _teachers = _makeTeacherDict();
    _classrooms = _makeDict('classrooms', valueField: 'short');
    _groups = {
      for (var g in _tables['groups']?['data_rows'] ?? []) g['id']: g,
    };
    _periodTime = {};
    for (var p in _tables['periods']?['data_rows'] ?? []) {
      _periodTime[p['id']] = '${p['starttime']}-${p['endtime']}';
    }
  }

  Map<String, String> _makeDict(String tableId, {String valueField = 'name'}) {
    final rows = _tables[tableId]?['data_rows'] ?? [];
    return {for (var row in rows) row['id']: row[valueField] ?? '???'};
  }

  Map<String, String> _makeTeacherDict() {
    final rows = _tables['teachers']?['data_rows'] ?? [];
    final dict = <String, String>{};
    for (var row in rows) {
      String name = (row['name'] ?? '').toString().trim();
      if (name.isEmpty) name = (row['short'] ?? '???').toString().trim();
      dict[row['id']] = name;
    }
    return dict;
  }

  List<TimetableDay> parse() {
    final lessons = {
      for (var l in _tables['lessons']?['data_rows'] ?? []) l['id']: l,
    };
    final cards = _tables['cards']?['data_rows'] ?? [];

    final timetableByTime = <String, Map<String, List<Map<String, dynamic>>>>{};

    for (var card in cards) {
      final lessonId = card['lessonid'];
      if (!lessons.containsKey(lessonId)) continue;

      final lesson = lessons[lessonId];
      final classIds = _toList(lesson['classids']).cast<String>();
      if (!classIds.contains(classId)) continue;

      final days = _getDaysFromMask(card['days'] ?? '00000');
      final startPeriod = card['period'].toString();
      final duration = int.tryParse(lesson['durationperiods'].toString()) ?? 1;

      final subject = _subjects[lesson['subjectid']] ?? '???';
      final teachers = _formatTeachers(lesson['teacherids']);
      final classrooms = _formatClassrooms(
        card['classroomids'] ?? lesson['classroomids'],
      );
      final weeksCode = card['weeks'] ?? '';

      final timeInterval = _calculateTimeInterval(startPeriod, duration);

      final classroomStr = classrooms.split(', ').first;
      final classroom = classroomStr.isNotEmpty ? classroomStr : '—';
      final weeks = _parseWeeks(weeksCode);
      final group = _resolveGroup(lesson);

      final entry = {
        'subject': subject,
        'teacher': teachers.isEmpty ? '—' : teachers,
        'classroom': classroom,
        'weeks': weeks,
        'group': group,
        'time_interval': timeInterval,
      };

      for (var day in days) {
        timetableByTime.putIfAbsent(day, () => {});
        timetableByTime[day]!.putIfAbsent(timeInterval, () => []);
        timetableByTime[day]![timeInterval]!.add(entry);
      }
    }

    final result = <TimetableDay>[];
    for (var dayId in ['0', '1', '2', '3', '4']) {
      final slots = <String, Map<String, TimetableEntry>>{};

      final dayData = timetableByTime[dayId] ?? {};
      final sortedTimes = dayData.keys.toList()..sort();

      for (var timeInterval in sortedTimes) {
        var entries = dayData[timeInterval]!;
        if (entries.isEmpty) continue;

        entries.sort((a, b) {
          final wa = a['weeks'] as int;
          final wb = b['weeks'] as int;

          if (wa != wb) {
            return -wa.compareTo(wb);
          }

          final ga = a['group'] as String;
          final gb = b['group'] as String;
          if (ga != gb) {
            return ga.compareTo(gb);
          }

          return (a['subject'] as String).compareTo(b['subject'] as String);
        });
        final timeSlot = <String, TimetableEntry>{};

        for (var entry in entries) {
          var subjectName = entry['subject'] as String;
          final baseSubject = subjectName;
          int counter = 1;

          while (timeSlot.containsKey(subjectName)) {
            subjectName = '$baseSubject ($counter)';
            counter++;
          }

          timeSlot[subjectName] = TimetableEntry(
            teacher: entry['teacher'] as String,
            classroom: entry['classroom'] as String,
            weeks: entry['weeks'] as int,
            group: entry['group'] as String,
          );
        }

        slots[timeInterval] = timeSlot;
      }

      result.add(TimetableDay(slots));
    }

    return result;
  }

  List<String> _getDaysFromMask(String mask) {
    if (mask.length < 5) return [];
    return [
      for (int i = 0; i < 5; i++)
        if (mask[i] == '1') i.toString(),
    ];
  }

  String _formatTeachers(dynamic raw) {
    final ids = _toList(raw).cast<String>();
    return ids
        .where((id) => id.trim().isNotEmpty)
        .map((id) => _teachers[id.trim()] ?? id)
        .join(', ');
  }

  String _formatClassrooms(dynamic raw) {
    final ids = _toList(raw).cast<String>();
    return ids
        .where((id) => id.trim().isNotEmpty)
        .map((id) => _classrooms[id.trim()] ?? id)
        .join(', ');
  }

  /// Edupage used to inline group names on the lesson (`groupnames`); it now
  /// only sends `groupids` pointing into the `groups` table, where a lesson
  /// shared by several classes lists one group per class. Both are handled.
  String _resolveGroup(Map<String, dynamic> lesson) {
    final groupIds = _toList(lesson['groupids']);
    if (groupIds.isEmpty) {
      return _parseGroup(
        _toList(lesson['groupnames']).where((g) => g != null).map((g) => '$g'),
      );
    }

    final names = <String>[];
    for (var id in groupIds) {
      final group = _groups[id];
      if (group == null || group['classid'] != classId) continue;
      if (group['entireclass'] == true) return '0';
      names.add((group['name'] ?? '').toString());
    }
    return _parseGroup(names);
  }

  int _parseWeeks(String code) {
    return {'11': 0, '01': 1, '10': 2}[code] ?? 0;
  }

  /// Only the "Grupa 1"/"Grupa 2" split counts as group A/B. Language
  /// sub-groups ("Engleză 1", "Franceză 2") are filtered by subject instead,
  /// so their digit must not leak into the group filter.
  String _parseGroup(Iterable<String> names) {
    for (var name in names) {
      final match = RegExp(
        r'^grupa\s*([12])$',
        caseSensitive: false,
      ).firstMatch(name.trim());
      if (match != null) return match.group(1)!;
    }
    return '0';
  }

  String _calculateTimeInterval(String startPeriod, int duration) {
    final startTime = _periodTime[startPeriod]?.split('-')[0] ?? '??:??';
    final endPeriodId = (int.parse(startPeriod) + duration - 1).toString();
    final endTime = _periodTime[endPeriodId]?.split('-')[1] ?? '??:??';
    return '$startTime-$endTime';
  }

  List<dynamic> _toList(dynamic value) {
    if (value is List) return value;
    if (value == null) return [];
    return [value];
  }
}