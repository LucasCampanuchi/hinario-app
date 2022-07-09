// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_hymn.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$NewHymnStore on _NewHymnStoreBase, Store {
  late final _$hymnsAtom =
      Atom(name: '_NewHymnStoreBase.hymns', context: context);

  @override
  ObservableList<NewHymnModel> get hymns {
    _$hymnsAtom.reportRead();
    return super.hymns;
  }

  @override
  set hymns(ObservableList<NewHymnModel> value) {
    _$hymnsAtom.reportWrite(value, super.hymns, () {
      super.hymns = value;
    });
  }

  late final _$getAllAsyncAction =
      AsyncAction('_NewHymnStoreBase.getAll', context: context);

  @override
  Future<void> getAll() {
    return _$getAllAsyncAction.run(() => super.getAll());
  }

  late final _$_NewHymnStoreBaseActionController =
      ActionController(name: '_NewHymnStoreBase', context: context);

  @override
  void clear() {
    final _$actionInfo = _$_NewHymnStoreBaseActionController.startAction(
        name: '_NewHymnStoreBase.clear');
    try {
      return super.clear();
    } finally {
      _$_NewHymnStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void init() {
    final _$actionInfo = _$_NewHymnStoreBaseActionController.startAction(
        name: '_NewHymnStoreBase.init');
    try {
      return super.init();
    } finally {
      _$_NewHymnStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
hymns: ${hymns}
    ''';
  }
}
