import 'package:hinario_flutter/config/errors.dart';

import 'mobx.dart';

Future<void> init() async {
  await mobx();

  initErrors();
}
