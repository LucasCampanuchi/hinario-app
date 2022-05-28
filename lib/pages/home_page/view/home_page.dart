import 'package:flutter/material.dart';

import '../../../layout/colors.dart';
import '../components/button.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text(
        'Bíblia e Hinário',
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );

    final double height = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: appBar,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: height,
        color: AppColors.primary,
        child: Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const [
              ButtonHome(
                route: '/verses',
                title: 'Bíblia',
                icon: Icons.menu_book_rounded,
              ),
              ButtonHome(
                route: '/keyboardhymn',
                title: 'Hinário',
                icon: Icons.book,
              ),
              ButtonHome(
                route: '/searchhymn',
                title: 'Buscar Hino',
                icon: Icons.search,
              ),
              ButtonHome(
                route: '/keyboardhymn',
                title: 'Hinos Novos',
                icon: Icons.library_books_sharp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
