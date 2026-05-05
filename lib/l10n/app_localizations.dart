import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'ROBOTOY'**
  String get appName;

  /// No description provided for @common_save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get common_cancel;

  /// No description provided for @common_close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get common_close;

  /// No description provided for @common_back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get common_back;

  /// No description provided for @common_next.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get common_next;

  /// No description provided for @common_continue.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get common_continue;

  /// No description provided for @common_loading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get common_error;

  /// No description provided for @common_coming_soon.
  ///
  /// In tr, this message translates to:
  /// **'Yakında!'**
  String get common_coming_soon;

  /// No description provided for @nav_home.
  ///
  /// In tr, this message translates to:
  /// **'Anasayfa'**
  String get nav_home;

  /// No description provided for @nav_reports.
  ///
  /// In tr, this message translates to:
  /// **'Raporlarım'**
  String get nav_reports;

  /// No description provided for @nav_joystick.
  ///
  /// In tr, this message translates to:
  /// **'Joystick'**
  String get nav_joystick;

  /// No description provided for @nav_settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get nav_settings;

  /// No description provided for @auth_welcome_back.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar hoş geldin'**
  String get auth_welcome_back;

  /// No description provided for @auth_welcome_new.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bir maceraya başlayalım'**
  String get auth_welcome_new;

  /// No description provided for @auth_login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get auth_login;

  /// No description provided for @auth_register.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get auth_register;

  /// No description provided for @auth_first_name_hint.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get auth_first_name_hint;

  /// No description provided for @auth_last_name_hint.
  ///
  /// In tr, this message translates to:
  /// **'Soyad'**
  String get auth_last_name_hint;

  /// No description provided for @auth_email_hint.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get auth_email_hint;

  /// No description provided for @auth_password_hint.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get auth_password_hint;

  /// No description provided for @auth_or.
  ///
  /// In tr, this message translates to:
  /// **'veya'**
  String get auth_or;

  /// No description provided for @auth_google_continue.
  ///
  /// In tr, this message translates to:
  /// **'Google ile devam et'**
  String get auth_google_continue;

  /// No description provided for @auth_no_account.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?  '**
  String get auth_no_account;

  /// No description provided for @auth_have_account.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı?  '**
  String get auth_have_account;

  /// No description provided for @dashboard_title.
  ///
  /// In tr, this message translates to:
  /// **'ROBOTOY Kontrol Paneli'**
  String get dashboard_title;

  /// No description provided for @dashboard_title_short.
  ///
  /// In tr, this message translates to:
  /// **'ROBOTOY Panel'**
  String get dashboard_title_short;

  /// No description provided for @dashboard_hello.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba, {name}'**
  String dashboard_hello(String name);

  /// No description provided for @dashboard_connected_robot.
  ///
  /// In tr, this message translates to:
  /// **'Bağlı Robot: {id}'**
  String dashboard_connected_robot(String id);

  /// No description provided for @dashboard_add_child.
  ///
  /// In tr, this message translates to:
  /// **'Çocuk Ekle'**
  String get dashboard_add_child;

  /// No description provided for @dashboard_section_status.
  ///
  /// In tr, this message translates to:
  /// **'Durum Özeti'**
  String get dashboard_section_status;

  /// No description provided for @dashboard_section_camera.
  ///
  /// In tr, this message translates to:
  /// **'Canlı Kamera'**
  String get dashboard_section_camera;

  /// No description provided for @dashboard_section_controls.
  ///
  /// In tr, this message translates to:
  /// **'Robot Kontrolleri'**
  String get dashboard_section_controls;

  /// No description provided for @dashboard_section_recent.
  ///
  /// In tr, this message translates to:
  /// **'Son Olaylar'**
  String get dashboard_section_recent;

  /// No description provided for @dashboard_status_detected_person.
  ///
  /// In tr, this message translates to:
  /// **'Algılanan Kişi'**
  String get dashboard_status_detected_person;

  /// No description provided for @dashboard_status_emotion.
  ///
  /// In tr, this message translates to:
  /// **'Duygu Durumu'**
  String get dashboard_status_emotion;

  /// No description provided for @dashboard_status_daily_report.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Rapor'**
  String get dashboard_status_daily_report;

  /// No description provided for @dashboard_status_system.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get dashboard_status_system;

  /// No description provided for @dashboard_searching.
  ///
  /// In tr, this message translates to:
  /// **'Aranıyor...'**
  String get dashboard_searching;

  /// No description provided for @dashboard_unknown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmiyor'**
  String get dashboard_unknown;

  /// No description provided for @dashboard_calculating.
  ///
  /// In tr, this message translates to:
  /// **'Hesaplanıyor...'**
  String get dashboard_calculating;

  /// No description provided for @dashboard_no_record.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Yok'**
  String get dashboard_no_record;

  /// No description provided for @dashboard_no_data.
  ///
  /// In tr, this message translates to:
  /// **'Veri Alınamadı'**
  String get dashboard_no_data;

  /// No description provided for @dashboard_minutes_crying.
  ///
  /// In tr, this message translates to:
  /// **'{minutes} dk Ağladı'**
  String dashboard_minutes_crying(Object minutes);

  /// No description provided for @dashboard_btn_song.
  ///
  /// In tr, this message translates to:
  /// **'Şarkı'**
  String get dashboard_btn_song;

  /// No description provided for @dashboard_btn_lullaby.
  ///
  /// In tr, this message translates to:
  /// **'Ninni'**
  String get dashboard_btn_lullaby;

  /// No description provided for @dashboard_btn_dance.
  ///
  /// In tr, this message translates to:
  /// **'Dans'**
  String get dashboard_btn_dance;

  /// No description provided for @dashboard_btn_stop.
  ///
  /// In tr, this message translates to:
  /// **'Durdur'**
  String get dashboard_btn_stop;

  /// No description provided for @dashboard_cam_connecting.
  ///
  /// In tr, this message translates to:
  /// **'Kameraya bağlanılıyor...'**
  String get dashboard_cam_connecting;

  /// No description provided for @dashboard_cam_connect_fail.
  ///
  /// In tr, this message translates to:
  /// **'Kameraya bağlanılamadı.'**
  String get dashboard_cam_connect_fail;

  /// No description provided for @dashboard_cam_link_missing.
  ///
  /// In tr, this message translates to:
  /// **'Kamera linki bulunamadı.'**
  String get dashboard_cam_link_missing;

  /// No description provided for @dashboard_no_robot.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir robot eşleştirin.'**
  String get dashboard_no_robot;

  /// No description provided for @dashboard_pair_title.
  ///
  /// In tr, this message translates to:
  /// **'Robotunu Bağla'**
  String get dashboard_pair_title;

  /// No description provided for @dashboard_pair_label.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen Robot Kodunu girin.'**
  String get dashboard_pair_label;

  /// No description provided for @dashboard_pair_hint.
  ///
  /// In tr, this message translates to:
  /// **'Robot Kodu (Örn: ROBO-PI5)'**
  String get dashboard_pair_hint;

  /// No description provided for @dashboard_pair_invalid.
  ///
  /// In tr, this message translates to:
  /// **'Hata: Robot kodu geçersiz.'**
  String get dashboard_pair_invalid;

  /// No description provided for @dashboard_pair_action.
  ///
  /// In tr, this message translates to:
  /// **'Eşleştir'**
  String get dashboard_pair_action;

  /// No description provided for @dashboard_event_crying_started.
  ///
  /// In tr, this message translates to:
  /// **'Ağlama Algılandı'**
  String get dashboard_event_crying_started;

  /// No description provided for @dashboard_event_crying_stopped.
  ///
  /// In tr, this message translates to:
  /// **'Ağlama Durdu'**
  String get dashboard_event_crying_stopped;

  /// No description provided for @dashboard_events_loading_failed.
  ///
  /// In tr, this message translates to:
  /// **'Olaylar şu an yüklenemedi'**
  String get dashboard_events_loading_failed;

  /// No description provided for @dashboard_no_events.
  ///
  /// In tr, this message translates to:
  /// **'Henüz olay kaydedilmedi'**
  String get dashboard_no_events;

  /// No description provided for @reports_title.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Raporlarım'**
  String get reports_title;

  /// No description provided for @reports_no_robot.
  ///
  /// In tr, this message translates to:
  /// **'Robot eşleşmesi bulunamadı.'**
  String get reports_no_robot;

  /// No description provided for @reports_load_error.
  ///
  /// In tr, this message translates to:
  /// **'Raporlar yüklenirken bir hata oluştu.'**
  String get reports_load_error;

  /// No description provided for @reports_empty_title.
  ///
  /// In tr, this message translates to:
  /// **'Henüz rapor yok'**
  String get reports_empty_title;

  /// No description provided for @reports_empty_subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Robotoy küçük dostunla zaman geçirdikçe\nburada günlük raporlar belirecek.'**
  String get reports_empty_subtitle;

  /// No description provided for @reports_pull_to_refresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenilemek için aşağı çek'**
  String get reports_pull_to_refresh;

  /// No description provided for @reports_session_count.
  ///
  /// In tr, this message translates to:
  /// **'{count} Seans'**
  String reports_session_count(Object count);

  /// No description provided for @reports_total_minutes_label.
  ///
  /// In tr, this message translates to:
  /// **'Toplam ağlama süresi'**
  String get reports_total_minutes_label;

  /// No description provided for @reports_minutes_value.
  ///
  /// In tr, this message translates to:
  /// **'{m} dk'**
  String reports_minutes_value(Object m);

  /// No description provided for @saving_title.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlarınız kaydediliyor...'**
  String get saving_title;

  /// No description provided for @saving_subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Robotoy küçük dostunu hazırlıyor,\nlütfen biraz bekle.'**
  String get saving_subtitle;

  /// No description provided for @add_child_title.
  ///
  /// In tr, this message translates to:
  /// **'Çocuk Ekle'**
  String get add_child_title;

  /// No description provided for @add_child_name_q.
  ///
  /// In tr, this message translates to:
  /// **'Çocuğunuzun adı nedir?'**
  String get add_child_name_q;

  /// No description provided for @add_child_name_subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Robotoy onu tanıyabilsin diye sadece bir isim yeterli.'**
  String get add_child_name_subtitle;

  /// No description provided for @add_child_name_hint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Defne'**
  String get add_child_name_hint;

  /// No description provided for @add_child_birthdate_label.
  ///
  /// In tr, this message translates to:
  /// **'Doğum tarihi'**
  String get add_child_birthdate_label;

  /// No description provided for @add_child_pick_date.
  ///
  /// In tr, this message translates to:
  /// **'Tarih Seçin'**
  String get add_child_pick_date;

  /// No description provided for @add_child_gender_label.
  ///
  /// In tr, this message translates to:
  /// **'Cinsiyet'**
  String get add_child_gender_label;

  /// No description provided for @add_child_gender_male.
  ///
  /// In tr, this message translates to:
  /// **'Erkek'**
  String get add_child_gender_male;

  /// No description provided for @add_child_gender_female.
  ///
  /// In tr, this message translates to:
  /// **'Kız'**
  String get add_child_gender_female;

  /// No description provided for @add_child_photo_title.
  ///
  /// In tr, this message translates to:
  /// **'Yüz tanıma için fotoğraf'**
  String get add_child_photo_title;

  /// No description provided for @add_child_photo_subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Robotoy çocuğunu tanıyabilsin diye küçük bir kareye ihtiyacımız var.'**
  String get add_child_photo_subtitle;

  /// No description provided for @add_child_photo_take.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Çek'**
  String get add_child_photo_take;

  /// No description provided for @add_child_photo_front_cam.
  ///
  /// In tr, this message translates to:
  /// **'Ön kamera açılır'**
  String get add_child_photo_front_cam;

  /// No description provided for @add_child_photo_retake.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Çek'**
  String get add_child_photo_retake;

  /// No description provided for @add_child_btn_back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get add_child_btn_back;

  /// No description provided for @add_child_btn_next.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get add_child_btn_next;

  /// No description provided for @add_child_btn_save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get add_child_btn_save;

  /// No description provided for @add_child_error_fill_all.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tüm bilgileri doldurun!'**
  String get add_child_error_fill_all;

  /// No description provided for @add_child_error_name.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen adı girin.'**
  String get add_child_error_name;

  /// No description provided for @add_child_error_date.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tarihi seçin.'**
  String get add_child_error_date;

  /// No description provided for @joystick_title.
  ///
  /// In tr, this message translates to:
  /// **'Manuel Sürüş'**
  String get joystick_title;

  /// No description provided for @joystick_select_device.
  ///
  /// In tr, this message translates to:
  /// **'HC-06 Cihazı Seç'**
  String get joystick_select_device;

  /// No description provided for @joystick_unknown_device.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen'**
  String get joystick_unknown_device;

  /// No description provided for @joystick_connect.
  ///
  /// In tr, this message translates to:
  /// **'Bağlan'**
  String get joystick_connect;

  /// No description provided for @joystick_connected.
  ///
  /// In tr, this message translates to:
  /// **'Bağlandı'**
  String get joystick_connected;

  /// No description provided for @joystick_no_connection.
  ///
  /// In tr, this message translates to:
  /// **'Sürüşe başlamak için\nHC-06 modülüne bağlanın.'**
  String get joystick_no_connection;

  /// No description provided for @joystick_servo_title.
  ///
  /// In tr, this message translates to:
  /// **'Kamera Yönü (Servolar)'**
  String get joystick_servo_title;

  /// No description provided for @joystick_neck_label.
  ///
  /// In tr, this message translates to:
  /// **'Boyun (Sağ - Sol): {deg}°'**
  String joystick_neck_label(Object deg);

  /// No description provided for @joystick_head_label.
  ///
  /// In tr, this message translates to:
  /// **'Kafa (Aşağı - Yukarı): {deg}°'**
  String joystick_head_label(Object deg);

  /// No description provided for @joystick_btn_forward.
  ///
  /// In tr, this message translates to:
  /// **'İLERİ'**
  String get joystick_btn_forward;

  /// No description provided for @joystick_btn_back.
  ///
  /// In tr, this message translates to:
  /// **'GERİ'**
  String get joystick_btn_back;

  /// No description provided for @joystick_btn_left.
  ///
  /// In tr, this message translates to:
  /// **'SOL'**
  String get joystick_btn_left;

  /// No description provided for @joystick_btn_right.
  ///
  /// In tr, this message translates to:
  /// **'SAĞ'**
  String get joystick_btn_right;

  /// No description provided for @settings_title.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings_title;

  /// No description provided for @settings_section_account.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get settings_section_account;

  /// No description provided for @settings_section_appearance.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get settings_section_appearance;

  /// No description provided for @settings_section_notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get settings_section_notifications;

  /// No description provided for @settings_section_children.
  ///
  /// In tr, this message translates to:
  /// **'Çocuklarım'**
  String get settings_section_children;

  /// No description provided for @settings_section_robot.
  ///
  /// In tr, this message translates to:
  /// **'Robot'**
  String get settings_section_robot;

  /// No description provided for @settings_section_privacy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik & Veri'**
  String get settings_section_privacy;

  /// No description provided for @settings_section_help.
  ///
  /// In tr, this message translates to:
  /// **'Yardım & Hakkında'**
  String get settings_section_help;

  /// No description provided for @settings_section_danger.
  ///
  /// In tr, this message translates to:
  /// **'Tehlikeli Bölge'**
  String get settings_section_danger;

  /// No description provided for @settings_profile_edit.
  ///
  /// In tr, this message translates to:
  /// **'Profili Düzenle'**
  String get settings_profile_edit;

  /// No description provided for @settings_email_change.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Değiştir'**
  String get settings_email_change;

  /// No description provided for @settings_password_change.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Değiştir'**
  String get settings_password_change;

  /// No description provided for @settings_theme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get settings_theme;

  /// No description provided for @settings_theme_pink.
  ///
  /// In tr, this message translates to:
  /// **'Pembe'**
  String get settings_theme_pink;

  /// No description provided for @settings_theme_blue.
  ///
  /// In tr, this message translates to:
  /// **'Mavi'**
  String get settings_theme_blue;

  /// No description provided for @settings_theme_dark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get settings_theme_dark;

  /// No description provided for @settings_theme_changed.
  ///
  /// In tr, this message translates to:
  /// **'Tema değiştirildi'**
  String get settings_theme_changed;

  /// No description provided for @settings_lang.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settings_lang;

  /// No description provided for @settings_lang_tr.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get settings_lang_tr;

  /// No description provided for @settings_lang_en.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get settings_lang_en;

  /// No description provided for @settings_lang_ar.
  ///
  /// In tr, this message translates to:
  /// **'Arapça'**
  String get settings_lang_ar;

  /// No description provided for @settings_lang_changed.
  ///
  /// In tr, this message translates to:
  /// **'Dil değiştirildi'**
  String get settings_lang_changed;

  /// No description provided for @settings_lang_select_title.
  ///
  /// In tr, this message translates to:
  /// **'Dili Seç'**
  String get settings_lang_select_title;

  /// No description provided for @settings_lang_select_subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Robotoy hangi dili konuşsun?'**
  String get settings_lang_select_subtitle;

  /// No description provided for @settings_notif_enabled.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimleri Aç'**
  String get settings_notif_enabled;

  /// No description provided for @settings_notif_sound.
  ///
  /// In tr, this message translates to:
  /// **'Ses'**
  String get settings_notif_sound;

  /// No description provided for @settings_notif_vibration.
  ///
  /// In tr, this message translates to:
  /// **'Titreşim'**
  String get settings_notif_vibration;

  /// No description provided for @settings_signout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get settings_signout;

  /// No description provided for @settings_delete_account.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get settings_delete_account;

  /// No description provided for @settings_delete_account_warning.
  ///
  /// In tr, this message translates to:
  /// **'Hesabını silmek istediğine emin misin? Bu işlem geri alınamaz; tüm verilerin kalıcı olarak silinir.'**
  String get settings_delete_account_warning;

  /// No description provided for @settings_feature_inactive.
  ///
  /// In tr, this message translates to:
  /// **'Bu özellik henüz aktif değil'**
  String get settings_feature_inactive;

  /// No description provided for @settings_dialog_profile_subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Adın ve soyadın Robotoy hesabını kişiselleştirir.'**
  String get settings_dialog_profile_subtitle;

  /// No description provided for @settings_dialog_password_subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifren en az 6 karakter olsun. Hesap güvenliğin için tahmin edilemez bir şey seç.'**
  String get settings_dialog_password_subtitle;

  /// No description provided for @settings_dialog_email_subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Güvenliğin için yeni adresine bir onay maili gönderilir. Linki onaylamayı unutma.'**
  String get settings_dialog_email_subtitle;

  /// No description provided for @settings_dialog_first_name_label.
  ///
  /// In tr, this message translates to:
  /// **'Adınız'**
  String get settings_dialog_first_name_label;

  /// No description provided for @settings_dialog_last_name_label.
  ///
  /// In tr, this message translates to:
  /// **'Soyadınız'**
  String get settings_dialog_last_name_label;

  /// No description provided for @settings_dialog_new_email.
  ///
  /// In tr, this message translates to:
  /// **'Yeni E-posta'**
  String get settings_dialog_new_email;

  /// No description provided for @settings_dialog_new_password.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre'**
  String get settings_dialog_new_password;

  /// No description provided for @settings_dialog_send_confirm.
  ///
  /// In tr, this message translates to:
  /// **'Onay Gönder'**
  String get settings_dialog_send_confirm;

  /// No description provided for @settings_dialog_password_update.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi Güncelle'**
  String get settings_dialog_password_update;

  /// No description provided for @settings_profile_updated.
  ///
  /// In tr, this message translates to:
  /// **'Profil güncellendi!'**
  String get settings_profile_updated;

  /// No description provided for @settings_password_updated.
  ///
  /// In tr, this message translates to:
  /// **'Şifreniz başarıyla değiştirildi!'**
  String get settings_password_updated;

  /// No description provided for @settings_email_updated.
  ///
  /// In tr, this message translates to:
  /// **'Onay maili yeni adrese gönderildi. Lütfen e-postanı kontrol et.'**
  String get settings_email_updated;

  /// No description provided for @settings_password_too_short.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalıdır.'**
  String get settings_password_too_short;

  /// No description provided for @settings_email_invalid.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir e-posta adresi girin.'**
  String get settings_email_invalid;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
