import 'package:cihcahul_plus/core/utils/getter.dart';
import 'package:logging/logging.dart';
import 'package:logging_to_logcat/logging_to_logcat.dart';

class Log {
  static late String defaultId;
  
  static void init() {
    Logger.root.level = Level.ALL;
    Logger.root.activateLogcat();
  }

  static void setDefaultId(String id) {
    defaultId = id;
  }
   
  static void info(String message, [String? id]) {
    if ((defaultId.isEmpty) && (id == null || id.isEmpty)) throw Exception("Logger ID not provided");
    final loggerId = id ?? defaultId;

    Logger(loggerId).info("${Getter.getCaller()} $message");
  }

  static void warning(String message, [String? id]) {
    if ((defaultId.isEmpty) && (id == null || id.isEmpty))throw Exception("Logger ID not provided");
    final loggerId = id ?? defaultId;

    Logger(loggerId).info("\x1B[33m${Getter.getCaller()} $message\x1B[0m");
  }

  static void error(String message, [String? id]) {
    if ((defaultId.isEmpty) && (id == null || id.isEmpty)) throw Exception("Logger ID not provided");
    final loggerId = id ?? defaultId;

    Logger(loggerId).info(
      "\x1B[31m${Getter.getCaller()} $message\x1B[0m",
    );
  }

  static void success(String message, [String? id]) {
    if ((defaultId.isEmpty) && (id == null || id.isEmpty)) throw Exception("Logger ID not provided");
    final loggerId = id ?? defaultId;

    Logger(loggerId).info(
      "\x1B[32m${Getter.getCaller()} $message\x1B[0m",
    );
  }
}