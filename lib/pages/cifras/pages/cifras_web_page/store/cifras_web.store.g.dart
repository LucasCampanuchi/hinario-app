// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cifras_web.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CifrasWebStore on _CifrasWebStore, Store {
  late final _$cifrasAtom =
      Atom(name: '_CifrasWebStore.cifras', context: context);

  @override
  ObservableList<Cifra> get cifras {
    _$cifrasAtom.reportRead();
    return super.cifras;
  }

  @override
  set cifras(ObservableList<Cifra> value) {
    _$cifrasAtom.reportWrite(value, super.cifras, () {
      super.cifras = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_CifrasWebStore.isLoading', context: context);

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

  late final _$isLoadingMoreAtom =
      Atom(name: '_CifrasWebStore.isLoadingMore', context: context);

  @override
  bool get isLoadingMore {
    _$isLoadingMoreAtom.reportRead();
    return super.isLoadingMore;
  }

  @override
  set isLoadingMore(bool value) {
    _$isLoadingMoreAtom.reportWrite(value, super.isLoadingMore, () {
      super.isLoadingMore = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_CifrasWebStore.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$searchQueryAtom =
      Atom(name: '_CifrasWebStore.searchQuery', context: context);

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$currentPageAtom =
      Atom(name: '_CifrasWebStore.currentPage', context: context);

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

  late final _$totalPagesAtom =
      Atom(name: '_CifrasWebStore.totalPages', context: context);

  @override
  int get totalPages {
    _$totalPagesAtom.reportRead();
    return super.totalPages;
  }

  @override
  set totalPages(int value) {
    _$totalPagesAtom.reportWrite(value, super.totalPages, () {
      super.totalPages = value;
    });
  }

  late final _$totalCifrasAtom =
      Atom(name: '_CifrasWebStore.totalCifras', context: context);

  @override
  int get totalCifras {
    _$totalCifrasAtom.reportRead();
    return super.totalCifras;
  }

  @override
  set totalCifras(int value) {
    _$totalCifrasAtom.reportWrite(value, super.totalCifras, () {
      super.totalCifras = value;
    });
  }

  late final _$hasMoreDataAtom =
      Atom(name: '_CifrasWebStore.hasMoreData', context: context);

  @override
  bool get hasMoreData {
    _$hasMoreDataAtom.reportRead();
    return super.hasMoreData;
  }

  @override
  set hasMoreData(bool value) {
    _$hasMoreDataAtom.reportWrite(value, super.hasMoreData, () {
      super.hasMoreData = value;
    });
  }

  late final _$loadCifrasAsyncAction =
      AsyncAction('_CifrasWebStore.loadCifras', context: context);

  @override
  Future<void> loadCifras({bool refresh = false}) {
    return _$loadCifrasAsyncAction
        .run(() => super.loadCifras(refresh: refresh));
  }

  late final _$loadMoreCifrasAsyncAction =
      AsyncAction('_CifrasWebStore.loadMoreCifras', context: context);

  @override
  Future<void> loadMoreCifras() {
    return _$loadMoreCifrasAsyncAction.run(() => super.loadMoreCifras());
  }

  late final _$setSearchQueryAsyncAction =
      AsyncAction('_CifrasWebStore.setSearchQuery', context: context);

  @override
  Future<void> setSearchQuery(String query) {
    return _$setSearchQueryAsyncAction.run(() => super.setSearchQuery(query));
  }

  late final _$_CifrasWebStoreActionController =
      ActionController(name: '_CifrasWebStore', context: context);

  @override
  void clearSearch() {
    final _$actionInfo = _$_CifrasWebStoreActionController.startAction(
        name: '_CifrasWebStore.clearSearch');
    try {
      return super.clearSearch();
    } finally {
      _$_CifrasWebStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
cifras: ${cifras},
isLoading: ${isLoading},
isLoadingMore: ${isLoadingMore},
errorMessage: ${errorMessage},
searchQuery: ${searchQuery},
currentPage: ${currentPage},
totalPages: ${totalPages},
totalCifras: ${totalCifras},
hasMoreData: ${hasMoreData}
    ''';
  }
}
