import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

import '../../../../../controllers/hymn.controller.dart';
import '../../../../../models/hymn.model.dart';

part 'search_hymn.store.g.dart';

class SearchHymnStore = _SearchHymnStoreBase with _$SearchHymnStore;

abstract class _SearchHymnStoreBase with Store {
  final HymnController _hymnController = HymnController();
  int _searchRequest = 0;

  TextEditingController text = TextEditingController();

  @observable
  ObservableList<HymnModel>? hymns = ObservableList<HymnModel>();

  void setSearch(SearchHymnStore controller, BuildContext context) {
    controller.search(context);
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> search(BuildContext context) async {
    final query = text.text.trim();
    final request = ++_searchRequest;
    hymns = ObservableList<HymnModel>();

    // `LIKE "%%"` devolve todos os hinos e trava a renderização da lista.
    if (query.isEmpty) return;

    List<HymnModel>? tempHymns = await _hymnController.listHymnByText(query);

    // Descarta o retorno de uma busca que foi limpa ou substituída.
    if (request != _searchRequest) return;

    if (tempHymns != null) {
      hymns!.addAll(tempHymns);
    }
  }

  void clear() {
    _searchRequest++;
    hymns = ObservableList<HymnModel>();
    text.text = '';
  }
}
