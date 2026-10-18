import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_application_brt_bub/pages/profile/profile_page.dart'
    show ProfilePage;
import 'package:flutter_application_brt_bub/localization/app_language.dart';
import 'package:flutter_application_brt_bub/config/app_colors.dart';
import 'package:flutter_application_brt_bub/models/ticket_model.dart';
import 'package:flutter_application_brt_bub/pages/profile/history_page.dart';
import 'bus_page.dart' show BusPage;

class SuccessPage extends StatelessWidget {
  final int total;
  final int qty;
  final TicketModel? ticket;

  const SuccessPage({super.key, this.total = 7000, this.qty = 1, this.ticket});

  @override
  Widget build(BuildContext context) {
    final int displayTotal = ticket?.totalAmount ?? total;
    final int displayQty = ticket?.quantity ?? qty;
    final String ticketId =
        ticket?.id ??
        'BRT-TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final String qrData = ticket?.qrPayload ?? 'BRT:TICKET:$ticketId:VALID';
    final String origin = ticket?.originStation ?? 'station_talatxao';
    final String destination = ticket?.destinationStation ?? 'station_dongdok';

    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BusPage(total: 7000),
                    ),
                  );
                }
              },
            ),
            title: Text(
              tr('my_tickets_title'),
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
          ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.successBadge,
              child: Icon(Icons.check, color: AppColors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              tr('pay_success'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.successBadge,
              ),
            ),
            const SizedBox(height: 16),

            // ກ່ອງຂໍ້ມູນສະຖານະຕົ໋ວ
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryBorder),
              ),
              child: Column(
                children: [
                  // ລະຫັດຕົ໋ວ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr('ticket_id_label'),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: ticketId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(tr('copied_ticket_id')),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              ticketId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.copy,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),

                  // ເສັ້ນທາງ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr('route_label'),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      Text(
                        "${tr(origin)} ➔ ${tr(destination)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ສະຖານະການຈ່າຍ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr('payment_status_label'),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tr('paid_status'),
                          style: const TextStyle(
                            color: AppColors.successBadge,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ຍອດຕົ໋ວ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr('tickets_received_label'),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "$displayQty ${tr('tickets_unit')} ($displayTotal ${tr('kip')})",
                        style: const TextStyle(
                          color: AppColors.infoBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              tr('show_qr_to_officer'),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),

            // --- QR Code ແທ້ (Dynamic Ticket QR Code) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderMedium),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 160.0,
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
                  const SizedBox(height: 8),
                  Text(
                    tr('scan_qr_hint'),
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ປຸ່ມກັບຄືນໜ້າຫຼັກ
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text(
                  tr('back_to_main_btn'),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ປຸ່ມເບິ່ງປະຫວັດການຊື້ຕົ໋ວທັງໝົດ
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                );
              },
              icon: const Icon(
                Icons.history,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                tr('purchase_history'),
                style: const TextStyle(color: AppColors.primary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: AppColors.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: tr('home_nav'),
              isActive: false,
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const BusPage(total: 7000)),
                  (route) => false,
                );
              },
            ),
            _buildNavItem(
              icon: Icons.add_box,
              label: tr('booking_nav'),
              isActive: true,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.person,
              label: tr('profile_nav'),
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppColors.white
                  : AppColors.white.withValues(alpha: 0.65),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? AppColors.white
                    : AppColors.white.withValues(alpha: 0.65),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

