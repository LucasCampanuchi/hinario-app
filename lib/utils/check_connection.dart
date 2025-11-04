import 'dart:io';

import 'package:flutter/foundation.dart';

Future<bool> checkUserConnection() async {
  bool activeConnection = false;

  if (kIsWeb) {
    return true;
  }

  try {
    final List<InternetAddress> result = await InternetAddress.lookup(
      'google.com',
    );

    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      activeConnection = true;
    }
  } on SocketException catch (_) {
    activeConnection = false;
  }

  return activeConnection;
}
