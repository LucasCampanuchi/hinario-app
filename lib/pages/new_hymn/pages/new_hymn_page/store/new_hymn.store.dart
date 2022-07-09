import 'package:mobx/mobx.dart';

import '../../../../../controllers/new_hymn.controller.dart';
import '../../../../../models/new_hymn.model.dart';
part 'new_hymn.store.g.dart';

class NewHymnStore = _NewHymnStoreBase with _$NewHymnStore;

abstract class _NewHymnStoreBase with Store {
  final NewHymnController _newHymnController = NewHymnController();

  @observable
  ObservableList<NewHymnModel> hymns = ObservableList<NewHymnModel>();

  @action
  Future<void> getAll() async {
    List<NewHymnModel>? tempHymns = await _newHymnController.getAll();

    if (tempHymns != null) {
      hymns.addAll(tempHymns);
    }
  }

  @action
  void clear() {
    hymns = ObservableList<NewHymnModel>();
  }

  @action
  void init() {
    clear();
    getAll();
  }
}
