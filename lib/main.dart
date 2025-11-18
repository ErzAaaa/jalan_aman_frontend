import 'package:flutter/material.dart';
import 'controllers/auth_controller.dart';
import 'views/login_page.dart';
import 'views/dashboard_admin.dart';
import 'views/peta_interaktif_page.dart';
import 'views/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialPage() async {
    await Future.delayed(const Duration(seconds: 2)); // ⏳ tampilkan splash dulu

    final user = await AuthController.checkLogin();
    if (user == null) return const LoginPage(); // belum login → ke login

    final role = user['role'];
    final lastPage = user['lastPage'] ?? 'dashboard';
    final username = user['username'];
    final token = user['token'];

    // 🔹 Jika role admin
    if (role == 'admin') {
      switch (lastPage) {
        case 'peta':
          return PetaInteraktifPage(token: token); // ✅ kirim token
        case 'data_jalan':
          return DashboardAdmin(username: username, token: token);
        default:
          return DashboardAdmin(username: username, token: token);
      }
    }

    // 🔹 Jika role petugas (belum ada dashboard khusus)
    return const LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jalan Aman',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        useMaterial3: true,
      ),
      home: FutureBuilder<Widget>(
        future: _getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashPage(); // ✅ tampilkan splash saat loading
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Terjadi kesalahan: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          } else {
            return snapshot.data ?? const LoginPage();
          }
        },
      ),
    );
  }
}