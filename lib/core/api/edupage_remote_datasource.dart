import 'dart:convert';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

const String _dataKey = "edupage_data";
const String _lastFetchDateKey = "edupage_data_last_fetch_date";

/// Tables every parser relies on. A response missing any of them (an error
/// page, a payload for the wrong request, a half-loaded school database...)
/// is treated as a failed fetch instead of replacing a working timetable.
const List<String> _requiredTables = [
  'periods',
  'lessons',
  'cards',
  'classes',
  'teachers',
];

const Duration _requestTimeout = Duration(seconds: 15);

/// After a failed refresh, keep serving the cached copy for this long
/// instead of retrying (and waiting out a timeout) on every single call.
const Duration _retryCooldown = Duration(seconds: 30);

bool _forceRefresh = false;
DateTime? _lastFailure;
Future<String>? _inFlight;

String _todayKey() {
  final now = DateTime.now();
  return "${now.year}-${now.month}-${now.day}";
}

bool _needsRefresh() {
  if (_forceRefresh) return true;
  final lastFetch = ReactiveStore.get(_lastFetchDateKey)?.get() as String?;
  if (lastFetch == _todayKey()) return false;
  final failure = _lastFailure;
  return failure == null || DateTime.now().difference(failure) > _retryCooldown;
}

/// Makes the next [fetchTimetableJson] call hit the network regardless of
/// whether today's data was already fetched — used by pull-to-refresh. The
/// cached timetable is *kept* until a valid replacement actually arrives, so
/// refreshing without a connection leaves the current schedule on screen.
void forceRefreshTimetableData() {
  _forceRefresh = true;
}

bool _isValidPayload(String body) {
  try {
    final tables = jsonDecode(body)['r']['dbiAccessorRes']['tables'];
    if (tables is! List) return false;
    final ids = {for (final t in tables) t['id']};
    return ids.containsAll(_requiredTables);
  } catch (_) {
    return false;
  }
}

Future<void> _storeFetched(String body) async {
  // Persisted (toSave: true): this is the last-known-good timetable that
  // keeps the app usable offline across restarts. It is only ever
  // overwritten by another validated response, never deleted.
  final existing = ReactiveStore.get(_dataKey);
  if (existing == null) {
    ReactiveStore.createAndGet(name: _dataKey, value: body, toSave: true);
  } else {
    await existing.set(body);
  }

  final dateVar =
      ReactiveStore.get(_lastFetchDateKey) ??
      ReactiveStore.createAndGet(
        name: _lastFetchDateKey,
        value: "",
        toSave: true,
      );
  await dateVar!.set(_todayKey());

  await ReactiveStore.save();
}

Future<String> _refresh(String? cachedJson) async {
  final hadForce = _forceRefresh;
  try {
    final response = await http
        .post(
          Uri.parse(ApiConstants.timetableEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "__args": [null, ApiConstants.defaultSchoolId],
            "__gsh": ApiConstants.edupageGsh,
          }),
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 200 && _isValidPayload(response.body)) {
      await _storeFetched(response.body);
      _lastFailure = null;
      return response.body;
    }
  } catch (_) {
    // Offline, timeout, DNS failure... handled below like any bad response.
  } finally {
    if (hadForce) _forceRefresh = false;
  }

  _lastFailure = DateTime.now();
  if (cachedJson != null && cachedJson.isNotEmpty) return cachedJson;
  throw Exception("Timetable unavailable: no connection and nothing cached");
}

Future<String> fetchTimetableJson() {
  final cachedJson = ReactiveStore.get(_dataKey)?.get() as String?;
  final hasCache = cachedJson != null && cachedJson.isNotEmpty;

  if (hasCache && !_needsRefresh()) return Future.value(cachedJson);

  // Several callers (timetable, pickers, notifications) ask at once on
  // startup — share one request instead of waiting out N timeouts offline.
  return _inFlight ??= _refresh(
    cachedJson,
  ).whenComplete(() => _inFlight = null);
}
