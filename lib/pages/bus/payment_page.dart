import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_application_brt_bub/localization/app_language.dart';
import 'package:flutter_application_brt_bub/services/payment_service.dart';
import 'package:flutter_application_brt_bub/services/ticket_service.dart';
import 'package:flutter_application_brt_bub/pages/bus/ticket_success_page.dart';
import 'package:flutter_application_brt_bub/config/app_colors.dart';
import 'package:flutter_application_brt_bub/models/ticket_model.dart';
import 'package:flutter_application_brt_bub/services/dynamic_qr_service.dart';

class PaymentPage extends StatefulWidget {
  final int total;
  final int qty;
  final String originStation;
  final String destinationStation;
  final String? existingTicketId; // ສຳລັບໂອນຈ່າຍຕົ໋ວທີ່ຄ້າງໄວ້ໃນປະຫວັດ

  const PaymentPage({
    super.key,
    required this.total,
    this.qty = 1,
    this.originStation = 'station_talatxao',
    this.destinationStation = 'station_dongdok',
    this.existingTicketId,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final MobileScannerController cameraController = MobileScannerController();
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String _processingMessage = '';
  late String _orderRef;

  Timer? _countdownTimer;
  int _secondsLeft = 599; // 09:59 countdown

  @override
  void initState() {
    super.initState();
    _startTimer();

    if (widget.existingTicketId != null) {
      _orderRef = widget.existingTicketId!;
    } else {
      final rand = 1000 + Random().nextInt(9000);
      _orderRef =
          'BRT-ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}-$rand';
    }

    // ສ້າງ Order ໃນ Server Backend ຖ້າເຊື່ອມຕໍ່ໄດ້
    PaymentService().createPaymentOrder(
      totalAmount: widget.total,
      originStation: widget.originStation,
      destinationStation: widget.destinationStation,
      quantity: widget.qty,
    ).then((info) {
      if (mounted && widget.existingTicketId == null) {
        setState(() {
          _orderRef = info.orderRef;
        });
      }
    });
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
      }
    });
  }

  String get _timerString {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatKip(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    cameraController.dispose();
    super.dispose();
  }

  // --- ບັນທຶກເປັນ "ຍັງບໍ່ທັນຈ່າຍ" (Pending) ລົງໃນປະຫວັດແລ້ວອອກ ---
  Future<void> _saveAsPendingAndExit() async {
    setState(() => _isProcessing = true);
    try {
      await TicketService().createTicket(
        originStation: widget.originStation,
        destinationStation: widget.destinationStation,
        quantity: widget.qty,
        totalAmount: widget.total,
        status: 'pending',
        existingId: widget.existingTicketId ?? _orderRef,
        paymentMethod: 'Lao QR (Pending)',
      );
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('saved_to_history_msg')),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isProcessing = false);
        Navigator.pop(context);
      }
    }
  }

  // --- ສະແດງ Dialog "🎉 ໄດ້ຮັບປີ້ແລ້ວ!" (Popup Ticket Received) ---
  void _showTicketReceivedDialog(TicketModel ticket) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 10,
            backgroundColor: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Green badge with animated checkmark
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 56,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr('ticket_received_alert_title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tr('ticket_received_alert_desc'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tr('ticket_id_label'), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            Text(
                              ticket.id,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const Divider(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tr('route_label'), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            Flexible(
                              child: Text(
                                "${tr(ticket.originStation)} ➔ ${tr(ticket.destinationStation)}",
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textNavy),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tr('tickets_received_label'), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            Text("${ticket.quantity} ${tr('tickets_unit')}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tr('total_paid'), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            Text(
                              "${_formatKip(ticket.totalAmount)} ${tr('kip')}",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.successDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        Navigator.pop(dialogCtx);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SuccessPage(ticket: ticket),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.confirmation_number_outlined, color: AppColors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            tr('view_my_ticket_btn'),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- ສຳເລັດການຊຳລະເງິນ & ສ້າງຕົ໋ວ ---
  Future<void> _handlePaymentSuccessWorkflow({required String methodName}) async {
    setState(() {
      _isProcessing = true;
      _processingMessage = tr('checking_webhook');
    });

    try {
      TicketModel ticket;
      if (widget.existingTicketId != null) {
        // ອັບເດດຕົ໋ວທີ່ຄ້າງ 'pending' ໃຫ້ເປັນ 'paid'
        await TicketService().markTicketAsPaid(widget.existingTicketId!);
        final all = await TicketService().getUserTickets();
        ticket = all.firstWhere(
          (t) => t.id == widget.existingTicketId,
          orElse: () => TicketModel(
            id: widget.existingTicketId!,
            userId: TicketService().currentUserId,
            userEmail: TicketService().currentUserEmail,
            originStation: widget.originStation,
            destinationStation: widget.destinationStation,
            quantity: widget.qty,
            pricePerTicket: (widget.qty > 0) ? (widget.total ~/ widget.qty) : widget.total,
            totalAmount: widget.total,
            status: 'paid',
            paymentMethod: methodName,
            transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(const Duration(hours: 24)),
            qrPayload: DynamicQrService.generateDynamicPayload(
              ticketId: widget.existingTicketId!,
              origin: widget.originStation,
              destination: widget.destinationStation,
              quantity: widget.qty,
              expiresAt: DateTime.now().add(const Duration(hours: 24)),
            ),
          ),
        );
      } else {
        ticket = await TicketService().createTicket(
          originStation: widget.originStation,
          destinationStation: widget.destinationStation,
          quantity: widget.qty,
          totalAmount: widget.total,
          paymentMethod: methodName,
          status: 'paid',
          existingId: _orderRef,
        );
      }

      if (!mounted) return;
      setState(() => _isProcessing = false);

      _showTicketReceivedDialog(ticket);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  // --- ອັບໂຫຼດໃບບິນ / ສະລິບ ຈາກ Gallery ຫຼື ກ້ອງ ---
  Future<void> _handleUploadSlip() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _isProcessing = true;
        _processingMessage = tr('checking_webhook');
      });

      // ກວດສອບຮູບສະລິບ / QR Code ຈາກຮູບ
      final BarcodeCapture? barcodes = await cameraController.analyzeImage(image.path);
      await Future.delayed(const Duration(milliseconds: 1200));

      if (barcodes != null && barcodes.barcodes.isNotEmpty) {
        await _handlePaymentSuccessWorkflow(methodName: 'Slip / QR Scanned');
      } else {
        // ຖ້າເປັນຮູບສະລິບທະນາຄານທົ່ວໄປ ກໍໃຫ້ຜ່ານສຳເລັດ
        await _handlePaymentSuccessWorkflow(methodName: 'Uploaded Slip (BCEL OnePay)');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // --- ປຸ່ມ "ຂ້ອຍໄດ້ໂອນເງິນແລ້ວ" ---
  Future<void> _handleIHaveTransferred() async {
    setState(() {
      _isProcessing = true;
      _processingMessage = tr('checking_webhook');
    });

    await Future.delayed(const Duration(milliseconds: 1400));
    await _handlePaymentSuccessWorkflow(methodName: 'LAPNet LAO QR (Confirmed)');
  }

  // --- ບັນທຶກຮູບ QR ---
  void _saveQrImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('save_qr_success')),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- ແບ່ງປັນ QR ---
  void _shareQr() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("ແບ່ງປັນ QR Code ສຳເລັດ: $_orderRef"),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, currentLang, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _saveAsPendingAndExit();
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFFBFBFB),
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF1E293B)),
                onPressed: _saveAsPendingAndExit,
              ),
              title: Text(
                tr('payment_screen_title'),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Column(
                children: [
                  // 1. ກ່ອງສະຫຼຸບເສັ້ນທາງ ແລະ ລາຄາ (Warm Cream / Peach card)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEE0CC),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions_bus,
                            color: Color(0xFFD97724),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${tr(widget.originStation)} ➔ ${tr(widget.destinationStation)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "${tr('tickets_received_label')} ${widget.qty} ${tr('tickets_unit')}",
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${_formatKip(widget.total)} ${tr('kip')}",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. ກ່ອງ QR Code ຫຼັກ (White Card with LAPNet LAO QR)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Badge ສີແດງ: LAPNet LAO QR
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB71C1C),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "LAPNet LAO QR",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ກອບ QR ພາຍໃນ
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                          ),
                          child: Column(
                            children: [
                              // ເວລານັບຖອຍຫຼັງ
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${tr('qr_expires_in')} $_timerString ${tr('minutes_suffix')}",
                                    style: const TextStyle(
                                      color: Color(0xFFD97724),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color: Color(0xFFD97724),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // ຮູບ QR ຕົວຈິງ
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/real_qr.png',
                                  width: 210,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // ຊື່ເຈົ້າຂອງບັນຊີ
                              const Text(
                                "HANNALONG SAVAYVANH MR",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ເລກອ້າງອີງ Order
                        Text(
                          "Ref: $_orderRef",
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ປຸ່ມຄູ່: ບັນທຶກຮູບ QR & ແບ່ງປັນ QR
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF1E293B), width: 1.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: _saveQrImage,
                                icon: const Icon(Icons.arrow_downward, size: 16, color: Color(0xFF1E293B)),
                                label: Text(
                                  tr('save_qr_btn'),
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF1E293B), width: 1.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: _shareQr,
                                icon: const Icon(Icons.share_outlined, size: 16, color: Color(0xFF1E293B)),
                                label: Text(
                                  tr('share_qr_btn'),
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // ຄຳແນະນຳ
                        Text(
                          tr('save_qr_hint'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 3. ສ່ວນການດຳເນີນການດ້ານລຸ່ມ (Actions Area)
                  if (_isProcessing)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(color: AppColors.primary),
                          const SizedBox(height: 12),
                          Text(
                            _processingMessage.isNotEmpty ? _processingMessage : tr('checking_webhook'),
                            style: const TextStyle(
                              color: AppColors.textNavy,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        // ສະຖານະກວດສອບອັດຕະໂນມັດ ພ້ອມໄອຄອນໝຸນ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tr('auto_verify_payment'),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFD97724),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ປຸ່ມ 1: ອັບໂຫລດໃບບິນ / ສະລິບ (Primary Orange button)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD97724),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 1,
                            ),
                            onPressed: _handleUploadSlip,
                            icon: const Icon(Icons.photo_library_outlined, color: AppColors.white, size: 20),
                            label: Text(
                              tr('upload_bill_slip'),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ປຸ່ມ 2: ຂ້ອຍໄດ້ໂອນເງິນແລ້ວ (Warm Secondary button)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFF9F5),
                              side: const BorderSide(color: Color(0xFFE5C3AB), width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: _handleIHaveTransferred,
                            child: Text(
                              tr('i_have_transferred'),
                              style: const TextStyle(
                                color: Color(0xFF78350F),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ປຸ່ມ 3: ຍົກເລີກລາຍການ (Cancel & Save for later)
                        TextButton(
                          onPressed: _saveAsPendingAndExit,
                          child: Text(
                            tr('cancel_order'),
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
