import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ReactiveStore {
  static Map<String, Variable> store = {}; 
  static Map<String, Variable> toSaveStore = {};

  static Variable? createAndGet({
    required String name,
    required dynamic value,
    bool? isConst,
    DateTime? expiry,
    required bool toSave,
  }) {
    if (store.containsKey(name)) return store[name];
    final variable = Variable(value, isConst: isConst ?? false, expiry: expiry);
    store[name] = variable;
    if (toSave) toSaveStore[name] = variable;
    return store[name];
  }

  static void remove(String name) {
    store.remove(name);
  }

  static Variable? get(String name) => store[name];
   
  static Future<dynamic> wait(String name) async {
    while (!store.containsKey(name)) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    final variable = store[name]!;

    if (variable.get() != null) return variable.get();

    return await variable.stream.first;
  }

  static Future<void> save() async {
    final box = await Hive.openBox<VariableData>('variables');

    for (final entry in toSaveStore.entries) {
      final key = entry.key;
      final variable = entry.value;

      final data = VariableData(
        value: variable.get(),
        isConst: variable.isConst,
        expiry: variable.expiry,
      );

      await box.put(key, data);
    }
  }

  static Future<void> extract() async {
    final box = await Hive.openBox<VariableData>('variables');

    store.clear();
    toSaveStore.clear();

    for (var entry in box.toMap().entries) {
      final key = entry.key;
      final data = entry.value;

      final variable = Variable(
        data.value,
        isConst: data.isConst,
        expiry: data.expiry,
      );

      store[key] = variable;
      toSaveStore[key] = variable;
    }
  }
}