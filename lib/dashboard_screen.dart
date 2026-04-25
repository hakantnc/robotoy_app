import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';
import 'camera_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  String _firstName = 'Ebeveyn';
  int? _userId; // public.users tablosundaki ID'miz
  String? _robotId; // Eşleşen robotun kodu

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndRobot();
  }

  // 1. Önce Kullanıcıyı, Sonra Robotunu Çekiyoruz
  Future<void> _fetchUserDataAndRobot() async {
    final user = supabase.auth.currentUser;
    if (user != null && user.email != null) {
      try {
        final userData = await supabase.from('users').select('user_id, first_name').eq('email', user.email!).single();
        _userId = userData['user_id'];
        _firstName = userData['first_name'] ?? 'Ebeveyn';

        final robotData = await supabase.from('user_robots').select('robot_id').eq('user_id', _userId!).maybeSingle();

        if (robotData != null) {
          setState(() {
            _robotId = robotData['robot_id'];
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
          _showPairingDialog();
        }
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 2. Robot Eşleştirme Diyalogu
  void _showPairingDialog() {
    final codeController = TextEditingController();
    bool isPairing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Robotunu Bağla 🤖'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Lütfen satın aldığınız ROBOTOY kutusunun içinden çıkan veya size verilen Robot Kodunu girin.'),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Robot Kodu (Örn: ROBO-PI5)', border: OutlineInputBorder()),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => _signOut(),
                child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
              ),
              isPairing
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        final code = codeController.text.trim();
                        if (code.isEmpty) return;

                        setDialogState(() => isPairing = true);

                        try {
                          await supabase.from('user_robots').insert({
                            'user_id': _userId,
                            'robot_id': code
                          });

                          if (mounted) {
                            Navigator.pop(context);
                            setState(() => _robotId = code);
                          }
                        } catch (e) {
                          setDialogState(() => isPairing = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Hata: Robot kodu geçersiz veya zaten bağlı.'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      child: const Text('Eşleştir'),
                    ),
            ],
          );
        });
      },
    );
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AuthScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_robotId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ROBOTOY Panel'), actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _signOut)]),
        body: const Center(child: Text('Lütfen bir robot eşleştirin.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ROBOTOY Canlı Panel'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _signOut)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Merhaba, $_firstName 👋', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text('Bağlı Robot: $_robotId', style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 20),

            // --- CANLI VERİLER (BATARYA & ISI) ---
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('robot_status').stream(primaryKey: ['id']).eq('robot_id', _robotId!).order('time').limit(1),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Robot verisi bekleniyor...');
                }
                
                final lastData = snapshot.data!.first;
                final battery = lastData['battery_level'] ?? 0;
                final temp = lastData['cpu_temp'] ?? 0;
                final isCharging = lastData['charging'] ?? false;

                return Row(
                  children: [
                    Expanded(child: _buildStatusCard('Batarya', '%$battery', isCharging ? Icons.battery_charging_full : Icons.battery_std, isCharging ? Colors.orange : Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatusCard('Sıcaklık', '$temp°C', Icons.thermostat, Colors.red)),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 24), // Araya boşluk ekledik

            // --- KAMERA BAĞLANTI BUTONU ---
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // Butona basıldığında Kameraya git ve robotId'yi ilet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(robotId: _robotId!),
                      ),
                    );
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam, color: Colors.white, size: 40),
                      SizedBox(height: 8),
                      Text(
                        'Canlı Kameraya Bağlan',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          Text(title, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}