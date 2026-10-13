import 'package:flutter/material.dart';
import 'package:flutter_application_brt_bub/proflie.dart' show ProfilePage;

import 'brt.dart' show BusPage;

class SuccessPage extends StatelessWidget {
  final int total;
  final int qty;

  const SuccessPage({super.key, required this.total, required this.qty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "ປີ້ລົດຂອງທ່ານ",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFEE6C4D),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF4CAF50),
              child: Icon(Icons.check, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            const Text(
              "ຈ່າຍເງິນສຳເລັດ!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "ສະຖານະການຈ່າຍ:",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "ຈ່າຍແລ້ວ",
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "ຍອດຕົ໋ວທີ່ໄດ້:",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  "$qty ໃບ",
                  style: const TextStyle(
                    color: Color(0xFF2F80ED),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            const Text(
              "ສະແດງ QR ນີ້ຕໍ່ເຈົ້າໜ້າທີ່ເວລານັກຂຶ້ນລົດ",
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.qr_code_2,
                size: 120,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
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
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  "ກັບຄືນໜ້າຫຼັກ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 56,
        color: const Color(0xFFD97724),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(
                Icons.home,
                color: Colors.white70,
              ), // ສີຈາງລົງບອກວ່າບໍ່ໄດ້ຢູ່ໜ້ານີ້
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const BusPage(total: 2)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white70),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SuccessPage(total: 1, qty: 2),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.person,
                color: Colors.white,
              ), // ສີແຈ້ງເພາະຢູ່ໜ້າໂປຣຟາຍ
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              }, // ຢູ່ໜ້ານີ້ແລ້ວບໍ່ຕ້ອງເຮັດຫຍັງ
            ),
          ],
        ),
      ),
    );
  }
}
