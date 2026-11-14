import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Méthodes pour l'utilisateur connecté
  static Future<void> setUserConnected(bool isConnected) async {
    await _prefs?.setBool('user_connected', isConnected);
  }

  static bool? isUserConnected() {
    return _prefs?.getBool('user_connected');
  }

  static Future<void> setUserId(int userId) async {
    await _prefs?.setInt('user_id', userId);
  }

  static int? getUserId() {
    return _prefs?.getInt('user_id');
  }

  static Future<void> setUserPhone(String phone) async {
    await _prefs?.setString('user_phone', phone);
  }

  static String? getUserPhone() {
    return _prefs?.getString('user_phone');
  }

  static Future<void> setUserCodeTp(String codeTp) async {
    await _prefs?.setString('user_code_tp', codeTp);
  }

  static String? getUserCodeTp() {
    return _prefs?.getString('user_code_tp');
  }

  static Future<void> setUserFullName(String fullName) async {
    await _prefs?.setString('user_full_name', fullName);
  }

  static String? getUserFullName() {
    return _prefs?.getString('user_full_name');
  }

  // Méthodes pour les données de l'application
  static Future<void> setLastSyncTime(DateTime dateTime) async {
    await _prefs?.setString('last_sync_time', dateTime.toIso8601String());
  }

  static DateTime? getLastSyncTime() {
    String? timeString = _prefs?.getString('last_sync_time');
    return timeString != null ? DateTime.parse(timeString) : null;
  }

  // Méthode pour effacer toutes les données utilisateur
  static Future<void> clearUserData() async {
    await _prefs?.remove('user_connected');
    await _prefs?.remove('user_id');
    await _prefs?.remove('user_phone');
    await _prefs?.remove('user_code_tp');
    await _prefs?.remove('user_full_name');
  }
}