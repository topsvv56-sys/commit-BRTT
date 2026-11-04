import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_application_brt_bub/localization/app_language.dart';
import 'package:flutter_application_brt_bub/services/payment_service.dart';
import 'package:flutter_application_brt_bub/services/ticket_service.dart';
import 'package:flutter_application_brt_bub/pages/bus/ticket_success_page.dart';
import 'package:flutter_application_brt_bub/config/app_colors.dart';
import 'package:flutter_application_brt_bub/models/ticket_model.dart';

class PaymentPage extends StatefulWidget {
  final int total;
  final int qty;
  final String originStation;
  final String destinationStation;

  const PaymentPage({
    super.key,
    required this.total,
    this.qty = 1,
    this.originStation = 'station_talatxao',
    this.destinationStation = 'station_dongdok',
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
  late String _paymentQrData;
  int _selectedQrMode = 0; // 0: LAPNet LAO QR ແທ້, 1: Dynamic QR

  @override
  void initState() {
    super.initState();
    final rand = 1000 + Random().nextInt(9000);
    _orderRef =
        'BRT-ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}-$rand';
    _paymentQrData = PaymentService.generatePaymentQrString(
      amount: widget.total,
      orderRef: _orderRef,
    );

    // ສ້າງ Order ໃນ Server Backend ຖ້າເຊື່ອມຕໍ່ໄດ້
    PaymentService().createPaymentOrder(
      totalAmount: widget.total,
      originStation: widget.originStation,
      destinationStation: widget.destinationStation,
      quantity: widget.qty,
    ).then((info) {
      if (mounted) {
        setState(() {
          _orderRef = info.orderRef;
          _paymentQrData = info.qrData;
        });
      }
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  // --- ສະແດງ Dialog "ໄດ້ຮັບປີ້ແລ້ວ!" (Popup Ticket Received) ---
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
                  // Animated green badge
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
                              "${ticket.totalAmount} ${tr('kip')}",
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

  // --- 1. ກວດສອບ Webhook ຕົວຈິງຈາກ Server ທະນາຄານ (Real Webhook Polling) ---
  Future<void> _handleRealWebhookPolling() async {
    setState(() {
      _isProcessing = true;
      _processingMessage = tr('waiting_bank_webhook');
    });

    try {
      final result = await PaymentService().pollPaymentVerification(
        orderRef: _orderRef,
        originStation: widget.originStation,
        destinationStation: widget.destinationStation,
        quantity: widget.qty,
        totalAmount: widget.total,
        onTick: (sec) {
          if (mounted) {
            setState(() {
              _processingMessage = '${tr('waiting_bank_seconds')} (${sec}s)...';
            });
          }
        },
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (result.isSuccess && result.ticket != null) {
        _showTicketReceivedDialog(result.ticket!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.errorAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // --- 2. ຈຳລອງການຮັບ Webhook ຈາກລະບົບທະນາຄານ (Sandbox Simulation Test) ---
  Future<void> _handleWebhookSimulation() async {
    setState(() {
      _isProcessing = true;
      _processingMessage = tr('testing_sandbox');
    });

    try {
      final result = await PaymentService().simulateBankWebhookPayment(
        originStation: widget.originStation,
        destinationStation: widget.destinationStation,
        quantity: widget.qty,
        totalAmount: widget.total,
        paymentMethod: 'BCEL OnePay (Sandbox Test)',
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (result.isSuccess && result.ticket != null) {
        _showTicketReceivedDialog(result.ticket!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // --- 3. ຢືນຢັນການຊຳລະເງິນທົ່ວໄປ (ບັນທຶກລົງຖານຂໍ້ມູນ Firebase) ---
  Future<void> _handleConfirmPayment() async {
    setState(() => _isProcessing = true);

    try {
      final ticket = await TicketService().createTicket(
        originStation: widget.originStation,
        destinationStation: widget.destinationStation,
        quantity: widget.qty,
        totalAmount: widget.total,
        paymentMethod: 'Lao QR Payment',
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      _showTicketReceivedDialog(ticket);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  // --- 4. ສະແກນ QR ດ້ວຍກ້ອງສົດ (Live Camera Scanner) ---
  void _openCameraScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr('scan_qr_camera_title'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textNavy,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MobileScanner(
                          onDetect: (capture) async {
                            final barcode = capture.barcodes.firstOrNull;
                            if (barcode != null && barcode.rawValue != null) {
                              Navigator.pop(sheetCtx);
                              await _handleConfirmPayment();
                            }
                          },
                        ),
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary, width: 3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Text(
                  tr('scan_camera_hint'),
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 5. ສະແກນ QR ຈາກ Gallery ---
  Future<void> _scanQrFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final BarcodeCapture? barcodes = await cameraController.analyzeImage(
        image.path,
      );

      if (barcodes != null && barcodes.barcodes.isNotEmpty) {
        final scannedData = barcodes.barcodes.first.rawValue ?? 'Valid Slip';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${tr('qr_scanned_success')}: $scannedData'),
            ),
          );
        }
        await _handleConfirmPayment();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(tr('no_qr_found_image'))));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: AppColors.tabBarBg,
          appBar: AppBar(
            title: Text(
              tr('scan_qr_title'),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.primary,
            centerTitle: false,
            titleSpacing: 0,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              children: [
                // ກ່ອງສະແດງເສັ້ນທາງ ແລະ ລາຍລະອຽດ
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primarySurface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions_bus,
                            color: AppColors.primary,
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
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${tr('tickets_received_label')} ${widget.qty} ${tr('tickets_unit')}",
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${widget.total} ${tr('kip')}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.infoBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ແຖບສະຫຼັບ QR Code (QR ແທ້ LAPNet LAO QR ຫຼື QR ລະບົບ)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedQrMode = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: _selectedQrMode == 0 ? AppColors.primary : AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedQrMode == 0 ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_2,
                                size: 18,
                                color: _selectedQrMode == 0 ? AppColors.white : AppColors.textNavy,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tr('real_lao_qr_tab'),
                                style: TextStyle(
                                  color: _selectedQrMode == 0 ? AppColors.white : AppColors.textNavy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedQrMode = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: _selectedQrMode == 1 ? AppColors.primary : AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedQrMode == 1 ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: _selectedQrMode == 1 ? AppColors.white : AppColors.textNavy,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tr('dynamic_qr_tab'),
                                style: TextStyle(
                                  color: _selectedQrMode == 1 ? AppColors.white : AppColors.textNavy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ກ່ອງສະແດງ QR Code
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedQrMode == 0 ? const Color(0xFFC62828) : AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedQrMode == 0 ? "LAPNet LAO QR" : "LAO QR / OnePay",
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // QR Graphic
                      if (_selectedQrMode == 0)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/real_qr.png',
                              width: 210,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                      else
                        QrImageView(
                          data: _paymentQrData,
                          version: QrVersions.auto,
                          size: 190.0,
                          backgroundColor: AppColors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppColors.primary,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: AppColors.textNavy,
                          ),
                        ),
                      const SizedBox(height: 12),

                      Text(
                        "Ref: $_orderRef",
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr('qr_hint'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_isProcessing)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(color: AppColors.primary),
                        const SizedBox(height: 12),
                        Text(
                          _processingMessage.isNotEmpty ? _processingMessage : tr('checking_webhook'),
                          style: const TextStyle(color: AppColors.textNavy, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr('bcel_app_hint'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      // ປຸ່ມ 1: ສະແກນ QR ຜ່ານກ້ອງ (Scan QR via Camera)
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _openCameraScanner,
                          icon: const Icon(Icons.qr_code_scanner, color: AppColors.white),
                          label: Text(
                            tr('scan_qr_camera_btn'),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ປຸ່ມ 2: ກວດສອບ Webhook ຈາກທະນາຄານຕົວຈິງ (Real Bank Webhook Polling)
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonBgNavy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                            ),
                            elevation: 1,
                          ),
                          onPressed: _handleRealWebhookPolling,
                          icon: const Icon(Icons.sync, color: AppColors.white),
                          label: Text(
                            tr('check_webhook_real_btn'),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ປຸ່ມ 3: ຈຳລອງ Webhook ຈາກທະນາຄານ (Sandbox Instant Test)
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _handleWebhookSimulation,
                          icon: const Icon(Icons.flash_on, color: AppColors.white),
                          label: Text(
                            tr('simulate_webhook'),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ປຸ່ມ 4: ຢືນຢັນການຊຳລະເງິນ & ຮັບປີ້ (Manual Confirm)
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                            ),
                          ),
                          onPressed: _handleConfirmPayment,
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            tr('confirm_and_receipt'),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ປຸ່ມ 5: ສະແກນຮູບສະລິບຈາກ Gallery
                      TextButton.icon(
                        onPressed: _scanQrFromGallery,
                        icon: const Icon(
                          Icons.photo_library,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        label: Text(
                          tr('upload_slip_qr'),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
