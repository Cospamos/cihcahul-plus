import 'package:week_number/iso.dart';

class Getter {
  static int getWeekParity() {
    final now = DateTime.now();
    final weekNumber = now.weekNumber;
    final isOddWeekNow = weekNumber % 2 == 1;
    return isOddWeekNow ? 2 : 1;
  }

  static String getCaller() {
    final trace = StackTrace.current.toString().split('\n');
    final line = trace.length > 2 ? trace[2] : trace.last;
    final match = RegExp(r'#\d+\s+(.+?) \((.+?):(\d+):\d+\)').firstMatch(line);
    
    if (match != null) {
      final file = match.group(2)?.split('/').last;
      final lineNumber = match.group(3);
      return '[$file:$lineNumber]';
    }
    return 'unknown';
  }
}