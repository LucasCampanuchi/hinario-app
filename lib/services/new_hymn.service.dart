import 'package:sqflite/sqflite.dart';

import '../database/index.dart';

class NewHymnService {
  Future<List<Map<String, Object?>>> getAll() async {
    Database db = await DbConfig().connection();

    return await db.rawQuery(
      'SELECT * FROM hino_novos',
    );
  }
}
