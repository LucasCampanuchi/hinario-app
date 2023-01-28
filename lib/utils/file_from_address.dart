import 'dart:async';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';

Future<File> createFileOfPdfUrl(String url) async {
  Completer<File> completer = Completer();

  try {
    String filename = url.substring(url.lastIndexOf("/") + 1);
    HttpClientRequest request = await HttpClient().getUrl(
      Uri.parse(url),
    );
    HttpClientResponse response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    Directory dir = await getApplicationDocumentsDirectory();

    File file = File("${dir.path}/$filename");

    await file.writeAsBytes(
      bytes,
      flush: true,
    );
    completer.complete(file);
  } catch (e) {
    throw Exception('Error parsing asset file!');
  }

  return completer.future;
}
