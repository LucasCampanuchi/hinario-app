import 'package:hinario_flutter/services/supabase.service.dart';
import 'package:mobx/mobx.dart';
import 'package:supabase/supabase.dart';
part 'list.store.g.dart';

class ListStore = _ListStoreBase with _$ListStore;

abstract class _ListStoreBase with Store {
  final SupabaseService _supabaseService = SupabaseService();

  @observable
  List<FileObject> files = [];

  @observable
  bool loading = false;

  @action
  Future<void> listFiles() async {
    loading = true;

    files = await _supabaseService.listFiles();
    files = files
      ..removeWhere(
        (element) => element.name == '.emptyFolderPlaceholder',
      );

    loading = false;
  }
}
