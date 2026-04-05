import 'package:cihcahul_plus/core/api/edupage_remote_datasource.dart';
import 'package:cihcahul_plus/core/models/selector_entry.dart';
import 'package:cihcahul_plus/core/utils/classroom_parser.dart';
import 'package:cihcahul_plus/core/utils/teacher_parser.dart';

class SelectorService {
  static Future<List<SelectorEntry>> getClassroomsFromApi() async {
    try {
      final jsonString = await fetchTimetableJson();
      final classroomData = ClassParser.parse(jsonString);
      return classroomData;
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<List<SelectorEntry>> getTeachersFromApi() async {
    try {
      final jsonString = await fetchTimetableJson();
      final teacherData = TeacherParser.parse(jsonString);
      return teacherData;
    } catch (e) {
      throw Exception(e);
    }
  }
}
