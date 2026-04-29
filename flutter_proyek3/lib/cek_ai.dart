import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'foto_ai.dart';
import 'validasi_foto.dart';

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
                                imageQuality: 85,
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
              color: const Color(0xFF3E792F),
              child: SafeArea(
                child: Column(
                  children: [
                    /// HEADER SIDEBAR
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'History',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: _closeSidebar,
                            child: const CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Text(
                                'X',
                                style: TextStyle(color: Color(0xFF3E792F)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// LIST
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          _historyItem('Tanaman Hias', true),
                          _historyItem('Daun Kering', false),
                          _historyItem('Tanaman Janda', false),
                          _historyItem('Daun Bolong', false),
                        ],
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

  Widget _historyItem(String title, bool selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? const Color(0xFF3E792F) : Colors.white,
            fontWeight: FontWeight.w600,
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