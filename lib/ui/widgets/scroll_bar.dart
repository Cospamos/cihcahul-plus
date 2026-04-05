import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:flutter/material.dart';

class ScrollBar extends StatefulWidget {
  final Widget child;

  const ScrollBar({super.key, required this.child});

  @override
  State<ScrollBar> createState() => _ScrollBarState();
}

class _ScrollBarState extends State<ScrollBar> {
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_update);
  }

  @override
  void dispose() {
    controller.removeListener(_update);
    controller.dispose();
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (_) {
            _update();
            return false;
          },
          child: SingleChildScrollView(
            controller: controller,
            child: widget.child,
          ),
        ),
        Positioned(
          right: 6,
          top: 0,
          bottom: 0,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              const double paddingVertical = 4;
              const double thumbHeight = 30;

              if (!controller.hasClients) {
                return const SizedBox();
              }

              final maxScroll = controller.position.maxScrollExtent;
              final offset = controller.offset;
              final viewHeight = constraints.maxHeight;
              final usableHeight = viewHeight - paddingVertical * 2 + paddingVertical;

              final thumbTop = maxScroll == 0
                  ? paddingVertical
                  : paddingVertical +
                        (offset / maxScroll) * (usableHeight - thumbHeight);

              return Container(
                width: paddingVertical * 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? context.theme.primaryContainer
                      : context.theme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: thumbTop.clamp(0, usableHeight - thumbHeight),
                      right: paddingVertical,
                      child: Container(
                        width: paddingVertical * 2,
                        height: thumbHeight,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                              ? context.theme.primary
                              : context.theme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
