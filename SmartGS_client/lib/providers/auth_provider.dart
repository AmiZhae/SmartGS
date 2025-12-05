import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _username;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get username => _username;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _username = prefs.getString('username');
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    try {
      final response = await ApiService.login(username, password);

      final token = response['token'];
      if (token == null) {
        throw Exception('Token is missing in response.');
      }

      _token = token;
      _username = username;
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('username', username);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signup(
    String username,
    String email,
    String password,
    String phone,
  ) async {
    try {
      await ApiService.signup(username, email, password, phone);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    _username = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');

    notifyListeners();
  }
}
