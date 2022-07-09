import 'package:get_it/get_it.dart';
import 'package:hinario_flutter/pages/home_page/store/home.store.dart';

import '../pages/bible/pages/books_page/store/books.store.dart';
import '../pages/bible/pages/search_page/store/search_bible.store.dart';
import '../pages/bible/pages/verses_page/store/verses.store.dart';
import '../pages/hymnal/pages/keyboard_page/store/keyboard.store.dart';
import '../pages/hymnal/pages/search_hymn_page/store/search_hymn.store.dart';
import '../pages/new_hymn/pages/new_hymn_page/store/new_hymn.store.dart';

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
  getIt.registerSingleton<SearchBibleStore>(
    SearchBibleStore(),
  );
  getIt.registerSingleton<KeyBoardStore>(
    KeyBoardStore(),
  );
  getIt.registerSingleton<SearchHymnStore>(
    SearchHymnStore(),
  );
  getIt.registerSingleton<NewHymnStore>(
    NewHymnStore(),
  );
}
