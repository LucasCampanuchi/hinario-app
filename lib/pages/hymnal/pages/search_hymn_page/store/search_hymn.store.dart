import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

import '../../../../../controllers/hymn.controller.dart';
import '../../../../../models/hymn.model.dart';

part 'search_hymn.store.g.dart';

class SearchHymnStore = _SearchHymnStoreBase with _$SearchHymnStore;

abstract class _SearchHymnStoreBase with Store {
  final HymnController _hymnController = HymnController();

  TextEditingController text = TextEditingController();

  @observable
  ObservableList<HymnModel>? hymns = ObservableList<HymnModel>();

  void setSearch(
    SearchHymnStore controller,
    BuildContext context,
  ) {
    controller.search(context);
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> search(BuildContext context) async {
    hymns = ObservableList<HymnModel>();

    List<HymnModel>? tempHymns = await _hymnController.listHymnByText(
      text.text,
    );

    if (tempHymns != null) {
      hymns!.addAll(tempHymns);
    }
  }

  void clear() {
    hymns = ObservableList<HymnModel>();
    text.text = '';
  }
}
