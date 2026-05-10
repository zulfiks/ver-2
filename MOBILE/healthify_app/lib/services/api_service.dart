import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Gunakan 10.0.2.2 untuk Emulator Android. 
  // Jika pakai HP Fisik, ganti dengan IP WiFi laptopmu (misal: 192.168.1.10)
  static const String baseUrl = 'http://10.111.10.161:8000/api';

  // Ubah parameternya menjadi seperti ini
  static Future<Map<String, dynamic>> registerUser(
      String name, 
      String email, 
      String password, 
      Map<String, String> healthData) async {
    try {
      // Gabungkan data user dan data kesehatan menjadi satu JSON
      final Map<String, dynamic> requestBody = {
        'name': name,
        'email': email,
        'password': password,
      };
      requestBody.addAll(healthData); // Memasukkan semua data form kesehatan

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message'] ?? 'Gagal mendaftar'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan: $e'};
    }
  }
static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)['user']};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }

  // Fungsi untuk mengambil daftar makanan dari database
  static Future<List<dynamic>> getFoods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/foods'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return responseBody['data']; // Mengembalikan array data makanan
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching foods: $e");
      return [];
    }
  }
  // Fungsi Simpan Jurnal
  static Future<bool> saveFoodLog(int userId, int foodId, double porsi, int totalKalori) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/food-logs'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'food_id': foodId,
          'porsi': porsi,
          'total_kalori': totalKalori,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Fungsi Ambil Data Hari Ini
  static Future<Map<String, dynamic>?> getTodayFoodLogs(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/food-logs/today/$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  // Nanti fungsi login ditambahkan di sini
}