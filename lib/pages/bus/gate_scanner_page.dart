import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_application_brt_bub/config/app_colors.dart';
import 'package:flutter_application_brt_bub/services/ticket_service.dart';
import 'package:flutter_application_brt_bub/services/dynamic_qr_service.dart';

/// ໜ້າລະບົບກວດສອບຕົ໋ວໂດຍສານສຳລັບເຈົ້າໜ້າທີ່ ແລະ ປະຕູກັ້ນສະຖານີ (Gate / Turnstile Inspector)
class GateScannerPage extends StatefulWidget {
  const GateScannerPage({super.key});

  @override
  State<GateScannerPage> createState() => _GateScannerPageState();
}

class _GateScannerPageState extends State<GateScannerPage> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;
  String _currentStation = 'ST_TALATXAO';
  String _gateMode = 'ENTRY'; // 'ENTRY' หรือ 'EXIT'
  final List<Map<String, dynamic>> _scanHistory = [];

  final List<Map<String, String>> _stations = [
    {'id': 'ST_TALATXAO', 'name': 'ຕະຫຼາດເຊົ້າ (Talat Sao)'},
    {'id': 'ST_DONGDOK', 'name': 'ດົງໂດກ (Dongdok)'},
    {'id': 'ST_THATLUANG', 'name': 'ທາດຫຼວງ (That Luang)'},
    {'id': 'ST_AIRPORT', 'name': 'ສະໜາມບິນວັດໄຕ (Wattay Airport)'},
  ];

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final rawData = barcode.rawValue!;
    setState(() => _isProcessing = true);

    try {
      final result = await TicketService().validateAndUseTicket(
        rawQrPayload: rawData,
        stationId: _currentStation,
        staffId: 'STAFF-${_gateMode.toLowerCase()}-01',
      );

      if (!mounted) return;
      setState(() {
        _scanHistory.insert(0, {
          'ticketId': result.ticketId ?? 'Unknown',
          'status': result.status,
          'message': result.message,
          'time': DateTime.now(),
          'isValid': result.isValid,
        });
      });

      _showScanFeedbackSheet(result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      // Delay เล็กน้อยก่อนเปิดรับ scan ถัดไป
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showScanFeedbackSheet(TicketValidationResult result) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isSuccess = result.isValid;
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (isSuccess ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isSuccess ? AppColors.successBadge : AppColors.errorAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check : Icons.close,
                  color: AppColors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isSuccess ? 'ຜ່ານປະຕູໄດ້ (VALID)' : 'ບໍ່ສາມາດຜ່ານໄດ້ (REJECTED)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? AppColors.successDark : AppColors.errorAccent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                result.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              if (result.ticketId != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ticket Ref:', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      Text(
                        result.ticketId!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? AppColors.successDark : AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('ຕົກລົງ / Scan Next', style: TextStyle(color: AppColors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text(
          'ລະບົບກວດສອບຕົ໋ວ / Gate Scanner',
          style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: AppColors.white),
            onPressed: () => _cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Station & Mode Selector Header
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _currentStation,
                      isExpanded: true,
                      items: _stations.map((s) {
                        return DropdownMenuItem(
                          value: s['id'],
                          child: Text(s['name']!, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _currentStation = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'ENTRY', label: Text('ຂາເຂົ້າ')),
                    ButtonSegment(value: 'EXIT', label: Text('ຂາອອກ')),
                  ],
                  selected: {_gateMode},
                  onSelectionChanged: (set) => setState(() => _gateMode = set.first),
                ),
              ],
            ),
          ),

          // Camera Viewport
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _cameraController,
                  onDetect: _handleBarcodeDetected,
                ),
                // Scanner Overlay Viewport
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isProcessing ? AppColors.warning : AppColors.primary,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isProcessing
                          ? 'ກຳລັງກວດສອບຕົ໋ວກັບຖານຂໍ້ມູນ...'
                          : 'ສ່ອງ QR Code ຕົ໋ວໂດຍສານທີ່ນີ້',
                      style: const TextStyle(color: AppColors.white, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Recent Scans List
          Expanded(
            flex: 3,
            child: Container(
              color: AppColors.surfaceWhite,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ປະຫວັດການສະແກນຫຼ້າສຸດ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        '${_scanHistory.length} ລາຍການ',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _scanHistory.isEmpty
                        ? const Center(
                            child: Text(
                              'ຍັງບໍ່ມີປະຫວັດການສະແກນ',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _scanHistory.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (ctx, idx) {
                              final item = _scanHistory[idx];
                              final isOk = item['isValid'] as bool;
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  isOk ? Icons.check_circle : Icons.cancel,
                                  color: isOk ? AppColors.success : AppColors.errorAccent,
                                  size: 20,
                                ),
                                title: Text(
                                  item['ticketId'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                subtitle: Text(
                                  item['message'] as String,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
