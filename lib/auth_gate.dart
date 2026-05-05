import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart'; // Kendi giriş ekranının dosya adı
import 'main_screen.dart'; // Kendi ana ekranının dosya adı
import 'theme_controller.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final supabase = Supabase.instance.client;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // Supabase'in giriş/çıkış olaylarını (Deep Link dahil) anlık dinleyen yapı
    supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        // Kullanıcı giriş yaptı! (Google'dan döndü veya normal giriş yaptı)
        await _syncUserData(session.user);
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else if (event == AuthChangeEvent.signedOut) {
        // Çıkış yapıldı
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AuthScreen()),
          );
        }
      } else if (event == AuthChangeEvent.initialSession) {
        // Uygulama ilk açıldığında çalışır (Otomatik Giriş Kontrolü)
        if (session != null) {
          // Oturum zaten var, şifre sormadan içeri al!
          await _syncUserData(session.user);
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        } else {
          // Oturum yok, giriş ekranını göster
          if (mounted) {
            setState(() => _isChecking = false);
          }
        }
      }
    });
  }

  // === GOOGLE'DAN VEYA KAYITTAN GELEN İSMİ VERİTABANINA YAZMA FONKSİYONU ===
  Future<void> _syncUserData(User user) async {
    try {
      // Önce bu kullanıcının bizim 'users' tablosunda olup olmadığına bakalım
      final existingUser = await supabase.from('users').select().eq('email', user.email!).maybeSingle();

      String firstName = 'Yeni';
      String lastName = 'Kullanıcı';

      // Supabase'in bize sunduğu gizli Metadata paketi
      final meta = user.userMetadata;
      if (meta != null) {
        // 1. Durum: Google ile giriş yapıldıysa isim 'full_name' içindedir
        if (meta.containsKey('full_name')) {
          final fullName = meta['full_name'].toString();
          final parts = fullName.split(' ');
          firstName = parts.isNotEmpty ? parts.first : 'Google';
          lastName = parts.length > 1 ? parts.sublist(1).join(' ') : 'Kullanıcısı';
        } 
        // 2. Durum: Normal kayıt yapıldıysa AuthScreen'deki data'dan gelir
        else if (meta.containsKey('first_name')) {
          firstName = meta['first_name'];
          lastName = meta['last_name'] ?? '';
        }
      }

      if (existingUser == null) {
        // KULLANICI İLK KEZ GİRİŞ YAPIYOR -> Tabloya Ekle
        await supabase.from('users').insert({
          'email': user.email,
          'first_name': firstName,
          'last_name': lastName,
        });
        debugPrint('✅ Yeni kullanıcı users tablosuna eklendi!');
      } 
      // (Opsiyonel) Eğer kullanıcı varsa ama ismi "Yeni" kalmışsa güncelleyebilirsin, 
      // şimdilik var olan kullanıcının ismini ezmemesi için bir şey yapmıyoruz.
      
    } catch (e) {
      debugPrint('❌ Kullanıcı senkronizasyon hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sistem kontrol yaparken ekranda tatlı bir yüklenme animasyonu göster
    if (_isChecking) {
      return Scaffold(
        backgroundColor: context.appCream,
        body: Center(
          child: CircularProgressIndicator(color: context.appPink),
        ),
      );
    }

    // Eğer oturum yoksa AuthScreen (Giriş) ekranını bas
    return const AuthScreen();
  }
}