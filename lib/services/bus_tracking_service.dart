import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_brt_bub/config/api_config.dart';
import 'package:flutter_application_brt_bub/models/bus_live_location.dart';

/// ລະບົບຕິດຕາມລົດເມແບບ Real-Time GPS Tracking & ຄຳນວນເວລາເຖິງໂດຍປະມານ (ETA)
class BusTrackingService {
  static final BusTrackingService _instance = BusTrackingService._internal();
  factory BusTrackingService() => _instance;
  BusTrackingService._internal();

  /// ພິກັດສະຖານີ BRT ວຽງຈັນ (Vientiane Stations GPS Coordinates)
  static final Map<String, Map<String, double>> stationCoordinates = {
    'ST_DONGDOK': {'lat': 18.0402, 'lng': 102.6324},
    'ST_NUOL': {'lat': 18.0285, 'lng': 102.6300},
    'ST_THATLUANG': {'lat': 17.9766, 'lng': 102.6366},
    'ST_TALATXAO': {'lat': 17.9667, 'lng': 102.6133},
    'ST_AIRPORT': {'lat': 17.9883, 'lng': 102.5633},
  };

  /// ຄຳນວນໄລຍະຫ່າງລະຫວ່າງ 2 ຈຸດ GPS ດ້ວຍ Haversine Formula (ຜົນລວງເປັນ ກິໂລແມັດ)
  static double calculateDistanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R * asin... (Earth radius = 6371 km)
  }

  /// ຄຳນວນເວລາເຖິງໂດຍປະມານ (ETA) ເປັນນາທີ
  static int estimateEtaMinutes({
    required double distanceKm,
    double averageSpeedKmh = 30.0,
    int stationDwellMinutes = 2,
  }) {
    if (distanceKm <= 0.2) return 1; // ໃກ້ຮອດແລ້ວ
    final travelMinutes = (distanceKm / averageSpeedKmh) * 60;
    return (travelMinutes + stationDwellMinutes).round();
  }

  /// ດຶງຂໍ້ມູນພິກັດລົດເມສົດທັງໝົດຈາກ Server Backend
  Future<List<BusLiveLocation>> getLiveBuses() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.busLiveLocations))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as List<dynamic>;
        return decoded
            .map((b) => BusLiveLocation.fromMap(b as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Backend live buses endpoint unavailable ($e), using simulated telemetry');
    }

    // Fallback: ຈຳລອງຂໍ້ມູນ GPS Telemetry ທີ່ເຄື່ອນໄຫວຈິງຕາມເສັ້ນທາງວຽງຈັນ
    return _generateSimulatedTelemetry();
  }

  /// Real-time Stream ສົ່ງພິກັດລົດເມສົດທຸກໆ 3 ວິນາທີ
  Stream<List<BusLiveLocation>> streamLiveBuses() async* {
    while (true) {
      yield await getLiveBuses();
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  /// ຈຳລອງພິກັດ GPS ສຳລັບການທົດສອບ (Simulated Bus Telemetry on Vientiane Routes)
  List<BusLiveLocation> _generateSimulatedTelemetry() {
    final now = DateTime.now();
    // ໃຊ້ວິນາທີເພື່ອຈຳລອງການເຄື່ອນໄຫວລຽບຕາມເສັ້ນທາງ
    final phase = (now.second % 60) / 60.0;

    final lat1 = 18.0402 - (18.0402 - 17.9667) * phase;
    final lng1 = 102.6324 - (102.6324 - 102.6133) * phase;
    final distToTalatxao = calculateDistanceKm(
      lat1: lat1,
      lon1: lng1,
      lat2: 17.9667,
      lon2: 102.6133,
    );

    final lat2 = 17.9667 + (17.9883 - 17.9667) * ((phase + 0.5) % 1.0);
    final lng2 = 102.6133 - (102.6133 - 102.5633) * ((phase + 0.5) % 1.0);
    final distToAirport = calculateDistanceKm(
      lat1: lat2,
      lon1: lng2,
      lat2: 17.9883,
      lon2: 102.5633,
    );

    return [
      BusLiveLocation(
        busId: 1,
        busCode: 'BRT-01',
        busName: 'BRT Express 01',
        driverName: 'ສົມພອນ (Somphone)',
        latitude: lat1,
        longitude: lng1,
        speedKmh: (32.0 + (sin(phase * pi) * 10)).roundToDouble(),
        currentStation: phase < 0.5 ? 'ດົງໂດກ (Dongdok)' : 'ທາດຫຼວງ (That Luang)',
        nextStation: 'ຕະຫຼາດເຊົ້າ (Talat Sao)',
        etaMinutes: estimateEtaMinutes(distanceKm: distToTalatxao),
        status: 'moving',
        lastUpdated: now,
      ),
      BusLiveLocation(
        busId: 2,
        busCode: 'BRT-02',
        busName: 'BRT Airport Link 02',
        driverName: 'ບຸນມີ (Bounmy)',
        latitude: lat2,
        longitude: lng2,
        speedKmh: 42.0,
        currentStation: 'ຕະຫຼາດເຊົ້າ (Talat Sao)',
        nextStation: 'ສະໜາມບິນວັດໄຕ (Wattay Airport)',
        etaMinutes: estimateEtaMinutes(distanceKm: distToAirport),
        status: 'moving',
        lastUpdated: now,
      ),
    ];
  }
}
