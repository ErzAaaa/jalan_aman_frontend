import 'package:flutter/material.dart';

class CustomSidebarUser extends StatelessWidget {
  final String selectedMenu;
  final Function(String) onSelect;

  const CustomSidebarUser({
    super.key,
    required this.selectedMenu,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final menus = [
      {"icon": Icons.dashboard, "title": "Dashboard"},
      {"icon": Icons.add_location_alt, "title": "Buat Laporan"},
      {"icon": Icons.history, "title": "Riwayat Laporan"},
      {"icon": Icons.notifications, "title": "Notifikasi"},
    ];

    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color: Color(0xFF16213E),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            "Petugas Jalan Aman 👷",
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white24, height: 30),

          // daftar menu
          Expanded(
            child: ListView.builder(
              itemCount: menus.length,
              itemBuilder: (context, index) {
                final menu = menus[index];
                final bool isActive = selectedMenu == menu["title"];
                return InkWell(
                  onTap: () => onSelect(menu["title"] as String),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.orange.withOpacity(0.15)
                          : Colors.transparent,
                      border: Border(
                        left: BorderSide(
                          color: isActive ? Colors.orange : Colors.transparent,
                          width: 4,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(menu["icon"] as IconData,
                            color: isActive
                                ? Colors.orangeAccent
                                : Colors.white70),
                        const SizedBox(width: 12),
                        Text(
                          menu["title"] as String,
                          style: TextStyle(
                            color:
                                isActive ? Colors.orangeAccent : Colors.white70,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white24),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "© 2025 Dinas PUPR",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
