import 'dart:convert';
import 'package:cihcahul_plus/core/models/selector_entry.dart';

class TeacherParser {
  factory TeacherParser(String jsonString) {
    final data = json.decode(jsonString);
    return TeacherParser._fromMap(data);
  }

  TeacherParser._fromMap(Map<String, dynamic> data);

  static List<SelectorEntry> parse(String jsonString) {
    final data = json.decode(jsonString);
    return parseFromMap(data);
  }

  static List<SelectorEntry> parseFromMap(Map<String, dynamic> data) {
    final tables = data['r']['dbiAccessorRes']['tables'] as List<dynamic>;

    final teachersTable = tables.firstWhere(
      (table) => table['id'] == 'teachers',
      orElse: () => <String, dynamic>{'data_rows': []},
    );

    final rows = teachersTable['data_rows'] as List<dynamic>;

    return rows.map((row) {
      String name = (row['name'] ?? '').toString().trim();
      if (name.isEmpty) {
        name = (row['short'] ?? '').toString().trim();
      }
      
      if (name.isEmpty) {
        name = '??? (${row['id'] ?? '—'})';
      }

      return SelectorEntry(id: (row['id'] ?? '').toString(), name: name);
    }).toList();
  }
}
