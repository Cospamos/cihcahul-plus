import 'dart:convert';
import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

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
      v = ReactiveStore.createAndGet(
        name: "edupage_data", 
        value: response.body, 
        toSave: true
      );
      return v!.get() as String;
    }
  } catch (e) {
    throw Exception(e);
  }
  return '';
}
