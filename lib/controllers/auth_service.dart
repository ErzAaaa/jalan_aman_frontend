import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio;

  AuthService({String? baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? "http://192.168.1.4:5000/api", // 💡 ganti ke IP LAN kamu
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            responseType: ResponseType.json,
          ),
        ) {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  /// 🔹 Login User (Admin atau Petugas)
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        "/auth/login",
        data: {
          "username": username,
          "password": password,
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        print("⚠ Login gagal: ${response.statusCode}");
        return null;
      }
    } on DioException catch (e) {
      // Menangani error lebih jelas
      if (e.response != null) {
        print("❌ Login error response: ${e.response?.data}");
      } else {
        print("❌ Login error: ${e.message}");
      }
      return null;
    }
  }

  /// 🔹 Registrasi (jika diperlukan di masa depan)
  Future<Map<String, dynamic>?> register(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        "/auth/register",
        data: data,
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      return response.statusCode == 201 ? response.data : null;
    } on DioException catch (e) {
      print("❌ Register error: ${e.response?.data ?? e.message}");
      return null;
    }
  }
}