import 'package:flutter/material.dart';

/// Colors sampled from the reference design (dark navy background, gold accents).
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0E1730);
  static const Color surface = Color(0xFF16223F);
  static const Color surfaceLight = Color(0xFF1C2A4A);
  static const Color border = Color(0xFF26355C);

  static const Color gold = Color(0xFFE9B94D);
  static const Color goldDark = Color(0xFFC9973A);

  static const Color textPrimary = Color(0xFFF5F7FB);
  static const Color textSecondary = Color(0xFFA9B4CE);
  static const Color textMuted = Color(0xFF6E7A9A);

  // Status colors — match the calendar legend exactly
  static const Color present = Color(0xFF34C77B);      // حاضر
  static const Color annualLeave = Color(0xFF2FB673);   // إجازة اعتيادية
  static const Color casualLeave = Color(0xFFE0645A);   // إجازة عارضة
  static const Color sickLeave = Color(0xFF3E8FE0);     // إجازة مرضية
  static const Color permission = Color(0xFFE0B23E);    // إذن
  static const Color cutOff = Color(0xFFE0876B);        // انقطاع
  static const Color mission = Color(0xFF6E7EE0);       // مأمورية
  static const Color none = surfaceLight;

  // Dashboard tile accent colors
  static const Color violet = Color(0xFF7C7FEF);
  static const Color green = Color(0xFF3ED17A);
  static const Color pink = Color(0xFFE87DA0);
  static const Color blue = Color(0xFF3E8FE0);
  static const Color amber = Color(0xFFE0B23E);
  static const Color slate = Color(0xFF7C8AAE);

  static const Color danger = Color(0xFFE0645A);
  static const Color warning = Color(0xFFE0B23E);
  static const Color info = Color(0xFF3E8FE0);
}
