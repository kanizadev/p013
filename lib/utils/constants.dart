import 'package:flutter/material.dart';

// Sage green color palette
class SageGreenColors {
  static const Color sageGreen = Color(0xFF9CAF88);
  static const Color sageGreenLight = Color(0xFFB2B5A0);
  static const Color sageGreenDark = Color(0xFF87AE73);
  static const Color sageGreenLighter = Color(0xFFD4D9C8);
  static const Color sageGreenDarker = Color(0xFF6B8E5A);

  // For theme seed color
  static const Color themeSeed = Color(0xFF9CAF88);

  // Colors with opacity (using Color.fromRGBO for proper opacity handling)
  static Color sageGreenLightWithOpacity(double opacity) {
    return Color.fromRGBO(0xB2, 0xB5, 0xA0, opacity);
  }

  static Color sageGreenWithOpacity(double opacity) {
    return Color.fromRGBO(0x9C, 0xAF, 0x88, opacity);
  }

  static Color sageGreenDarkWithOpacity(double opacity) {
    return Color.fromRGBO(0x87, 0xAE, 0x73, opacity);
  }

  // Pre-defined common opacity values
  static final Color sageGreenLight30 = Color.fromRGBO(0xB2, 0xB5, 0xA0, 0.3);
  static final Color sageGreen20 = Color.fromRGBO(0x9C, 0xAF, 0x88, 0.2);
  static final Color sageGreenDark80 = Color.fromRGBO(0x87, 0xAE, 0x73, 0.8);
}

class NewsCategories {
  static const List<String> categories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  static String getCategoryLabel(String category) {
    switch (category) {
      case 'general':
        return 'General';
      case 'business':
        return 'Business';
      case 'entertainment':
        return 'Entertainment';
      case 'health':
        return 'Health';
      case 'science':
        return 'Science';
      case 'sports':
        return 'Sports';
      case 'technology':
        return 'Technology';
      default:
        return category;
    }
  }
}
