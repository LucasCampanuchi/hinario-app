import 'package:hinario_flutter/services/supabase.service.dart';
import 'package:mobx/mobx.dart';

part 'hymv_view.store.g.dart';

class HymnViewStore = _HymnViewStoreBase with _$HymnViewStore;

abstract class _HymnViewStoreBase with Store {
  final SupabaseService _supabaseService = SupabaseService();

  @observable
  List<Map<String, dynamic>> indices = [];

  @observable
  bool loading = false;

  @action
  Future<void> verifyIndice(String hymn) async {
    loading = true;

    final response = await _supabaseService.listHyms(
      hymn,
    );

    loading = false;

    if (response != null) {
      indices = List.from(response)
          .map((e) => {
                ...e as Map<String, dynamic>,
                'url': _supabaseService.getPublicUrlHymn(e['nome']),
                'nome_formatado': e['nome'].toString().split('.').first,
              })
          .toList();
    }
  }
}
