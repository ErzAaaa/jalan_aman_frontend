import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthController {
  /// 🔹 Simpan status login ke local storage
  static Future<void> saveLogin(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', user.username);
    await prefs.setString('role', user.role);
    await prefs.setString('namaLengkap', user.namaLengkap ?? "");
    await prefs.setString('token', user.token ?? "");
    await prefs.setString('lastPage', 'dashboard');
  }

  /// 🔹 Simpan halaman terakhir
  static Future<void> saveLastPage(String page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastPage', page);
  }

  /// 🔹 Ambil halaman terakhir
  static Future<String?> getLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastPage');
  }

  /// 🔹 Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// 🔹 Cek apakah user masih login
  static Future<Map<String, dynamic>?> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (!loggedIn) return null;
    return {
      'username': prefs.getString('username'),
      'role': prefs.getString('role'),
      'token': prefs.getString('token'),
      'lastPage': prefs.getString('lastPage') ?? 'dashboard',
    };
  }
}