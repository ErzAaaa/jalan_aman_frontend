class RoadData {
  final int no;
  String namaJalan;
  String jenisKerusakan;
  String detail;
  String status;
  double latitude;
  double longitude;

  RoadData({
    required this.no,
    required this.namaJalan,
    required this.jenisKerusakan,
    this.detail = "",
    this.status = "Belum Ditinjau",
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  // ✅ Encapsulation (getter & setter)
  String get getNamaJalan => namaJalan;
  String get getJenisKerusakan => jenisKerusakan;
  String get getDetail => detail;
  String get getStatus => status;

  set setNamaJalan(String value) => namaJalan = value;
  set setJenisKerusakan(String value) => jenisKerusakan = value;
  set setStatus(String value) => status = value;
}

/// ✅ Inheritance
class JalanUtama extends RoadData {
  JalanUtama({
    required super.no,
    required super.namaJalan,
    required super.jenisKerusakan,
    super.detail,
    super.status,
  });

  // ✅ Polymorphism (override)
  @override
  String get getJenisKerusakan => "KERUSAKAN SERIUS: $jenisKerusakan";
}
