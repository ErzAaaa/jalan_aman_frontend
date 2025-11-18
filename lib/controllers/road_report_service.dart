import 'dart:io';
import 'package:dio/dio.dart';
import '../models/road_report.dart';
import 'auth_controller.dart';

class RoadReportService {
  final Dio _dio;

  RoadReportService({String? baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? "http://192.168.1.4:5000/api/road_reports",
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
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

  /// 🔹 Ambil semua laporan jalan (Admin / Petugas)
  Future<List<RoadReport>> fetchReports(String token) async {
    try {
      final response = await _dio.get(
        "",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((e) => RoadReport.fromJson(e)).toList();
        } else if (data is Map && data['data'] is List) {
          return (data['data'] as List)
              .map((e) => RoadReport.fromJson(e))
              .toList();
        } else {
          throw Exception("Format data tidak dikenali: $data");
        }
      } else {
        throw Exception("Gagal memuat data laporan (${response.statusCode})");
      }
    } on DioException catch (e) {
      throw Exception("❌ Error Fetch Reports: ${e.message}");
    } catch (e) {
      throw Exception("❌ Error tidak terduga: $e");
    }
  }

  /// 🔹 Tambah laporan baru (Petugas)
  Future<bool> createReport({
    required String namaJalan,
    required String jenisKerusakan,
    required String deskripsi,
    required double latitude,
    required double longitude,
    File? foto,
    required String token,
  }) async {
    try {
      // ✅ Ambil nama petugas otomatis dari local storage
      final userData = await AuthController.checkLogin();
      final namaPetugas = userData?['namaLengkap'] ?? 
                          userData?['username'] ?? 
                          "Petugas Tidak Dikenal";

      print("📤 Mengirim laporan dengan data:");
      print("- Nama Jalan: $namaJalan");
      print("- Jenis Kerusakan: $jenisKerusakan");
      print("- Nama Petugas: $namaPetugas");
      print("- Lokasi: ($latitude, $longitude)");

      final formData = FormData.fromMap({
        "namaJalan": namaJalan,
        "jenisKerusakan": jenisKerusakan,
        "deskripsi": deskripsi,
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "namaPetugas": namaPetugas,
        if (foto != null)
          "foto": await MultipartFile.fromFile(
            foto.path,
            filename: foto.path.split(Platform.pathSeparator).last,
          ),
      });

      final response = await _dio.post(
        "",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Laporan berhasil dikirim!");
        return true;
      } else {
        print("⚠ Response status: ${response.statusCode}");
        return false;
      }
    } on DioException catch (e) {
      print("❌ Gagal upload laporan:");
      print("   Status: ${e.response?.statusCode}");
      print("   Data: ${e.response?.data}");
      print("   Message: ${e.message}");
      return false;
    } catch (e) {
      print("❌ Error tidak terduga: $e");
      return false;
    }
  }

  /// 🔹 Update status laporan (Admin)
  Future<bool> updateStatus(String id, String status, String token) async {
    try {
      final response = await _dio.patch(
        "/$id/status",
        data: {"status": status},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        print("✅ Status laporan $id berhasil diupdate ke: $status");
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("❌ Gagal update status: ${e.response?.data ?? e.message}");
      return false;
    } catch (e) {
      print("❌ Error tidak terduga: $e");
      return false;
    }
  }

  /// 🔹 Update data laporan (nama, jenis, deskripsi, status)
  Future<bool> updateReport(
      String id, Map<String, dynamic> data, String token) async {
    try {
      final response = await _dio.patch(
        "/$id",
        data: data,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      
      if (response.statusCode == 200) {
        print("✅ Laporan $id berhasil diupdate");
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("❌ Gagal update laporan: ${e.response?.data ?? e.message}");
      return false;
    } catch (e) {
      print("❌ Error tidak terduga: $e");
      return false;
    }
  }

  /// 🔹 Hapus laporan jalan
  Future<bool> deleteReport(String id, String token) async {
    try {
      final response = await _dio.delete(
        "/$id",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      
      if (response.statusCode == 200) {
        print("✅ Laporan $id berhasil dihapus");
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("❌ Gagal hapus laporan: ${e.response?.data ?? e.message}");
      return false;
    } catch (e) {
      print("❌ Error tidak terduga: $e");
      return false;
    }
  }
}