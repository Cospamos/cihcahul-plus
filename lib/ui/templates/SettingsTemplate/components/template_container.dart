import 'package:cihcahul_plus/core/models/selector_entry.dart';
import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/classroom_servie.dart';
import 'package:cihcahul_plus/core/services/localization_service.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:cihcahul_plus/ui/templates/SettingsTemplate/common/selector_container.dart';
import 'package:cihcahul_plus/ui/templates/SettingsTemplate/common/switcher_container.dart';
import 'package:cihcahul_plus/ui/templates/SettingsTemplate/common/toggle_container.dart';
import 'package:cihcahul_plus/ui/widgets/headinfo_container.dart';
import 'package:cihcahul_plus/ui/widgets/notification_trigher.dart';
import 'package:cihcahul_plus/ui/widgets/qr_share_dialog.dart';
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
              L10n.tr("section_general"),
              style: context.theme.textTheme.titleLarge!.copyWith(
                color: context.theme.textPrimary,
              ),
            ),
          ),
          SwitchContainer(
            name: L10n.tr("setting_language"),
            id: "language",
            variants: const ["Română", "Русский", "English"],
            variatsId: ['ro', 'ru', 'en'],
            defaultVariant: "ro",
          ),

          SizedBox(height: 5),
          SwitchContainer(
            name: L10n.tr("setting_theme"),
            id: "theme",
            variants: [
              L10n.tr("theme_light"),
              L10n.tr("theme_dark"),
              L10n.tr("theme_system"),
            ],
            variatsId: ['light', 'dark', 'system'],
            defaultVariant: "system",
          ),
          HeadInfoContainer(
            text1: Text(
              L10n.tr("section_filters"),
              style: context.theme.textTheme.titleLarge!.copyWith(
                color: context.theme.textPrimary,
              ),
            ),
          ),
          SwitchContainer(
            name: L10n.tr("setting_show_timetable"),
            id: "timetable_type",
            variants: [L10n.tr("role_student"), L10n.tr("role_teacher")],
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
                        name: L10n.tr("label_i_am"),
                        selectorId: "teacher_id",
                        selecotrMessage: L10n.tr("selector_choose_name"),
                        defaultData: SelectorEntry(
                          id: "-40",
                          name: "Arseni Adriana",
                        ),
                        data: <SelectorEntry>[],
                      );
                    }
                    return SelectorContainer(
                      key: ValueKey("teacher_container"),
                      name: L10n.tr("label_i_am"),
                      selectorId: "teacher_id",
                      selecotrMessage: L10n.tr("selector_choose_name"),
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
                      name: L10n.tr("setting_am_in_class"),
                      selectorId: "classroom_id",
                      selecotrMessage: L10n.tr("selector_choose_group"),
                      defaultData: SelectorEntry(id: "-68", name: "P.2421"),
                      data: <SelectorEntry>[],
                    );
                  }

                  return Column(
                    children: [
                      SelectorContainer(
                        key: ValueKey("classroom_container"),
                        name: L10n.tr("setting_am_in_class"),
                        selectorId: "classroom_id",
                        selecotrMessage: L10n.tr("selector_choose_group"),
                        defaultData: SelectorEntry(id: "-68", name: "P.2421"),
                        data: futureSnapshot.data!,
                      ),
                      SizedBox(height: 5),
                      SwitchContainer(
                        name: L10n.tr("setting_show_group"),
                        id: "show_group",
                        variants: [
                          L10n.tr("group_all"),
                          L10n.tr("group_first"),
                          L10n.tr("group_second"),
                        ],
                        variatsId: ['all', 'first', 'second'],
                        defaultVariant: "all",
                      ),
                      SizedBox(height: 5),
                      SwitchContainer(
                        name: L10n.tr("label_i_am"),
                        id: "student_language",
                        variants: [
                          L10n.tr("lang_track_anglophone"),
                          L10n.tr("lang_track_francophone"),
                          L10n.tr("lang_track_none"),
                        ],
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
          ToggleContainer(
            name: L10n.tr("setting_show_weekend"),
            id: "show_weekend",
          ),
          HeadInfoContainer(
            text1: Text(
              L10n.tr("section_automation"),
              style: context.theme.textTheme.titleLarge!.copyWith(
                color: context.theme.textPrimary,
              ),
            ),
          ),
          ToggleContainer(
            name: L10n.tr("setting_auto_day_switch"),
            id: "auto_day_switch",
            description: L10n.tr("setting_auto_day_switch_desc"),
          ),
          HeadInfoContainer(
            text1: Text(
              L10n.tr("section_notifications"),
              style: context.theme.textTheme.titleLarge!.copyWith(
                color: context.theme.textPrimary,
              ),
            ),
          ),
          ToggleContainer(
            name: L10n.tr("setting_lesson_start_notify"),
            id: "lesson_start_switch",
            description: L10n.tr("setting_lesson_start_notify_desc"),
          ),
          NotificationTrigher(
            type: "warning",
            content: L10n.tr("feature_unavailable"),
            trigherElement: ToggleContainer(
              name: L10n.tr("setting_fast_info_notify"),
              id: "fast_info_notify",
              description: L10n.tr("setting_fast_info_notify_desc"),
            ),
          ),
          HeadInfoContainer(
            text1: Text(
              L10n.tr("section_additional"),
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
              L10n.tr("setting_endpoint_source"),
              style: TextStyle(
                color: context.theme.surface,
                decoration: TextDecoration.underline,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () => showQrShareDialog(context),
            child: Text(
              L10n.tr("share_app_qr_label"),
              style: TextStyle(
                color: context.theme.surface,
                decoration: TextDecoration.underline,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
