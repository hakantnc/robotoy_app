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
    url: 'https://gwkdypfpxftqqwimqodr.supabase.co', // Supabase URL'si
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3a2R5cGZweGZ0cXF3aW1xb2RyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5NjAxMzEsImV4cCI6MjA5MjUzNjEzMX0.hC7m4FQ40pyRSHdiy_uJT3HPkoQ8G0s-5j00ZutOFvk' // Supabase Anon Key
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
