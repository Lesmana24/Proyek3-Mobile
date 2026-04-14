import 'package:flutter/material.dart';

class InformasiPage extends StatelessWidget {
  const InformasiPage({Key? key}) : super(key: key);

  Widget buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget buildContent(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• "),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Informasi & Cara Kerja Sistem",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ),

                buildSectionTitle("1. Registrasi & Login"),
                buildContent(
                    "Pengguna terlebih dahulu melakukan registrasi akun, kemudian login untuk dapat mengakses seluruh fitur sistem."),

                buildSectionTitle("2. Monitoring Lingkungan"),
                buildContent(
                    "Sistem akan menampilkan data kondisi greenhouse secara real-time, meliputi:"),
                buildBullet("Suhu udara"),
                buildBullet("Kelembapan udara"),
                buildContent(
                    "Data ini diperoleh dari sensor yang terpasang di dalam greenhouse dan akan terus diperbarui secara otomatis."),

                buildSectionTitle("3. Pengaturan Batas Ambang"),
                buildContent(
                    "Pengguna dapat mengatur batas suhu dan kelembapan sesuai kebutuhan tanaman. Jika kondisi lingkungan melebihi batas tersebut, sistem akan memberikan notifikasi peringatan."),

                buildSectionTitle("4. Sistem Penyiraman Otomatis"),
                buildContent("Berdasarkan data suhu dan kelembapan:"),
                buildBullet(
                    "Sistem akan mengaktifkan penyiraman secara otomatis jika kondisi tidak ideal"),
                buildBullet(
                    "Penyiraman dapat disesuaikan dengan jadwal atau kondisi lingkungan"),

                buildSectionTitle("5. Deteksi Kesehatan Tanaman"),
                buildContent(
                    "Pengguna dapat mengunggah foto tanaman melalui fitur:"),
                buildBullet("Ambil foto langsung"),
                buildBullet("Upload dari galeri"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}