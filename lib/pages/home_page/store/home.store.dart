import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hinario_flutter/controllers/shared_preferences.controller.dart';
import 'package:hinario_flutter/models/book.model.dart';
import 'package:mobx/mobx.dart';
part 'home.store.g.dart';

class HomeStore = _HomeStoreBase with _$HomeStore;

abstract class _HomeStoreBase with Store {
  final SharedPreferencesController _sharedPreferencesController =
      SharedPreferencesController();

  @observable
  int? chapter;

  @observable
  BookModel? book;

  @action
  Future<void> setRoute(
    BuildContext context,
    String route,
  ) async {
    String? tempChapter = await _sharedPreferencesController.readData(
      'chapter',
    );
    String? tempBook = await _sharedPreferencesController.readData(
      'book',
    );

    if (tempChapter != null) {
      chapter = int.parse(tempChapter);
    }

    if (tempBook != null) {
      book = BookModel.fromJson(jsonDecode(tempBook));
    }

    if (route == '/verses') {
      Navigator.pushNamed(
        context,
        route,
        arguments: {
          'book': book!,
          'chapter': chapter!,
        },
      );
    } else {
      Navigator.pushNamed(context, route);
    }
  }
}
