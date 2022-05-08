import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbConfig {
  final String _dbName = 'ARA.sqlite';

  Future<void> initDatabase() async {
    try {
      String dbDir = await getDatabasesPath();
      String dbPath = join(dbDir, _dbName);

      await deleteDatabase(dbPath);

      ByteData data = await rootBundle.load("assets/db/$_dbName");
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(dbPath).writeAsBytes(bytes);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<String> dbPath() async {
    String dbDir = await getDatabasesPath();
    return join(dbDir, _dbName);
  }

  Future<Database> connection() async {
    return await openDatabase(await dbPath());
  }
}
