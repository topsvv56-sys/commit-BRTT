import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_application_brt_bub/pages/bus/bus_page.dart';
import 'package:flutter_application_brt_bub/pages/bus/payment_page.dart';
import 'package:flutter_application_brt_bub/pages/profile/profile_page.dart';
import 'package:flutter_application_brt_bub/localization/app_language.dart';
import 'package:flutter_application_brt_bub/models/ticket_model.dart';
import 'package:flutter_application_brt_bub/services/ticket_service.dart';
import 'package:flutter_application_brt_bub/pages/bus/ticket_success_page.dart';
import 'package:flutter_application_brt_bub/config/app_colors.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TicketService _ticketService = TicketService();
  late Future<List<TicketModel>> _ticketsFuture;
  int _selectedFilterIndex = 0; // 0: ທັງໝົດ, 1: ຈ່າຍແລ້ວ, 2: ຍັງບໍ່ທັນຈ່າຍ, 3: ສະແກນແລ້ວ

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    setState(() {
      _ticketsFuture = _ticketService.getUserTickets();
    });
  }

  String displayStatus(String status) {
    if (status == 'pending' || status == 'ຍັງບໍ່ທັນຈ່າຍ') return tr('status_pending');
    if (status == 'paid' || status == 'ຈ່າຍແລ້ວ') return tr('status_paid');
    if (status == 'used' || status == 'ໃຊ້ແລ້ວ') return tr('ticket_scan_completed');
    if (status == 'expired' || status == 'ໝົດອາຍຸ') return tr('status_expired');
    return status;
  }

  Color getStatusColor(String status) {
    if (status == 'pending') {
      return const Color(0xFFD97706); // Amber / Orange
    }
    if (status == 'paid' || status == 'ຈ່າຍແລ້ວ') {
      return AppColors.successDark; // Green
    }
    if (status == 'used' || status == 'ໃຊ້ແລ້ວ') {
      return const Color(0xFF475569); // Slate Gray
    }
    return AppColors.errorBadge;
  }

  Color getStatusBgColor(String status) {
    if (status == 'pending') {
      return const Color(0xFFFEF3C7); // Light Amber
    }
    if (status == 'paid' || status == 'ຈ່າຍແລ້ວ') {
      return const Color(0xFFDCFCE7); // Light Green
    }
    if (status == 'used' || status == 'ໃຊ້ແລ້ວ') {
      return const Color(0xFFF1F5F9); // Light Gray
    }
    return const Color(0xFFFEE2E2);
  }

  void _goToPaymentForPendingTicket(TicketModel ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          total: ticket.totalAmount,
          qty: ticket.quantity,
          originStation: ticket.originStation,
          destinationStation: ticket.destinationStation,
          existingTicketId: ticket.id,
        ),
      ),
    ).then((_) => _loadTickets());
  }

  void _showTicketDetailModal(TicketModel ticket) {
    final bool isPending = ticket.status == 'pending';
    final bool isPaid = ticket.status == 'paid';
    final bool isUsed = ticket.status == 'used';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMedium,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // ສະຖານະ Badge ໃຫຍ່
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: getStatusBgColor(ticket.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayStatus(ticket.status),
                  style: TextStyle(
                    color: getStatusColor(ticket.status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                "${tr(ticket.originStation)} ➔ ${tr(ticket.destinationStation)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "ID: ${ticket.id}",
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // QR Code Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (isPending)
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pending_actions, size: 48, color: Color(0xFFD97706)),
                            SizedBox(height: 8),
                            Text(
                              "ລໍຖ້າການໂອນຈ່າຍ",
                              style: TextStyle(
                                color: Color(0xFFD97706),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      QrImageView(
                        data: ticket.qrPayload,
                        version: QrVersions.auto,
                        size: 150.0,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: isUsed ? AppColors.textMuted : AppColors.primary,
                        ),
                      ),
                    if (isPaid) ...[
                      const SizedBox(height: 8),
                      Text(
                        tr('show_qr_to_officer'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                "${tr('price_label')} ${ticket.totalAmount} ${tr('kip')} (${ticket.quantity} ${tr('tickets_unit')})",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${tr('date_label')} ${DateFormat('dd/MM/yyyy HH:mm').format(ticket.createdAt)}",
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 20),

              if (isPending)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _goToPaymentForPendingTicket(ticket);
                    },
                    icon: const Icon(Icons.qr_code, color: AppColors.white),
                    label: Text(
                      tr('pay_now_btn'),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SuccessPage(ticket: ticket),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(tr('view_full_ticket')),
                      ),
                    ),
                    if (isPaid) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await _ticketService.markTicketAsUsed(ticket.id);
                            _loadTickets();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(tr('ticket_used_success')),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                          child: Text(
                            tr('simulate_use_ticket'),
                            style: const TextStyle(color: AppColors.white, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFBFBFB),
          appBar: AppBar(
            title: Text(
              tr('history_title'),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.primary,
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              // ແຖບເລືອກສະຖານະ (Filter Tabs)
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _buildFilterChip(0, tr('tab_all')),
                    const SizedBox(width: 8),
                    _buildFilterChip(1, tr('tab_paid')),
                    const SizedBox(width: 8),
                    _buildFilterChip(2, tr('tab_pending')),
                    const SizedBox(width: 8),
                    _buildFilterChip(3, tr('tab_used')),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              Expanded(
                child: FutureBuilder<List<TicketModel>>(
                  future: _ticketsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }

                    final List<TicketModel> allList = snapshot.data ?? [];
                    final filteredList = allList.where((item) {
                      if (_selectedFilterIndex == 1) return item.status == 'paid';
                      if (_selectedFilterIndex == 2) return item.status == 'pending';
                      if (_selectedFilterIndex == 3) return item.status == 'used';
                      return true; // 0: ທັງໝົດ
                    }).toList();

                    if (filteredList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.confirmation_number_outlined,
                              size: 64,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              tr('no_tickets_history'),
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const BusPage(total: 7000),
                                  ),
                                );
                              },
                              child: Text(
                                tr('go_buy_tickets'),
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _loadTickets(),
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt);
                          final isPending = item.status == 'pending';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isPending ? const Color(0xFFFFFBEB) : AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isPending ? const Color(0xFFFDE68A) : const Color(0xFFF1F5F9),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () => _showTicketDetailModal(item),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // ໄອຄອນ
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: getStatusBgColor(item.status),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            isPending
                                                ? Icons.pending_actions
                                                : item.status == 'paid'
                                                    ? Icons.qr_code_2
                                                    : Icons.done_all,
                                            color: getStatusColor(item.status),
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // ຂໍ້ມູນເສັ້ນທາງ
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${tr(item.originStation)} ➔ ${tr(item.destinationStation)}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                "${tr('date_label')} $dateStr",
                                                style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // ປ້າຍສະຖານະ
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: getStatusBgColor(item.status),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            displayStatus(item.status),
                                            style: TextStyle(
                                              color: getStatusColor(item.status),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 18, color: Color(0xFFF1F5F9)),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${item.totalAmount} ${tr('kip')} (${item.quantity} ${tr('tickets_unit')})",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: AppColors.textNavy,
                                          ),
                                        ),

                                        if (isPending)
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                              elevation: 0,
                                            ),
                                            onPressed: () => _goToPaymentForPendingTicket(item),
                                            icon: const Icon(Icons.arrow_forward, size: 14, color: AppColors.white),
                                            label: Text(
                                              tr('pay_now_btn'),
                                              style: const TextStyle(
                                                color: AppColors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        else if (item.status == 'paid')
                                          Row(
                                            children: [
                                              const Icon(Icons.qr_code, size: 14, color: AppColors.primary),
                                              const SizedBox(width: 4),
                                              Text(
                                                tr('ready_to_board'),
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          Text(
                                            tr('ticket_scan_completed'),
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 11,
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
                      ),
                    );
                  },
                ),
              ),
            ],
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const BusPage(total: 7000)),
                    );
                  },
                ),
                _buildNavItem(
                  icon: Icons.add_box,
                  label: tr('booking_nav'),
                  isActive: false,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SuccessPage(total: 7000, qty: 1),
                      ),
                    );
                  },
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: tr('profile_nav'),
                  isActive: true,
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

  Widget _buildFilterChip(int index, String label) {
    final bool isSelected = _selectedFilterIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.textNavy,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
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
              color: isActive ? AppColors.white : AppColors.white.withValues(alpha: 0.65),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.white : AppColors.white.withValues(alpha: 0.65),
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
