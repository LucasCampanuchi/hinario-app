import 'dart:convert';

import 'package:hinario_flutter/controllers/shared_preferences.controller.dart';
import 'package:hinario_flutter/models/book.model.dart';
import 'package:hinario_flutter/services/book.service.dart';

class BookController {
  final BookService _bookService = BookService();
  final SharedPreferencesController _sharedPreferencesController =
      SharedPreferencesController();

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
      // ignore: empty_catches
    } catch (e) {}
    return null;
  }

  Future<BookModel?> getBookById(int id) async {
    try {
      List<Map<String, Object?>> book = await _bookService.getBookById(id);

      if (book.isNotEmpty) {
        return BookModel.fromJson(book[0]);
      }
      // ignore: empty_catches
    } catch (e) {}
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
      // ignore: empty_catches
    } catch (e) {}
    return null;
  }

  Future<void> saveBook(
    String chapter,
    BookModel book,
  ) async {
    await _sharedPreferencesController.insertData(
      'book',
      jsonEncode(
        book.toJson(),
      ),
    );
    await _sharedPreferencesController.insertData(
      'chapter',
      chapter,
    );
  }
}
