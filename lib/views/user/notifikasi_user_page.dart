import 'package:flutter/material.dart';

class NotifikasiUserPage extends StatelessWidget {
  final String token;
  const NotifikasiUserPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> dummyNotif = [
      {"title": "Status diperbarui", "message": "Laporan Jl. Maospati kini disetujui"},
      {"title": "Laporan baru diterima", "message": "Laporan kamu sedang ditinjau"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyNotif.length,
        itemBuilder: (context, index) {
          final notif = dummyNotif[index];
          return Card(
            color: const Color(0xFF0F0F23),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.notifications_active,
                  color: Colors.orangeAccent),
              title: Text(notif["title"]!,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle:
                  Text(notif["message"]!, style: const TextStyle(color: Colors.white70)),
            ),
          );
        },
      ),
    );
  }
}