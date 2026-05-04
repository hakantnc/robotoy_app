import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'auth_screen.dart';
import 'main_screen.dart';
import 'dart:io' show Platform;
import 'add_child_screen.dart';
import 'settings_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;

  bool _isLoading = true;
  String _firstName = 'Ebeveyn';
  int? _userId;
  String? _robotId;

  // Günlük raporu tutacağımız değişken
  String _dailyReport = 'Hesaplanıyor...';

  // --- KAMERA DEĞİŞKENLERİ ---
  WebViewController? _cameraController;
  bool _isCameraLoading = true;
  String _cameraError = '';

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndRobot();
  }

  Future<void> _setupNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. İzin İste
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android 12 ve altı için .provisional da dönebilir, onu da kabul ediyoruz
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // 2. Token'ı al
      String? token = await messaging.getToken();

      if (token != null && _userId != null) {
        try {
          // Context kullanmadan güvenli cihaz tespiti
          final deviceType = Platform.isAndroid ? 'Android' : 'iOS';

          // 3. Supabase'e Yaz
          await supabase.from('user_push_tokens').upsert({
            'user_id': _userId,
            'push_token': token,
            'device_type': deviceType,
          }, onConflict: 'user_id, push_token');

          debugPrint("✅ Token kaydedildi: $token");

          // BAŞARILI OLURSA EKRANDA GÖRELİM (Test için)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Token veritabanına başarıyla yazıldı!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          debugPrint("❌ Token DB'ye yazılamadı: $e");

          // HATA OLURSA EKRANDA GÖRELİM (Sorunun ne olduğunu bize söyleyecek)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ DB Hatası: $e'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      }
    } else {
      debugPrint("❌ Kullanıcı bildirim izni vermedi.");
    }
  }

  Future<void> _fetchUserDataAndRobot() async {
    final user = supabase.auth.currentUser;
    if (user != null && user.email != null) {
      try {
        final userData = await supabase
            .from('users')
            .select('user_id, first_name')
            .eq('email', user.email!)
            .single();
        _userId = userData['user_id'];
        _firstName = userData['first_name'] ?? 'Ebeveyn';
        _setupNotifications(); // Bildirim izni ve token kaydı işlemini başlat

        final robotData = await supabase
            .from('user_robots')
            .select('robot_id')
            .eq('user_id', _userId!)
            .maybeSingle();

        if (robotData != null) {
          setState(() {
            _robotId = robotData['robot_id'];
            _isLoading = false;
          });
          _initCamera();
          _fetchDailyReport(); // Robot bulunduysa raporu çek
        } else {
          setState(() => _isLoading = false);
          _showPairingDialog();
        }
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- GÜNLÜK RAPORU ÇEKME FONKSİYONU ---
  Future<void> _fetchDailyReport() async {
    // Bugünün tarihini YYYY-MM-DD formatında alıyoruz
    final today = DateTime.now().toIso8601String().split('T')[0];
    try {
      final response = await supabase
          .from('daily_crying_reports')
          .select('total_crying_minutes')
          .eq('robot_id', _robotId!)
          .eq('report_date', today)
          .maybeSingle();

      if (mounted) {
        setState(() {
          if (response != null && response['total_crying_minutes'] != null) {
            _dailyReport = '${response['total_crying_minutes']} dk Ağladı';
          } else {
            _dailyReport = 'Kayıt Yok';
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _dailyReport = 'Veri Alınamadı');
    }
  }

  // --- KAMERAYI BAŞLATMA FONKSİYONU ---
  Future<void> _initCamera() async {
    try {
      final response = await supabase
          .from('robots')
          .select('streaming_url')
          .eq('robot_id', _robotId!)
          .maybeSingle();

      if (response != null && response['streaming_url'] != null) {
        final streamUrl = response['streaming_url'];

        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.black);

        if (controller.platform is AndroidWebViewController) {
          (controller.platform as AndroidWebViewController)
              .setMediaPlaybackRequiresUserGesture(false);
        }

        await controller.loadRequest(Uri.parse(streamUrl));

        if (mounted) {
          setState(() {
            _cameraController = controller;
            _isCameraLoading = false;
          });
        }
      } else {
        setState(() => _cameraError = 'Kamera linki bulunamadı.');
      }
    } catch (e) {
      setState(() => _cameraError = 'Kameraya bağlanılamadı.');
    }
  }

  // --- ROBOT KOMUT GÖNDERME FONKSİYONLARI ---
  // --- ROBOT KOMUT GÖNDERME FONKSİYONLARI (AKILLI TOGGLE) ---
  Future<void> _sendRobotCommand(
    String targetCommand,
    String currentCommand,
  ) async {
    if (_robotId == null) return;

    // Eğer bastığımız buton zaten aktif olan komutsa, durdurmak için 'none' gönder
    final commandToSend = (currentCommand == targetCommand)
        ? 'none'
        : targetCommand;

    try {
      await supabase
          .from('robots')
          .update({'current_command': commandToSend})
          .eq('robot_id', _robotId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              commandToSend == 'none'
                  ? 'Komut durduruldu 🛑'
                  : 'Komut gönderildi: $targetCommand 🚀',
            ),
            backgroundColor: commandToSend == 'none'
                ? Colors.orange
                : Colors.green,
            duration: const Duration(
              seconds: 1,
            ), // Üst üste basılınca ekranda beklemesin
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hata: Komut iletilemedi!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildControlButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
      onPressed: onTap,
    );
  }

  // --- EŞLEŞTİRME DİYALOGU ---
  void _showPairingDialog() {
    final codeController = TextEditingController();
    bool isPairing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Robotunu Bağla 🤖'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Lütfen Robot Kodunu girin.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Robot Kodu (Örn: ROBO-PI5)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _signOut,
                  child: const Text(
                    'Çıkış Yap',
                    style: TextStyle(color: Colors.red),
                  ),
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
                              'robot_id': code,
                            });
                            if (mounted) {
                              Navigator.pop(context);
                              setState(() => _robotId = code);
                              _initCamera();
                              _fetchDailyReport();
                            }
                          } catch (e) {
                            setDialogState(() => isPairing = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Hata: Robot kodu geçersiz.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('Eşleştir'),
                      ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_robotId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ROBOTOY Panel'),
          actions: [
            IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
          ],
        ),
        body: const Center(child: Text('Lütfen bir robot eşleştirin.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      // === EKLENEN YENİ BUTON KODU BURASI ===
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddChildScreen()),
          );
        },
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.child_care),
        label: const Text(
          'Çocuk Ekle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // =======================================
      appBar: AppBar(
        title: const Text('ROBOTOY Kontrol Paneli'),
        elevation: 0,
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Merhaba, $_firstName 👋',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Bağlı Robot: $_robotId',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // --- 4'LÜ BİLGİ KUTUCUKLARI (GRID MİMARİSİ) ---
            GridView.count(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Scroll çakışmasını önler
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3, // Kutucukların en/boy oranı
              children: [
                // 1. Kutu: AI Duygu Durumu ve Tespit (robots tablosundan)
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: supabase
                      .from('robots')
                      .stream(primaryKey: ['robot_id'])
                      .eq('robot_id', _robotId!),
                  builder: (context, snapshot) {
                    final aiData = snapshot.data?.isNotEmpty == true
                        ? snapshot.data!.first
                        : {};
                    final emotion = aiData['emotion'] ?? 'Bilinmiyor';
                    final detectedPerson =
                        aiData['detected_person'] ?? 'Aranıyor...';

                    return Column(
                      children: [
                        Expanded(
                          child: _buildStatusCard(
                            'Algılanan Kişi',
                            detectedPerson,
                            Icons.face_retouching_natural,
                            Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),

                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: supabase
                      .from('robots')
                      .stream(primaryKey: ['robot_id'])
                      .eq('robot_id', _robotId!),
                  builder: (context, snapshot) {
                    final aiData = snapshot.data?.isNotEmpty == true
                        ? snapshot.data!.first
                        : {};
                    final emotion = aiData['emotion'] ?? 'Bilinmiyor';

                    return _buildStatusCard(
                      'Duygu Durumu',
                      emotion,
                      Icons.emoji_emotions,
                      Colors.orange,
                    );
                  },
                ),

                // 3. Kutu: Günlük Rapor (Sanal Tablodan hesaplanıp gelen)
                _buildStatusCard(
                  'Günlük Rapor',
                  _dailyReport,
                  Icons.insert_chart_outlined,
                  Colors.purple,
                ),

                // 4. Kutu: Sistem Durumu (robot_status tablosundan)
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: supabase
                      .from('robot_status')
                      .stream(primaryKey: ['id'])
                      .eq('robot_id', _robotId!)
                      .order('time')
                      .limit(1),
                  builder: (context, snapshot) {
                    final lastData = snapshot.data?.isNotEmpty == true
                        ? snapshot.data!.first
                        : {};
                    final battery = lastData['battery_level'] ?? 0;
                    final temp = lastData['cpu_temp'] ?? 0;

                    return _buildStatusCard(
                      'Sistem',
                      '🔋 %$battery  |  🌡️ $temp°C',
                      Icons.memory,
                      Colors.teal,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Canlı Kamera',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // --- KAMERA EKRANI ---
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: _cameraController == null
                  ? Center(
                      child: _cameraError.isNotEmpty
                          ? Text(
                              _cameraError,
                              style: const TextStyle(color: Colors.redAccent),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 10),
                                Text(
                                  'Kameraya bağlanılıyor...',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                    )
                  : WebViewWidget(controller: _cameraController!),
            ),

            const SizedBox(height: 24),

            // --- YENİ: ROBOT KONTROLLERİ ---
            const Text(
              'Robot Kontrolleri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('robots')
                  .stream(primaryKey: ['robot_id'])
                  .eq('robot_id', _robotId!),
              builder: (context, snapshot) {
                // Veritabanındaki güncel veriyi çekiyoruz
                final robotData = snapshot.data?.isNotEmpty == true
                    ? snapshot.data!.first
                    : {};
                final currentCommand = robotData['current_command'] ?? 'none';

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      context,
                      title: currentCommand == 'play_song'
                          ? 'Durdur'
                          : 'Şarkı Çal',
                      icon: currentCommand == 'play_song'
                          ? Icons.stop
                          : Icons.music_note,
                      color: currentCommand == 'play_song'
                          ? Colors.redAccent
                          : Colors.blue,
                      onTap: () =>
                          _sendRobotCommand('play_song', currentCommand),
                    ),
                    _buildControlButton(
                      context,
                      title: currentCommand == 'play_lullaby'
                          ? 'Durdur'
                          : 'Ninni Çal',
                      icon: currentCommand == 'play_lullaby'
                          ? Icons.stop
                          : Icons.nightlight_round,
                      color: currentCommand == 'play_lullaby'
                          ? Colors.redAccent
                          : Colors.indigo,
                      onTap: () =>
                          _sendRobotCommand('play_lullaby', currentCommand),
                    ),
                    _buildControlButton(
                      context,
                      title: currentCommand == 'dance' ? 'Durdur' : 'Dans Et',
                      icon: currentCommand == 'dance'
                          ? Icons.stop
                          : Icons.directions_run,
                      color: currentCommand == 'dance'
                          ? Colors.redAccent
                          : Colors.deepOrange,
                      onTap: () => _sendRobotCommand('dance', currentCommand),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // --- YENİ EKLENEN: AĞLAMA GEÇMİŞİ WIDGET'I ---
            _buildCryingTimeline(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- AĞLAMA GEÇMİŞİ (TIMELINE) WIDGET'I (FIXED) ---
  Widget _buildCryingTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Son Olaylar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        StreamBuilder<List<Map<String, dynamic>>>(
          // Stream içinde sadece TEK FİLTRE (robot_id) kullanıyoruz
          stream: supabase
              .from('monitoring_events')
              .stream(primaryKey: ['id'])
              .eq('robot_id', _robotId!)
              .order('created_at', ascending: false)
              .limit(
                20,
              ), // İçinden ayıklama yapacağımız için limiti biraz yüksek tuttuk
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text(
                'Henüz bir olay kaydedilmedi.',
                style: TextStyle(color: Colors.grey),
              );
            }

            // Gelen tüm olayların içinden sadece 'baby_crying' olanları Dart ile filtreliyoruz
            final cryingEvents = snapshot.data!
                .where((e) => e['event_type'] == 'baby_crying')
                .take(5) // Sadece son 5 ağlama olayını göster
                .toList();

            if (cryingEvents.isEmpty) {
              return const Text(
                'Kayıtlı ağlama olayı bulunmuyor.',
                style: TextStyle(color: Colors.grey),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cryingEvents.length,
              itemBuilder: (context, index) {
                final event = cryingEvents[index];
                final data = event['data'] as Map<String, dynamic>;
                final isStart =
                    data['status'] == 'start'; // 'start' veya 'stop' kontrolü

                final DateTime time = DateTime.parse(
                  event['created_at'],
                ).toLocal();
                final String formattedTime =
                    "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

                return IntrinsicHeight(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.access_time_filled_rounded,
                              size: 16,
                              color: isStart ? Colors.redAccent : Colors.grey,
                            ),
                          ),
                          if (index != cryingEvents.length - 1)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: Colors.grey.shade300,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          "$formattedTime - ${isStart ? 'Ağlama Algılandı' : 'Ağlama Durdu'}",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isStart
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isStart ? Colors.black87 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
