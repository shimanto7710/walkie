import 'package:shared_preferences/shared_preferences.dart';
import '../constants/session_constants.dart';

class SessionHelper {

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(SessionConstants.isLoggedInKey) ?? false;
    return isLoggedIn;
  }

  static Future<void> saveLoginSession({
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SessionConstants.isLoggedInKey, true);
    await prefs.setString(SessionConstants.userIdKey, userId);
    await prefs.setString(SessionConstants.userNameKey, userName);
    await prefs.setString(SessionConstants.userEmailKey, userEmail);
  }

  static Future<void> clearLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SessionConstants.isLoggedInKey);
    await prefs.remove(SessionConstants.userIdKey);
    await prefs.remove(SessionConstants.userNameKey);
    await prefs.remove(SessionConstants.userEmailKey);
  }

  static Future<Map<String, String?>> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(SessionConstants.userIdKey),
      'userName': prefs.getString(SessionConstants.userNameKey),
      'userEmail': prefs.getString(SessionConstants.userEmailKey),
    };
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SessionConstants.userIdKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SessionConstants.userNameKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SessionConstants.userEmailKey);
  }
}
