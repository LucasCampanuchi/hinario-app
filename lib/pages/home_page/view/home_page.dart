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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Image.asset(
                'assets/icon/icon.png',
                width: MediaQuery.of(context).size.width,
                height: height * 0.25,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(
                  top: 25,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        height: 25,
                      ),
                      Center(
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
                            ButtonHome(
                              route: '/keyboardhymn',
                              title: 'Configurações',
                              icon: Icons.settings,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
