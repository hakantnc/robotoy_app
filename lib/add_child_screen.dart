import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'saving_screen.dart';
import 'theme_controller.dart';
import 'l10n/app_localizations.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  // ─── Backend / logic ─────────────────────────────────────────
  final supabase = Supabase.instance.client;
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _isLoading = false;

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

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedBirthDate = picked);
  }

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );
    if (image != null) setState(() => _faceImage = File(image.path));
  }

  Future<void> _saveChildData() async {
    if (_nameController.text.isEmpty ||
        _selectedBirthDate == null ||
        _faceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).add_child_error_fill_all,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Giriş yapılmamış!');

      final userData = await supabase
          .from('users')
          .select('user_id')
          .eq('email', user.email!)
          .single();
      final int userId = userData['user_id'];

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_nameController.text.replaceAll(' ', '')}.jpg';
      final imageBytes = await _faceImage!.readAsBytes();

      await supabase.storage.from('child_faces').uploadBinary(
            fileName,
            imageBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final String imageUrl =
          supabase.storage.from('child_faces').getPublicUrl(fileName);

      final formattedDate =
          _selectedBirthDate!.toIso8601String().split('T')[0];

      await supabase.from('children').insert({
        'user_id': userId,
        'name': _nameController.text.trim(),
        'birth_date': formattedDate,
        'gender': _selectedGender,
        'face_data': {'image_url': imageUrl},
        'custom_settings': {},
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SavingScreen()),
        );
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

  void _nextPage() {
    if (_currentPage == 0 && _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).add_child_error_name),
        ),
      );
      return;
    }
    if (_currentPage == 1 && _selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).add_child_error_date),
        ),
      );
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

  // ─── BUILD ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pink = context.appPink;
    final lavender = context.appLavender;
    final idle = context.appHairline;
    final textDark = context.appTextDark;

    return Scaffold(
      backgroundColor: context.appCream,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textDark,
        title: Text(
          AppLocalizations.of(context).add_child_title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Nokta göstergesi ──
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final isActive = i == _currentPage;
                  final isDone = i < _currentPage;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: isActive ? 16 : 10,
                    height: isActive ? 16 : 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? pink
                          : isDone
                              ? lavender
                              : idle,
                    ),
                  );
                }),
              ),
            ),

            // ── Sayfalar ──
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _namePage(),
                  _detailsPage(),
                  _photoPage(),
                ],
              ),
            ),

            // ── Alt butonlar ──
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  // ─── Sayfa 1: İsim ───────────────────────────────────────────
  Widget _namePage() {
    final pink = context.appPink;
    final lavender = context.appLavender;
    final textDark = context.appTextDark;
    final muted = context.appMuted;
    final surface = context.appSurface;
    final t = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: pink,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.child_care_rounded,
              size: 52,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            t.add_child_name_q,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            t.add_child_name_subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: muted,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: lavender, width: 1),
            ),
            child: TextField(
              controller: _nameController,
              textInputAction: TextInputAction.done,
              style: TextStyle(fontSize: 16, color: textDark),
              decoration: InputDecoration(
                hintText: t.add_child_name_hint,
                hintStyle: TextStyle(color: muted),
                prefixIcon: Icon(
                  Icons.face_retouching_natural_rounded,
                  color: pink,
                ),
                filled: true,
                fillColor: surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Sayfa 2: Detaylar ───────────────────────────────────────
  Widget _detailsPage() {
    final pink = context.appPink;
    final lavender = context.appLavender;
    final textDark = context.appTextDark;
    final muted = context.appMuted;
    final surface = context.appSurface;
    final t = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            t.add_child_birthdate_label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _selectBirthDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedBirthDate != null ? pink : lavender,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: pink,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _selectedBirthDate == null
                          ? t.add_child_pick_date
                          : '${_selectedBirthDate!.day.toString().padLeft(2, '0')}/'
                              '${_selectedBirthDate!.month.toString().padLeft(2, '0')}/'
                              '${_selectedBirthDate!.year}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: _selectedBirthDate == null
                            ? FontWeight.w400
                            : FontWeight.w600,
                        color: _selectedBirthDate == null ? muted : textDark,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            t.add_child_gender_label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _genderCard(
                  // Backend'e Türkçe değer ('Erkek' / 'Kız') gider, UI etiketi
                  // dile göre değişir.
                  storedValue: 'Erkek',
                  label: t.add_child_gender_male,
                  icon: Icons.male_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _genderCard(
                  storedValue: 'Kız',
                  label: t.add_child_gender_female,
                  icon: Icons.female_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _genderCard({
    required String storedValue,
    required String label,
    required IconData icon,
  }) {
    final pink = context.appPink;
    final lavender = context.appLavender;
    final textDark = context.appTextDark;
    final muted = context.appMuted;
    final surface = context.appSurface;
    final selected = _selectedGender == storedValue;

    return GestureDetector(
      onTap: () => setState(() => _selectedGender = storedValue),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: selected ? pink.withValues(alpha: 0.18) : surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? pink : lavender,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected ? pink : lavender,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? textDark : muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sayfa 3: Fotoğraf ───────────────────────────────────────
  Widget _photoPage() {
    final pink = context.appPink;
    final lavender = context.appLavender;
    final textDark = context.appTextDark;
    final muted = context.appMuted;
    final t = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            t.add_child_photo_title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.add_child_photo_subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: muted,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: _takePicture,
            child: Container(
              width: 260,
              height: 260,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [pink, lavender],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _faceImage == null ? _emptyCamera() : _filledCamera(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _emptyCamera() {
    final pink = context.appPink;
    final textDark = context.appTextDark;
    final muted = context.appMuted;
    final surface = context.appSurface;
    final t = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: pink,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            t.add_child_photo_take,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.add_child_photo_front_cam,
            style: TextStyle(fontSize: 12, color: muted),
          ),
        ],
      ),
    );
  }

  Widget _filledCamera() {
    return ClipOval(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(_faceImage!, fit: BoxFit.cover),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _takePicture,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.black54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context).add_child_photo_retake,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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

  // ─── Alt buton çubuğu ─────────────────────────────────────────
  Widget _bottomBar() {
    final pink = context.appPink;
    final lavender = context.appLavender;
    final t = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          if (_currentPage > 0) ...[
            TextButton(
              onPressed: _isLoading ? null : _prevPage,
              style: TextButton.styleFrom(
                foregroundColor: lavender,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    t.add_child_btn_back,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: SizedBox(
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [pink, lavender],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_currentPage == 2 ? _saveChildData : _nextPage),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_currentPage == 2)
                              const Icon(Icons.check_rounded, size: 20),
                            if (_currentPage == 2)
                              const SizedBox(width: 8),
                            Text(
                              _currentPage == 2
                                  ? t.add_child_btn_save
                                  : t.add_child_btn_next,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_currentPage != 2)
                              const SizedBox(width: 8),
                            if (_currentPage != 2)
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
