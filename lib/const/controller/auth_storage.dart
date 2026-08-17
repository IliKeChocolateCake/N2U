import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _tokenKey = 'auth_token';
  static const _rememberMeKey = 'remember_me';
  static const _userKey = 'user_data';
  static const _tokenExpiryKey = 'token_expiry';
  static const _refreshTokenKey = 'refresh_token';

  static const _secureStorage = FlutterSecureStorage();

  /// Save token and session data
  /// If rememberMe = true, persists long-term
  /// If rememberMe = false, still saves for current session
  static Future<void> saveSession({
    required String token,
    bool rememberMe = false,
    Map<String, dynamic>? user,
    DateTime? tokenExpiry,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Always save token for current session
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_rememberMeKey, rememberMe);

    if (user != null) {
      await prefs.setString(_userKey, jsonEncode(user));
    }

    // Save token expiry if provided (for future use)
    if (tokenExpiry != null) {
      await prefs.setString(_tokenExpiryKey, tokenExpiry.toIso8601String());
    }

    // Save refresh token if provided (for future use)
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  /// Get saved token (null if not logged in)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Check if user chose Remember Me
  static Future<bool> isRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  /// Get stored user info
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  /// Get token expiry time (for future use)
  static Future<DateTime?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString(_tokenExpiryKey);
    if (expiryStr == null) return null;

    try {
      return DateTime.parse(expiryStr);
    } catch (e) {
      return null;
    }
  }

  /// Check if token is expired (for future use)
  static Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return false;

    return DateTime.now().isAfter(expiry);
  }

  /// Get refresh token (for future use)
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Clear everything (full logout)
  /// Also clears secure storage credentials
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear SharedPreferences
    await prefs.remove(_tokenKey);
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_userKey);
    await prefs.remove(_tokenExpiryKey);
    await prefs.remove(_refreshTokenKey);

    // Clear SecureStorage credentials
    await _secureStorage.delete(key: 'remembered_uid');
    await _secureStorage.delete(key: 'remembered_password');
  }

  /// Clear only session data, keep Remember Me credentials
  /// Used when user wants to stay logged in next time
  static Future<void> clearSessionKeepCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    // Only clear session data
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_tokenExpiryKey);
    await prefs.remove(_refreshTokenKey);

    // Keep remember_me flag as true
    await prefs.setBool(_rememberMeKey, true);

    // SecureStorage credentials remain intact
  }

  /// Quick login check
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;

    // Optional: Check if token is expired (for future use)
    final expired = await isTokenExpired();
    return !expired;
  }

  /// Update just the token (useful for token refresh)
  static Future<void> updateToken(String newToken, {DateTime? newExpiry}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, newToken);

    if (newExpiry != null) {
      await prefs.setString(_tokenExpiryKey, newExpiry.toIso8601String());
    }
  }
}