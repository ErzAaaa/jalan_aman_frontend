class Config {
  /// Base URL API. Ubah di sini saat pindah antara local/prod.
  static String apiBaseUrl =
      "https://jalanamanbackend-production.up.railway.app"; // ganti ke IP lokal jika perlu

  /// Set base URL saat runtime (mis. dari main sebelum runApp)
  static void setBaseUrl(String url) => apiBaseUrl = url;
}
