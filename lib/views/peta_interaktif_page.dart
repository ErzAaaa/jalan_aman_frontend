import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/road_report_service.dart';
import '../models/road_report.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/custom_sidebar.dart';

class PetaInteraktifPage extends StatefulWidget {
  final String token;
  const PetaInteraktifPage({super.key, required this.token});

  @override
  State<PetaInteraktifPage> createState() => _PetaInteraktifPageState();
}

class _PetaInteraktifPageState extends State<PetaInteraktifPage> {
  final PopupController _popupController = PopupController();
  final RoadReportService _roadService = RoadReportService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<RoadReport> _reports = [];
  bool _isLoading = true;
  String selectedMenu = "Peta Interaktif";

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final reports = await _roadService.fetchReports(widget.token);
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
      print("✅ ${reports.length} laporan jalan berhasil dimuat di peta.");
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat data laporan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1A1A2E),
      drawer: isMobile
          ? Drawer(
              backgroundColor: const Color(0xFF16213E),
              child: CustomSidebar(
                selectedMenu: selectedMenu,
                token: widget.token,
                onSelect: (menu) {
                  setState(() => selectedMenu = menu);
                  Navigator.pop(context);
                },
              ),
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile)
              CustomSidebar(
                selectedMenu: selectedMenu,
                token: widget.token,
                onSelect: (menu) => setState(() => selectedMenu = menu),
              ),
            Expanded(
              child: Column(
                children: [
                  CustomNavbar(
                    username: "Admin",
                    token: widget.token, // ✅ tambahkan token
                    searchData: _reports.map((e) => e.namaJalan).toList(),
                    onSearch: (query) {
                      setState(() {
                        _reports = _reports.where((r) {
                          return r.namaJalan
                                  .toLowerCase()
                                  .contains(query.toLowerCase()) ||
                              r.jenisKerusakan
                                  .toLowerCase()
                                  .contains(query.toLowerCase());
                        }).toList();
                      });
                    },
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.orange),
                          )
                        : _reports.isEmpty
                            ? const Center(
                                child: Text(
                                  "Tidak ada laporan jalan rusak 😔",
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 16),
                                ),
                              )
                            : _buildMap(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(-7.6542, 111.3325),
        initialZoom: 12,
        onTap: (_, __) => _popupController.hideAllPopups(),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.app',
        ),
        PopupMarkerLayerWidget(
          options: PopupMarkerLayerOptions(
            popupController: _popupController,
            markers: _reports.map((report) {
              return Marker(
                point: LatLng(report.latitude, report.longitude),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 40,
                ),
              );
            }).toList(),
            popupDisplayOptions: PopupDisplayOptions(
              builder: (context, marker) {
                final report = _reports.firstWhere(
                  (r) =>
                      r.latitude == marker.point.latitude &&
                      r.longitude == marker.point.longitude,
                  orElse: () => _reports.first,
                );
                return _buildPopupCard(report);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopupCard(RoadReport report) {
    return Card(
      color: const Color(0xFF0F0F23),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.namaJalan,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text("Jenis: ${report.jenisKerusakan}",
                style: const TextStyle(color: Colors.white70)),
            Text("Status: ${report.status ?? '-'}",
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Text("Deskripsi: ${report.deskripsi}",
                style: const TextStyle(color: Colors.white70)),
            if (report.fotoUrl != null && report.fotoUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    report.fotoUrl!,
                    height: 120,
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Text(
                      "Gagal memuat foto",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}