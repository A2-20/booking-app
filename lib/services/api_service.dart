import 'dart:io';
import 'package:dio/dio.dart';
import '../storage/local_storage_manager.dart';
import '../config/app_config.dart';

class ApiService {
  static String get _baseUrl {
    if (Platform.isAndroid && AppConfig.apiBaseIp == '127.0.0.1') {
      return 'http://10.0.2.2:${AppConfig.apiPort}/api';
    }
    return AppConfig.apiUrl;
  }

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  static Future<void> init() async {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await LocalStorageManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          print('API Error [${e.type}]: ${e.message}');
          if (e.response != null) {
            print('Response Status: ${e.response?.statusCode}');
            print('Response Data: ${e.response?.data}');
          }
          if (e.error is SocketException) {
            print('Socket Error: ${e.error}');
            print('Please ensure your backend server is running at $_baseUrl');
          }
          if (e.response?.statusCode == 401) {
            // Handle unauthorized (e.g. logout)
          }
          return handler.next(e);
        },
      ),
    );
  }

  // GET Request
  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  // POST Request
  static Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  // PUT Request
  static Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE Request
  static Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      rethrow;
    }
  }
}
