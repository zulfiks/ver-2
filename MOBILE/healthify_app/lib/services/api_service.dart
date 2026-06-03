import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // FIX: Ditambahkan agar kIsWeb tidak lagi 'Undefined name'

class ApiService {
  // GANTI: Menggunakan URL Ngrok aktifmu agar HP fisik bisa menembak database laptop lewat internet
  static const String baseUrl = 'https://taenidial-lipogrammatic-antony.';

  // Fungsi Ambil Top 3 Leaderboard Riil
  static Future<List<dynamic>> getTopLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/top'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return responseBody['leaderboard'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching leaderboard: $e");
      return [];
    }
  }

  // Fungsi Upload Foto Profil Hybrid
  static Future<String?> uploadProfilePicture(int userId, dynamic pickedFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/user/$userId/upload-profile-picture'),
      );

      if (kIsWeb) {
        var bytes = await pickedFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: pickedFile.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          pickedFile.path,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['profile_picture_url'];
        }
      }
      return null;
    } catch (e) {
      print("Error upload API: $e"); // FIX: Menggunakan print biasa agar tidak memicu undefined_method
      return null;
    }
  }

  // Fungsi Register Asli
  static Future<Map<String, dynamic>> registerUser(
      String name, 
      String email, 
      String password, 
      Map<String, String> healthData) async {
    try {
      final Map<String, dynamic> requestBody = {
        'name': name,
        'email': email,
        'password': password,
      };
      requestBody.addAll(healthData);

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

  // Fungsi Login Asli
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
        return responseBody['data'];
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

  // Fungsi Ambil Data Hari Ini (FIX: Menyesuaikan route bawaan Laravelmu: /api/food-logs/today/{id})
  static Future<Map<String, dynamic>?> getTodayFoodLogs(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/food-logs/today/$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error fetching today food logs: $e");
      return null;
    }
  }
}