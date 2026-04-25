import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart'; // Yeni oluşturduğumuz dosyayı import ediyoruz

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // .env dosyasını yükle
  await dotenv.load(fileName: '.env');
  
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  
  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('SUPABASE_URL veya SUPABASE_ANON_KEY .env dosyasında tanımlanmadı.');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const RobotoyApp());
}

class RobotoyApp extends StatelessWidget {
  const RobotoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROBOTOY',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthScreen(), // İlk açılacak sayfa
    );
  }
}