// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyboard.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$KeyBoardStore on _KeyBoardStore, Store {
  late final _$numAtom = Atom(name: '_KeyBoardStore.num', context: context);

  @override
  String get num {
    _$numAtom.reportRead();
    return super.num;
  }

  @override
  set num(String value) {
    _$numAtom.reportWrite(value, super.num, () {
      super.num = value;
    });
  }

  late final _$setAsyncAction =
      AsyncAction('_KeyBoardStore.set', context: context);

  @override
  Future<void> set(BuildContext context) {
    return _$setAsyncAction.run(() => super.set(context));
  }

  late final _$_KeyBoardStoreActionController =
      ActionController(name: '_KeyBoardStore', context: context);

  @override
  void typeText(String text) {
    final _$actionInfo = _$_KeyBoardStoreActionController.startAction(
        name: '_KeyBoardStore.typeText');
    try {
      return super.typeText(text);
    } finally {
      _$_KeyBoardStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clean() {
    final _$actionInfo = _$_KeyBoardStoreActionController.startAction(
        name: '_KeyBoardStore.clean');
    try {
      return super.clean();
    } finally {
      _$_KeyBoardStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
num: ${num}
    ''';
  }
}
