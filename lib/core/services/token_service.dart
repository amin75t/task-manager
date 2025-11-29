import 'package:shared_preferences/shared_preferences.dart';

/// Token Service
///
/// Manages JWT token storage and retrieval using SharedPreferences
class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _phoneKey = 'phone';

  /// Save authentication token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear authentication token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_phoneKey);
  }

  /// Save user ID
  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  /// Get user ID
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  /// Save phone number
  Future<void> savePhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phone);
  }

  /// Get phone number
  Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  /// Save complete auth data
  Future<void> saveAuthData({
    required String token,
    required int userId,
    required String phone,
  }) async {
    await saveToken(token);
    await saveUserId(userId);
    await savePhone(phone);
  }

  /// Clear all auth data
  Future<void> clearAuthData() async {
    await clearToken();
  }
}
