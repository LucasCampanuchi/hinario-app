import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:hinario_flutter/pages/hymnal/pages/keyboard_page/widgets/modal_menu.dart';

import '../components/button.dart';
import '../components/button_icon.dart';
import '../store/keyboard.store.dart';

class KeyboardPage extends StatelessWidget {
  const KeyboardPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final KeyBoardStore controller = GetIt.I.get<KeyBoardStore>();
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF38527E),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () => modalMenu(context),
              icon: const Icon(Icons.more_vert),
            )
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFF38527E),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: size.width,
              height: size.height * 0.20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Observer(
                    builder: (_) => Text(
                      controller.num,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              children: [
                //first row
                ...['1', '2', '3', 'C'].map(
                  (e) => Button(
                    text: e,
                    ontap: () => controller.typeText(e == 'C' ? 'C-' : e),
                  ),
                ),
                //second row
                ...['4', '5', '6', 'S'].map(
                  (e) => Button(
                    text: e,
                    ontap: () => controller.typeText(e == 'S' ? 'S-' : e),
                  ),
                ),
                //third row
                ...[
                  ...['7', '8', '9'].map(
                    (e) => Button(
                      text: e,
                      ontap: () => controller.typeText(e == 'C' ? 'C+' : e),
                    ),
                  ),
                  ButtonIcon(
                    icon: Icons.backspace,
                    ontap: () => controller.clean(),
                  ),
                ],
                //fourth row
                ...[
                  const Button(),
                  Button(
                    text: '0',
                    ontap: () => controller.typeText("0"),
                  ),
                  const Button(),
                  ButtonIcon(
                    icon: Icons.check_circle_rounded,
                    sizeIcon: 32,
                    ontap: () {
                      if (controller.num != '') {
                        controller.set(context);
                      }
                    },
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}
