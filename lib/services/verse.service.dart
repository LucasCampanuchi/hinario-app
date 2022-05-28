import 'package:sqflite/sqflite.dart';

import '../database/index.dart';

class VerseService {
  final String _name = 'verses';

  Future<List<Map<String, Object?>>> getVerseByBook(int bookId) async {
    Database db = await DbConfig().connection();

    return await db.query(_name, where: '"book_id" = $bookId');
  }

  Future<List<Map<String, Object?>>> getVerseByText(String text) async {
    Database db = await DbConfig().connection();

    return await db.rawQuery(
      'SELECT * FROM $_name AS v INNER JOIN book AS b ON b.id = v.book_id WHERE textWitoutDiacrit LIKE "%$text%" COLLATE NOACCENTS ',
    );
  }
}
