import 'dart:convert';

import 'package:hinario_flutter/controllers/shared_preferences.controller.dart';

import '../models/book.model.dart';

Future<void> initBook() async {
  final SharedPreferencesController sharedPreferencesController =
      SharedPreferencesController();

  await sharedPreferencesController.insertData(
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
  await sharedPreferencesController.insertData(
    'chapter',
    '1',
  );

  await sharedPreferencesController.insertData(
    'verse',
    '1',
  );
}
