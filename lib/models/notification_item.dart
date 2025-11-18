import 'package:flutter/material.dart';

class NotificationItem {
  final String? id; // 🔥 tambahkan ini
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    this.id,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.isRead = false,
    required this.createdAt,
  });

  // 🔹 Fungsi bantu untuk menghitung selisih waktu
  String get timeAgo {
    final duration = DateTime.now().difference(createdAt);

    if (duration.inSeconds < 60) return "Baru saja";
    if (duration.inMinutes < 60) return "${duration.inMinutes} menit lalu";
    if (duration.inHours < 24) return "${duration.inHours} jam lalu";
    if (duration.inDays < 7) return "${duration.inDays} hari lalu";
    return "${createdAt.day}/${createdAt.month}/${createdAt.year}";
  }
}
