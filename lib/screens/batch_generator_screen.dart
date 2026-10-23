import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/qr_item.dart';
import '../services/storage_service.dart';
import '../widgets/glass_card.dart';

class BatchGeneratorScreen extends StatefulWidget {
  const BatchGeneratorScreen({super.key});

  @override
  State<BatchGeneratorScreen> createState() => _BatchGeneratorScreenState();
}

class _BatchGeneratorScreenState extends State<BatchGeneratorScreen> {
  final TextEditingController _batchController = TextEditingController();
  List<String> _generatedItems = [];
  bool _isGenerated = false;

  @override
  void dispose() {
    _batchController.dispose();
    super.dispose();
  }

  void _generateBatch() {
    final text = _batchController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one item (one per line)')),
      );
      return;
    }

    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return;

    for (final line in lines) {
      final trimmed = line.trim();
      StorageService.addItem(QrItem(
        id: DateTime.now().millisecondsSinceEpoch.toString() + trimmed.hashCode.toString(),
        data: trimmed,
        title: 'Batch: $trimmed',
        type: trimmed.startsWith('http') ? 'url' : 'text',
        timestamp: DateTime.now(),
        foregroundColorValue: const Color(0xFF0F172A).toARGB32(),
        backgroundColorValue: Colors.white.toARGB32(),
        errorCorrectionLevel: 'M',
      ));
    }

    setState(() {
      _generatedItems = lines;
      _isGenerated = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successfully generated ${lines.length} QR codes and saved to history!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch QR Generator'),
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
                  Text(
                    'Batch Generator',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter multiple items below (one per line). Each line will generate its own QR code.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _batchController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'https://google.com\nhttps://github.com\nHello World',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _generateBatch,
                    icon: const Icon(Icons.playlist_add),
                    label: const Text('Generate All QR Codes'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_isGenerated) ...[
              Text(
                'Generated Batch Results (${_generatedItems.length})',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _generatedItems.length,
                itemBuilder: (context, index) {
                  final itemData = _generatedItems[index];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: QrImageView(
                              data: itemData,
                              version: QrVersions.auto,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itemData,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Saved to history',
                                  style: TextStyle(fontSize: 12, color: theme.colorScheme.secondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
