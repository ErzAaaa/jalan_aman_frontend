import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../controllers/road_report_service.dart';

class LaporanBaruPage extends StatefulWidget {
  final String token;

  const LaporanBaruPage({
    super.key,
    required this.token,
  });

  @override
  State<LaporanBaruPage> createState() => _LaporanBaruPageState();
}

class _LaporanBaruPageState extends State<LaporanBaruPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaJalanController = TextEditingController();
  final TextEditingController _jenisKerusakanController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  File? _selectedFoto;
  bool _isLoading = false;
  bool _isGettingLocation = false;

  final ImagePicker _picker = ImagePicker();
  final RoadReportService _roadService = RoadReportService();

  /// 📸 Ambil foto dari galeri
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedFoto = File(picked.path));
    }
  }

  /// 📍 Ambil lokasi otomatis
  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack("❌ Aktifkan layanan lokasi terlebih dahulu");
      setState(() => _isGettingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnack("⚠ Izin lokasi ditolak");
        setState(() => _isGettingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnack("⚠ Izin lokasi diblokir permanen");
      setState(() => _isGettingLocation = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
      _isGettingLocation = false;
    });

    _showSnack("📍 Lokasi berhasil diambil");
  }

  /// 🚀 Kirim laporan ke backend
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final success = await _roadService.createReport(
        namaJalan: _namaJalanController.text.trim(),
        jenisKerusakan: _jenisKerusakanController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        latitude: double.tryParse(_latitudeController.text) ?? 0.0,
        longitude: double.tryParse(_longitudeController.text) ?? 0.0,
        foto: _selectedFoto,
        token: widget.token,
      );

      if (success) {
        _showSnack("✅ Laporan berhasil dikirim!", Colors.green);
        _formKey.currentState!.reset();
        setState(() => _selectedFoto = null);
      } else {
        _showSnack("❌ Gagal mengirim laporan");
      }
    } catch (e) {
      _showSnack("Terjadi kesalahan: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message, [Color color = Colors.orange]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text("📝 Buat Laporan Baru"),
        backgroundColor: const Color(0xFF0F0F23),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Formulir Laporan Jalan Rusak",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(_namaJalanController, "Nama Jalan"),
              const SizedBox(height: 16),

              _buildTextField(_jenisKerusakanController, "Jenis Kerusakan"),
              const SizedBox(height: 16),

              _buildTextField(_deskripsiController, "Deskripsi", maxLines: 3),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_latitudeController, "Latitude", keyboard: TextInputType.number),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(_longitudeController, "Longitude", keyboard: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: Text(_isGettingLocation ? "Mengambil lokasi..." : "Ambil Lokasi Otomatis"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    _selectedFoto != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _selectedFoto!,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Text("Belum ada foto dipilih", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo),
                      label: const Text("Pilih Foto"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitReport,
                  icon: const Icon(Icons.send),
                  label: Text(_isLoading ? "Mengirim..." : "Kirim Laporan"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, String label,
      {int maxLines = 1, TextInputType? keyboard}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF16213E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) => v!.isEmpty ? "Masukkan $label" : null,
      style: const TextStyle(color: Color.fromARGB(255, 204, 132, 132)),
    );
  }
}