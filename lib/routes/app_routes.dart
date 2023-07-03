import 'package:flutter_modular/flutter_modular.dart';
import 'package:hinario_flutter/pages/hymnal/pages/score_page/view/score_page.dart';
import 'package:hinario_flutter/pages/read/pages/list_page/view/list_page.dart';
import 'package:hinario_flutter/pages/read/pages/read_page/view/read_page.dart';
import 'package:hinario_flutter/pages/read_image_page/view/read_image_page.dart';

import '../pages/bible/pages/books_page/view/books_page.dart';
import '../pages/bible/pages/search_page/view/search_page.dart';
import '../pages/bible/pages/verses_page/view/verses_page.dart';
import '../pages/home_page/view/home_page.dart';
import '../pages/hymnal/pages/hymn_view_page/view/hymn_view.dart';
import '../pages/hymnal/pages/indice_page/view/indice_page.dart';
import '../pages/hymnal/pages/keyboard_page/view/keyboard_page.dart';
import '../pages/hymnal/pages/search_hymn_page/view/search_hymn_page.dart';
import '../pages/new_hymn/pages/new_hymn_page/view/new_hymn_page.dart';
import '../pages/new_hymn/pages/new_hymn_view_page/view/hymn_view.dart';

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
            verse: args.data['verse'],
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
        ChildRoute(
          '/score',
          child: (context, args) => ScorePage(
            hymn: args.data['hymn'],
          ),
        ),
        ChildRoute(
          '/newhymn',
          child: (context, args) => const NewHymnPage(),
        ),
        ChildRoute(
          '/newhymnview',
          child: (context, args) => NewHymnViewPage(
            hymn: args.data['hymn'],
          ),
        ),
        /* IndicePage */
        ChildRoute(
          '/indice',
          child: (context, args) => IndicePage(
            hymns: args.data['hymns'],
          ),
        ),
        ChildRoute(
          '/list',
          child: (context, args) => const ListPage(),
        ),
        ChildRoute(
          '/read',
          child: (context, args) => ReadPage(
            file: args.data['file'],
          ),
        ),
        ChildRoute(
          '/read_image',
          child: (context, args) => ReadImagePage(
            image: args.data['image'],
          ),
        ),
      ];
}
