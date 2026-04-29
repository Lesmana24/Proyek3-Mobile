import 'package:flutter/material.dart';
import 'home.dart';

class MasukPage extends StatelessWidget {
  const MasukPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4C732E);
    return Scaffold(
      body: Stack(
        children: [
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
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                            'Masuk',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4C732E),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _InputField(
                            label: 'Nama',
                            image: 'gambar/profile.png',
                          ),
                          const SizedBox(height: 12),
                          const _InputField(
                            label: 'Password',
                            image: 'gambar/password.png',
                            obscureText: true,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomePage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                shape: const StadiumBorder(),
                              ),
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 255, 255, 255),
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

class _InputField extends StatelessWidget {
  final String label;
  final String image;
  final bool obscureText;

  const _InputField({
    required this.label,
    required this.image,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4C732E);
    return TextField(
      obscureText: obscureText,
      cursorColor: primaryGreen,
      style: const TextStyle(color: primaryGreen),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF4C732E),
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: const TextStyle(color: Color(0xFF4C732E)),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(image, width: 25, height: 25, fit: BoxFit.contain),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4C732E)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4C732E), width: 2),
        ),
      ),
    );
  }
}
