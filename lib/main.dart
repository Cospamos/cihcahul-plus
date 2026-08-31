import 'package:cihcahul_plus/core/models/selector_entry.dart';
import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/localization_service.dart';
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
  // "edupage_data" used to be persisted (toSave: true); purge whatever a
  // previous version of the app already wrote to Hive so it doesn't keep
  // coming back through extract()/save() forever.
  await ReactiveStore.forget("edupage_data");

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
        ReactiveStore.createAndGet(
          name: "theme",
          value: "system",
          toSave: true,
        );
    final languageType =
        ReactiveStore.get("language") ??
        ReactiveStore.createAndGet(name: "language", value: "ro", toSave: true);

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

        return StreamBuilder(
          stream: languageType!.stream,
          initialData: languageType.get(),
          builder: (context, langSnapshot) {
            final language = langSnapshot.data as String? ?? "ro";

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
              // Remounting HomePage on language change is the simplest way
              // to make every L10n.tr(...) call downstream (none of which
              // take a BuildContext) pick up the new value immediately.
              home: HomePage(key: ValueKey("home_$language")),
            );
          },
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
          title: L10n.tr("notification_title", {
            "subject": Converter.subjectToAbbreviation(lessonTime.name),
          }),
          text: L10n.tr("notification_body", {"group": lessonTime.group}),
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
        // Force a fresh timetable fetch every time the app is opened,
        // instead of trusting whatever "edupage_data" already sits in
        // memory from before the app was backgrounded.
        ReactiveStore.forget("edupage_data");
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
