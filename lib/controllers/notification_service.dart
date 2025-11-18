import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/notification_item.dart';

class NotificationService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://192.168.1.4:5000/api"));

  // 🔹 Ambil semua notifikasi
  Future<List<NotificationItem>> getNotifications(String token) async {
    final response = await _dio.get(
      '/notifications',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return (response.data as List)
        .map((n) => NotificationItem(
              id: n['_id'] ?? '',
              title: n['title'] ?? 'Notifikasi',
              message: n['message'] ?? '',
              color: const Color(0xFFFFA726),
              icon: Icons.notifications_active,
              createdAt: DateTime.parse(n['createdAt']),
            ))
        .toList();
  }

  // 🔹 Tandai semua notifikasi sudah dibaca
  Future<void> markAllAsRead(String token) async {
    await _dio.post(
      '/notifications/mark-read',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  // 🔹 Hapus notifikasi tertentu
  Future<void> deleteNotification(String id, String token) async {
    await _dio.delete(
      '/notifications/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}