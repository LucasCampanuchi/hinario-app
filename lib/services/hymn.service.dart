import 'package:sqflite/sqflite.dart';

import '../database/index.dart';

class HymnService {
  Future<List<Map<String, Object?>>> getHymnByNumber(String number) async {
    Database db = await DbConfig().connection();

    return await db.query('hinos', where: "number = '$number'");
  }

  Future<List<Map<String, Object?>>> getHymnByText(String text) async {
    final query = text.trim();
    if (query.isEmpty) return <Map<String, Object?>>[];

    Database db = await DbConfig().connection();

    return await db.rawQuery(
      'SELECT * FROM hinos WHERE text LIKE ? COLLATE NOACCENTS',
      <Object?>['%$query%'],
    );
  }
}
