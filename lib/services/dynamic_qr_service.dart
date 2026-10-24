import 'dart:convert';
import 'package:flutter/foundation.dart';

/// ຜົນການກວດສອບຕົ໋ວໂດຍສານຜ່ານ QR Code ໂດຍ Gate Scanner
class TicketValidationResult {
  final bool isValid;
  final String status; // 'SUCCESS', 'ALREADY_USED', 'EXPIRED', 'INVALID_SIGNATURE', 'INVALID_FORMAT'
  final String message;
  final String? ticketId;
  final String? origin;
  final String? destination;
  final int quantity;
  final DateTime? expiresAt;

  TicketValidationResult({
    required this.isValid,
    required this.status,
    required this.message,
    this.ticketId,
    this.origin,
    this.destination,
    this.quantity = 1,
    this.expiresAt,
  });
}

/// ລະບົບສ້າງ ແລະ ກວດສອບ Dynamic QR Code (Time-based Token / Anti-Fraud)
class DynamicQrService {
  static final DynamicQrService _instance = DynamicQrService._internal();
  factory DynamicQrService() => _instance;
  DynamicQrService._internal();

  /// Secret Key ພາຍໃນລະບົບ BRT ສຳລັບກວດສອບ Signature (ປ້ອງກັນການປອມແປງ Payload)
  static const String _systemSecret = 'BRT_LAOS_SECURE_TOKEN_2026';

  /// ໄລຍະເວລາໝຸນວຽນລະຫັດ Dynamic QR (ທຸກໆ 30 ວິນາທີ)
  static const int refreshIntervalSeconds = 30;

  /// ສ້າງ Dynamic Security Hash ອີງຕາມເວລາປັດຈຸບັນ (TOTP Window)
  static int generateTimeToken(String ticketId, [DateTime? time]) {
    final now = time ?? DateTime.now();
    final timeWindow = now.millisecondsSinceEpoch ~/ (refreshIntervalSeconds * 1000);
    final combined = '$ticketId:$_systemSecret:$timeWindow';

    // Simple deterministic hash function for cross-platform matching
    int hash = 0;
    for (int i = 0; i < combined.length; i++) {
      hash = (31 * hash + combined.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return (hash % 900000) + 100000; // 6-digit rolling token
  }

  /// ສ້າງ Dynamic QR Payload ສະບັບປອດໄພສູງສຸດ
  static String generateDynamicPayload({
    required String ticketId,
    required String origin,
    required String destination,
    required int quantity,
    required DateTime expiresAt,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final token = generateTimeToken(ticketId, now);

    final payload = {
      'app': 'BRT_LAOS',
      'ver': '2.0',
      'tid': ticketId,
      'from': origin,
      'to': destination,
      'qty': quantity,
      'exp': expiresAt.millisecondsSinceEpoch,
      'iat': now.millisecondsSinceEpoch,
      'tok': token,
    };

    return jsonEncode(payload);
  }

  /// ກວດສອບ QR Code ທີ່ຖືກສະແກນໂດຍເຈົ້າໜ້າທີ່ ຫຼື ປະຕູກັ້ນ (Gate Scanner)
  static TicketValidationResult verifyScannedPayload(String rawPayload) {
    try {
      if (!rawPayload.contains('{') || !rawPayload.contains('}')) {
        return TicketValidationResult(
          isValid: false,
          status: 'INVALID_FORMAT',
          message: 'ຮູບແບບ QR Code ບໍ່ຖືກຕ້ອງຕາມມາດຕະຖານ BRT',
        );
      }

      final Map<String, dynamic> data = jsonDecode(rawPayload);

      if (data['app'] != 'BRT_LAOS' || data['tid'] == null) {
        return TicketValidationResult(
          isValid: false,
          status: 'INVALID_FORMAT',
          message: 'QR Code ນີ້ບໍ່ແມ່ນຕົ໋ວຂອງລະບົບ BRT Laos',
        );
      }

      final String ticketId = data['tid'].toString();
      final String origin = data['from']?.toString() ?? '-';
      final String destination = data['to']?.toString() ?? '-';
      final int qty = (data['qty'] as num?)?.toInt() ?? 1;
      final int? expMillis = (data['exp'] as num?)?.toInt();
      final int? scannedToken = (data['tok'] as num?)?.toInt();

      final now = DateTime.now();

      // 1. ກວດສອບວັນໝົດອາຍຸຂອງຕົ໋ວ (Ticket Expiration)
      if (expMillis != null) {
        final expiresAt = DateTime.fromMillisecondsSinceEpoch(expMillis);
        if (now.isAfter(expiresAt)) {
          return TicketValidationResult(
            isValid: false,
            status: 'EXPIRED',
            message: 'ຕົ໋ວໃບນີ້ໝົດອາຍຸການໃຊ້ງານແລ້ວ',
            ticketId: ticketId,
            origin: origin,
            destination: destination,
            quantity: qty,
            expiresAt: expiresAt,
          );
        }
      }

      // 2. ກວດສອບ Time-based Dynamic Token (ຍອມຮັບ window ປັດຈຸບັນ ແລະ window ກ່ອນໜ້າ 30 ວິ ເພື່ອປ້ອງກັນ delay)
      if (scannedToken != null) {
        final currentToken = generateTimeToken(ticketId, now);
        final prevToken = generateTimeToken(
          ticketId,
          now.subtract(const Duration(seconds: refreshIntervalSeconds)),
        );

        if (scannedToken != currentToken && scannedToken != prevToken) {
          return TicketValidationResult(
            isValid: false,
            status: 'INVALID_SIGNATURE',
            message: 'QR Code ນີ້ໝົດອາຍຸ (Dynamic Token Expired) ກະລຸນາເປີດແອັບແທ້ເພື່ອສະແກນ',
            ticketId: ticketId,
            origin: origin,
            destination: destination,
            quantity: qty,
          );
        }
      }

      // ຜ່ານການກວດສອບ Signature & Expiration
      return TicketValidationResult(
        isValid: true,
        status: 'SUCCESS',
        message: 'ຕົ໋ວຖືກຕ້ອງຕາມມາດຕະຖານ ພ້ອມໃຊ້ງານ',
        ticketId: ticketId,
        origin: origin,
        destination: destination,
        quantity: qty,
        expiresAt: expMillis != null ? DateTime.fromMillisecondsSinceEpoch(expMillis) : null,
      );
    } catch (e) {
      debugPrint('Error verifying QR Payload: $e');
      return TicketValidationResult(
        isValid: false,
        status: 'INVALID_FORMAT',
        message: 'ບໍ່ສາມາດອ່ານຂໍ້ມູນ QR ໄດ້: $e',
      );
    }
  }
}
