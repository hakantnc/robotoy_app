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
  await Supabase.initialize(
    url: 'https://gwkdypfpxftqqwimqodr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3a2R5cGZweGZ0cXF3aW1xb2RyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5NjAxMzEsImV4cCI6MjA5MjUzNjEzMX0.hC7m4FQ40pyRSHdiy_uJT3HPkoQ8G0s-5j00ZutOFvk',
  );

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
