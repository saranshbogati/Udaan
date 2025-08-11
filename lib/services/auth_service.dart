import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthService() {
    _checkLoginStatus();
  }

  // Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final userId = prefs.getInt('user_id');
      final userName = prefs.getString('user_name');
      final userEmail = prefs.getString('user_email');

      if (token != null &&
          userId != null &&
          userName != null &&
          userEmail != null) {
        _currentUser = User(id: userId, name: userName, email: userEmail);
        _isLoggedIn = true;
      }
    } catch (e) {
      print('Error checking login status: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login method
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      // For now, simulate login
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful login
      if (email.isNotEmpty && password.length >= 6) {
        final user = User(id: 1, name: 'John Doe', email: email);

        await _saveUserData(user, 'mock_jwt_token');
        _currentUser = user;
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Register method
  Future<bool> register(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      // For now, simulate registration
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful registration
      if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
        final user = User(id: 1, name: name, email: email, phone: phone);

        await _saveUserData(user, 'mock_jwt_token');
        _currentUser = user;
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Registration error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Logout method
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _currentUser = null;
      _isLoggedIn = false;
    } catch (e) {
      print('Logout error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save user data to local storage
  Future<void> _saveUserData(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setInt('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    if (user.phone != null) {
      await prefs.setString('user_phone', user.phone!);
    }
  }

  // Get JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
}
