import 'package:flutter_modular/flutter_modular.dart';

import '../pages/bible/pages/books_page/view/books_page.dart';
import '../pages/bible/pages/search_page/view/search_page.dart';
import '../pages/bible/pages/verses_page/view/verses_page.dart';
import '../pages/home_page/view/home_page.dart';
import '../pages/hymnal/pages/hymn_view_page/view/hymn_view.dart';
import '../pages/hymnal/pages/keyboard_page/view/keyboard_page.dart';
import '../pages/hymnal/pages/search_hymn_page/view/search_hymn_page.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (context, args) => const HomePage(),
        ),
        ChildRoute(
          '/books',
          child: (context, args) => const BooksPage(),
        ),
        ChildRoute(
          '/verses',
          child: (context, args) => VersesPage(
            book: args.data['book'],
            chapter: args.data['chapter'],
          ),
        ),
        ChildRoute(
          '/searchbible',
          child: (context, args) => const SearchPage(),
        ),
        ChildRoute(
          '/keyboardhymn',
          child: (context, args) => const KeyboardPage(),
        ),
        ChildRoute(
          '/hymnview',
          child: (context, args) => HymnView(
            hymn: args.data['hymn'],
          ),
        ),
        ChildRoute(
          '/searchhymn',
          child: (context, args) => const SearchHymnPage(),
        ),
      ];
}
