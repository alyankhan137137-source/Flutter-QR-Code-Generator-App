import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/qr_item.dart';
import 'dart:io';

class StorageService {
  static const String _storageKey = 'qr_generator_history_v1';

  // Save QR history list
  static Future<void> saveHistory(List<QrItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  // Load QR history list
  static Future<List<QrItem>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey);
    if (jsonList == null) return [];
    try {
      return jsonList
          .map((itemStr) => QrItem.fromJson(jsonDecode(itemStr)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Add a single item to history
  static Future<List<QrItem>> addItem(QrItem newItem) async {
    final items = await loadHistory();
    // Avoid duplicate exact data at top if exists, or just prepend
    items.insert(0, newItem);
    // Keep max 100 items
    if (items.length > 100) {
      items.removeRange(100, items.length);
    }
    await saveHistory(items);
    return items;
  }

  // Delete item by ID
  static Future<List<QrItem>> deleteItem(String id) async {
    final items = await loadHistory();
    items.removeWhere((item) => item.id == id);
    await saveHistory(items);
    return items;
  }

  // Clear all history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // Capture screenshot and save to gallery
  static Future<bool> saveQrToGallery(ScreenshotController controller) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      final imageBytes = await controller.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0,
      );

      if (imageBytes == null) return false;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageBytes);

      await Gal.putImage(file.path, album: 'QR Generator');
      return true;
    } catch (e) {
      debugPrint('Error saving to gallery: $e');
      return false;
    }
  }

  // Share QR Image
  static Future<void> shareQrImage(ScreenshotController controller, String text) async {
    try {
      final imageBytes = await controller.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0,
      );

      if (imageBytes == null) return;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out this QR Code: $text',
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  // Share Text
  static Future<void> shareText(String text) async {
    await Share.share(text);
  }
}
