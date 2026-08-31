import 'package:cihcahul_plus/core/models/selector_entry.dart';
import 'package:cihcahul_plus/core/services/classroom_servie.dart';
import 'package:cihcahul_plus/core/services/localization_service.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:fuzzy/fuzzy.dart';

/// Classroom codes follow the school's own convention, e.g. "P.2431": a
/// type prefix ("P."), a 2-digit enrollment year ("24"), a 1-digit
/// course/year number ("3") and a 1-digit sub-group ("1", used only when a
/// class is big enough to be split in two). Every new school year every
/// class moves up one course, so the code the user picked last year quietly
/// stops existing and "classroom_id" is left pointing at nothing.
class ClassroomMigrationService {
  static final RegExp _codePattern = RegExp(r'^(.*?)(\d{2})(\d)(\d)$');

  /// Checks whether the saved "classroom_id" selection is still present in
  /// a freshly fetched classroom list and, if not, tries to find where it
  /// moved to: first by bumping the course digit (the expected case), then
  /// by fuzzy name matching (for the irregular renames that don't follow
  /// the pattern, e.g. "PAP" turning into "P").
  ///
  /// Returns a message to show the user when something changed (or
  /// couldn't be resolved at all), or `null` when there was nothing to do
  /// — nothing saved yet, the selection is still valid, or the API isn't
  /// returning data right now (e.g. actual vacation).
  static Future<String?> checkForClassroomChange() async {
    if (ReactiveStore.get("timetable_type")?.get() != "student") return null;

    final classroomVar = ReactiveStore.get("classroom_id");
    final current = classroomVar?.get();
    if (classroomVar == null || current is! SelectorEntry) return null;

    final List<SelectorEntry> classrooms;
    try {
      classrooms = await SelectorService.getClassroomsFromApi();
    } catch (_) {
      return null;
    }
    if (classrooms.isEmpty) return null;

    final byId = _findById(classrooms, current.id);
    if (byId != null) {
      // Still resolves — just keep the displayed name in sync in case the
      // school renamed it in place without changing the id.
      if (byId.name != current.name) classroomVar.set(byId);
      return null;
    }

    // The saved id is gone. Try the expected "course +1" rename first,
    // since that's what actually happens for the vast majority of classes.
    final guessedName = _incrementedName(current.name);
    if (guessedName != null) {
      final exact = _findByName(classrooms, guessedName);
      if (exact != null) {
        classroomVar.set(exact);
        return L10n.tr("classroom_auto_updated", {
          "old": current.name,
          "new": exact.name,
        });
      }
    }

    // Fall back to fuzzy matching (the same approach as the manual search
    // in Settings), but with a much stricter threshold since nobody is
    // there to confirm the result.
    final fuse = Fuzzy<SelectorEntry>(
      classrooms,
      options: FuzzyOptions(
        keys: [WeightedKey(name: 'name', getter: (e) => e.name, weight: 1.0)],
        threshold: 0.3,
      ),
    );
    final results = fuse.search(current.name);
    if (results.isNotEmpty && results.first.score <= 0.15) {
      final match = results.first.item;
      classroomVar.set(match);
      return L10n.tr("classroom_auto_updated", {
        "old": current.name,
        "new": match.name,
      });
    }

    return L10n.tr("classroom_not_found", {"old": current.name});
  }

  static SelectorEntry? _findById(List<SelectorEntry> list, String id) {
    for (final entry in list) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  static SelectorEntry? _findByName(List<SelectorEntry> list, String name) {
    for (final entry in list) {
      if (entry.name == name) return entry;
    }
    return null;
  }

  static String? _incrementedName(String name) {
    final match = _codePattern.firstMatch(name);
    if (match == null) return null;

    final prefix = match.group(1)!;
    final year = match.group(2)!;
    final course = int.parse(match.group(3)!);
    final group = match.group(4)!;

    if (course >= 9) return null;
    return '$prefix$year${course + 1}$group';
  }
}
