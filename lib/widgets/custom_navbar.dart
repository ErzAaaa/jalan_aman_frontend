import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/notification_service.dart';
import '../views/login_page.dart';
import '../models/notification_item.dart';

class CustomNavbar extends StatefulWidget implements PreferredSizeWidget {
  final String username;
  final String token; // ✅ akses API
  final List<String> searchData;
  final Function(String)? onSearch;
  final List<NotificationItem>? notifications; // ✅ notifikasi dari Dashboard
  final VoidCallback? onNotificationUpdate; // ✅ callback untuk update notifikasi

  const CustomNavbar({
    super.key,
    required this.username,
    required this.token,
    required this.searchData,
    this.onSearch,
    this.notifications,
    this.onNotificationUpdate, // ✅ tambahkan di konstruktor
  });

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomNavbarState extends State<CustomNavbar> {
  final TextEditingController _searchController = TextEditingController();
  final NotificationService _notifService = NotificationService();
  List<String> filteredResults = [];
  List<NotificationItem> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications(); // ✅ ambil data awal dari API
  }

  // ✅ ambil dari backend saat pertama kali
  Future<void> _fetchNotifications() async {
    try {
      final data = await _notifService.getNotifications(widget.token);
      setState(() => notifications = data);
    } catch (e) {
      debugPrint("❌ Gagal memuat notifikasi: $e");
    }
  }

  // ✅ update hasil pencarian
  void _onSearchChanged(String query) {
    final lowerQuery = query.toLowerCase();
    if (widget.onSearch != null) widget.onSearch!(lowerQuery);

    setState(() {
      filteredResults = widget.searchData
          .where((item) => item.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  // ✅ popup daftar notifikasi
  void _showNotificationsPopup(BuildContext context) async {
    // ambil dari dashboard kalau ada
    if (widget.notifications != null && widget.notifications!.isNotEmpty) {
      notifications = widget.notifications!;
    } else {
      try {
        final data = await _notifService.getNotifications(widget.token);
        notifications = data;
      } catch (e) {
        debugPrint("⚠ Gagal load notifikasi: $e");
      }
    }

    setState(() {}); // refresh badge count

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Notifikasi Terbaru",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await _notifService.markAllAsRead(widget.token);
                          setState(() => notifications.clear());
                          // ✅ Panggil callback setelah ditandai dibaca semua
                          if (widget.onNotificationUpdate != null) {
                            widget.onNotificationUpdate!();
                          }
                          Navigator.pop(context);
                        } catch (e) {
                          debugPrint("⚠ Gagal tandai dibaca: $e");
                        }
                      },
                      child: const Text(
                        "Tandai Dibaca Semua",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (notifications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Belum ada notifikasi",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return Dismissible(
                          key: ValueKey("${notif.title}-$index"),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) async {
                            try {
                              await _notifService.deleteNotification(
                                notif.id ?? '',
                                widget.token,
                              );
                              setState(() => notifications.removeAt(index));
                              // ✅ Panggil callback setelah notifikasi dihapus
                              if (widget.onNotificationUpdate != null) {
                                widget.onNotificationUpdate!();
                              }
                            } catch (e) {
                              debugPrint("❌ Gagal hapus notifikasi: $e");
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F0F23),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: notif.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    notif.icon,
                                    color: notif.color,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notif.title,
                                        style: TextStyle(
                                          color: notif.color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        notif.message,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        notif.timeAgo,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ UI AppBar
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 1024;

    return AppBar(
      backgroundColor: const Color(0xFF0F0F23),
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: isMobile
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : null,
      title: Text(
        "Halo, ${widget.username} 👋",
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 16 : 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () => _showNotificationsPopup(context),
            ),
            if ((widget.notifications?.isNotEmpty ?? false) ||
                notifications.isNotEmpty)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    ((widget.notifications?.length ?? notifications.length))
                        .toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 10),
        CircleAvatar(
          backgroundColor: Colors.orange,
          child: Text(
            widget.username.isNotEmpty
                ? widget.username[0].toUpperCase()
                : "A",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        PopupMenuButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          color: const Color(0xFF1A1A2E),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: "logout",
              onTap: () async {
                await AuthController.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ],
    );
  }
}