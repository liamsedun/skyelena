import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final ApiService _api = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> init() async {
    _token = await _storage.read(key: AppConstants.tokenKey);
    if (_token != null) {
      try {
        final data = await _api.getProfile();
        _currentUser = UserModel.fromJson(data);
        _isAuthenticated = true;
      } catch (e) {
        await _storage.delete(key: AppConstants.tokenKey);
        _token = null;
      }
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _api.login(email, password);
      _token = data['token'];
      _currentUser = UserModel.fromJson(data['user']);
      _isAuthenticated = true;

      await _storage.write(key: AppConstants.tokenKey, value: _token);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _api.signup(userData);
      _token = data['token'];
      _currentUser = UserModel.fromJson(data['user']);
      _isAuthenticated = true;

      await _storage.write(key: AppConstants.tokenKey, value: _token);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _isAuthenticated = false;
    await _storage.delete(key: AppConstants.tokenKey);
    notifyListeners();
  }
}
