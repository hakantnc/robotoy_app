import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Robotoy tema modları.
enum AppThemeMode { pinkCream, blueCream, dark }

/// Global tema yöneticisi. main()'de `instance.load()` çağrıldıktan sonra
/// MaterialApp `ListenableBuilder` ile sarılır; `setMode()` ile anlık tema değişir.
class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._();
  ThemeController._();

  AppThemeMode _mode = AppThemeMode.pinkCream;
  AppThemeMode get mode => _mode;

  static const String _prefsKey = 'app_theme_mode';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    _mode = AppThemeMode.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => AppThemeMode.pinkCream,
    );
    notifyListeners();
  }

  Future<void> setMode(AppThemeMode m) async {
    if (_mode == m) return;
    _mode = m;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, m.name);
    notifyListeners();
  }

  ThemeData get themeData {
    switch (_mode) {
      case AppThemeMode.pinkCream:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFFFF8F0),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFC5D3),
            brightness: Brightness.light,
            primary: const Color(0xFFFFC5D3),
            secondary: const Color(0xFFC8B6E2),
            surface: Colors.white,
          ),
        );
      case AppThemeMode.blueCream:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF6F8FF),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFA8C8FF),
            brightness: Brightness.light,
            primary: const Color(0xFFA8C8FF),
            secondary: const Color(0xFFB6D4E2),
            surface: Colors.white,
          ),
        );
      case AppThemeMode.dark:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF15131D),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFC8B6E2),
            brightness: Brightness.dark,
            primary: const Color(0xFFC8B6E2),
            secondary: const Color(0xFFFFC5D3),
            surface: const Color(0xFF1F1B2E),
          ),
        );
    }
  }
}

/// Tüm uygulamanın hızlı tema renklerine ulaşması için BuildContext extension'ı.
/// Tema değişince [Theme.of] yeniden çağrıldığı için renkler otomatik güncellenir.
extension AppColorsX on BuildContext {
  ColorScheme get _scheme => Theme.of(this).colorScheme;

  /// Marka birinci rengi (pembe / mavi / mor — temaya göre).
  Color get appPink => _scheme.primary;

  /// Marka ikinci rengi (lavanta / mavi-gri / pembe — temaya göre).
  Color get appLavender => _scheme.secondary;

  /// Sayfa arka planı (krem / açık mavi / koyu mor).
  Color get appCream => Theme.of(this).scaffoldBackgroundColor;

  /// Kart yüzeyi (beyaz / açık koyu).
  Color get appSurface => _scheme.surface;

  /// Ana metin rengi.
  Color get appTextDark => _scheme.onSurface;

  /// Yumuşak ikincil metin (subtitle, hint).
  Color get appMuted => _scheme.onSurface.withValues(alpha: 0.55);

  /// Çok soluk hatlar / divider rengi.
  Color get appHairline => _scheme.onSurface.withValues(alpha: 0.08);

  /// Aktif olan tema koyu mu?
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
}
