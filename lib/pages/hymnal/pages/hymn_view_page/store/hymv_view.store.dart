import 'package:mobx/mobx.dart';

import '../../../../../controllers/indice.controller.dart';
part 'hymv_view.store.g.dart';

class HymnViewStore = _HymnViewStoreBase with _$HymnViewStore;

abstract class _HymnViewStoreBase with Store {
  final IndiceController _indiceController = IndiceController();

  @observable
  List<String> indices = [];

  @action
  Future<void> verifyIndice(String number) async {
    List<String>? indicesResponse = await _indiceController.getHymnByNumber(
      number,
    );

    if (indicesResponse != null) {
      indices = indicesResponse;
    }
  }
}
