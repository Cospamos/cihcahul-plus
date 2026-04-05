import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:flutter/material.dart';

class NotificationTrigher extends StatefulWidget {
  final String type;
  final String content;
  final Widget trigherElement;

  const NotificationTrigher({
    super.key,
    required this.type,
    required this.trigherElement,
    required this.content,
  });

  @override
  State<NotificationTrigher> createState() => _NotificationTrigherState();
}

class _NotificationTrigherState extends State<NotificationTrigher> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.black26,
          builder: (context) => _warningNotification(context, widget.content),
        );
      },
      child: AbsorbPointer(absorbing: true, child: widget.trigherElement),
    );
  }
}

Widget _warningNotification(BuildContext context, String content) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return DefaultTextStyle(
    style: TextStyle(decoration: TextDecoration.none),
    child: GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            height: 400,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (isDark) ? context.theme.primaryContainer : context.theme.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Transform.translate(
                    offset: Offset(0, -70),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1000),
                        gradient: LinearGradient(
                          colors: [Color(0xFFFBB22D), Color(0xFFFF8C00)],
                        ),
                        border: Border.all(
                          color: (isDark)
                              ? context.theme.primaryContainer
                              : context.theme.primary,
                          width: 8,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 50, bottom: 20),
                  child: Column(
                    children: [
                      Text(
                        "Atentie",
                        style: context.theme.textTheme.displayLarge!.copyWith(
                          color: context.theme.textPrimary,
                        ),
                      ),
                      Text(
                        content,
                        style: context.theme.textTheme.bodyMedium!.copyWith(
                          color: context.theme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: context.theme.surface,
                        ),
                        child: Text(
                          "Ok",
                          style: context.theme.textTheme.bodyMedium!.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
