import 'package:hinario_flutter/controllers/shared_preferences.controller.dart';
import 'package:mobx/mobx.dart';
part 'configuration.store.g.dart';

class ConfigurationStore = _ConfigurationStoreBase with _$ConfigurationStore;

abstract class _ConfigurationStoreBase with Store {
  _ConfigurationStoreBase() {
    init();
  }

  final SharedPreferencesController _sharedPreferencesController =
      SharedPreferencesController();

  @observable
  int adjustFontSize = 0;

  @action
  void increment() {
    adjustFontSize++;

    _sharedPreferencesController.insertData(
      'adjustFontSize',
      adjustFontSize.toString(),
    );
  }

  @action
  void decrement() {
    adjustFontSize--;

    _sharedPreferencesController.insertData(
      'adjustFontSize',
      adjustFontSize.toString(),
    );
  }

  //init
  @action
  void init() {
    _sharedPreferencesController.readData('adjustFontSize').then((value) {
      if (value != null) {
        adjustFontSize = int.parse(value);
      }
    });
  }
}
