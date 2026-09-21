import 'dart:convert';
import 'dart:io';

import 'package:cihcahul_plus/core/api/edupage_remote_datasource.dart';
import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

String _payload(String marker) => jsonEncode({
  'marker': marker,
  'r': {
    'dbiAccessorRes': {
      'tables': [
        for (final id in ['periods', 'lessons', 'cards', 'classes', 'teachers'])
          {'id': id, 'data_rows': []},
      ],
    },
  },
});

MockClient _online(String body, {int status = 200}) =>
    MockClient((_) async => http.Response(body, status));

MockClient _offline() =>
    MockClient((_) async => throw const SocketException('no route to host'));

Future<String> _fetch(MockClient client) =>
    http.runWithClient(fetchTimetableJson, () => client);

void main() {
  late Directory tmp;

  setUpAll(() {
    tmp = Directory.systemTemp.createTempSync('edupage_cache_test');
    Hive.init(tmp.path);
    Hive.registerAdapter(VariableDataAdapter());
  });

  tearDownAll(() async {
    await Hive.close();
    tmp.deleteSync(recursive: true);
  });

  setUp(() {
    ReactiveStore.store.clear();
    ReactiveStore.toSaveStore.clear();
  });

  test('a valid response is returned and persisted as last-known-good', () async {
    final body = _payload('day1');
    expect(await _fetch(_online(body)), body);

    expect(ReactiveStore.get('edupage_data')?.get(), body);
    expect(ReactiveStore.toSaveStore.containsKey('edupage_data'), isTrue);
  });

  test('a forced refresh while offline keeps the cached timetable', () async {
    final good = _payload('good');
    await _fetch(_online(good));

    forceRefreshTimetableData();
    expect(await _fetch(_offline()), good);
    expect(ReactiveStore.get('edupage_data')?.get(), good);
  });

  test('a 200 with an unexpected payload never replaces the cache', () async {
    final good = _payload('good');
    await _fetch(_online(good));

    forceRefreshTimetableData();
    expect(await _fetch(_online('{"error":"nope"}')), good);

    forceRefreshTimetableData();
    expect(await _fetch(_online('<html>maintenance</html>')), good);

    forceRefreshTimetableData();
    expect(await _fetch(_online(good, status: 500)), good);

    expect(ReactiveStore.get('edupage_data')?.get(), good);
  });

  test('a later valid response does replace the cache', () async {
    await _fetch(_online(_payload('old')));

    final fresh = _payload('fresh');
    forceRefreshTimetableData();
    expect(await _fetch(_online(fresh)), fresh);
    expect(ReactiveStore.get('edupage_data')?.get(), fresh);
  });

  test('offline with nothing cached fails instead of returning junk', () async {
    await expectLater(_fetch(_offline()), throwsException);
    expect(ReactiveStore.get('edupage_data'), isNull);
  });

  test('cached data survives a restart (persisted, then extracted)', () async {
    final body = _payload('persisted');
    await _fetch(_online(body));

    ReactiveStore.store.clear();
    ReactiveStore.toSaveStore.clear();
    await ReactiveStore.extract();

    // "Cold start" on a day the last fetch didn't happen: refresh fails,
    // the persisted copy is still served.
    ReactiveStore.get('edupage_data_last_fetch_date')?.set('1999-1-1');
    expect(await _fetch(_offline()), body);
  });
}
