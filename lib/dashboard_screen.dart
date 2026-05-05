import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'auth_screen.dart';
import 'dart:io' show Platform;
import 'add_child_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'theme_controller.dart';
import 'l10n/app_localizations.dart';

// Sadece semantic (durum) renkleri sabit kalır — bunlar tema bağımsız.
const Color _kStartRed = Color(0xFFFF8FA3);
const Color _kStopGreen = Color(0xFF94D2A4);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;

  // Tema renklerini context üzerinden alan getter'lar; tema değişince
  // otomatik olarak yeni renge geçerler.
  Color get _kPink => context.appPink;
  Color get _kLavender => context.appLavender;
  Color get _kCream => context.appCream;
  Color get _kDarkPurple => context.appTextDark;
  Color get _kSoftPurple => context.appMuted;
  Color get _kSurface => context.appSurface;

  bool _isLoading = true;
  String _firstName = 'Ebeveyn';
  int? _userId;
  String? _robotId;

  // Günlük raporu tutacağımız değişken (initState sırasında dil bilgisi
  // henüz hazır değil; didChangeDependencies içinde lokalize edilecek)
  String _dailyReport = '';
  bool _dailyReportInitialized = false;

  // --- KAMERA DEĞİŞKENLERİ ---
  WebViewController? _cameraController;
  bool _isCameraLoading = true;
  String _cameraError = '';

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndRobot();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dailyReportInitialized) {
      _dailyReport = AppLocalizations.of(context).dashboard_calculating;
      _dailyReportInitialized = true;
    }
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

          // BAŞARILI OLURSA EKRANDA GÖRELİM (Test için)
         
        } catch (e) {
         
        }
      }
    } else {
      return;
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
        final t = AppLocalizations.of(context);
        setState(() {
          if (response != null && response['total_crying_minutes'] != null) {
            _dailyReport = t.dashboard_minutes_crying(
              response['total_crying_minutes'],
            );
          } else {
            _dailyReport = t.dashboard_no_record;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _dailyReport = AppLocalizations.of(context).dashboard_no_data);
      }
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
        setState(
          () => _cameraError = AppLocalizations.of(context).dashboard_cam_link_missing,
        );
      }
    } catch (e) {
      setState(
        () => _cameraError = AppLocalizations.of(context).dashboard_cam_connect_fail,
      );
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
      
    } catch (e) {
      return;
    }
  }

  Widget _buildControlButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final Color darker = Color.lerp(color, Colors.black, 0.22) ?? color;
    return _ScaleOnTap(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, darker],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(color: Colors.white, width: 2.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isActive ? 0.55 : 0.3),
              blurRadius: isActive ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- EŞLEŞTİRME DİYALOGU ---
  void _showPairingDialog() {
    final codeController = TextEditingController();
    bool isPairing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final t = AppLocalizations.of(dialogContext);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('${t.dashboard_pair_title} 🤖'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t.dashboard_pair_label),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: t.dashboard_pair_hint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _signOut,
                  child: Text(
                    t.settings_signout,
                    style: const TextStyle(color: Colors.red),
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
                              SnackBar(
                                content: Text(t.dashboard_pair_invalid),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Text(t.dashboard_pair_action),
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
      return Scaffold(
        backgroundColor: _kCream,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_kPink),
            strokeWidth: 3,
          ),
        ),
      );
    }

    final t = AppLocalizations.of(context);

    if (_robotId == null) {
      return Scaffold(
        backgroundColor: _kCream,
        appBar: _buildGradientAppBar(
          title: t.dashboard_title_short,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _signOut,
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              t.dashboard_no_robot,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: _kDarkPurple,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _kCream,
      appBar: _buildGradientAppBar(title: t.dashboard_title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 24),

            _buildAddChildCard(),
            const SizedBox(height: 24),

            _buildSectionTitle(t.dashboard_section_status),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: supabase
                      .from('robots')
                      .stream(primaryKey: ['robot_id'])
                      .eq('robot_id', _robotId!),
                  builder: (context, snapshot) {
                    final aiData = snapshot.data?.isNotEmpty == true
                        ? snapshot.data!.first
                        : {};
                    final detectedPerson =
                        aiData['detected_person'] ?? t.dashboard_searching;

                    return _buildStatusCard(
                      t.dashboard_status_detected_person,
                      detectedPerson,
                      Icons.face_retouching_natural,
                      _kPink,
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
                    final emotion = aiData['emotion'] ?? t.dashboard_unknown;

                    return _buildStatusCard(
                      t.dashboard_status_emotion,
                      emotion,
                      Icons.emoji_emotions,
                      const Color(0xFFFFD6A5),
                    );
                  },
                ),

                _buildStatusCard(
                  t.dashboard_status_daily_report,
                  _dailyReport,
                  Icons.insert_chart_outlined,
                  _kLavender,
                ),

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
                      t.dashboard_status_system,
                      '🔋 %$battery |🌡️ $temp°C',
                      Icons.memory,
                      const Color(0xFFB5EAD7),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionTitle(t.dashboard_section_camera),
            const SizedBox(height: 12),
            _buildCameraView(),

            const SizedBox(height: 24),

            _buildSectionTitle(t.dashboard_section_controls),
            const SizedBox(height: 12),

            StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('robots')
                  .stream(primaryKey: ['robot_id'])
                  .eq('robot_id', _robotId!),
              builder: (context, snapshot) {
                final robotData = snapshot.data?.isNotEmpty == true
                    ? snapshot.data!.first
                    : {};
                final currentCommand = robotData['current_command'] ?? 'none';

                return Row(
                  children: [
                    Expanded(
                      child: _buildControlButton(
                        context,
                        title: currentCommand == 'play_song'
                            ? t.dashboard_btn_stop
                            : t.dashboard_btn_song,
                        icon: currentCommand == 'play_song'
                            ? Icons.stop
                            : Icons.music_note,
                        color: currentCommand == 'play_song'
                            ? _kStartRed
                            : _kPink,
                        isActive: currentCommand == 'play_song',
                        onTap: () =>
                            _sendRobotCommand('play_song', currentCommand),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildControlButton(
                        context,
                        title: currentCommand == 'play_lullaby'
                            ? t.dashboard_btn_stop
                            : t.dashboard_btn_lullaby,
                        icon: currentCommand == 'play_lullaby'
                            ? Icons.stop
                            : Icons.nightlight_round,
                        color: currentCommand == 'play_lullaby'
                            ? _kStartRed
                            : _kLavender,
                        isActive: currentCommand == 'play_lullaby',
                        onTap: () =>
                            _sendRobotCommand('play_lullaby', currentCommand),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildControlButton(
                        context,
                        title: currentCommand == 'dance'
                            ? t.dashboard_btn_stop
                            : t.dashboard_btn_dance,
                        icon: currentCommand == 'dance'
                            ? Icons.stop
                            : Icons.directions_run,
                        color: currentCommand == 'dance'
                            ? _kStartRed
                            : const Color(0xFFFFD6A5),
                        isActive: currentCommand == 'dance',
                        onTap: () => _sendRobotCommand('dance', currentCommand),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            _buildCryingTimeline(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGradientAppBar({
    required String title,
    List<Widget>? actions,
  }) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 70,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_kPink, _kLavender],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kPink.withOpacity(0.55),
            _kLavender.withOpacity(0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kLavender.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).dashboard_hello(_firstName),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: _kDarkPurple,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)
                      .dashboard_connected_robot(_robotId ?? ''),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7E6E96),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _kPink,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _kPink.withOpacity(0.45),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _firstName.isNotEmpty ? _firstName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddChildCard() {
    return _ScaleOnTap(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddChildScreen()),
        );
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_kPink, _kLavender],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _kPink.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.child_care, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context).dashboard_add_child,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _kDarkPurple,
      ),
    );
  }

  Widget _buildCameraView() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kLavender.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: _cameraController == null
          ? Center(
              child: _cameraError.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam_off_rounded,
                            color: _kPink,
                            size: 42,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _cameraError,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(_kPink),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context).dashboard_cam_connecting,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
            )
          : WebViewWidget(controller: _cameraController!),
    );
  }

  Widget _buildStatusCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kLavender.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.35)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.45),
                  color.withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, color: _kDarkPurple, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: _kSoftPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _kDarkPurple,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryingTimeline() {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(t.dashboard_section_recent),
        const SizedBox(height: 12),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: supabase
              .from('monitoring_events')
              .stream(primaryKey: ['id'])
              .eq('robot_id', _robotId!)
              .order('created_at', ascending: false)
              .limit(20),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_kPink),
                    strokeWidth: 3,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildEmptyTimeline(
                message: t.dashboard_events_loading_failed,
                icon: Icons.cloud_off_rounded,
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyTimeline();
            }

            final cryingEvents = snapshot.data!
                .where((e) => e['event_type'] == 'baby_crying')
                .take(5)
                .toList();

            if (cryingEvents.isEmpty) {
              return _buildEmptyTimeline();
            }

            return Column(
              children: List.generate(cryingEvents.length, (index) {
                final event = cryingEvents[index];
                final data = event['data'] as Map<String, dynamic>;
                final isStart = data['status'] == 'start';

                final DateTime time = DateTime.parse(
                  event['created_at'],
                ).toLocal();
                final String formattedTime =
                    "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

                final Color dotColor = isStart ? _kStartRed : _kStopGreen;

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _kLavender.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                              boxShadow: [
                                BoxShadow(
                                  color: dotColor.withOpacity(0.45),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _kSoftPurple,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isStart
                                      ? t.dashboard_event_crying_started
                                      : t.dashboard_event_crying_stopped,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isStart
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: _kDarkPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isStart
                                ? Icons.notifications_active_rounded
                                : Icons.check_circle_rounded,
                            color: dotColor,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                    if (index != cryingEvents.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: _buildDashedLine(),
                      ),
                  ],
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyTimeline({
    String? message,
    IconData icon = Icons.spa_rounded,
  }) {
    final resolvedMessage =
        message ?? AppLocalizations.of(context).dashboard_no_events;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kLavender.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _kPink.withOpacity(0.55),
                  _kLavender.withOpacity(0.55),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            resolvedMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _kSoftPurple,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return SizedBox(
      height: 8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dashCount = (constraints.maxWidth / 8).floor();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(dashCount, (_) {
                return Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _kLavender.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class _ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ScaleOnTap({required this.child, required this.onTap});

  @override
  State<_ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<_ScaleOnTap> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
