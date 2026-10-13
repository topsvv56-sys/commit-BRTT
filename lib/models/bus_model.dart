class Bus {
  final int id;
  final String busname;
  final String driver;
  final String route;
  final String time;
  final int price;

  Bus({
    required this.id,
    required this.busname,
    required this.driver,
    required this.route,
    required this.time,
    required this.price,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'] as int,
      busname: json['busname'] ?? '',
      driver: json['driver'] ?? '',
      route: json['route'] ?? '',
      time: json['time'] ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toInt()
          : int.tryParse(json['price'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'busname': busname,
      'driver': driver,
      'route': route,
      'time': time,
      'price': price,
    };
  }
}
