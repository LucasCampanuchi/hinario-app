import 'package:flutter/material.dart';

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
        /* color: AppColors.primary, */
        color: const Color.fromARGB(255, 62, 90, 134),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: height * 0.18,
                    width: height * 0.18,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                          offset: Offset(15.0, 10.0),
                          blurRadius: 55.0,
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.black26,
                      radius: (height * 0.125),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icon/icon.png',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.transparent,
                        offset: Offset(5.0, 0.0),
                        blurRadius: 25.0,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(
                          height: 25,
                        ),
                        Center(
                          child: Wrap(
                            crossAxisAlignment:
                                MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? WrapCrossAlignment.center
                                    : WrapCrossAlignment.start,
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
                                route: '/list',
                                title: 'Leitura Diária',
                                icon: Icons.library_books_sharp,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
