import 'timetable_entry.dart';

class TimetableDay {
  final Map<String, Map<String, TimetableEntry>> slots;

  TimetableDay(this.slots);
}
