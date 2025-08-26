import 'package:flutter_modular/flutter_modular.dart';
import 'package:hinario_flutter/pages/hymnal/pages/score_page/view/score_page.dart';
import 'package:hinario_flutter/pages/cifras/pages/cifras_page/view/cifras_page.dart';
import 'package:hinario_flutter/pages/cifras/pages/cifra_view_page/view/cifra_view_page.dart';
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
  AppModule();

  @override
  void routes(r) {
    r.child(
      '/',
      child: (context) => const HomePage(),
    );

/*  */
/*  */

    r.child(
      '/books',
      child: (context) => const BooksPage(),
    );

    r.child(
      '/verses',
      child: (context) => VersesPage(
        book: r.args.data['book'],
        chapter: r.args.data['chapter'],
        verse: r.args.data['verse'],
      ),
    );

    r.child(
      '/searchbible',
      child: (context) => const SearchPage(),
    );

    r.child(
      '/keyboardhymn',
      child: (context) => const KeyboardPage(),
    );

    r.child(
      '/hymnview',
      child: (context) => HymnView(
        hymn: r.args.data['hymn'],
      ),
    );

    r.child(
      '/searchhymn',
      child: (context) => const SearchHymnPage(),
    );

    r.child(
      '/score',
      child: (context) => ScorePage(
        hymn: r.args.data['hymn'],
      ),
    );

    r.child(
      '/newhymn',
      child: (context) => const NewHymnPage(),
    );

    r.child(
      '/newhymnview',
      child: (context) => NewHymnViewPage(
        hymn: r.args.data['hymn'],
      ),
    );

    r.child(
      '/indice',
      child: (context) => IndicePage(
        hymn: r.args.data['hymn'],
      ),
    );

    r.child(
      '/cifras',
      child: (context) => const CifrasPage(),
    );

    r.child(
      '/cifra_view',
      child: (context) => CifraViewPage(
        cifra: r.args.data['cifra'],
      ),
    );

    r.child(
      '/read',
      child: (context) => ReadPage(
        file: r.args.data['file'],
      ),
    );

    r.child(
      '/read_image',
      child: (context) => ReadImagePage(
        image: r.args.data['image'],
      ),
    );
  }
}
