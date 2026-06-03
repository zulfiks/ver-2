import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ================= ACTION LOGIN (TIDAK BERUBAH) =================
  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Email dan Password tidak boleh kosong', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.loginUser(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(userData: result['data']),
        ),
      );
    } else {
      _showSnackBar(result['message'], Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF63C1C2), // Warna fallback tema l1.png
      body: SafeArea(
        top: false, // Membiarkan background gambar naik penuh sampai status bar atas
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxHeight = constraints.maxHeight;

            return Stack(
              children: [
                // 1. BACKGROUND IMAGE UTAMA (Mengunci porsi atas layar)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: maxHeight * 0.58, // Sesuai porsi ruang l1.png agar karakter orang berlari terlihat jelas
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/l1.png'),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),

                // 2. FORM KONTEN LOGIN (Fix Terkunci, Anti-Scroll)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 28, // Sedikit diperpendek jarak atasnya agar padat
                      bottom: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul Aplikasi (Warna Khas Hijau Gelap l2.png)
                        const Text(
                          'Healthify⁺',
                          style: TextStyle(
                            color: Color(0xFF143C3D),
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color(0xFF143C3D),
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 20), // Jarak dipendekkan agar fit

                        // Input Field Email
                        const Text(
                          'Email',
                          style: TextStyle(
                            color: Color(0xFF143C3D),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 50, // Tinggi input dikurangi sedikit demi efisiensi ruang
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              color: Color(0xFF143C3D),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your email',
                              hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Input Field Password
                        const Text(
                          'Password',
                          style: TextStyle(
                            color: Color(0xFF143C3D),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              color: Color(0xFF143C3D),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your password',
                              hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              suffixIcon: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.black38,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28), // Diperpendek agar pas mengunci layar

                        // Tombol Sign In Solid Teal Khas l2.png
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FA0A1), // Hex teal akurat tombol l2.png
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Link Menuju Register Screen (DIPERTAHANKAN UTUH & WARNA DISESUAIKAN)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Color(0xFF143C3D),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Create one!',
                                style: TextStyle(
                                  color: Color(0xFF143C3D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}