import 'package:flutter/material.dart';
import 'package:flutter_application_brt_bub/ticket.dart';
import 'package:flutter_application_brt_bub/proflie.dart';
import 'package:flutter_application_brt_bub/tikkets.dart';
import 'package:flutter_application_brt_bub/data/app_language.dart';

class BusPage extends StatefulWidget {
  final int total;
  const BusPage({super.key, this.total = 7000});

  @override
  State<BusPage> createState() => _BusPageState();
}

class _BusPageState extends State<BusPage> {
  int qty = 1;
  int price = 7000;

  int get totalAmount => qty * price;

  void add() => setState(() => qty++);
  void remove() {
    if (qty > 1) setState(() => qty--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD97724),
      body: SafeArea(
        child: Column(
          children: [
            // ສ່ວນ Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                tr('sell_bus_ticket'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ສ່ວນສະແດງຮູບພາບ (ຂະຫຍາຍເຕັມຂອບ)
            Expanded(
              flex: 4,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  'assets/images/bus_ticket.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'ບໍ່ພົບໄຟລ໌ຮູບ',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ສ່ວນຂໍ້ມູນລາຄາ ແລະ ປຸ່ມກົດ
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2B49A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('price'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "7,000 ${tr('kip_per_person')}",
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 15),

                      // ສະແດງລາຄາລວມ
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 160,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Center(
                            child: Text(
                              "$totalAmount ${tr('kip')}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // ປຸ່ມບວກ/ລົບ ຈຳນວນ
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF75838F),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: add,
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6),
                              ),
                              Text(
                                "$qty",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: remove,
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // ປຸ່ມເລືອກສະຖານີ
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    BRTpage(total: totalAmount, qty: qty),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFED4C36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            tr('select_station_btn'),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white70),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SuccessPage(total: 2, qty: 2),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white70),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
