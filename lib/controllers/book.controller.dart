import 'package:hinario_flutter/models/book.model.dart';
import 'package:hinario_flutter/services/book.service.dart';

class BookController {
  final BookService _bookService = BookService();

  Future<List<BookModel>?> getAll() async {
    try {
      List<Map<String, Object?>> listBooks = await _bookService.getAll();
      return List.from(
        listBooks
            .map(
              (book) => BookModel.fromJson(book),
            )
            .toList(),
      );
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<int?> getCountChapterByBook(int bookId) async {
    try {
      List<Map<String, Object?>> listBooks =
          await _bookService.getAllChaptersByBook(
        bookId,
      );

      return int.parse(
        listBooks[0]['chapters'].toString(),
      );
    } catch (e) {
      print(e);
    }
    return null;
  }
}
