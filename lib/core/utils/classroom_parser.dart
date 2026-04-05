import 'dart:convert';

import 'package:cihcahul_plus/core/models/selector_entry.dart';

class ClassParser {
  factory ClassParser(String jsonString) {
    final data = json.decode(jsonString);
    return ClassParser._fromMap(data);
  }

  ClassParser._fromMap(Map<String, dynamic> data);

  static List<SelectorEntry> parse(String jsonString) {
    final data = json.decode(jsonString);
    return parseFromMap(data);
  }

  static List<SelectorEntry> parseFromMap(Map<String, dynamic> data) {
    final tables = data['r']['dbiAccessorRes']['tables'] as List<dynamic>;

    final classesTable = tables.firstWhere(
      (table) => table['id'] == 'classes',
      orElse: () => <String, dynamic>{'data_rows': []},
    );

    final rows = classesTable['data_rows'] as List<dynamic>;

    return rows.map((row) {
      return SelectorEntry(
        id: (row['id'] ?? '').toString(),
        name: (row['name'] ?? '').toString().trim(),
      );
    }).toList();
  }
}
