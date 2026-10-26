import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  String get role => _user?.roleName ?? '';

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      await ApiClient.saveToken(response.data['token']);
      _user = UserModel.fromJson(response.data['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Неверный email или пароль';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await ApiClient.clearToken();
    _user = null;
    notifyListeners();
  }
}
