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
    surfaceVariant: Colors.white,
    surfaceDim: Color(0xFF1A1A1A),
    primary: Colors.white,
    primaryContainer: Color(0xFF7C5ACB),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF666666),
    textSecondaryVariant: Color(0xFF1A1A1A),
    error: Color(0xFFD32F2F),
    warning: Color(0xFFF57C00),
    success: Color(0xFF388E3C),
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