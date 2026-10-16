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
  late String _orderRef;
  late String _paymentQrData;

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
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  // --- 1. ຈຳລອງການຮັບ Webhook ຈາກລະບົບທະນາຄານ (Webhook Simulation) ---
  Future<void> _handleWebhookSimulation() async {
    setState(() => _isProcessing = true);

    try {
      final result = await PaymentService().simulateBankWebhookPayment(
        originStation: widget.originStation,
        destinationStation: widget.destinationStation,
        quantity: widget.qty,
        totalAmount: widget.total,
        paymentMethod: 'BCEL OnePay (Webhook)',
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (result.isSuccess && result.ticket != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SuccessPage(ticket: result.ticket!),
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

  // --- 2. ຢືນຢັນການຊຳລະເງິນທົ່ວໄປ (ບັນທຶກລົງຖານຂໍ້ມູນ Firebase) ---
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SuccessPage(ticket: ticket)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  // --- 3. ສະແກນ QR ຈາກ Gallery ---
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
            const SizedBox(height: 16),

            // ກ່ອງ QR Code ຕົວຈິງ (Lao QR / BCEL OnePay Dynamic QR)
            Container(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "LAO QR / OnePay",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // QR Code ແທ້ (Dynamic Generated QR)
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
                  const SizedBox(height: 10),

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
            const SizedBox(height: 24),

            if (_isProcessing)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 10),
                    Text(
                      tr('checking_webhook'),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  // ປຸ່ມ 1: ຈຳລອງ Webhook ຈາກທະນາຄານ (Instant Simulation)
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                        elevation: 2,
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

                  // ປຸ່ມ 2: ຢືນຢັນການຊຳລະເງິນ & ຮັບບິນ
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _handleConfirmPayment,
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.white,
                      ),
                      label: Text(
                        tr('confirm_and_receipt'),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ປຸ່ມ 3: ສະແກນຮູບສະລິບຈາກ Gallery
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
