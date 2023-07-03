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
  _VersesStoreBase() {
    reaction((_) => chapter, (c) {
      saveHistory(
        chapter,
        book,
      );
    });

    reaction((_) => book, (b) {
      saveHistory(
        chapter,
        book,
      );
    });
  }

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

  @observable
  int verseActive = 0;

  @observable
  bool loading = false;

  @action
  void cleanAllVariables() {
    pageController = PageController();
    pageAppBarController = PageController();
    listVerses = ObservableList<List<VerseModel>>();
    chapter = 0;
    chapters = 0;
    book = null;
    verseActive = 0;
    loading = false;
    listHistoryBook = ObservableList();
    listItemController = [];
    listItemPositionsListener = [];
  }

  @action
  Future<void> list(
    BuildContext context,
    BookModel b,
    int c, [
    int? verse,
  ]) async {
    loading = true;

    await listHistory();

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

    for (var element in listItemPositionsListener) {
      element.itemPositions.addListener(() {
        if (element.itemPositions.value.isNotEmpty) {
          savePage(element.itemPositions.value.first.index + 1);
          verseActive = element.itemPositions.value.first.index + 1;
        }
      });
    }

    pageController.jumpToPage(c - 1);
    pageAppBarController.jumpToPage(c - 1);

    animatedNumber(context);

    if (verse != null) {
      await Future.delayed(
        const Duration(milliseconds: 200),
        () => listItemController[c - 1].jumpTo(
          index: verse - 1,
        ),
      );

      pageAppBarController.jumpToPage(c - 1);
    }

    loading = false;
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
          ((40 * pageController.offset / size.width) / pageController.offset));

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

  @action
  Future<void> savePage(int verse) async {
    if (book != null) {
      _bookController.saveBook('${(chapter + 1)}', book!, verse);
    }
  }

  @action
  Future<void> saveHistory(
    int c,
    BookModel? b,
  ) async {
    listHistory();

    Future.delayed(const Duration(seconds: 5), () {
      if (b != null && book != null) {
        if (c == chapter && b.id == book?.id) {
          _bookController.saveHistory('${(chapter + 1)}', book!, verseActive);
        }
      }
    });
  }

  @observable
  ObservableList<dynamic> listHistoryBook = ObservableList<dynamic>();

  //listHistory
  @action
  Future<void> listHistory() async {
    final List<dynamic>? list = await _bookController.getHistory();
    if (list != null) {
      listHistoryBook = list.asObservable();
    }
  }
}
