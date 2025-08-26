// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_progress.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SyncProgressStore on _SyncProgressStore, Store {
  Computed<double>? _$progressComputed;

  @override
  double get progress =>
      (_$progressComputed ??= Computed<double>(() => super.progress,
              name: '_SyncProgressStore.progress'))
          .value;
  Computed<int>? _$progressPercentComputed;

  @override
  int get progressPercent =>
      (_$progressPercentComputed ??= Computed<int>(() => super.progressPercent,
              name: '_SyncProgressStore.progressPercent'))
          .value;

  late final _$isSyncingAtom =
      Atom(name: '_SyncProgressStore.isSyncing', context: context);

  @override
  bool get isSyncing {
    _$isSyncingAtom.reportRead();
    return super.isSyncing;
  }

  @override
  set isSyncing(bool value) {
    _$isSyncingAtom.reportWrite(value, super.isSyncing, () {
      super.isSyncing = value;
    });
  }

  late final _$currentAtom =
      Atom(name: '_SyncProgressStore.current', context: context);

  @override
  int get current {
    _$currentAtom.reportRead();
    return super.current;
  }

  @override
  set current(int value) {
    _$currentAtom.reportWrite(value, super.current, () {
      super.current = value;
    });
  }

  late final _$totalAtom =
      Atom(name: '_SyncProgressStore.total', context: context);

  @override
  int get total {
    _$totalAtom.reportRead();
    return super.total;
  }

  @override
  set total(int value) {
    _$totalAtom.reportWrite(value, super.total, () {
      super.total = value;
    });
  }

  late final _$currentItemAtom =
      Atom(name: '_SyncProgressStore.currentItem', context: context);

  @override
  String get currentItem {
    _$currentItemAtom.reportRead();
    return super.currentItem;
  }

  @override
  set currentItem(String value) {
    _$currentItemAtom.reportWrite(value, super.currentItem, () {
      super.currentItem = value;
    });
  }

  late final _$_SyncProgressStoreActionController =
      ActionController(name: '_SyncProgressStore', context: context);

  @override
  void startSync(int totalItems) {
    final _$actionInfo = _$_SyncProgressStoreActionController.startAction(
        name: '_SyncProgressStore.startSync');
    try {
      return super.startSync(totalItems);
    } finally {
      _$_SyncProgressStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateProgress(int currentCount, int totalItems, String itemName) {
    final _$actionInfo = _$_SyncProgressStoreActionController.startAction(
        name: '_SyncProgressStore.updateProgress');
    try {
      return super.updateProgress(currentCount, totalItems, itemName);
    } finally {
      _$_SyncProgressStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void finishSync() {
    final _$actionInfo = _$_SyncProgressStoreActionController.startAction(
        name: '_SyncProgressStore.finishSync');
    try {
      return super.finishSync();
    } finally {
      _$_SyncProgressStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isSyncing: ${isSyncing},
current: ${current},
total: ${total},
currentItem: ${currentItem},
progress: ${progress},
progressPercent: ${progressPercent}
    ''';
  }
}
