import 'package:flutter/material.dart';
import 'package:proyek3/home.dart';
import 'package:proyek3/informasi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  static const List<Map<String, String>> dataNotifikasi = [
    const {
      "isi":
          "Penyiraman selesai! Pemicu: Kondisi Kritis (Suhu 29.2C, Lembab: 83%)",
      "waktu": "Minggu, 05 Februari 2026 | 11.05"
    },
    const {
      "isi":
          "Penyiraman selesai! faqih Pemicu: Kondisi Kritis (Suhu 29.2C, Lembab: 83%)",
      "waktu": "Minggu, 05 Februari 2026 | 11.05"
    },
    const {
      "isi":
          "Penyiraman selesai! Pemicu: Kondisi Kritis (Suhu 29.2C, Lembab: 83%)",
      "waktu": "Minggu, 05 Februari 2026 | 11.05"
    },
    const {
      "isi":
          "Penyiraman selesai! Pemicu: Kondisi Kritis (Suhu 29.2C, Lembab: 83%)",
      "waktu": "Minggu, 05 Februari 2026 | 11.05"
    },
    const {
      "isi":
          "Penyiraman selesai! Pemicu: Kondisi Kritis (Suhu 29.2C, Lembab: 83%)",
      "waktu": "Minggu, 05 Februari 2026 | 11.05"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: dataNotifikasi.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dataNotifikasi[index]["isi"]!,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    dataNotifikasi[index]["waktu"]!,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}