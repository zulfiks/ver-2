import 'package:flutter/material.dart';
import 'food_search_screen.dart';
import 'screening_page.dart';
import 'login_screen.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const DashboardScreen({super.key, this.userData});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalKaloriHariIni = 0;
  List<dynamic> _riwayatMakanan = [];
  bool _isLoadingLogs = true;
  Map<String, dynamic>? _latestScreening;

  // Variabel pesan AI yang sekarang akan kita buat dinamis
  String _aiSmartMessage = "Menganalisis pola makanmu...";

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _fetchDashboardData();
    } else {
      _isLoadingLogs = false;
      _aiSmartMessage = "Selamat Datang! Silakan login untuk fitur lengkap.";
    }
  }

  void _handleProtectedNavigation(Widget targetScreen) async {
    if (widget.userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Wajib Login untuk akses fitur ini!"),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      );

      // =========================
      // REFRESH DASHBOARD
      // =========================

      await _fetchDashboardData();

      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _fetchDashboardData() async {
    if (widget.userData == null) return;

    setState(() => _isLoadingLogs = true);

    final int userId = widget.userData!['id'];

    try {
      final logData = await ApiService.getTodayFoodLogs(userId);

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/analysis/$userId'),
      );

      Map<String, dynamic>? screeningData;

      String alertMessage = "";
      String reminderMessage = "";

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        alertMessage = data['alert_message'] ?? "";
        reminderMessage = data['reminder_message'] ?? "";

        // =========================
        // AMBIL SCREENING TERBARU
        // =========================

        screeningData = data['latest_screening'];
      }

      if (mounted) {
        setState(() {
          // =========================
          // FOOD LOG
          // =========================

          if (logData != null && logData['success'] == true) {
            _totalKaloriHariIni =
                int.tryParse(logData['total_kalori'].toString()) ?? 0;

            _riwayatMakanan = logData['logs'];
          }

          // =========================
          // SCREENING AI PLAN
          // =========================

          _latestScreening = screeningData;

          // =========================
          // SMART MESSAGE
          // =========================

          if (_totalKaloriHariIni > 1800) {
            _aiSmartMessage = "Asupan kalori hari ini sudah melampaui target.";
          } else if (alertMessage.isNotEmpty) {
            _aiSmartMessage = alertMessage;
          } else {
            _aiSmartMessage = reminderMessage.isNotEmpty
                ? reminderMessage
                : "Pola makanmu sudah cukup baik hari ini.";
          }

          _isLoadingLogs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiSmartMessage = "Gagal memuat analisis kesehatan.";

          _isLoadingLogs = false;
        });
      }
    }
  }

  Widget _buildCard({required Widget child, Color bgColor = Colors.white}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPlanItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF10B981)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = widget.userData != null;
    String userName = isLoggedIn ? widget.userData!['name'] : 'Tamu';
    String klasifikasiRisiko = isLoggedIn
        ? (widget.userData!['klasifikasi_risiko'] ?? 'Belum Dianalisis')
        : 'Login untuk Cek Risiko';

    int targetKalori = 1800; // Target kalori default [cite: 575]
    double progressKalori = _totalKaloriHariIni / targetKalori;
    if (progressKalori > 1.0) progressKalori = 1.0;

    Color cardRisikoColor =
        klasifikasiRisiko.contains('Tinggi') || klasifikasiRisiko.contains('II')
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFFFFBEB);
    Color iconRisikoColor =
        klasifikasiRisiko.contains('Tinggi') || klasifikasiRisiko.contains('II')
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);

    // AI PERSONAL WEIGHT LOSS PLAN (Target, Aktivitas, Menu Lokal, Habit)
    String targetMingguan =
        _latestScreening?['weekly_target'] ?? 'Belum ada rekomendasi';

    String aktivitasTarget =
        _latestScreening?['activity_target'] ?? 'Belum ada rekomendasi';

    String menuLokal =
        _latestScreening?['food_recommendation'] ?? 'Belum ada rekomendasi';

    String habitKecil =
        _latestScreening?['habit_recommendation'] ?? 'Belum ada rekomendasi';
    if (klasifikasiRisiko == "Normal") {
      targetMingguan = "Pertahankan berat badan ideal";
      aktivitasTarget = "Olahraga intensitas sedang 30 menit [cite: 685]";
      menuLokal = "Gado-gado & Telur Rebus";
      habitKecil = "Minum air putih sebelum makan";
    } else if (klasifikasiRisiko.contains("II")) {
      targetMingguan = "Fokus penurunan lemak bertahap [cite: 568]";
      aktivitasTarget = "Latihan aerobik ringan 45 menit [cite: 708]";
      menuLokal = "Soto Ayam & Tempe Bacem";
      habitKecil = "Ganti cemilan manis dengan buah";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, $userName ✨',
              style: const TextStyle(
                color: Color(0xFF064E3B),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Text(
                _aiSmartMessage,
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (!isLoggedIn)
            IconButton(
              icon: const Icon(Icons.login, color: Color(0xFF10B981)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        color: const Color(0xFF10B981),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _handleProtectedNavigation(const ScreeningPage()),
                child: _buildCard(
                  bgColor: const Color(0xFF064E3B),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.health_and_safety,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Skrining Obesitas',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Berdasarkan KMK No. 509 Tahun 2025',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildCard(
                bgColor: cardRisikoColor,
                child: Row(
                  children: [
                    Icon(Icons.show_chart, color: iconRisikoColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            klasifikasiRisiko,
                            style: TextStyle(
                              color: iconRisikoColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            'Berdasarkan data kesehatanmu',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Personal Plan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF064E3B),
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Minggu 1',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: Color(0xFF10B981),
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPlanItem(
                      Icons.track_changes,
                      'Target Mingguan',
                      targetMingguan,
                    ),
                    _buildPlanItem(
                      Icons.directions_walk,
                      'Target Aktivitas',
                      aktivitasTarget,
                    ),
                    _buildPlanItem(
                      Icons.restaurant,
                      'Rekomendasi Menu Lokal',
                      menuLokal,
                    ),
                    _buildPlanItem(
                      Icons.tips_and_updates,
                      'Kebiasaan Baru',
                      habitKecil,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kalori Hari Ini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF064E3B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$_totalKaloriHariIni kkal',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        Text(
                          '/ $targetKalori kkal',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressKalori,
                        minHeight: 12,
                        backgroundColor: const Color(0xFFECFDF5),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _totalKaloriHariIni > targetKalori
                              ? Colors.red
                              : const Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Catatan Makanan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _isLoadingLogs
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF10B981),
                            ),
                          )
                        : _riwayatMakanan.isEmpty
                        ? const Text(
                            'Belum ada makanan dicatat.',
                            style: TextStyle(color: Colors.grey),
                          )
                        : Column(
                            children: _riwayatMakanan
                                .map(
                                  (log) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          log['food_name'] ?? 'Makanan',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${log['total_calories']} kkal',
                                          style: const TextStyle(
                                            color: Color(0xFF10B981),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleProtectedNavigation(
                          FoodSearchScreen(
                            userId: isLoggedIn ? widget.userData!['id'] : 0,
                          ),
                        ),
                        icon: const Icon(
                          Icons.search,
                          color: Color(0xFF10B981),
                        ),
                        label: const Text(
                          'Cari & Tambah Makanan',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF10B981)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleProtectedNavigation(const Placeholder()),
        backgroundColor: const Color(0xFF064E3B),
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text(
          'Chat AI Healthify',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
