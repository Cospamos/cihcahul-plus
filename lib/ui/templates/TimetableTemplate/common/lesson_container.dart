import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:flutter/material.dart';

class LessonContainer extends StatefulWidget {
  final Widget image;
  final String subject;
  final String teacher;
  final String classroom;
  final String weeks;
  final String group;

  const LessonContainer({
    super.key,
    required this.image,
    required this.subject,
    required this.teacher,
    required this.classroom,
    required this.weeks,
    required this.group,
  });

  @override
  State<LessonContainer> createState() => _LessonContainerState();
}

class _LessonContainerState extends State<LessonContainer> {
  @override
  Widget build(BuildContext context) {
    String classroom = widget.classroom == "0"
        ? "Sala sportiva"
        : "Clasa ${widget.classroom}";
    String group = widget.group == "0"
        ? "Ambele grupe"
        : "Grupa ${widget.group}";
    Widget image = widget.image;
    String teacher = widget.teacher;
    String subject = widget.subject;

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          image,
          SizedBox(width: 5),
          DefaultTextStyle(
            style: context.theme.textTheme.bodyMedium!.copyWith(
              color: context.theme.textPrimary,
              height: 1.1
            ),
            child: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(subject),
                  Text(classroom),
                  Text(group),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          teacher,
                          style: TextStyle(color: context.theme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
