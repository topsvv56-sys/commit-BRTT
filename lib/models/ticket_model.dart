import 'dart:convert';

class TicketModel {
  final String id;
  final String userId;
  final String userEmail;
  final String originStation;
  final String destinationStation; // ສະຖານີປາຍທາງ
  final int quantity; // ຈຳນວນຕົ໋ວ
  final int pricePerTicket; // ລາຄາຕໍ່ໃບ (ກີບ)
  final int totalAmount; // ຍອດເງິນລວມ (ກີບ)
  final String currency; // "LAK" (ກີບ)
  final String
  status; // 'paid' (ຈ່າຍແລ້ວ), 'used' (ໃຊ້ແລ້ວ), 'expired' (ໝົດອາຍຸ)
  final String paymentMethod; // 'BCEL OnePay', 'Lao QR', 'Visa/Master'
  final String transactionId; // ລະຫັດອ້າງອີງທຸລະກຳ
  final DateTime createdAt; // ວັນເວລາທີ່ຊື້
  final DateTime? usedAt; // ວັນເວລາທີ່ສະແກນຂຶ້ນລົດ
  final DateTime expiresAt; // ວັນເວລາໝົດອາຍຸ
  final String qrPayload; // ຂໍ້ມູນ QR ສຳລັບເຈົ້າໜ້າທີ່ສະແກນກວດສອບ

  TicketModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.originStation,
    required this.destinationStation,
    required this.quantity,
    required this.pricePerTicket,
    required this.totalAmount,
    this.currency = 'LAK',
    this.status = 'paid',
    this.paymentMethod = 'BCEL OnePay',
    required this.transactionId,
    required this.createdAt,
    this.usedAt,
    required this.expiresAt,
    required this.qrPayload,
  });

  /// ແປງເປັນ Map ສຳລັບບັນທຶກລົງ Firebase Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'originStation': originStation,
      'destinationStation': destinationStation,
      'quantity': quantity,
      'pricePerTicket': pricePerTicket,
      'totalAmount': totalAmount,
      'currency': currency,
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
      'usedAt': usedAt?.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'qrPayload': qrPayload,
    };
  }

  /// ສ້າງ TicketModel ຈາກ Firestore Document Data
  factory TicketModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return TicketModel(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      originStation: map['originStation'] ?? '',
      destinationStation: map['destinationStation'] ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      pricePerTicket: (map['pricePerTicket'] as num?)?.toInt() ?? 7000,
      totalAmount: (map['totalAmount'] as num?)?.toInt() ?? 7000,
      currency: map['currency'] ?? 'LAK',
      status: map['status'] ?? 'paid',
      paymentMethod: map['paymentMethod'] ?? 'BCEL OnePay',
      transactionId: map['transactionId'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      usedAt: map['usedAt'] != null ? DateTime.tryParse(map['usedAt']) : null,
      expiresAt: map['expiresAt'] != null
          ? DateTime.tryParse(map['expiresAt']) ??
                DateTime.now().add(const Duration(hours: 24))
          : DateTime.now().add(const Duration(hours: 24)),
      qrPayload: map['qrPayload'] ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory TicketModel.fromJson(String source) =>
      TicketModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  TicketModel copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? originStation,
    String? destinationStation,
    int? quantity,
    int? pricePerTicket,
    int? totalAmount,
    String? currency,
    String? status,
    String? paymentMethod,
    String? transactionId,
    DateTime? createdAt,
    DateTime? usedAt,
    DateTime? expiresAt,
    String? qrPayload,
  }) {
    return TicketModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      originStation: originStation ?? this.originStation,
      destinationStation: destinationStation ?? this.destinationStation,
      quantity: quantity ?? this.quantity,
      pricePerTicket: pricePerTicket ?? this.pricePerTicket,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      usedAt: usedAt ?? this.usedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      qrPayload: qrPayload ?? this.qrPayload,
    );
  }
}
