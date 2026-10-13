import 'package:flutter/material.dart';
import 'package:flutter_application_brt_bub/brt.dart';
import 'package:flutter_application_brt_bub/data/bay_many.dart';
import 'package:flutter_application_brt_bub/data/hitory_bay.dart';
import 'package:flutter_application_brt_bub/data/setting.dart';
import 'package:flutter_application_brt_bub/hitory_tikete.dart';
import 'package:flutter_application_brt_bub/tikkets.dart';
import 'bus_page.dart';
import 'history_page.dart';
import 'account_payment_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "ຂໍ້ມູນສ່ວນຕົວ",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 218, 129, 45),
        automaticallyImplyLeading:
            false, // ບໍ່ໃຫ້ມີປຸ່ມ back ເພາະມີ bottom bar ແລ້ວ
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ຮູບ Profile Placeholder
            const Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFF2E5F8A),
                child: Icon(Icons.person, size: 70, color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "ໍHannalong Savayvanh",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "toppy20003@brtlaos.com",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // ເມນູຕ່າງໆ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.history, color: Colors.blue),
                      title: const Text("ປະຫວັດການຊື້ປີ້"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => HistoryPage()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.payment, color: Colors.green),
                      title: const Text("ບັນຊີ/ ວິທີຈ່າຍເງິນ"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AccountPaymentPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.grey),
                      title: const Text("ຕັ້ງຄ່າລະບົບ"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SettingsPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔻 Bottom Navigation Bar ທີ່ກົດໄດ້ແທ້
      bottomNavigationBar: Container(
        height: 60,
        color: const Color.fromARGB(255, 218, 129, 45),
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
                    builder: (_) => SuccessPage(total: 1, qty: 2),
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
