// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ROBOTOY';

  @override
  String get common_save => 'Save';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_close => 'Close';

  @override
  String get common_back => 'Back';

  @override
  String get common_next => 'Next';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'Error';

  @override
  String get common_coming_soon => 'Coming soon!';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_reports => 'Reports';

  @override
  String get nav_joystick => 'Joystick';

  @override
  String get nav_settings => 'Settings';

  @override
  String get auth_welcome_back => 'Welcome back';

  @override
  String get auth_welcome_new => 'Let\'s start a new adventure';

  @override
  String get auth_login => 'Sign In';

  @override
  String get auth_register => 'Sign Up';

  @override
  String get auth_first_name_hint => 'First name';

  @override
  String get auth_last_name_hint => 'Last name';

  @override
  String get auth_email_hint => 'Email';

  @override
  String get auth_password_hint => 'Password';

  @override
  String get auth_or => 'or';

  @override
  String get auth_google_continue => 'Continue with Google';

  @override
  String get auth_no_account => 'No account yet?  ';

  @override
  String get auth_have_account => 'Already have an account?  ';

  @override
  String get dashboard_title => 'ROBOTOY Control Panel';

  @override
  String get dashboard_title_short => 'ROBOTOY Panel';

  @override
  String dashboard_hello(String name) {
    return 'Hi, $name';
  }

  @override
  String dashboard_connected_robot(String id) {
    return 'Connected robot: $id';
  }

  @override
  String get dashboard_add_child => 'Add Child';

  @override
  String get dashboard_section_status => 'Status Overview';

  @override
  String get dashboard_section_camera => 'Live Camera';

  @override
  String get dashboard_section_controls => 'Robot Controls';

  @override
  String get dashboard_section_recent => 'Recent Events';

  @override
  String get dashboard_status_detected_person => 'Detected Person';

  @override
  String get dashboard_status_emotion => 'Emotion';

  @override
  String get dashboard_status_daily_report => 'Daily Report';

  @override
  String get dashboard_status_system => 'System';

  @override
  String get dashboard_searching => 'Searching...';

  @override
  String get dashboard_unknown => 'Unknown';

  @override
  String get dashboard_calculating => 'Calculating...';

  @override
  String get dashboard_no_record => 'No record';

  @override
  String get dashboard_no_data => 'No data';

  @override
  String dashboard_minutes_crying(Object minutes) {
    return '$minutes min cried';
  }

  @override
  String get dashboard_btn_song => 'Song';

  @override
  String get dashboard_btn_lullaby => 'Lullaby';

  @override
  String get dashboard_btn_dance => 'Dance';

  @override
  String get dashboard_btn_stop => 'Stop';

  @override
  String get dashboard_cam_connecting => 'Connecting to camera...';

  @override
  String get dashboard_cam_connect_fail => 'Could not connect to camera.';

  @override
  String get dashboard_cam_link_missing => 'Camera link not found.';

  @override
  String get dashboard_no_robot => 'Please pair a robot.';

  @override
  String get dashboard_pair_title => 'Pair your robot';

  @override
  String get dashboard_pair_label => 'Please enter the Robot Code.';

  @override
  String get dashboard_pair_hint => 'Robot Code (e.g. ROBO-PI5)';

  @override
  String get dashboard_pair_invalid => 'Error: Invalid robot code.';

  @override
  String get dashboard_pair_action => 'Pair';

  @override
  String get dashboard_event_crying_started => 'Crying detected';

  @override
  String get dashboard_event_crying_stopped => 'Crying stopped';

  @override
  String get dashboard_events_loading_failed => 'Could not load events';

  @override
  String get dashboard_no_events => 'No events recorded yet';

  @override
  String get reports_title => 'My Daily Reports';

  @override
  String get reports_no_robot => 'Robot pairing not found.';

  @override
  String get reports_load_error => 'An error occurred while loading reports.';

  @override
  String get reports_empty_title => 'No reports yet';

  @override
  String get reports_empty_subtitle =>
      'As your little one spends time with Robotoy,\ndaily reports will appear here.';

  @override
  String get reports_pull_to_refresh => 'Pull down to refresh';

  @override
  String reports_session_count(Object count) {
    return '$count sessions';
  }

  @override
  String get reports_total_minutes_label => 'Total crying time';

  @override
  String reports_minutes_value(Object m) {
    return '$m min';
  }

  @override
  String get saving_title => 'Saving your settings...';

  @override
  String get saving_subtitle =>
      'Robotoy is getting your little buddy ready,\nplease hold on a moment.';

  @override
  String get add_child_title => 'Add Child';

  @override
  String get add_child_name_q => 'What is your child\'s name?';

  @override
  String get add_child_name_subtitle =>
      'A first name is enough so Robotoy can recognize them.';

  @override
  String get add_child_name_hint => 'e.g. Defne';

  @override
  String get add_child_birthdate_label => 'Date of birth';

  @override
  String get add_child_pick_date => 'Pick a date';

  @override
  String get add_child_gender_label => 'Gender';

  @override
  String get add_child_gender_male => 'Boy';

  @override
  String get add_child_gender_female => 'Girl';

  @override
  String get add_child_photo_title => 'Photo for face recognition';

  @override
  String get add_child_photo_subtitle =>
      'We need a quick selfie so Robotoy can recognize your child.';

  @override
  String get add_child_photo_take => 'Take Photo';

  @override
  String get add_child_photo_front_cam => 'Front camera will open';

  @override
  String get add_child_photo_retake => 'Retake';

  @override
  String get add_child_btn_back => 'Back';

  @override
  String get add_child_btn_next => 'Next';

  @override
  String get add_child_btn_save => 'Save';

  @override
  String get add_child_error_fill_all => 'Please fill in all the information!';

  @override
  String get add_child_error_name => 'Please enter a name.';

  @override
  String get add_child_error_date => 'Please pick a date.';

  @override
  String get joystick_title => 'Manual Drive';

  @override
  String get joystick_select_device => 'Select HC-06 device';

  @override
  String get joystick_unknown_device => 'Unknown';

  @override
  String get joystick_connect => 'Connect';

  @override
  String get joystick_connected => 'Connected';

  @override
  String get joystick_no_connection =>
      'To start driving, connect\nto the HC-06 module.';

  @override
  String get joystick_servo_title => 'Camera direction (Servos)';

  @override
  String joystick_neck_label(Object deg) {
    return 'Neck (Right - Left): $deg°';
  }

  @override
  String joystick_head_label(Object deg) {
    return 'Head (Down - Up): $deg°';
  }

  @override
  String get joystick_btn_forward => 'FWD';

  @override
  String get joystick_btn_back => 'BACK';

  @override
  String get joystick_btn_left => 'LEFT';

  @override
  String get joystick_btn_right => 'RIGHT';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_section_account => 'Account';

  @override
  String get settings_section_appearance => 'Appearance';

  @override
  String get settings_section_notifications => 'Notifications';

  @override
  String get settings_section_children => 'My Children';

  @override
  String get settings_section_robot => 'Robot';

  @override
  String get settings_section_privacy => 'Privacy & Data';

  @override
  String get settings_section_help => 'Help & About';

  @override
  String get settings_section_danger => 'Danger Zone';

  @override
  String get settings_profile_edit => 'Edit Profile';

  @override
  String get settings_email_change => 'Change Email';

  @override
  String get settings_password_change => 'Change Password';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_theme_pink => 'Pink';

  @override
  String get settings_theme_blue => 'Blue';

  @override
  String get settings_theme_dark => 'Dark';

  @override
  String get settings_theme_changed => 'Theme changed';

  @override
  String get settings_lang => 'Language';

  @override
  String get settings_lang_tr => 'Turkish';

  @override
  String get settings_lang_en => 'English';

  @override
  String get settings_lang_ar => 'Arabic';

  @override
  String get settings_lang_changed => 'Language changed';

  @override
  String get settings_lang_select_title => 'Select Language';

  @override
  String get settings_lang_select_subtitle =>
      'Which language should Robotoy speak?';

  @override
  String get settings_notif_enabled => 'Enable notifications';

  @override
  String get settings_notif_sound => 'Sound';

  @override
  String get settings_notif_vibration => 'Vibration';

  @override
  String get settings_signout => 'Sign Out';

  @override
  String get settings_delete_account => 'Delete Account';

  @override
  String get settings_delete_account_warning =>
      'Are you sure you want to delete your account? This action cannot be undone; all your data will be permanently deleted.';

  @override
  String get settings_feature_inactive => 'This feature is not active yet';

  @override
  String get settings_dialog_profile_subtitle =>
      'Your first and last name personalize your Robotoy account.';

  @override
  String get settings_dialog_password_subtitle =>
      'Pick a password of at least 6 characters that\'s hard to guess.';

  @override
  String get settings_dialog_email_subtitle =>
      'For your security, a confirmation mail will be sent to your new address. Don\'t forget to confirm the link.';

  @override
  String get settings_dialog_first_name_label => 'First name';

  @override
  String get settings_dialog_last_name_label => 'Last name';

  @override
  String get settings_dialog_new_email => 'New email';

  @override
  String get settings_dialog_new_password => 'New password';

  @override
  String get settings_dialog_send_confirm => 'Send Confirmation';

  @override
  String get settings_dialog_password_update => 'Update Password';

  @override
  String get settings_profile_updated => 'Profile updated!';

  @override
  String get settings_password_updated => 'Password changed successfully!';

  @override
  String get settings_email_updated =>
      'Confirmation mail sent to the new address. Please check your inbox.';

  @override
  String get settings_password_too_short =>
      'Password must be at least 6 characters.';

  @override
  String get settings_email_invalid => 'Please enter a valid email address.';
}
