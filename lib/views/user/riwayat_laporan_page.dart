import 'package:flutter/material.dart';
import '../../controllers/road_report_service.dart';
import '../../models/road_report.dart';

class RiwayatLaporanPage extends StatefulWidget {
  final String token;
  const RiwayatLaporanPage({super.key, required this.token});

  @override
  State<RiwayatLaporanPage> createState() => _RiwayatLaporanPageState();
}

class _RiwayatLaporanPageState extends State<RiwayatLaporanPage> {
  late Future<List<RoadReport>> _futureReports;
  final RoadReportService _roadService = RoadReportService(); // ✅ gunakan instance

  @override
  void initState() {
    super.initState();
    _futureReports = _loadReports(); // ✅ pakai method async
  }

  Future<List<RoadReport>> _loadReports() async {
    try {
      final reports = await _roadService.fetchReports(widget.token);
      return reports;
    } catch (e) {
      debugPrint("❌ Gagal memuat laporan: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<RoadReport>>(
          future: _futureReports,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "Gagal memuat laporan",
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Belum ada laporan.",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final report = data[index];
                return Card(
                  color: const Color(0xFF0F0F23),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      report.namaJalan,
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Jenis: ${report.jenisKerusakan}\nStatus: ${report.status ?? 'Belum Ditinjau'}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
                    onTap: () {
                      _showDetailDialog(report);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// 🪧 Popup detail laporan (biar user bisa lihat lengkap)
  void _showDetailDialog(RoadReport report) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F23),
        title: const Text("Detail Laporan", style: TextStyle(color: Colors.orangeAccent)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (report.fotoUrl != null && report.fotoUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    report.fotoUrl!,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Text(
                      "Gagal memuat foto",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              _info("Nama Jalan", report.namaJalan),
              _info("Jenis Kerusakan", report.jenisKerusakan),
              _info("Deskripsi", report.deskripsi),
              _info("Latitude", report.latitude.toString()),
              _info("Longitude", report.longitude.toString()),
              _info("Status", report.status ?? "Belum Ditinjau"),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Tutup", style: TextStyle(color: Colors.orangeAccent)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: RichText(
          text: TextSpan(
            text: "$label: ",
            style: const TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
}