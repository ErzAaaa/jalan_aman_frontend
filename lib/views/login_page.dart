import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_service.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import 'dashboard_admin.dart';
import 'user/dashboard_user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isPasswordHidden = true;
  bool _isLoading = false;

  final AuthService _authService = AuthService(); // ✅ Instance AuthService

  Future<void> _login() async {
    final username = _userController.text.trim();
    final password = _passController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username dan password wajib diisi")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.login(username, password);

    setState(() => _isLoading = false);

    if (result != null && result["token"] != null) {
      final token = result["token"];
      final user = result["user"];

      // ✅ Simpan login ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      await prefs.setString("username", user["username"]);
      await prefs.setString("role", user["role"]);
      await prefs.setBool("isLoggedIn", true);

      // ✅ Simpan status login ke AuthController juga (optional)
      await AuthController.saveLogin(
        UserModel(
          username: user["username"],
          role: user["role"],
          token: token,
        ),
      );

      // ✅ Navigasi ke dashboard sesuai role
      if (user["role"] == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardAdmin(
              username: user["username"],
              token: token,
            ),
          ),
        );
      } else if (user["role"] == "petugas") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardUser(
              username: user["username"],
              token: token,
              userId: user['_id'],
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username atau password salah")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    final horizontalPadding = isMobile ? 20.0 : (isTablet ? 40.0 : 60.0);
    final cardPadding = isMobile ? 24.0 : (isTablet ? 35.0 : 40.0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF512F), Color(0xFFF09819)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: isMobile ? 100.0 : 140.0,
                    height: isMobile ? 100.0 : 140.0,
                    child: Image.asset("assets/images/logo.png"),
                  ),
                  SizedBox(height: isMobile ? 16 : 24),
                  const Text(
                    "JALAN AMAN, KOTA NYAMAN",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: isMobile ? 30 : 50),
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? 500 : (isTablet ? 800 : 1200),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: cardPadding,
                      vertical: isMobile ? 30.0 : 50.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isMobile ? 20 : 30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _userController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            hintText: "Username",
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passController,
                          obscureText: _isPasswordHidden,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            hintText: "Password",
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () => setState(() {
                                _isPasswordHidden = !_isPasswordHidden;
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: Text(_isLoading ? "Memproses..." : "Login"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }
}