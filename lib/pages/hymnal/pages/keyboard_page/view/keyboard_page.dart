import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../../../layout/colors.dart';
import '../components/button.dart';
import '../store/keyboard.store.dart';

class KeyboardPage extends StatelessWidget {
  const KeyboardPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = GetIt.I.get<KeyBoardStore>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: size.width,
                height: size.height * 0.27,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Button(
                  text: '1',
                  ontap: () => controller.typeText("1"),
                ),
                Button(
                  text: '2',
                  ontap: () => controller.typeText("2"),
                ),
                Button(
                  text: '3',
                  ontap: () => controller.typeText("3"),
                ),
                Button(
                  text: 'C',
                  ontap: () => controller.typeText("C-"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Button(
                  text: '4',
                  ontap: () => controller.typeText("4"),
                ),
                Button(
                  text: '5',
                  ontap: () => controller.typeText("5"),
                ),
                Button(
                  text: '6',
                  ontap: () => controller.typeText("6"),
                ),
                Button(
                  text: 'S',
                  ontap: () => controller.typeText("S-"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Button(
                  text: '7',
                  ontap: () => controller.typeText("7"),
                ),
                Button(
                  text: '8',
                  ontap: () => controller.typeText("8"),
                ),
                Button(
                  text: '9',
                  ontap: () => controller.typeText("9"),
                ),
                Button(
                  text: 'Limpar',
                  ontap: () => controller.clean(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Button(),
                Button(
                  text: '0',
                  ontap: () => controller.typeText("0"),
                ),
                const Button(),
                Button(
                  text: 'Ok',
                  ontap: () {
                    if (controller.num != '') {
                      controller.set(context);
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
