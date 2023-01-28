// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'books.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BooksStore on _BooksStoreBase, Store {
  late final _$listBooksAtom =
      Atom(name: '_BooksStoreBase.listBooks', context: context);

  @override
  List<BookModel>? get listBooks {
    _$listBooksAtom.reportRead();
    return super.listBooks;
  }

  @override
  set listBooks(List<BookModel>? value) {
    _$listBooksAtom.reportWrite(value, super.listBooks, () {
      super.listBooks = value;
    });
  }

  late final _$listBooksReceivedAtom =
      Atom(name: '_BooksStoreBase.listBooksReceived', context: context);

  @override
  List<BookModel>? get listBooksReceived {
    _$listBooksReceivedAtom.reportRead();
    return super.listBooksReceived;
  }

  @override
  set listBooksReceived(List<BookModel>? value) {
    _$listBooksReceivedAtom.reportWrite(value, super.listBooksReceived, () {
      super.listBooksReceived = value;
    });
  }

  late final _$pageControllerAtom =
      Atom(name: '_BooksStoreBase.pageController', context: context);

  @override
  ScrollController get pageController {
    _$pageControllerAtom.reportRead();
    return super.pageController;
  }

  @override
  set pageController(ScrollController value) {
    _$pageControllerAtom.reportWrite(value, super.pageController, () {
      super.pageController = value;
    });
  }

  late final _$ordenedAtom =
      Atom(name: '_BooksStoreBase.ordened', context: context);

  @override
  bool get ordened {
    _$ordenedAtom.reportRead();
    return super.ordened;
  }

  @override
  set ordened(bool value) {
    _$ordenedAtom.reportWrite(value, super.ordened, () {
      super.ordened = value;
    });
  }

  late final _$listAsyncAction =
      AsyncAction('_BooksStoreBase.list', context: context);

  @override
  Future<void> list() {
    return _$listAsyncAction.run(() => super.list());
  }

  late final _$setOrderAsyncAction =
      AsyncAction('_BooksStoreBase.setOrder', context: context);

  @override
  Future<void> setOrder(bool o) {
    return _$setOrderAsyncAction.run(() => super.setOrder(o));
  }

  late final _$_BooksStoreBaseActionController =
      ActionController(name: '_BooksStoreBase', context: context);

  @override
  void order(List<BookModel> list) {
    final _$actionInfo = _$_BooksStoreBaseActionController.startAction(
        name: '_BooksStoreBase.order');
    try {
      return super.order(list);
    } finally {
      _$_BooksStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
listBooks: ${listBooks},
listBooksReceived: ${listBooksReceived},
pageController: ${pageController},
ordened: ${ordened}
    ''';
  }
}
