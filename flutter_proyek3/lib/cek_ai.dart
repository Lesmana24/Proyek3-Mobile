import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'foto_ai.dart';
import 'validasi_foto.dart';
import 'hasil_ai.dart';

class CekAIPage extends StatefulWidget {
  const CekAIPage({super.key});

  @override
  State<CekAIPage> createState() => _CekAIPageState();
}

class _CekAIPageState extends State<CekAIPage> {
  bool _isSidebarOpen = false;
  bool _hoverAmbil = false;
  bool _hoverUpload = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  List<dynamic> _historyList = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return;

      final response = await http.get(
        Uri.parse('https://unjoyfully-decrepit-dian.ngrok-free.dev/api/ai/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        setState(() {
          _historyList = responseBody['data'] ?? [];
        });
      }
    } catch (e) {
      // Abaikan error untuk sementara
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _closeSidebar() {
    setState(() {
      _isSidebarOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF3E792F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// MAIN CONTENT
          SafeArea(
            child: RefreshIndicator(
              color: const Color(0xFF3E792F),
              onRefresh: () async {
                await _fetchHistory();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Memperbarui riwayat...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _iconCircularButton(
                        icon: Icons.arrow_back,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      _iconCircularButton(
                        icon: Icons.menu,
                        onPressed: _toggleSidebar,
                      ),
                    ],
                  ),

                  const SizedBox(height: 42),

                  /// TITLE
                  const Text(
                    'Cek Kesehatan\nTanaman (AI)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF2F6627),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// BUTTONS
                  Row(
                    children: [
                      /// AMBIL FOTO
                      Expanded(
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _hoverAmbil = true),
                          onExit: (_) => setState(() => _hoverAmbil = false),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const FotoAIPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hoverAmbil
                                  ? primaryGreen.withValues(alpha: 0.8)
                                  : primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Ambil Foto',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// UPLOAD FOTO
                      Expanded(
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _hoverUpload = true),
                          onExit: (_) => setState(() => _hoverUpload = false),
                          child: OutlinedButton(
                            onPressed: () async {
                              final navigator = Navigator.of(context);
                              final picked = await _picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 800,
                                maxHeight: 800,
                                imageQuality: 70,
                              );

                              if (picked != null) {
                                final bytes = await picked.readAsBytes();

                                if (!mounted) return;

                                setState(() {
                                  _pickedImage = picked;
                                });

                                navigator.push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ValidasiFoto(imageBytes: bytes),
                                  ),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: primaryGreen.withValues(
                                  alpha: _hoverUpload ? 0.8 : 1.0,
                                ),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: _hoverUpload
                                  ? primaryGreen.withValues(alpha: 0.1)
                                  : Colors.white,
                            ),
                            child: Text(
                              'Upload dari Galeri',
                              style: TextStyle(
                                color: primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Unggah foto daun/tanaman dengan pencahayaan cukup',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF7A7A7A)),
                  ),

                  /// PREVIEW IMAGE
                  if (_pickedImage != null) ...[
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(_pickedImage!.path),
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ),
            ),
          ),

          /// OVERLAY
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _closeSidebar,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),

          /// SIDEBAR
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: _isSidebarOpen ? 0 : -280,
            top: 0,
            bottom: 0,
            width: 280,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(-4, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    /// HEADER SIDEBAR
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'History',
                                style: TextStyle(
                                  color: Color(0xFF3E792F),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _isLoadingHistory ? null : _fetchHistory,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3E792F).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: _isLoadingHistory
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF3E792F),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.refresh,
                                          size: 20,
                                          color: Color(0xFF3E792F),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _closeSidebar,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Color(0xFF3E792F),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// LIST
                    Expanded(
                      child: _isLoadingHistory
                          ? const Center(
                              child: CircularProgressIndicator(color: Color(0xFF3E792F)),
                            )
                          : _historyList.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Belum ada riwayat',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: _historyList.length,
                                  itemBuilder: (context, index) {
                                    return _historyItem(_historyList[index]);
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 0) {
        return '${diff.inDays} hari yang lalu';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} jam yang lalu';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} menit yang lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      // Jika parsing gagal, kembalikan substring
      return dateString.length > 16 ? dateString.substring(0, 16) : dateString;
    }
  }

  Future<void> _hapusHistory(int id) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text('Apakah Anda yakin ingin menghapus riwayat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('https://unjoyfully-decrepit-dian.ngrok-free.dev/api/ai/history/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Riwayat berhasil dihapus'), backgroundColor: Colors.green),
        );
        _fetchHistory();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus riwayat: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Widget _historyItem(Map<String, dynamic> itemData) {
    final id = itemData['id'];
    final plantName = itemData['plant_name'] ?? 'Tanaman';
    final diseaseName = itemData['disease_name'] ?? itemData['ai_health_status'] ?? 'Tidak Diketahui';
    final imagePath = itemData['image_path'];
    final createdAt = itemData['created_at'];

    final isHealthy = diseaseName.toString().toLowerCase().contains('sehat') || 
                      diseaseName.toString().toLowerCase().contains('tidak ada');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HasilAIPage(data: itemData),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Bagian Kiri (Thumbnail)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imagePath != null && imagePath.toString().isNotEmpty
                    ? Image.network(
                        'https://unjoyfully-decrepit-dian.ngrok-free.dev/storage/$imagePath',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        cacheWidth: 150,
                        cacheHeight: 150,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 12),
              // Bagian Kanan (Info)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plantName,
                      style: const TextStyle(
                        color: Color(0xFF3E792F),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Badge Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isHealthy ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isHealthy ? Icons.check_circle : Icons.warning,
                            size: 12,
                            color: isHealthy ? const Color(0xFF3E792F) : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              diseaseName,
                              style: TextStyle(
                                color: isHealthy ? const Color(0xFF3E792F) : Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTimeAgo(createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol Hapus
              IconButton(
                onPressed: () {
                  if (id != null) {
                    _hapusHistory(id);
                  }
                },
                icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade300,
                iconSize: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: const Color(0xFFEEF5EE),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: const Color(0xFF3E792F)),
        ),
      ),
    );
  }
}