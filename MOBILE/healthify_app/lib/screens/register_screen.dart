import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Variabel untuk menyimpan pilihan form kesehatan (Tetap dipertahankan)
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
                    const Text('Analisis Kesehatan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF064E3B))),
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
                          backgroundColor: const Color(0xFF10B981),
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
        icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF10B981)),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, required IconData icon, required TextEditingController controller, bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade400),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background Elements (Lingkaran Hijau & Gambar Wanita)
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: const Icon(Icons.arrow_back, color: Color(0xFF064E3B)),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Header Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.spa, color: Color(0xFF059669), size: 30),
                            ),
                            const SizedBox(height: 20),
                            const Text('Selamat Datang di\nHealthify ✨', 
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF064E3B), height: 1.2)),
                            const SizedBox(height: 12),
                            const Text('Pendamping AI untuk perjalanan sehat & penurunan berat badan Anda.', 
                              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Image.network(
                          'https://cdn-icons-png.flaticon.com/512/4140/4140047.png', // Ganti dengan asset image wanita Anda
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Form Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Buat Akun Anda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF064E3B))),
                      const SizedBox(height: 4),
                      const Text('Langkah pertama menuju hidup lebih sehat!', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 16),
                      
                      // Progress Bar Simple
                      Row(
                        children: [
                          Expanded(child: Container(height: 4, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(2)))),
                          const SizedBox(width: 4),
                          Expanded(child: Container(height: 4, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(2)))),
                          const SizedBox(width: 4),
                          Expanded(child: Container(height: 4, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(2)))),
                          const SizedBox(width: 4),
                          Expanded(child: Container(height: 4, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(2)))),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      _buildTextField(hint: 'Nama Lengkap', icon: Icons.person_outline, controller: _nameController),
                      _buildTextField(hint: 'Email', icon: Icons.email_outlined, controller: _emailController),
                      _buildTextField(hint: 'Password', icon: Icons.lock_outline, controller: _passwordController, isPassword: true),
                      
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                          const SizedBox(width: 8),
                          Text('Minimal 8 karakter', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          const SizedBox(width: 16),
                          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                          const SizedBox(width: 8),
                          Text('Huruf & angka', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _showHealthProfilePopup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Lanjutkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Footer Features Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFooterItem(Icons.verified_user_outlined, 'Aman &\nTerpercaya'),
                      _buildFooterItem(Icons.health_and_safety_outlined, 'Dibuat\noleh Ahli'),
                      _buildFooterItem(Icons.track_changes, 'Hasil\nNyata'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF064E3B), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFD1FAE5).withOpacity(0.5), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF059669), size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF064E3B))),
      ],
    );
  }
}