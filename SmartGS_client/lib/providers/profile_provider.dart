import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.getProfile(token);
      _userProfile = UserProfile.fromJson(data);
    } catch (e, stackTrace) {
      _error = e.toString();
      log(
        'Error loading profile: $e',
        name: 'ProfileProvider',
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(
    String token, {
    String? email,
    String? phone,
  }) async {
    try {
      await ApiService.updateProfile(token, email: email, phone: phone);
      await loadProfile(token);
    } catch (e, stackTrace) {
      log(
        'Error updating profile: $e',
        name: 'ProfileProvider',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> changePassword(
    String token, {
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await ApiService.changePassword(
        token,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e, stackTrace) {
      log(
        'Error changing password: $e',
        name: 'ProfileProvider',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void clearProfile() {
    _userProfile = null;
    notifyListeners();
  }
}
