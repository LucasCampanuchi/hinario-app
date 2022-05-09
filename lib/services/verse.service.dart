import 'package:sqflite/sqflite.dart';

import '../database/index.dart';

class VerseService {
  Future<List<Map<String, Object?>>> getVerseByBook(int bookId) async {
    Database db = await DbConfig().connection();

    return await db.query('verse', where: '"book_id" = $bookId');
  }

  Future<List<Map<String, Object?>>> getVerseByText(String text) async {
    Database db = await DbConfig().connection();

    /* return await db.query(
      'verse',
      where: 'text LIKE ?',
      whereArgs: ['%$text%'],
    ); */

    return await db.rawQuery(
      'SELECT * FROM verse AS v INNER JOIN book AS b ON b.id = v.book_id WHERE text LIKE "%$text%" COLLATE NOACCENTS ',
    );
  }
}
