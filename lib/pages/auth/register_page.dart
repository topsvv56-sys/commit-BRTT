import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_brt_bub/pages/bus/bus_page.dart';
import 'package:flutter_application_brt_bub/localization/app_language.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isObscurePass = true;
  bool _isObscureConfirm = true;

  // ກຳນົດສີສົ້ມຫຼັກ
  static const Color orangePrimary = Color(0xFFD97724);

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ຟັງຊັນສະໝັກສະມາຊິກດ້ວຍ Firebase Auth
  Future<void> _handleRegister() async {
    String name = _fullNameController.text.trim();
    String input = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        input.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('please_fill_all'))));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('passwords_not_match')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('password_min_6')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ແປງເບີໂທເປັນ Format ຂອງ Email ຖ້າຜູ້ໃຊ້ປ້ອນເບີໂທ
    String email = input.contains('@') ? input : '$input@brtapp.com';

    setState(() => _isLoading = true);

    try {
      // ສ້າງ User ໃໝ່ໃນ Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // ອັບເດດ Display Name ເປັນຊື່ຜູ້ໃຊ້
      await userCredential.user?.updateDisplayName(name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('register_success')),
            backgroundColor: Colors.green,
          ),
        );

        // ເມື່ອສະໝັກສຳເລັດໃຫ້ເຂົ້າໄປໜ້າ BusPage ເລີຍ
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BusPage(total: 7000)),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = tr('login_failed');
        if (e.code == 'email-already-in-use') {
          errorMessage = e.message ?? errorMessage;
        } else if (e.code == 'weak-password') {
          errorMessage = tr('password_min_6');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              tr('register_btn'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: orangePrimary,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Text(
                  tr('create_account_title'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: orangePrimary,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // 1. ຊື່ - ນາມສະກຸນ
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  hintText: tr('enter_full_name'),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: orangePrimary,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: orangePrimary,
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // 2. ອີເມວ ຫຼື ເບີໂທ
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: tr('enter_phone_email'),
                  prefixIcon: const Icon(
                    Icons.phone_android_outlined,
                    color: orangePrimary,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: orangePrimary,
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // 3. ລະຫັດຜ່ານ
              TextField(
                controller: _passwordController,
                obscureText: _isObscurePass,
                decoration: InputDecoration(
                  hintText: tr('enter_password_8'),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: orangePrimary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscurePass ? Icons.visibility_off : Icons.visibility,
                      color: orangePrimary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscurePass = !_isObscurePass;
                      });
                    },
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: orangePrimary,
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // 4. ຢືນຢັນລະຫັດຜ່ານ
              TextField(
                controller: _confirmPasswordController,
                obscureText: _isObscureConfirm,
                decoration: InputDecoration(
                  hintText: tr('confirm_password_new'),
                  prefixIcon: const Icon(
                    Icons.lock_reset_outlined,
                    color: orangePrimary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: orangePrimary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscureConfirm = !_isObscureConfirm;
                      });
                    },
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: orangePrimary,
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ປຸ່ມ "ສະໝັກສະມາຊິກ"
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangePrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        tr('register_btn'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 15),

              // ປຸ່ມກັບໄປໜ້າ Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tr('already_have_account_q')),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      tr('login_btn'),
                      style: const TextStyle(
                        color: orangePrimary,
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
  },
);
}
}
