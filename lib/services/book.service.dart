import 'package:sqflite/sqflite.dart';

import '../database/index.dart';

class BookService {
  Future<List<Map<String, Object?>>> getAll() async {
    Database db = await DbConfig().connection();

    return await db.query('book');
  }

  Future<List<Map<String, Object?>>> getAllChaptersByBook(int bookId) async {
    Database db = await DbConfig().connection();

    return await db.query(
      'chapter',
      columns: ["chapters"],
      where: '"book_id" = $bookId',
    );
  }
}
