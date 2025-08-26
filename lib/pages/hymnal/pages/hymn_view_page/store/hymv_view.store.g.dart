// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hymv_view.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HymnViewStore on _HymnViewStoreBase, Store {
  late final _$indicesAtom =
      Atom(name: '_HymnViewStoreBase.indices', context: context);

  @override
  List<Map<String, dynamic>> get indices {
    _$indicesAtom.reportRead();
    return super.indices;
  }

  @override
  set indices(List<Map<String, dynamic>> value) {
    _$indicesAtom.reportWrite(value, super.indices, () {
      super.indices = value;
    });
  }

  late final _$loadingAtom =
      Atom(name: '_HymnViewStoreBase.loading', context: context);

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

  late final _$verifyIndiceAsyncAction =
      AsyncAction('_HymnViewStoreBase.verifyIndice', context: context);

  @override
  Future<void> verifyIndice(String hymn) {
    return _$verifyIndiceAsyncAction.run(() => super.verifyIndice(hymn));
  }

  @override
  String toString() {
    return '''
indices: ${indices},
loading: ${loading}
    ''';
  }
}
