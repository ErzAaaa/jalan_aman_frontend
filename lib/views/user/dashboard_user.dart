import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../config.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../widgets/custom_navbar_user.dart';
import '../../widgets/custom_sidebar_user.dart';
import '../../models/notification_item.dart';
import 'laporan_baru_page.dart';
import 'riwayat_laporan_page.dart';
import 'notifikasi_user_page.dart';
import '../login_page.dart';

class DashboardUser extends StatefulWidget {
  final String username;
  final String token;
  final String userId;

  const DashboardUser({
    super.key,
    required this.username,
    required this.token,
    required this.userId,
  });

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  String selectedMenu = "Dashboard";
  late IO.Socket socket;
  final player = AudioPlayer();
  final List<NotificationItem> notifications = [];

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  // 🔥 Koneksi ke Socket.IO + Listener Notifikasi
  void _connectSocket() {
    // Gunakan host dari Config.apiBaseUrl dan bangun URL socket (http/https + host[:port])
    final uri = Uri.parse(Config.apiBaseUrl);
    final scheme = (uri.scheme == 'https') ? 'https' : 'http';
    final hostPort = uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
    final socketUrl = '$scheme://$hostPort';

    socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();
    socket.emit('register_user', widget.userId);

    socket.onConnect((_) => debugPrint('✅ Petugas terhubung ke server!'));

    socket.on('new_notification', (data) {
      debugPrint('📩 Petugas menerima notifikasi baru: $data');

      // 🔊 Bunyi notifikasi
      player.play(AssetSource('sounds/notification.mp3'));

      // 🔔 Snackbar real-time
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Ada pembaruan dari admin'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // 🔹 Tambahkan ke list notifikasi
      setState(() {
        notifications.insert(
          0,
          NotificationItem(
            id: data['_id'],
            title: data['title'] ?? 'Notifikasi Baru',
            message: data['message'] ?? '',
            color: Colors.orange,
            icon: Icons.notifications_active,
            createdAt:
                DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
          ),
        );
      });
    });

    socket.onDisconnect((_) => debugPrint('❌ Petugas terputus dari server'));
  }

  @override
  void dispose() {
    socket.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuPages = [
      {"title": "Dashboard", "widget": const DashboardContent()},
      {"title": "Buat Laporan", "widget": LaporanBaruPage(token: widget.token)},
      {
        "title": "Riwayat Laporan",
        "widget": RiwayatLaporanPage(token: widget.token),
      },
      {
        "title": "Notifikasi",
        "widget": NotifikasiUserPage(
          token: widget.token,
          notifications: notifications,
        ),
      },
    ];

    final currentPage = menuPages.firstWhere(
      (menu) => menu["title"] == selectedMenu,
      orElse: () => menuPages[0],
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      drawer: MediaQuery.of(context).size.width < 600
          ? Drawer(
              backgroundColor: const Color(0xFF16213E),
              child: CustomSidebarUser(
                selectedMenu: selectedMenu,
                onSelect: (menu) => setState(() => selectedMenu = menu),
              ),
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (MediaQuery.of(context).size.width >= 600)
              CustomSidebarUser(
                selectedMenu: selectedMenu,
                onSelect: (menu) => setState(() => selectedMenu = menu),
              ),
            Expanded(
              child: Column(
                children: [
                  CustomNavbarUser(
                    username: widget.username,
                    onLogout: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                  ),
                  Expanded(child: currentPage["widget"]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Selamat Datang, Petugas 👷‍♂",
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Kelola dan pantau laporan kondisi jalan di wilayah tugasmu.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatCard(Icons.warning, "Total Laporan", "12"),
              _buildStatCard(Icons.check_circle, "Disetujui", "7"),
              _buildStatCard(Icons.timer, "Belum Ditinjau", "5"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 36),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
