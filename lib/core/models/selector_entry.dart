import 'package:hive/hive.dart';

part 'selector_entry.g.dart';

@HiveType(typeId: 3)
class SelectorEntry {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  SelectorEntry({required this.id, required this.name});
}