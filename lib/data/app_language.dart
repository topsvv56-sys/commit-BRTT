import 'package:flutter/material.dart';

// ValueNotifier ເພື່ອແຈ້ງໃຫ້ທຸກໆໜ້າປ່ຽນພາສາທັນທີ
ValueNotifier<String> appLanguageNotifier = ValueNotifier<String>('lao');

// ຄັງເກັບຄຳແປທຸກໜ້າໃນແອັບ
Map<String, Map<String, String>> localizedValues = {
  'lao': {
    // --- 1. ໜ້າ Login ---
    'welcome_brt': 'WELCOME TO BRT',
    'phone_email': 'ເບີໂທລະສັບ / ອີເມວ',
    'password': 'ລະຫັດຜ່ານ',
    'remember_me': 'ຈື່ຂ້ອຍ',
    'login_btn': 'ເຂົ້າສູ່ລະບົບ',
    'forgot_pass': 'ລືມລະຫັດຜ່ານ',

    // --- 2. ໜ້າ ປ່ຽນລະຫັດຜ່ານ ---
    'change_pass_title': 'ປ່ຽນລະຫັດຜ່ານ',
    'old_pass': 'ລະຫັດຜ່ານເກົ່າ',
    'new_pass': 'ລະຫັດຜ່ານໃໝ່',
    'confirm_pass': 'ຢືນຢັນລະຫັດຜ່ານໃໝ່',
    'confirm_change_btn': 'ຢືນຢັນການປ່ຽນລະຫັດຜ່ານ',

    // --- 3. ໜ້າ ຊື້ປີ້ລົດ ---
    'bus_ticket_title': 'ຊື້ປີ້ລົດ',
    'price': 'ລາຄາ',
    'kip_per_ticket': 'ກີບ / ໃບ',
    'select_station_btn': 'ເລືອກສະຖານີປາຍທາງ',

    // --- 4. ໜ້າ ເລືອກສະຖານີ ---
    'select_station_title': 'ເລືອກສະຖານີລົດ',
    'origin_station': 'ສະຖານີຂຶ້ນລົດ',
    'destination_station': 'ສະຖານີລົງ',
    'calculate_route_btn': 'ຄຳນວນເສັ້ນທາງ',

    // --- 5. ໜ້າ ສະແກນ QR ເພື່ອຈ່າຍເງິນ ---
    'scan_qr_title': 'ສະແກນ QR ເພື່ອຈ່າຍເງິນ',
    'qr_hint': 'ກົດໃສ່ຮູບ QR ເພື່ອດາວໂຫລດສະແກນຈ່າຍເງິນ',
    'tickets_count': '2 ໃບ',
    'confirm_pay_btn': 'ຢືນຢັນການຊຳລະເງິນ',

    // --- 6. ໜ້າ ປີ້ລົດສຳເລັດ ---
    'my_tickets_title': 'ປີ້ລົດຂອງທ່ານ',
    'pay_success': 'ຈ່າຍປີ້ສຳເລັດ!',
    'status_paid': 'ຊຳລະແລ້ວ',
    'total_paid': 'ຍອດເງິນທັງໝົດ:',
    'scan_qr_hint': 'ສະແກນ QR ນີ້ຢູ່ທາງເຂົ້າ-ອອກ',
    'back_to_main_btn': 'ກັບຄືນໜ້າຫຼັກ',

    // --- 7. ໜ້າ ຂໍ້ມູນສ່ວນຕົວ (Profile) ---
    'profile_title': 'ຂໍ້ມູນສ່ວນຕົວ',
    'purchase_history': 'ປະຫວັດການຊື້ປີ້',
    'payment_method': 'ບັນຊີ / ວິທີຈ່າຍເງິນ',
    'system_settings': 'ຕັ້ງຄ່າລະບົບ',

    // --- 8. ໜ້າ ປະຫວັດການຊື້ປີ້ ---
    'history_title': 'ປະຫວັດການຊື້ປີ້',
    'status_used': 'ໃຊ້ແລ້ວ',
    'status_expired': 'ໝົດອາຢຸ',
    'date_label': 'ວັນທີ:',
    'price_label': 'ລາຄາ:',

    // --- 9. ໜ້າ ບັນຊີ / ວິທີຈ່າຍເງິນ ---
    'payment_title': 'ບັນຊີ / ວິທີຈ່າຍເງິນ',
    'my_payment_method': 'ວິທີຈ່າຍເງິນຂອງຂ້ອຍ',
    'primary_acc': 'ບັນຊີຫຼັກ ພັນທະມິດ',
    'add_account_btn': '+ ເພີ່ມບັນຊີ ຫຼື ບັດອື່ນໆ',

    // --- 10. ໜ້າ ຕັ້ງຄ່າລະບົບ ---
    'settings_title': 'ຕັ້ງຄ່າລະບົບ',
    'change_language': 'ປ່ຽນພາສາ (Language)',
    'notifications': 'ການແຈ້ງເຕືອນ',
    'logout': 'ອອກຈາກລະບົບ',
    'logout_confirm': 'ທ່ານຕ້ອງການອອກຈາກລະບົບ ຫຼື ບໍ່?',
    'cancel': 'ຍົກເລີກ',
    'confirm': 'ຢືນຢັນ',
    'lao_lang': 'ພາສາລາວ',
    'eng_lang': 'English',
  },
  'en': {
    // --- 1. Login ---
    'welcome_brt': 'WELCOME TO BRT',
    'phone_email': 'Phone Number / Email',
    'password': 'Password',
    'remember_me': 'Remember Me',
    'login_btn': 'Login',
    'forgot_pass': 'Forgot Password?',

    // --- 2. Change Password ---
    'change_pass_title': 'Change Password',
    'old_pass': 'Old Password',
    'new_pass': 'New Password',
    'confirm_pass': 'Confirm New Password',
    'confirm_change_btn': 'Confirm Password Change',

    // --- 3. Bus Ticket ---
    'bus_ticket_title': 'Bus Ticket',
    'price': 'Price',
    'kip_per_ticket': 'Kip / ticket',
    'select_station_btn': 'Select Destination Station',

    // --- 4. Select Station ---
    'select_station_title': 'Select Bus Station',
    'origin_station': 'Departure Station',
    'destination_station': 'Arrival Station',
    'calculate_route_btn': 'Calculate Route',

    // --- 5. Scan QR ---
    'scan_qr_title': 'Scan QR to Pay',
    'qr_hint': 'Click on QR image to download scan pay',
    'tickets_count': '2 Tickets',
    'confirm_pay_btn': 'Confirm Payment',

    // --- 6. Ticket Success ---
    'my_tickets_title': 'Your Bus Ticket',
    'pay_success': 'Payment Successful!',
    'status_paid': 'Paid',
    'total_paid': 'Total Amount:',
    'scan_qr_hint': 'Scan this QR code at entry/exit',
    'back_to_main_btn': 'Back to Main Page',

    // --- 7. Profile ---
    'profile_title': 'Personal Information',
    'purchase_history': 'Purchase History',
    'payment_method': 'Account / Payment Method',
    'system_settings': 'System Settings',

    // --- 8. Purchase History ---
    'history_title': 'Purchase History',
    'status_used': 'Used',
    'status_expired': 'Expired',
    'date_label': 'Date:',
    'price_label': 'Price:',

    // --- 9. Payment Method ---
    'payment_title': 'Account / Payment Method',
    'my_payment_method': 'My Payment Method',
    'primary_acc': 'Primary Account',
    'add_account_btn': '+ Add Account or Card',

    // --- 10. Settings ---
    'settings_title': 'System Settings',
    'change_language': 'Change Language',
    'notifications': 'Notifications',
    'logout': 'Logout',
    'logout_confirm': 'Are you sure you want to logout?',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'lao_lang': 'Lao',
    'eng_lang': 'English',
  },
};

// ຟັງຊັນສັ້ນໆດຶງຄຳແປ
String tr(String key) {
  String langCode = appLanguageNotifier.value;
  return localizedValues[langCode]?[key] ?? key;
}
