import 'package:cihcahul_plus/core/services/localization_service.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

const _repoReleasesUrl =
    'https://github.com/Cospamos/cihcahul-plus/releases/latest';

/// Full-screen QR code pointing at the GitHub releases page, so someone can
/// hand their phone to a friend and have them scan straight to the latest
/// APK — bigger than an inline code, easier to scan from a quick glance.
/// Tapping anywhere on the screen closes it.
void showQrShareDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog.fullscreen(
      backgroundColor: context.theme.primary,
      child: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    L10n.tr("share_app_qr_label"),
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.bodyLarge!.copyWith(
                      color: context.theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    // Plain white backing regardless of theme: a QR code
                    // needs reliable light/dark contrast to stay
                    // scannable, which the app's own colors don't
                    // guarantee.
                    child: QrImageView(
                      data: _repoReleasesUrl,
                      version: QrVersions.auto,
                      size: 260,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
