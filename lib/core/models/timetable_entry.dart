class TimetableEntry {
  final String teacher;
  final int classroom;
  final int weeks;
  final String group;

  TimetableEntry({
    required this.teacher,
    required this.classroom,
    required this.weeks,
    required this.group,
  });
  Map<String, dynamic> toJson() => {
    'teacher': teacher,
    'classroom': classroom,
    'weeks': weeks,
    'group': group,
  };
}
