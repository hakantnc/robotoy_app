import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// FİREBASE KÜTÜPHANELERİ
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'theme_controller.dart';
import 'locale_controller.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. FİREBASE'İ BAŞLAT (Supabase'den önce burası çalışmalı)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. SUPABASE BAŞLATMA
  await Supabase.initialize(
    url: String.fromEnvironment('SUPABASE_URL'), // Supabase URL'si
    anonKey: String.fromEnvironment('SUPABASE_ANON_KEY'), // Supabase Anon Key
  );

  // 3. KAYITLI TEMA + DİL TERCİHİNİ YÜKLE
  await ThemeController.instance.load();
  await LocaleController.instance.load();

  runApp(const RobotoyApp());
}

class RobotoyApp extends StatelessWidget {
  const RobotoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ThemeController.instance,
        LocaleController.instance,
      ]),
      builder: (context, _) => MaterialApp(
        title: 'ROBOTOY',
        debugShowCheckedModeBanner: false,
        theme: ThemeController.instance.themeData,

        // ─── i18n ────────────────────────────────────────────────────
        locale: LocaleController.instance.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,

        // 🔥 KRİTİK DEĞİŞİKLİK: Uygulama her zaman Güvenlik Kapısı'ndan (AuthGate) başlar.
        // İçeri alınıp alınmayacağına veya Dashboard'a atılıp atılmayacağına AuthGate karar verir.
        home: const AuthGate(),
      ),
    );
  }
}
