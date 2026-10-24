/// Configuration สำหรับการเชื่อมต่อ Server Backend, APIs, และ Payment Gateway
class ApiConfig {
  ApiConfig._();

  // ==========================================
  // 1. Server Backend Environment
  // ==========================================
  /// ໂໝດການທຳງານ (true = Production Server, false = Local / Mock Test)
  static const bool isProduction = true;

  /// Sandbox Mode ສຳລັບການທົດສອບລະບົບຊຳລະເງິນ (true = ທົດສອບ, false = ຕັດເງິນຈິງ)
  static const bool isPaymentSandbox = true;

  /// Backend Server Base URL
  static const String serverHost = '174.138.25.208';
  static const int serverPort = 10200;
  static const String baseUrl = 'http://$serverHost:$serverPort';

  // ==========================================
  // 2. Endpoints
  // ==========================================
  // Auth
  static const String authLogin = '$baseUrl/api/auth/login';
  static const String authRegister = '$baseUrl/api/auth/register';
  static const String userProfile = '$baseUrl/api/user';

  // Bus & Route Management
  static const String busList = '$baseUrl/api/buses';
  static const String busLiveLocations = '$baseUrl/api/buses/live';
  static const String stations = '$baseUrl/api/stations';
  static const String routes = '$baseUrl/api/routes';

  // Payment Gateway (BCEL OnePay / Lao QR Webhook)
  static const String paymentCreateOrder = '$baseUrl/api/payment/create-order';
  static const String paymentCheckStatus = '$baseUrl/api/payment/status';
  static const String paymentWebhookEndpoint = '$baseUrl/api/payment/webhook';

  // Ticketing & Validation
  static const String ticketCreate = '$baseUrl/api/tickets';
  static const String ticketVerify = '$baseUrl/api/tickets/verify';
  static const String ticketScanAudit = '$baseUrl/api/tickets/scan';

  // ==========================================
  // 3. Payment Gateway Constants (Lao QR / BCEL OnePay)
  // ==========================================
  static const String bcelMerchantId = 'BRT-VIENTIANE-001';
  static const String bcelMerchantName = 'BRT Vientiane Bus Rapid Transit';
  static const String bcelMcc = '4111'; // Transportation / Bus Lines
  static const String currencyLak = 'LAK';

  // ==========================================
  // 4. Timeouts & Polling
  // ==========================================
  static const Duration requestTimeout = Duration(seconds: 15);
  static const Duration paymentPollingInterval = Duration(seconds: 3);
  static const Duration paymentPollingTimeout = Duration(seconds: 120);
  static const int dynamicQrRefreshSeconds = 30;
}
