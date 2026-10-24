class BusLiveLocation {
  final int busId;
  final String busCode;
  final String busName;
  final String driverName;
  final double latitude;
  final double longitude;
  final double speedKmh;
  final String currentStation;
  final String nextStation;
  final int etaMinutes;
  final String status; // 'moving', 'at_station', 'traffic_delay'
  final DateTime lastUpdated;

  BusLiveLocation({
    required this.busId,
    required this.busCode,
    required this.busName,
    required this.driverName,
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.currentStation,
    required this.nextStation,
    required this.etaMinutes,
    this.status = 'moving',
    required this.lastUpdated,
  });

  factory BusLiveLocation.fromMap(Map<String, dynamic> map) {
    return BusLiveLocation(
      busId: (map['busId'] as num?)?.toInt() ?? 1,
      busCode: map['busCode']?.toString() ?? 'BRT-01',
      busName: map['busName']?.toString() ?? 'BRT Express 01',
      driverName: map['driverName']?.toString() ?? 'ສົມພອນ (Somphone)',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 17.9667,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 102.6133,
      speedKmh: (map['speedKmh'] as num?)?.toDouble() ?? 35.0,
      currentStation: map['currentStation']?.toString() ?? 'ST_DONGDOK',
      nextStation: map['nextStation']?.toString() ?? 'ST_TALATXAO',
      etaMinutes: (map['etaMinutes'] as num?)?.toInt() ?? 8,
      status: map['status']?.toString() ?? 'moving',
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.tryParse(map['lastUpdated'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'busId': busId,
      'busCode': busCode,
      'busName': busName,
      'driverName': driverName,
      'latitude': latitude,
      'longitude': longitude,
      'speedKmh': speedKmh,
      'currentStation': currentStation,
      'nextStation': nextStation,
      'etaMinutes': etaMinutes,
      'status': status,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
