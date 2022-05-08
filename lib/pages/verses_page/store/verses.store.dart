import 'package:flutter/material.dart';
import 'package:hinario_flutter/controllers/book.controller.dart';
import 'package:hinario_flutter/controllers/verse.controller.dart';
import 'package:hinario_flutter/models/book.model.dart';
import 'package:hinario_flutter/models/verse.model.dart';
import 'package:mobx/mobx.dart';
part 'verses.store.g.dart';

class VersesStore = _VersesStoreBase with _$VersesStore;

abstract class _VersesStoreBase with Store {
  final VerseController _verseController = VerseController();
  final BookController _bookController = BookController();

  @observable
  PageController pageController = PageController();

  @observable
  ObservableList<List<VerseModel>> listVerses =
      ObservableList<List<VerseModel>>();

  @observable
  int chapter = 0;

  @observable
  BookModel? book;

  @action
  Future<void> list(
    BookModel b,
    int c,
  ) async {
    int? qtdeChapters = await _bookController.getCountChapterByBook(b.id!);

    book = b;
    chapter = c - 1;
    listVerses = ObservableList<List<VerseModel>>();

    List<VerseModel>? tempList = await _verseController.listVerseByBook(
      b.id!,
    );

    if (tempList != null) {
      for (var i = 1; i <= qtdeChapters!; i++) {
        List<VerseModel> tempChapter = [];

        for (var verse in tempList) {
          if (verse.chapter == i) {
            tempChapter.add(verse);
          }
        }
        listVerses.add(tempChapter);
      }
    }

    pageController.jumpToPage(c - 1);
  }

  @action
  void setChapter(int c) {
    chapter = c;
  }
}
