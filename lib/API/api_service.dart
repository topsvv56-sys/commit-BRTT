import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ========== AUTH ==========
  static Future<Map<String, dynamic>> login(
    String phone,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login), // ໃຊ້ຈາກ config
      headers: _headers,
      body: jsonEncode({'phone': phone, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register({
    required String phone,
    required String email,
    required String password,
    required String name,
  }) async {
    var register = ApiConfig.register;
    final response = await http.post(
      Uri.parse(register!),
      headers: _headers,
      body: jsonEncode({
        'phone': phone,
        'email': email,
        'password': password,
        'name': name,
      }),
    );
    return jsonDecode(response.body);
  }

  // ========== TICKETS ==========
  static Future<Map<String, dynamic>> createTicket({
    required String fromStation,
    required String toStation,
    required int quantity,
  }) async {
    var createTicket = ApiConfig.createTicket;
    final response = await http.post(
      Uri.parse(createTicket!),
      headers: _headers,
      body: jsonEncode({
        'fromStation': fromStation,
        'toStation': toStation,
        'quantity': quantity,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMyTickets() async {
    var getMyTickets = ApiConfig.getMyTickets;
    final response = await http.get(
      Uri.parse(getMyTickets!),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // ========== PAYMENTS ==========
  static Future<Map<String, dynamic>> payTicket(String ticketId) async {
    final response = await http.post(
      Uri.parse(ApiConfig.payTicket),
      headers: _headers,
      body: jsonEncode({'ticketId': ticketId, 'method': 'qr'}),
    );
    return jsonDecode(response.body);
  }

  // ========== STATIONS ==========
  static Future<Map<String, dynamic>> getStations() async {
    var getStations = ApiConfig.getStations;
    final response = await http.get(Uri.parse(getStations!), headers: _headers);
    return jsonDecode(response.body);
  }
}

class ApiConfig {
  static late String login;

  static late String payTicket;

  static String? get register => null;

  static String? get createTicket => m;

  static String? get m => null;

  static String? get getStations => null;

  static String? get getMyTickets => null;
}
