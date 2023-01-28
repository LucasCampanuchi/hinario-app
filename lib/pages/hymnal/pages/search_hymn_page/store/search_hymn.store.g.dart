// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_hymn.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SearchHymnStore on _SearchHymnStoreBase, Store {
  late final _$hymnsAtom =
      Atom(name: '_SearchHymnStoreBase.hymns', context: context);

  @override
  ObservableList<HymnModel>? get hymns {
    _$hymnsAtom.reportRead();
    return super.hymns;
  }

  @override
  set hymns(ObservableList<HymnModel>? value) {
    _$hymnsAtom.reportWrite(value, super.hymns, () {
      super.hymns = value;
    });
  }

  @override
  String toString() {
    return '''
hymns: ${hymns}
    ''';
  }
}
