import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screen.dart';

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

  // === 2. PROFİL DÜZENLEME ===
  Future<void> _showEditProfileDialog() async {
    final fNameCtrl = TextEditingController(
      text: _userData?['first_name'] ?? '',
    );
    final lNameCtrl = TextEditingController(
      text: _userData?['last_name'] ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profili Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: fNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Adınız',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Soyadınız',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await supabase
                    .from('users')
                    .update({
                      'first_name': fNameCtrl.text.trim(),
                      'last_name': lNameCtrl.text.trim(),
                    })
                    .eq('user_id', _userData!['user_id']);

                if (mounted) {
                  Navigator.pop(context);
                  _loadAllSettingsData();
                  _showSuccess('Profil güncellendi!');
                }
              } catch (e) {
                _showError('Hata: $e');
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  // === 3. ŞİFRE DEĞİŞTİRME ===
  Future<void> _showChangePasswordDialog() async {
    final pwCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: TextField(
          controller: pwCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Yeni Şifre (En az 6 karakter)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (pwCtrl.text.length < 6) {
                _showError('Şifre en az 6 karakter olmalıdır.');
                return;
              }
              try {
                await supabase.auth.updateUser(
                  UserAttributes(password: pwCtrl.text),
                );
                if (mounted) {
                  Navigator.pop(context);
                  _showSuccess('Şifreniz başarıyla değiştirildi!');
                }
              } catch (e) {
                _showError('Şifre güncellenemedi: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text(
              'Şifreyi Güncelle',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // === YENİ: E-POSTA DEĞİŞTİRME ===
  Future<void> _showChangeEmailDialog() async {
    // Mevcut e-postayı kutucuğa varsayılan olarak yazdırıyoruz
    final emailCtrl = TextEditingController(text: _userData?['email'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('E-posta Değiştir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Not: Güvenliğiniz için yeni adresinize bir onay maili gönderilecektir. Linke tıklamayı unutmayın.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Yeni E-posta Adresi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newEmail = emailCtrl.text.trim();
              if (newEmail.isEmpty || !newEmail.contains('@')) {
                _showError('Lütfen geçerli bir e-posta adresi girin.');
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
                  Navigator.pop(context);
                  _loadAllSettingsData(); // Ekrandaki yazıyı güncelle

                  // Kullanıcıyı mailini kontrol etmesi için uyar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'E-posta güncellendi! Lütfen gelen kutunuza gidip onay linkine tıklayın.',
                      ),
                      backgroundColor: Colors.blueAccent,
                      duration: Duration(seconds: 5),
                    ),
                  );
                }
              } catch (e) {
                _showError('E-posta güncellenemedi: $e');
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
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
                    if (picked != null)
                      setModalState(() => selectedDate = picked);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Ayarlar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAllSettingsData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildProfileSection(),
                  const SizedBox(height: 16),
                  _buildNotificationSettings(),
                  const SizedBox(height: 16),
                  _buildChildrenSection(),
                  const SizedBox(height: 32),
                  _buildDangerZone(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection() {
    final firstName = _userData?['first_name'] ?? '';
    final lastName = _userData?['last_name'] ?? '';
    final email = _userData?['email'] ?? '';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              '$firstName $lastName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(email),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: _showEditProfileDialog,
            ),
          ),
          const Divider(height: 0),

          // === EKLENEN E-POSTA BUTONU ===
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('E-posta Değiştir'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangeEmailDialog,
          ),
          const Divider(height: 0),

          // ===============================
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Şifreyi Değiştir'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangePasswordDialog,
          ),
        ],
      ),
    );
  }

  // === YENİLENEN BİLDİRİM KARTI ===
  Widget _buildNotificationSettings() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Bildirim Tercihleri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
          SwitchListTile(
            title: const Text(
              'Anlık Bildirimler',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Ağlama ve güvenlik alarmlarını al'),
            value: _notificationsEnabled,
            activeColor: Colors.blueAccent,
            secondary: const Icon(Icons.notifications_active),
            onChanged: _toggleNotifications,
          ),
          const Divider(height: 0, indent: 16, endIndent: 16),
          SwitchListTile(
            title: const Text('Bildirim Sesi'),
            subtitle: const Text('Bildirimler gelirken ses çal'),
            value: _soundEnabled,
            activeColor: Colors.blueAccent,
            // Eğer ana bildirimler kapalıysa ses düğmesini de deaktif (gri) yapıyoruz
            onChanged: _notificationsEnabled ? _toggleSound : null,
            secondary: const Icon(Icons.volume_up),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kayıtlı Çocuklar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const Divider(),
            if (_childrenList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Henüz çocuk eklenmemiş.'),
                ),
              )
            else
              ..._childrenList
                  .map(
                    (child) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: child['gender'] == 'Kız'
                            ? Colors.pink.shade50
                            : Colors.blue.shade50,
                        child: Icon(
                          child['gender'] == 'Kız' ? Icons.girl : Icons.boy,
                          color: child['gender'] == 'Kız'
                              ? Colors.pink
                              : Colors.blue,
                        ),
                      ),
                      title: Text(
                        child['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Doğum: ${child['birth_date']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditChildDialog(child),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteChild(child['child_id'], child['name']),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return ElevatedButton.icon(
      onPressed: _signOut,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.logout),
      label: const Text(
        'Çıkış Yap',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
