import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ================= UTUH: CONTROLLER ASLI ANDA =================
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  // ================= UTUH: VARIABEL KESEHATAN ASLI ANDA =================
  String? _polaMakan;
  String? _jamMakan;
  String? _ngemil;
  String? _gula;
  String? _aktivitas;
  String? _tidur;
  String? _stres;
  String? _riwayat;
  String? _penyakit;

  String _hitungKlasifikasiRisiko() {
    int skorRisiko = 0;
    if (_jamMakan == 'Di atas jam 20:00') skorRisiko += 2;
    if (_ngemil == 'Sering (Tinggi Kalori/Manis)') skorRisiko += 2;
    if (_gula == 'Tinggi (>2x sehari)') skorRisiko += 2;
    if (_aktivitas == 'Jarang gerak (Sedentary)') skorRisiko += 2;
    if (_tidur == 'Kurang (< 5 jam)') skorRisiko += 1;
    if (_riwayat == 'Ya, ada riwayat obesitas') skorRisiko += 2;
    if (_penyakit == 'Diabetes' || _penyakit == 'Hipertensi' || _penyakit == 'Kolesterol') skorRisiko += 3;

    if (skorRisiko >= 8) return 'Risiko Obesitas: Tinggi (Prioritas P1)';
    if (skorRisiko >= 4) return 'Risiko Obesitas: Sedang (Prioritas P2)';
    return 'Risiko Obesitas: Rendah (Pencegahan)';
  }

  void _submitDataToBackend() async {
    if (_polaMakan == null || _jamMakan == null || _aktivitas == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap lengkapi semua pilihan!'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    String hasilKlasifikasi = _hitungKlasifikasiRisiko();

    Map<String, String> healthDataToSend = {
      'pola_makan': _polaMakan ?? '',
      'jam_makan': _jamMakan ?? '',
      'ngemil': _ngemil ?? '',
      'gula': _gula ?? '',
      'aktivitas': _aktivitas ?? '',
      'tidur': _tidur ?? '',
      'stres': _stres ?? '',
      'riwayat': _riwayat ?? '',
      'penyakit': _penyakit ?? '',
      'klasifikasi_risiko': hasilKlasifikasi,
    };

    final result = await ApiService.registerUser(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      healthDataToSend,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi Sukses! Silakan Login.'), backgroundColor: Colors.green));
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.redAccent));
    }
  }

  void _showHealthProfilePopup() {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi Nama, Email, dan Password dulu!'), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.all(24),
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
                child: Column(
                  children: [
                    const Text('Analisis Kesehatan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF143C3D))),
                    const SizedBox(height: 8),
                    const Text('Pilih kebiasaan harianmu:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDropdown('Pola Makan Harian', ['1-2x sehari', '3x sehari', '>3x sehari (Sering)'], _polaMakan, (val) => setModalState(() => _polaMakan = val)),
                            _buildDropdown('Jam Makan Terakhir', ['Sebelum 18:00', '18:00 - 20:00', 'Di atas jam 20:00'], _jamMakan, (val) => setModalState(() => _jamMakan = val)),
                            _buildDropdown('Kebiasaan Ngemil', ['Jarang', 'Kadang-kadang', 'Sering (Tinggi Kalori/Manis)'], _ngemil, (val) => setModalState(() => _ngemil = val)),
                            _buildDropdown('Konsumsi Gula', ['Rendah (Pilih Air Putih)', 'Sedang (1x manis/hari)', 'Tinggi (>2x sehari)'], _gula, (val) => setModalState(() => _gula = val)),
                            _buildDropdown('Aktivitas Fisik', ['Jarang gerak (Sedentary)', 'Ringan (1-2x seminggu)', 'Aktif (Rutin Olahraga)'], _aktivitas, (val) => setModalState(() => _aktivitas = val)),
                            _buildDropdown('Kualitas Tidur', ['Kurang (< 5 jam)', 'Cukup (6-8 jam)', 'Lebih (> 8 jam)'], _tidur, (val) => setModalState(() => _tidur = val)),
                            _buildDropdown('Tingkat Stres', ['Rendah', 'Sedang', 'Tinggi'], _stres, (val) => setModalState(() => _stres = val)),
                            _buildDropdown('Riwayat Keluarga Obesitas', ['Tidak ada', 'Ya, ada riwayat obesitas'], _riwayat, (val) => setModalState(() => _riwayat = val)),
                            _buildDropdown('Penyakit Penyerta', ['Tidak Ada', 'Diabetes', 'Hipertensi', 'Kolesterol', 'Kombinasi / Lainnya'], _penyakit, (val) => setModalState(() => _penyakit = val)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () {
                          setModalState(() => _isLoading = true);
                          _submitDataToBackend();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FA0A1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Kirim Analisis & Daftar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                    )
                  ],
                ),
              );
            }
          ),
        );
      },
    );
  }

  Widget _buildDropdown(String title, List<String> options, String? currentValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        isExpanded: true,
        hint: Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        items: options.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: onChanged,
        icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF4FA0A1)),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  // ================= TAMPILAN BARU: l1.png SEBAGAI BACKGROUND PENUH =================
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // DISINI KUNCINYA: Gambar l1.png diset penuh menutup seluruh background layar
        decoration: const BoxDecoration(
          color: Color(0xFF63C1C2), // Jaga-jaga jika gambar telat dimuat
          image: DecorationImage(
            image: AssetImage('assets/images/l1.png'),
            fit: BoxFit.cover, // Menutup penuh seluruh layar dari ujung ke ujung
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Spacer transparan agar kontainer form putih turun ke bawah mirip login asli
                SizedBox(height: screenHeight * 0.40),

                // Kontainer Form Putih Utama
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Healthify⁺',
                        style: TextStyle(
                          color: Color(0xFF143C3D),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFF143C3D),
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Field Nama Lengkap
                      const Text(
                        'Nama Lengkap',
                        style: TextStyle(
                          color: Color(0xFF143C3D),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Color(0xFF143C3D), fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            hintText: 'Enter your name',
                            hintStyle: TextStyle(color: Colors.black26),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Field Email
                      const Text(
                        'Email',
                        style: TextStyle(
                          color: Color(0xFF143C3D),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Color(0xFF143C3D), fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(color: Colors.black26),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Field Password
                      const Text(
                        'Password',
                        style: TextStyle(
                          color: Color(0xFF143C3D),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Color(0xFF143C3D), fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.black26,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tombol Sign Up Utama
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _showHealthProfilePopup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FA0A1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Footer Link Kembali ke Sign In
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? ", style: TextStyle(color: Color(0xFF143C3D))),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                "Sign In!",
                                style: TextStyle(
                                  color: Color(0xFF143C3D),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}