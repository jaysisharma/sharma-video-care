import '../utils/format.dart';
import 'package:flutter/material.dart';

const List<String> kUsedCategories = [
  'All',
  'Cameras',
  'Lenses',
  'Drones',
  'Laptops',
  'Gimbals',
];

const List<Map<String, String>> kGradeFilters = [
  {'id': 'All', 'label': 'All Grades'},
  {'id': 'LIKE_NEW', 'label': 'Grade A+'},
  {'id': 'EXCELLENT', 'label': 'Grade A'},
  {'id': 'GOOD', 'label': 'Grade B'},
];

Map<String, dynamic> getGradeBadge(String grade) {
  switch (grade.toUpperCase()) {
    case "LIKE_NEW":
      return {
        "label": "Grade A+",
        "bg": const Color(0xFFECFDF5),
        "text": const Color(0xFF047857),
        "border": const Color(0xFFA7F3D0),
      };
    case "EXCELLENT":
      return {
        "label": "Grade A",
        "bg": const Color(0xFFEFF6FF),
        "text": const Color(0xFF1D4ED8),
        "border": const Color(0xFFBFDBFE),
      };
    case "GOOD":
      return {
        "label": "Grade B",
        "bg": const Color(0xFFFFFBEB),
        "text": const Color(0xFFB45309),
        "border": const Color(0xFFFDE68A),
      };
    default:
      return {
        "label": "Grade ${grade.replaceAll('_', ' ')}",
        "bg": const Color(0xFFF1F5F9),
        "text": const Color(0xFF334155),
        "border": const Color(0xFFCBD5E1),
      };
  }
}

/// Nepali/Indian digit grouping, e.g. Rs. 1,15,000.
String formatUsedPrice(int amount) => formatRs(amount);
