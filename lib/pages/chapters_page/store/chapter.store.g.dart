// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ChapterStore on _ChapterStoreBase, Store {
  late final _$qtdeChaptersAtom =
      Atom(name: '_ChapterStoreBase.qtdeChapters', context: context);

  @override
  int? get qtdeChapters {
    _$qtdeChaptersAtom.reportRead();
    return super.qtdeChapters;
  }

  @override
  set qtdeChapters(int? value) {
    _$qtdeChaptersAtom.reportWrite(value, super.qtdeChapters, () {
      super.qtdeChapters = value;
    });
  }

  late final _$listAsyncAction =
      AsyncAction('_ChapterStoreBase.list', context: context);

  @override
  Future<void> list(BookModel book) {
    return _$listAsyncAction.run(() => super.list(book));
  }

  @override
  String toString() {
    return '''
qtdeChapters: ${qtdeChapters}
    ''';
  }
}
