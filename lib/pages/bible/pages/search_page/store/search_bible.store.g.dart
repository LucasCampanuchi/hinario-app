// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_bible.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SearchBibleStore on _SearchBibleStoreBase, Store {
  late final _$listVersesAtom =
      Atom(name: '_SearchBibleStoreBase.listVerses', context: context);

  @override
  List<dynamic>? get listVerses {
    _$listVersesAtom.reportRead();
    return super.listVerses;
  }

  @override
  set listVerses(List<dynamic>? value) {
    _$listVersesAtom.reportWrite(value, super.listVerses, () {
      super.listVerses = value;
    });
  }

  late final _$searchAsyncAction =
      AsyncAction('_SearchBibleStoreBase.search', context: context);

  @override
  Future<void> search(BuildContext context) {
    return _$searchAsyncAction.run(() => super.search(context));
  }

  late final _$setVerseAsyncAction =
      AsyncAction('_SearchBibleStoreBase.setVerse', context: context);

  @override
  Future<void> setVerse(BuildContext context, dynamic verse) {
    return _$setVerseAsyncAction.run(() => super.setVerse(context, verse));
  }

  @override
  String toString() {
    return '''
listVerses: ${listVerses}
    ''';
  }
}
