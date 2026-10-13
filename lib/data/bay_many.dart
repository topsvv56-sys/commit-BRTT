import 'package:flutter/material.dart';
import 'package:flutter_application_brt_bub/AddPaymentPage.dart';

class AccountPaymentPage extends StatelessWidget {
  const AccountPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ບັນຊີ / ວິທີຈ່າຍເງິນ",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 218, 129, 45),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ວິທີຈ່າຍເງິນຂອງຂ້ອຍ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // ກາດສະແດງບັນຊີ BCEL One ທີ່ຜູກໄວ້
            Card(
              color: Colors.blue.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "BCEL One / OnePay",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.account_balance,
                          color: Colors.white,
                          size: 30,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "•••• •••• •••• 4567",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ສົມສັກ ພັນທະວົງ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "ສະຖານະ: ຜູກແລ້ວ",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ປຸ່ມເພີ່ມວິທີຈ່າຍເງິນໃໝ່
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Color(0xFF2E5F8A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPaymentPage()),
                );
              },
              icon: const Icon(Icons.add, color: Color(0xFF2E5F8A)),
              label: const Text(
                "ເພີ່ມບັນຊີ ຫຼື ບັດອື່ນໆ",
                style: TextStyle(color: Color(0xFF2E5F8A), fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
