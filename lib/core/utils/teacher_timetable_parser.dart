import 'dart:convert';
import '../models/timetable_entry.dart';
import '../models/timetable_day.dart';

class TeacherTimetableParser {
  final Map<String, dynamic> data;
  final Map<String, dynamic> _tables;
  final String teacherId;

  late final Map<String, String> _subjects;
  late final Map<String, String> _classrooms;
  late final Map<String, String> _classes;
  late final Map<String, String> _teachers;
  late final Map<String, String> _periodTime;

  TeacherTimetableParser(String jsonString, {required this.teacherId})
    : data = json.decode(jsonString),
      _tables = {
        for (var t in json.decode(jsonString)['r']['dbiAccessorRes']['tables'])
          t['id']: t,
      } {
    _initDictionaries();
  }

  void _initDictionaries() {
    _subjects = _makeDict('subjects');
    _classrooms = _makeDict('classrooms', valueField: 'short');
    _classes = _makeDict('classes');

    _teachers = _makeTeacherDict();

    _periodTime = {};
    for (var p in _tables['periods']?['data_rows'] ?? []) {
      _periodTime[p['id']] = '${p['starttime']}-${p['endtime']}';
    }
  }

  Map<String, String> _makeTeacherDict() {
    final rows = _tables['teachers']?['data_rows'] ?? [];
    final dict = <String, String>{};
    for (var row in rows) {
      String name = (row['name'] ?? '').toString().trim();
      if (name.isEmpty) {
        name = (row['short'] ?? '???').toString().trim();
      }
      dict[row['id']] = name;
    }
    return dict;
  }

  Map<String, String> _makeDict(String tableId, {String valueField = 'name'}) {
    final rows = _tables[tableId]?['data_rows'] ?? [];
    return {for (var row in rows) row['id']: row[valueField] ?? '???'};
  }

  List<TimetableDay> parse() {
    final lessons = {
      for (var l in _tables['lessons']?['data_rows'] ?? []) l['id']: l,
    };
    final cards = _tables['cards']?['data_rows'] ?? [];

    final timetableByTime = <String, Map<String, List<Map<String, dynamic>>>>{};

    final currentTeacherName = _teachers[teacherId] ?? teacherId;

    for (var card in cards) {
      final lessonId = card['lessonid'];
      if (!lessons.containsKey(lessonId)) continue;

      final lesson = lessons[lessonId]!;
      final teacherIds = _toList(lesson['teacherids']).cast<String>();
      if (!teacherIds.contains(teacherId)) continue;

      final days = _getDaysFromMask(card['days'] ?? '00000');
      final startPeriod = card['period'].toString();
      final duration =
          int.tryParse(lesson['durationperiods']?.toString() ?? '1') ?? 1;

      final subject = _subjects[lesson['subjectid']] ?? '???';
      final classroomsStr = _formatClassrooms(
        card['classroomids'] ?? lesson['classroomids'],
      );
      final weeksCode = card['weeks'] ?? '11';

      final timeInterval = _calculateTimeInterval(startPeriod, duration);

      final classroomStr = classroomsStr
          .split(', ')
          .firstWhere(
            (s) => s != '—' && s.trim().isNotEmpty,
            orElse: () => '0',
          );
      final classroom = int.tryParse(classroomStr) ?? 0;

      final weeks = _parseWeeks(weeksCode);

      final classIds = _toList(lesson['classids']).cast<String>();
      final group = _formatClasses(classIds);

      final entry = {
        'subject': subject,
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
        final entries = dayData[timeInterval]!;
        if (entries.isEmpty) continue;

        entries.sort((a, b) {
          final wa = a['weeks'] as int;
          final wb = b['weeks'] as int;
          if (wa != wb) return -wa.compareTo(wb);
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
            weeks: entry['weeks'] as int,
            classroom: entry['classroom'] as int,
            group: entry['group'] as String,
            teacher: currentTeacherName,
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

  String _formatClassrooms(dynamic raw) {
    final ids = _toList(raw).cast<String>();
    return ids
        .where((id) => id.trim().isNotEmpty)
        .map((id) => _classrooms[id.trim()] ?? id)
        .join(', ');
  }

  String _formatClasses(List<String> ids) {
    if (ids.isEmpty) return '—';
    return ids
        .where((id) => id.trim().isNotEmpty)
        .map((id) => _classes[id.trim()] ?? id)
        .join(', ');
  }

  int _parseWeeks(String code) {
    return {'11': 0, '01': 1, '10': 2}[code] ?? 0;
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
