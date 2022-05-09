// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verses.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

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

  late final _$listAsyncAction =
      AsyncAction('_VersesStoreBase.list', context: context);

  @override
  Future<void> list(BuildContext context, BookModel b, int c, [int? verse]) {
    return _$listAsyncAction.run(() => super.list(context, b, c, verse));
  }

  late final _$_VersesStoreBaseActionController =
      ActionController(name: '_VersesStoreBase', context: context);

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
listItemController: ${listItemController},
listItemPositionsListener: ${listItemPositionsListener}
    ''';
  }
}
