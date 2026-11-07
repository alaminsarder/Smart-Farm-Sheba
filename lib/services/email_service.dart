import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EmailService {
  static const String _serviceId = 'service_b5gh0yd';
  static const String _templateId = 'template_hpbvhrg';
  static const String _publicKey = '2AoCyc5Roi6Q_-aXQ';

  static Future<bool> _send({
    required String tag,
    required String toEmail,
    required String toName,
    required String subject,
    required String heading,
    required String message,
    required String boxTitle,
    required String boxText,
    required String footerNote,
  }) async {
    debugPrint('EmailJS [$tag] sending to $toEmail');
    try {
      final res = await http
          .post(
            Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'service_id': _serviceId,
              'template_id': _templateId,
              'user_id': _publicKey,
              'template_params': {
                'to_email': toEmail,
                'to_name': toName,
                'subject': subject,
                'heading': heading,
                'message': message,
                'box_title': boxTitle,
                'box_text': boxText,
                'footer_note': footerNote,
              },
            }),
          )
          .timeout(const Duration(seconds: 12));
      debugPrint('EmailJS [$tag] status: ${res.statusCode} body: ${res.body}');
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('EmailJS [$tag] failed: $e');
      return false;
    }
  }

  static String _now() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final d = DateTime.now();
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final p = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day} ${months[d.month - 1]} ${d.year}, $h:$m $p';
  }

  static Future<bool> sendWelcome({
    required String toEmail,
    required String toName,
  }) {
    return _send(
      tag: 'welcome',
      toEmail: toEmail,
      toName: toName,
      subject: 'Welcome to Smart Farm Sheba',
      heading: 'Welcome aboard! 🌱',
      message: 'Your Smart Farm Sheba account has been created successfully. '
          'From now on you can manage your whole farm in one place, '
          'right from your phone or computer.',
      boxTitle: 'WHAT YOU CAN DO',
      boxText:
          'Track your farm expenses and profit • Keep your farming notes • '
          'Plan irrigation • Get crop suggestions and tips • Check the weather',
      footerNote:
          'Your data is saved to your own account, so only you can see it.',
    );
  }

  static Future<bool> sendLoginAlert({
    required String toEmail,
    required String toName,
  }) {
    return _send(
      tag: 'login',
      toEmail: toEmail,
      toName: toName,
      subject: 'New login to your Smart Farm Sheba account',
      heading: 'New login detected 🔐',
      message:
          'We noticed that your Smart Farm Sheba account was just used to log in. '
          'If this was you, no action is needed.',
      boxTitle: 'LOGIN DETAILS',
      boxText: 'Time: ${_now()} • Account: $toEmail • App: Smart Farm Sheba',
      footerNote:
          'If this was not you, please change your password immediately.',
    );
  }
}
