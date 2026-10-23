import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import '../services/storage_service.dart';
import '../widgets/glass_card.dart';

class FrameDesignerScreen extends StatefulWidget {
  const FrameDesignerScreen({super.key});

  @override
  State<FrameDesignerScreen> createState() => _FrameDesignerScreenState();
}

class _FrameDesignerScreenState extends State<FrameDesignerScreen> {
  final TextEditingController _dataController = TextEditingController(text: 'https://example.com');
  final TextEditingController _headerController = TextEditingController(text: 'SCAN ME');
  final TextEditingController _footerController = TextEditingController(text: 'Thank You!');
  final ScreenshotController _screenshotController = ScreenshotController();

  final Color _frameColor = const Color(0xFF0F172A);
  final Color _textColor = Colors.white;
  bool _isSaving = false;

  @override
  void dispose() {
    _dataController.dispose();
    _headerController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _saveFrameGallery() async {
    setState(() => _isSaving = true);
    final result = await StorageService.saveQrToGallery(_screenshotController);
    setState(() => _isSaving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] as String),
        backgroundColor: (result['success'] as bool) ? Colors.green.shade700 : Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _dataController.text.trim();
    final header = _headerController.text.trim();
    final footer = _footerController.text.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Frame & Banner Designer'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              borderRadius: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _dataController,
                    decoration: InputDecoration(
                      labelText: 'QR Content / URL',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _headerController,
                    decoration: InputDecoration(
                      labelText: 'Banner Header Text',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _footerController,
                    decoration: InputDecoration(
                      labelText: 'Banner Footer Text',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Framed Preview Card
            Center(
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _frameColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (header.isNotEmpty) ...[
                        Text(
                          header.toUpperCase(),
                          style: TextStyle(
                            color: _textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: data.isEmpty
                            ? const SizedBox(
                                width: 180,
                                height: 180,
                                child: Center(child: Text('Enter data')),
                              )
                            : QrImageView(
                                data: data,
                                version: QrVersions.auto,
                                size: 180,
                                backgroundColor: Colors.white,
                              ),
                      ),
                      if (footer.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          footer,
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveFrameGallery,
              icon: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download),
              label: Text(_isSaving ? 'Saving...' : 'Save Framed QR Code'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
