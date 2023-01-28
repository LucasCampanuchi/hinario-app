// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'read.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ReadStore on _ReadStoreBase, Store {
  late final _$fileAtom = Atom(name: '_ReadStoreBase.file', context: context);

  @override
  File? get file {
    _$fileAtom.reportRead();
    return super.file;
  }

  @override
  set file(File? value) {
    _$fileAtom.reportWrite(value, super.file, () {
      super.file = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ReadStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isErrorAtom =
      Atom(name: '_ReadStoreBase.isError', context: context);

  @override
  bool get isError {
    _$isErrorAtom.reportRead();
    return super.isError;
  }

  @override
  set isError(bool value) {
    _$isErrorAtom.reportWrite(value, super.isError, () {
      super.isError = value;
    });
  }

  late final _$pagesAtom = Atom(name: '_ReadStoreBase.pages', context: context);

  @override
  int get pages {
    _$pagesAtom.reportRead();
    return super.pages;
  }

  @override
  set pages(int value) {
    _$pagesAtom.reportWrite(value, super.pages, () {
      super.pages = value;
    });
  }

  late final _$currentPageAtom =
      Atom(name: '_ReadStoreBase.currentPage', context: context);

  @override
  int get currentPage {
    _$currentPageAtom.reportRead();
    return super.currentPage;
  }

  @override
  set currentPage(int value) {
    _$currentPageAtom.reportWrite(value, super.currentPage, () {
      super.currentPage = value;
    });
  }

  late final _$pdfViewControllerAtom =
      Atom(name: '_ReadStoreBase.pdfViewController', context: context);

  @override
  PDFViewController? get pdfViewController {
    _$pdfViewControllerAtom.reportRead();
    return super.pdfViewController;
  }

  @override
  set pdfViewController(PDFViewController? value) {
    _$pdfViewControllerAtom.reportWrite(value, super.pdfViewController, () {
      super.pdfViewController = value;
    });
  }

  late final _$setFileAsyncAction =
      AsyncAction('_ReadStoreBase.setFile', context: context);

  @override
  Future<void> setFile(String u) {
    return _$setFileAsyncAction.run(() => super.setFile(u));
  }

  late final _$_ReadStoreBaseActionController =
      ActionController(name: '_ReadStoreBase', context: context);

  @override
  void setPdfViewController(PDFViewController controller) {
    final _$actionInfo = _$_ReadStoreBaseActionController.startAction(
        name: '_ReadStoreBase.setPdfViewController');
    try {
      return super.setPdfViewController(controller);
    } finally {
      _$_ReadStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPage(int page) {
    final _$actionInfo = _$_ReadStoreBaseActionController.startAction(
        name: '_ReadStoreBase.setPage');
    try {
      return super.setPage(page);
    } finally {
      _$_ReadStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
file: ${file},
isLoading: ${isLoading},
isError: ${isError},
pages: ${pages},
currentPage: ${currentPage},
pdfViewController: ${pdfViewController}
    ''';
  }
}
