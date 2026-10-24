import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_brt_bub/localization/app_language.dart';
import 'package:flutter_application_brt_bub/config/app_colors.dart';
import 'package:flutter_application_brt_bub/models/bus_live_location.dart';
import 'package:flutter_application_brt_bub/services/bus_tracking_service.dart';
import 'package:flutter_application_brt_bub/widgets/live_bus_tracker_card.dart';

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
          _statusMessage = tr('api_online');
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
      _statusMessage = tr('api_offline');
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
          title: Text(tr('set_api_url_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tr('enter_api_url_hint'),
                style: const TextStyle(fontSize: 13, color: AppColors.textDark),
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
              child: Text(tr('cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
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
              child: Text(tr('save_and_reload')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, currentLang, _) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                tr('bus_api_title'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              bottom: TabBar(
                indicatorColor: AppColors.white,
                indicatorWeight: 3,
                labelColor: AppColors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(icon: const Icon(Icons.list_alt, size: 20), text: tr('bus_schedules_tab')),
                  Tab(icon: const Icon(Icons.gps_fixed, size: 20), text: tr('bus_live_gps_tab')),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: tr('set_url_tooltip'),
                  onPressed: _showChangeUrlDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: tr('refresh_tooltip'),
                  onPressed: _refreshData,
                ),
              ],
            ),
            body: TabBarView(
              children: [
                Column(
                  children: [
                    // ແຖບແຈ້ງເຕືອນສະຖານະການເຊື່ອມຕໍ່ API
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: _isUsingFallback ? AppColors.warningLight : AppColors.successLight,
                      child: Row(
                        children: [
                          Icon(
                            _isUsingFallback ? Icons.info_outline : Icons.check_circle_outline,
                            size: 18,
                            color: _isUsingFallback ? AppColors.warningDark : AppColors.successDark,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _statusMessage.isEmpty
                                  ? tr('loading_data')
                                  : _statusMessage,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _isUsingFallback
                                    ? AppColors.warningDark
                                    : AppColors.successDark,
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 24),
                            ),
                            onPressed: _showChangeUrlDialog,
                            child: Text(tr('change_url_btn'), style: const TextStyle(fontSize: 12)),
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
                                color: AppColors.primary,
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Text(
                                tr('no_buses_found'),
                                style: const TextStyle(fontSize: 16, color: AppColors.textMuted),
                              ),
                            );
                          }

                          final List<dynamic> buses = snapshot.data!;

                          return RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () async => _refreshData(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: buses.length,
                              itemBuilder: (context, index) {
                                final item = buses[index];
                                final id = item['id']?.toString() ?? '${index + 1}';
                                final name = item['bus_name'] ?? item['busname'] ?? 'BRT Bus';
                                final driver = item['driver'] ?? tr('no_driver_name');
                                final route = item['route'] ?? tr('general_route');
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
                                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                          child: Text(
                                            id,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
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
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.person_pin,
                                                    size: 15,
                                                    color: AppColors.textMuted,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${tr('driver_prefix')} $driver',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: AppColors.textDark,
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
                                                    color: AppColors.primary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      route,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: AppColors.textDark,
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
                                                    color: AppColors.textMuted,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    time,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.textMuted,
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
                                                color: AppColors.primary.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '$price ${tr('kip')}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
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

                // Tab 2: ຕິດຕາມພິກັດ GPS ສົດ & ຄຳນວນ ETA ແບບ Real-time
                StreamBuilder<List<BusLiveLocation>>(
                  stream: BusTrackingService().streamLiveBuses(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }

                    final liveBuses = snapshot.data!;
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primaryBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.satellite_alt, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tr('live_gps_system_title'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      tr('live_gps_system_subtitle'),
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...liveBuses.map((b) => LiveBusTrackerCard(bus: b)),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
