import 'package:flutter/material.dart';
import 'package:hinario_flutter/controllers/book.controller.dart';
import 'package:hinario_flutter/controllers/verse.controller.dart';
import 'package:hinario_flutter/models/book.model.dart';
import 'package:hinario_flutter/models/verse.model.dart';
import 'package:mobx/mobx.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
part 'verses.store.g.dart';

class VersesStore = _VersesStoreBase with _$VersesStore;

abstract class _VersesStoreBase with Store {
  final VerseController _verseController = VerseController();
  final BookController _bookController = BookController();

  @observable
  PageController pageController = PageController();

  @observable
  PageController pageAppBarController = PageController();

  @observable
  ObservableList<List<VerseModel>> listVerses =
      ObservableList<List<VerseModel>>();

  @observable
  int chapter = 0;

  @observable
  int chapters = 0;

  @observable
  BookModel? book;

  @action
  Future<void> list(
      BuildContext context,
      BookModel b, //book
      int c, //chapter
      [int? verse]) async {
    int? qtdeChapters = await _bookController.getCountChapterByBook(b.id!);

    chapters = qtdeChapters!;
    book = b;
    chapter = c - 1;
    listVerses = ObservableList<List<VerseModel>>();

    List<VerseModel>? tempList = await _verseController.listVerseByBook(
      b.id!,
    );

    if (tempList != null) {
      for (var i = 1; i <= qtdeChapters; i++) {
        List<VerseModel> tempChapter = [];

        for (var verse in tempList) {
          if (verse.chapter == i) {
            tempChapter.add(verse);
          }
        }
        listVerses.add(tempChapter);
      }
    }

    listItemController = [];
    listItemPositionsListener = [];

    for (var i = 0; i < chapters; i++) {
      listItemController.add(ItemScrollController());
      listItemPositionsListener.add(ItemPositionsListener.create());
    }

    pageController.jumpToPage(c - 1);
    pageAppBarController.animateTo(
      0,
      duration: const Duration(milliseconds: 10),
      curve: Curves.linear,
    );

    animatedNumber(context);

    if (verse != null) {
      await Future.delayed(
        const Duration(milliseconds: 200),
        () => listItemController[c - 1].jumpTo(
          index: verse - 1,
          /* duration: const Duration(
            milliseconds: 500,
          ), */
        ),
      );

      pageAppBarController.jumpToPage(c - 1);
    }
  }

  @action
  void setChapter(int c) {
    chapter = c;

    pageController.jumpToPage(c - 1);
    pageAppBarController.jumpToPage(c - 1);
  }

  @action
  void animatedNumber(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    pageController.addListener(() {
      double offset = (pageController.offset *
          ((30 * pageController.offset / size.width) / pageController.offset));

      if (offset.isNaN) {
        offset = 0;
      }

      pageAppBarController.animateTo(
        offset,
        duration: const Duration(milliseconds: 10),
        curve: Curves.linear,
      );
    });
  }

  @observable
  List<ItemScrollController> listItemController = [];

  @observable
  List<ItemPositionsListener> listItemPositionsListener = [];
}
