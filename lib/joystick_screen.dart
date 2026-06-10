import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'theme_controller.dart';
import 'l10n/app_localizations.dart';

class JoystickScreen extends StatefulWidget {
  const JoystickScreen({super.key});

  @override
  State<JoystickScreen> createState() => _JoystickScreenState();
}

class _JoystickScreenState extends State<JoystickScreen> {
  final supabase = Supabase.instance.client;
  String? _robotId;

  // --- KAMERA DEĞİŞKENLERİ ---
  WebViewController? _cameraController;
  // ignore: unused_field
  bool _isCameraLoading = true;
  String _cameraError = '';

  // --- BLUETOOTH DEĞİŞKENLERİ ---
  // ignore: unused_field
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _selectedDevice;
  BluetoothConnection? _connection;
  bool isConnecting = false;
  bool get isConnected => (_connection?.isConnected ?? false);

  // Servo Açısı Değişkenleri
  double _boyunAci = 90;
  double _kafaAci = 90;

  @override
  void initState() {
    super.initState();
    _fetchRobotAndCamera();
    _izinleriAlVeBaslat();
  }

  // ==========================================
  // 1. SUPABASE VE KAMERA BAĞLANTISI
  // ==========================================
  Future<void> _fetchRobotAndCamera() async {
    final user = supabase.auth.currentUser;
    if (user != null && user.email != null) {
      try {
        final userData = await supabase
            .from('users')
            .select('user_id')
            .eq('email', user.email!)
            .single();
        final robotData = await supabase
            .from('user_robots')
            .select('robot_id')
            .eq('user_id', userData['user_id'])
            .maybeSingle();

        if (robotData != null) {
          _robotId = robotData['robot_id'];
          _initCamera();
        } else {
          if (mounted) {
            setState(() => _cameraError = 'Robot eşleşmesi bulunamadı.');
          }
        }
      } catch (e) {
        if (mounted) setState(() => _cameraError = 'Veri çekilemedi.');
      }
    }
  }

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
        if (mounted) setState(() => _cameraError = 'Kamera linki bulunamadı.');
      }
    } catch (e) {
      if (mounted) setState(() => _cameraError = 'Kameraya bağlanılamadı.');
    }
  }

  // ==========================================
  // 2. BLUETOOTH FONKSİYONLARI
  // ==========================================
  Future<void> _izinleriAlVeBaslat() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    FlutterBluetoothSerial.instance.state.then((state) {
      if (mounted) setState(() => _bluetoothState = state);
    });

    try {
      List<BluetoothDevice> pairedDevices = await FlutterBluetoothSerial
          .instance
          .getBondedDevices();
      if (mounted) setState(() => _devicesList = pairedDevices);
    } catch (e) {
      debugPrint("Cihazlar alınamadı: $e");
    }
  }

  void _baglan() async {
    if (_selectedDevice == null) return;
    setState(() => isConnecting = true);

    try {
      BluetoothConnection connection = await BluetoothConnection.toAddress(
        _selectedDevice!.address,
      );
      if (mounted) {
        setState(() {
          _connection = connection;
          isConnecting = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isConnecting = false);
    }
  }

  void _komutGonder(String komut) {
    if (isConnected) {
      _connection!.output.add(Uint8List.fromList(utf8.encode(komut)));
      _connection!.output.allSent.then((_) => debugPrint("Gönderilen: $komut"));
    }
  }

  @override
  void dispose() {
    if (isConnected) _connection?.dispose();
    super.dispose();
  }

  // ==========================================
  // ARAYÜZ (BUILD)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final pink = context.appPink;
    final lavender = context.appLavender;
    final textDark = context.appTextDark;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.appCream,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          t.joystick_title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [pink, lavender],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // --- 1. KAMERA ALANI ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: lavender.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: _cameraController == null
                  ? Center(
                      child: _cameraError.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                _cameraError,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                          : CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(pink),
                              strokeWidth: 3,
                            ),
                    )
                  : WebViewWidget(controller: _cameraController!),
            ),
          ),

          // --- 2. BLUETOOTH BAĞLANTI ÇUBUĞU ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: lavender.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<BluetoothDevice>(
                      isExpanded: true,
                      hint: Text(
                        t.joystick_select_device,
                        style: TextStyle(color: context.appMuted),
                      ),
                      value: _selectedDevice,
                      items: _devicesList
                          .map(
                            (device) => DropdownMenuItem(
                              value: device,
                              child: Text(
                                device.name ?? t.joystick_unknown_device,
                                style: TextStyle(color: textDark),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedDevice = value),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 44,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [pink, lavender],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: ElevatedButton(
                      onPressed: isConnected ? null : _baglan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                      child: isConnecting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isConnected
                                  ? t.joystick_connected
                                  : t.joystick_connect,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- 3. KONTROLLER ---
          Expanded(
            child: isConnected
                ? SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      16,
                      20,
                      MediaQuery.of(context).padding.bottom + 72 + 16 + 16,
                    ),
                    child: Column(
                      children: [
                        _kontrolButonuDuzen(),
                        const SizedBox(height: 24),
                        Container(height: 1, color: context.appHairline),
                        const SizedBox(height: 24),
                        _servoKontrolDuzen(),
                      ],
                    ),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [pink, lavender],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: const Icon(
                              Icons.bluetooth_searching_rounded,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t.joystick_no_connection,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.appMuted,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- D-PAD WIDGET'LARI ---
  Widget _kontrolButonuDuzen() {
    final t = AppLocalizations.of(context);
    return Column(
      children: [
        _yonButonu(t.joystick_btn_forward, Icons.arrow_upward, 'F'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // GÖRÜNÜM: Sol ikon ve etiket
            // İŞLEV: Robota 'R' komutunu göndererek donanımsal tersliği dengeler
            _yonButonu(t.joystick_btn_left, Icons.arrow_back, 'R'),

            const SizedBox(width: 60),

            // GÖRÜNÜM: Sağ ikon ve etiket
            // İŞLEV: Robota 'L' komutunu göndererek donanımsal tersliği dengeler
            _yonButonu(t.joystick_btn_right, Icons.arrow_forward, 'L'),
          ],
        ),
        _yonButonu(t.joystick_btn_back, Icons.arrow_downward, 'B'),
      ],
    );
  }

  Widget _yonButonu(String etiket, IconData ikon, String komut) {
    final pink = context.appPink;
    final lavender = context.appLavender;

    return GestureDetector(
      onTapDown: (_) => _komutGonder(komut),
      onTapUp: (_) => _komutGonder('S'),
      onTapCancel: () => _komutGonder('S'),
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [pink, lavender],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: pink.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: Colors.white, size: 28),
            Text(
              etiket,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _servoKontrolDuzen() {
    final pink = context.appPink;
    final lavender = context.appLavender;
    final textDark = context.appTextDark;
    final muted = context.appMuted;
    final t = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          Text(
            t.joystick_servo_title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Icon(Icons.swap_horiz_rounded, color: muted, size: 18),
              const SizedBox(width: 6),
              Text(
                t.joystick_neck_label(_boyunAci.toInt()),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: muted,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: pink,
              inactiveTrackColor: lavender.withValues(alpha: 0.3),
              thumbColor: pink,
              overlayColor: pink.withValues(alpha: 0.18),
            ),
            child: Slider(
              value: _boyunAci,
              min: 0,
              max: 180,
              onChanged: (val) => setState(() => _boyunAci = val),
              onChangeEnd: (val) => _komutGonder('X${val.toInt()}\n'),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.swap_vert_rounded, color: muted, size: 18),
              const SizedBox(width: 6),
              Text(
                t.joystick_head_label(_kafaAci.toInt()),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: muted,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: lavender,
              inactiveTrackColor: pink.withValues(alpha: 0.3),
              thumbColor: lavender,
              overlayColor: lavender.withValues(alpha: 0.18),
            ),
            child: Slider(
              value: _kafaAci,
              min: 0,
              max: 180,
              onChanged: (val) => setState(() => _kafaAci = val),
              onChangeEnd: (val) => _komutGonder('Y${val.toInt()}\n'),
            ),
          ),
        ],
      ),
    );
  }
}
