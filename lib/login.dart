import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_brt_bub/Regis_ter_Page.dart';
import 'package:flutter_application_brt_bub/brt.dart';
import 'package:flutter_application_brt_bub/bus_page.dart';

// --- หน้า ป່ຽນ/ກູ້ຄືນລະຫັດຜ່ານ (ForgotPasswordPage) ---
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController(text: '');
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ส่งลิงก์รีเซ็ตรหัสผ่านไปยังอีเมลด้วย Firebase Auth
  Future<void> _handleResetPassword() async {
    String input = _emailController.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ກະລຸນາປ້ອນອີເມວ ຫຼື ເບີໂທລະສັບ')),
      );
      return;
    }

    String email = input.contains('@') ? input : '$input@brtapp.com';

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ສົ່ງລິ້ງຣີເຊັດລະຫັດຜ່ານໄປຫາ ອີເມວ ຂອງທ່ານແລ້ວ!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ຜິດພາດ: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        backgroundColor: const Color.fromARGB(255, 211, 69, 9),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'ປ້ອນຊື່ ເບີໂທ ຫຼື ອີເມວຂອງທ່ານ',
                prefixIcon: const Icon(Icons.email_outlined), // [ເພີ່ມ] ໄອຄອນ
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 25),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 211, 69, 9),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isLoading ? null : _handleResetPassword,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'ສົ່ງລິ້ງກູ້ຄືນລະຫັດຜ່ານ',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- หน้า Login (LoginPage) ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');

  bool rememberMe = false;
  bool _isLoading = false;
  bool _isObscure = true; // [ເພີ່ມ] ຕົວແປສຳລັບເປີດ/ປິດເບິ່ງລະຫັດຜ່ານ

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // เข้าสู่ระบบด้วย Firebase Auth
  Future<void> _handleLogin() async {
    String input = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ກະລຸນາປ້ອນຂໍ້ມູນໃຫ້ຄົບ')));
      return;
    }

    String email = input.contains('@') ? input : '$input@brtapp.com';

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BusPage(total: 2)),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ເຂົ້າສູ່ລະບົບບໍ່ສຳເລັດ: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BRT Login', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 211, 69, 9),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),

              const Center(
                child: Text(
                  "WELCOME TO BRT",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),

              // USERNAME / EMAIL / PHONE (ເພີ່ມ Icon ໜ້າ)
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'ປ້ອນຊື່ ເບີໂທ ຫຼື ອີເມວຂອງທ່ານ',
                  prefixIcon: const Icon(Icons.person_outline), // [ເພີ່ມ]
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // PASSWORD (ເພີ່ມ Icon ແລະ ປຸ່ມເປີດ/ປິດ ຕາ)
              TextField(
                controller: _passwordController,
                obscureText: _isObscure, // [ປັບປຸງ]
                decoration: InputDecoration(
                  hintText: 'ປ້ອນລະຫັດຜ່ານຂອງທ່ານ',
                  prefixIcon: const Icon(Icons.lock_outline), // [ເພີ່ມ]
                  suffixIcon: IconButton(
                    // [ເພີ່ມ] ປຸ່ມເປີດ/ປິດເບິ່ງລະຫັດ
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // REMEMBER ME
              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (value) {
                      setState(() {
                        rememberMe = value!;
                      });
                    },
                  ),
                  const Text('ຈື່ຈຳຂ້ອຍ'),
                ],
              ),

              const SizedBox(height: 10),

              // LOGIN BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'ເຂົ້າສູ່ລະບົບ',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),

              const SizedBox(height: 12),

              // FORGOT PASSWORD LINK
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'ລືມລະຫັດຜ່ານບໍ',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),

              // [ເພີ່ມ] ປຸ່ມສະໝັກສະມາຊິກໃໝ່ (Register Link)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("ຍັງບໍ່ມີບັນຊີບໍ?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      'ສະໝັກສະມາຊິກ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 211, 69, 9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
