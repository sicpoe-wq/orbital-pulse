import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 dark theme — modern tech / orbital aesthetic.
class AppTheme {
  static const Color _bg = Color(0xFF0B0F1A);
  static const Color _surface = Color(0xFF141A2A);
  static const Color _surfaceHigh = Color(0xFF1C2438);
  static const Color _accent = Color(0xFF5B8CFF);
  static const Color _accentAlt = Color(0xFF00E5C3);
  static const Color _warn = Color(0xFFFFB74D);
  static const Color _danger = Color(0xFFFF6B6B);

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accent,
        brightness: Brightness.dark,
        primary: _accent,
        secondary: _accentAlt,
        surface: _surface,
        error: _danger,
      ),
      scaffoldBackgroundColor: _bg,
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: Colors.white.withValues(alpha: 0.92),
      displayColor: Colors.white,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface,
        indicatorColor: _accent.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? _accent : Colors.white54,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? _accent : Colors.white54,
            size: 24,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceHigh,
        selectedColor: _accent.withValues(alpha: 0.25),
        labelStyle: const TextStyle(fontSize: 12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
      dividerColor: Colors.white.withValues(alpha: 0.08),
      splashColor: _accent.withValues(alpha: 0.12),
    );
  }

  static Color get accent => _accent;
  static Color get accentAlt => _accentAlt;
  static Color get warn => _warn;
  static Color get surfaceHigh => _surfaceHigh;
}
