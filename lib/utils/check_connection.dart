import 'dart:io';

Future<bool> checkUserConnection() async {
  bool activeConnection = false;

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
