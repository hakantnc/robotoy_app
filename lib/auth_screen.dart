import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_screen.dart';
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Kontrolcülerimiz (Ad ve Soyad eklendi)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true; // True ise Giriş Yap, False ise Kayıt Ol ekranı

  Future<void> _authenticate() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen e-posta ve şifre girin.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // Giriş Yapma İşlemi
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        // Yeni Kayıt Olma İşlemi (Ad Soyad verisiyle gönderiliyor)
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
          },
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isLogin ? 'Giriş Başarılı!' : 'Kayıt Başarılı!')),
        );
        
        // YENİ EKLENEN YÖNLENDİRME KODU
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Beklenmeyen bir hata oluştu.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'ROBOTOY Giriş' : 'ROBOTOY Kayıt Ol'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Klavye açıldığında ekranın kayabilmesi için SingleChildScrollView ekledik
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // EĞER KAYIT OL (Sign Up) EKRANINDAYSAK AD-SOYAD GÖSTER
              if (!_isLogin) ...[
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Ad'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Soyad'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
              ],
              
              // E-POSTA VE ŞİFRE (Her iki durumda da görünür)
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-posta'),
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              
              // GİRİŞ/KAYIT BUTONU
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _authenticate,
                      child: Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
                    ),
              const SizedBox(height: 16),
              
              // EKRANLAR ARASI GEÇİŞ BUTONU
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin
                      ? 'Hesabın yok mu? Kayıt Ol'
                      : 'Zaten hesabın var mı? Giriş Yap',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}