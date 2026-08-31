import 'package:flutter/material.dart';

class AppTheme extends ThemeExtension<AppTheme> {
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceDim;
  final Color primary;
  final Color primaryContainer;
  final Color textPrimary;
  final Color textSecondary;
  final Color textSecondaryVariant;
  final Color error;
  final Color warning;
  final Color success;
  // Segmented-control / toggle chip colors, kept separate from
  // primary/primaryContainer because those are shared by several other
  // widgets (nav tabs, search field, overlays) that already depend on
  // primaryContainer always being a saturated color.
  final Color chipTrack;
  final Color chipSelected;
  final Color chipSelectedText;
  final Color chipUnselectedText;
  final TextTheme textTheme;

  const AppTheme({
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceDim,
    required this.primary,
    required this.primaryContainer,
    required this.textPrimary,
    required this.textSecondary,
    required this.textSecondaryVariant,
    required this.error,
    required this.warning,
    required this.success,
    required this.chipTrack,
    required this.chipSelected,
    required this.chipSelectedText,
    required this.chipUnselectedText,
    required this.textTheme,
  });

  static const dark = AppTheme(
    surface: Color(0xFF7C5ACB),
    surfaceVariant: Color(0xFF7C5ACB),
    surfaceDim: Color(0xFF704BC4),
    primary: Color(0xFF23313C),
    primaryContainer: Color(0xFF162029),
    textPrimary: Colors.white,
    textSecondary: Color(0xFF7B7B7B),
    textSecondaryVariant: Color(0xFFAAAEB2),
    error: Color(0xFFE57373),
    warning: Color(0xFFFFB74D),
    success: Color(0xFF4CAF50),
    // Unchanged from how these controls always rendered before this pair
    // of fields existed: dark navy track, navy selected chip, purple
    // selected text, white unselected text.
    chipTrack: Color(0xFF162029),
    chipSelected: Color(0xFF23313C),
    chipSelectedText: Color(0xFF704BC4),
    chipUnselectedText: Colors.white,
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, height: 1.12),
      titleLarge:   TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.33),
      titleSmall:   TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.33),
      bodyLarge:    TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.50),
      bodyMedium:   TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.33),
      bodySmall:    TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.43),
      labelLarge:   TextStyle(fontSize: 14, fontWeight: FontWeight.w500,  height: 1.43),
      labelMedium:  TextStyle(fontSize: 13, fontWeight: FontWeight.w500,  height: 1.33),
      labelSmall:   TextStyle(fontSize: 11, fontWeight: FontWeight.w500,  height: 1.33),
    ),
  );

  static const light = AppTheme(
    surface: Color(0xFF7C5ACB),
    // Matches primaryContainer, same as dark's surfaceVariant matches its
    // own surface — otherwise the selector chip border (this token's only
    // use) is a stray white outline with no equivalent in dark mode.
    surfaceVariant: Color(0xFF7C5ACB),
    surfaceDim: Color(0xFF1A1A1A),
    primary: Colors.white,
    primaryContainer: Color(0xFF7C5ACB),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF666666),
    textSecondaryVariant: Color(0xFF1A1A1A),
    error: Color(0xFFD32F2F),
    warning: Color(0xFFF57C00),
    success: Color(0xFF388E3C),
    // A quiet neutral track with a solid accent chip for the selected
    // option reads as a normal segmented control; filling the whole track
    // with saturated purple (the old behavior) made every switch look
    // like a big candy-colored button.
    chipTrack: Color(0xFFF1EEF9),
    chipSelected: Color(0xFF7C5ACB),
    chipSelectedText: Colors.white,
    chipUnselectedText: Color(0xFF1A1A1A),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, height: 1.12),
      titleLarge:   TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.33),
      titleSmall:   TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.33),
      bodyLarge:    TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.50),
      bodyMedium:   TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.33),
      bodySmall:    TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.43),
      labelLarge:   TextStyle(fontSize: 14, fontWeight: FontWeight.w500,  height: 1.43),
      labelMedium:  TextStyle(fontSize: 13, fontWeight: FontWeight.w500,  height: 1.33),
      labelSmall:   TextStyle(fontSize: 11, fontWeight: FontWeight.w500,  height: 1.33),
    ),
  );

  @override
  AppTheme copyWith({
    Color? surface,
    Color? surfaceVariant,
    Color? surfaceDim,
    Color? primary,
    Color? primaryContainer,
    Color? textPrimary,
    Color? textSecondary,
    Color? textSecondaryVariant,
    Color? error,
    Color? warning,
    Color? success,
    Color? chipTrack,
    Color? chipSelected,
    Color? chipSelectedText,
    Color? chipUnselectedText,
    TextTheme? textTheme,
  }) {
    return AppTheme(
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textSecondaryVariant: textSecondaryVariant ?? this.textSecondaryVariant,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      chipTrack: chipTrack ?? this.chipTrack,
      chipSelected: chipSelected ?? this.chipSelected,
      chipSelectedText: chipSelectedText ?? this.chipSelectedText,
      chipUnselectedText: chipUnselectedText ?? this.chipUnselectedText,
      textTheme: textTheme ?? this.textTheme,
    );
  }

  @override
  AppTheme lerp(covariant ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) return this;

    return AppTheme(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textSecondaryVariant: Color.lerp(textSecondaryVariant, other.textSecondaryVariant, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      chipTrack: Color.lerp(chipTrack, other.chipTrack, t)!,
      chipSelected: Color.lerp(chipSelected, other.chipSelected, t)!,
      chipSelectedText: Color.lerp(chipSelectedText, other.chipSelectedText, t)!,
      chipUnselectedText: Color.lerp(chipUnselectedText, other.chipUnselectedText, t)!,
      textTheme: TextTheme(
        displayLarge: TextStyle.lerp(textTheme.displayLarge, other.textTheme.displayLarge, t),
        titleLarge:   TextStyle.lerp(textTheme.titleLarge,   other.textTheme.titleLarge,   t),
        titleSmall:   TextStyle.lerp(textTheme.titleSmall,   other.textTheme.titleSmall,   t),
        bodyLarge:    TextStyle.lerp(textTheme.bodyLarge,    other.textTheme.bodyLarge,    t),
        bodyMedium:   TextStyle.lerp(textTheme.bodyMedium,   other.textTheme.bodyMedium,   t),
        bodySmall:    TextStyle.lerp(textTheme.bodySmall,    other.textTheme.bodySmall,    t),
        labelLarge:   TextStyle.lerp(textTheme.labelLarge,   other.textTheme.labelLarge,   t),
        labelMedium:  TextStyle.lerp(textTheme.labelMedium,  other.textTheme.labelMedium,  t),
        labelSmall:   TextStyle.lerp(textTheme.labelSmall,   other.textTheme.labelSmall,   t),
      ),
    );
  }
}

extension ThemeX on BuildContext {
  AppTheme get theme => Theme.of(this).extension<AppTheme>()!;
}
