// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ROBOTOY';

  @override
  String get common_save => 'حفظ';

  @override
  String get common_cancel => 'إلغاء';

  @override
  String get common_close => 'إغلاق';

  @override
  String get common_back => 'رجوع';

  @override
  String get common_next => 'التالي';

  @override
  String get common_continue => 'متابعة';

  @override
  String get common_loading => 'جارٍ التحميل...';

  @override
  String get common_error => 'خطأ';

  @override
  String get common_coming_soon => 'قريباً!';

  @override
  String get nav_home => 'الرئيسية';

  @override
  String get nav_reports => 'تقاريري';

  @override
  String get nav_joystick => 'وحدة التحكم';

  @override
  String get nav_settings => 'الإعدادات';

  @override
  String get auth_welcome_back => 'أهلاً بعودتك';

  @override
  String get auth_welcome_new => 'لنبدأ مغامرة جديدة';

  @override
  String get auth_login => 'تسجيل الدخول';

  @override
  String get auth_register => 'إنشاء حساب';

  @override
  String get auth_first_name_hint => 'الاسم';

  @override
  String get auth_last_name_hint => 'اسم العائلة';

  @override
  String get auth_email_hint => 'البريد الإلكتروني';

  @override
  String get auth_password_hint => 'كلمة المرور';

  @override
  String get auth_or => 'أو';

  @override
  String get auth_google_continue => 'المتابعة باستخدام Google';

  @override
  String get auth_no_account => 'ليس لديك حساب؟  ';

  @override
  String get auth_have_account => 'لديك حساب بالفعل؟  ';

  @override
  String get dashboard_title => 'لوحة تحكم ROBOTOY';

  @override
  String get dashboard_title_short => 'لوحة ROBOTOY';

  @override
  String dashboard_hello(String name) {
    return 'مرحباً، $name';
  }

  @override
  String dashboard_connected_robot(String id) {
    return 'الروبوت المتصل: $id';
  }

  @override
  String get dashboard_add_child => 'إضافة طفل';

  @override
  String get dashboard_section_status => 'نظرة عامة';

  @override
  String get dashboard_section_camera => 'كاميرا مباشرة';

  @override
  String get dashboard_section_controls => 'تحكّم الروبوت';

  @override
  String get dashboard_section_recent => 'آخر الأحداث';

  @override
  String get dashboard_status_detected_person => 'الشخص المكتشف';

  @override
  String get dashboard_status_emotion => 'الحالة العاطفية';

  @override
  String get dashboard_status_daily_report => 'التقرير اليومي';

  @override
  String get dashboard_status_system => 'النظام';

  @override
  String get dashboard_searching => 'جارٍ البحث...';

  @override
  String get dashboard_unknown => 'غير معروف';

  @override
  String get dashboard_calculating => 'جارٍ الحساب...';

  @override
  String get dashboard_no_record => 'لا يوجد سجل';

  @override
  String get dashboard_no_data => 'لا توجد بيانات';

  @override
  String dashboard_minutes_crying(Object minutes) {
    return 'بكى $minutes دقيقة';
  }

  @override
  String get dashboard_btn_song => 'أغنية';

  @override
  String get dashboard_btn_lullaby => 'تهويدة';

  @override
  String get dashboard_btn_dance => 'رقصة';

  @override
  String get dashboard_btn_stop => 'إيقاف';

  @override
  String get dashboard_cam_connecting => 'جارٍ الاتصال بالكاميرا...';

  @override
  String get dashboard_cam_connect_fail => 'تعذّر الاتصال بالكاميرا.';

  @override
  String get dashboard_cam_link_missing => 'لم يتم العثور على رابط الكاميرا.';

  @override
  String get dashboard_no_robot => 'يرجى إقران روبوت.';

  @override
  String get dashboard_pair_title => 'اقرن روبوتك';

  @override
  String get dashboard_pair_label => 'يرجى إدخال رمز الروبوت.';

  @override
  String get dashboard_pair_hint => 'رمز الروبوت (مثال: ROBO-PI5)';

  @override
  String get dashboard_pair_invalid => 'خطأ: رمز الروبوت غير صالح.';

  @override
  String get dashboard_pair_action => 'إقران';

  @override
  String get dashboard_event_crying_started => 'تم رصد بكاء';

  @override
  String get dashboard_event_crying_stopped => 'توقّف البكاء';

  @override
  String get dashboard_events_loading_failed => 'تعذّر تحميل الأحداث';

  @override
  String get dashboard_no_events => 'لم تُسجَّل أي أحداث بعد';

  @override
  String get reports_title => 'تقاريري اليومية';

  @override
  String get reports_no_robot => 'لم يتم العثور على إقران للروبوت.';

  @override
  String get reports_load_error => 'حدث خطأ أثناء تحميل التقارير.';

  @override
  String get reports_empty_title => 'لا توجد تقارير بعد';

  @override
  String get reports_empty_subtitle =>
      'كلما قضى صغيرك وقتاً مع Robotoy،\nستظهر التقارير اليومية هنا.';

  @override
  String get reports_pull_to_refresh => 'اسحب للأسفل للتحديث';

  @override
  String reports_session_count(Object count) {
    return '$count جلسة';
  }

  @override
  String get reports_total_minutes_label => 'إجمالي وقت البكاء';

  @override
  String reports_minutes_value(Object m) {
    return '$m دقيقة';
  }

  @override
  String get saving_title => 'جارٍ حفظ إعداداتك...';

  @override
  String get saving_subtitle =>
      'Robotoy يجهّز صديقك الصغير،\nيرجى الانتظار قليلاً.';

  @override
  String get add_child_title => 'إضافة طفل';

  @override
  String get add_child_name_q => 'ما اسم طفلك؟';

  @override
  String get add_child_name_subtitle =>
      'اسم أوّل يكفي حتى يتعرّف Robotoy عليه.';

  @override
  String get add_child_name_hint => 'مثال: دفنة';

  @override
  String get add_child_birthdate_label => 'تاريخ الميلاد';

  @override
  String get add_child_pick_date => 'اختر التاريخ';

  @override
  String get add_child_gender_label => 'الجنس';

  @override
  String get add_child_gender_male => 'ذكر';

  @override
  String get add_child_gender_female => 'أنثى';

  @override
  String get add_child_photo_title => 'صورة للتعرّف على الوجه';

  @override
  String get add_child_photo_subtitle =>
      'نحتاج صورة سريعة حتى يتعرّف Robotoy على طفلك.';

  @override
  String get add_child_photo_take => 'التقط صورة';

  @override
  String get add_child_photo_front_cam => 'ستفتح الكاميرا الأمامية';

  @override
  String get add_child_photo_retake => 'إعادة الالتقاط';

  @override
  String get add_child_btn_back => 'رجوع';

  @override
  String get add_child_btn_next => 'التالي';

  @override
  String get add_child_btn_save => 'حفظ';

  @override
  String get add_child_error_fill_all => 'يرجى ملء جميع المعلومات!';

  @override
  String get add_child_error_name => 'يرجى إدخال الاسم.';

  @override
  String get add_child_error_date => 'يرجى اختيار التاريخ.';

  @override
  String get joystick_title => 'القيادة اليدوية';

  @override
  String get joystick_select_device => 'اختر جهاز HC-06';

  @override
  String get joystick_unknown_device => 'غير معروف';

  @override
  String get joystick_connect => 'اتصال';

  @override
  String get joystick_connected => 'متصل';

  @override
  String get joystick_no_connection => 'لبدء القيادة، اتصل\nبوحدة HC-06.';

  @override
  String get joystick_servo_title => 'اتجاه الكاميرا (محرّكات السيرفو)';

  @override
  String joystick_neck_label(Object deg) {
    return 'الرقبة (يمين - يسار): $deg°';
  }

  @override
  String joystick_head_label(Object deg) {
    return 'الرأس (أسفل - أعلى): $deg°';
  }

  @override
  String get joystick_btn_forward => 'أمام';

  @override
  String get joystick_btn_back => 'خلف';

  @override
  String get joystick_btn_left => 'يسار';

  @override
  String get joystick_btn_right => 'يمين';

  @override
  String get settings_title => 'الإعدادات';

  @override
  String get settings_section_account => 'الحساب';

  @override
  String get settings_section_appearance => 'المظهر';

  @override
  String get settings_section_notifications => 'الإشعارات';

  @override
  String get settings_section_children => 'أطفالي';

  @override
  String get settings_section_robot => 'الروبوت';

  @override
  String get settings_section_privacy => 'الخصوصية والبيانات';

  @override
  String get settings_section_help => 'المساعدة وحول التطبيق';

  @override
  String get settings_section_danger => 'منطقة الخطر';

  @override
  String get settings_profile_edit => 'تعديل الملف الشخصي';

  @override
  String get settings_email_change => 'تغيير البريد الإلكتروني';

  @override
  String get settings_password_change => 'تغيير كلمة المرور';

  @override
  String get settings_theme => 'السمة';

  @override
  String get settings_theme_pink => 'وردي';

  @override
  String get settings_theme_blue => 'أزرق';

  @override
  String get settings_theme_dark => 'داكن';

  @override
  String get settings_theme_changed => 'تم تغيير السمة';

  @override
  String get settings_lang => 'اللغة';

  @override
  String get settings_lang_tr => 'التركية';

  @override
  String get settings_lang_en => 'الإنجليزية';

  @override
  String get settings_lang_ar => 'العربية';

  @override
  String get settings_lang_changed => 'تم تغيير اللغة';

  @override
  String get settings_lang_select_title => 'اختر اللغة';

  @override
  String get settings_lang_select_subtitle => 'بأي لغة تريد أن يتحدث Robotoy؟';

  @override
  String get settings_notif_enabled => 'تشغيل الإشعارات';

  @override
  String get settings_notif_sound => 'الصوت';

  @override
  String get settings_notif_vibration => 'الاهتزاز';

  @override
  String get settings_signout => 'تسجيل الخروج';

  @override
  String get settings_delete_account => 'حذف الحساب';

  @override
  String get settings_delete_account_warning =>
      'هل أنت متأكد من حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء؛ ستُحذف جميع بياناتك نهائياً.';

  @override
  String get settings_feature_inactive => 'هذه الميزة غير مُفعّلة بعد';

  @override
  String get settings_dialog_profile_subtitle =>
      'اسمك ولقبك يمنحان حسابك في Robotoy طابعاً شخصياً.';

  @override
  String get settings_dialog_password_subtitle =>
      'اختر كلمة مرور لا تقل عن 6 أحرف ويصعب تخمينها.';

  @override
  String get settings_dialog_email_subtitle =>
      'لأمانك، سيُرسل بريد تأكيد إلى عنوانك الجديد. لا تنسَ تأكيد الرابط.';

  @override
  String get settings_dialog_first_name_label => 'الاسم';

  @override
  String get settings_dialog_last_name_label => 'اسم العائلة';

  @override
  String get settings_dialog_new_email => 'بريد إلكتروني جديد';

  @override
  String get settings_dialog_new_password => 'كلمة مرور جديدة';

  @override
  String get settings_dialog_send_confirm => 'إرسال التأكيد';

  @override
  String get settings_dialog_password_update => 'تحديث كلمة المرور';

  @override
  String get settings_profile_updated => 'تم تحديث الملف الشخصي!';

  @override
  String get settings_password_updated => 'تم تغيير كلمة المرور بنجاح!';

  @override
  String get settings_email_updated =>
      'تم إرسال بريد التأكيد إلى العنوان الجديد. يرجى التحقق من بريدك.';

  @override
  String get settings_password_too_short =>
      'يجب أن تكون كلمة المرور 6 أحرف على الأقل.';

  @override
  String get settings_email_invalid => 'يرجى إدخال بريد إلكتروني صالح.';
}
