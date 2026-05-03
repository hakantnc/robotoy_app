import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final supabase = Supabase.instance.client;
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _isLoading = false;

  // Çocuğun Verileri
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedBirthDate;
  String _selectedGender = 'Erkek';
  File? _faceImage;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // TAKVİMİ AÇAN KISIM
  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 3),
      ), // Varsayılan 3 yaş
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  // KAMERAYI AÇAN KISIM
  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front, // Ön kamera açılsın
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _faceImage = File(image.path);
      });
    }
  }

  // SUPABASE'E KAYDEDEN KISIM (BÜTÜN SİHİR BURADA)
  Future<void> _saveChildData() async {
    if (_nameController.text.isEmpty ||
        _selectedBirthDate == null ||
        _faceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm bilgileri doldurun!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Giriş yapılmamış!');

      // 1. Ebeveynin user_id'sini bul
      final userData = await supabase
          .from('users')
          .select('user_id')
          .eq('email', user.email!)
          .single();
      final int userId = userData['user_id'];

      // 2. Fotoğrafı Storage'a yükle (İsmi benzersiz olsun diye saat ekliyoruz)
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_nameController.text.replaceAll(' ', '')}.jpg';
      final imageBytes = await _faceImage!.readAsBytes();

      await supabase.storage
          .from('child_faces')
          .uploadBinary(
            fileName,
            imageBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      // 3. Yüklenen fotoğrafın açık linkini al
      final String imageUrl = supabase.storage
          .from('child_faces')
          .getPublicUrl(fileName);

      // 4. Tarihi YYYY-MM-DD formatına çevir
      final formattedDate = _selectedBirthDate!.toIso8601String().split('T')[0];

      // 5. Her şeyi Children tablosuna gönder
      await supabase.from('children').insert({
        'user_id': userId,
        'name': _nameController.text.trim(),
        'birth_date': formattedDate,
        'gender': _selectedGender,
        'face_data': {'image_url': imageUrl}, // JSONB olarak linki kaydediyoruz
        'custom_settings': {},
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çocuk Başarıyla Eklendi! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // İşlem bitince ana ekrana dön
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // İLERİ BUTONU KONTROLLERİ
  void _nextPage() {
    if (_currentPage == 0 && _nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen adı girin.')));
      return;
    }
    if (_currentPage == 1 && _selectedBirthDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen tarihi seçin.')));
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Çocuk Ekle'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ÜSTTEKİ İLERLEME ÇUBUĞU
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / 3,
              minHeight: 8,
              color: Colors.blueAccent,
            ),
          ),

          // ORTADAKİ DEĞİŞEN SAYFALAR
          Expanded(
            child: PageView(
              controller: _pageController,
              physics:
                  const NeverScrollableScrollPhysics(), // El ile kaydırmayı kapatır
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                // 1. SAYFA: İSİM
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Çocuğunuzun Adı Nedir?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Adı',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                // 2. SAYFA: DETAYLAR
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Doğum Tarihi',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectBirthDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                _selectedBirthDate == null
                                    ? 'Tarih Seçin'
                                    : '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Cinsiyet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Erkek', label: Text('Erkek')),
                          ButtonSegment(value: 'Kız', label: Text('Kız')),
                        ],
                        selected: {_selectedGender},
                        onSelectionChanged: (Set<String> newSelection) =>
                            setState(
                              () => _selectedGender = newSelection.first,
                            ),
                      ),
                    ],
                  ),
                ),
                // 3. SAYFA: KAMERA
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Yüz Tanıma İçin Fotoğraf',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          height: 250,
                          width: 250,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                            image: _faceImage != null
                                ? DecorationImage(
                                    image: FileImage(_faceImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _faceImage == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 64,
                                  color: Colors.blueAccent,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ALTTAKİ BUTONLAR
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: _isLoading ? null : _prevPage,
                    child: const Text('Geri'),
                  ),
                if (_currentPage == 0)
                  const SizedBox(), // İlk sayfada geri butonu boş
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_currentPage == 2 ? _saveChildData : _nextPage),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentPage == 2
                        ? Colors.green
                        : Colors.blueAccent,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _currentPage == 2 ? 'Kaydet' : 'İleri',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
