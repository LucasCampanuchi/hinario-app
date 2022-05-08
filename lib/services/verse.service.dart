import 'package:sqflite/sqflite.dart';

import '../database/index.dart';

class VerseService {
  Future<List<Map<String, Object?>>> getVerseByBook(int bookId) async {
    Database db = await DbConfig().connection();

    return await db.query('verse', where: '"book_id" = $bookId');
  }
}
