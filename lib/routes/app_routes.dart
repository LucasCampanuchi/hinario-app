import 'package:flutter_modular/flutter_modular.dart';

import '../pages/books_page/view/books_page.dart';
import '../pages/home_page/view/home_page.dart';
import '../pages/verses_page/view/verses_page.dart';

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
      ];
}
