import 'package:flutter/material.dart';

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

  final List<String> _providers = [
    'BCEL One / OnePay',
    'LDB Bank',
    'JDB Bank',
    'ບັດ Visa / Mastercard',
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
          const SnackBar(
            content: Text('ເພີ່ມບັນຊີສຳເລັດ!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // ກັບໄປໜ້າກ່ອນໜ້ານີ້
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        title: const Text(
          'ເພີ່ມບັນຊີ / ວິທີຈ່າຍເງິນ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              const Text(
                'ເລືອກທະນາຄານ ຫຼື ວິທີຈ່າຍເງິນ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedProvider,
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
                  setState(() {
                    _selectedProvider = newValue!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // 2. ຊື່ບັນຊີ
              const Text(
                'ຊື່ບັນຊີ / ຊື່ເຈົ້າຂອງບັດ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _accountNameController,
                decoration: InputDecoration(
                  hintText: 'ປ້ອນຊື່ ແລະ ນາມສະກຸນ',
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
                    return 'ກະລຸນາປ້ອນຊື່ບັນຊີ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // 3. ເລກບັນຊີ / ເລກບັດ
              const Text(
                'ເລກບັນຊີ / ເລກບັດ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'ປ້ອນເລກບັນຊີ',
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
                    return 'ກະລຸນາປ້ອນເລກບັນຊີ';
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
                      : const Text(
                          'ຢືນຢັນການເພີ່ມບັນຊີ',
                          style: TextStyle(
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
    );
  }
}
