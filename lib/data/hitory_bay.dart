import 'package:flutter/material.dart';
import 'package:flutter_application_brt_bub/brt.dart';
import 'package:flutter_application_brt_bub/proflie.dart';
import '../tikkets.dart'; // ຖ້າ tikkets.dart ຢູ່ lib/

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ຂໍ້ມູນຕົວຢ່າງປະຫວັດການຊື້ປີ້ຕາມ UI ຮູບທີ 4
    final List<Map<String, String>> historyList = [
      {
        "date": "30/06/2026",
        "route": "ຕະຫຼາດເຊົ້າ -> ດົງໂດກ",
        "price": "14,000 ກີບ",
        "status": "ໃຊ້ແລ້ວ",
      },
      {
        "date": "28/06/2026",
        "route": "ສີຫອມ -> ທາດຫຼວງ",
        "price": "7,000 ກີບ",
        "status": "ໃຊ້ແລ້ວ",
      },
      {
        "date": "25/06/2026",
        "route": "ດົງໂດກ -> ສີເກີດ",
        "price": "21,000 ກີບ",
        "status": "ໝົດອາຍຸ",
      },
    ];

    Color getStatusColor(String status) {
      switch (status) {
        case 'ຈ່າຍແລ້ວ':
          return const Color(0xFF2F80ED); // ສີຟ້າ
        case 'ໃຊ້ແລ້ວ':
          return const Color(0xFF4CAF50); // ສີຂຽວ
        case 'ໝົດອາຍຸ':
          return const Color(0xFFE53935); // ສີແດງ
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F9), // ພື້ນຫຼັງສີຂາວອົມຊົມພູ
      appBar: AppBar(
        title: const Text(
          "ປະຫວັດການຊື້ປີ້",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFD97724), // ສີສົ້ມຕາມແບບ UI
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyList.length,
        itemBuilder: (context, index) {
          final item = historyList[index];
          final bool isUsed = item["status"] == "ໃຊ້ແລ້ວ";

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EBF0), // ສີກອບອົມຊົມພູອ່ອນ
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // ໄອຄອນຕົ໋ວໃນກອບສີຂາວ
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300, width: 1),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    color: Colors.green,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),

                // ຂໍ້ມູນເສັ້ນທາງ, ວັນທີ ແລະ ລາຄາ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["route"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "ວັນທີ: ${item["date"]}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        "ລາຄາ: ${item["price"]}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // ສະຖານະ (ໃຊ້ແລ້ວ / ໝົດອາຍຸ)
                Text(
                  item["status"]!,
                  style: TextStyle(
                    color: isUsed
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE53935),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                    builder: (_) => SuccessPage(total: 7000, qty: 1),
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
