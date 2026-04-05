import 'package:cihcahul_plus/core/models/selector_entry.dart';
import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/notification_handler.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/services/timetable_processor.dart';
import 'package:cihcahul_plus/core/utils/converter.dart';
import 'package:cihcahul_plus/core/utils/logger.dart';
import 'package:cihcahul_plus/ui/templates/TimetableTemplate/timetable_template.dart';
import 'package:flutter/material.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:cihcahul_plus/ui/templates/SettingsTemplate/settings_template.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Chisinau'));
  
  Log.init();
  Log.setDefaultId("MyApp");
  
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(VariableDataAdapter());
  Hive.registerAdapter(SelectorEntryAdapter());

  await ReactiveStore.extract();

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeType =
        ReactiveStore.get("theme") ??
        ReactiveStore.createAndGet(name: "theme", value: "dark", toSave: true);

    return StreamBuilder(
      stream: themeType!.stream,
      initialData: themeType.get(),
      builder: (context, snapshot) {
        final theme = snapshot.data;
        final themeMode = switch (theme) {
          "system" => ThemeMode.system,
          "dark" => ThemeMode.dark,
          "light" => ThemeMode.light,
          _ => ThemeMode.dark,
        };

        return MaterialApp(
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF7C5ACB),
              brightness: Brightness.light,
            ),
            extensions: <ThemeExtension<dynamic>>[AppTheme.light],
            textTheme: AppTheme.light.textTheme,
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF7C5ACB),
              brightness: Brightness.dark,
            ),
            extensions: <ThemeExtension<dynamic>>[AppTheme.dark],
            textTheme: AppTheme.dark.textTheme,
          ),
          themeMode: themeMode,
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final Variable? settingsToggle;
  late final Variable? lessonStartSitch;

  @override
  void initState() {
    super.initState();
    settingsToggle = ReactiveStore.createAndGet(
      name: 'settings_toggle',
      value: false,
      toSave: false,
    );
    lessonStartSitch =
        ReactiveStore.get("lesson_start_switch") ??
        ReactiveStore.createAndGet(
          name: "lesson_start_switch",
          value: false,
          toSave: true,
        );

    lessonStartSitch?.stream.listen((v) {
      if (v == true) {
        _init();
      }
    });

    _init();
  }

  Future<void> _init() async {
    if (lessonStartSitch?.get()) {
      bool allowed = await platform.invokeMethod('canScheduleExactAlarms');
      if (!allowed) {
        allowed = await platform.invokeMethod('requestExactAlarmPermission');
        if (!allowed) {
          Log.error("Permission denied on canScheduleExactAlarms");
          return;
        }
      }
      
      final now = DateTime.now();
      final lessonsTime = await TimetableProcessor().requestNotifyInterval(
        now.weekday - 1,
        Duration(hours: now.hour, minutes: now.minute, seconds: now.second),
      );
      for (final lessonTime in lessonsTime) {
        final targetDateTime = DateTime.now().add(lessonTime.time);
        final delayMillis = targetDateTime.millisecondsSinceEpoch;
        await showNotification(
          title:
              "${Converter.subjectToAbbreviation(lessonTime.name)} se incepe peste 5min",
          text: "In classa ${lessonTime.group} se va desfasura lectia",
          delay: delayMillis,
        );
      }

      if (lessonsTime.isNotEmpty) {
        Log.info("All notifications has been set");
        
      } else {
        Log.info("Notification buffer is empty");
        Log.info("$lessonsTime");
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;

      case AppLifecycleState.inactive:
        break;

      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        ReactiveStore.save();
        break;

      case AppLifecycleState.detached:
        ReactiveStore.save();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.success("Flutter app initialized");
    return Scaffold(
      backgroundColor: context.theme.surface,
      body: StreamBuilder(
        stream: settingsToggle!.stream,
        initialData: settingsToggle!.get(),
        builder: (context, snapshot) {
          final value = snapshot.data ?? false;

          return PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) {
              ReactiveStore.save();
            },
            child: value ? const SettingsTemplate() : const TimetableTemplate(),
          );
        },
      ),
    );
  }
}
