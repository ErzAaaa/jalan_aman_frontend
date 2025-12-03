import 'package:flutter/material.dart';
import '../controllers/road_report_service.dart';
import '../models/road_report.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/custom_sidebar.dart';

class DataJalanPage extends StatefulWidget {
  final String token;
  
  const DataJalanPage({super.key, required this.token});

  @override
  State<DataJalanPage> createState() => _DataJalanPageState();
}

class _DataJalanPageState extends State<DataJalanPage> {
  final RoadReportService _roadService = RoadReportService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<RoadReport> dataJalan = [];
  List<RoadReport> filteredData = [];
  bool isLoading = true;
  String selectedMenu = "Data Jalan";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ==================== DATA LOADING ====================
  
  Future<void> _loadData() async {
    try {
      final reports = await _roadService.fetchReports(widget.token);
      setState(() {
        dataJalan = reports;
        filteredData = reports;
        isLoading = false;
      });
      debugPrint("✅ Data jalan berhasil dimuat: ${reports.length}");
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Gagal memuat data: $e");
    }
  }

  // ==================== CRUD OPERATIONS ====================
  
  Future<void> _updateStatus(String id, String status) async {
    final success = await _roadService.updateStatus(id, status, widget.token);
    if (success) {
      await _loadData();
      _showSnackBar("Status berhasil diubah ke $status");
    }
  }

  Future<void> _deleteData(String id) async {
    final confirm = await _showDeleteConfirmation();
    
    if (confirm == true) {
      final success = await _roadService.deleteReport(id, widget.token);
      if (success) {
        await _loadData();
        _showSnackBar("🗑 Data berhasil dihapus");
      } else {
        _showSnackBar("❌ Gagal menghapus data");
      }
    }
  }

  // ==================== DIALOGS ====================
  
  void _showDetail(RoadReport jalan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          "Detail Laporan Jalan",
          style: TextStyle(color: Colors.orange),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (jalan.fotoUrl != null && jalan.fotoUrl!.isNotEmpty)
                _buildImage(jalan.fotoUrl!),
              const SizedBox(height: 12),
              _detailItem("Nama Jalan", jalan.namaJalan),
              _detailItem("Jenis Kerusakan", jalan.jenisKerusakan),
              _detailItem("Deskripsi", jalan.deskripsi),
              _detailItem("Latitude", jalan.latitude.toString()),
              _detailItem("Longitude", jalan.longitude.toString()),
              _detailItem("Status", jalan.status ?? "Belum Ditinjau"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tutup",
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(RoadReport jalan) {
    final namaCtrl = TextEditingController(text: jalan.namaJalan);
    final jenisCtrl = TextEditingController(text: jalan.jenisKerusakan);
    final deskripsiCtrl = TextEditingController(text: jalan.deskripsi);
    final statusCtrl = TextEditingController(text: jalan.status ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          "Edit Data Jalan",
          style: TextStyle(color: Colors.orange),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _editField("Nama Jalan", namaCtrl),
            _editField("Jenis Kerusakan", jenisCtrl),
            _editField("Deskripsi", deskripsiCtrl),
            _editField("Status", statusCtrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => _handleEditSave(
              jalan,
              namaCtrl,
              jenisCtrl,
              deskripsiCtrl,
              statusCtrl,
            ),
            child: const Text(
              "Simpan",
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          "Hapus Data",
          style: TextStyle(color: Colors.orange),
        ),
        content: const Text(
          "Yakin ingin menghapus data ini?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Batal",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HANDLERS ====================
  
  Future<void> _handleEditSave(
    RoadReport jalan,
    TextEditingController namaCtrl,
    TextEditingController jenisCtrl,
    TextEditingController deskripsiCtrl,
    TextEditingController statusCtrl,
  ) async {
    Navigator.pop(context);
    
    final success = await _roadService.updateReport(
      jalan.id ?? "",
      {
        "namaJalan": namaCtrl.text,
        "jenisKerusakan": jenisCtrl.text,
        "deskripsi": deskripsiCtrl.text,
        "status": statusCtrl.text,
      },
      widget.token,
    );

    if (success) {
      await _loadData();
      _showSnackBar("✅ Data berhasil diperbarui");
    } else {
      _showSnackBar("❌ Gagal memperbarui data");
    }
  }

  void _handleSearch(String query) {
    setState(() {
      filteredData = dataJalan.where((jalan) {
        return jalan.namaJalan.toLowerCase().contains(query.toLowerCase()) ||
            jalan.jenisKerusakan.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // ==================== UI HELPERS ====================
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "Disetujui":
        return Colors.green;
      case "Ditolak":
        return Colors.red;
      case "Belum Ditinjau":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // ==================== WIDGET BUILDERS ====================
  
  Widget _buildImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Text(
          "Gagal memuat foto",
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orangeAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            const Color(0xFFFFA726).withOpacity(0.2),
          ),
          columns: const [
            DataColumn(
              label: Text("No.", style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text("Nama Jalan", style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text(
                "Jenis Kerusakan",
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text("Status", style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text("Aksi", style: TextStyle(color: Colors.white)),
            ),
          ],
          rows: _buildDataRows(),
        ),
      ),
    );
  }

  List<DataRow> _buildDataRows() {
    return List.generate(filteredData.length, (index) {
      final jalan = filteredData[index];
      return DataRow(
        cells: [
          DataCell(
            Text(
              "${index + 1}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          DataCell(
            Text(
              jalan.namaJalan,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          DataCell(
            Text(
              jalan.jenisKerusakan,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          DataCell(
            Text(
              jalan.status ?? "-",
              style: TextStyle(color: _getStatusColor(jalan.status)),
            ),
          ),
          DataCell(_buildActionButtons(jalan)),
        ],
      );
    });
  }

  Widget _buildActionButtons(RoadReport jalan) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.info, color: Colors.orange),
          tooltip: "Detail",
          onPressed: () => _showDetail(jalan),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.orangeAccent),
          tooltip: "Edit",
          onPressed: () => _showEditDialog(jalan),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          tooltip: "Hapus",
          onPressed: () => _deleteData(jalan.id ?? ""),
        ),
      ],
    );
  }

  // ==================== MAIN BUILD ====================
  
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1A1A2E),
      drawer: isMobile ? _buildDrawer() : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile) _buildSidebar(),
            Expanded(child: _buildMainContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF16213E),
      child: CustomSidebar(
        selectedMenu: selectedMenu,
        onSelect: (menu) {
          setState(() => selectedMenu = menu);
          Navigator.pop(context);
        },
        token: widget.token,
      ),
    );
  }

  Widget _buildSidebar() {
    return CustomSidebar(
      selectedMenu: selectedMenu,
      onSelect: (menu) => setState(() => selectedMenu = menu),
      token: widget.token,
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        CustomNavbar(
          username: "Admin",
          token: widget.token, // ✅ tambahkan token
          searchData: dataJalan.map((e) => e.namaJalan).toList(),
          onSearch: _handleSearch,
        ),
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildDataTable(),
                ),
        ),
      ],
    );
  }
}