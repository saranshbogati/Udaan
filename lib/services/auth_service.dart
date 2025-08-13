import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

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

      if (token != null) {
        // Verify token with backend
        final user = await _verifyToken(token);
        if (user != null) {
          _currentUser = user;
          _isLoggedIn = true;
          _apiService.setAuthToken(token);
        } else {
          // Token is invalid, clear stored data
          await _clearUserData();
        }
      }
    } catch (e) {
      print('Error checking login status: $e');
      await _clearUserData();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Verify token with backend
  Future<User?> _verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      }
    } catch (e) {
      print('Token verification error: $e');
    }
    return null;
  }

  // Login method
  Future<AuthResult> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];

        // Get user info with the token
        final user = await _verifyToken(token);
        if (user != null) {
          await _saveUserData(user, token);
          _currentUser = user;
          _isLoggedIn = true;
          _apiService.setAuthToken(token);
          ApiService.globalAuthToken = token;

          _isLoading = false;
          notifyListeners();
          return AuthResult(success: true, message: 'Login successful');
        } else {
          _isLoading = false;
          notifyListeners();
          return AuthResult(success: false, message: 'Failed to get user info');
        }
      } else {
        final errorData = json.decode(response.body);
        _isLoading = false;
        notifyListeners();
        return AuthResult(
          success: false,
          message: errorData['detail'] ?? 'Login failed',
        );
      }
    } catch (e) {
      print('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return AuthResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // Register method
  Future<AuthResult> register(
    String username,
    String email,
    String password,
    String fullName,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];

        if (token != null && token is String && token.isNotEmpty) {
          // Use the returned token to fetch user info and persist
          final user = await _verifyToken(token);
          if (user != null) {
            await _saveUserData(user, token);
            _currentUser = user;
            _isLoggedIn = true;
            _apiService.setAuthToken(token);
            ApiService.globalAuthToken = token;

            _isLoading = false;
            notifyListeners();
            return AuthResult(
                success: true, message: 'Registration successful');
          } else {
            // Fallback to login if token verification failed
            final loginResult = await login(username, password);
            return loginResult;
          }
        } else {
          // Backward compatibility: if no token returned, perform login
          final loginResult = await login(username, password);
          return loginResult;
        }
      } else {
        final errorData = json.decode(response.body);
        _isLoading = false;
        notifyListeners();
        return AuthResult(
          success: false,
          message: errorData['detail'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      print('Registration error: $e');
      _isLoading = false;
      notifyListeners();
      return AuthResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // Logout method
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _clearUserData();
      _currentUser = null;
      _isLoggedIn = false;
      _apiService.clearAuthToken();
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
    await prefs.setString('user_username', user.username);
    await prefs.setString('user_email', user.email);
    if (user.fullName != null) {
      await prefs.setString('user_full_name', user.fullName!);
    }
  }

  // Clear user data from local storage
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_id');
    await prefs.remove('user_username');
    await prefs.remove('user_email');
    await prefs.remove('user_full_name');
  }

  // Get JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Check if user has valid token
  Future<bool> hasValidToken() async {
    final token = await getToken();
    if (token == null) return false;

    final user = await _verifyToken(token);
    return user != null;
  }

  // Update current user data
  void updateUser(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      await _saveUserData(user, token);
    }
    notifyListeners();
  }
}

// Result class for auth operations
class AuthResult {
  final bool success;
  final String message;

  AuthResult({required this.success, required this.message});
}
