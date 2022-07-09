// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$HomeStore on _HomeStoreBase, Store {
  late final _$chapterAtom =
      Atom(name: '_HomeStoreBase.chapter', context: context);

  @override
  int? get chapter {
    _$chapterAtom.reportRead();
    return super.chapter;
  }

  @override
  set chapter(int? value) {
    _$chapterAtom.reportWrite(value, super.chapter, () {
      super.chapter = value;
    });
  }

  late final _$bookAtom = Atom(name: '_HomeStoreBase.book', context: context);

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

  late final _$setRouteAsyncAction =
      AsyncAction('_HomeStoreBase.setRoute', context: context);

  @override
  Future<void> setRoute(BuildContext context, String route) {
    return _$setRouteAsyncAction.run(() => super.setRoute(context, route));
  }

  @override
  String toString() {
    return '''
chapter: ${chapter},
book: ${book}
    ''';
  }
}
