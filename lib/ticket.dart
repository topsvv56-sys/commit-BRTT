import 'package:flutter/material.dart';
import 'package:flutter_application_brt_bub/brt.dart';
import 'package:flutter_application_brt_bub/page/qr_code.dart';
import 'package:flutter_application_brt_bub/proflie.dart';
import 'package:flutter_application_brt_bub/tikkets.dart';
import 'package:flutter_application_brt_bub/data/app_language.dart';

class BRTpage extends StatefulWidget {
  final int total;
  const BRTpage({super.key, required this.total, required int qty});

  @override
  State<BRTpage> createState() => _BRTpageState();
}

class _BRTpageState extends State<BRTpage> {
  String? startStation;
  String? endStation;

  final List<String> stationKeys = [
    "station_talatxao",
    "station_dongdok",
    "station_thatluang",
    "station_sihom",
    "station_sikeut",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 218, 129, 45),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: const Color.fromARGB(255, 211, 69, 9),
                child: Text(
                  tr('select_origin_title'),
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(12),
                height: 220,
                width: double.infinity,
                child: Image.asset(
                  "assets/images/map.png",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.map, size: 60, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('origin_station'), style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 236, 64, 17),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButton<String>(
                        value: startStation,
                        hint: Text(tr('select_hint')),
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: stationKeys
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(tr(s)),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => startStation = val),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('destination_station'), style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 198, 58, 27),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButton<String>(
                        value: endStation,
                        hint: Text(
                          tr('select_hint'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        dropdownColor: const Color(0xFF1E5F74),
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: stationKeys
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  tr(s),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => endStation = val),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 211, 69, 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      if (startStation == null || endStation == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(tr('please_select_all_stations')),
                          ),
                        );
                        return;
                      }

                      if (startStation == endStation) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(tr('same_station_error')),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentPage(total: widget.total),
                        ),
                      );
                    },
                    child: Text(
                      tr('calculate_route_btn'),
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: const Color.fromARGB(255, 211, 69, 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white70),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const BusPage(total: 3)),
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
