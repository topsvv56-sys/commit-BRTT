import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_brt_bub/data/app_language.dart';

class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({super.key});

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  // ກຳນົດສີສົ້ມຫຼັກຂອງແອັບ
  static const Color orangePrimary = Color(0xFFD97724);

  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();

  String _selectedProvider = 'BCEL One / OnePay';
  bool _isLoading = false;

  List<String> get _providers => [
        'BCEL One / OnePay',
        'LDB Bank',
        'JDB Bank',
        tr('visa_master'),
      ];

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  void _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // ຈຳລອງການບັນທຶກຂໍ້ມູນ
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('add_account_success')),
            backgroundColor: Colors.green,
          ),
        );
        // ກັບໄປໜ້າກ່ອນໜ້ານີ້ ພ້ອມສົ່ງຂໍ້ມູນບັນຊີກັບຄືນ
        Navigator.pop(context, {
          'provider': _selectedProvider,
          'accountName': _accountNameController.text.trim(),
          'accountNumber': _accountNumberController.text.trim(),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, currentLang, _) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: const Color(0xFFFAF8F5),
            appBar: AppBar(
              title: Text(
                tr('add_payment_title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: orangePrimary,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. ເລືອກທະນາຄານ / ປະເພດການຈ່າຍ
                    Text(
                      tr('select_bank_method'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedProvider,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.account_balance,
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
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      items: _providers.map((String provider) {
                        return DropdownMenuItem<String>(
                          value: provider,
                          child: Text(provider),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedProvider = newValue;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // 2. ຊື່ບັນຊີ
                    Text(
                      tr('account_name_title'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _accountNameController,
                      decoration: InputDecoration(
                        hintText: tr('account_name_hint'),
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
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return tr('please_enter_name');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // 3. ເລກບັນຊີ / ເລກບັດ
                    Text(
                      tr('account_number_title'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _accountNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: tr('account_number_hint'),
                        prefixIcon: const Icon(
                          Icons.credit_card,
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
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return tr('please_enter_number');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 35),

                    // 4. ປຸ່ມບັນທຶກ (ສີສົ້ມ)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangePrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _isLoading ? null : _saveAccount,
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
                                tr('confirm_add_account'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
