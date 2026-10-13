import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_brt_bub/API/firebase_options.dart';
import 'package:flutter_application_brt_bub/data/app_language.dart';
import 'package:flutter_application_brt_bub/login.dart'; // import ໜ້າ Login
import 'app_language.dart'; // import ໄຟລ໌ເກັບພາສາ

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, currentLang, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BRT App',
          home: LoginPage(), // ກຳນົດໃຫ້ໜ້າທຳອິດເປັນໜ້າ Login
        );
      },
    );
  }
}
