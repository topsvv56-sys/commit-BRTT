import 'package:flutter/material.dart';
import 'package:flutter_application_brt_bub/login.dart';
import 'app_language.dart'; // import ໄຟລ໌ພາສາທີ່ສ້າງໃໝ່

class AppSettings {
  static bool isNotificationOn = true;
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('settings'), // ໃຊ້ tr() ເພື່ອແປພາສາ
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFD34509),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Column(
              children: [
                // ---------------- 1. ປ່ຽນພາສາ ----------------
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.orange),
                  title: Text(tr('change_language')),
                  trailing: Text(
                    appLanguageNotifier.value == 'lao' ? 'ພາສາລາວ' : 'English',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: _showLanguageBottomSheet,
                ),
                const Divider(height: 1),

                // ---------------- 2. ການແຈ້ງເຕືອນ ----------------
                ListTile(
                  leading: const Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.red,
                  ),
                  title: Text(tr('notifications')),
                  trailing: Switch(
                    value: AppSettings.isNotificationOn,
                    activeColor: Colors.deepPurple,
                    onChanged: (val) {
                      setState(() {
                        AppSettings.isNotificationOn = val;
                      });
                    },
                  ),
                ),
                const Divider(height: 1),

                // ---------------- 3. ປ່ຽນລະຫັດຜ່ານ ----------------
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: Colors.blue),
                  title: Text(tr('change_password')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showChangePasswordDialog,
                ),
                const Divider(height: 1),

                // ---------------- 4. ອອກຈາກລະບົບ ----------------
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.grey),
                  title: Text(
                    tr('logout'),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: _showLogoutConfirmDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Function ເລືອກພາສາ (Bottom Sheet) ---
  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(tr('lao_lang')),
                trailing: appLanguageNotifier.value == 'lao'
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  // ອັບເດດພາສາເປັນ ລາວ (ທຸກໜ້າຈະປ່ຽນຕາມອັດໂຕໂນມັດ)
                  appLanguageNotifier.value = 'lao';
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(tr('eng_lang')),
                trailing: appLanguageNotifier.value == 'en'
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  // ອັບເດດພາສາເປັນ ອັງກິດ (ທຸກໜ້າຈະປ່ຽນຕາມອັດໂຕໂນມັດ)
                  appLanguageNotifier.value = 'en';
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 2. Function ປ່ຽນລະຫັດຜ່ານ (Dialog Input) ---
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
            onPressed: () {
              if (newPassController.text != confirmPassController.text) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(tr('pass_not_match'))));
                return;
              }
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(tr('pass_changed'))));
            },
            child: Text(tr('save')),
          ),
        ],
      ),
    );
  }

  // --- 3. Function ອອກຈາກລະບົບ (Dialog Confirm) ---
  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr('logout')),
        content: Text(tr('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: Text(
              tr('confirm'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
