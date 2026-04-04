import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global theme notifier
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.dark);

/// ─────────────────────────────────────────────
/// EcoWatch Design System
/// Photo-matched: Forest Green #1A5C3A / #1E7A48
/// Light mode: white body + green headers
/// Dark mode: pure black combo
/// ─────────────────────────────────────────────

class AppColors {
  // ── Primary Greens (matches login screen photo exactly) ──
  static const Color primary = Color(0xFF1E5A46);       // exact photo deep matte green
  static const Color primaryLight = Color(0xFF246651);  // lighter green circle color
  static const Color primaryDark = Color(0xFF164736);   // deep forest green

  // ── Dark Mode Primary (black combo — use green as accent) ──
  static const Color darkPrimary = Color(0xFF22A857);       // bright green on black
  static const Color darkPrimaryLight = Color(0xFF39CC6E);
  static const Color darkPrimaryDark = Color(0xFF157A3E);

  // ── Officer Amber ──
  static const Color amber = Color(0xFFE8A838);
  static const Color amberLight = Color(0xFFF5C563);

  // ── Light Mode Neutrals ──
  // Body/scaffold: pure white; surfaces: white; text: dark
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF4FAF6);         // very slight green tint
  static const Color textPrimaryLight = Color(0xFF0D1F14);  // deep dark green-black
  static const Color textSecondaryLight = Color(0xFF2D5139); // medium forest text
  static const Color textTertiaryLight = Color(0xFF5C8A6B);  // muted green

  // ── Dark Mode Neutrals (pure black combo) ──
  static const Color backgroundDark = Color(0xFF000000);    // pure black
  static const Color surfaceDark = Color(0xFF0A0A0A);       // near-black
  static const Color cardDark = Color(0xFF111111);          // dark card
  static const Color textPrimaryDark = Color(0xFFEEFFE8);   // warm white with green tint
  static const Color textSecondaryDark = Color(0xFF8CB89A); // muted green-grey
  static const Color textTertiaryDark = Color(0xFF4A6B52);  // deep muted green

  // ── Semantic ──
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFFFA940);
  static const Color danger = Color(0xFFFF4D4F);

  // ── Helpers (theme-aware) ──
  static Color getPrimary(Brightness brightness) =>
      brightness == Brightness.dark ? darkPrimary : primary;
  static Color getPrimaryLight(Brightness brightness) =>
      brightness == Brightness.dark ? darkPrimaryLight : primaryLight;
  static Color getPrimaryDark(Brightness brightness) =>
      brightness == Brightness.dark ? darkPrimaryDark : primaryDark;

  static Color getBackground(Brightness brightness) =>
      brightness == Brightness.dark ? backgroundDark : backgroundLight;
  static Color getSurface(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceDark : surfaceLight;
  static Color getCard(Brightness brightness) =>
      brightness == Brightness.dark ? cardDark : cardLight;
  static Color getTextPrimary(Brightness brightness) =>
      brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;
  static Color getTextSecondary(Brightness brightness) =>
      brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;
  static Color getTextTertiary(Brightness brightness) =>
      brightness == Brightness.dark ? textTertiaryDark : textTertiaryLight;

  // ── Legacy statics (used by widgets that aren't fully theme-aware yet)
  // These now default to LIGHT mode values, since full theme-awareness is handled per-widget
  static const Color background = Color(0xFF000000);      // dark fallback
  static const Color surface = Color(0xFF0A0A0A);         // dark fallback
  static const Color surfaceVariant = Color(0xFF1A1A1A);  // dark variant
  static const Color divider = Color(0xFF1E1E1E);
  static const Color textPrimary = Color(0xFFEEFFE8);     // dark mode text
  static const Color textSecondary = Color(0xFF8CB89A);
  static const Color textTertiary = Color(0xFF4A6B52);
  static const Color info = Color(0xFF22A857);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color accent = Color(0xFF22A857);

  // ── Gradients ──
  // Login/Splash screen background: deep forest green (matches photo 1)
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E5A46), Color(0xFF1E5A46), Color(0xFF1E5A46)], // Solid fallback
    stops: [0.0, 0.5, 1.0],
  );

  // Hero section gradient (top of dashboard, photo 2 green header)
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF164736), Color(0xFF1E5A46), Color(0xFF246651)],
    stops: [0.0, 0.55, 1.0],
  );

  // Dark mode hero gradient: pure black to dark
  static const LinearGradient darkHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF000000), Color(0xFF0A0A0A), Color(0xFF0D1F14)],
    stops: [0.0, 0.5, 1.0],
  );

  // Button gradient: green
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF27A35A), Color(0xFF1E7A48)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Dark button gradient: bright green on black
  static const LinearGradient darkButtonGradient = LinearGradient(
    colors: [Color(0xFF39CC6E), Color(0xFF22A857)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Officer dark steel gradient (replaces yellow/amber)
  static const LinearGradient officerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D1117), Color(0xFF161B22), Color(0xFF1C2333)],
    stops: [0.0, 0.55, 1.0],
  );

  // Officer accent color (blue-steel, used for highlights on the dark header)
  static const Color officerAccent = Color(0xFF58A6FF);

  static const LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC000000)],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final Color primaryColor = AppColors.getPrimary(brightness);
    final Color bgColor = AppColors.getBackground(brightness);
    final Color surfaceColor = AppColors.getSurface(brightness);
    final Color textColor = AppColors.getTextPrimary(brightness);
    final Color textSecColor = AppColors.getTextSecondary(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgColor,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryColor,
              secondary: primaryColor,
              surface: surfaceColor,
              error: AppColors.danger,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: textColor,
            )
          : ColorScheme.light(
              primary: primaryColor,
              secondary: primaryColor,
              surface: surfaceColor,
              error: AppColors.danger,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: textColor,
            ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
            fontSize: 32, fontWeight: FontWeight.w700, color: textColor),
        headlineMedium: GoogleFonts.poppins(
            fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
        titleMedium: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
        bodyLarge: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w400, color: textSecColor),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        // Light mode AppBar uses primary green; dark mode uses pure black surface
        backgroundColor: isDark ? AppColors.surfaceDark : primaryColor,
        foregroundColor: Colors.white,
      ),
      dividerColor: isDark ? AppColors.surfaceVariant : const Color(0xFFD6EDDE),
      cardColor: AppColors.getCard(brightness),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // Light mode input on a green background → dark fill; dark mode → black fill
        fillColor: isDark ? AppColors.cardDark : const Color(0xFF122B1E),
        prefixIconColor: isDark ? AppColors.textTertiaryDark : Colors.white70,
        hintStyle: GoogleFonts.inter(
          color: isDark ? AppColors.textTertiaryDark : Colors.white54,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF27A35A), width: 2),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
// GLOBAL SHARED WIDGETS
// ═══════════════════════════════════════

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppColors.darkButtonGradient : AppColors.buttonGradient;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : gradient,
        color: onPressed == null ? AppColors.surfaceVariant : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed == null
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                )
              ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}

class StyledInputField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;
  final bool showPassword;
  final VoidCallback? onTogglePassword;
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  const StyledInputField({
    super.key,
    required this.icon,
    required this.hint,
    this.isPassword = false,
    this.controller,
    this.showPassword = false,
    this.onTogglePassword,
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // On green bg (login/splash): dark fill. On white bg: grey fill
        color: const Color(0xFF122B1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        onChanged: onChanged,
        obscureText: isPassword && !showPassword,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white54, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    showPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.white54,
                    size: 20,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF27A35A), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFF122B1E),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: child,
    );
  }
}

/// Theme-aware card used in body sections (not on green headers)
class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? borderRadius;

  const ThemedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.04))
            : Border.all(color: const Color(0xFFD6EDDE)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF1E7A48).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
