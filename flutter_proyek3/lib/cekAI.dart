import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'fotoAI.dart';
import 'validasiFoto.dart';

class CekAIPage extends StatefulWidget {
  const CekAIPage({Key? key}) : super(key: key);

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
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _hoverAmbil = true),
                          onExit: (_) => setState(() => _hoverAmbil = false),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const FotoAIPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hoverAmbil ? primaryGreen.withOpacity(0.8) : primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Ambil Foto',
                              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _hoverUpload = true),
                          onExit: (_) => setState(() => _hoverUpload = false),
                          child: OutlinedButton(
                            onPressed: () async {
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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ValidasiFoto(imageBytes: bytes),
      ),
    );
  }
},
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryGreen.withOpacity(_hoverUpload ? 0.8 : 1.0), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: _hoverUpload ? primaryGreen.withOpacity(0.1) : Colors.white,
                            ),
                            child: Text(
                              'Upload dari Galeri',
                              style: TextStyle(
                                color: primaryGreen,
                                fontSize: 16,
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
                    style: TextStyle(
                      color: Color(0xFF7A7A7A),
                      fontSize: 14,
                    ),
                  ),
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

          // Sidebar overlay
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _closeSidebar,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),

          // Sidebar
          AnimatedPositioned(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  right: _isSidebarOpen ? 0 : -280,
  top: 0,
  bottom: 0,
  width: 280,
  child: Container(
    color: const Color(0xFF3E792F), // ⬅️ FULL HIJAU
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
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
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'X',
                      style: TextStyle(
                        color: Color(0xFF3E792F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// LIST MENU
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _historyItem(title: 'Tanaman Hias', selected: true, onTap: _closeSidebar),
                _historyItem(title: 'Daun Kering', selected: false, onTap: _closeSidebar),
                _historyItem(title: 'Tanaman Janda', selected: false, onTap: _closeSidebar),
                _historyItem(title: 'Daun Bolong', selected: false, onTap: _closeSidebar),
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

  Widget _historyItem({
  required String title,
  required bool selected,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? const Color(0xFF3E792F) : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

  Widget _iconCircularButton({IconData? icon, Widget? child, required VoidCallback onPressed}) {
    return Material(
      color: const Color(0xFFEEF5EE),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: child ?? Icon(
            icon,
            color: const Color(0xFF3E792F),
            size: 22,
          ),
        ),
      ),
    );
  }
}
