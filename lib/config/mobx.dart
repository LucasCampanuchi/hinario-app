import 'package:get_it/get_it.dart';

import '../pages/cifras/pages/cifras_web_page/store/cifras_web.store.dart';

Future<void> mobx() async {
  GetIt getIt = GetIt.I;

  getIt.registerSingleton<CifrasWebStore>(
    CifrasWebStore(),
  );
}
