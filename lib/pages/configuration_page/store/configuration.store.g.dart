// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ConfigurationStore on _ConfigurationStoreBase, Store {
  late final _$adjustFontSizeAtom =
      Atom(name: '_ConfigurationStoreBase.adjustFontSize', context: context);

  @override
  int get adjustFontSize {
    _$adjustFontSizeAtom.reportRead();
    return super.adjustFontSize;
  }

  @override
  set adjustFontSize(int value) {
    _$adjustFontSizeAtom.reportWrite(value, super.adjustFontSize, () {
      super.adjustFontSize = value;
    });
  }

  late final _$_ConfigurationStoreBaseActionController =
      ActionController(name: '_ConfigurationStoreBase', context: context);

  @override
  void increment() {
    final _$actionInfo = _$_ConfigurationStoreBaseActionController.startAction(
        name: '_ConfigurationStoreBase.increment');
    try {
      return super.increment();
    } finally {
      _$_ConfigurationStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void decrement() {
    final _$actionInfo = _$_ConfigurationStoreBaseActionController.startAction(
        name: '_ConfigurationStoreBase.decrement');
    try {
      return super.decrement();
    } finally {
      _$_ConfigurationStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void init() {
    final _$actionInfo = _$_ConfigurationStoreBaseActionController.startAction(
        name: '_ConfigurationStoreBase.init');
    try {
      return super.init();
    } finally {
      _$_ConfigurationStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
adjustFontSize: ${adjustFontSize}
    ''';
  }
}
