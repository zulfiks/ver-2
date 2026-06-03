import 'package:flutter/material.dart';
import 'dart:math' as math;
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
  List<dynamic> _leaderboardData = []; 
  bool _isLoading = true;
  Map<String, dynamic>? _latestScreening;
  String _aiSmartMessage = "Menganalisis pola makanmu...";

  // Target Nutrisi Default Makro
  final int _targetKalori = 1800;
  final int _proteinTarget = 60;
  final int _fatTarget = 50;
  final int _carbsTarget = 200;

  // Nilai Makro Riil (Hasil kalkulasi dari log makanan hari ini)
  int _proteinHariIni = 0;
  int _fatHariIni = 0;
  int _carbsHariIni = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (widget.userData == null) {
      setState(() {
        _isLoading = false;
        _aiSmartMessage = "Selamat Datang! Silakan login untuk fitur lengkap.";
      });
      return;
    }

    setState(() => _isLoading = true);
    final int userId = widget.userData!['id'];

    try {
      // 1. Ambil Log Makanan Hari Ini dari ApiService
      final logData = await ApiService.getTodayFoodLogs(userId);
      
      // 2. Ambil Peringatan & Reminder Khusus dari Controller Laravel
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/food-logs/today/$userId'),
      );

      // 3. Ambil data leaderboard top 5 riil dari backend
      final fetchedLeaderboard = await ApiService.getTopLeaderboard();

      Map<String, dynamic>? screeningData;
      String alertMessage = "";
      String reminderMessage = "";

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        alertMessage = data['alert_message'] ?? "";
        reminderMessage = data['reminder_message'] ?? "";
        screeningData = data['latest_screening'];
      }

      if (mounted) {
        setState(() {
          if (logData != null && logData['success'] == true) {
            _totalKaloriHariIni = int.tryParse(logData['total_kalori'].toString()) ?? 0;
            _riwayatMakanan = logData['logs'] ?? [];
            
            // Mengkalkulasi Makronutrisi secara riil dan aman dari Null
            _proteinHariIni = 0;
            _fatHariIni = 0;
            _carbsHariIni = 0;
            
            for (var log in _riwayatMakanan) {
              double portion = double.tryParse(log['portion']?.toString() ?? '1.0') ?? 1.0;
              
              int proteinBase = int.tryParse(log['protein']?.toString() ?? '0') ?? 0;
              int fatBase = int.tryParse(log['fat']?.toString() ?? '0') ?? 0;
              int carbsBase = int.tryParse(log['carbs']?.toString() ?? '0') ?? 0;

              _proteinHariIni += (proteinBase * portion).round();
              _fatHariIni += (fatBase * portion).round();
              _carbsHariIni += (carbsBase * portion).round();
            }
          }
          
          _latestScreening = screeningData;
          _leaderboardData = fetchedLeaderboard;

          if (alertMessage.isNotEmpty) {
            _aiSmartMessage = alertMessage;
          } else if (_totalKaloriHariIni > _targetKalori) {
            _aiSmartMessage = "Asupan kalori hari ini sudah melampaui batas target harianmu.";
          } else if (_latestScreening != null && _latestScreening!['imt_classification'] != null) {
            _aiSmartMessage = "Status IMT terakhirmu: ${_latestScreening!['imt_classification']}. Jaga pola makan ya!";
          } else {
            _aiSmartMessage = reminderMessage.isNotEmpty ? reminderMessage : "Pola makanmu sudah cukup baik hari ini.";
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiSmartMessage = "Gagal memuat analisis data dari server.";
          _isLoading = false;
        });
      }
    }
  }

  void _handleProtectedNavigation(Widget targetScreen) {
    if (widget.userData == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen)).then((_) => _fetchDashboardData());
    }
  }

  @override
  Widget build(BuildContext context) {
    String userName = widget.userData?['name'] ?? 'Tamu';
    String statusRisiko = widget.userData?['klasifikasi_risiko'] ?? 'Normal';
    
    // BACA LINK FOTO PROFIL DARI DATABASE LARAVEL
    String? profilePicture = widget.userData?['profile_picture'];

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF14B8A6)))
            : RefreshIndicator(
                onRefresh: _fetchDashboardData,
                color: const Color(0xFF14B8A6),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER PROFILE DINAMIS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hai, ${userName.toLowerCase()}',
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                              const Text('Kamu hebat hari ini',
                                  style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF14B8A6).withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: const Color(0xFF14B8A6),
                              // RENDER FOTO NETWORKING JIKA URL SUDAH TERSEDIA DI DATABASE
                              backgroundImage: (profilePicture != null && profilePicture.isNotEmpty)
                                  ? NetworkImage(profilePicture)
                                  : null,
                              child: (profilePicture == null || profilePicture.isEmpty)
                                  ? Text(
                                      userName[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                                    )
                                  : null,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),

                      // LEADERBOARD CARD
                      _buildLeaderboardCard(userName),
                      const SizedBox(height: 24),

                      // CALORIE & MACRO CARD
                      _buildCalorieCard(),
                      const SizedBox(height: 24),

                      // RISIKO BANNER
                      _buildRiskBanner(statusRisiko),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF14B8A6),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Food Log'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Community'),
        ],
        onTap: (index) {
          if (index == 1) {
            _handleProtectedNavigation(FoodSearchScreen(userId: widget.userData?['id'] ?? 0));
          } else if (index == 2) {
            _handleProtectedNavigation(const ScreeningPage());
          }
        },
      ),
    );
  }

  Widget _buildLeaderboardCard(String userName) {
    final List<dynamic> sortedUsers = List.from(_leaderboardData);
    sortedUsers.sort((a, b) => (int.tryParse(b['skor']?.toString() ?? '0') ?? 0)
        .compareTo(int.tryParse(a['skor']?.toString() ?? '0') ?? 0));

    Map<String, dynamic> p1 = sortedUsers.isNotEmpty ? sortedUsers[0] : {'name': 'User 1', 'skor': 0};
    Map<String, dynamic> p2 = sortedUsers.length > 1 ? sortedUsers[1] : {'name': 'User 2', 'skor': 0};
    Map<String, dynamic> p3 = sortedUsers.length > 2 ? sortedUsers[2] : {'name': 'User 3', 'skor': 0};
    Map<String, dynamic> p4 = sortedUsers.length > 3 ? sortedUsers[3] : {'name': 'User 4', 'skor': 0};
    Map<String, dynamic> p5 = sortedUsers.length > 4 ? sortedUsers[4] : {'name': 'User 5', 'skor': 0};

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF14B8A6), 
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  'Top 5 Minggu Ini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Text(
                      'Lihat Semua',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 11),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPodiumItem(
                user: p5,
                rank: '5',
                podiumHeight: 40,
                podiumColor: Colors.white.withValues(alpha: 0.75),
                textColor: const Color(0xFF14B8A6),
                hasGlow: false,
              ),
              _buildPodiumItem(
                user: p3,
                rank: '3',
                podiumHeight: 65,
                podiumColor: Colors.white.withValues(alpha: 0.9),
                textColor: const Color(0xFF14B8A6),
                hasGlow: false,
              ),
              _buildPodiumItem(
                user: p1,
                rank: '1',
                podiumHeight: 100,
                podiumColor: const Color(0xFFFBBF24), 
                textColor: Colors.white,
                hasGlow: true,
              ),
              _buildPodiumItem(
                user: p2,
                rank: '2',
                podiumHeight: 80,
                podiumColor: Colors.white.withValues(alpha: 0.9),
                textColor: const Color(0xFF14B8A6),
                hasGlow: false,
              ),
              _buildPodiumItem(
                user: p4,
                rank: '4',
                podiumHeight: 50,
                podiumColor: Colors.white.withValues(alpha: 0.75),
                textColor: const Color(0xFF14B8A6),
                hasGlow: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required Map<String, dynamic> user,
    required String rank,
    required double podiumHeight,
    required Color podiumColor,
    required Color textColor,
    required bool hasGlow,
  }) {
    String name = user['name'] ?? '-';
    String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: rank == '1' ? const Color(0xFFFBBF24) : Colors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            rank,
            style: TextStyle(
              color: rank == '1' ? Colors.white : const Color(0xFF14B8A6),
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: 4),

        Container(
          width: rank == '1' ? 46 : 38,
          height: rank == '1' ? 46 : 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: rank == '1' ? const Color(0xFFFFF176) : Colors.white24,
              width: rank == '1' ? 2.5 : 1.5,
            ),
            boxShadow: hasGlow
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: CircleAvatar(
            backgroundColor: rank == '1' ? const Color(0xFFD97706) : Colors.black.withValues(alpha: 0.15),
            child: Text(
              initial,
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold, 
                fontSize: rank == '1' ? 13 : 11,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),

        SizedBox(
          width: 48, 
          child: Text(
            name.toLowerCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: rank == '1' ? 11 : 10,
              fontWeight: rank == '1' ? FontWeight.bold : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 5),

        Container(
          width: 48, 
          height: podiumHeight,
          decoration: BoxDecoration(
            color: podiumColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                '${user['skor'] ?? 0}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: rank == '1' ? 13 : 11,
                ),
              ),
              if (rank == '1') ...[
                const SizedBox(height: 2),
                const Icon(Icons.star_rounded, color: Colors.white, size: 12),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieCard() {
    double progress = _totalKaloriHariIni / _targetKalori;
    if (progress > 1.0) progress = 1.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        children: [
          const Text('Kalori Hari Ini', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(200, 100),
                painter: GaugePainter(progress: progress),
              ),
              Column(
                children: [
                  const SizedBox(height: 15),
                  Text('$_totalKaloriHariIni', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  const Text('cal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _macroItem(Icons.restaurant, "Protein", _proteinHariIni, _proteinTarget, Colors.orange),
              _macroItem(Icons.opacity, "Fat", _fatHariIni, _fatTarget, Colors.purple),
              _macroItem(Icons.grain, "Carbs", _carbsHariIni, _carbsTarget, Colors.green),
            ],
          )
        ],
      ),
    );
  }

  Widget _macroItem(IconData icon, String label, int current, int target, Color color) {
    double macroProgress = current / target;
    if (macroProgress > 1.0) macroProgress = 1.0;
    if (macroProgress < 0.0) macroProgress = 0.0;

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: 65,
          height: 6,
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: macroProgress,
            child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10))),
          ),
        ),
        const SizedBox(height: 6),
        Text('$current/$target g', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildRiskBanner(String status) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined, color: Color(0xFF14B8A6), size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Risiko Obesitas ($status)', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14B8A6), fontSize: 15)),
                const SizedBox(height: 2),
                Text(_aiSmartMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _handleProtectedNavigation(const ScreeningPage()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2DD4BF), 
              elevation: 0, 
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: const StadiumBorder()
            ),
            child: const Text('Screening', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          )
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double progress;
  GaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    final Paint trackPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final Paint progressPaint = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)]).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi, false, trackPaint);
    canvas.drawArc(rect, math.pi, math.pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}