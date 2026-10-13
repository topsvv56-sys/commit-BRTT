import 'dart:async';
import 'dart:math';
import 'package:flutter_application_brt_bub/models/ticket_model.dart';
import 'ticket_service.dart';

class PaymentResult {
  final bool isSuccess;
  final String transactionId;
  final String message;
  final TicketModel? ticket;

  PaymentResult({
    required this.isSuccess,
    required this.transactionId,
    required this.message,
    this.ticket,
  });
}

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  /// ສ້າງ Dynamic QR Code String ມາດຕະຖານ Lao QR / OnePay
  static String generatePaymentQrString({
    required int amount,
    required String orderRef,
    String merchantName = 'BRT Vientiane Transport',
  }) {
    // ຮູບແບບມາດຕະຖານ Lao QR Data String (EMVCo Compatible Mock)
    return 'LAOQR://PAY?mcc=4111&mc=$merchantName&ref=$orderRef&amt=$amount&cur=LAK&ver=1.0';
  }

  /// ຈຳລອງການຮັບ Webhook ຈາກລະບົບທະນາຄານ (Bank Webhook Simulation)
  Future<PaymentResult> simulateBankWebhookPayment({
    required String originStation,
    required String destinationStation,
    required int quantity,
    required int totalAmount,
    String paymentMethod = 'BCEL OnePay (Webhook)',
  }) async {
    // 1. ຈຳລອງ Network Latency ແລະ ເວລາລໍຖ້າການໂອນເງິນ (2 ວິນາທີ)
    await Future.delayed(const Duration(seconds: 2));

    // 2. ສ້າງລະຫັດ Transaction ຈາກທະນາຄານ
    final rand = 100000 + Random().nextInt(900000);
    final txnId = 'BCEL-TXN-$rand';

    // 3. ເມື່ອທະນາຄານຢືນຢັນ Webhook Status = 200 OK -> ບັນທຶກຕົ໋ວລົງຖານຂໍ້ມູນ Firebase
    final ticket = await TicketService().createTicket(
      originStation: originStation,
      destinationStation: destinationStation,
      quantity: quantity,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      transactionId: txnId,
    );

    return PaymentResult(
      isSuccess: true,
      transactionId: txnId,
      message: 'ຊຳລະເງິນສຳເລັດຜ່ານລະບົບທະນາຄານ (Webhook Verified)',
      ticket: ticket,
    );
  }
}
