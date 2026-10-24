import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_brt_bub/models/ticket_model.dart';

/// ລະບົບ Offline Cache ສຳລັບເກັບຮັກສາ ແລະ ເອີ້ນເບິ່ງຕົ໋ວໂດຍສານໃນຕອນທີ່ບໍ່ມີອິນເຕີເນັດ
class OfflineTicketCache {
  static final OfflineTicketCache _instance = OfflineTicketCache._internal();
  factory OfflineTicketCache() => _instance;
  OfflineTicketCache._internal();

  static const String _storageKey = 'brt_offline_cached_tickets_v2';

  /// ບັນທຶກ ຫຼື ອັບເດດຕົ໋ວລົງໃນ Offline Storage
  Future<void> saveTicket(TicketModel ticket) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<TicketModel> all = await getCachedTickets();

      // ກວດສອບວ່າມີຢູ່ແລ້ວບໍ ຖ້າມີໃຫ້ອັບເດດ ຖ້າບໍ່ມີໃຫ້ເພີ່ມໃໝ່
      final index = all.indexWhere((t) => t.id == ticket.id);
      if (index >= 0) {
        all[index] = ticket;
      } else {
        all.insert(0, ticket);
      }

      // ຈຳກັດ cache ໄວ້ 50 ໃບຫຼ້າສຸດ
      final trimmed = all.take(50).toList();
      final jsonList = trimmed.map((t) => t.toMap()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving ticket to offline cache: $e');
    }
  }

  /// ດຶງລາຍການຕົ໋ວທັງໝົດທີ່ບັນທຶກໄວ້ໃນເຄື່ອງ
  Future<List<TicketModel>> getCachedTickets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => TicketModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading cached tickets: $e');
      return [];
    }
  }

  /// ດຶງຕົ໋ວດ່ຽວຕາມ ID
  Future<TicketModel?> getTicketById(String ticketId) async {
    final all = await getCachedTickets();
    try {
      return all.firstWhere((t) => t.id == ticketId);
    } catch (_) {
      return null;
    }
  }

  /// ອັບເດດສະຖານະຕົ໋ວໃນ Offline Storage (ເຊັ່ນ: ຖືກໃຊ້ງານແລ້ວ 'used' ຫຼື 'in_use')
  Future<void> updateTicketStatus(String ticketId, String newStatus, {DateTime? usedAt}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final all = await getCachedTickets();
      final index = all.indexWhere((t) => t.id == ticketId);

      if (index >= 0) {
        all[index] = all[index].copyWith(
          status: newStatus,
          usedAt: usedAt ?? DateTime.now(),
        );
        final jsonList = all.map((t) => t.toMap()).toList();
        await prefs.setString(_storageKey, jsonEncode(jsonList));
      }
    } catch (e) {
      debugPrint('Error updating cached ticket status: $e');
    }
  }
}
