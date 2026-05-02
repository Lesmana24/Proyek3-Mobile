import 'package:flutter/material.dart';

class InformasiPage extends StatelessWidget {
  const InformasiPage({super.key});

  static const _primaryGreen = Color(0xFF4C732E);
  static const _lightGreen = Color(0xFFF0FDF4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGreen,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Panduan Sistem',
          style: TextStyle(
            color: _primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ═══════════════════════════════════════
            // SECTION 1 — Monitoring & Kontrol IoT
            // ═══════════════════════════════════════
            _SectionCard(
              icon: Icons.sensors,
              title: 'Monitoring & Kontrol IoT',
              items: const [
                _GuideItem(
                  icon: Icons.thermostat,
                  title: 'Batas Ambang Sensor (Suhu & Lembab)',
                  description:
                      'Berfungsi sebagai pemicu (trigger) otomatis. Jika suhu/kelembapan aktual melewati batas ini, sistem akan menyalakan pompa air.',
                ),
                _GuideItem(
                  icon: Icons.timer_outlined,
                  title: 'Durasi Penyiraman',
                  description:
                      'Mengatur berapa lama pompa menyala saat suhu kritis tercapai atau saat jadwal rutin tiba.',
                ),
                _GuideItem(
                  icon: Icons.calendar_month,
                  title: 'Jadwal Otomatis',
                  description:
                      'Mengatur hari dan jam spesifik untuk menyiram tanaman secara rutin, tanpa bergantung pada suhu.',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ═══════════════════════════════════════
            // SECTION 2 — Deteksi Penyakit AI
            // ═══════════════════════════════════════
            _SectionCard(
              icon: Icons.psychology,
              title: 'Deteksi Penyakit AI (Smart Botanist)',
              items: const [
                _GuideItem(
                  icon: Icons.touch_app,
                  title: 'Akses Fitur',
                  description:
                      'Klik logo Agro Squad yang melayang di atas untuk masuk ke halaman scan daun.',
                ),
                _GuideItem(
                  icon: Icons.camera_alt_outlined,
                  title: 'Upload Foto',
                  description:
                      'Unggah foto daun untuk dianalisis oleh AI (Cabai, Tomat, Terong, atau Melon).',
                ),
                _GuideItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat Botanist',
                  description:
                      'Setelah hasil scan keluar, gunakan fitur ini untuk konsultasi penanganan dan pengobatan penyakit.',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ═══════════════════════════════════════
            // SECTION 3 — Status Perangkat
            // ═══════════════════════════════════════
            _SectionCard(
              icon: Icons.wifi_tethering,
              title: 'Status Perangkat',
              headerNote:
                  'Indikator status MQTT di bagian atas menunjukkan koneksi perangkat fisik IoT Anda ke sistem.',
              items: const [
                _GuideItem(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  title: 'Terhubung (Hijau)',
                  description:
                      'Perangkat IoT menyala dan terkoneksi dengan internet.',
                ),
                _GuideItem(
                  icon: Icons.cancel,
                  iconColor: Colors.red,
                  title: 'OFFLINE (Merah)',
                  description:
                      'Perangkat tidak merespons, kemungkinan alat mati atau terputus dari jaringan WiFi.',
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Widget: Section Card — kartu utama per section
// ─────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? headerNote;
  final List<_GuideItem> items;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.items,
    this.headerNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF4C732E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Header Note (opsional) ──
          if (headerNote != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text(
                headerNote!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // ── List Items ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              children: items.map((item) => item).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Widget: Guide Item — baris individual di dalam section
// ─────────────────────────────────────────────────────
class _GuideItem extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String description;

  const _GuideItem({
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon bulat
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (iconColor ?? const Color(0xFF4C732E)).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor ?? const Color(0xFF4C732E),
            ),
          ),
          const SizedBox(width: 12),

          // Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: Color(0xFF4C732E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
