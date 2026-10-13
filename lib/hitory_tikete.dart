import 'package:flutter/material.dart';
import 'package:flutter_application_brt_bub/brt.dart';
import 'bus_page.dart'; // Import ເພື່ອກັບຄືນໜ້າທຳອິດ

class TicketPage extends StatelessWidget {
  final int total; // ຮັບຄ່າຍອດເງິນມາສະແດງໃນບິນ

  const TicketPage({super.key, required this.total, required int qty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E5F74), // ໃຊ້ໂທນສີດຽວກັນກັບໜ້າ BRT
      appBar: AppBar(
        title: const Text(
          "ປີ້ລົດເມຂອງທ່ານ",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E5F74),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 70),
                const SizedBox(height: 10),
                const Text(
                  "ຈ່າຍເງິນສຳເລັດ!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.grey),
                const SizedBox(height: 10),

                // ລາຍລະອຽດບິນ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "ສະຖານະການຈ່າຍ:",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "ຈ່າຍແລ້ວ",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "ຍອດເງິນທັງໝົດ:",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      "$total ກີບ",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),
                const Divider(color: Colors.grey),
                const SizedBox(height: 15),

                // QR Code ສຳລັບກວດປີ້ (ອັນນີ້ໃຊ້ Icon ແທນ ຫາກມີຮູບສາມາດປ່ຽນເປັນ Image.asset ໄດ້)
                const Text(
                  "ສະແດງ QR ນີ້ຕໍ່ເຈົ້າໜ້າທີ່ເວລາຂຶ້ນລົດ",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    size: 140,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 30),

                // ປຸ່ມກັບຄືນໜ້າຫຼັກ
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E5F74),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      // ລ້າງໜ້າທັງໝົດແລ້ວກັບໄປໜ້າທຳອິດ (BusPage)
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BusPage(total: 2),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "ກັບຄືນໜ້າຫຼັກ",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
