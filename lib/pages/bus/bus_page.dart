import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_brt_bub/pages/bus/station_select_page.dart';
import 'package:flutter_application_brt_bub/pages/profile/profile_page.dart';
import 'package:flutter_application_brt_bub/pages/bus/ticket_success_page.dart';
import 'package:flutter_application_brt_bub/pages/bus/bus_api_page.dart';
import 'package:flutter_application_brt_bub/localization/app_language.dart';
import 'package:flutter_application_brt_bub/config/app_colors.dart';

class BusPage extends StatefulWidget {
  final int total;
  const BusPage({super.key, this.total = 7000});

  @override
  State<BusPage> createState() => _BusPageState();
}

class _BusPageState extends State<BusPage> {
  int qty = 1;
  final int basePrice = 7000;
  int discount = 0;
  String appliedPromoCode = '';

  int get totalAmount {
    final raw = qty * basePrice - discount;
    return raw > 0 ? raw : 0;
  }

  // PageView Controller สำหรับ Banner Carousel
  late final PageController _bannerController;
  int _currentBannerIndex = 0;

  // รายการ Banner ข้อมูล
  final List<Map<String, String>> _banners = [
    {
      'title': 'ສະບາຍດີ',
      'subtitle': 'brt',
      'passenger': 'MR. HANNALONG SAVAYVANH',
      'routeBadge': 'ທ່າວຽງຈັນ - ວັງວຽງ',
      'tag': 'ລົດເມ BRT ໃໝ່',
      'info': 'ທິວທັດ...',
    },
    {
      'title': 'BRT Express',
      'subtitle': 'ສາຍດ່ວນວຽງຈັນ',
      'passenger': 'VIENTIANE RAPID TRANSIT',
      'routeBadge': 'ດົງໂດກ ⇄ ຕະຫຼາດເຊົ້າ',
      'tag': 'ສະອາດ & ສະດວກ',
      'info': 'ທຸກໆ 15 ນາທີ',
    },
    {
      'title': 'Green Energy',
      'subtitle': 'ລົດເມໄຟຟ້າ EV',
      'passenger': 'ECO-FRIENDLY BUS',
      'routeBadge': 'ຕະຫຼາດເຊົ້າ ⇄ ສະໜາມບິນວັດໄຕ',
      'tag': '100% Electric',
      'info': 'ປອດໄພຕໍ່ສິ່ງແວດລ້ອມ',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(initialPage: 0, viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  void add() => setState(() => qty++);
  void remove() {
    if (qty > 1) setState(() => qty--);
  }

  String _formatKip(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _getUserDisplayName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        user.displayName != null &&
        user.displayName!.isNotEmpty) {
      return user.displayName!.toUpperCase();
    }
    return 'MR. HANNALONG SAVAYVANH';
  }

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tr('sell_bus_ticket'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFFEF3C7),
                  child: Icon(Icons.directions_bus, color: AppColors.primary),
                ),
                title: Text('BRT ສາຍ 1 (ດົງໂດກ - ຕະຫຼາດເຊົ້າ)'),
                subtitle: Text('ລົດອອກທຸກໆ 15 ນາທີ ຕັ້ງແຕ່ 06:00 - 18:30'),
              ),
              const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFDCFCE7),
                  child: Icon(Icons.local_offer, color: Colors.green),
                ),
                title: Text('ໂປຣໂມຊັ່ນ OnePay ສະແກນຈ່າຍ'),
                subtitle: Text(
                  'ຮັບສ່ວນຫຼຸດພິເສດເມື່ອຊື້ປີ້ລົດຜ່ານລະບົບ QR Code',
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showPromoDialog() {
    final controller = TextEditingController(text: appliedPromoCode);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.discount, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(tr('promo_code')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tr('enter_promo_hint'),
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'BRT2026',
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
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
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final code = controller.text.trim().toUpperCase();
                setState(() {
                  if (code == 'BRT2026' || code == 'PROMO') {
                    discount = 2000;
                    appliedPromoCode = code;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(tr('promo_success')),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (code.isEmpty) {
                    discount = 0;
                    appliedPromoCode = '';
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(tr('promo_invalid')),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
                Navigator.pop(ctx);
              },
              child: Text(tr('confirm')),
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
        return Scaffold(
          backgroundColor: AppColors.primary,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ================= 1. TOP APP BAR =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      if (Navigator.canPop(context)) ...[
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        tr('bus_ticket_title'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                  const Spacer(),
                  // ປຸ່ມ Bus API Schedule
                  IconButton(
                    tooltip: tr('bus_api_title'),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_bus_filled_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BUS(total: totalAmount),
                        ),
                      );
                    },
                  ),
                  // ປຸ່ມ Notification (ກະດິ່ງ)
                  IconButton(
                    tooltip: tr('notifications_title'),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 26,
                        ),
                        Positioned(
                          right: -1,
                          top: -1,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.yellowAccent.shade700,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: _showNotificationSheet,
                  ),
                ],
              ),
            ),

            // ================= 2. HERO BANNER CAROUSEL =================
            SizedBox(
              height: 195,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _bannerController,
                    itemCount: _banners.length,
                    onPageChanged: (index) {
                      setState(() => _currentBannerIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final banner = _banners[index];
                      return AnimatedScale(
                        duration: const Duration(milliseconds: 250),
                        scale: _currentBannerIndex == index ? 1.0 : 0.94,
                        child: _buildBannerCard(banner),
                      );
                    },
                  ),

                  // ປຸ່ມເລື່ອນຊ້າຍ
                  Positioned(
                    left: 6,
                    child: _buildArrowButton(
                      icon: Icons.chevron_left,
                      onTap: () {
                        if (_currentBannerIndex > 0) {
                          _bannerController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),

                  // ປຸ່ມເລື່ອນຂວາ
                  Positioned(
                    right: 6,
                    child: _buildArrowButton(
                      icon: Icons.chevron_right,
                      onTap: () {
                        if (_currentBannerIndex < _banners.length - 1) {
                          _bannerController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Indicator Dots (ຈຸດເລື່ອນ)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_banners.length, (i) {
                  final isActive = _currentBannerIndex == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ),

            // ================= 3. WHITE CURVED CONTENT CARD =================
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFBFBFB),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
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
                      // --- ROW: PRICE & QUANTITY & REMAINING SEATS ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ຝັ່ງຊ້າຍ: ລາຄາ ແລະ ຈຳນວນບ່ອນນັ່ງວ່າງ
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr('price'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "7,000 ${tr('kip_per_person')}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Badge ສະແດງບ່ອນນັ່ງວ່າງ (Remaining seats: 14)
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF10B981),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tr('remaining_seats'),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF1E293B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ຝັ່ງຂວາ: ກ່ອງສະແດງລາຄາລວມ ແລະ ປຸ່ມບວກລົບ
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // ກ່ອງລາຄາລວມ (Cream Box)
                              Container(
                                width: 140,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7E6D7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE5C3AB),
                                    width: 1.2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "${_formatKip(totalAmount)} ${tr('kip')}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF78350F),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // ປຸ່ມບວກລົບ ຈຳນວນ (Dark Pill: + 1 -)
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5E6D7E),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: add,
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                            left: Radius.circular(24),
                                          ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        "$qty",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: remove,
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                            right: Radius.circular(24),
                                          ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ================= 4. MAIN ACTION BUTTON =================
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
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
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tr('select_station_btn'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= 5. QUICK INFO CARDS ROW =================
                      Row(
                        children: [
                          // ກ່ອງທີ 1: Vientiane Bus Station
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BRTpage(total: totalAmount, qty: qty),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.directions_bus_filled,
                                      color: Color(0xFF1E293B),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tr('vientiane_bus_station'),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // ກ່ອງທີ 2: % (Promo Code)
                          Expanded(
                            child: InkWell(
                              onTap: _showPromoDialog,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7E6D7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE5C3AB),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        appliedPromoCode.isEmpty
                                            ? '(${tr('promo_code')})'
                                            : appliedPromoCode,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: appliedPromoCode.isEmpty
                                              ? const Color(0xFF1E293B)
                                              : AppColors.primary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ================= 6. BOTTOM NAVIGATION BAR =================
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.primary,
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
            // Home (Active)
            _buildNavItem(
              icon: Icons.home,
              label: tr('home_nav'),
              isActive: true,
              onTap: () {},
            ),
            // Book (+)
            _buildNavItem(
              icon: Icons.add,
              label: tr('booking_nav'),
              isActive: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SuccessPage(total: totalAmount, qty: qty),
                  ),
                );
              },
            ),
            // Profile
            _buildNavItem(
              icon: Icons.person,
              label: tr('profile_nav'),
              isActive: false,
              onTap: () {
                Navigator.push(
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

  // --- WIDGET HELPER: BANNER CARD ---
  Widget _buildBannerCard(Map<String, String> banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background patterns
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),

            // Content Layout
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Left Badge/Thumbnail
                  Container(
                    width: 82,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withValues(alpha: 0.18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              banner['routeBadge'] ?? '',
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Image.asset(
                              'assets/images/bus_ticket.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.directions_bus_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Center Greeting & Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          banner['title'] ?? 'ສະບາຍດີ',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          banner['subtitle'] ?? 'brt',
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            banner['passenger'] ?? _getUserDisplayName(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right Badge/Thumbnail
                  Container(
                    width: 72,
                    height: 105,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            banner['tag'] ?? 'ລົດເມ BRT',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          const Icon(
                            Icons.directions_bus,
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            banner['info'] ?? '',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER: ARROW BUTTON ---
  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  // --- WIDGET HELPER: BOTTOM NAV ITEM ---
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
                  : Colors.white.withValues(alpha: 0.65),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.65),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
