import 'package:mobx/mobx.dart';

import '../../../../../controllers/shared_preferences.controller.dart';
part 'verse_font_size.store.g.dart';

class VerseFontSizeStore = _VerseFontSizeStoreBase with _$VerseFontSizeStore;

abstract class _VerseFontSizeStoreBase with Store {
  final SharedPreferencesController _sharedPreferencesController =
      SharedPreferencesController();

  _VerseFontSizeStoreBase() {
    init();
  }

  @observable
  double fontSize = 18;

  @action
  void adjustFontSize(double value) {
    fontSize = value;

    _sharedPreferencesController.insertData(
      'fontSizeVerseText',
      fontSize.toString(),
    );
  }

  //init
  @action
  void init() {
    _sharedPreferencesController.readData('fontSizeVerseText').then((value) {
      if (value != null) {
        fontSize = double.parse(value);
      }
    });
  }
}
