import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'home.dart'; // Ganti sesuai nama file HomePage lu

// URL Ngrok lu + /api (Jangan lupa di-update kalau ngroknya direstart)
const String baseUrl = 'https://unjoyfully-decrepit-dian.ngrok-free.dev/api';

// ==========================================
// 1. FUNGSI LOGIKA REGISTER
// ==========================================
Future<void> prosesRegister(BuildContext context, String nama, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'nama': nama,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    // 201 Created = Sukses masuk database
    if (response.statusCode == 201 && data['success'] == true) {
      // Tangkep Tokennya
      String token = data['token'];

      // Simpen Token ke laci HP (Shared Preferences)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setBool('isLoggedIn', true); // Penanda udah login

      // Munculin notif sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
      );

      // Pindah ke HomePage dan buang halaman Register dari tumpukan (biar ga bisa di-back)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else {
      // Kalau gagal (misal nama udah ada)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${data['message'] ?? 'Nama sudah dipakai'}'), backgroundColor: Colors.red),
      );
    }
  } catch (e) {
    print('Error Register: $e');
  }
}

// ==========================================
// 2. FUNGSI LOGIKA LOGIN
// ==========================================
Future<void> prosesLogin(BuildContext context, String nama, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'nama': nama,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    // 200 OK = Ketemu dan cocok
    if (response.statusCode == 200 && data['success'] == true) {
      String token = data['token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setBool('isLoggedIn', true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else {
      // Kalau gagal (salah password / nama ga ada)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${data['message']}'), backgroundColor: Colors.red),
      );
    }
  } catch (e) {
    print('Error Login: $e');
  }
}