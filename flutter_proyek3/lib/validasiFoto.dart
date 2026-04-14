import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_proyek3/cekAI.dart';
import 'fotoAI.dart';
import 'cekAI.dart';

class ValidasiFoto extends StatelessWidget {
  final Uint8List? imageBytes;

  const ValidasiFoto({Key? key, this.imageBytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF3E792F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryGreen.withOpacity(0.2), width: 1),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.arrow_back, color: Color(0xFF3E792F)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Builder(
                      builder: (context) {
                        if (imageBytes != null) {
                          return Image.memory(imageBytes!, fit: BoxFit.cover);
                        }

                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Gambar tidak tersedia', style: TextStyle(color: Colors.red, fontSize: 16)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const CekAIPage()),
                      );
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryGreen, width: 1.8),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.refresh, color: primaryGreen, size: 26),
                    ),
                  ),
                  const SizedBox(width: 32),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryGreen, width: 1.8),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.arrow_forward, color: primaryGreen, size: 26),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
