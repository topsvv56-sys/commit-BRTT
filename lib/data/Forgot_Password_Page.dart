import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailOrPhoneController = TextEditingController();

  void _sendResetLink() {
    if (_emailOrPhoneController.text.isNotEmpty) {
      // ໃສ່ Logic ສົ່ງ OTP ຫຼື Reset Link ໄປຫາ ອີເມວ/ເບີໂທ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ສົ່ງລະຫັດກູ້ຄືນໄປຫາ ອີເມວ/ເບີໂທ ແລ້ວ!')),
      );
      Navigator.pop(context); // ກັບໄປໜ້າ Login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ກູ້ຄືນລະຫັດຜ່ານ',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 23, 32, 157),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ກະລຸນາປ້ອນ ເບີໂທລະສັບ ຫຼື ອີເມວ ຂອງທ່ານເພື່ອຮັບລະຫັດກູ້ຄືນລະຫັດຜ່ານ',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailOrPhoneController,
              decoration: InputDecoration(
                hintText: 'ເບີໂທລະສັບ / ອີເມວ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 23, 32, 157),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _sendResetLink,
              child: const Text(
                'ສົ່ງລະຫັດກູ້ຄືນ',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
