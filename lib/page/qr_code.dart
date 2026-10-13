import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_application_brt_bub/data/app_language.dart';
import 'package:flutter_application_brt_bub/data/payment_service.dart';
import 'package:flutter_application_brt_bub/data/ticket_service.dart';
import 'package:flutter_application_brt_bub/tikkets.dart';

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
    _orderRef = 'BRT-ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}-$rand';
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
            backgroundColor: Colors.green,
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
        SnackBar(content: Text('Payment Error: $e'), backgroundColor: Colors.red),
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
        MaterialPageRoute(
          builder: (_) => SuccessPage(ticket: ticket),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
            SnackBar(content: Text('${tr('qr_scanned_success')}: $scannedData')),
          );
        }
        await _handleConfirmPayment();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr('no_qr_found_image'))),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F9),
      appBar: AppBar(
        title: Text(
          tr('scan_qr_title'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFD97724),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
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
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${tr('tickets_received_label')} ${widget.qty} ${tr('tickets_unit')}",
                            style: const TextStyle(
                              color: Colors.grey,
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
                        color: Color(0xFF2F80ED),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
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
                          color: const Color(0xFFD97724),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "LAO QR / OnePay",
                          style: TextStyle(
                            color: Colors.white,
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
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFFD97724),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF2B3A4A),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    "Ref: $_orderRef",
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr('qr_hint'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFFD97724)),
                    SizedBox(height: 10),
                    Text(
                      "ກຳລັງກວດສອບການໂອນເງິນຈາກທະນາຄານ (Webhook)...",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
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
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _handleWebhookSimulation,
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      label: const Text(
                        "ຈຳລອງການຊຳລະເງິນ (Simulate Webhook)",
                        style: TextStyle(
                          color: Colors.white,
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
                        backgroundColor: const Color(0xFFD97724),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _handleConfirmPayment,
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: Text(
                        tr('confirm_and_receipt'),
                        style: const TextStyle(
                          color: Colors.white,
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
                    icon: const Icon(Icons.photo_library, size: 18, color: Colors.blueGrey),
                    label: const Text(
                      "ອັບໂຫລດຮູບ QR / ສະລິບຈາກເຄື່ອງ",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 13),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
