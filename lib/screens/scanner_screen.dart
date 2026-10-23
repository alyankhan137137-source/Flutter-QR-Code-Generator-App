import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/qr_item.dart';
import '../services/storage_service.dart';
import '../widgets/glass_card.dart';
import 'dart:io' show Platform;

class ScannerScreen extends StatefulWidget {
  final Function(String data, String title, String type) onScanned;

  const ScannerScreen({super.key, required this.onScanned});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final MobileScannerController _controller;
  bool _isTorchOn = false;
  bool _isScanningActive = true;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (!_isScanningActive) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isScanningActive = false);
        final rawValue = barcode.rawValue!;
        
        String type = 'text';
        if (rawValue.startsWith('http://') || rawValue.startsWith('https://')) {
          type = 'url';
        } else if (rawValue.startsWith('WIFI:')) {
          type = 'wifi';
        } else if (rawValue.startsWith('BEGIN:VCARD')) {
          type = 'vCard';
        } else if (rawValue.startsWith('mailto:')) {
          type = 'email';
        } else if (rawValue.startsWith('tel:')) {
          type = 'phone';
        } else if (rawValue.startsWith('SMSTO:')) {
          type = 'sms';
        }

        final title = rawValue.length > 25 ? '${rawValue.substring(0, 25)}...' : rawValue;

        StorageService.addItem(QrItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          data: rawValue,
          title: 'Scanned: $title',
          type: type,
          timestamp: DateTime.now(),
          foregroundColorValue: const Color(0xFF0F172A).toARGB32(),
          backgroundColorValue: Colors.white.toARGB32(),
          errorCorrectionLevel: 'M',
        ));

        _showScannedDialog(rawValue, type);
        break;
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      final capture = await _controller.analyzeImage(image.path);
      if (capture == null || capture.barcodes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No QR code found in selected image')),
        );
      } else {
        _handleBarcode(capture);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing image: $e')),
      );
    }
  }

  void _showScannedDialog(String data, String type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Scanned'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scanned Content:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(data, maxLines: 5, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isScanningActive = true);
            },
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: data));
              Navigator.pop(context);
              widget.onScanned(data, data, type);
            },
            child: const Text('Open / Copy'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        elevation: 0,
        actions: [
          if (isMobile)
            IconButton(
              icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
              onPressed: () async {
                await _controller.toggleTorch();
                setState(() => _isTorchOn = !_isTorchOn);
              },
            ),
          IconButton(
            icon: const Icon(Icons.image),
            tooltip: 'Scan from Gallery',
            onPressed: _pickImageFromGallery,
          ),
        ],
      ),
      body: isMobile
          ? Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _handleBarcode,
                ),
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.primary, width: 3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: GlassCard(
                    borderRadius: 16,
                    child: const Text(
                      'Align QR code within the frame to scan automatically',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: GlassCard(
                  borderRadius: 20,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 64, color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Camera Scanner is optimized for Android & iOS',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You can scan QR codes by picking an image from your gallery using the gallery button above.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickImageFromGallery,
                        icon: const Icon(Icons.image),
                        label: const Text('Pick QR Image from Gallery'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
