import 'package:flutter/material.dart';

class QrItem {
  final String id;
  final String data;
  final String title;
  final String type; // 'text', 'url', 'wifi', 'email', 'phone', 'vcard'
  final DateTime timestamp;
  final int foregroundColorValue;
  final int backgroundColorValue;
  final String errorCorrectionLevel; // 'L', 'M', 'Q', 'H'

  QrItem({
    required this.id,
    required this.data,
    required this.title,
    required this.type,
    required this.timestamp,
    required this.foregroundColorValue,
    required this.backgroundColorValue,
    required this.errorCorrectionLevel,
  });

  Color get foregroundColor => Color(foregroundColorValue);
  Color get backgroundColor => Color(backgroundColorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
        'title': title,
        'type': type,
        'timestamp': timestamp.toIso8601String(),
        'foregroundColorValue': foregroundColor.toARGB32(),
        'backgroundColorValue': backgroundColor.toARGB32(),
        'errorCorrectionLevel': errorCorrectionLevel,
      };

  factory QrItem.fromJson(Map<String, dynamic> json) => QrItem(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        data: json['data'] ?? '',
        title: json['title'] ?? 'Untitled',
        type: json['type'] ?? 'text',
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
        foregroundColorValue: json['foregroundColorValue'] ?? const Color(0xFF000000).toARGB32(),
        backgroundColorValue: json['backgroundColorValue'] ?? const Color(0xFFFFFFFF).toARGB32(),
        errorCorrectionLevel: json['errorCorrectionLevel'] ?? 'M',
      );
}
