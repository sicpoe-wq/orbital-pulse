import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the user's browser / handling app; shows a snackbar on failure.
Future<void> openExternal(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final uri = Uri.tryParse(url);
  var ok = false;
  if (uri != null) {
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
  }
  if (!ok) {
    messenger.showSnackBar(
      SnackBar(
        content: Text('Couldn\'t open link: $url'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
