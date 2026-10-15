import 'package:flutter/material.dart';
import 'package:flutter_application_brt_bub/pages/auth/login_page.dart';
import 'package:flutter_application_brt_bub/localization/app_language.dart';
import 'package:flutter_application_brt_bub/config/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, currentLang, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              tr('settings_title'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.primary,
            centerTitle: false,
            titleSpacing: 0,
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
                        currentLang == 'lao'
                            ? 'ພາສາລາວ'
                            : (currentLang == 'zh'
                                  ? '中文'
                                  : 'English'),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: _showLanguageBottomSheet,
                    ),
                    const Divider(height: 1),

                    // ---------------- 2. ປ່ຽນລະຫັດຜ່ານ ----------------
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: Colors.blue),
                      title: Text(tr('change_password')),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _showChangePasswordDialog,
                    ),
                    const Divider(height: 1),

                    // ---------------- 3. ອອກຈາກລະບົບ ----------------
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
      },
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
                onTap: () async {
                  await changeAppLanguage('lao');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(tr('eng_lang')),
                trailing: appLanguageNotifier.value == 'en'
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () async {
                  await changeAppLanguage('en');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(tr('zh_lang')),
                trailing: appLanguageNotifier.value == 'zh'
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () async {
                  await changeAppLanguage('zh');
                  if (context.mounted) Navigator.pop(context);
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
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
            child: Text(
              tr('save'),
              style: const TextStyle(color: Colors.white),
            ),
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
