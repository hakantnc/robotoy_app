import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama genelinde aktif dili yöneten singleton controller.
///
/// `MaterialApp`'in `locale` parametresine bağlandığında
/// [setLocale] çağrısı tüm uygulamayı yeniden boyutlandırır ve metinler
/// otomatik olarak yeni dile geçer.
class LocaleController extends ChangeNotifier {
  static final LocaleController instance = LocaleController._();
  LocaleController._();

  static const String _prefsKey = 'app_locale';

  /// Desteklenen diller — `MaterialApp.supportedLocales` ile aynı sıra.
  static const List<Locale> supported = [
    Locale('tr'),
    Locale('en'),
    Locale('ar'),
  ];

  Locale _locale = const Locale('tr');
  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null) {
      final match = supported.firstWhere(
        (l) => l.languageCode == code,
        orElse: () => const Locale('tr'),
      );
      _locale = match;
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == _locale.languageCode) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
    notifyListeners();
  }
}
