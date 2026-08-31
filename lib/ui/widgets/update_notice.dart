import 'package:cihcahul_plus/core/services/localization_service.dart';
import 'package:cihcahul_plus/core/services/update_service.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:flutter/material.dart';

/// Shows a dialog offering to download and install [info]. Styled after
/// the same "Attention" card used elsewhere, but with its own state for
/// the download progress instead of a single "Ok" dismiss button.
void showUpdateDialog(BuildContext context, UpdateInfo info) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black26,
    builder: (context) => _UpdateNotification(info: info),
  );
}

class _UpdateNotification extends StatefulWidget {
  final UpdateInfo info;

  const _UpdateNotification({required this.info});

  @override
  State<_UpdateNotification> createState() => _UpdateNotificationState();
}

class _UpdateNotificationState extends State<_UpdateNotification> {
  bool _downloading = false;
  double? _progress;
  String? _error;

  Future<void> _startUpdate() async {
    setState(() {
      _downloading = true;
      _error = null;
    });
    try {
      await UpdateService.downloadAndInstall(
        widget.info.downloadUrl,
        onProgress: (progress) {
          if (mounted) setState(() => _progress = progress);
        },
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _downloading = false;
          _error = L10n.tr("update_error");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
            Container(
              width: double.infinity,
              height: 400,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? context.theme.primaryContainer
                    : context.theme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Transform.translate(
                      offset: const Offset(0, -70),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1000),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C5ACB), Color(0xFF4CAF50)],
                          ),
                          border: Border.all(
                            color: isDark
                                ? context.theme.primaryContainer
                                : context.theme.primary,
                            width: 8,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.system_update,
                            color: Colors.white,
                            size: 56,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 20),
                    child: Column(
                      children: [
                        Text(
                          L10n.tr("update_available_title"),
                          // displayLarge (40) is sized for a single short
                          // word like a day name; this title is a longer
                          // phrase in every language and would get clipped
                          // inside the dialog's fixed width otherwise.
                          style: context.theme.textTheme.displayLarge!
                              .copyWith(
                                color: context.theme.textPrimary,
                                fontSize: 26,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          L10n.tr("update_available_body", {
                            "version": widget.info.version,
                          }),
                          style: context.theme.textTheme.bodyMedium!.copyWith(
                            color: context.theme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        if (_downloading) ...[
                          Text(
                            L10n.tr("update_downloading"),
                            style: context.theme.textTheme.bodySmall!
                                .copyWith(color: context.theme.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 180,
                            child: LinearProgressIndicator(
                              value: _progress,
                              color: context.theme.surface,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ] else ...[
                          if (_error != null) ...[
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: context.theme.textTheme.labelMedium!
                                  .copyWith(color: context.theme.error),
                            ),
                            const SizedBox(height: 10),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    L10n.tr("update_later_button"),
                                    style: context.theme.textTheme.bodyMedium!
                                        .copyWith(
                                          color: context.theme.textSecondary,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _startUpdate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: context.theme.surface,
                                  ),
                                  child: Text(
                                    L10n.tr("update_now_button"),
                                    style: context.theme.textTheme.bodyMedium!
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
