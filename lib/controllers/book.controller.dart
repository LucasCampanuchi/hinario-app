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
    int verse,
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
    await _sharedPreferencesController.insertData(
      'verse',
      verse.toString(),
    );
  }

  //saveHistory
  Future<void> saveHistory(
    String chapter,
    BookModel book,
    int verse,
  ) async {
    List<dynamic> listBooks = [];

    final obj = {
      'book': jsonEncode(
        book.toJson(),
      ),
      'chapter': chapter,
      'verse': verse.toString(),
    };

    listBooks.add(obj);

    String? tempBooks = await _sharedPreferencesController.readData(
      'bookHistory',
    );

    if (tempBooks != null) {
      List<dynamic> tempListBooks = jsonDecode(tempBooks);

      int index = tempListBooks.indexWhere(
        (element) =>
            element['chapter'] == chapter &&
            element['book'] == jsonEncode(book.toJson()),
      );

      if (index != -1) {
        tempListBooks.removeAt(index);
      }

      if (tempListBooks.length > 9) {
        tempListBooks.removeAt(tempListBooks.length - 1);
      }

      listBooks.addAll(tempListBooks);
    }

    print('list');
    print(listBooks);
    print('list');

    await _sharedPreferencesController.insertData(
      'bookHistory',
      jsonEncode(
        listBooks,
      ),
    );
  }

  Future<List<dynamic>?> getHistory() async {
    String? tempBooks = await _sharedPreferencesController.readData(
      'bookHistory',
    );

    if (tempBooks != null) {
      return jsonDecode(tempBooks);
    }
    return null;
  }
}
