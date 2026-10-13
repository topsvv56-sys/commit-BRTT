import 'package:flutter/material.dart';
import 'package:flutter_application_brt_bub/pages/bus/bus_page.dart';
import 'package:flutter_application_brt_bub/pages/profile/payment_methods_page.dart';
import 'package:flutter_application_brt_bub/pages/profile/history_page.dart';
import 'package:flutter_application_brt_bub/pages/profile/settings_page.dart';
import 'package:flutter_application_brt_bub/pages/bus/ticket_success_page.dart';
import 'package:flutter_application_brt_bub/localization/app_language.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          tr('profile_title'),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 218, 129, 45),
        automaticallyImplyLeading: false,
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
              "Hannalong Savayvanh",
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
                      title: Text(tr('purchase_history')),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.payment, color: Colors.green),
                      title: Text(tr('payment_method')),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AccountPaymentPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.grey),
                      title: Text(tr('system_settings')),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsPage(),
                          ),
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

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 60,
        color: const Color.fromARGB(255, 218, 129, 45),
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
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
