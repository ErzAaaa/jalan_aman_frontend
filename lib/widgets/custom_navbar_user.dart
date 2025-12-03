import 'package:flutter/material.dart';

class CustomNavbarUser extends StatelessWidget {
  final String username;
  final VoidCallback onLogout;

  const CustomNavbarUser({
    super.key,
    required this.username,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      color: const Color(0xFF0F0F23),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            )
          else
            const Text(
              "Dashboard Petugas",
              style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.orange),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Notifikasi belum tersedia")),
                  );
                },
              ),
              const SizedBox(width: 12),
              Text(
                username,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                tooltip: "Logout",
                onPressed: onLogout,
              ),
            ],
          )
        ],
      ),
    );
  }
}
