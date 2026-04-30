import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// FİREBASE KÜTÜPHANELERİ EKLENDİ
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_screen.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. FİREBASE'İ BAŞLAT (Supabase'den önce burası çalışmalı)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. SUPABASE BAŞLATMA
  await Supabase.initialize(url: 'SUPABASE_URL', anonKey: 'SUPABASE_ANON_KEY');

  runApp(const RobotoyApp());
}

class RobotoyApp extends StatelessWidget {
  const RobotoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'ROBOTOY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: session == null ? const AuthScreen() : MainScreen(),
    );
  }
}
