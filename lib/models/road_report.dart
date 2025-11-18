class RoadReport {
  final String? id;
  final String namaJalan;
  final String jenisKerusakan;
  final String deskripsi;
  final double latitude;
  final double longitude;
  final String? fotoUrl;
  final String? videoUrl;
  final String status;

  RoadReport({
    this.id,
    required this.namaJalan,
    required this.jenisKerusakan,
    required this.deskripsi,
    required this.latitude,
    required this.longitude,
    this.fotoUrl,
    this.videoUrl,
    this.status = 'Belum Ditinjau',
  });

  /// 🔹 Konversi JSON ke objek Dart
  factory RoadReport.fromJson(Map<String, dynamic> json) {
    return RoadReport(
      id: json['_id']?.toString(),
      namaJalan: json['namaJalan'] ?? '',
      jenisKerusakan: json['jenisKerusakan'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      fotoUrl: json['fotoUrl'],
      videoUrl: json['videoUrl'],
      status: json['status'] ?? 'Belum Ditinjau',
    );
  }

  /// 🔹 Konversi objek Dart ke JSON (untuk dikirim ke backend)
  Map<String, dynamic> toJson() {
    return {
      'namaJalan': namaJalan,
      'jenisKerusakan': jenisKerusakan,
      'deskripsi': deskripsi,
      'latitude': latitude,
      'longitude': longitude,
      'fotoUrl': fotoUrl,
      'videoUrl': videoUrl,
      'status': status,
    };
  }
}
