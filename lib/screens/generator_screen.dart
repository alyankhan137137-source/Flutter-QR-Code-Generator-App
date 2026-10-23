import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import '../models/qr_item.dart';
import '../services/storage_service.dart';
import '../widgets/glass_card.dart';

class GeneratorScreen extends StatefulWidget {
  final String? initialData;
  final String? initialTitle;
  final String? initialType;

  const GeneratorScreen({
    super.key,
    this.initialData,
    this.initialTitle,
    this.initialType,
  });

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();

  Color _foregroundColor = const Color(0xFF0F172A); // Professional Slate
  Color _backgroundColor = Colors.white;
  String _errorCorrectionLevel = 'M';
  double _qrSize = 220.0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _textController.text = widget.initialData!;
    }
  }

  @override
  void didUpdateWidget(covariant GeneratorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != null && widget.initialData != oldWidget.initialData) {
      _textController.text = widget.initialData!;
      _saveToHistory(widget.initialTitle ?? 'QR Code', widget.initialType ?? 'text');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveToHistory(String title, String type) async {
    final data = _textController.text.trim();
    if (data.isEmpty) return;

    final item = QrItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: data,
      title: title,
      type: type,
      timestamp: DateTime.now(),
      foregroundColorValue: _foregroundColor.toARGB32(),
      backgroundColorValue: _backgroundColor.toARGB32(),
      errorCorrectionLevel: _errorCorrectionLevel,
    );

    await StorageService.addItem(item);
  }

  void _handleGenerate() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter content or URL to generate QR code')),
      );
      return;
    }

    String type = 'text';
    if (text.startsWith('http://') || text.startsWith('https://')) {
      type = 'url';
    } else if (text.startsWith('WIFI:')) {
      type = 'wifi';
    } else if (text.startsWith('BEGIN:VCARD')) {
      type = 'vCard';
    } else if (text.startsWith('mailto:')) {
      type = 'email';
    } else if (text.startsWith('tel:')) {
      type = 'phone';
    } else if (text.startsWith('SMSTO:')) {
      type = 'sms';
    }

    final title = text.length > 25 ? '${text.substring(0, 25)}...' : text;
    _saveToHistory(title, type);

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code generated successfully'),
        duration: Duration(seconds: 2),
      ),
    );
    setState(() {});
  }

  Future<void> _saveGallery() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generate a QR code first')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final result = await StorageService.saveQrToGallery(_screenshotController);
    setState(() => _isSaving = false);

    if (!mounted) return;
    final success = result['success'] as bool;
    final message = result['message'] as String;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _shareImage() async {
    if (_textController.text.trim().isEmpty) return;
    await StorageService.shareQrImage(_screenshotController, _textController.text);
  }

  Future<void> _shareTextContent() async {
    if (_textController.text.trim().isEmpty) return;
    await StorageService.shareText(_textController.text);
  }

  Future<void> _copyText() async {
    if (_textController.text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _textController.text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textContent = _textController.text.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Generator'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.paste),
            tooltip: 'Paste from clipboard',
            onPressed: () async {
              final data = await Clipboard.getData('text/plain');
              if (data?.text != null) {
                setState(() {
                  _textController.text = data!.text!;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Glass Card
            GlassCard(
              borderRadius: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _textController,
                    maxLines: 4,
                    minLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Enter text, URL, or data',
                      hintText: 'https://example.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _textController.clear();
                          });
                        },
                      ),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _handleGenerate,
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Generate QR Code'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Preview Glass Card
            GlassCard(
              borderRadius: 20,
              blur: 16,
              opacity: 0.15,
              child: Column(
                children: [
                  Screenshot(
                    controller: _screenshotController,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: textContent.isEmpty
                          ? SizedBox(
                              width: _qrSize,
                              height: _qrSize,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.qr_code_2,
                                      size: 56,
                                      color: theme.colorScheme.outline
                                          .withValues(alpha: 0.4),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Preview will appear here',
                                      style: TextStyle(
                                        color: theme.colorScheme.outline,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : QrImageView(
                              data: textContent,
                              version: QrVersions.auto,
                              size: _qrSize,
                              backgroundColor: _backgroundColor,
                              eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: _foregroundColor,
                              ),
                              dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: _foregroundColor,
                              ),
                              errorCorrectionLevel:
                                  _getErrorCorrectionEnum(_errorCorrectionLevel),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (textContent.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          context,
                          icon: Icons.download,
                          label: 'Save',
                          isLoading: _isSaving,
                          onPressed: _saveGallery,
                        ),
                        _buildActionButton(
                          context,
                          icon: Icons.share,
                          label: 'Image',
                          onPressed: _shareImage,
                        ),
                        _buildActionButton(
                          context,
                          icon: Icons.text_snippet,
                          label: 'Text',
                          onPressed: _shareTextContent,
                        ),
                        _buildActionButton(
                          context,
                          icon: Icons.copy,
                          label: 'Copy',
                          onPressed: _copyText,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customization Card (Standard Material Card to support ExpansionTile properly)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                title: const Text('Customization'),
                leading: const Icon(Icons.palette_outlined),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Error Correction:'),
                            ToggleButtons(
                              borderRadius: BorderRadius.circular(8),
                              isSelected: [
                                _errorCorrectionLevel == 'L',
                                _errorCorrectionLevel == 'M',
                                _errorCorrectionLevel == 'Q',
                                _errorCorrectionLevel == 'H',
                              ],
                              onPressed: (index) {
                                setState(() {
                                  _errorCorrectionLevel = ['L', 'M', 'Q', 'H'][index];
                                });
                              },
                              children: const [
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Text('L')),
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Text('M')),
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Text('Q')),
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Text('H')),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Size:'),
                            Expanded(
                              child: Slider(
                                value: _qrSize,
                                min: 150,
                                max: 280,
                                divisions: 13,
                                label: _qrSize.round().toString(),
                                onChanged: (val) => setState(() => _qrSize = val),
                              ),
                            ),
                            Text('${_qrSize.round()}px'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildColorPickerButton(
                              label: 'QR Color',
                              color: _foregroundColor,
                              onTap: () => _showColorPickerDialog(true),
                            ),
                            _buildColorPickerButton(
                              label: 'Background',
                              color: _backgroundColor,
                              onTap: () => _showColorPickerDialog(false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon, size: 20, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPickerButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400, width: 1.5),
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showColorPickerDialog(bool isForeground) {
    final colors = [
      const Color(0xFF0F172A), // Slate / Black
      const Color(0xFF1E3A8A), // Deep Navy
      const Color(0xFF047857), // Emerald
      const Color(0xFFB91C1C), // Crimson
      const Color(0xFF4338CA), // Indigo
      const Color(0xFF374151), // Charcoal
      const Color(0xFF000000), // Pure Black
      const Color(0xFFFFFFFF), // White
      const Color(0xFFF1F5F9), // Light Slate
      const Color(0xFFE2E8F0), // Cool Gray
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isForeground ? 'Select QR Color' : 'Select Background Color'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((c) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isForeground) {
                    _foregroundColor = c;
                  } else {
                    _backgroundColor = c;
                  }
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  int _getErrorCorrectionEnum(String level) {
    switch (level) {
      case 'L':
        return QrErrorCorrectLevel.L;
      case 'Q':
        return QrErrorCorrectLevel.Q;
      case 'H':
        return QrErrorCorrectLevel.H;
      case 'M':
      default:
        return QrErrorCorrectLevel.M;
    }
  }
}
