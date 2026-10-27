import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/svc_snackbar.dart';

/// The workshop's public contact details, matching the website
/// (apps/web/src/app/layout.tsx and Footer.tsx). Change them here only.
class BusinessContact {
  BusinessContact._();

  static const name = 'QuickySewa';
  static const phoneDisplay = '+977 985-4022200';
  static const phoneE164 = '+9779854022200';
  static const whatsappNumber = '9779854022200';
  static const street = 'Station Road (Near Ramanand Chowk)';
  static const city = 'Janakpurdham';
  static const hours = 'Sun – Fri: 9:00 AM – 7:30 PM (Sat: on-call)';
  static const hoursShort = 'Sun–Fri 9 AM – 7:30 PM';
}

/// Opens the phone dialer with the workshop number.
Future<void> callWorkshop(BuildContext context) =>
    _open(context, Uri(scheme: 'tel', path: BusinessContact.phoneE164));

/// Opens a WhatsApp chat with the workshop, optionally with a message typed in.
Future<void> whatsappWorkshop(BuildContext context, {String? message}) => _open(
      context,
      Uri.https('wa.me', '/${BusinessContact.whatsappNumber}', {
        if (message != null && message.isNotEmpty) 'text': message,
      }),
    );

Future<void> _open(BuildContext context, Uri uri) async {
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (opened || !context.mounted) return;
  // No dialer / WhatsApp available (e.g. a tablet): give them the number instead.
  await Clipboard.setData(const ClipboardData(text: BusinessContact.phoneDisplay));
  if (context.mounted) {
    SvcSnackbar.show(context, 'Couldn\'t open it here. Number copied: ${BusinessContact.phoneDisplay}', type: SnackType.info);
  }
}
