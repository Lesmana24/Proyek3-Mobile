import 'package:flutter/material.dart';
import 'auth_.service.dart';

class DaftarPage extends StatefulWidget {
  const DaftarPage({super.key});

  @override
  State<DaftarPage> createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  static const primaryGreen = Color(0xFF4C732E);

  @override
  void dispose() {
    _namaCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _handleDaftar() {
    final nama = _namaCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    // Validasi: jangan panggil API kalau kosong
    if (nama.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan Password tidak boleh kosong!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    prosesRegister(context, nama, password).whenComplete(
      () => setState(() => _isLoading = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background dua warna ──
          Row(
            children: [
              Expanded(flex: 3, child: Container(color: Colors.white)),
              Expanded(flex: 2, child: Container(color: primaryGreen)),
            ],
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tombol Back ──
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    splashColor: primaryGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: primaryGreen,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Card Form ──
                  Center(
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 340),
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Daftar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Input Nama
                          _InputField(
                            label: 'Nama',
                            image: 'gambar/profile.png',
                            controller: _namaCtrl,
                          ),
                          const SizedBox(height: 12),

                          // Input Password
                          _InputField(
                            label: 'Password',
                            image: 'gambar/password.png',
                            obscureText: true,
                            controller: _passwordCtrl,
                          ),
                          const SizedBox(height: 20),

                          // Tombol Daftar
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleDaftar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                disabledBackgroundColor:
                                    primaryGreen.withValues(alpha: 0.6),
                                shape: const StadiumBorder(),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Daftar',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Gambar pojok kanan bawah ──
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'gambar/img2.png',
              width: 200,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Input Field dengan TextEditingController
// ──────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final String label;
  final String image;
  final bool obscureText;
  final TextEditingController controller;

  const _InputField({
    required this.label,
    required this.image,
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4C732E);
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: primaryGreen,
      style: const TextStyle(color: primaryGreen),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: primaryGreen,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: const TextStyle(color: primaryGreen),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(image, width: 25, height: 25, fit: BoxFit.contain),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: primaryGreen),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: primaryGreen, width: 2),
        ),
      ),
    );
  }
}
