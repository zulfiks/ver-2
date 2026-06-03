import 'dart:io';
import 'package:flutter/foundation.dart'; // Untuk mendeteksi kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart'; // Sesuaikan dengan login screen Anda
import '../services/api_service.dart'; // Import ApiService bawaan Anda

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProfileScreen({super.key, this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;          // Untuk handle di Mobile (Android/iOS)
  Uint8List? _webImageBytes; // KHUSUS WEB: Menyimpan data gambar dalam bentuk memori bytes
  XFile? _pickedFile;        // Menyimpan mentahan file gambar yang dipilih untuk diupload nanti
  
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  bool _isImageChanged = false; // Penanda apakah ada foto baru yang belum disimpan

  // Fungsi mengambil gambar dari Galeri atau Kamera (Hanya menampung sesaat di UI)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? selected = await _picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (selected != null) {
        if (kIsWeb) {
          final Uint8List bytes = await selected.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _imageFile = null;
            _pickedFile = selected;
            _isImageChanged = true; // Munculkan tombol simpan
          });
        } else {
          setState(() {
            _imageFile = File(selected.path);
            _webImageBytes = null;
            _pickedFile = selected;
            _isImageChanged = true; // Munculkan tombol simpan
          });
        }
      }
    } catch (e) {
      debugPrint("Error mengambil gambar: $e");
    }
  }

  // Fungsi untuk menyimpan secara permanen ke database Laravel melalui ApiService
  Future<void> _simpanFotoKeBackend() async {
    if (widget.userData == null || widget.userData!['id'] == null || _pickedFile == null) return;

    setState(() => _isSaving = true);

    try {
      // Memanggil fungsi upload bawaan ApiService proyek Anda
      String? uploadedUrl = await ApiService.uploadProfilePicture(
        widget.userData!['id'], 
        _pickedFile!,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        
        if (uploadedUrl != null) {
          setState(() {
            widget.userData!['profile_picture'] = uploadedUrl;
            _isImageChanged = false; // Sembunyikan tombol karena sudah tersimpan
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil berhasil disimpan permanen!'), 
              backgroundColor: Color(0xFF14B8A6)
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan foto ke server.'), 
              backgroundColor: Colors.red
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        debugPrint("Error saving image: $e");
      }
    }
  }

  // Menampilkan pilihan dialog bawah (Bottom Sheet) untuk memilih sumber gambar
  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Ganti Foto Profil',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF14B8A6)),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF14B8A6)),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String userName = widget.userData?['name'] ?? 'Beniya';
    String email = widget.userData?['email'] ?? 'ben@gmail.com';
    String statusRisiko = widget.userData?['klasifikasi_risiko'] ?? 'Risiko Obesitas: Rendah (Pencegahan)';
    String? profilePictureUrl = widget.userData?['profile_picture'];
    
    String initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'B';
    bool hasLocalImage = (kIsWeb && _webImageBytes != null) || (!kIsWeb && _imageFile != null);

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF14B8A6),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, widget.userData?['profile_picture']),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          // Mengembalikan URL foto terbaru ke dashboard saat tombol back ditekan
          Navigator.pop(context, widget.userData?['profile_picture']);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            children: [
              // --- FOTO PROFIL DENGAN EDIT LINK ---
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ClipOval(
                          child: hasLocalImage
                              ? (kIsWeb 
                                  ? Image.memory(_webImageBytes!, fit: BoxFit.cover) 
                                  : Image.file(_imageFile!, fit: BoxFit.cover))
                              : (profilePictureUrl != null && profilePictureUrl.isNotEmpty
                                  ? Image.network(
                                      profilePictureUrl, 
                                      fit: BoxFit.cover, 
                                      errorBuilder: (c, e, s) => Container(
                                        color: const Color(0xFF14B8A6), 
                                        child: Center(child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold)))
                                      )
                                    )
                                  : Container(
                                      color: const Color(0xFF14B8A6), 
                                      child: Center(child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold)))
                                    )),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: _isSaving ? null : _showImageSourcePicker,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2DD4BF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- TOMBOL SIMPAN (Hanya muncul jika ada perubahan foto baru) ---
              if (_isImageChanged) ...[
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _simpanFotoKeBackend,
                    icon: _isSaving 
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                    label: Text(
                      _isSaving ? 'Menyimpan...' : 'Simpan Foto Baru', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 8),

              // --- TEXT NAMA & EMAIL ---
              Text(
                userName.toLowerCase(),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),

              // --- KARTU DETAIL INFORMASI ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoTile(Icons.person_outline_rounded, 'Nama Lengkap', userName),
                    const Divider(height: 24, thickness: 0.8),
                    _buildInfoTile(Icons.email_outlined, 'Alamat Email', email),
                    const Divider(height: 24, thickness: 0.8),
                    _buildInfoTile(Icons.health_and_safety_outlined, 'Klasifikasi Risiko', statusRisiko, isHighlight: true),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- TOMBOL LOGOUT ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFECEF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Keluar dari Akun',
                    style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value, {bool isHighlight = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF14B8A6), size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isHighlight ? const Color(0xFF0D9488) : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}