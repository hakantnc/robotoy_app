// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'ROBOTOY';

  @override
  String get common_save => 'Kaydet';

  @override
  String get common_cancel => 'İptal';

  @override
  String get common_close => 'Kapat';

  @override
  String get common_back => 'Geri';

  @override
  String get common_next => 'İleri';

  @override
  String get common_continue => 'Devam';

  @override
  String get common_loading => 'Yükleniyor...';

  @override
  String get common_error => 'Hata';

  @override
  String get common_coming_soon => 'Yakında!';

  @override
  String get nav_home => 'Anasayfa';

  @override
  String get nav_reports => 'Raporlarım';

  @override
  String get nav_joystick => 'Joystick';

  @override
  String get nav_settings => 'Ayarlar';

  @override
  String get auth_welcome_back => 'Tekrar hoş geldin';

  @override
  String get auth_welcome_new => 'Yeni bir maceraya başlayalım';

  @override
  String get auth_login => 'Giriş Yap';

  @override
  String get auth_register => 'Kayıt Ol';

  @override
  String get auth_first_name_hint => 'Ad';

  @override
  String get auth_last_name_hint => 'Soyad';

  @override
  String get auth_email_hint => 'E-posta';

  @override
  String get auth_password_hint => 'Şifre';

  @override
  String get auth_or => 'veya';

  @override
  String get auth_google_continue => 'Google ile devam et';

  @override
  String get auth_no_account => 'Hesabın yok mu?  ';

  @override
  String get auth_have_account => 'Zaten hesabın var mı?  ';

  @override
  String get dashboard_title => 'ROBOTOY Kontrol Paneli';

  @override
  String get dashboard_title_short => 'ROBOTOY Panel';

  @override
  String dashboard_hello(String name) {
    return 'Merhaba, $name';
  }

  @override
  String dashboard_connected_robot(String id) {
    return 'Bağlı Robot: $id';
  }

  @override
  String get dashboard_add_child => 'Çocuk Ekle';

  @override
  String get dashboard_section_status => 'Durum Özeti';

  @override
  String get dashboard_section_camera => 'Canlı Kamera';

  @override
  String get dashboard_section_controls => 'Robot Kontrolleri';

  @override
  String get dashboard_section_recent => 'Son Olaylar';

  @override
  String get dashboard_status_detected_person => 'Algılanan Kişi';

  @override
  String get dashboard_status_emotion => 'Duygu Durumu';

  @override
  String get dashboard_status_daily_report => 'Günlük Rapor';

  @override
  String get dashboard_status_system => 'Sistem';

  @override
  String get dashboard_searching => 'Aranıyor...';

  @override
  String get dashboard_unknown => 'Bilinmiyor';

  @override
  String get dashboard_calculating => 'Hesaplanıyor...';

  @override
  String get dashboard_no_record => 'Kayıt Yok';

  @override
  String get dashboard_no_data => 'Veri Alınamadı';

  @override
  String dashboard_minutes_crying(Object minutes) {
    return '$minutes dk Ağladı';
  }

  @override
  String get dashboard_btn_song => 'Şarkı';

  @override
  String get dashboard_btn_lullaby => 'Ninni';

  @override
  String get dashboard_btn_dance => 'Dans';

  @override
  String get dashboard_btn_stop => 'Durdur';

  @override
  String get dashboard_cam_connecting => 'Kameraya bağlanılıyor...';

  @override
  String get dashboard_cam_connect_fail => 'Kameraya bağlanılamadı.';

  @override
  String get dashboard_cam_link_missing => 'Kamera linki bulunamadı.';

  @override
  String get dashboard_no_robot => 'Lütfen bir robot eşleştirin.';

  @override
  String get dashboard_pair_title => 'Robotunu Bağla';

  @override
  String get dashboard_pair_label => 'Lütfen Robot Kodunu girin.';

  @override
  String get dashboard_pair_hint => 'Robot Kodu (Örn: ROBO-PI5)';

  @override
  String get dashboard_pair_invalid => 'Hata: Robot kodu geçersiz.';

  @override
  String get dashboard_pair_action => 'Eşleştir';

  @override
  String get dashboard_event_crying_started => 'Ağlama Algılandı';

  @override
  String get dashboard_event_crying_stopped => 'Ağlama Durdu';

  @override
  String get dashboard_events_loading_failed => 'Olaylar şu an yüklenemedi';

  @override
  String get dashboard_no_events => 'Henüz olay kaydedilmedi';

  @override
  String get reports_title => 'Günlük Raporlarım';

  @override
  String get reports_no_robot => 'Robot eşleşmesi bulunamadı.';

  @override
  String get reports_load_error => 'Raporlar yüklenirken bir hata oluştu.';

  @override
  String get reports_empty_title => 'Henüz rapor yok';

  @override
  String get reports_empty_subtitle =>
      'Robotoy küçük dostunla zaman geçirdikçe\nburada günlük raporlar belirecek.';

  @override
  String get reports_pull_to_refresh => 'Yenilemek için aşağı çek';

  @override
  String reports_session_count(Object count) {
    return '$count Seans';
  }

  @override
  String get reports_total_minutes_label => 'Toplam ağlama süresi';

  @override
  String reports_minutes_value(Object m) {
    return '$m dk';
  }

  @override
  String get saving_title => 'Ayarlarınız kaydediliyor...';

  @override
  String get saving_subtitle =>
      'Robotoy küçük dostunu hazırlıyor,\nlütfen biraz bekle.';

  @override
  String get add_child_title => 'Çocuk Ekle';

  @override
  String get add_child_name_q => 'Çocuğunuzun adı nedir?';

  @override
  String get add_child_name_subtitle =>
      'Robotoy onu tanıyabilsin diye sadece bir isim yeterli.';

  @override
  String get add_child_name_hint => 'Örn: Defne';

  @override
  String get add_child_birthdate_label => 'Doğum tarihi';

  @override
  String get add_child_pick_date => 'Tarih Seçin';

  @override
  String get add_child_gender_label => 'Cinsiyet';

  @override
  String get add_child_gender_male => 'Erkek';

  @override
  String get add_child_gender_female => 'Kız';

  @override
  String get add_child_photo_title => 'Yüz tanıma için fotoğraf';

  @override
  String get add_child_photo_subtitle =>
      'Robotoy çocuğunu tanıyabilsin diye küçük bir kareye ihtiyacımız var.';

  @override
  String get add_child_photo_take => 'Fotoğraf Çek';

  @override
  String get add_child_photo_front_cam => 'Ön kamera açılır';

  @override
  String get add_child_photo_retake => 'Tekrar Çek';

  @override
  String get add_child_btn_back => 'Geri';

  @override
  String get add_child_btn_next => 'İleri';

  @override
  String get add_child_btn_save => 'Kaydet';

  @override
  String get add_child_error_fill_all => 'Lütfen tüm bilgileri doldurun!';

  @override
  String get add_child_error_name => 'Lütfen adı girin.';

  @override
  String get add_child_error_date => 'Lütfen tarihi seçin.';

  @override
  String get joystick_title => 'Manuel Sürüş';

  @override
  String get joystick_select_device => 'HC-06 Cihazı Seç';

  @override
  String get joystick_unknown_device => 'Bilinmeyen';

  @override
  String get joystick_connect => 'Bağlan';

  @override
  String get joystick_connected => 'Bağlandı';

  @override
  String get joystick_no_connection =>
      'Sürüşe başlamak için\nHC-06 modülüne bağlanın.';

  @override
  String get joystick_servo_title => 'Kamera Yönü (Servolar)';

  @override
  String joystick_neck_label(Object deg) {
    return 'Boyun (Sağ - Sol): $deg°';
  }

  @override
  String joystick_head_label(Object deg) {
    return 'Kafa (Aşağı - Yukarı): $deg°';
  }

  @override
  String get joystick_btn_forward => 'İLERİ';

  @override
  String get joystick_btn_back => 'GERİ';

  @override
  String get joystick_btn_left => 'SOL';

  @override
  String get joystick_btn_right => 'SAĞ';

  @override
  String get settings_title => 'Ayarlar';

  @override
  String get settings_section_account => 'Hesap';

  @override
  String get settings_section_appearance => 'Görünüm';

  @override
  String get settings_section_notifications => 'Bildirimler';

  @override
  String get settings_section_children => 'Çocuklarım';

  @override
  String get settings_section_robot => 'Robot';

  @override
  String get settings_section_privacy => 'Gizlilik & Veri';

  @override
  String get settings_section_help => 'Yardım & Hakkında';

  @override
  String get settings_section_danger => 'Tehlikeli Bölge';

  @override
  String get settings_profile_edit => 'Profili Düzenle';

  @override
  String get settings_email_change => 'E-posta Değiştir';

  @override
  String get settings_password_change => 'Şifre Değiştir';

  @override
  String get settings_theme => 'Tema';

  @override
  String get settings_theme_pink => 'Pembe';

  @override
  String get settings_theme_blue => 'Mavi';

  @override
  String get settings_theme_dark => 'Koyu';

  @override
  String get settings_theme_changed => 'Tema değiştirildi';

  @override
  String get settings_lang => 'Dil';

  @override
  String get settings_lang_tr => 'Türkçe';

  @override
  String get settings_lang_en => 'İngilizce';

  @override
  String get settings_lang_ar => 'Arapça';

  @override
  String get settings_lang_changed => 'Dil değiştirildi';

  @override
  String get settings_lang_select_title => 'Dili Seç';

  @override
  String get settings_lang_select_subtitle => 'Robotoy hangi dili konuşsun?';

  @override
  String get settings_notif_enabled => 'Bildirimleri Aç';

  @override
  String get settings_notif_sound => 'Ses';

  @override
  String get settings_notif_vibration => 'Titreşim';

  @override
  String get settings_signout => 'Çıkış Yap';

  @override
  String get settings_delete_account => 'Hesabı Sil';

  @override
  String get settings_delete_account_warning =>
      'Hesabını silmek istediğine emin misin? Bu işlem geri alınamaz; tüm verilerin kalıcı olarak silinir.';

  @override
  String get settings_feature_inactive => 'Bu özellik henüz aktif değil';

  @override
  String get settings_dialog_profile_subtitle =>
      'Adın ve soyadın Robotoy hesabını kişiselleştirir.';

  @override
  String get settings_dialog_password_subtitle =>
      'Yeni şifren en az 6 karakter olsun. Hesap güvenliğin için tahmin edilemez bir şey seç.';

  @override
  String get settings_dialog_email_subtitle =>
      'Güvenliğin için yeni adresine bir onay maili gönderilir. Linki onaylamayı unutma.';

  @override
  String get settings_dialog_first_name_label => 'Adınız';

  @override
  String get settings_dialog_last_name_label => 'Soyadınız';

  @override
  String get settings_dialog_new_email => 'Yeni E-posta';

  @override
  String get settings_dialog_new_password => 'Yeni Şifre';

  @override
  String get settings_dialog_send_confirm => 'Onay Gönder';

  @override
  String get settings_dialog_password_update => 'Şifreyi Güncelle';

  @override
  String get settings_profile_updated => 'Profil güncellendi!';

  @override
  String get settings_password_updated => 'Şifreniz başarıyla değiştirildi!';

  @override
  String get settings_email_updated =>
      'Onay maili yeni adrese gönderildi. Lütfen e-postanı kontrol et.';

  @override
  String get settings_password_too_short => 'Şifre en az 6 karakter olmalıdır.';

  @override
  String get settings_email_invalid =>
      'Lütfen geçerli bir e-posta adresi girin.';
}
