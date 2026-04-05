import 'package:cihcahul_plus/core/api/edupage_remote_datasource.dart';
import 'package:cihcahul_plus/core/models/timetable_day.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/utils/student_timetable_parser.dart';
import 'package:cihcahul_plus/core/utils/teacher_timetable_parser.dart';

class TimetableService {
  String? classroomId = ReactiveStore.get("classroom_id")?.get().id;
  String? teacherId = ReactiveStore.get("teacher_id")?.get().id;

  List<TimetableDay> _generateStudentTimetableSync(
    String jsonString,
    String classId,
  ) {
    final parser = StudentTimetableParser(jsonString, classId: classId);
    final days = parser.parse();
    return days;
  }

  List<TimetableDay> _generateTeacherTimetableSync(
    String jsonString,
    String teacherId,
  ) {
    final parser = TeacherTimetableParser(jsonString, teacherId: teacherId);
    final days = parser.parse();
    return days;
  }

  Future<List<TimetableDay>> getStudentTimetableFromApi() async {
    try {
      final jsonString = await fetchTimetableJson();
      final timetableData = _generateStudentTimetableSync(
        jsonString,
        classroomId ?? '-68',
      );

      return timetableData;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<TimetableDay>> getTeacherTimetableFronApi() async {
    try {
      final jsonString = await fetchTimetableJson();
      final timetableData = _generateTeacherTimetableSync(
        jsonString,
        teacherId ?? "-40",
      );
      return timetableData;
    } catch (e) {
      throw Exception(e);
    }
  }
}
