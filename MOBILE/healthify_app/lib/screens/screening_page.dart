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

  // BODY DATA
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _waistCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController();

  String _gender = 'male';

  // STEP
  int _currentStep = 0;

  // LIFESTYLE
  String _activityLevel = '';
  String _sweetDrink = '';
  String _fastFood = '';
  String _sleepDuration = '';
  String _sittingDuration = '';
  String _fatigue = '';

  // CONDITIONS
  List<String> _conditions = [];

  bool _isSubmitting = false;

  // =========================
  // SUBMIT SCREENING
  // =========================

  Future<void> _submitScreening() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/screening'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({

          // BODY
          'weight': double.tryParse(_weightCtrl.text) ?? 0,
          'height': double.tryParse(_heightCtrl.text) ?? 0,
          'waist': double.tryParse(_waistCtrl.text) ?? 0,
          'age': int.tryParse(_ageCtrl.text) ?? 0,
          'gender': _gender,

          // LIFESTYLE
          'activity_level': _activityLevel,
          'sweet_drink': _sweetDrink,
          'fast_food': _fastFood,
          'sleep_duration': _sleepDuration,
          'sitting_duration': _sittingDuration,
          'fatigue': _fatigue,

          // CONDITIONS
          'conditions': _conditions,
        }),
      );

      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      // =========================
      // SUCCESS
      // =========================

      if (response.statusCode == 200) {

        final decoded = jsonDecode(response.body);

        final result = decoded['data'];

        if (!mounted) return;

     showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) {

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),

        // =========================
        // FIX OVERFLOW
        // =========================

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Icon(
                Icons.health_and_safety_rounded,
                color: Color(0xFF10B981),
                size: 70,
              ),

              const SizedBox(height: 20),

              const Text(
                "Hasil Analisis Kesehatan",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              _buildResultCard(
                "BMI",
                "${result['imt_value']} (${result['imt_classification']})",
              ),

              const SizedBox(height: 12),

              _buildResultCard(
                "Tingkat Risiko",
                result['overall_risk']?.toString() ?? '-',
              ),

              const SizedBox(height: 12),

              _buildResultCard(
                "Obesitas Sentral",
                result['central_obesity_status']?.toString() ?? '-',
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "AI sedang menyiapkan rekomendasi personal berdasarkan hasil screening kamu.",
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {

                    Navigator.pop(context);
                    Navigator.pop(context);

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Selesai",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
);

      } else {

        // =========================
        // FAILED RESPONSE
        // =========================

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Gagal menyimpan data (${response.statusCode})",
            ),
          ),
        );
      }

    } catch (e) {

      // =========================
      // ERROR
      // =========================

      debugPrint("ERROR SCREENING: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Terjadi error: $e",
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          _isSubmitting = false;
        });

      }
    }
  }

  // =========================
  // RESULT CARD
  // =========================

  Widget _buildResultCard(String title, String value) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF9FAFB),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // CHOICE QUESTION
  // =========================

  Widget _buildChoiceQuestion(
    String title,
    List<String> options,
    String selected,
    Function(String) onSelect,
  ) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.only(
            top: 18,
            bottom: 10,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {

            final isSelected = selected == option;

            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              selectedColor: const Color(0xFF10B981),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w500,
              ),
              onSelected: (_) => onSelect(option),
            );

          }).toList(),
        ),
      ],
    );
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF9FAFB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text(
          "Health Screening",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Form(
        key: _formKey,
        child: Stepper(

          currentStep: _currentStep,

          onStepContinue: () {

            if (_currentStep < 2) {

              setState(() {
                _currentStep++;
              });

            } else {

              _submitScreening();

            }
          },

          onStepCancel: () {

            if (_currentStep > 0) {

              setState(() {
                _currentStep--;
              });

            }
          },

          controlsBuilder: (context, details) {

            return Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Row(
                children: [

                  Expanded(
                    child: ElevatedButton(

                      onPressed: _isSubmitting
                          ? null
                          : details.onStepContinue,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      child: _isSubmitting
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(

                              _currentStep == 2
                                  ? "Analisis Sekarang"
                                  : "Lanjut",

                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  if (_currentStep > 0) ...[

                    const SizedBox(width: 10),

                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text("Kembali"),
                    ),
                  ]
                ],
              ),
            );
          },

          steps: [

            // =========================
            // STEP 1
            // =========================

            Step(
              title: const Text("Data Tubuh"),
              isActive: _currentStep >= 0,

              content: Column(
                children: [

                  TextFormField(
                    controller: _ageCtrl,
                    keyboardType: TextInputType.number,

                    decoration: InputDecoration(
                      labelText: "Umur",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _weightCtrl,
                    keyboardType: TextInputType.number,

                    decoration: InputDecoration(
                      labelText: "Berat Badan (kg)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _heightCtrl,
                    keyboardType: TextInputType.number,

                    decoration: InputDecoration(
                      labelText: "Tinggi Badan (cm)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _waistCtrl,
                    keyboardType: TextInputType.number,

                    decoration: InputDecoration(
                      labelText: "Lingkar Pinggang (cm)",
                      helperText: "Ukur sejajar pusar",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(

                    value: _gender,

                    decoration: InputDecoration(
                      labelText: "Jenis Kelamin",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    items: const [

                      DropdownMenuItem(
                        value: 'male',
                        child: Text("Male"),
                      ),

                      DropdownMenuItem(
                        value: 'female',
                        child: Text("Female"),
                      ),
                    ],

                    onChanged: (v) {

                      setState(() {
                        _gender = v!;
                      });

                    },
                  ),
                ],
              ),
            ),

            // =========================
            // STEP 2
            // =========================

            Step(
              title: const Text("Gaya Hidup"),
              isActive: _currentStep >= 1,

              content: Column(
                children: [

                  _buildChoiceQuestion(
                    "Seberapa sering olahraga?",
                    ["Jarang", "Kadang", "Rutin"],
                    _activityLevel,
                    (v) {
                      setState(() {
                        _activityLevel = v;
                      });
                    },
                  ),

                  _buildChoiceQuestion(
                    "Seberapa sering minum manis?",
                    ["Sering", "Kadang", "Jarang"],
                    _sweetDrink,
                    (v) {
                      setState(() {
                        _sweetDrink = v;
                      });
                    },
                  ),

                  _buildChoiceQuestion(
                    "Seberapa sering makan fast food?",
                    ["Sering", "Kadang", "Jarang"],
                    _fastFood,
                    (v) {
                      setState(() {
                        _fastFood = v;
                      });
                    },
                  ),

                  _buildChoiceQuestion(
                    "Durasi tidur per hari?",
                    ["<5 jam", "6-7 jam", ">7 jam"],
                    _sleepDuration,
                    (v) {
                      setState(() {
                        _sleepDuration = v;
                      });
                    },
                  ),

                  _buildChoiceQuestion(
                    "Apakah kamu sering duduk terlalu lama?",
                    ["Ya", "Kadang", "Tidak"],
                    _sittingDuration,
                    (v) {
                      setState(() {
                        _sittingDuration = v;
                      });
                    },
                  ),

                  _buildChoiceQuestion(
                    "Apakah kamu sering cepat lelah?",
                    ["Ya", "Kadang", "Tidak"],
                    _fatigue,
                    (v) {
                      setState(() {
                        _fatigue = v;
                      });
                    },
                  ),
                ],
              ),
            ),

            // =========================
            // STEP 3
            // =========================

            Step(
              title: const Text("Riwayat Kesehatan"),
              isActive: _currentStep >= 2,

              content: Column(
                children: [

                  CheckboxListTile(
                    title: const Text("Hipertensi"),
                    value: _conditions.contains("hypertension"),

                    onChanged: (v) {

                      setState(() {

                        if (v == true) {
                          _conditions.add("hypertension");
                        } else {
                          _conditions.remove("hypertension");
                        }

                      });
                    },
                  ),

                  CheckboxListTile(
                    title: const Text("Diabetes"),
                    value: _conditions.contains("diabetes"),

                    onChanged: (v) {

                      setState(() {

                        if (v == true) {
                          _conditions.add("diabetes");
                        } else {
                          _conditions.remove("diabetes");
                        }

                      });
                    },
                  ),

                  CheckboxListTile(
                    title: const Text("Kolesterol"),
                    value: _conditions.contains("cholesterol"),

                    onChanged: (v) {

                      setState(() {

                        if (v == true) {
                          _conditions.add("cholesterol");
                        } else {
                          _conditions.remove("cholesterol");
                        }

                      });
                    },
                  ),

                  CheckboxListTile(
                    title: const Text("Nyeri Sendi"),
                    value: _conditions.contains("joint_pain"),

                    onChanged: (v) {

                      setState(() {

                        if (v == true) {
                          _conditions.add("joint_pain");
                        } else {
                          _conditions.remove("joint_pain");
                        }

                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}