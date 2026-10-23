import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import '../models/qr_item.dart';
import '../services/storage_service.dart';

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

  Color _foregroundColor = Colors.black;
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
        const SnackBar(content: Text('Please enter text or URL to generate QR code')),
      );
      return;
    }

    // Determine type
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
        content: Text('QR Code generated and saved to history!'),
        backgroundColor: Colors.green,
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
    final success = await StorageService.saveQrToGallery(_screenshotController);
    setState(() => _isSaving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'QR Code saved to gallery successfully!'
            : 'Failed to save QR Code to gallery'),
        backgroundColor: success ? Colors.green : Colors.red,
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
      const SnackBar(content: Text('Copied text to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textContent = _textController.text.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.paste),
            tooltip: 'Paste from Clipboard',
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input TextField Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _textController,
                      maxLines: 4,
                      minLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Enter text, URL, or data',
                        hintText: 'https://example.com or any message...',
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
                      icon: const Icon(Icons.bolt),
                      label: const Text('Generate QR Code'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // QR Code Live Preview Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Screenshot(
                      controller: _screenshotController,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _backgroundColor,
                          borderRadius: BorderRadius.circular(16),
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
                                        Icons.qr_code,
                                        size: 64,
                                        color: theme.colorScheme.outline
                                            .withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Your QR code will appear here',
                                        style: TextStyle(
                                          color: theme.colorScheme.outline,
                                          fontSize: 12,
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

                    // Action buttons
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
                            label: 'Share Image',
                            onPressed: _shareImage,
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.text_snippet,
                            label: 'Share Text',
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
            ),
            const SizedBox(height: 20),

            // Customization Options Expansion Tile
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                title: const Text('Advanced Customization'),
                leading: const Icon(Icons.palette),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error Correction Level
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
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('L')),
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('M')),
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('Q')),
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('H')),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Size Slider
                        Row(
                          children: [
                            const Text('QR Size:'),
                            Expanded(
                              child: Slider(
                                value: _qrSize,
                                min: 150,
                                max: 300,
                                divisions: 15,
                                label: _qrSize.round().toString(),
                                onChanged: (val) => setState(() => _qrSize = val),
                              ),
                            ),
                            Text('${_qrSize.round()}px'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Color Pickers
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
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 1),
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showColorPickerDialog(bool isForeground) {
    final colors = [
      Colors.black,
      Colors.blue.shade900,
      Colors.deepPurple,
      Colors.indigo,
      Colors.teal,
      Colors.green.shade800,
      Colors.red.shade800,
      Colors.white,
      Colors.amber.shade100,
      Colors.grey.shade200,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isForeground ? 'Select QR Color' : 'Select Background Color'),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 2),
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
