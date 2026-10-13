import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'tikkets.dart';

class PaymentPage extends StatefulWidget {
  final int total;
  final int qty;

  const PaymentPage({super.key, required this.total, this.qty = 1});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final MobileScannerController cameraController = MobileScannerController();
  final ImagePicker _picker = ImagePicker();
  String? _scannedQrData;

  // ຟັງຊັນເລືອກຮູບ QR ຈາກ Gallery ເພື່ອສະແກນ
  Future<void> _scanQrFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final BarcodeCapture? barcodes = await cameraController.analyzeImage(
        image.path,
      );

      if (barcodes != null && barcodes.barcodes.isNotEmpty) {
        setState(() {
          _scannedQrData = barcodes.barcodes.first.rawValue;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ສະແກນ QR ສຳເລັດ: $_scannedQrData')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ບໍ່ພົບ QR Code ໃນຮູບພາບນີ້')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ເກີດຂໍ້ຜິດພາດ: $e')));
      }
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F9),
      appBar: AppBar(
        title: const Text(
          "ສະແກນ QR ເພື່ອຈ່າຍເງິນ",
          style: TextStyle(
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            const Spacer(flex: 2),

            // ກ່ອງ QR Code (ກົດແລ້ວເປີດ Gallery ມາສະແກນ)
            GestureDetector(
              onTap: _scanQrFromGallery,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9ECEF),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_2,
                  size: 160,
                  color: Color(0xFF2B3A4A),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "ກົດໃສ່ຮູບ QR ເພື່ອດາວໂຫຼດສະແກນຈ່າຍເງິນ",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),

            // ສະແດງຍອດເງິນຕົວຈິງ
            Text(
              "${widget.total} ກີບ",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F80ED),
              ),
            ),

            const Spacer(flex: 3),

            // ປຸ່ມ "ຮັບບິນຢ່າງຖືກຕ້ອງ"
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97724),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SuccessPage(total: widget.total, qty: widget.qty),
                    ),
                  );
                },
                child: const Text(
                  "ຮັບບິນຢ່າງຖືກຕ້ອງ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
