import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BUS extends StatefulWidget {
  final int total;
  const BUS({super.key, required this.total});

  @override
  State<BUS> createState() => _BUSState();
}

class _BUSState extends State<BUS> {
  // URL ສຳລັບດຶງຂໍ້ມູນລົດເມ (ສາມາດປ່ຽນໄດ້ໃນແອັບ)
  String _apiUrl = 'http://174.138.25.208:10200/api/buses';
  Future<List<dynamic>>? _busFuture;
  bool _isUsingFallback = false;
  String _statusMessage = '';

  // ຂໍ້ມູນສຳຮອງ (Fallback / Mock Data) ກໍລະນີເຊີເວີຍັງບໍ່ເປີດ ຫຼື Host Not Found
  final List<Map<String, dynamic>> _mockBuses = [
    {
      'id': 1,
      'bus_name': 'BRT Express 01',
      'driver': 'ສົມພອນ (Somphone)',
      'route': 'Dongdok -> Talat Sao (ຕະຫຼາດເຊົ້າ)',
      'time': '06:30 - 18:30 (ທຸກໆ 15 ນາທີ)',
      'price': 7000,
    },
    {
      'id': 2,
      'bus_name': 'BRT City Line 02',
      'driver': 'ບຸນມີ (Bounmy)',
      'route': 'Talat Sao -> Wattay Airport (ສະໜາມບິນວັດໄຕ)',
      'time': '07:00 - 20:00 (ທຸກໆ 20 ນາທີ)',
      'price': 7000,
    },
    {
      'id': 3,
      'bus_name': 'BRT Shuttle 03',
      'driver': 'ຄຳຫຼ້າ (Khamla)',
      'route': 'Talat Sao -> ITECC Mall -> Thanaleng',
      'time': '06:00 - 19:00 (ທຸກໆ 30 ນາທີ)',
      'price': 10000,
    },
    {
      'id': 4,
      'bus_name': 'BRT Express 04',
      'driver': 'ສົມສັກ (Somsack)',
      'route': 'Dongdok -> National University -> Center',
      'time': '07:30 - 17:30 (ທຸກໆ 20 ນາທີ)',
      'price': 7000,
    },
  ];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _busFuture = fetchBus();
    });
  }

  /// ດຶງຂໍ້ມູນລົດເມຈາກ API ພ້ອມລະບົບ Fallback ປ້ອງກັນແອັບ Error
  Future<List<dynamic>> fetchBus() async {
    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _isUsingFallback = false;
          _statusMessage = 'ເຊື່ອມຕໍ່ API ສຳເລັດ (Online)';
        });

        if (data is Map && data.containsKey('user') && data['user'] is List) {
          return data['user'];
        } else if (data is Map &&
            data.containsKey('buses') &&
            data['buses'] is List) {
          return data['buses'];
        } else if (data is List) {
          return data;
        }
      }
    } catch (e) {
      debugPrint('API Error: $e -> ໃຊ້ຂໍ້ມູນ Mock ສຳຮອງແທນ');
    }

    // ຖ້າ API ເກີດຂໍ້ຜິດພາດ (ເຊັ່ນ ENOTFOUND / 404 / Offline) ໃຫ້ສະແດງຂໍ້ມູນ Mock ແທນ
    setState(() {
      _isUsingFallback = true;
      _statusMessage = 'ກຳລັງສະແດງຂໍ້ມູນຈຳລອງ (API Offline / Mock Mode)';
    });

    return _mockBuses;
  }

  /// Dialog ສຳລັບປ່ຽນ URL API ຕາມໃຈຜູ້ໃຊ້
  void _showChangeUrlDialog() {
    final controller = TextEditingController(text: _apiUrl);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('ຕັ້ງຄ່າ API URL'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ປ້ອນ URL ຂອງ Server API ທີ່ຕ້ອງການທົດສອບ:',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'http://174.138.25.208:10200/api/buses',
                  labelText: 'API Endpoint',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ຍົກເລີກ'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97724),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final newUrl = controller.text.trim();
                if (newUrl.isNotEmpty) {
                  setState(() {
                    _apiUrl = newUrl;
                  });
                  Navigator.pop(ctx);
                  _refreshData();
                }
              },
              child: const Text('ບັນທຶກ ແລະ ໂຫຼດໃໝ່'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD97724),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'BRT Bus Schedule & API',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'ຕັ້ງຄ່າ URL',
            onPressed: _showChangeUrlDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'ໂຫຼດຂໍ້ມູນໃໝ່',
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Column(
        children: [
          // แถบแจ้งเตือนสถานะการเชื่อมต่อ API
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _isUsingFallback ? Colors.amber.shade100 : Colors.green.shade100,
            child: Row(
              children: [
                Icon(
                  _isUsingFallback ? Icons.info_outline : Icons.check_circle_outline,
                  size: 18,
                  color: _isUsingFallback ? Colors.amber.shade900 : Colors.green.shade800,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage.isEmpty
                        ? 'ກຳລັງໂຫຼດຂໍ້ມູນ...'
                        : _statusMessage,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isUsingFallback
                          ? Colors.amber.shade900
                          : Colors.green.shade800,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 24),
                  ),
                  onPressed: _showChangeUrlDialog,
                  child: const Text('ປ່ຽນ URL', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          // รายการรถบัส
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _busFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD97724),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'ບໍ່ພົບຂໍ້ມູນລົດເມ',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final List<dynamic> buses = snapshot.data!;

                return RefreshIndicator(
                  color: const Color(0xFFD97724),
                  onRefresh: () async => _refreshData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: buses.length,
                    itemBuilder: (context, index) {
                      final item = buses[index];
                      final id = item['id']?.toString() ?? '${index + 1}';
                      final name = item['bus_name'] ?? item['busname'] ?? 'BRT Bus';
                      final driver = item['driver'] ?? 'ບໍ່ມີຊື່ຄົນຂັບ';
                      final route = item['route'] ?? 'ສາຍທາງທົ່ວໄປ';
                      final time = item['time'] ?? '06:00 - 18:00';
                      final price = item['price']?.toString() ?? '7,000';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFFD97724).withValues(alpha: 0.15),
                                child: Text(
                                  id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD97724),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person_pin,
                                          size: 15,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'ຄົນຂັບ: $driver',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.alt_route,
                                          size: 15,
                                          color: Color(0xFFD97724),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            route,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          size: 15,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          time,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD97724).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$price ກີບ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFD97724),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
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
          ),
        ],
      ),
    );
  }
}
