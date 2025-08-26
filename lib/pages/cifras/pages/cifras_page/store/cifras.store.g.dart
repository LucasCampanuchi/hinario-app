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
  Computed<bool>? _$needsUpdateComputed;

  @override
  bool get needsUpdate =>
      (_$needsUpdateComputed ??= Computed<bool>(() => super.needsUpdate,
              name: '_CifrasStore.needsUpdate'))
          .value;
  Computed<int>? _$missingCifrasComputed;

  @override
  int get missingCifras =>
      (_$missingCifrasComputed ??= Computed<int>(() => super.missingCifras,
              name: '_CifrasStore.missingCifras'))
          .value;
  Computed<bool>? _$hasFileIssuesComputed;

  @override
  bool get hasFileIssues =>
      (_$hasFileIssuesComputed ??= Computed<bool>(() => super.hasFileIssues,
              name: '_CifrasStore.hasFileIssues'))
          .value;
  Computed<SyncProgressStore>? _$syncProgressComputed;

  @override
  SyncProgressStore get syncProgress => (_$syncProgressComputed ??=
          Computed<SyncProgressStore>(() => super.syncProgress,
              name: '_CifrasStore.syncProgress'))
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

  late final _$totalCifrasCountAtom =
      Atom(name: '_CifrasStore.totalCifrasCount', context: context);

  @override
  int get totalCifrasCount {
    _$totalCifrasCountAtom.reportRead();
    return super.totalCifrasCount;
  }

  @override
  set totalCifrasCount(int value) {
    _$totalCifrasCountAtom.reportWrite(value, super.totalCifrasCount, () {
      super.totalCifrasCount = value;
    });
  }

  late final _$remoteTotalAtom =
      Atom(name: '_CifrasStore.remoteTotal', context: context);

  @override
  int? get remoteTotal {
    _$remoteTotalAtom.reportRead();
    return super.remoteTotal;
  }

  @override
  set remoteTotal(int? value) {
    _$remoteTotalAtom.reportWrite(value, super.remoteTotal, () {
      super.remoteTotal = value;
    });
  }

  late final _$isCheckingRemoteAtom =
      Atom(name: '_CifrasStore.isCheckingRemote', context: context);

  @override
  bool get isCheckingRemote {
    _$isCheckingRemoteAtom.reportRead();
    return super.isCheckingRemote;
  }

  @override
  set isCheckingRemote(bool value) {
    _$isCheckingRemoteAtom.reportWrite(value, super.isCheckingRemote, () {
      super.isCheckingRemote = value;
    });
  }

  late final _$isStartingSyncAtom =
      Atom(name: '_CifrasStore.isStartingSync', context: context);

  @override
  bool get isStartingSync {
    _$isStartingSyncAtom.reportRead();
    return super.isStartingSync;
  }

  @override
  set isStartingSync(bool value) {
    _$isStartingSyncAtom.reportWrite(value, super.isStartingSync, () {
      super.isStartingSync = value;
    });
  }

  late final _$fileIntegrityAtom =
      Atom(name: '_CifrasStore.fileIntegrity', context: context);

  @override
  Map<String, dynamic>? get fileIntegrity {
    _$fileIntegrityAtom.reportRead();
    return super.fileIntegrity;
  }

  @override
  set fileIntegrity(Map<String, dynamic>? value) {
    _$fileIntegrityAtom.reportWrite(value, super.fileIntegrity, () {
      super.fileIntegrity = value;
    });
  }

  late final _$isCheckingFilesAtom =
      Atom(name: '_CifrasStore.isCheckingFiles', context: context);

  @override
  bool get isCheckingFiles {
    _$isCheckingFilesAtom.reportRead();
    return super.isCheckingFiles;
  }

  @override
  set isCheckingFiles(bool value) {
    _$isCheckingFilesAtom.reportWrite(value, super.isCheckingFiles, () {
      super.isCheckingFiles = value;
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

  late final _$setSearchQueryAsyncAction =
      AsyncAction('_CifrasStore.setSearchQuery', context: context);

  @override
  Future<void> setSearchQuery(String query) {
    return _$setSearchQueryAsyncAction.run(() => super.setSearchQuery(query));
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

  late final _$_checkRemoteTotalAsyncAction =
      AsyncAction('_CifrasStore._checkRemoteTotal', context: context);

  @override
  Future<void> _checkRemoteTotal() {
    return _$_checkRemoteTotalAsyncAction.run(() => super._checkRemoteTotal());
  }

  late final _$_checkFileIntegrityAsyncAction =
      AsyncAction('_CifrasStore._checkFileIntegrity', context: context);

  @override
  Future<void> _checkFileIntegrity() {
    return _$_checkFileIntegrityAsyncAction
        .run(() => super._checkFileIntegrity());
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
totalCifrasCount: ${totalCifrasCount},
remoteTotal: ${remoteTotal},
isCheckingRemote: ${isCheckingRemote},
isStartingSync: ${isStartingSync},
fileIntegrity: ${fileIntegrity},
isCheckingFiles: ${isCheckingFiles},
hasMoreData: ${hasMoreData},
needsUpdate: ${needsUpdate},
missingCifras: ${missingCifras},
hasFileIssues: ${hasFileIssues},
syncProgress: ${syncProgress}
    ''';
  }
}
