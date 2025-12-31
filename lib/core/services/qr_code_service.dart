import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Service for generating QR codes and invitation URLs
class QRCodeService {
  static final QRCodeService _instance = QRCodeService._internal();
  factory QRCodeService() => _instance;
  QRCodeService._internal();

  /// Base URL for invitation links (can be changed to actual domain)
  static const String _invitationBaseUrl = 'https://tickdose.app/invite';
  static const String _customScheme = 'tickdose://invite';

  /// Generate invitation URL with token
  /// 
  /// [token] - Invitation token
  /// [useCustomScheme] - If true, use tickdose:// scheme, otherwise use https://
  String generateInvitationUrl(String token, {bool useCustomScheme = false}) {
    if (useCustomScheme) {
      return '$_customScheme?token=$token';
    }
    return '$_invitationBaseUrl?token=$token';
  }

  /// Get QR code widget for invitation token
  /// 
  /// [token] - Invitation token
  /// [size] - Size of the QR code widget
  /// [backgroundColor] - Background color
  /// [foregroundColor] - Foreground color
  /// [useCustomScheme] - Use custom scheme instead of HTTPS
  QrImageView generateQRWidget({
    required String token,
    required double size,
    bool useCustomScheme = false,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    try {
      final url = generateInvitationUrl(token, useCustomScheme: useCustomScheme);
      Logger.info('Generating QR code for URL: $url', tag: 'QRCodeService');
      
      return QrImageView(
        data: url,
        version: QrVersions.auto,
        size: size,
        backgroundColor: backgroundColor ?? const Color(0xFFFFFFFF),
        errorCorrectionLevel: QrErrorCorrectLevel.M,
        padding: const EdgeInsets.all(10),
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: foregroundColor ?? const Color(0xFF000000),
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: foregroundColor ?? const Color(0xFF000000),
        ),
      );
    } catch (e) {
      Logger.error('Error generating QR code: $e', tag: 'QRCodeService');
      rethrow;
    }
  }
}
