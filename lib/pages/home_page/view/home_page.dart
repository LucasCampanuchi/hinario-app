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

    final height = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: height,
            color: AppColors.primary,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                children: const [
                  ButtonHome(
                    route: '/verses',
                    title: 'Bíblia',
                    icon: Icons.menu_book_rounded,
                  ),
                  ButtonHome(
                    route: '/keyboard',
                    title: 'Hinário',
                    icon: Icons.book,
                  ),
                  ButtonHome(
                    route: '/newpage',
                    title: 'Hinos Novos',
                    icon: Icons.book_online_rounded,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: height * 0.35),
            child: Container(
              height: height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    30,
                  ),
                  topRight: Radius.circular(
                    30,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      height: 80,
                      child: const Center(
                        child: Text('Configurações'),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
