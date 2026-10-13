import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ticket_model.dart';

class TicketService {
  static final TicketService _instance = TicketService._internal();
  factory TicketService() => _instance;
  TicketService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _localCacheKey = 'brt_local_tickets_cache';

  /// ດຶງ User ID ປັດຈຸບັນ
  String get currentUserId => _auth.currentUser?.uid ?? 'guest_user';
  String get currentUserEmail => _auth.currentUser?.email ?? 'passenger@brt.com';

  /// ສ້າງ Ticket ID ແບບສະເພາະ ເຊັ່ນ: BRT-2610-8934
  static String generateTicketId() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final randomDigits = (1000 + Random().nextInt(9000)).toString();
    return 'BRT-$year$month-$randomDigits';
  }

  /// ສ້າງ QR Payload ທີ່ຖືກຕ້ອງຕາມມາດຕະຖານ BRT System
  static String generateQrPayload({
    required String ticketId,
    required String origin,
    required String destination,
    required int quantity,
    required DateTime expiresAt,
  }) {
    final payload = {
      'app': 'BRT_LAOS',
      'tid': ticketId,
      'from': origin,
      'to': destination,
      'qty': quantity,
      'exp': expiresAt.millisecondsSinceEpoch,
      'sec': Random().nextInt(999999),
    };
    return jsonEncode(payload);
  }

  /// ບັນທຶກຕົ໋ວໃໝ່ລົງ Firebase Firestore ແລະ Local Cache
  Future<TicketModel> createTicket({
    required String originStation,
    required String destinationStation,
    required int quantity,
    required int totalAmount,
    String paymentMethod = 'BCEL OnePay',
    String? transactionId,
  }) async {
    final now = DateTime.now();
    final ticketId = generateTicketId();
    final expiresAt = now.add(const Duration(hours: 24));
    final txnId = transactionId ?? 'TXN-${now.millisecondsSinceEpoch}';

    final qrPayload = generateQrPayload(
      ticketId: ticketId,
      origin: originStation,
      destination: destinationStation,
      quantity: quantity,
      expiresAt: expiresAt,
    );

    final ticket = TicketModel(
      id: ticketId,
      userId: currentUserId,
      userEmail: currentUserEmail,
      originStation: originStation,
      destinationStation: destinationStation,
      quantity: quantity,
      pricePerTicket: (quantity > 0) ? (totalAmount ~/ quantity) : totalAmount,
      totalAmount: totalAmount,
      currency: 'LAK',
      status: 'paid',
      paymentMethod: paymentMethod,
      transactionId: txnId,
      createdAt: now,
      expiresAt: expiresAt,
      qrPayload: qrPayload,
    );

    // 1. ບັນທຶກລົງ Local Cache ທັນທີ (ບໍ່ໃຫ້ພາດ)
    await _saveTicketToLocalCache(ticket);

    // 2. ບັນທຶກລົງ Firebase Firestore
    try {
      await _firestore
          .collection('tickets')
          .doc(ticket.id)
          .set(ticket.toMap())
          .timeout(const Duration(seconds: 5));
      debugPrint('Ticket saved to Firestore successfully: ${ticket.id}');
    } catch (e) {
      debugPrint('Warning: Could not save to Firestore directly (offline or rules): $e');
    }

    return ticket;
  }

  /// ດຶງລາຍການຕົ໋ວທັງໝົດຂອງ User ປັດຈຸບັນ
  Future<List<TicketModel>> getUserTickets() async {
    final List<TicketModel> tickets = [];

    // ລອງດຶງຈາກ Firebase Firestore
    try {
      final querySnapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 4));

      for (var doc in querySnapshot.docs) {
        tickets.add(TicketModel.fromMap(doc.data(), doc.id));
      }
    } catch (e) {
      debugPrint('Notice: Fallback to local cache for tickets: $e');
    }

    // ດຶງຈາກ Local Cache ມາລວມກັນ
    final cachedTickets = await _getLocalCachedTickets();
    for (var cached in cachedTickets) {
      if (!tickets.any((t) => t.id == cached.id)) {
        tickets.add(cached);
      }
    }

    // ຈັດລຽງຕາມເວລາໃໝ່ສຸດ
    tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tickets;
  }

  /// Real-time Stream ສຳລັບຟັງການປ່ຽນແປງຂອງຕົ໋ວ
  Stream<List<TicketModel>> streamUserTickets() {
    return _firestore
        .collection('tickets')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => TicketModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// ປ່ຽນສະຖານະຕົ໋ວເປັນ 'used' (ໃຊ້ແລ້ວ)
  Future<bool> markTicketAsUsed(String ticketId) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({
        'status': 'used',
        'usedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Update firestore error: $e');
    }

    // ອັບເດດ local cache
    final localList = await _getLocalCachedTickets();
    final updatedList = localList.map((t) {
      if (t.id == ticketId) {
        return t.copyWith(status: 'used', usedAt: DateTime.now());
      }
      return t;
    }).toList();
    await _saveAllTicketsToLocalCache(updatedList);
    return true;
  }

  // --- Local Cache Helpers ---
  Future<void> _saveTicketToLocalCache(TicketModel ticket) async {
    final currentList = await _getLocalCachedTickets();
    currentList.removeWhere((t) => t.id == ticket.id);
    currentList.insert(0, ticket);
    await _saveAllTicketsToLocalCache(currentList);
  }

  Future<void> _saveAllTicketsToLocalCache(List<TicketModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((t) => t.toJson()).toList();
    await prefs.setStringList(_localCacheKey, jsonList);
  }

  Future<List<TicketModel>> _getLocalCachedTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_localCacheKey) ?? [];
    return rawList
        .map((str) {
          try {
            return TicketModel.fromJson(str);
          } catch (_) {
            return null;
          }
        })
        .whereType<TicketModel>()
        .toList();
  }
}
