import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_application_brt_bub/pages/bus/bus_page.dart';
import 'package:flutter_application_brt_bub/pages/profile/profile_page.dart';
import 'package:flutter_application_brt_bub/localization/app_language.dart';
import 'package:flutter_application_brt_bub/models/ticket_model.dart';
import 'package:flutter_application_brt_bub/services/ticket_service.dart';
import 'package:flutter_application_brt_bub/pages/bus/ticket_success_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TicketService _ticketService = TicketService();
  late Future<List<TicketModel>> _ticketsFuture;

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
    if (status == 'used' || status == 'ໃຊ້ແລ້ວ') return tr('status_used');
    if (status == 'expired' || status == 'ໝົດອາຍຸ') return tr('status_expired');
    if (status == 'paid' || status == 'ຈ່າຍແລ້ວ') return tr('status_paid');
    return status;
  }

  Color getStatusColor(String status) {
    if (status == 'paid' || status == 'ຈ່າຍແລ້ວ') {
      return const Color(0xFF2E7D32);
    }
    if (status == 'used' || status == 'ໃຊ້ແລ້ວ') {
      return Colors.blueGrey;
    }
    return const Color(0xFFE53935);
  }

  void _showTicketDetailModal(TicketModel ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "${tr(ticket.originStation)} ➔ ${tr(ticket.destinationStation)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3A4A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "ID: ${ticket.id}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // QR Code ຕົວຈິງ
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: ticket.qrPayload,
                  version: QrVersions.auto,
                  size: 150.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFFD97724),
                  ),
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
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),

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
                      ),
                      child: const Text("ເບິ່ງຕົ໋ວເຕັມໜ້າຈໍ"),
                    ),
                  ),
                  if (ticket.status == 'paid') ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97724),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _ticketService.markTicketAsUsed(ticket.id);
                          _loadTickets();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ສະແກນໃຊ້ຕົ໋ວສຳເລັດແລ້ວ!'),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "ຈຳລອງການໃຊ້ຕົ໋ວ",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F9),
      appBar: AppBar(
        title: Text(
          tr('history_title'),
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
      body: FutureBuilder<List<TicketModel>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD97724)),
            );
          }

          final List<TicketModel> list = snapshot.data ?? [];

          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "ຍັງບໍ່ມີປະຫວັດການຊື້ຕົ໋ວ",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
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
                    child: const Text("ໄປຊື້ຕົ໋ວລົດເມດຽວນີ້"),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadTickets(),
            color: const Color(0xFFD97724),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                final dateStr = DateFormat(
                  'dd/MM/yyyy HH:mm',
                ).format(item.createdAt);

                return InkWell(
                  onTap: () => _showTicketDetailModal(item),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EBF0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // ໄອຄອນຕົ໋ວໃນກອບສີຂາວ
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: getStatusColor(
                                item.status,
                              ).withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.qr_code,
                            color: getStatusColor(item.status),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // ຂໍ້ມູນເສັ້ນທາງ, ວັນທີ ແລະ ລາຄາ
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${tr(item.originStation)} ➔ ${tr(item.destinationStation)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "${tr('date_label')} $dateStr",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                "${tr('price_label')} ${item.totalAmount} ${tr('kip')} (${item.quantity} ${tr('tickets_unit')})",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ສະຖານະ
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor(
                              item.status,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
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
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 56,
        color: const Color(0xFFD97724),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white70),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const BusPage(total: 7000)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white70),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SuccessPage(total: 7000, qty: 1),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
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
  }
}
