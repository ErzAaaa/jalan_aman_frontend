import 'package:flutter/material.dart';
import '../views/data_jalan_page.dart';
import '../views/dashboard_admin.dart';
import '../views/peta_interaktif_page.dart';
import '../controllers/auth_controller.dart';

class CustomSidebar extends StatelessWidget {
  final String token;
  final Function(String) onSelect;
  final String selectedMenu;

  const CustomSidebar({
    super.key,
    required this.onSelect,
    required this.selectedMenu,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Deteksi ukuran layar
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;
    final isDesktop = screenWidth > 1024;

    // ✅ Sidebar width dinamis
    double sidebarWidth = 250;
    if (isTablet) {
      sidebarWidth = 200; // Lebih kecil untuk tablet
    } else if (!isDesktop) {
      sidebarWidth = 250; // Full width untuk mobile (dalam drawer)
    }

    return Container(
      width: sidebarWidth,
      color: const Color(0xFF16213E),
      child: Column(
        children: [
          // ✅ Logo dengan ukuran responsif
          Container(
            padding: EdgeInsets.all(isDesktop ? 20 : 12),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/images/logo.png",
                  width: isDesktop ? 100 : (isTablet ? 70 : 80),
                  height: isDesktop ? 100 : (isTablet ? 70 : 80),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const Divider(color: Colors.grey, height: 1),

          // ✅ Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSidebarItem(context, Icons.dashboard, "Dashboard", true),
                _buildSidebarItem(context, Icons.traffic, "Data Jalan", true),
                _buildSidebarItem(context, Icons.map, "Peta Interaktif", true),
                _buildSidebarItem(context, Icons.analytics, "Statistik", true),
                _buildSidebarItem(context, Icons.settings, "Pengaturan", true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context,
    IconData icon,
    String title,
    bool showText,
  ) {
    final isSelected = selectedMenu == title;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: showText ? 12 : 8, vertical: 4),
      child: Tooltip(
        message: showText ? "" : title, // Tooltip hanya muncul jika icon only
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.orange : Colors.grey[400],
            size: 22,
          ),
          // ✅ Tampilkan title hanya jika desktop/tablet
          title: showText
              ? Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.orange : Colors.grey[400],
                    fontSize: 15,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                )
              : null,
          onTap: () async {
            onSelect(title);

            if (title == "Dashboard") {
              await AuthController.saveLastPage('dashboard');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => DashboardAdmin(username: 'Admin', token: token,),
                ),
              );
            } else if (title == "Data Jalan") {
              await AuthController.saveLastPage('data_jalan');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => DataJalanPage(token: token),
                ),
              );
            } else if (title == "Peta Interaktif") {
              await AuthController.saveLastPage('peta');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PetaInteraktifPage(token: token),
                ),
              );
            }
          },

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: isSelected
              ? Colors.orange.withOpacity(0.1)
              : Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: showText ? 16 : 12,
            vertical: 4,
          ),
          minLeadingWidth: showText
              ? null
              : 0, // Hilangkan space jika icon only
        ),
      ),
    );
  }
}
