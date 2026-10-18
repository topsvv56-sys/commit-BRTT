import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_brt_bub/pages/bus/bus_page.dart';
import 'package:flutter_application_brt_bub/pages/profile/payment_methods_page.dart';
import 'package:flutter_application_brt_bub/pages/profile/history_page.dart';
import 'package:flutter_application_brt_bub/pages/profile/settings_page.dart';
import 'package:flutter_application_brt_bub/pages/profile/edit_profile_page.dart';
import 'package:flutter_application_brt_bub/pages/bus/ticket_success_page.dart';
import 'package:flutter_application_brt_bub/localization/app_language.dart';
import 'package:flutter_application_brt_bub/config/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'Hannalong Savayvanh';
  String _userEmail = 'toppy20003@brtlaos.com';
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// ໂຫຼດຂໍ້ມູນຜູ້ໃຊ້
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final authUser = FirebaseAuth.instance.currentUser;

    final savedName = prefs.getString('user_profile_name') ??
        authUser?.displayName ??
        'Hannalong Savayvanh';
    final savedEmail = prefs.getString('user_profile_email') ??
        authUser?.email ??
        'toppy20003@brtlaos.com';
    final savedImagePath = prefs.getString('user_profile_image_path');

    if (mounted) {
      setState(() {
        _userName = savedName;
        _userEmail = savedEmail;
        if (savedImagePath != null && File(savedImagePath).existsSync()) {
          _profileImage = File(savedImagePath);
        } else {
          _profileImage = null;
        }
      });
    }
  }

  /// ໄປໜ້າແກ້ໄຂໂປຣໄຟລ໌
  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );
    if (result == true) {
      _loadProfileData();
    }
  }

  /// Dialog ປ່ຽນລະຫັດຜ່ານ
  void _showChangePasswordDialog() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr('change_password')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: InputDecoration(labelText: tr('old_pass')),
            ),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: InputDecoration(labelText: tr('new_pass')),
            ),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: InputDecoration(labelText: tr('confirm_pass')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () {
              if (newPassController.text != confirmPassController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(tr('pass_not_match'))),
                );
                return;
              }
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('pass_changed')),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              tr('confirm'),
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: AppColors.bgWarmCream,
          appBar: AppBar(
            title: Text(
              tr('profile_title'),
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: false,
            titleSpacing: 0,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BusPage(total: 7000),
                    ),
                  );
                }
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: InkWell(
                                   child: Row(
                    children: [
                      Text(
                        tr('edit'),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, color: AppColors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // --- ຮູບ Profile + ປຸ່ມກ້ອງ Camera Badge ---
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _navigateToEditProfile,
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: AppColors.infoNavy,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(
                                  Icons.person,
                                  size: 64,
                                  color: AppColors.white,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: _navigateToEditProfile,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: AppColors.textDark,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ຊື່ຜູ້ໃຊ້
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),

                // ອີເມລ
                Text(
                  _userEmail,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 14),

                // ປຸ່ມ Outline: "ແກ້ໄຂໂປຣໄຟລ໌"
                OutlinedButton(
                  onPressed: _navigateToEditProfile,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                  ),
                  child: Text(
                    tr('edit_profile'),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // --- Card ເມນູຕ່າງໆ ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 1. ປະຫວັດການຊື້ປີ້
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.history,
                              color: AppColors.info,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            tr('purchase_history'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HistoryPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 60),

                        // 2. ບັນຊີ / ວິທີຈ່າຍເງິນ
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.credit_card,
                              color: AppColors.success,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            tr('payment_method'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AccountPaymentPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 60),

                        // 3. ຕັ້ງຄ່າລະບົບ
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.grey.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.settings,
                              color: AppColors.textSecondary,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            tr('system_settings'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 60),

                        // 4. ປ່ຽນລະຫັດຜ່ານ
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: AppColors.warningGold,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            tr('change_password'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                          onTap: _showChangePasswordDialog,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // Bottom Navigation Bar
          bottomNavigationBar: Container(
            height: 60,
            color: AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: tr('home_nav'),
                  isActive: false,
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BusPage(total: 7000),
                        ),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  icon: Icons.add_box,
                  label: tr('booking_nav'),
                  isActive: false,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SuccessPage(total: 7000, qty: 1),
                      ),
                    );
                  },
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: tr('profile_nav'),
                  isActive: true,
                  onTap: () {},
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
                  ? AppColors.white
                  : AppColors.white.withValues(alpha: 0.65),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? AppColors.white
                    : AppColors.white.withValues(alpha: 0.65),
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
