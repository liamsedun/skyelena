import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.requestTimeout,
      receiveTimeout: AppConstants.requestTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _storage.delete(key: AppConstants.tokenKey);
        }
        return handler.next(error);
      },
    ));
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    final response = await _dio.post('/auth/signup', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/auth/profile');
    return response.data;
  }

  Future<List<dynamic>> getCalls() async {
    final response = await _dio.get('/calls');
    return response.data;
  }

  Future<Map<String, dynamic>> updateCall(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/calls/$id', data: data);
    return response.data;
  }

  Future<List<dynamic>> getMessages() async {
    final response = await _dio.get('/messages');
    return response.data;
  }

  Future<List<dynamic>> getConversations() async {
    final response = await _dio.get('/messages/conversations');
    return response.data;
  }

  Future<List<dynamic>> getConversationMessages(String id) async {
    final response = await _dio.get('/messages/conversations/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> data) async {
    final response = await _dio.post('/messages/send', data: data);
    return response.data;
  }

  Future<List<dynamic>> getBookings() async {
    final response = await _dio.get('/bookings');
    return response.data;
  }

  Future<List<dynamic>> getUpcomingBookings() async {
    final response = await _dio.get('/bookings/upcoming');
    return response.data;
  }

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data) async {
    final response = await _dio.post('/bookings', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> updateBooking(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/bookings/$id', data: data);
    return response.data;
  }

  Future<void> deleteBooking(String id) async {
    await _dio.delete('/bookings/$id');
  }

  Future<Map<String, dynamic>> getSettings() async {
    final response = await _dio.get('/settings');
    return response.data;
  }

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> data) async {
    final response = await _dio.patch('/settings', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> getSubscription() async {
    final response = await _dio.get('/billing/subscription');
    return response.data;
  }

  Future<Map<String, dynamic>> createCheckoutSession(String tier) async {
    final response = await _dio.post('/billing/create-checkout', data: {'tier': tier});
    return response.data;
  }

  Future<Map<String, dynamic>> getBillingPortal() async {
    final response = await _dio.post('/billing/portal');
    return response.data;
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _dio.get('/dashboard/stats');
    return response.data;
  }

  Dio get dio => _dio;
}
