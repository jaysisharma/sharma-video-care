import 'package:intl/intl.dart';

final _nepaliGrouping = NumberFormat.decimalPattern('en_IN');

/// Rupee amount with Nepali/Indian digit grouping, e.g. Rs. 1,15,000.
String formatRs(num amount) => 'Rs. ${_nepaliGrouping.format(amount)}';
