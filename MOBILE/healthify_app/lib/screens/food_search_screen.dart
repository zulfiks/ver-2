import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FoodSearchScreen extends StatefulWidget {
  final int userId;

  const FoodSearchScreen({super.key, required this.userId});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  List<dynamic> _databaseFoods = [];
  List<dynamic> _filteredFoods = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFoodsFromDatabase();
  }

  Future<void> _fetchFoodsFromDatabase() async {
    final foods = await ApiService.getFoods();
    if (mounted) {
      setState(() {
        _databaseFoods = foods;
        _filteredFoods = foods;
        _isLoading = false;
      });
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredFoods = _databaseFoods.where((food) {
        String nama = food['name']?.toString().toLowerCase() ?? '';
        return nama.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5).withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10)
                            ],
                          ),
                          child: const Icon(Icons.arrow_back, color: Color(0xFF064E3B)),
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cari Makanan',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF064E3B)),
                          ),
                          Text(
                            'Catat asupan nutrisimu hari ini ✨',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterSearch,
                      decoration: InputDecoration(
                        hintText: 'Ketik "Nasi Padang", "Bakso"...',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Food List
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Color(0xFF10B981)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: _filteredFoods.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _filteredFoods.length) {
                              return _buildTipsCard();
                            }

                            final food = _filteredFoods[index];
                            return _buildFoodCard(food);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    String nama = food['nama_makanan']?.toString() ?? 'Makanan';
    String kkal = food['kalori_standar']?.toString() ?? '0';
    String porsi = food['satuan_standar']?.toString() ?? '1 Porsi';
    
    String label = "Tinggi Protein";
    if (nama.toLowerCase().contains("pecel")) label = "Tinggi Serat";
    if (nama.toLowerCase().contains("es")) label = "Rendah Kalori";
    if (nama.toLowerCase().contains("mie")) label = "Energi Seimbang";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.restaurant_menu, color: Color(0xFF10B981), size: 35),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text('$kkal kkal',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.scale, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(porsi,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 10,
                        fontWeight: FontWeight.w800),
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showPortionCalculator(food),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tips Sehat ✨',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  'Gunakan porsi yang tepat agar asupan kalori tetap terjaga sesuai target harianmu.',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.lightbulb_circle, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  void _showPortionCalculator(Map<String, dynamic> food) {
    double selectedPortion = 1.0;
    String namaMakanan = food['nama_makanan']?.toString() ?? 'Makanan Tidak Diketahui';
    int kaloriStandar = int.tryParse(food['kalori_standar']?.toString() ?? '0') ?? 0;
    String satuanStandar = food['satuan_standar']?.toString() ?? 'Porsi';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          int totalCalories = (kaloriStandar * selectedPortion).round();
          Color calColor = totalCalories > 800
              ? const Color(0xFFEF4444)
              : const Color(0xFF10B981);

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 24),
                Text(namaMakanan,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF064E3B))),
                Text('Standar: $kaloriStandar kkal / $satuanStandar',
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 24),
                const Text('Berapa banyak yang kamu makan?',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _portionIconButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (selectedPortion > 0.5) {
                            setModalState(() => selectedPortion -= 0.5);
                          }
                        }),
                    Column(
                      children: [
                        Text('${selectedPortion}x',
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF064E3B))),
                        const Text('Porsi',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    _portionIconButton(
                        icon: Icons.add,
                        onTap: () {
                          if (selectedPortion < 5.0) {
                            setModalState(() => selectedPortion += 0.5);
                          }
                        }),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPresetChip('½ Porsi', 0.5, selectedPortion,
                        (val) => setModalState(() => selectedPortion = val)),
                    _buildPresetChip('1 Porsi', 1.0, selectedPortion,
                        (val) => setModalState(() => selectedPortion = val)),
                    _buildPresetChip('2 Porsi', 2.0, selectedPortion,
                        (val) => setModalState(() => selectedPortion = val)),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: calColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: calColor.withValues(alpha: 0.2))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Kalori',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('$totalCalories kkal',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: calColor)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      // 1. Tampilkan Loading Indicator
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (c) => const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF10B981))));

                      // 2. Jalankan fungsi API
                      bool isSuccess = await ApiService.saveFoodLog(
                          widget.userId,
                          food['id'],
                          selectedPortion,
                          totalCalories);

                      if (!context.mounted) return;
                      
                      // 3. TUTUP LOADING DIALOG (Baik sukses atau gagal, loading harus ditutup)
                      Navigator.pop(context); 

                      if (isSuccess) {
                        // 4. TUTUP BOTTOM SHEET KALKULATOR PORSI
                        Navigator.pop(context); 

                        // 5. Tampilkan snackbar sukses
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Berhasil mencatat $namaMakanan! ✨'),
                            backgroundColor: const Color(0xFF10B981),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        // 6. Tampilkan snackbar gagal jika API bermasalah
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal menyimpan ke jurnal. Coba lagi! ❌'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Simpan ke Jurnal',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _portionIconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDCFCE7))),
        child: Icon(icon, color: const Color(0xFF10B981), size: 28),
      ),
    );
  }

  Widget _buildPresetChip(String label, double value, double currentValue,
      Function(double) onSelected) {
    bool isSelected = currentValue == value;
    return ChoiceChip(
      label: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.green[800])),
      selected: isSelected,
      onSelected: (selected) => onSelected(value),
      selectedColor: const Color(0xFF10B981),
      backgroundColor: const Color(0xFFF0FDF4),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}