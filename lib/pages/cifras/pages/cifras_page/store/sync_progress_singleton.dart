import 'sync_progress.store.dart';

class SyncProgressSingleton {
  static SyncProgressStore? _instance;
  
  static SyncProgressStore get instance {
    _instance ??= SyncProgressStore();
    return _instance!;
  }
}