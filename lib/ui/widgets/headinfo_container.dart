import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';

class HeadInfoContainer extends StatefulWidget {
  final Widget text1;
  final Widget? text2;
  
  const HeadInfoContainer({super.key, required this.text1, this.text2});

  @override
  State<HeadInfoContainer> createState() => _HeadInfoContainerState();
}

class _HeadInfoContainerState extends State<HeadInfoContainer> {
  @override
  Widget build(BuildContext context) {
    final text1 = widget.text1;
    final text2 = widget.text2;

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.titleSmall!,
      child: Column(
        children: [
          SizedBox(height: 10),
          Row(
            children: [
              if (text2 != null) ...[
                text2,
                SizedBox(width: 10),
              ],
              _separator(context),
              SizedBox(width: 10),
              text1,
              if (text2 == null) ...[SizedBox(width: 10), _separator(context)]
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

Widget _separator(BuildContext context) {
  return Expanded(
    child: SizedBox(
      height: 8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: context.theme.primary,
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(104, 0, 0, 0),
              offset: Offset(0, 4),
              blurRadius: 8,
              inset: true,
            ),
          ],
        ),
      ),
    ),
  );
}
