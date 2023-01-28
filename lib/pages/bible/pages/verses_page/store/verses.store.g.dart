// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verses.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$VersesStore on _VersesStoreBase, Store {
  late final _$pageControllerAtom =
      Atom(name: '_VersesStoreBase.pageController', context: context);

  @override
  PageController get pageController {
    _$pageControllerAtom.reportRead();
    return super.pageController;
  }

  @override
  set pageController(PageController value) {
    _$pageControllerAtom.reportWrite(value, super.pageController, () {
      super.pageController = value;
    });
  }

  late final _$pageAppBarControllerAtom =
      Atom(name: '_VersesStoreBase.pageAppBarController', context: context);

  @override
  PageController get pageAppBarController {
    _$pageAppBarControllerAtom.reportRead();
    return super.pageAppBarController;
  }

  @override
  set pageAppBarController(PageController value) {
    _$pageAppBarControllerAtom.reportWrite(value, super.pageAppBarController,
        () {
      super.pageAppBarController = value;
    });
  }

  late final _$listVersesAtom =
      Atom(name: '_VersesStoreBase.listVerses', context: context);

  @override
  ObservableList<List<VerseModel>> get listVerses {
    _$listVersesAtom.reportRead();
    return super.listVerses;
  }

  @override
  set listVerses(ObservableList<List<VerseModel>> value) {
    _$listVersesAtom.reportWrite(value, super.listVerses, () {
      super.listVerses = value;
    });
  }

  late final _$chapterAtom =
      Atom(name: '_VersesStoreBase.chapter', context: context);

  @override
  int get chapter {
    _$chapterAtom.reportRead();
    return super.chapter;
  }

  @override
  set chapter(int value) {
    _$chapterAtom.reportWrite(value, super.chapter, () {
      super.chapter = value;
    });
  }

  late final _$chaptersAtom =
      Atom(name: '_VersesStoreBase.chapters', context: context);

  @override
  int get chapters {
    _$chaptersAtom.reportRead();
    return super.chapters;
  }

  @override
  set chapters(int value) {
    _$chaptersAtom.reportWrite(value, super.chapters, () {
      super.chapters = value;
    });
  }

  late final _$bookAtom = Atom(name: '_VersesStoreBase.book', context: context);

  @override
  BookModel? get book {
    _$bookAtom.reportRead();
    return super.book;
  }

  @override
  set book(BookModel? value) {
    _$bookAtom.reportWrite(value, super.book, () {
      super.book = value;
    });
  }

  late final _$verseActiveAtom =
      Atom(name: '_VersesStoreBase.verseActive', context: context);

  @override
  int get verseActive {
    _$verseActiveAtom.reportRead();
    return super.verseActive;
  }

  @override
  set verseActive(int value) {
    _$verseActiveAtom.reportWrite(value, super.verseActive, () {
      super.verseActive = value;
    });
  }

  late final _$loadingAtom =
      Atom(name: '_VersesStoreBase.loading', context: context);

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  late final _$listItemControllerAtom =
      Atom(name: '_VersesStoreBase.listItemController', context: context);

  @override
  List<ItemScrollController> get listItemController {
    _$listItemControllerAtom.reportRead();
    return super.listItemController;
  }

  @override
  set listItemController(List<ItemScrollController> value) {
    _$listItemControllerAtom.reportWrite(value, super.listItemController, () {
      super.listItemController = value;
    });
  }

  late final _$listItemPositionsListenerAtom = Atom(
      name: '_VersesStoreBase.listItemPositionsListener', context: context);

  @override
  List<ItemPositionsListener> get listItemPositionsListener {
    _$listItemPositionsListenerAtom.reportRead();
    return super.listItemPositionsListener;
  }

  @override
  set listItemPositionsListener(List<ItemPositionsListener> value) {
    _$listItemPositionsListenerAtom
        .reportWrite(value, super.listItemPositionsListener, () {
      super.listItemPositionsListener = value;
    });
  }

  late final _$listHistoryBookAtom =
      Atom(name: '_VersesStoreBase.listHistoryBook', context: context);

  @override
  ObservableList<dynamic> get listHistoryBook {
    _$listHistoryBookAtom.reportRead();
    return super.listHistoryBook;
  }

  @override
  set listHistoryBook(ObservableList<dynamic> value) {
    _$listHistoryBookAtom.reportWrite(value, super.listHistoryBook, () {
      super.listHistoryBook = value;
    });
  }

  late final _$listAsyncAction =
      AsyncAction('_VersesStoreBase.list', context: context);

  @override
  Future<void> list(BuildContext context, BookModel b, int c, [int? verse]) {
    return _$listAsyncAction.run(() => super.list(context, b, c, verse));
  }

  late final _$savePageAsyncAction =
      AsyncAction('_VersesStoreBase.savePage', context: context);

  @override
  Future<void> savePage(int verse) {
    return _$savePageAsyncAction.run(() => super.savePage(verse));
  }

  late final _$saveHistoryAsyncAction =
      AsyncAction('_VersesStoreBase.saveHistory', context: context);

  @override
  Future<void> saveHistory(int c, BookModel? b) {
    return _$saveHistoryAsyncAction.run(() => super.saveHistory(c, b));
  }

  late final _$listHistoryAsyncAction =
      AsyncAction('_VersesStoreBase.listHistory', context: context);

  @override
  Future<void> listHistory() {
    return _$listHistoryAsyncAction.run(() => super.listHistory());
  }

  late final _$_VersesStoreBaseActionController =
      ActionController(name: '_VersesStoreBase', context: context);

  @override
  void cleanAllVariables() {
    final _$actionInfo = _$_VersesStoreBaseActionController.startAction(
        name: '_VersesStoreBase.cleanAllVariables');
    try {
      return super.cleanAllVariables();
    } finally {
      _$_VersesStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setChapter(int c) {
    final _$actionInfo = _$_VersesStoreBaseActionController.startAction(
        name: '_VersesStoreBase.setChapter');
    try {
      return super.setChapter(c);
    } finally {
      _$_VersesStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void animatedNumber(BuildContext context) {
    final _$actionInfo = _$_VersesStoreBaseActionController.startAction(
        name: '_VersesStoreBase.animatedNumber');
    try {
      return super.animatedNumber(context);
    } finally {
      _$_VersesStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pageController: ${pageController},
pageAppBarController: ${pageAppBarController},
listVerses: ${listVerses},
chapter: ${chapter},
chapters: ${chapters},
book: ${book},
verseActive: ${verseActive},
loading: ${loading},
listItemController: ${listItemController},
listItemPositionsListener: ${listItemPositionsListener},
listHistoryBook: ${listHistoryBook}
    ''';
  }
}
