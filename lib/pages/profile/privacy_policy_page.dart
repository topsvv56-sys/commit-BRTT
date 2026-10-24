import 'package:flutter/material.dart';
import 'package:flutter_application_brt_bub/config/app_colors.dart';

/// ໜ້ານະໂຍບາຍຄວາມເປັນສ່ວນຕົວ ແລະ ຂໍ້ກຳນົດການໃຫ້ບໍລິການ (PDPA & Privacy Policy for Store Compliance)
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'ນະໂຍບາຍຄວາມເປັນສ່ວນຕົວ (Privacy & PDPA)',
          style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
              title: '1. ການເກັບກຳຂໍ້ມູນສ່ວນບຸກຄົນ (Data Collection)',
              content:
                  'ແອັບພລິເຄຊັນ BRT Vientiane Bus Rapid Transit ເກັບກຳຂໍ້ມູນທີ່ຈຳເປັນຕໍ່ການໃຫ້ບໍລິການຂົນສົ່ງ ປະກອບດ້ວຍ:\n'
                  '• ເບີໂທລະສັບ ແລະ ຊື່-ນາມສະກຸນ ສຳລັບການຢືນຢັນຕົວຕົນ\n'
                  '• ຂໍ້ມູນການຊື້ຕົ໋ວ ແລະ ປະຫວັດການເດີນທາງ\n'
                  '• ພິກັດສະຖານທີ່ (GPS) ສຳລັບການຄົ້ນຫາສະຖານີໃກ້ຄຽງ ແລະ ຄຳນວນເວລາລົດເມ (ETA)',
              icon: Icons.security,
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              title: '2. ຄວາມປອດໄພຂອງການຊຳລະເງິນ (Payment Security)',
              content:
                  'ລະບົບຊຳລະເງິນຜ່ານ Lao QR ແລະ BCEL OnePay ດຳເນີນການຜ່ານມາດຕະຖານຄວາມປອດໄພລະດັບສາກົນ (EMVCo).\n'
                  'ແອັບພລິເຄຊັນຈະບໍ່ເກັບຮັກສາລະຫັດຜ່ານບັນຊີທະນາຄານ ຫຼື ຂໍ້ມູນບັດເຄຣດິດຂອງທ່ານໄວ້ໃນເຄື່ອງ.',
              icon: Icons.payment,
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              title: '3. ສິດທິຂອງເຈົ້າຂອງຂໍ້ມູນ (User Rights & PDPA)',
              content:
                  'ທ່ານມີສິດຮ້ອງຂໍກວດສອບ, ແກ້ໄຂ, ຫຼື ຮ້ອງຂໍລຶບບັນຊີ ແລະ ປະຫວັດການເດີນທາງຂອງທ່ານອອກຈາກລະບົບໄດ້ທຸກເວລາ ຜ່ານເມນູການຕັ້ງຄ່າໃນແອັບ ຫຼື ຕິດຕໍ່ສູນບໍລິການລູກຄ້າ BRT.',
              icon: Icons.verified_user,
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              title: '4. ຊ່ອງທາງການຕິດຕໍ່ (Contact Support)',
              content:
                  'ສູນບໍລິການລົດເມດ່ວນ ນະຄອນຫຼວງວຽງຈັນ (BRT Vientiane)\n'
                  '• ເບີໂທຕິດຕໍ່: 021-123456\n'
                  '• ອີເມວ: support@brtlaos.com\n'
                  '• ທີ່ຢູ່: ສະຖານີລົດເມຕະຫຼາດເຊົ້າ, ນະຄອນຫຼວງວຽງຈັນ',
              icon: Icons.contact_support,
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'ເວີຊັນ 1.0.0 (Build 2026.10)',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
