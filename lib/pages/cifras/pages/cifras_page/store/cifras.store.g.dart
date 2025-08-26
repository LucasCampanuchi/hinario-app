// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cifras.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CifrasStore on _CifrasStore, Store {
  Computed<bool>? _$hasMoreDataComputed;

  @override
  bool get hasMoreData =>
      (_$hasMoreDataComputed ??= Computed<bool>(() => super.hasMoreData,
              name: '_CifrasStore.hasMoreData'))
          .value;

  late final _$cifrasAtom = Atom(name: '_CifrasStore.cifras', context: context);

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

  late final _$filteredCifrasAtom =
      Atom(name: '_CifrasStore.filteredCifras', context: context);

  @override
  ObservableList<Cifra> get filteredCifras {
    _$filteredCifrasAtom.reportRead();
    return super.filteredCifras;
  }

  @override
  set filteredCifras(ObservableList<Cifra> value) {
    _$filteredCifrasAtom.reportWrite(value, super.filteredCifras, () {
      super.filteredCifras = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_CifrasStore.isLoading', context: context);

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
      Atom(name: '_CifrasStore.isLoadingMore', context: context);

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
      Atom(name: '_CifrasStore.errorMessage', context: context);

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
      Atom(name: '_CifrasStore.searchQuery', context: context);

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

  late final _$loadCifrasAsyncAction =
      AsyncAction('_CifrasStore.loadCifras', context: context);

  @override
  Future<void> loadCifras() {
    return _$loadCifrasAsyncAction.run(() => super.loadCifras());
  }

  late final _$loadMoreCifrasAsyncAction =
      AsyncAction('_CifrasStore.loadMoreCifras', context: context);

  @override
  Future<void> loadMoreCifras() {
    return _$loadMoreCifrasAsyncAction.run(() => super.loadMoreCifras());
  }

  late final _$syncCifrasAsyncAction =
      AsyncAction('_CifrasStore.syncCifras', context: context);

  @override
  Future<void> syncCifras() {
    return _$syncCifrasAsyncAction.run(() => super.syncCifras());
  }

  late final _$clearAllCifrasAsyncAction =
      AsyncAction('_CifrasStore.clearAllCifras', context: context);

  @override
  Future<void> clearAllCifras() {
    return _$clearAllCifrasAsyncAction.run(() => super.clearAllCifras());
  }

  late final _$_CifrasStoreActionController =
      ActionController(name: '_CifrasStore', context: context);

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$_CifrasStoreActionController.startAction(
        name: '_CifrasStore.setSearchQuery');
    try {
      return super.setSearchQuery(query);
    } finally {
      _$_CifrasStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
cifras: ${cifras},
filteredCifras: ${filteredCifras},
isLoading: ${isLoading},
isLoadingMore: ${isLoadingMore},
errorMessage: ${errorMessage},
searchQuery: ${searchQuery},
hasMoreData: ${hasMoreData}
    ''';
  }
}
