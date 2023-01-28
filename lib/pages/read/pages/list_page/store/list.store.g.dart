// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ListStore on _ListStoreBase, Store {
  late final _$filesAtom = Atom(name: '_ListStoreBase.files', context: context);

  @override
  List<FileObject> get files {
    _$filesAtom.reportRead();
    return super.files;
  }

  @override
  set files(List<FileObject> value) {
    _$filesAtom.reportWrite(value, super.files, () {
      super.files = value;
    });
  }

  late final _$loadingAtom =
      Atom(name: '_ListStoreBase.loading', context: context);

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

  late final _$listFilesAsyncAction =
      AsyncAction('_ListStoreBase.listFiles', context: context);

  @override
  Future<void> listFiles() {
    return _$listFilesAsyncAction.run(() => super.listFiles());
  }

  @override
  String toString() {
    return '''
files: ${files},
loading: ${loading}
    ''';
  }
}
