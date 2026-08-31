import 'package:cihcahul_plus/core/api/edupage_remote_datasource.dart';
import 'package:cihcahul_plus/core/models/selector_entry.dart';
import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/classroom_migration_service.dart';
import 'package:cihcahul_plus/core/services/localization_service.dart';
import 'package:cihcahul_plus/core/services/notification_handler.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/services/timetable_processor.dart';
import 'package:cihcahul_plus/core/services/update_service.dart';
import 'package:cihcahul_plus/core/utils/converter.dart';
import 'package:cihcahul_plus/core/utils/logger.dart';
import 'package:cihcahul_plus/ui/templates/TimetableTemplate/timetable_template.dart';
import 'package:cihcahul_plus/ui/widgets/notification_trigher.dart';
import 'package:cihcahul_plus/ui/widgets/update_notice.dart';
import 'package:flutter/material.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:cihcahul_plus/ui/templates/SettingsTemplate/settings_template.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Module-level (not per-widget) so it survives HomePage being remounted
// with a new key on a language switch, but still resets on a genuine
// process restart — exactly the "once per real app launch" scope the
// update check needs.
bool _updateCheckPerformed = false;

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
  // Only refetch once per day on a cold start (a resume does the same
  // check, see didChangeAppLifecycleState below) — not on every launch,
  // so the timetable doesn't get re-downloaded every time the app opens.
  ensureFreshDataForToday();

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
    _checkClassroomChange();
    _checkForUpdate();
  }

  Future<void> _checkClassroomChange() async {
    final message = await ClassroomMigrationService.checkForClassroomChange();
    if (message == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showAttentionDialog(context, message);
    });
  }

  Future<void> _checkForUpdate() async {
    // Only on a genuine app launch — not on every resume from background,
    // and not on the HomePage remount a language switch triggers.
    if (_updateCheckPerformed) return;
    _updateCheckPerformed = true;

    final info = await UpdateService.checkForUpdate();
    if (info == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showUpdateDialog(context, info);
    });
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
        // Once-a-day refresh: only forces a new API call if today's data
        // hasn't been fetched yet, instead of hammering the API (or being
        // stuck with a stale response) on every single app open.
        ensureFreshDataForToday();
        _checkClassroomChange();
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
