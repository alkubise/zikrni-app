import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showInfoDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF121212),
      title: Text(title, style: const TextStyle(color: Colors.white, fontFamily: "Cairo")),
      content: Text(
        message,
        style: TextStyle(color: Colors.white.withOpacity(0.8), fontFamily: "Cairo"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("إغلاق"),
        ),
      ],
    ),
  );
}

Future<void> launchUrlExternal(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<void> composeEmail({
  required String to,
  required String subject,
  required String body,
}) async {
  final uri = Uri(
    scheme: 'mailto',
    path: to,
    queryParameters: {
      'subject': subject,
      'body': body,
    },
  );

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

Future<void> requestInAppReviewOrStore() async {
  final review = InAppReview.instance;
  if (await review.isAvailable()) {
    await review.requestReview();
  }
}

Future<String> getVersionText() async {
  final info = await PackageInfo.fromPlatform();
  return "${info.appName}\nالإصدار: ${info.version}\nرقم البناء: ${info.buildNumber}";
}