import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:audioplayers/audioplayers.dart';
import '../controllers/notification_service.dart';
import '../models/notification_item.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/custom_sidebar.dart';

class DashboardAdmin extends StatefulWidget {
  final String token;
  final String username;

  const DashboardAdmin({
    super.key,
    required this.username,
    required this.token,
  });

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  String selectedMenu = "Dashboard";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late IO.Socket socket;
  final NotificationService _notifService = NotificationService();
  List<NotificationItem> notifications = [];
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _connectSocket();
    _fetchNotifications();
  }

  // ✅ Koneksi ke Socket.IO backend
  void _connectSocket() {
    socket = IO.io(
      'https://jalanamanbackend-production.up.railway.app', // ganti IP sesuai server.js kamu
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) => debugPrint('✅ Socket terhubung ke server!'));

    socket.on('new_notification', (data) {
      debugPrint('📩 Notifikasi baru: $data');

      setState(() {
        notifications.insert(
          0,
          NotificationItem(
            id: data['_id'],
            title: data['title'] ?? 'Notifikasi Baru',
            message: data['message'] ?? '',
            color: Colors.orange,
            icon: Icons.notifications_active,
            createdAt: DateTime.parse(data['createdAt']),
          ),
        );
      });

      player.play(AssetSource('sounds/notification.mp3'));
    });

    socket.onDisconnect((_) => debugPrint('❌ Socket terputus'));
  }

  // ✅ Fungsi untuk mengambil notifikasi dari backend
  Future<void> _fetchNotifications() async {
    try {
      final data = await _notifService.getNotifications(widget.token);
      setState(() => notifications = data);
    } catch (e) {
      debugPrint("❌ Gagal memuat notifikasi di dashboard: $e");
    }
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0F1419),
      drawer: MediaQuery.of(context).size.width < 600
          ? Drawer(
              backgroundColor: const Color(0xFF16213E),
              child: CustomSidebar(
                selectedMenu: selectedMenu,
                onSelect: (menu) {
                  setState(() => selectedMenu = menu);
                  Navigator.pop(context);
                },
                token: widget.token, // ✅ tambahkan token
              ),
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return Column(
                children: [
                  CustomNavbar(
                    username: widget.username,
                    token: widget.token,
                    searchData: notifications.map((n) => n.title).toList(),
                    notifications: notifications,
                    onNotificationUpdate: _fetchNotifications, // ✅ tambahkan callback
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildDashboardContent(
                        context,
                        notifications,
                        isMobile: true,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              final isTablet = constraints.maxWidth < 1024;
              return Row(
                children: [
                  CustomSidebar(
                    selectedMenu: selectedMenu,
                    onSelect: (menu) {
                      setState(() => selectedMenu = menu);
                    },
                    token: widget.token, // ✅ tambahkan token
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        CustomNavbar(
                          username: widget.username,
                          token: widget.token,
                          searchData: notifications.map((n) => n.title).toList(),
                          notifications: notifications,
                          onNotificationUpdate: _fetchNotifications, // ✅ tambahkan callback
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(isTablet ? 16 : 24),
                            child: _buildDashboardContent(
                              context,
                              notifications,
                              isTablet: isTablet,
                              isDesktop: !isTablet,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    List<NotificationItem> notifications, {
    bool isMobile = false,
    bool isTablet = false,
    bool isDesktop = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Banner
        _buildHeaderBanner(),
        const SizedBox(height: 24),

        // Statistik Cards
        _buildStatistikSection(isMobile: isMobile),
        const SizedBox(height: 24),

        // Two Column Layout: Notifications & Status Overview
        if (isMobile)
          Column(
            children: [
              _buildNotificationsSection(notifications),
              const SizedBox(height: 24),
              _buildStatusOverview(),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildNotificationsSection(notifications),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildStatusOverview(),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFFA500)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Jalan Aman Kota Nyaman",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Deteksi Dini Kerusakan Jalan dan Potensi Bahaya\nBerbasis Citra Satelit dan Drone",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikSection({bool isMobile = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Statistik Kerusakan Jalan",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (isMobile) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard("Jalan Rusak", "20", Colors.red, Icons.warning, "Total kerusakan terdeteksi")),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard("Sudah Ditangani", "11", Colors.green, Icons.check_circle, "Perbaikan selesai")),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard("Belum Ditangani", "14", Colors.blue, Icons.pending, "Menunggu perbaikan")),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard("Survey Hari Ini", "5", Colors.orange, Icons.flight, "Pemindaian drone")),
                    ],
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(child: _buildStatCard("Jalan Rusak", "20", Colors.red, Icons.warning, "Total kerusakan terdeteksi")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard("Sudah Ditangani", "11", Colors.green, Icons.check_circle, "Perbaikan selesai")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard("Belum Ditangani", "14", Colors.blue, Icons.pending, "Menunggu perbaikan")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard("Survey Hari Ini", "5", Colors.orange, Icons.flight, "Pemindaian drone")),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2F3E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(List<NotificationItem> notifications) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2F3E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pembaruan Informasi",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...notifications.map((notif) => _buildNotificationCard(notif)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notif) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2F3E), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: notif.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(notif.icon, color: notif.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: notif.color,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notif.message,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notif.timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2F3E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Status Jalan Overview",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: 0.65,
                      strokeWidth: 20,
                      backgroundColor: const Color(0xFF2A2F3E),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "65%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Kondisi Baik",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildStatusItem("Kondisi Baik", "65%", Colors.green),
          const SizedBox(height: 12),
          _buildStatusItem("Perlu Perbaikan", "20%", Colors.orange),
          const SizedBox(height: 12),
          _buildStatusItem("Rusak Berat", "15%", Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}