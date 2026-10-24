import 'package:flutter/material.dart';
import 'package:flutter_application_brt_bub/config/app_colors.dart';
import 'package:flutter_application_brt_bub/localization/app_language.dart';

/// ໜ້ານະໂຍບາຍຄວາມເປັນສ່ວນຕົວ ແລະ ຂໍ້ກຳນົດການໃຫ້ບໍລິການ (PDPA & Privacy Policy for Store Compliance)
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: AppBar(
            title: Text(
              tr('privacy_policy_title'),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.primary,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard(
                  title: tr('privacy_section_1_title'),
                  content: tr('privacy_section_1_desc'),
                  icon: Icons.security,
                ),
                const SizedBox(height: 14),
                _buildSectionCard(
                  title: tr('privacy_section_2_title'),
                  content: tr('privacy_section_2_desc'),
                  icon: Icons.payment,
                ),
                const SizedBox(height: 14),
                _buildSectionCard(
                  title: tr('privacy_section_3_title'),
                  content: tr('privacy_section_3_desc'),
                  icon: Icons.verified_user,
                ),
                const SizedBox(height: 14),
                _buildSectionCard(
                  title: tr('privacy_section_4_title'),
                  content: tr('privacy_section_4_desc'),
                  icon: Icons.contact_support,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    tr('app_version_label'),
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
