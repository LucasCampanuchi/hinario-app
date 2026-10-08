import 'package:flutter_modular/flutter_modular.dart';
import 'package:hinario_flutter/pages/hymnal/pages/score_page/view/score_page.dart';
import 'package:hinario_flutter/pages/cifras/pages/cifras_page/view/cifras_page.dart';
import 'package:hinario_flutter/pages/cifras/pages/cifra_view_page/view/cifra_view_page.dart';
import 'package:hinario_flutter/pages/read/pages/read_page/view/read_page.dart';
import 'package:hinario_flutter/pages/read_image_page/view/read_image_page.dart';

import '../pages/bible/pages/books_page/view/books_page.dart';
import '../pages/bible/pages/favorites_page/view/bible_favorites_page.dart';
import '../pages/bible/pages/search_page/view/search_page.dart';
import '../pages/bible/pages/verses_page/view/verses_page.dart';
import '../pages/home_page/view/home_page.dart';
import '../pages/hymnal/pages/hymn_view_page/view/hymn_view.dart';
import '../pages/hymnal/pages/indice_page/view/indice_page.dart';
import '../pages/hymnal/pages/keyboard_page/view/keyboard_page.dart';
import '../pages/hymnal/pages/search_hymn_page/view/search_hymn_page.dart';
import '../pages/new_hymn/pages/new_hymn_page/view/new_hymn_page.dart';
import '../pages/new_hymn/pages/new_hymn_view_page/view/hymn_view.dart';
import '../pages/playlists/views/playlists_page.dart';

class AppModule extends Module {
  AppModule();

  @override
  void routes(r) {
    void page(String name, ModularChild child) {
      r.child(
        name,
        child: child,
        transition: TransitionType.rightToLeftWithFade,
        duration: const Duration(milliseconds: 260),
      );
    }

    r.child('/', child: (context) => const HomePage());

    /*  */
    /*  */

    page('/books', (context) => const BooksPage());

    page('/biblefavorites', (context) => const BibleFavoritesPage());

    page(
      '/verses',
      (context) => VersesPage(
        book: r.args.data['book'],
        chapter: r.args.data['chapter'],
        verse: r.args.data['verse'],
      ),
    );

    page('/searchbible', (context) => const SearchPage());

    page('/keyboardhymn', (context) => const KeyboardPage());

    page('/hymnview', (context) => HymnView(hymn: r.args.data['hymn']));

    page('/searchhymn', (context) => const SearchHymnPage());

    page('/score', (context) => ScorePage(hymn: r.args.data['hymn']));

    page('/newhymn', (context) => const NewHymnPage());

    page(
      '/newhymnview',
      (context) => NewHymnViewPage(hymn: r.args.data['hymn']),
    );

    page('/indice', (context) => IndicePage(hymn: r.args.data['hymn']));

    page('/cifras', (context) => const CifrasPage());

    page('/playlists', (context) => const PlaylistsPage());

    page(
      '/cifra_view',
      (context) => CifraViewPage(cifra: r.args.data['cifra']),
    );

    page('/read', (context) => ReadPage(file: r.args.data['file']));

    page(
      '/read_image',
      (context) => ReadImagePage(image: r.args.data['image']),
    );
  }
}
