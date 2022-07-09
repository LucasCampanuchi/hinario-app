import 'dart:convert';

import 'package:hinario_flutter/controllers/shared_preferences.controller.dart';

import '../models/book.model.dart';

Future<void> initBook() async {
  final SharedPreferencesController _sharedPreferencesController =
      SharedPreferencesController();

  await _sharedPreferencesController.insertData(
    'book',
    jsonEncode(
      BookModel(
        id: 1,
        bookReferenceId: 1,
        testamentReferenceId: 1,
        name: 'Gênesis',
      ),
    ),
  );
  await _sharedPreferencesController.insertData(
    'chapter',
    '1',
  );
}
