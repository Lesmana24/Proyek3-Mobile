import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_proyek3/cek_ai.dart';
import 'chat_ai.dart';

class HasilAIPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final Uint8List? imageBytes;

  const HasilAIPage({super.key, required this.data, this.imageBytes});

  @override
  State<HasilAIPage> createState() => _HasilAIPageState();
}

class _HasilAIPageState extends State<HasilAIPage> {
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    // Jika data memiliki 'id', berarti ini data dari database (History), otomatis set tombol ke Tersimpan
    if (widget.data.containsKey('id')) {
      _isSaved = true;
    }
  }

  Future<void> _simpanLaporan() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap login terlebih dahulu')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('https://unjoyfully-decrepit-dian.ngrok-free.dev/api/ai/store'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(widget.data),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isSaved = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildCareItem(
      IconData icon, Color iconColor, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black87, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemsBox(List<String> problems) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
              const SizedBox(width: 8),
              Text(
                'Masalah & Gejala',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...problems.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6, right: 8),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade800,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        p,
                        style: const TextStyle(
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF3E792F);

    final data = widget.data;
    final plantName = data['plant_name'] ?? 'Tidak diketahui';
    final diseaseName = data['disease_name'] ?? 'Tidak diketahui';
    final healthStatus = data['ai_health_status'] ?? 'Unknown';
    double confValue = 0.0;
    if (data['confidence_score'] != null) {
      confValue = double.tryParse(data['confidence_score'].toString()) ?? 0.0;
    }
    final confidence = confValue.toStringAsFixed(1);
    
    List<String> problems = [];
    if (data['problems_list'] != null && data['problems_list'] is List) {
      problems = (data['problems_list'] as List).map((e) => e.toString()).toList();
    }

    final careLight = data['care_light'] ?? '-';
    final careWater = data['care_water'] ?? '-';
    final careTemp = data['care_temperature'] ?? '-';

    final isHealthy = diseaseName.toString().toLowerCase() == 'healthy' ||
        diseaseName.toString().toLowerCase() == 'sehat';
    final diseaseColor = isHealthy ? primaryGreen : Colors.red;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Hasil Diagnosis AI',
            style:
                TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryGreen),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatAIPage(
                      plantName: data['plant_name'] ?? 'Tanaman',
                      diseaseName: data['disease_name'] ?? 'Sehat',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline,
                  size: 18, color: primaryGreen),
              label: const Text('Tanya AI',
                  style: TextStyle(color: primaryGreen)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryGreen),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.imageBytes != null) ...[
                      Image.memory(
                        widget.imageBytes!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 20),
                    ] else if (widget.data.containsKey('image_path')) ...[
                      Image.network(
                        'https://unjoyfully-decrepit-dian.ngrok-free.dev/storage/${widget.data['image_path']}',
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(
                          height: 250,
                          child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 1. Sub-header 1
                    const Text(
                      'Identitas Tanaman',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 12),

                    // 2. Card Identitas
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Kiri
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('NAMA TANAMAN',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  plantName.toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isHealthy
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'STATUS: $healthStatus',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isHealthy
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Card Kanan
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('PENYAKIT UTAMA',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  diseaseName.toString(),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: diseaseColor),
                                ),
                                const SizedBox(height: 8),
                                const Text('AKURASI DETEKSI',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(
                                  '$confidence%',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 3. Sub-header 2
                    const Text(
                      'Panduan Perawatan',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 12),

                    // 4. List Perawatan
                    _buildCareItem(Icons.wb_sunny, Colors.orange, 'CAHAYA',
                        careLight.toString()),
                    const SizedBox(height: 12),
                    _buildCareItem(Icons.water_drop, Colors.blue,
                        'PENYIRAMAN', careWater.toString()),
                    const SizedBox(height: 12),
                    _buildCareItem(Icons.thermostat, Colors.red,
                        'SUHU IDEAL', careTemp.toString()),
                        
                    if (!isHealthy && problems.isNotEmpty) _buildProblemsBox(problems),
                  ],
                ),
              ),
            ),

            // 5. Footer: Tombol Scan Ulang & Simpan Laporan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Tombol Kiri (Scan Ulang)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const CekAIPage()),
                        );
                      },
                      icon: const Icon(Icons.refresh, color: primaryGreen),
                      label: const Text(
                        'Scan Ulang',
                        style: TextStyle(
                            color: primaryGreen, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: primaryGreen, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol Kanan (Simpan Laporan)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (_isSaving || _isSaved) ? null : _simpanLaporan,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(_isSaved ? Icons.check : Icons.save, color: Colors.white),
                      label: Text(
                        _isSaving 
                            ? 'Menyimpan...' 
                            : (_isSaved ? 'Tersimpan' : 'Simpan Laporan'),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSaved ? Colors.grey : primaryGreen,
                        disabledBackgroundColor: _isSaved ? Colors.grey : null,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
