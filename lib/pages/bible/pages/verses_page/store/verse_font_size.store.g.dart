// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_font_size.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$VerseFontSizeStore on _VerseFontSizeStoreBase, Store {
  late final _$fontSizeAtom =
      Atom(name: '_VerseFontSizeStoreBase.fontSize', context: context);

  @override
  double get fontSize {
    _$fontSizeAtom.reportRead();
    return super.fontSize;
  }

  @override
  set fontSize(double value) {
    _$fontSizeAtom.reportWrite(value, super.fontSize, () {
      super.fontSize = value;
    });
  }

  late final _$_VerseFontSizeStoreBaseActionController =
      ActionController(name: '_VerseFontSizeStoreBase', context: context);

  @override
  void adjustFontSize(double value) {
    final _$actionInfo = _$_VerseFontSizeStoreBaseActionController.startAction(
        name: '_VerseFontSizeStoreBase.adjustFontSize');
    try {
      return super.adjustFontSize(value);
    } finally {
      _$_VerseFontSizeStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void init() {
    final _$actionInfo = _$_VerseFontSizeStoreBaseActionController.startAction(
        name: '_VerseFontSizeStoreBase.init');
    try {
      return super.init();
    } finally {
      _$_VerseFontSizeStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
fontSize: ${fontSize}
    ''';
  }
}
