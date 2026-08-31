import 'dart:convert';
import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

const String _lastFetchDateKey = "edupage_data_last_fetch_date";

String _todayKey() {
  final now = DateTime.now();
  return "${now.year}-${now.month}-${now.day}";
}

/// Drops the cached timetable response if it hasn't been (successfully)
/// refreshed today yet, so the next [fetchTimetableJson] call hits the
/// network instead of serving whatever was fetched on a previous day. Safe
/// to call on every app open/resume — it's a no-op once today's fetch has
/// already gone through.
void ensureFreshDataForToday() {
  final lastFetch = ReactiveStore.get(_lastFetchDateKey)?.get() as String?;
  if (lastFetch != _todayKey()) {
    ReactiveStore.remove("edupage_data");
  }
}

/// Forces the next [fetchTimetableJson] call to hit the network regardless
/// of whether today's data was already fetched — used by pull-to-refresh.
void forceRefreshTimetableData() {
  ReactiveStore.remove("edupage_data");
}

Future<String> fetchTimetableJson() async {
  Variable? v = ReactiveStore.get("edupage_data");
  if (v != null) return v.get();

  final url = Uri.parse(ApiConstants.timetableEndpoint);

  final headers = {'Content-Type': 'application/json'};

  final body = jsonEncode({
    "__args": [null, ApiConstants.defaultSchoolId],
    "__gsh": ApiConstants.edupageGsh,
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Not persisted (toSave: false): a stale/failed response should
      // never survive an app restart. Freshness across restarts is
      // instead handled explicitly by ensureFreshDataForToday(), gated by
      // _lastFetchDateKey (which IS persisted).
      v = ReactiveStore.createAndGet(
        name: "edupage_data",
        value: response.body,
        toSave: false,
      );

      final dateVar =
          ReactiveStore.get(_lastFetchDateKey) ??
          ReactiveStore.createAndGet(
            name: _lastFetchDateKey,
            value: "",
            toSave: true,
          );
      dateVar!.set(_todayKey());

      return v!.get() as String;
    }
  } catch (e) {
    throw Exception(e);
  }
  return '';
}
