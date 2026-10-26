import 'package:shared_preferences/shared_preferences.dart';

/// Repair ticket ids booked on this device without an account, so guests can
/// still see their repairs under "My repairs".
class GuestRepairTickets {
  GuestRepairTickets._();

  static const _key = 'svc_guest_repair_tickets';
  static const _max = 20;

  static Future<List<String>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_key) ?? const [];
    } catch (_) {
      return const [];
    }
  }

  static Future<void> add(String ticketId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_key) ?? const [];
      await prefs.setStringList(_key, [ticketId, ...ids.where((id) => id != ticketId)].take(_max).toList());
    } catch (_) {
      // Best effort: the ticket number is also shown in the confirmation.
    }
  }
}
