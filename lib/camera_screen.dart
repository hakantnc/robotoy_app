import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CameraScreen extends StatefulWidget {
  final String robotId;

  const CameraScreen({super.key, required this.robotId});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Modern webview_flutter kullanımı (Arka planı siyah yapıyoruz ki sinematik dursun)
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black);
      
    _loadCameraStream();
  }

  Future<void> _loadCameraStream() async {
    try {
      // Supabase'den dinamik olarak bu robotun güncel kamera linkini çekiyoruz
      final response = await Supabase.instance.client
          .from('robots')
          .select('streaming_url')
          .eq('robot_id', widget.robotId)
          .single();

      final streamUrl = response['streaming_url'];

      if (streamUrl != null && streamUrl.toString().isNotEmpty) {
        // Link bulunduysa WebView'a yükle
        await _controller.loadRequest(Uri.parse(streamUrl));
        if (mounted) {
          setState(() => _isLoading = false);
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Kamera yayını bulunamadı.\nRobotun açık olduğundan emin olun.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Bağlantı hatası oluştu.\nLütfen internetinizi kontrol edin.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Tam ekran hissiyatı için siyah
      appBar: AppBar(
        title: const Text('Canlı Kamera', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : WebViewWidget(controller: _controller), // Görüntünün aktığı yer
    );
  }
}