import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/qr_item.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  final Function(QrItem item) onSelectHistoryItem;

  const HistoryScreen({super.key, required this.onSelectHistoryItem});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<QrItem> _history = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final items = await StorageService.loadHistory();
    setState(() {
      _history = items;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(QrItem item) async {
    item.isFavorite = !item.isFavorite;
    await StorageService.saveHistory(_history);
    setState(() {});
  }

  Future<void> _deleteItem(String id) async {
    final updated = await StorageService.deleteItem(id);
    setState(() => _history = updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item removed from history')),
    );
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text('This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.clearHistory();
      await _loadHistory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('History cleared')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Sort: favorites first, then timestamp descending
    _history.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return b.timestamp.compareTo(a.timestamp);
    });

    final filtered = _history.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.data.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_showFavoritesOnly) {
        return matchesSearch && item.isFavorite;
      }
      return matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Favorites'),
        actions: [
          IconButton(
            icon: Icon(_showFavoritesOnly ? Icons.star : Icons.star_border),
            tooltip: _showFavoritesOnly ? 'Show All' : 'Show Favorites Only',
            onPressed: () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
          ),
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear All',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search history...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_toggle_off,
                              size: 64,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _history.isEmpty
                                  ? 'No generated QR codes yet'
                                  : 'No matching QR codes found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final formattedDate = DateFormat('MMM dd, yyyy - HH:mm')
                              .format(item.timestamp);

                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                foregroundColor:
                                    theme.colorScheme.onPrimaryContainer,
                                child: Icon(_getIconForType(item.type)),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      item.isFavorite ? Icons.star : Icons.star_border,
                                      color: item.isFavorite ? Colors.amber : Colors.grey,
                                    ),
                                    onPressed: () => _toggleFavorite(item),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.data,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () => _deleteItem(item.id),
                              ),
                              onTap: () {
                                widget.onSelectHistoryItem(item);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Loaded QR code into generator'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'url':
        return Icons.link;
      case 'wifi':
        return Icons.wifi;
      case 'vCard':
        return Icons.contact_page;
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'sms':
        return Icons.sms;
      default:
        return Icons.text_snippet;
    }
  }
}
