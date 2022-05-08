import 'package:get_it/get_it.dart';
import 'package:hinario_flutter/pages/home_page/store/home.store.dart';

import '../pages/books_page/store/books.store.dart';
import '../pages/verses_page/store/verses.store.dart';

Future<void> mobx() async {
  GetIt getIt = GetIt.I;
  getIt.registerSingleton<BooksStore>(
    BooksStore(),
  );
  getIt.registerSingleton<HomeStore>(
    HomeStore(),
  );
  getIt.registerSingleton<VersesStore>(
    VersesStore(),
  );
}
