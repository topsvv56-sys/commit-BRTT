import 'package:flutter/material.dart';

/// คลาสรวมการกำหนดสีทั้งหมดของหน้าแอปพลิเคชัน BRT
/// ทำหน้าที่เป็น Single Source of Truth สำหรับการจัดการสีทั่วทั้งแอป
class AppColors {
  // ---------------------------------------------------------------------------
  // โทนสีหลักของแบรนด์ BRT (Brand & Primary Colors)
  // ---------------------------------------------------------------------------
  /// สีส้มหลักตามธีมของแอป BRT
  static const Color primary = Color(0xFFD97724);
  /// สีส้มเข้ม สำหรับเงาหรือปุ่มกด
  static const Color primaryDark = Color(0xFFC06718);
  /// สีส้มสว่าง สำหรับไฮไลต์หรือ Gradient
  static const Color primaryLight = Color(0xFFEA8C3D);
  /// สีส้มอ่อน สำหรับพื้นหลังกล่องข้อความ / Badges / Tag สถานี
  static const Color primarySoft = Color(0xFFF7E6D7);
  /// สีส้มอ่อนมาก สำหรับพื้นหลังการ์ดหรือตั๋ว
  static const Color primarySurface = Color(0xFFFFF7F2);
  /// สีเส้นขอบโทนส้มอ่อน
  static const Color primaryBorder = Color(0xFFE5C3AB);
  /// สีข้อความน้ำตาลเข้มเข้ากับโทนส้ม
  static const Color primaryDarkText = Color(0xFF78350F);
  /// สีส้มโทนลึก
  static const Color primaryAccent = Color(0xFFC8691A);

  // นามแฝงเพื่อรองรับโค้ดเดิม (Aliases for backwards compatibility)
  static const Color primaryOrange = primary;
  static const Color orangePrimary = primary;

  // ---------------------------------------------------------------------------
  // โทนสีพื้นหลัง (Background & Surface Colors)
  // ---------------------------------------------------------------------------
  /// สีพื้นหลัง Scaffold หลักโทนสว่าง
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  /// สีพื้นหลังโทนครีม/อุ่น
  static const Color bgWarmCream = Color(0xFFF9F7F2);
  /// สีพื้นหลังโทนอุ่นนุ่ม
  static const Color surfaceWarm = Color(0xFFF9F8F5);
  /// สีพื้นหลังการ์ด / Container สีขาว
  static const Color surfaceWhite = Colors.white;
  /// สีพื้นผิวสว่างนวล (Slate 50)
  static const Color surfaceLight = Color(0xFFF8FAFC);
  /// สีพื้นหลังการ์ด
  static const Color cardBg = Colors.white;
  /// สีพื้นหลังการ์ดย่อย
  static const Color cardBgSubtle = Color(0xFFFBFBFB);
  /// สีพื้นหลัง Modal / BottomSheet
  static const Color modalBg = Color(0xFFFAF8F5);
  /// สีพื้นหลัง TabBar หรือหน้าประวัติ
  static const Color tabBarBg = Color(0xFFFBF7F9);
  /// สีพื้นหลัง Tab ที่ถูกเลือก
  static const Color tabActiveBg = Color(0xFFF5EBF0);
  /// สีพื้นหลัง Input Field
  static const Color inputBg = Color(0xFFF8FAFC);
  /// สีเงาแบบเบา
  static const Color shadowLight = Color(0x0A000000);
  /// สีเงาแบบเข้มปานกลาง
  static const Color shadowDark = Color(0x42000000);

  // ---------------------------------------------------------------------------
  // โทนสีข้อความ (Typography & Text Colors)
  // ---------------------------------------------------------------------------
  /// สีข้อความหัวข้อหลัก (เข้มมาก)
  static const Color textPrimary = Color(0xFF0F172A);
  /// สีข้อความเข้ม (Slate 800)
  static const Color textDark = Color(0xFF1E293B);
  /// สีข้อความเข้มอมฟ้า (Navy Slate)
  static const Color textNavy = Color(0xFF2B3A4A);
  /// สีข้อความรอง (Slate 500)
  static const Color textSecondary = Color(0xFF64748B);
  /// สีข้อความสเลตกลาง (Slate 600)
  static const Color textSlate = Color(0xFF475569);
  /// สีข้อความเบา/ข้อความใบ้ (Slate 400)
  static const Color textMuted = Color(0xFF94A3B8);
  /// สีข้อความเทา
  static const Color textGrey = Color(0xFF8C9BA8);
  /// สีข้อความขาว
  static const Color textWhite = Colors.white;
  /// สีข้อความขาวโปร่ง 70%
  static const Color textWhite70 = Colors.white70;

  // ---------------------------------------------------------------------------
  // โทนสีเส้นขอบและเส้นแบ่ง (Borders & Dividers)
  // ---------------------------------------------------------------------------
  /// สีเส้นขอบทั่วไป (Slate 200)
  static const Color border = Color(0xFFE2E8F0);
  /// สีเส้นขอบอ่อนโทนอุ่น
  static const Color borderLight = Color(0xFFF0EBE1);
  /// สีเส้นขอบกลาง (Slate 300)
  static const Color borderMedium = Color(0xFFCBD5E1);
  /// สีเส้นขอบการ์ด
  static const Color cardBorder = Color(0xFFF0EBE1);
  /// สีเส้นแบ่ง
  static const Color divider = Color(0xFFE2E8F0);

  // ---------------------------------------------------------------------------
  // โทนสีสถานะและการแจ้งเตือน (Status & Functional Colors)
  // ---------------------------------------------------------------------------
  // สำเร็จ (Success)
  static const Color success = Color(0xFF16A34A);
  static const Color successDark = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color successBadge = Color(0xFF4CAF50);
  static const Color successAccent = Color(0xFF10B981);

  // เตือน / รอดำเนินการ (Warning / Pending)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningBadge = Color(0xFFFBBF24);
  static const Color warningGold = Color(0xFFE5A100);

  // ผิดพลาด / ยกเลิก (Error / Danger)
  static const Color error = Color(0xFFDC2626);
  static const Color errorDark = Color(0xFFB91C1C);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorBadge = Color(0xFFE53935);
  static const Color errorAccent = Colors.redAccent;

  // ข้อมูล / ลิงก์ (Info & Accent Colors)
  static const Color info = Color(0xFF2563EB);
  static const Color infoBlue = Color(0xFF2F80ED);
  static const Color infoDark = Color(0xFF1D4ED8);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoGoogle = Color(0xFF4285F4);
  static const Color infoNavy = Color(0xFF2E5F8A);

  // ---------------------------------------------------------------------------
  // สีสำหรับแผนที่และเส้นทางเดินรถ (Map & Route Colors)
  // ---------------------------------------------------------------------------
  static const Color mapBackground = Color(0xFFF1F3F4);
  static const Color mapBlock = Color(0xFFE8EAED);
  static const Color mapRoad = Colors.white;
  static const Color mapRiver = Color(0xFFCBD5E1);
  static const Color stationPin = Color(0xFFD97724);
  static const Color stationPinExpress = Color(0xFFEA580C);
  static const Color stationPinTerminal = Color(0xFFDC2626);
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleRed = Color(0xFFEA4335);
  static const Color googleYellow = Color(0xFFFBBC05);
  static const Color googleGreen = Color(0xFF34A853);

  // ---------------------------------------------------------------------------
  // สีพื้นฐานทั่วไป (Base Colors)
  // ---------------------------------------------------------------------------
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color black87 = Colors.black87;
  static const Color black54 = Colors.black54;
  static const Color black26 = Colors.black26;
  static const Color black12 = Colors.black12;
  static const Color transparent = Colors.transparent;
  static const Color grey = Colors.grey;
  static const Color greyLight = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);

  // ---------------------------------------------------------------------------
  // Gradients ประจำแอป
  // ---------------------------------------------------------------------------
  /// ไล่เฉดสีส้มหลัก
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );

  /// ไล่เฉดสีส้มสองสี
  static const LinearGradient primaryGradientTwoTone = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  /// ไล่เฉดสีส้มอ่อนสำหรับพื้นหลังส่วนหัว
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );
}
