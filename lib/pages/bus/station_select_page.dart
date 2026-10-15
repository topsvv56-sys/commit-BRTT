import 'package:flutter/material.dart';
import 'package:flutter_application_brt_bub/pages/bus/bus_page.dart';
import 'package:flutter_application_brt_bub/pages/bus/payment_page.dart';
import 'package:flutter_application_brt_bub/pages/profile/profile_page.dart';
import 'package:flutter_application_brt_bub/localization/app_language.dart';

class BRTpage extends StatefulWidget {
  final int total;
  final int qty;
  const BRTpage({super.key, required this.total, required this.qty});

  @override
  State<BRTpage> createState() => _BRTpageState();
}

class _BRTpageState extends State<BRTpage> {
  String? startStation;
  String? endStation;

  // ລາຍການສະຖານີລົດເມ BRT
  final List<String> stations = [
    'station_talatxao',
    'station_dongdok',
    'station_thatluang',
    'station_southern',
    'station_northern',
    'station_airport',
    'station_itecc',
    'station_sihom',
    'station_sikeut',
  ];

  String _getStationName(String key) {
    return tr(key);
  }

  void _showStationPicker({required bool isOrigin, required String title}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_bus_rounded,
                      color: isOrigin
                          ? const Color(0xFFD97724)
                          : const Color(0xFFE24A2B),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: stations.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.shade100,
                    indent: 68,
                  ),
                  itemBuilder: (context, index) {
                    final key = stations[index];
                    final isSelected = isOrigin
                        ? startStation == key
                        : endStation == key;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? (isOrigin
                                  ? const Color(0xFFD97724)
                                  : const Color(0xFFE24A2B))
                            : const Color(0xFFF1F5F9),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 20,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                      title: Text(
                        tr(key),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? (isOrigin
                                    ? const Color(0xFFD97724)
                                    : const Color(0xFFE24A2B))
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      subtitle: Text(
                        tr('${key}_desc'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: isOrigin
                                  ? const Color(0xFFD97724)
                                  : const Color(0xFFE24A2B),
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          if (isOrigin) {
                            startStation = key;
                          } else {
                            endStation = key;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleConfirm() {
    if (startStation == null || endStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('please_select_all_stations')),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    if (startStation == endStation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('same_station_error')),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          total: widget.total,
          qty: widget.qty,
          originStation: startStation!,
          destinationStation: endStation!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFDA812D),
          appBar: AppBar(
            backgroundColor: const Color(0xFFDA812D),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              tr('select_station_title'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
          ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ================= 1. MAP PREVIEW SECTION =================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Map Background (Stylized Realistic Vector Google Map)
                      Positioned.fill(
                        child: CustomPaint(painter: _RealisticMapPainter()),
                      ),

                      // Google Watermark
                      Positioned(
                        left: 12,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                              Text(
                                'o',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEA4335),
                                ),
                              ),
                              Text(
                                'o',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFBBC05),
                                ),
                              ),
                              Text(
                                'g',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                              Text(
                                'l',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF34A853),
                                ),
                              ),
                              Text(
                                'e',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEA4335),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Fullscreen Button
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.fullscreen,
                              size: 22,
                              color: Color(0xFF475569),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'BRT Map Route: Dongdok ⇄ Talat Sao',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // My Location Button
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.my_location,
                              size: 20,
                              color: Color(0xFF475569),
                            ),
                            onPressed: () {
                              setState(() {
                                startStation = 'station_talatxao';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${tr('current_station_selected')} ${tr('station_talatxao')}',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ================= 2. LOWER WHITE CURVED CARD =================
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- ສະຖານີຂຶ້ນລົດ ---
                      Text(
                        tr('origin_station'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Dropdown Box ຂຶ້ນລົດ (Cream Background with Orange Border)
                      InkWell(
                        onTap: () => _showStationPicker(
                          isOrigin: true,
                          title: tr('select_origin_title'),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7E6D7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFC8691A),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.directions_bus_filled,
                                color: Color(0xFFD97724),
                                size: 26,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  startStation != null
                                      ? _getStationName(startStation!)
                                      : tr('select_origin_hint'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: startStation != null
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: startStation != null
                                        ? const Color(0xFF1E293B)
                                        : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF78350F),
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // --- ສະຖານີລົງ ---
                      Text(
                        tr('destination_station'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Dropdown Box ລົງລົດ
                      InkWell(
                        onTap: () => _showStationPicker(
                          isOrigin: false,
                          title: tr('select_dest_title'),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7E6D7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFC8691A),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.directions_bus_filled,
                                color: Color(0xFFD33C1D),
                                size: 26,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  endStation != null
                                      ? _getStationName(endStation!)
                                      : tr('select_dest_hint'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: endStation != null
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: endStation != null
                                        ? const Color(0xFF1E293B)
                                        : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF78350F),
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),

                      // --- ປຸ່ມ ຢືນຢັນ (Confirm Button) ---
                      Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD33C1D),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFD33C1D,
                              ).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _handleConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            tr('confirm'),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ================= 3. BOTTOM NAVIGATION BAR =================
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: Color(0xFFDA812D),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // ໜ້າຫຼັກ (Home)
            _buildNavItem(
              icon: Icons.home,
              label: tr('home_nav'),
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const BusPage(total: 7000)),
                );
              },
            ),
            // ຈອງປີ້ (Book - Active)
            _buildNavItem(
              icon: Icons.add_box_rounded,
              label: tr('booking_nav'),
              isActive: true,
              onTap: () {},
            ),
            // ໂປຣໄຟລ໌ (Profile)
            _buildNavItem(
              icon: Icons.person,
              label: tr('profile_nav'),
              isActive: false,
              onTap: () {
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
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.7),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter ສຳລັບແຕ້ມແຜນທີ່ຖະໜົນ ແລະ ເສັ້ນທາງລົດເມ BRT ຕາມແບບ Google Maps
class _RealisticMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Map Base Background
    final bgPaint = Paint()..color = const Color(0xFFF1F3F4);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. City Blocks
    final blockPaint = Paint()..color = const Color(0xFFE8EAED);
    canvas.drawRect(Rect.fromLTWH(10, 10, 80, 60), blockPaint);
    canvas.drawRect(Rect.fromLTWH(110, 15, 120, 50), blockPaint);
    canvas.drawRect(Rect.fromLTWH(250, 10, 90, 70), blockPaint);
    canvas.drawRect(Rect.fromLTWH(15, 120, 100, 80), blockPaint);
    canvas.drawRect(Rect.fromLTWH(140, 130, 120, 90), blockPaint);
    canvas.drawRect(Rect.fromLTWH(280, 130, 90, 80), blockPaint);

    // 3. Minor Road Network (Light Grey)
    final minorRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final minorPath = Path()
      ..moveTo(0, 45)
      ..lineTo(size.width, 35)
      ..moveTo(0, 140)
      ..lineTo(size.width, 160)
      ..moveTo(60, 0)
      ..lineTo(40, size.height)
      ..moveTo(140, 0)
      ..lineTo(160, size.height)
      ..moveTo(230, 0)
      ..lineTo(210, size.height)
      ..moveTo(310, 0)
      ..lineTo(330, size.height);
    canvas.drawPath(minorPath, minorRoadPaint);

    // 4. Main Avenue (Thick White Road with subtle border)
    final mainRoadBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final mainRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final mainRoad = Path()
      ..moveTo(-10, 40)
      ..lineTo(size.width * 0.45, size.height * 0.42)
      ..lineTo(size.width * 0.70, size.height * 0.65)
      ..lineTo(size.width + 10, size.height * 0.90);

    canvas.drawPath(mainRoad, mainRoadBorder);
    canvas.drawPath(mainRoad, mainRoadPaint);

    // 5. BRT Route Line (Vibrant Orange-Red Line in Screenshot)
    final routeBorderPaint = Paint()
      ..color = const Color(0xFF7C2D12).withValues(alpha: 0.3)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final routePaint = Paint()
      ..color = const Color(0xFFD33C1D)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final routePath = Path()
      ..moveTo(size.width * 0.45, size.height * 0.42)
      ..lineTo(size.width * 0.51, size.height * 0.52)
      ..lineTo(size.width * 0.66, size.height * 0.65);

    canvas.drawPath(routePath, routeBorderPaint);
    canvas.drawPath(routePath, routePaint);

    // 6. Station Pins & Bus Icons (matching screenshot exactly)
    // --- Station 1: Bus Icon Circle (Top-Left) ---
    _drawBusCirclePin(
      canvas,
      Offset(size.width * 0.17, size.height * 0.33),
      const Color(0xFFD97724),
    );

    // --- Station 2: Bus Icon Teardrop ---
    _drawBusPin(
      canvas,
      Offset(size.width * 0.25, size.height * 0.36),
      const Color(0xFFD97724),
    );

    // --- Station 3: Orange Marker Pin ---
    _drawMarkerPin(
      canvas,
      Offset(size.width * 0.35, size.height * 0.40),
      const Color(0xFFD97724),
    );

    // --- Station 4: Orange Marker Pin ---
    _drawMarkerPin(
      canvas,
      Offset(size.width * 0.44, size.height * 0.44),
      const Color(0xFFD97724),
    );

    // --- Station 5: Orange Marker Pin (Midpoint) ---
    _drawMarkerPin(
      canvas,
      Offset(size.width * 0.49, size.height * 0.48),
      const Color(0xFFEA580C),
    );

    // --- Station 6: Red Marker Pin (Destination) ---
    _drawMarkerPin(
      canvas,
      Offset(size.width * 0.66, size.height * 0.65),
      const Color(0xFFDC2626),
    );

    // --- Station 7: Red Marker Pin (Terminal) ---
    _drawMarkerPin(
      canvas,
      Offset(size.width * 0.77, size.height * 0.73),
      const Color(0xFFDC2626),
    );
  }

  // Draw Bus Station Circle
  void _drawBusCirclePin(Canvas canvas, Offset pos, Color color) {
    final shadowPaint = Paint()..color = Colors.black26;
    canvas.drawCircle(pos.translate(0, 2), 12, shadowPaint);

    final bgPaint = Paint()..color = color;
    canvas.drawCircle(pos, 12, bgPaint);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(pos, 9, innerPaint);

    // Bus icon body
    final iconPaint = Paint()..color = color;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: pos, width: 10, height: 11),
      const Radius.circular(2),
    );
    canvas.drawRRect(rrect, iconPaint);
  }

  // Draw Teardrop Bus Pin
  void _drawBusPin(Canvas canvas, Offset pos, Color color) {
    _drawMarkerPin(canvas, pos, color);
  }

  // Draw Teardrop Pin Marker
  void _drawMarkerPin(Canvas canvas, Offset pos, Color color) {
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.25);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pos.dx, pos.dy + 12),
        width: 10,
        height: 4,
      ),
      shadowPaint,
    );

    final path = Path()
      ..moveTo(pos.dx, pos.dy + 11)
      ..cubicTo(
        pos.dx - 11,
        pos.dy - 3,
        pos.dx - 11,
        pos.dy - 12,
        pos.dx,
        pos.dy - 12,
      )
      ..cubicTo(
        pos.dx + 11,
        pos.dy - 12,
        pos.dx + 11,
        pos.dy - 3,
        pos.dx,
        pos.dy + 11,
      );

    final fillPaint = Paint()..color = color;
    canvas.drawPath(path, fillPaint);

    final innerCircle = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(pos.dx, pos.dy - 4), 4, innerCircle);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
