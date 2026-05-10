import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class ScreeningPage extends StatefulWidget {
  const ScreeningPage({super.key});

  @override
  State<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends State<ScreeningPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _waistCtrl = TextEditingController();
  String _gender = 'male';
  bool _isSubmitting = false;

  Map<String, int> sarcF = {"strength": 0, "walking": 0, "rise": 0, "stairs": 0, "falls": 0};

  Future<void> _submitScreening() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    int totalSarc = sarcF.values.reduce((a, b) => a + b);

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/screening'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'weight': double.tryParse(_weightCtrl.text),
          'height': double.tryParse(_heightCtrl.text),
          'gender': _gender,
          'waist': double.tryParse(_waistCtrl.text),
          'sarc_f_score': totalSarc,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)['data'];
        
        if (!mounted) return;
        
        // DIALOG ANALISIS SESUAI PNPK 2025 [cite: 1348]
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Hasil Analisis Menkes 2025"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("IMT: ${result['imt_value']} (${result['imt_classification']}) [cite: 278]"),
                Text("Tingkat Risiko: ${result['risk_level']}"),
                Text("Status Lemak Perut: ${result['central_obesity_status']} [cite: 285]"),
                Text("Kondisi Otot: ${result['sarcopenia_status']} [cite: 493]"),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context, result); // Kembali & update dashboard
                },
                child: const Text("Selesai"),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan data")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Koneksi Gagal: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Skrining Obesitas")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text("Data Fisik [cite: 262]", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextFormField(
              controller: _weightCtrl, 
              decoration: const InputDecoration(labelText: "Berat Badan (kg)", border: OutlineInputBorder()), 
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _heightCtrl, 
              decoration: const InputDecoration(labelText: "Tinggi Badan (cm)", border: OutlineInputBorder()), 
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _waistCtrl, 
              decoration: const InputDecoration(labelText: "Lingkar Pinggang (cm) [cite: 279]", border: OutlineInputBorder()), 
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: "Jenis Kelamin", border: OutlineInputBorder()),
              items: const [DropdownMenuItem(value: 'male', child: Text("Laki-laki")), DropdownMenuItem(value: 'female', child: Text("Perempuan"))],
              onChanged: (v) => setState(() => _gender = v!),
            ),
            const Divider(height: 40),
            const Text("Kuesioner SARC-F (Skrining Otot) [cite: 491, 496]", style: TextStyle(fontWeight: FontWeight.bold)),
            _buildSarcQuestion("Kesulitan angkat beban 4.5kg?", "strength"),
            _buildSarcQuestion("Kesulitan berjalan?", "walking"),
            _buildSarcQuestion("Kesulitan bangun dari kursi?", "rise"),
            _buildSarcQuestion("Kesulitan naik tangga?", "stairs"),
            _buildSarcQuestion("Pernah jatuh?", "falls"),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitScreening,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.all(15)),
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("Simpan Hasil", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSarcQuestion(String title, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 15), child: Text(title)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [0, 1, 2].map((val) => Row(children: [Radio<int>(value: val, groupValue: sarcF[key], onChanged: (v) => setState(() => sarcF[key] = v!)), Text("$val")])).toList(),
        ),
      ],
    );
  }
}