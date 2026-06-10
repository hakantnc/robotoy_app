import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalkieTalkieButton extends StatefulWidget {
  const WalkieTalkieButton({super.key});

  @override
  State<WalkieTalkieButton> createState() => _WalkieTalkieButtonState();
}

class _WalkieTalkieButtonState extends State<WalkieTalkieButton>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;
  bool _isUploading = false;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mikrofon izni verilmedi!')),
        );
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/robot_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );

      if (!mounted) return;
      setState(() => _isRecording = true);
    } catch (e) {
      debugPrint('Kayıt başlatılamadı: $e');
    }
  }

  Future<void> _stopRecordingAndUpload() async {
    if (!_isRecording) return;

    try {
      setState(() {
        _isRecording = false;
        _isUploading = true;
      });

      final path = await _audioRecorder.stop();
      if (path == null) throw Exception('Ses dosyası bulunamadı!');

      final audioFile = File(path);
      final fileName = path.split('/').last;

      await supabase.storage.from('robot_audio').upload(
            fileName,
            audioFile,
            fileOptions: const FileOptions(contentType: 'audio/mp4'),
          );

      final publicUrl =
          supabase.storage.from('robot_audio').getPublicUrl(fileName);

      await supabase.from('voice_messages').insert({
        'audio_url': publicUrl,
        'is_played': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ses robota iletildi! 🚀'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecordingAndUpload(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isRecording ? 90 : 70,
        height: _isRecording ? 90 : 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isUploading
              ? Colors.grey
              : (_isRecording
                  ? const Color(0xFFFF8FA3)
                  : const Color(0xFFC8B6E2)),
          boxShadow: _isRecording
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF8FA3).withOpacity(0.55),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
        ),
        child: _isUploading
            ? const Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              )
            : Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                color: Colors.white,
                size: _isRecording ? 40 : 30,
              ),
      ),
    );
  }
}

