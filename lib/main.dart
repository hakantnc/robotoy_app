import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// FİREBASE KÜTÜPHANELERİ
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. FİREBASE'İ BAŞLAT (Supabase'den önce burası çalışmalı)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. SUPABASE BAŞLATMA
  await Supabase.initialize(
    url: 'SUPABASE_URL', // Supabase URL'si
    anonKey: 'SUPABASE_ANON_KEY', // Supabase Anon Key
  );

  runApp(const RobotoyApp());
}

class RobotoyApp extends StatelessWidget {
  const RobotoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROBOTOY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // 🔥 KRİTİK DEĞİŞİKLİK: Uygulama her zaman Güvenlik Kapısı'ndan (AuthGate) başlar.
      // İçeri alınıp alınmayacağına veya Dashboard'a atılıp atılmayacağına AuthGate karar verir.
      home: const AuthGate(),
    );
  }
}