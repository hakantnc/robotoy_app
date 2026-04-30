import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

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
  bool _isCameraLoading = true;
  String _cameraError = '';

  // --- BLUETOOTH DEĞİŞKENLERİ ---
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
        final userData = await supabase.from('users').select('user_id').eq('email', user.email!).single();
        final robotData = await supabase.from('user_robots').select('robot_id').eq('user_id', userData['user_id']).maybeSingle();

        if (robotData != null) {
          _robotId = robotData['robot_id'];
          _initCamera();
        } else {
          if (mounted) setState(() => _cameraError = 'Robot eşleşmesi bulunamadı.');
        }
      } catch (e) {
        if (mounted) setState(() => _cameraError = 'Veri çekilemedi.');
      }
    }
  }

  Future<void> _initCamera() async {
    try {
      final response = await supabase.from('robots').select('streaming_url').eq('robot_id', _robotId!).maybeSingle();

      if (response != null && response['streaming_url'] != null) {
        final streamUrl = response['streaming_url'];

        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.black);

        if (controller.platform is AndroidWebViewController) {
          (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
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
  // 2. BLUETOOTH FONKSİYONLARI (Senin Kodların)
  // ==========================================
  Future<void> _izinleriAlVeBaslat() async {
    await [
      Permission.bluetooth, Permission.bluetoothConnect,
      Permission.bluetoothScan, Permission.location,
    ].request();

    FlutterBluetoothSerial.instance.state.then((state) {
      if (mounted) setState(() => _bluetoothState = state);
    });

    try {
      List<BluetoothDevice> pairedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
      if (mounted) setState(() => _devicesList = pairedDevices);
    } catch (e) {
      debugPrint("Cihazlar alınamadı: $e");
    }
  }

  void _baglan() async {
    if (_selectedDevice == null) return;
    setState(() => isConnecting = true);

    try {
      BluetoothConnection connection = await BluetoothConnection.toAddress(_selectedDevice!.address);
      if (mounted) {
        setState(() { _connection = connection; isConnecting = false; });
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Manuel Sürüş (Bluetooth)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- 1. KAMERA ALANI ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              height: 220, 
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
              ),
              clipBehavior: Clip.hardEdge,
              child: _cameraController == null
                  ? Center(
                      child: _cameraError.isNotEmpty
                          ? Text(_cameraError, style: const TextStyle(color: Colors.redAccent))
                          : const CircularProgressIndicator(color: Colors.white),
                    )
                  : WebViewWidget(controller: _cameraController!),
            ),
          ),

          // --- 2. BLUETOOTH BAĞLANTI ÇUBUĞU ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<BluetoothDevice>(
                    isExpanded: true,
                    hint: const Text('HC-06 Cihazı Seç'),
                    value: _selectedDevice,
                    items: _devicesList.map((device) => DropdownMenuItem(
                      value: device, child: Text(device.name ?? "Bilinmeyen"),
                    )).toList(),
                    onChanged: (value) => setState(() => _selectedDevice = value),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isConnected ? null : _baglan,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  child: isConnecting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : Text(isConnected ? 'Bağlandı' : 'Bağlan'),
                ),
              ],
            ),
          ),
          
          // --- 3. KONTROLLER (JOYSTICK & SLIDER) ---
          Expanded(
            child: isConnected 
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _kontrolButonuDuzen(), // D-Pad Motor Kontrolü
                      const Divider(height: 40, thickness: 2),
                      _servoKontrolDuzen(),  // Slider Servo Kontrolü
                      const SizedBox(height: 20),
                    ],
                  ),
                )
              : const Center(
                  child: Text(
                    'Sürüşe başlamak için\nHC-06 modülüne bağlanın.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  // --- D-PAD WIDGET'LARI ---
  Widget _kontrolButonuDuzen() {
    return Column(
      children: [
        _yonButonu('İLERİ', Icons.arrow_upward, 'F'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _yonButonu('SOL', Icons.arrow_back, 'L'),
            const SizedBox(width: 60), 
            _yonButonu('SAĞ', Icons.arrow_forward, 'R'),
          ],
        ),
        _yonButonu('GERİ', Icons.arrow_downward, 'B'),
      ],
    );
  }

  Widget _yonButonu(String etiket, IconData ikon, String komut) {
    return GestureDetector(
      onTapDown: (_) => _komutGonder(komut),
      onTapUp: (_) => _komutGonder('S'),     
      onTapCancel: () => _komutGonder('S'),  
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 75, height: 75,
        decoration: BoxDecoration(
          color: Colors.blueAccent, 
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: Colors.white, size: 28),
            Text(etiket, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // --- SLIDER WIDGET'LARI ---
  Widget _servoKontrolDuzen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const Text('Kamera Yönü (Servolar)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 10),
          
          Text('Boyun (Sağ - Sol): ${_boyunAci.toInt()}°'),
          Slider(
            value: _boyunAci,
            min: 0, max: 180,
            activeColor: Colors.green,
            onChanged: (val) => setState(() => _boyunAci = val),
            onChangeEnd: (val) => _komutGonder('X${val.toInt()}\n'),
          ),

          const SizedBox(height: 10),

          Text('Kafa (Aşağı - Yukarı): ${_kafaAci.toInt()}°'),
          Slider(
            value: _kafaAci,
            min: 0, max: 180,
            activeColor: Colors.orange,
            onChanged: (val) => setState(() => _kafaAci = val),
            onChangeEnd: (val) => _komutGonder('Y${val.toInt()}\n'),
          ),
        ],
      ),
    );
  }
}