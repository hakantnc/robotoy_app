import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screen.dart';
import 'theme_controller.dart';
import 'locale_controller.dart';
import 'l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final supabase = Supabase.instance.client;

  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  List<dynamic> _childrenList = [];

  // Bildirim Ayarları Değişkenleri
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  // Görsel switch (sadece SharedPreferences'a yazıyor; backend ile bağlı değil)
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadAllSettingsData();
  }

  // === 1. VERİLERİ VE YEREL AYARLARI YÜKLE ===
  Future<void> _loadAllSettingsData() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Veritabanından Kullanıcı ve Çocuk verilerini çek
      final userResponse = await supabase
          .from('users')
          .select()
          .eq('email', user.email!)
          .single();
      final childrenResponse = await supabase
          .from('children')
          .select()
          .eq('user_id', userResponse['user_id'])
          .order('child_id', ascending: true);

      // Telefonun yerel hafızasından bildirim ayarlarını çek
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _userData = userResponse;
        _childrenList = childrenResponse;
        // Eğer daha önce kaydedilmemişse varsayılan olarak true (açık) gelir
        _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
        _soundEnabled = prefs.getBool('soundEnabled') ?? true;
        _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;

        _isLoading = false;
      });
    } catch (e) {
      _showError('Veriler yüklenemedi: $e');
      setState(() => _isLoading = false);
    }
  }

  // === AYARLARI TELEFONA KAYDETME FONKSİYONLARI ===
  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() {
      _notificationsEnabled = value;
      // Eğer ana bildirimler kapanırsa, sesi de görsel olarak kapat
      if (!value) _soundEnabled = false;
    });

    _showSuccess(value ? 'Bildirimler açıldı.' : 'Bildirimler kapatıldı.');
  }

  Future<void> _toggleSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', value);
    setState(() => _soundEnabled = value);
  }

  Future<void> _toggleVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrationEnabled', value);
    setState(() => _vibrationEnabled = value);
  }

  // === 2. PROFİL DÜZENLEME ===
  Future<void> _showEditProfileDialog() async {
    final fNameCtrl = TextEditingController(
      text: _userData?['first_name'] ?? '',
    );
    final lNameCtrl = TextEditingController(
      text: _userData?['last_name'] ?? '',
    );

    final t = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder: (dialogContext) => _RoboDialog(
        icon: Icons.person_rounded,
        title: t.settings_profile_edit,
        subtitle: t.settings_dialog_profile_subtitle,
        children: [
          _RoboInputField(
            controller: fNameCtrl,
            label: t.settings_dialog_first_name_label,
            icon: Icons.badge_rounded,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          _RoboInputField(
            controller: lNameCtrl,
            label: t.settings_dialog_last_name_label,
            icon: Icons.badge_outlined,
            textCapitalization: TextCapitalization.words,
          ),
        ],
        primaryLabel: t.common_save,
        primaryIcon: Icons.check_rounded,
        secondaryLabel: t.common_cancel,
        onPrimary: () async {
          try {
            await supabase
                .from('users')
                .update({
                  'first_name': fNameCtrl.text.trim(),
                  'last_name': lNameCtrl.text.trim(),
                })
                .eq('user_id', _userData!['user_id']);

            if (mounted) {
              Navigator.pop(dialogContext);
              _loadAllSettingsData();
              _showSuccess(t.settings_profile_updated);
            }
          } catch (e) {
            _showError('${t.common_error}: $e');
          }
        },
      ),
    );
  }

  // === 3. ŞİFRE DEĞİŞTİRME ===
  Future<void> _showChangePasswordDialog() async {
    final pwCtrl = TextEditingController();

    final t = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder: (dialogContext) => _RoboDialog(
        icon: Icons.lock_rounded,
        title: t.settings_password_change,
        subtitle: t.settings_dialog_password_subtitle,
        children: [
          _RoboInputField(
            controller: pwCtrl,
            label: t.settings_dialog_new_password,
            icon: Icons.password_rounded,
            obscureText: true,
          ),
        ],
        primaryLabel: t.settings_dialog_password_update,
        primaryIcon: Icons.shield_rounded,
        secondaryLabel: t.common_cancel,
        onPrimary: () async {
          if (pwCtrl.text.length < 6) {
            _showError(t.settings_password_too_short);
            return;
          }
          try {
            await supabase.auth.updateUser(
              UserAttributes(password: pwCtrl.text),
            );
            if (mounted) {
              Navigator.pop(dialogContext);
              _showSuccess(t.settings_password_updated);
            }
          } catch (e) {
            _showError('${t.common_error}: $e');
          }
        },
      ),
    );
  }

  // === YENİ: E-POSTA DEĞİŞTİRME ===
  Future<void> _showChangeEmailDialog() async {
    // Mevcut e-postayı kutucuğa varsayılan olarak yazdırıyoruz
    final emailCtrl = TextEditingController(text: _userData?['email'] ?? '');

    final t = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder: (dialogContext) => _RoboDialog(
        icon: Icons.mail_rounded,
        title: t.settings_email_change,
        subtitle: t.settings_dialog_email_subtitle,
        children: [
          _RoboInputField(
            controller: emailCtrl,
            label: t.settings_dialog_new_email,
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
        primaryLabel: t.settings_dialog_send_confirm,
        primaryIcon: Icons.send_rounded,
        secondaryLabel: t.common_cancel,
        onPrimary: () async {
          final newEmail = emailCtrl.text.trim();
          if (newEmail.isEmpty || !newEmail.contains('@')) {
            _showError(t.settings_email_invalid);
            return;
          }
          try {
            // 1. Supabase Auth (Sistem) e-postasını değiştir (Onay maili atar)
            await supabase.auth.updateUser(UserAttributes(email: newEmail));
            // 2. Kendi users tablomuzdaki e-postayı da güncelliyoruz
            await supabase
                .from('users')
                .update({'email': newEmail})
                .eq('user_id', _userData!['user_id']);

            if (mounted) {
              Navigator.pop(dialogContext);
              _loadAllSettingsData();
              _showSuccess(t.settings_email_updated);
            }
          } catch (e) {
            _showError('${t.common_error}: $e');
          }
        },
      ),
    );
  }

  // === 4. ÇOCUK BİLGİLERİNİ DÜZENLEME ===
  Future<void> _showEditChildDialog(Map<String, dynamic> child) async {
    final nameCtrl = TextEditingController(text: child['name']);
    String selectedGender = child['gender'] ?? 'Erkek';
    DateTime selectedDate = DateTime.parse(child['birth_date'].toString());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Çocuk Bilgilerini Düzenle',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Adı',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setModalState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.blue),
                        const SizedBox(width: 16),
                        Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Erkek', label: Text('Erkek')),
                    ButtonSegment(value: 'Kız', label: Text('Kız')),
                  ],
                  selected: {selectedGender},
                  onSelectionChanged: (val) =>
                      setModalState(() => selectedGender = val.first),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final formattedDate = selectedDate
                            .toIso8601String()
                            .split('T')[0];
                        await supabase
                            .from('children')
                            .update({
                              'name': nameCtrl.text.trim(),
                              'birth_date': formattedDate,
                              'gender': selectedGender,
                            })
                            .eq('child_id', child['child_id']);

                        if (mounted) {
                          Navigator.pop(context);
                          _loadAllSettingsData();
                          _showSuccess('Çocuk bilgileri güncellendi!');
                        }
                      } catch (e) {
                        _showError('Hata: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Kaydet', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // === 5. ÇOCUK SİLME ===
  Future<void> _deleteChild(int childId, String childName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çocuğu Sil'),
        content: Text(
          '$childName adlı çocuğu silmek istediğinize emin misiniz? Yüz verileri kalıcı olarak silinecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Evet, Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase.from('children').delete().eq('child_id', childId);
        _loadAllSettingsData();
        _showSuccess('$childName silindi.');
      } catch (e) {
        _showError('Hata: $e');
      }
    }
  }

  void _showSuccess(String msg) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  void _showError(String msg) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));

  // === 7. ÇIKIŞ YAP ===
  Future<void> _signOut() async {
    try {
      // 1. Supabase'den çıkış yap
      await supabase.auth.signOut();

      if (mounted) {
        // 2. Sayfa geçmişini tamamen temizle ve Giriş ekranına at
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const AuthScreen(),
          ), // DİKKAT: Kendi giriş sayfanın Class adını yaz (Örn: LoginScreen, SignInPage vb.)
          (Route<dynamic> route) =>
              false, // Geri dönülecek hiçbir sayfa bırakma
        );
      }
    } catch (e) {
      // Çıkış yaparken internet koparsa vs. kullanıcıya haber ver
      if (mounted) {
        _showError('Çıkış yapılırken bir hata oluştu: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //                         UI
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          t.settings_title,
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
              colors: [scheme.primary, scheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAllSettingsData,
              color: scheme.primary,
              backgroundColor: scheme.surface,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(context).padding.bottom + 72 + 16 + 16,
                ),
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 28),

                  _buildSectionHeader(t.settings_section_account),
                  _buildAccountCard(),
                  const SizedBox(height: 24),

                  _buildSectionHeader(t.settings_section_appearance),
                  _buildAppearanceCard(),
                  const SizedBox(height: 24),

                  _buildSectionHeader(t.settings_section_notifications),
                  _buildNotificationsCard(),
                  const SizedBox(height: 24),

                  _buildSectionHeader(t.settings_section_children),
                  _buildChildrenCard(),
                  const SizedBox(height: 24),

                  _buildSectionHeader(t.settings_section_robot),
                  _buildRobotCard(),
                  const SizedBox(height: 24),

                  _buildSectionHeader(t.settings_section_privacy),
                  _buildPrivacyCard(),
                  const SizedBox(height: 24),

                  _buildSectionHeader(t.settings_section_help),
                  _buildHelpCard(),
                  const SizedBox(height: 28),

                  _buildDangerZone(),
                ],
              ),
            ),
    );
  }

  // ─── Yardımcı widget'lar ──────────────────────────────────────

  Widget _buildSectionHeader(String text) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface.withValues(alpha: 0.55),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconBg,
    Color? iconColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg ?? scheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null && onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurface.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 1,
        color: scheme.onSurface.withValues(alpha: 0.06),
      ),
    );
  }

  Widget _buildComingSoonBadge() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.secondary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Yakında',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: scheme.secondary,
        ),
      ),
    );
  }

  // ─── A) PROFİL ÖZET KARTI ─────────────────────────────────────
  Widget _buildProfileCard() {
    final scheme = Theme.of(context).colorScheme;
    final firstName = _userData?['first_name'] ?? '';
    final lastName = _userData?['last_name'] ?? '';
    final email = _userData?['email'] ?? '';
    final initial = (firstName.isNotEmpty ? firstName[0] : 'R').toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.secondary],
                ),
              ),
            ),
            InkWell(
              onTap: _showEditProfileDialog,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [scheme.primary, scheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$firstName $lastName'.trim().isEmpty
                                ? 'Robotoy Kullanıcısı'
                                : '$firstName $lastName',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: scheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── B) HESAP ─────────────────────────────────────────────────
  Widget _buildAccountCard() {
    final t = AppLocalizations.of(context);
    return _buildSectionCard(
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.email_outlined,
            title: t.settings_email_change,
            subtitle: t.settings_dialog_email_subtitle,
            onTap: _showChangeEmailDialog,
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.lock_outline_rounded,
            title: t.settings_password_change,
            subtitle: t.settings_dialog_password_subtitle,
            onTap: _showChangePasswordDialog,
          ),
        ],
      ),
    );
  }

  // ─── C) GÖRÜNÜM (TEMA SEÇİCİ) ─────────────────────────────────
  Widget _buildAppearanceCard() {
    return _buildSectionCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                AppLocalizations.of(context).settings_theme,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            ListenableBuilder(
              listenable: ThemeController.instance,
              builder: (context, _) {
                final current = ThemeController.instance.mode;
                final t = AppLocalizations.of(context);
                return Row(
                  children: [
                    Expanded(
                      child: _buildThemeOption(
                        mode: AppThemeMode.pinkCream,
                        label: t.settings_theme_pink,
                        isActive: current == AppThemeMode.pinkCream,
                        topColors: const [
                          Color(0xFFFFC5D3),
                          Color(0xFFC8B6E2),
                        ],
                        bottomColor: const Color(0xFFFFF8F0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildThemeOption(
                        mode: AppThemeMode.blueCream,
                        label: t.settings_theme_blue,
                        isActive: current == AppThemeMode.blueCream,
                        topColors: const [
                          Color(0xFFA8C8FF),
                          Color(0xFFB6D4E2),
                        ],
                        bottomColor: const Color(0xFFF6F8FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildThemeOption(
                        mode: AppThemeMode.dark,
                        label: t.settings_theme_dark,
                        isActive: current == AppThemeMode.dark,
                        topColors: const [
                          Color(0xFF4A3B6B),
                          Color(0xFFC8B6E2),
                        ],
                        bottomColor: const Color(0xFF15131D),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            _buildDivider(),
            const SizedBox(height: 8),
            _buildSettingsTile(
              icon: Icons.language_rounded,
              title: AppLocalizations.of(context).settings_lang,
              subtitle: _currentLanguageLabel(context),
              onTap: _showLanguageSheet,
            ),
          ],
        ),
      ),
    );
  }

  // ─── DİL SEÇİMİ ────────────────────────────────────────────────
  String _currentLanguageLabel(BuildContext context) {
    final t = AppLocalizations.of(context);
    switch (LocaleController.instance.locale.languageCode) {
      case 'en':
        return t.settings_lang_en;
      case 'ar':
        return t.settings_lang_ar;
      case 'tr':
      default:
        return t.settings_lang_tr;
    }
  }

  Future<void> _showLanguageSheet() async {
    final scheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    final options = <_LangOption>[
      _LangOption(
        code: 'tr',
        label: t.settings_lang_tr,
        flag: '🇹🇷',
        nativeName: 'Türkçe',
      ),
      _LangOption(
        code: 'en',
        label: t.settings_lang_en,
        flag: '🇬🇧',
        nativeName: 'English',
      ),
      _LangOption(
        code: 'ar',
        label: t.settings_lang_ar,
        flag: '🇸🇦',
        nativeName: 'العربية',
      ),
    ];

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        final activeCode = LocaleController.instance.locale.languageCode;
        return Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Tutamaç ──
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.onSurface.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [scheme.primary, scheme.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.translate_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.settings_lang_select_title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.settings_lang_select_subtitle,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                                color:
                                    scheme.onSurface.withValues(alpha: 0.55),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ...options.map((o) {
                    final isActive = o.code == activeCode;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          Navigator.pop(sheetCtx);
                          await LocaleController.instance.setLocale(
                            Locale(o.code),
                          );
                          if (mounted) {
                            _showSuccess(
                              AppLocalizations.of(context).settings_lang_changed,
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isActive
                                ? scheme.primary.withValues(alpha: 0.10)
                                : scheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? scheme.primary
                                  : scheme.onSurface.withValues(alpha: 0.10),
                              width: isActive ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color:
                                      scheme.secondary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    o.flag,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      o.label,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      o.nativeName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isActive)
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required AppThemeMode mode,
    required String label,
    required bool isActive,
    required List<Color> topColors,
    required Color bottomColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () async {
        await ThemeController.instance.setMode(mode);
        if (mounted) {
          _showSuccess(AppLocalizations.of(context).settings_theme_changed);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: 0.08),
            width: isActive ? 2.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 64,
                    width: double.infinity,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: topColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(color: bottomColor),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isActive)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.45),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? scheme.onSurface
                      : scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── D) BİLDİRİMLER ───────────────────────────────────────────
  Widget _buildNotificationsCard() {
    final scheme = Theme.of(context).colorScheme;
    return _buildSectionCard(
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications_active_rounded,
            title: 'Anlık Bildirimler',
            subtitle: 'Ağlama ve güvenlik uyarılarını al',
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.volume_up_rounded,
            title: 'Bildirim Sesi',
            subtitle: 'Bildirimler gelirken ses çal',
            value: _soundEnabled,
            onChanged: _notificationsEnabled ? _toggleSound : null,
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.vibration_rounded,
            title: 'Titreşim',
            subtitle: 'Bildirimlerde titreşim',
            value: _vibrationEnabled,
            onChanged: _notificationsEnabled ? _toggleVibration : null,
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.bedtime_rounded,
            title: 'Sessiz Saatler',
            subtitle: '22:00 — 07:00',
            iconBg: scheme.secondary,
            trailing: _buildComingSoonBadge(),
            onTap: () => _showSuccess('Yakında!'),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final disabled = onChanged == null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: disabled
                  ? scheme.onSurface.withValues(alpha: 0.12)
                  : scheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: disabled
                        ? scheme.onSurface.withValues(alpha: 0.4)
                        : scheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: scheme.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: scheme.onSurface.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }

  // ─── E) ÇOCUKLAR ──────────────────────────────────────────────
  Widget _buildChildrenCard() {
    final scheme = Theme.of(context).colorScheme;
    return _buildSectionCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: _childrenList.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.child_care_rounded,
                        size: 36,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Henüz çocuk eklenmemiş',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Anasayfadan yeni bir profil ekleyebilirsin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  for (int i = 0; i < _childrenList.length; i++) ...[
                    _buildChildRow(_childrenList[i] as Map<String, dynamic>),
                    if (i < _childrenList.length - 1) _buildDivider(),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildChildRow(Map<String, dynamic> child) {
    final scheme = Theme.of(context).colorScheme;
    final isGirl = child['gender'] == 'Kız';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isGirl ? scheme.primary : scheme.secondary)
                  .withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isGirl ? Icons.girl_rounded : Icons.boy_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child['name'] ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Doğum: ${child['birth_date']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditChildDialog(child),
            icon: Icon(Icons.edit_rounded, color: scheme.primary, size: 20),
            tooltip: 'Düzenle',
          ),
          IconButton(
            onPressed: () => _deleteChild(child['child_id'], child['name']),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFE57373),
              size: 22,
            ),
            tooltip: 'Sil',
          ),
        ],
      ),
    );
  }

  // ─── F) ROBOT ─────────────────────────────────────────────────
  Widget _buildRobotCard() {
    final scheme = Theme.of(context).colorScheme;
    return _buildSectionCard(
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.smart_toy_rounded,
            title: 'Robotum',
            subtitle: 'Bağlı değil',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE57373).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Çevrim Dışı',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE57373),
                ),
              ),
            ),
            onTap: () => _showSuccess('Yakında!'),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.bluetooth_rounded,
            title: 'Bluetooth Eşle',
            subtitle: 'Robotu telefonunla eşle',
            iconBg: scheme.secondary,
            onTap: () => _showSuccess('Yakında!'),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.drive_file_rename_outline_rounded,
            title: 'Robot Adını Değiştir',
            iconBg: scheme.secondary,
            onTap: () => _showSuccess('Yakında!'),
          ),
        ],
      ),
    );
  }

  // ─── G) GİZLİLİK & VERİ ───────────────────────────────────────
  Widget _buildPrivacyCard() {
    final scheme = Theme.of(context).colorScheme;
    return _buildSectionCard(
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.face_retouching_natural_rounded,
            title: 'Yüz Verilerini Yönet',
            subtitle: 'Yüklenmiş yüz tanıma verilerini görüntüle',
            onTap: () => _showSuccess('Yakında!'),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.delete_sweep_rounded,
            title: 'Tüm Aktivite Verilerini Sil',
            subtitle: 'Geçmiş raporlar ve istatistikler',
            iconBg: const Color(0xFFE57373),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('Verileri Sil'),
                  content: const Text(
                    'Tüm aktivite verilerin (raporlar, istatistikler) kalıcı olarak silinecek. Bu işlem geri alınamaz.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'İptal',
                        style: TextStyle(color: scheme.onSurface),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Evet, Sil',
                        style: TextStyle(color: Color(0xFFE57373)),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                _showSuccess('Yakında!');
              }
            },
          ),
        ],
      ),
    );
  }

  // ─── H) YARDIM & HAKKINDA ─────────────────────────────────────
  Widget _buildHelpCard() {
    final scheme = Theme.of(context).colorScheme;
    return _buildSectionCard(
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'SSS',
            subtitle: 'Sıkça sorulan sorular',
            onTap: () => _showSuccess('Yakında!'),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.support_agent_rounded,
            title: 'Bize Ulaşın',
            iconBg: scheme.secondary,
            onTap: () => _showSuccess('Yakında!'),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Kullanım Koşulları',
            iconBg: scheme.secondary,
            onTap: () => _showSuccess('Yakında!'),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Gizlilik Politikası',
            iconBg: scheme.secondary,
            onTap: () => _showSuccess('Yakında!'),
          ),
          _buildDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.onSurface.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sürüm',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Robotoy 1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── I) TEHLİKELİ ALAN ────────────────────────────────────────
  Widget _buildDangerZone() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: Text(
              AppLocalizations.of(context).settings_signout,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.secondary.withValues(alpha: 0.18),
              foregroundColor: scheme.secondary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _showDeleteAccountDialog,
            icon: const Icon(Icons.delete_forever_rounded, size: 20),
            label: Text(
              AppLocalizations.of(context).settings_delete_account,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE57373),
              side: BorderSide(
                color: const Color(0xFFE57373).withValues(alpha: 0.5),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final scheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.settings_delete_account),
        content: Text(t.settings_delete_account_warning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              t.common_cancel,
              style: TextStyle(color: scheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showError(t.settings_feature_inactive);
            },
            child: Text(
              t.settings_delete_account,
              style: const TextStyle(color: Color(0xFFE57373)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Robotoy temalı dialog widget'ı ────────────────────────────────
//
// Tüm ayar dialog'ları (Profili Düzenle / Şifre Değiştir / E-posta Değiştir
// vb.) bu widget'tan geçer. Tema değiştiğinde renkler otomatik uyum sağlar.
class _RoboDialog extends StatelessWidget {
  const _RoboDialog({
    required this.icon,
    required this.title,
    required this.children,
    required this.primaryLabel,
    required this.onPrimary,
    this.subtitle,
    this.primaryIcon,
    this.secondaryLabel = 'İptal',
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final String primaryLabel;
  final IconData? primaryIcon;
  final Future<void> Function() onPrimary;
  final String secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final pink = context.appPink;
    final lavender = context.appLavender;
    final textDark = context.appTextDark;
    final muted = context.appMuted;
    final surface = context.appSurface;

    return Dialog(
      backgroundColor: surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [pink, lavender],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                              letterSpacing: 0.2,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                                color: muted,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    InkResponse(
                      onTap: () => Navigator.of(context).pop(),
                      radius: 22,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: lavender.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: muted,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...children,
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: lavender,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: lavender.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                        child: Text(
                          secondaryLabel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _RoboPrimaryButton(
                        label: primaryLabel,
                        icon: primaryIcon,
                        onPressed: onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoboPrimaryButton extends StatefulWidget {
  const _RoboPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final Future<void> Function() onPressed;

  @override
  State<_RoboPrimaryButton> createState() => _RoboPrimaryButtonState();
}

class _RoboPrimaryButtonState extends State<_RoboPrimaryButton> {
  bool _busy = false;

  Future<void> _handle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pink = context.appPink;
    final lavender = context.appLavender;

    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [pink, lavender],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: pink.withValues(alpha: 0.32),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _busy ? null : _handle,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: _busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _RoboInputField extends StatelessWidget {
  const _RoboInputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final pink = context.appPink;
    final lavender = context.appLavender;
    final textDark = context.appTextDark;
    final muted = context.appMuted;
    final fillColor = context.isDarkTheme
        ? lavender.withValues(alpha: 0.10)
        : Colors.white;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      cursorColor: pink,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: muted, fontSize: 14),
        floatingLabelStyle: TextStyle(color: pink, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: lavender, size: 20),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: lavender.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: lavender.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: pink, width: 1.5),
        ),
      ),
    );
  }
}

class _LangOption {
  const _LangOption({
    required this.code,
    required this.label,
    required this.flag,
    required this.nativeName,
  });

  final String code;
  final String label;
  final String flag;
  final String nativeName;
}
