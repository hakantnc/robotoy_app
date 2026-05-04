import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; // Mevcut anasayfamız
import 'auth_screen.dart'; // Giriş ekranı
import 'joystick_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex =
      0; // Uygulama ilk açıldığında 0. sekme (Anasayfa) görünür

  // --- SEKME İÇERİKLERİ ---
  // Şimdilik boş olanlara geçici yer tutucular (Placeholder) koyduk
  final List<Widget> _pages = [
    const DashboardScreen(), // 0. Sekme: Senin yazdığın panel
    // 1. Sekme: Raporlarım
    const ReportsScreen(), // Raporlar ekranını buraya ekliyoruz
    // 2. Sekme: Joystick
    const JoystickScreen(), // Joystick ekranını buraya ekliyoruz
    // 3. Sekme: Ayarlar
    const SettingsScreen(), // Ayarlar ekranını buraya ekliyoruz
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // IndexedStack: Sayfaları arka planda uyutur ama öldürmez. (Kamera kopmaz!)
      body: IndexedStack(index: _selectedIndex, children: _pages),

      // --- ALT MENÜ (NAVBAR) TASARIMI ---
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // 4 ikon olduğu için fixed yapmamız şart
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey.shade400,
        showUnselectedLabels: true,
        elevation: 15,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Raporlarım',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad_rounded),
            label: 'Joystick',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}
