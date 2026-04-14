import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'validasiFoto.dart';

class FotoAIPage extends StatefulWidget {
  const FotoAIPage({Key? key}) : super(key: key);

  @override
  State<FotoAIPage> createState() => _FotoAIPageState();
}

class _FotoAIPageState extends State<FotoAIPage> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _capturedBytes;
  bool _isLoading = false;
  bool _hoverCapture = false;

  Future<void> _takePicture() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (picked == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto dibatalkan')));
        }
      } else {
        _capturedBytes = await picked.readAsBytes();

        if (_capturedBytes != null && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ValidasiFoto(imageBytes: _capturedBytes),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membaca foto')));
        }
      }
    } catch (e) {
      debugPrint('Capture failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memotret: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF3E792F);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.grey.shade200,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _capturedBytes != null
                            ? Image.memory(_capturedBytes!, fit: BoxFit.cover)
                            : const Center(child: Text('Tekan tombol kamera untuk mengambil foto', style: TextStyle(fontSize: 16))),
              ),
            ),
          ),
          const SizedBox(height: 16),
          MouseRegion(
            onEnter: (_) => setState(() => _hoverCapture = true),
            onExit: (_) => setState(() => _hoverCapture = false),
            child: GestureDetector(
              onTap: _takePicture,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _hoverCapture ? primaryGreen.withOpacity(0.85) : primaryGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Unggah foto daun/tanaman dengan pencahayaan cukup',
            style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 14),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
