import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/qr_item.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StorageService {
  static const String _storageKey = 'qr_generator_history_v1';

  static Future<void> saveHistory(List<QrItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

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

  static Future<List<QrItem>> addItem(QrItem newItem) async {
    final items = await loadHistory();
    items.insert(0, newItem);
    if (items.length > 100) {
      items.removeRange(100, items.length);
    }
    await saveHistory(items);
    return items;
  }

  static Future<List<QrItem>> deleteItem(String id) async {
    final items = await loadHistory();
    items.removeWhere((item) => item.id == id);
    await saveHistory(items);
    return items;
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  static Future<Map<String, dynamic>> saveQrToGallery(ScreenshotController controller) async {
    try {
      final imageBytes = await controller.capture(
        delay: const Duration(milliseconds: 150),
        pixelRatio: 3.0,
      );

      if (imageBytes == null) {
        return {
          'success': false,
          'message': 'Failed to capture QR code image.'
        };
      }

      if (kIsWeb) {
        await Share.shareXFiles(
          [XFile.fromData(imageBytes, mimeType: 'image/png', name: 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png')],
          text: 'QR Code Download',
        );
        return {
          'success': true,
          'message': 'QR code downloaded successfully!'
        };
      } else {
        try {
          final hasAccess = await Gal.hasAccess();
          if (!hasAccess) {
            final granted = await Gal.requestAccess();
            if (!granted) {
              return {
                'success': false,
                'message': 'Storage permission denied. Please allow access in app settings.'
              };
            }
          }

          await Gal.putImageBytes(imageBytes, album: 'QR Generator');
          return {
            'success': true,
            'message': 'QR code saved to gallery successfully!'
          };
        } catch (e) {
          // Fallback to share/download if gal throws on desktop/unsupported
          await Share.shareXFiles(
            [XFile.fromData(imageBytes, mimeType: 'image/png', name: 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png')],
            text: 'QR Code',
          );
          return {
            'success': true,
            'message': 'QR code exported successfully!'
          };
        }
      }
    } on GalException catch (e) {
      debugPrint('GalException saving to gallery: ${e.type.message}');
      return {
        'success': false,
        'message': e.type.message
      };
    } catch (e) {
      debugPrint('Error saving QR: $e');
      return {
        'success': false,
        'message': 'Failed to save QR code: $e'
      };
    }
  }

  static Future<void> shareQrImage(ScreenshotController controller, String text) async {
    try {
      final imageBytes = await controller.capture(
        delay: const Duration(milliseconds: 150),
        pixelRatio: 3.0,
      );

      if (imageBytes == null) return;

      await Share.shareXFiles(
        [XFile.fromData(imageBytes, mimeType: 'image/png', name: 'qr_share_${DateTime.now().millisecondsSinceEpoch}.png')],
        text: 'QR Code Data: $text',
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  static Future<void> shareText(String text) async {
    await Share.share(text);
  }
}
