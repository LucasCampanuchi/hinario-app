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

  @observable
  int? verse;

  @observable
  bool lock = false;

  @action
  Future<void> setRoute(
    BuildContext context,
    String route,
  ) async {
    if (lock) {
      return;
    }

    String? tempChapter = await _sharedPreferencesController.readData(
      'chapter',
    );
    String? tempBook = await _sharedPreferencesController.readData(
      'book',
    );
    String? tempVerse = await _sharedPreferencesController.readData(
      'verse',
    );

    if (tempChapter != null) {
      chapter = int.parse(tempChapter);
    }

    if (tempBook != null) {
      book = BookModel.fromJson(jsonDecode(tempBook));
    }

    if (tempVerse != null) {
      verse = int.parse(tempVerse);
    }

    if (route == '/verses') {
      Navigator.pushNamed(
        context,
        route,
        arguments: {
          'book': book!,
          'chapter': chapter!,
          'verse': (verse),
        },
      );
    } else {
      Navigator.pushNamed(context, route);
    }

    lock = true;

    Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    ).then(
      (value) {
        lock = false;
      },
    );
  }
}
