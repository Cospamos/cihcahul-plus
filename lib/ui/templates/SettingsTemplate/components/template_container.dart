import 'package:cihcahul_plus/core/models/selector_entry.dart';
import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/classroom_servie.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:cihcahul_plus/ui/templates/SettingsTemplate/common/selector_container.dart';
import 'package:cihcahul_plus/ui/templates/SettingsTemplate/common/switcher_container.dart';
import 'package:cihcahul_plus/ui/templates/SettingsTemplate/common/toggle_container.dart';
import 'package:cihcahul_plus/ui/widgets/headinfo_container.dart';
import 'package:cihcahul_plus/ui/widgets/notification_trigher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class TemplateContainer extends StatefulWidget {
  const TemplateContainer({super.key});

  @override
  State<TemplateContainer> createState() => _TemplateContainerState();
}

class _TemplateContainerState extends State<TemplateContainer> {
  final Variable timetableType =
      ReactiveStore.get("timetable_type") ??
      ReactiveStore.createAndGet(
        name: "timetable_type",
        value: "student",
        toSave: true,
      )!;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.only(top: 20, bottom: 30, left: 20, right: 20),
      width: double.infinity,
      constraints: BoxConstraints(minHeight: screenHeight - 270),
      decoration: BoxDecoration(
        color: context.theme.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          HeadInfoContainer(
            text1: Text(
              "General",
              style: context.theme.textTheme.titleLarge!.copyWith(
                color: context.theme.textPrimary,
              ),
            ),
          ),
          NotificationTrigher(
            type: "warning",
            content:
                "Aceasta functie acum este indisponibila din cauza lucrarilor asupra ei. Cerem scuze pentru incomoditati",
            trigherElement: SwitchContainer(
              name: "Limba",
              id: "language",
              variants: ["Romina", "Rusa", "Engleza"],
              variatsId: ['ro', 'ru', 'en'],
              defaultVariant: "ro",
            ),
          ),

          SizedBox(height: 5),
          SwitchContainer(
            name: "Tema",
            id: "theme",
            variants: ["Deschisa", "Inchisa", "Din sistema"],
            variatsId: ['light', 'dark', 'system'],
            defaultVariant: "dark",
          ),
          HeadInfoContainer(
            text1: Text(
              "Filtre",
              style: context.theme.textTheme.titleLarge!.copyWith(
                color: context.theme.textPrimary,
              ),
            ),
          ),
          SwitchContainer(
            name: "Arata graficul",
            id: "timetable_type",
            variants: ["Elevului", "Invatatorului"],
            variatsId: ['student', 'teacher'],
            defaultVariant: "student",
          ),
          SizedBox(height: 5),

          StreamBuilder<dynamic>(
            stream: timetableType.stream,
            initialData: timetableType.get(),
            builder: (context, snapshot) {
              if (snapshot.data != "student") {
                return FutureBuilder<List<SelectorEntry>>(
                  key: ValueKey("teachers"),
                  future: SelectorService.getTeachersFromApi(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SelectorContainer(
                        key: ValueKey("teacher_container"),
                        name: "Sunt",
                        selectorId: "teacher_id",
                        selecotrMessage: "Alege numele",
                        defaultData: SelectorEntry(
                          id: "-40",
                          name: "Arseni Adriana",
                        ),
                        data: <SelectorEntry>[],
                      );
                    }
                    return SelectorContainer(
                      key: ValueKey("teacher_container"),
                      name: "Sunt",
                      selectorId: "teacher_id",
                      selecotrMessage: "Alege numele",
                      defaultData: SelectorEntry(
                        id: "-40",
                        name: "Arseni Adriana",
                      ),
                      data: snapshot.data!,
                    );
                  },
                );
              }
              return FutureBuilder<List<SelectorEntry>>(
                key: ValueKey("classrooms"),
                future: SelectorService.getClassroomsFromApi(),
                builder: (context, futureSnapshot) {
                  if (!futureSnapshot.hasData) {
                    return SelectorContainer(
                      key: ValueKey("classroom_container"),
                      name: "Sunt in clasa",
                      selectorId: "classroom_id",
                      selecotrMessage: "Alege grupa",
                      defaultData: SelectorEntry(id: "-68", name: "P.2421"),
                      data: <SelectorEntry>[],
                    );
                  }

                  return Column(
                    children: [
                      SelectorContainer(
                        key: ValueKey("classroom_container"),
                        name: "Sunt in clasa",
                        selectorId: "classroom_id",
                        selecotrMessage: "Alege grupa",
                        defaultData: SelectorEntry(id: "-68", name: "P.2421"),
                        data: futureSnapshot.data!,
                      ),
                      SizedBox(height: 5),
                      SwitchContainer(
                        name: "Arata grupa",
                        id: "show_group",
                        variants: ["Toate", "Prima", "Adoua"],
                        variatsId: ['all', 'first', 'second'],
                        defaultVariant: "all",
                      ),
                      SizedBox(height: 5),
                      SwitchContainer(
                        name: "Sunt",
                        id: "student_language",
                        variants: ["Anglofon", "Francofon", "Nu importa"],
                        variatsId: ['anglophone', 'francophone', 'none'],
                        defaultVariant: 'none',
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(height: 5),
          ToggleContainer(name: "Arata zilele de odihna", id: "show_weekend"),
          HeadInfoContainer(
            text1: Text(
              "Automatizare",
              style: context.theme.textTheme.titleLarge!.copyWith(
                color: context.theme.textPrimary,
              ),
            ),
          ),
          ToggleContainer(
            name: "Trecerea zilei automat",
            id: "auto_day_switch",
            description:
                "Sistemul schimba orarul pe ziua urmatoare in cazul cind orele s-au terminat.",
          ),
          HeadInfoContainer(
            text1: Text(
              "Notificari",
              style: context.theme.textTheme.titleLarge!.copyWith(
                color: context.theme.textPrimary,
              ),
            ),
          ),
          ToggleContainer(
            name: "Inceputul lectiilor",
            id: "lesson_start_switch",
            description:
                "Cu 5min inainte de a se incepe lectia, sistemul trimite notificare de amintire.",
          ),
          NotificationTrigher(
            type: "warning",
            content:
                "Aceasta functie acum este indisponibila din cauza lucrarilor asupra ei. Cerem scuze pentru incomoditati",
            trigherElement: ToggleContainer(
              name: "Lectia acum si urmatoarea",
              id: "fast_info_notify",
              description:
                  "Arata notificarea cu informatia despre lectia de acum si urmatoarea",
            ),
          ),
          HeadInfoContainer(
            text1: Text(
              "Aditional",
              style: context.theme.textTheme.titleLarge!.copyWith(
                color: context.theme.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse(
                'https://cihcahul.edupage.org/timetable/view.php?num=75',
              );

              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                throw '[ERROR] url opening';
              }
            },
            child: Text(
              "Sursa Endpoint",
              style: TextStyle(
                color: context.theme.surface,
                decoration: TextDecoration.underline,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(height: 50,)
        ],
      ),
    );
  }
}