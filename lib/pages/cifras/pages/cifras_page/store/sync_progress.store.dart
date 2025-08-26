import 'package:mobx/mobx.dart';

part 'sync_progress.store.g.dart';

class SyncProgressStore = _SyncProgressStore with _$SyncProgressStore;

abstract class _SyncProgressStore with Store {

  @observable
  bool isSyncing = false;

  @observable
  int current = 0;

  @observable
  int total = 0;

  @observable
  String currentItem = '';

  @computed
  double get progress => total > 0 ? current / total : 0.0;

  @computed
  int get progressPercent => (progress * 100).round();

  @action
  void startSync(int totalItems) {
    isSyncing = true;
    current = 0;
    total = totalItems;
    currentItem = '';
  }

  @action
  void updateProgress(int currentCount, int totalItems, String itemName) {
    current = currentCount;
    total = totalItems;
    currentItem = itemName;
  }

  @action
  void finishSync() {
    isSyncing = false;
    current = 0;
    total = 0;
    currentItem = '';
  }
}